enum MatchClauseKind {
	DEFAULT
	ARRAY
	NUMBER
	OBJECT
}

enum TestKind {
	ARRAY
	OBJECT
}

namespace $match {
	func length(binding: ArrayBinding) { # {{{
		var mut min = 0
		var mut max = 0

		for var element in binding.elements() {
			min += element.min()
			max += element.max()
		}

		return {
			min: min
			max: max
		}
	} # }}}

	func length(elements: []) { # {{{
		var mut min = 0
		var mut max = 0

		for var element in elements {
			if element.spread {
				max = Infinity
			}
			else {
				min += 1
				max += 1
			}
		}

		return {
			min: min
			max: max
		}
	} # }}}

	export length
}

class MatchStatement extends Statement {
	private late {
		@bindingScope: Scope
		@castingEnum: Boolean				= false
		@clauses							= []
		@declaration: VariableDeclaration?
		@hasDeclaration: Boolean			= false
		@hasDefaultClause: Boolean			= false
		@hasLateInitVariables: Boolean		= false
		@initializedVariables: Object		= {}
		@lateInitVariables					= {}
		@name: String?						= null
		@nextClauseIndex: Number
		@reusableValue: Boolean				= false
		@tests								= {}
		@usingFallthrough: Boolean			= false
		@value								= null
		@valueType: Type
	}
	override initiate() { # {{{
		if ?@data.declaration {
			@hasDeclaration = true

			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@declaration = VariableDeclaration.new(@data.declaration, this, @bindingScope, @scope:Scope, false)
			@declaration.initiate()
		}
		else {
			@bindingScope = @scope!?
		}
	} # }}}
	override analyse() { # {{{
		if @hasDeclaration {
			@declaration.analyse()
		}
		else {
			@value = $compile.expression(@data.expression, this)
			@value.analyse()

			@reusableValue = @value is not IdentifierLiteral
		}

		var dyn condition, binding
		for var data, index in @data.clauses {
			var clause = {
				hasTest: ?data.filter
				bindings: []
				conditions: []
				scope: @newScope(@bindingScope, ScopeType.InlineBlock)
			}

			@clauses.push(clause)

			clause.scope.index = index

			var filter = MatchFilter.new(data, this, clause.scope)

			filter.analyse()

			if filter.hasTest() {
				clause.hasTest = true
			}
			else if @hasDefaultClause {
				throw NotSupportedException.new(this)
			}
			else {
				@hasDefaultClause = true
			}

			clause.filter = filter

			clause.body = $compile.block(data.body, this, clause.scope)
		}

		for var clause in @clauses {
			clause.body.analyse()
		}

		if @hasLateInitVariables && !@hasDefaultClause {
			for var value, name of @lateInitVariables when value.variable.isImmutable() {
				SyntaxException.throwMissingAssignmentMatchNoDefault(name, this)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @hasDeclaration {
			@declaration.prepare(AnyType.NullableUnexplicit)

			if var variable ?= @declaration.getIdentifierVariable() {
				@name = variable.getSecureName()
				@valueType = variable.getRealType().setNullable(false)

				variable.setRealType(@valueType)
			}
			else {
				throw NotSupportedException.new()
			}
		}
		else {
			@value.prepare(AnyType.NullableUnexplicit)

			@valueType = @value.type()

			if @reusableValue {
				@name = @scope.acquireTempName(false)
			}
			else {
				@name = @scope.getVariable(@data.expression.name).getSecureName()
			}
		}

		var inferables = {}
		var mut enumConditions = 0
		var mut maxConditions = 0

		var mut maxInferables = @clauses.length

		for var clause, index in @clauses {
			clause.filter.prepare(@scope.reference('Boolean'))

			enumConditions += clause.filter:MatchFilter.getEnumConditions()
			maxConditions += clause.filter:MatchFilter.getMaxConditions()

			clause.body.prepare(target)

			if @usingFallthrough {
				clause.name = @scope.acquireTempName(false)
			}

			if clause.body.isExit() {
				maxInferables -= 1
			}
			else {
				for var data, name of clause.body.scope().listUpdatedInferables() {
					if ?inferables[name] {
						if inferables[name].union {
							inferables[name].data.type.addType(data.type)
						}
						else if !data.type.equals(inferables[name].data.type) {
							inferables[name].data.type = Type.union(@scope, inferables[name].data.type, data.type)
							inferables[name].union = inferables[name].data.type.isUnion()
						}

						inferables[name].count += 1
					}
					else {
						inferables[name] = {
							count: 1
							union: false
							data
						}
					}
				}
			}
		}

		for var test of @tests when test.count > 1 {
			test.name = @scope.acquireTempName(false)

			test.tests = [test.name]
		}

		for var test of @tests when test.count == 1 {
			if test.kind == TestKind.ARRAY {
				var { testingType, minmax?, type? } = test

				if testingType && ?minmax && ?type {
					var conditionHash = `$Array,\(testingType),\(JSON.stringify(minmax ?? '')),`
					var bindingHash = `$Array,false,"",\(type?.hashCode() ?? '')`

					// TODO
					// if {
					// 	var condition ?= @tests[conditionHash]
					// 	var binding ?= @tests[bindingHash]
					// }
					// then {
					// }
					if ?@tests[conditionHash] && ?@tests[bindingHash] {
						@tests[conditionHash].count += 1
						@tests[bindingHash].count += 1

						if !?@tests[conditionHash].name {
							@tests[conditionHash].name = @scope.acquireTempName(false)
						}
						if !?@tests[bindingHash].name {
							@tests[bindingHash].name = @scope.acquireTempName(false)
						}

						test.tests = [@tests[conditionHash].name, @tests[bindingHash].name]
					}
				}
			}
		}

		if enumConditions != 0 {
			if @valueType.canBeEnum(false) {
				pass
			}
			else {
				for var clause in @clauses {
					clause.filter.setCastingEnum(true)
				}

				if @valueType.isAny() || @valueType.canBeEnum() {
					@castingEnum = true

					if !@reusableValue {
						@name = @scope.acquireTempName(false)

						@reusableValue = true
					}
				}
			}
		}

		for var data, name of @initializedVariables {
			var types = []
			var mut initializable = true

			for var clause, index in data.clauses {
				if clause.initializable {
					types.push(clause.type)
				}
				else if !@clauses[index].body.isExit() {
					initializable = false

					break
				}
			}

			if initializable {
				data.variable.type = Type.union(@scope, ...types)

				@parent.initializeVariable(data.variable, this, this)
			}
		}

		for var data, name of @lateInitVariables {
			var types = []

			for var clause, index in data.clauses {
				if clause.initializable {
					types.push(clause.type)
				}
				else if !@clauses[index].body.isExit() {
					SyntaxException.throwMissingAssignmentMatchClause(name, @clauses[index].body)
				}
			}

			var type = Type.union(@scope, ...types)

			@parent.initializeVariable(VariableBrief.new(name, type), this, this)
		}

		for var inferable, name of inferables {
			if inferable.count == maxInferables {
				@bindingScope.updateInferable(name, inferable.data, this)
			}
			else if inferable.data.isVariable {
				@bindingScope.replaceVariable(name, inferable.data.type, true, false, this)
			}
		}


		if @reusableValue {
			@scope.releaseTempName(@name)
		}
	} # }}}
	translate() { # {{{
		if @hasDeclaration {
			@declaration.translate()
		}
		else {
			@value.translate()
		}

		for var clause in @clauses {
			clause.filter.translate()

			clause.body.translate()
		}
	} # }}}
	addInitializableVariable(variable, node) { # {{{
		var name = variable.name()

		if !@hasDefaultClause {
			SyntaxException.throwMissingAssignmentMatchNoDefault(name, this)
		}

		var mut clauseIndex = -1
		for var clause, index in @clauses {
			if clause.body == node {
				clauseIndex = index

				break
			}
		}

		if var map ?= @lateInitVariables[name] {
			map.clauses[clauseIndex] = {
				initializable: true
				type: null
			}
		}
		else {
			var map = {
				variable
				clauses: []
			}

			for var i from 0 to~ @data.clauses.length {
				if i == clauseIndex {
					map.clauses[i] = {
						initializable: true
						type: null
					}
				}
				else {
					map.clauses[i] = {
						initializable: false
						type: null
					}
				}
			}

			@lateInitVariables[name] = map
		}

		@hasLateInitVariables = true

		@parent.addInitializableVariable(variable, node)
	} # }}}
	addArrayTest(testingType: Boolean, minmax: Object?, type: Type?) { # {{{
		var hash = `$Array,\(testingType),\(JSON.stringify(minmax ?? '')),\(type?.hashCode() ?? '')`

		if var data ?= @tests[hash] {
			data.count += 1
		}
		else {
			@tests[hash] = {
				kind: TestKind.ARRAY
				count: 1
				testingType
				minmax
				type
			}
		}
	} # }}}
	addObjectTest(testingType: Boolean, type: Type?) { # {{{
		var hash = `$Object,\(testingType),\(type?.hashCode() ?? '')`

		if var data ?= @tests[hash] {
			data.count += 1
		}
		else {
			@tests[hash] = {
				kind: TestKind.OBJECT
				count: 1
				testingType
				type
			}
		}
	} # }}}
	defineVariables(left, scope) { # {{{
		for var { name } in left.listAssignments([]) {
			if scope.hasDefinedVariable(name) {
				SyntaxException.throwAlreadyDeclared(name, this)
			}
			else if @options.rules.noUndefined {
				ReferenceException.throwNotDefined(name, this)
			}
			else {
				scope.define(name, false, AnyType.NullableUnexplicit, true, this)
			}
		}
	} # }}}
	flagUsingFallthrough() { # {{{
		@usingFallthrough = true

		return this
	} # }}}
	getArrayTests(testingType: Boolean, minmax: Object?, type: Type?) { # {{{
		var hash = `$Array,\(testingType),\(JSON.stringify(minmax ?? '')),\(type?.hashCode() ?? '')`

		if var data ?= @tests[hash]; ?data.tests {
			return data.tests
		}

		if testingType {
			var hash1 = `$Array,true,\(JSON.stringify(minmax ?? '')),`
			var hash2 = `$Array,false,\(JSON.stringify(minmax ?? '')),\(type?.hashCode() ?? '')`

			if ?@tests[hash1]?.tests && ?@tests[hash2]?.tests {
				var tests = [...@tests[hash1].tests, ...@tests[hash2].tests]

				@tests[hash] ??= {}
				@tests[hash].tests = tests

				return tests
			}
		}
		else {
			var hash1 = `$Array,true,\(JSON.stringify(minmax ?? '')),\(type?.hashCode() ?? '')`

			if var data ?= @tests[hash1]; ?data.tests {
				var tests = data.tests

				@tests[hash] ??= {}
				@tests[hash].tests = tests

				return tests
			}
		}

		return null
	} # }}}
	getObjectTests(testingType: Boolean, type: Type?) { # {{{
		var hash = `$Object,\(testingType),\(type?.hashCode() ?? '')`

		if var data ?= @tests[hash]; ?data.tests {
			return data.tests
		}
		else {
			return null
		}
	} # }}}
	getValueType() => @valueType
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		var {name, type} = variable

		if var map ?= @lateInitVariables[name] {
			var mut clause = null

			for var cc, i in @clauses {
				if cc.body == node {
					unless ?map.clauses[i] {
						ReferenceException.throwImmutable(name, expression)
					}

					clause = map.clauses[i]

					break
				}
			}

			if clause.type != null {
				if variable.isImmutable() {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(clause.type) {
					TypeException.throwInvalidAssignement(name, clause.type, type, expression)
				}
			}
			else {
				clause.type = type
			}

			var clone = node.scope().getVariable(name).clone()

			if clone.isDefinitive() {
				clone.setRealType(type)
			}
			else {
				clone.setDeclaredType(type, true).flagDefinitive()
			}

			node.scope().replaceVariable(name, clone)
		}
		else if !@hasDefaultClause {
			pass
		}
		else if var map ?= @initializedVariables[name] {
			var mut clause = null

			for var cc, i in @clauses {
				if cc.body == node {
					unless ?map.clauses[i] {
						ReferenceException.throwImmutable(name, expression)
					}

					clause = map.clauses[i]

					break
				}
			}

			if clause.type != null {
				if variable.isImmutable() {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(clause.type) {
					TypeException.throwInvalidAssignement(name, clause.type, type, expression)
				}
			}
			else {
				clause.type = type
				clause.initializable = true
			}

			node.scope().updateInferable(name, variable, expression)
		}
		else {
			var map = {
				variable
				clauses: []
			}

			for var clause, index in @clauses {
				if clause.body == node {
					map.clauses[index] = {
						initializable: true
						type
					}
				}
				else {
					map.clauses[index] = {
						initializable: false
						type: null
					}
				}
			}

			@initializedVariables[name] = map
		}
	} # }}}
	isExit() { # {{{
		unless @hasDefaultClause {
			return false
		}

		for var clause in @clauses {
			if !clause.body.isExit() {
				return false
			}
		}

		return true
	} # }}}
	isJumpable() => true
	isInitializingInstanceVariable(name) { # {{{
		return false unless @hasDefaultClause

		for var clause in @clauses {
			return false unless clause.filter.isInitializingInstanceVariable(name) || clause.body.isInitializingInstanceVariable(name)
		}

		return true
	} # }}}
	isInitializingStaticVariable(name) { # {{{
		return false unless @hasDefaultClause

		for var clause in @clauses {
			return false unless clause.filter.isInitializingStaticVariable(name) || clause.body.isInitializingStaticVariable(name)
		}

		return true
	} # }}}
	isLateInitializable() => true
	isUsingVariable(name) { # {{{
		if @hasDeclaration {
			if @declaration.isUsingVariable(name) {
				return true
			}
		}
		else {
			if @value.isUsingVariable(name) {
				return true
			}
		}

		for var clause in @clauses {
			if clause.body.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	throwExpectedType(type: String): Never ~ TypeException { # {{{
		TypeException.throwExpectedType(@hasDeclaration ? @name : @value.toQuote(), type, this)
	} # }}}
	toFallthroughFragments(fragments) { # {{{
		if @nextClauseIndex < @clauses.length {
			fragments.line(`\(@clauses[@nextClauseIndex].name)()`)
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @clauses.length == 0 {
			return
		}

		if @hasDeclaration {
			fragments.compile(@declaration)
		}
		else if @reusableValue {
			var line = fragments.newLine().code($runtime.scope(this), @name, ' = ')

			if @castingEnum {
				if @valueType.isEnum() {
					line.compile(@value).code('.value')
				}
				else if @valueType.isAny() {
					line.code($runtime.helper(this), '.valueOf(').compile(@value).code(')')
				}
				else {
					line.compile(@value)
				}
			}
			else {
				line.compile(@value)
			}

			line.done()
		}
		else if @castingEnum {
			var line = fragments.newLine().code($runtime.scope(this), @name, ' = ')

			if @valueType.isEnum() {
				line.code(@data.expression.name, '.value')
			}
			else if @valueType.isAny() {
				line.code($runtime.helper(this), '.valueOf(', @data.expression.name, ')')
			}
			else {
				line.code(@data.expression.name)
			}

			line.done()
		}

		for var test of @tests when test.count > 1 {
			var line = fragments.newLine()

			line.code(`\($runtime.scope(this))\(test.name) = \($runtime.helper(this)).memo(`)

			if test.kind == TestKind.ARRAY {
				var { testingType, minmax?, type? } = test

				if ?type {
					type.toTestFragments(@name, testingType, ?minmax, line, this)
				}
				else if ?minmax {
					var { min, max } = minmax

					line.code(`\($runtime.type(this)).isDexArray(\(@name), \(testingType ? 1 : 0), \(min), \(max == Infinity ? 0 : max))`)
				}
				else {
					line.code(`\($runtime.type(this)).isDexArray(\(@name), \(testingType ? 1 : 0))`)
				}
			}
			else {
				var { testingType, type? } = test

				if ?type {
					type.toTestFragments(@name, testingType, line, this)
				}
				else {
					line.code(`\($runtime.type(this)).isDexObject(\(@name), \(testingType ? 1 : 0))`)
				}
			}

			line.code(')').done()
		}

		if @usingFallthrough {
			for var clause, clauseIdx in @clauses {
				var line = fragments.newLine().code(`\($runtime.scope(this))\(clause.name) = () =>`)
				var block = line.newBlock()

				@nextClauseIndex = clauseIdx + 1

				clause.filter.toBindingFragments(block, @name)

				clause.body.toFragments(block, mode)

				block.done()
				line.done()
			}
		}

		var mut ctrl = fragments.newControl()

		for var clause, clauseIdx in @clauses {
			if clause.hasTest {
				if clauseIdx != 0 {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}

				clause.filter.toConditionFragments(ctrl, @name)

				ctrl.code(')').step()

				if @usingFallthrough {
					ctrl.line(`\(clause.name)()`)
				}
				else {
					clause.filter.toBindingFragments(ctrl, @name)

					clause.body.toFragments(ctrl, mode)
				}
			}
			else {
				if clauseIdx != 0 {
					ctrl.step().code('else')
				}
				else {
					ctrl.code('if(true)')
				}

				ctrl.step()

				if @usingFallthrough {
					ctrl.line(`\(clause.name)()`)
				}
				else {
					clause.filter.toBindingFragments(ctrl, @name)

					clause.body.toFragments(ctrl, mode)
				}
			}
		}

		ctrl.done()
	} # }}}
	value() => @value
}

class MatchBindingArray extends AbstractNode {
	private late {
		@binding
		@minmax
		@testingLength: Boolean			= true
		@testingProperties: Boolean		= true
		@testingType: Boolean			= true
	}
	analyse() { # {{{
		@binding = $compile.expression(@data, this)
		@binding.setAssignment(AssignmentType.Declaration)
		@binding.analyse()

		@minmax = $match.length(@binding)

		if @minmax.max == Infinity {
			@testingLength = false
		}

		@parent.defineVariables(@binding, @scope)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@binding.prepare()

		@testingType &&= !@parent.getValueType().isArray()
		@testingProperties = @binding.type().isTestingProperties()

		if @testingType || @testingLength || @testingProperties {
			@parent.addArrayTest(@testingType, @minmax, @testingProperties ? @binding.type() : null)
		}
	} # }}}
	translate() { # {{{
		@binding.translate()
	} # }}}
	getMinMax() => @minmax
	toFragments(fragments, mode) { # {{{
		fragments.compile(@binding)
	} # }}}
	toBindingFragments(fragments, name) { # {{{
		var value = Literal.new(name, this)

		var mut line = fragments.newLine()

		line.code($runtime.scope(this))

		@binding.toAssignmentFragments(line, value)

		line.done()
	} # }}}
	toConditionFragments(fragments, name, junction) { # {{{
		return unless @testingLength || @testingType || @testingProperties

		var { min, max } = @minmax
		var type = @binding.type()

		if var tests ?= @parent.getArrayTests(@testingType, @minmax, @testingProperties ? @binding.type() : null) {
			if junction == Junction.AND {
				for var test in tests {
					fragments.code(` && \(test)()`)
				}
			}
			else {
				for var test, index in tests {
					fragments
						.code(` && `) if index > 0
						.code(`\(test)()`)
				}
			}
		}
		else if @testingLength || @testingType || @testingProperties {
			fragments.code(' && ') if junction == Junction.AND

			type.toTestFragments(name, @testingType, true, fragments, this)
		}
	} # }}}
	unflagLengthTesting() { # {{{
		@testingLength = false
	} # }}}
	unflagTypeTesting() { # {{{
		@testingType = false
	} # }}}
}

class MatchBindingObject extends AbstractNode {
	private {
		@binding
		@testingProperties: Boolean		= false
		@testingType: Boolean			= true
	}
	analyse() { # {{{
		@binding = $compile.expression(@data, this)
		@binding.setAssignment(AssignmentType.Declaration)
		@binding.analyse()

		@parent.defineVariables(@binding, @scope)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@binding.prepare()

		var bindingType = @binding.type()
		var valueType = @parent.getValueType()

		@testingType &&= !(bindingType.isBroadObject() || target.isBroadObject() || valueType.isBroadObject())
		if bindingType.isBinding() && bindingType.isTestingProperties() {
			if target.isBroadObject() && valueType.isBroadObject() {
				for var _, name of bindingType.properties() {
					unless target.hasProperty(name) || valueType.hasProperty(name) {
						@testingProperties = true

						break
					}
				}
			}
			else if target.isBroadObject() {
				for var _, name of bindingType.properties() {
					unless target.hasProperty(name) {
						@testingProperties = true

						break
					}
				}
			}
			else {
				@testingProperties = true
			}
		}

		if @testingType || @testingProperties {
			@parent.addObjectTest(@testingType, @testingProperties ? @binding.type() : null)
		}
	} # }}}
	translate() { # {{{
		@binding.translate()
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@binding)
	} # }}}
	toBindingFragments(fragments, name) { # {{{
		var value = Literal.new(name, this)

		var line = fragments.newLine()

		line.code($runtime.scope(this))

		@binding.toAssignmentFragments(line, value)

		line.done()
	} # }}}
	toConditionFragments(fragments, name, junction) { # {{{
		return unless @testingType || @testingProperties

		var type = @binding.type()

		if var tests ?= @parent.getObjectTests(@testingType, @testingProperties ? @binding.type() : null) {
			if junction == Junction.AND {
				for var test in tests {
					fragments.code(` && \(test)()`)
				}
			}
			else {
				for var test, index in tests {
					fragments
						.code(` && `) if index > 0
						.code(`\(test)()`)
				}
			}
		}
		else if @testingType || @testingProperties {
			fragments.code(' && ') if junction == Junction.AND

			type.toTestFragments(name, @testingType, fragments, this)
		}
	} # }}}
	unflagTypeTesting() { # {{{
		@testingType = false
	} # }}}
}

class MatchBindingValue extends AbstractNode {
	private late {
		@name: String
	}
	analyse() { # {{{
		var mut immutable = true
		var mut type = null

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Mutable {
				immutable = false
			}
		}

		@name = @data.name.name

		if ?@data.type {
			type = Type.fromAST(@data.type, this)
		}

		@scope.define(@name, immutable, type, true, this)
	} # }}}
	override prepare(target, targetMode)
	translate()
	toBindingFragments(fragments, name) { # {{{
		fragments.line($runtime.scope(this), @name, ' = ', name)
	} # }}}
	toConditionFragments(fragments, name, junction)
	unflagLengthTesting()
	unflagTypeTesting()
}

class MatchConditionArray extends AbstractNode {
	private late {
		@minmax
		@values				= []
		@type: Type
	}
	analyse() { # {{{
		for var mut value in @data.values {
			if value.kind != NodeKind.OmittedExpression {
				if value.kind == NodeKind.MatchConditionRange {
					value = MatchConditionRange.new(value, this)
				}
				else {
					value = MatchConditionValue.new(value, this)
				}

				value.analyse()

				@values.push(value)
			}
		}

		@minmax = $match.length(@data.values)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = ArrayType.new(@scope)

		for var value in @values {
			value.prepare()

			@type.addProperty(value.type())
		}

		@parent.addArrayTest(true, @minmax, null)
	} # }}}
	translate() { # {{{
		for value in @values {
			value.translate()
		}
	} # }}}
	isEnum() => false
	setCastingEnum(_)
	toConditionFragments(fragments, name, junction) { # {{{
		var { min, max } = @minmax

		match junction {
			Junction.AND {
				fragments.code(' && ')
			}
			Junction.OR {
				fragments.code('(')
			}
		}

		// }
		if var tests ?= @parent.getArrayTests(true, @minmax, null) {
			for var test, index in tests {
				fragments
					.code(` && `) if index > 0
					.code(`\(test)()`)
			}
		}
		else {
			fragments.code(`\($runtime.type(this)).isDexArray(\(name), 1, \(min), \(max == Infinity ? 0 : max))`)
		}

		var mut index = 0

		for var value, i in @data.values when value.kind != NodeKind.OmittedExpression {
			fragments.code(' && ')

			@values[index].toConditionFragments(fragments, `\(name)[\(i)]`, Junction.AND)

			index += 1
		}

		fragments.code(')') if junction == Junction.OR
	} # }}}
	type() => @type
}

class MatchConditionObject extends AbstractNode {
	private late {
		@isObject: Boolean	= false
		@properties			= []
		@type: Type
	}
	analyse() { # {{{
		for var data in @data.properties {
			match data.kind {
				NodeKind.ObjectMember {
					var property = {
						name: data.name.name
					}

					if ?data.value {
						property.value = value = MatchConditionValue.new(data.value, this)
						property.value.analyse()
					}

					@properties.push(property)
				}
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = ObjectType.new(@scope)

		if #@properties {
			for var { name, value? } in @properties {
				if ?value {
					value.prepare()

					@type.addProperty(name, false, value.type())
				}
				else {
					@type.addProperty(name, false, AnyType.Unexplicit)
				}
			}
		}

		@isObject = @parent.getValueType().isBroadObject()

		if !@isObject {
			@parent.addObjectTest(true, null)
		}
	} # }}}
	translate() { # {{{
		for var property in @properties when ?property.value {
			property.value.translate()
		}
	} # }}}
	isEnum() => false
	setCastingEnum(_)
	toConditionFragments(fragments, name, junction?) { # {{{
		match junction {
			Junction.AND {
				fragments.code(' && ')
			}
			Junction.OR {
				fragments.code('(')
			}
		}

		if !@isObject {
			if var tests ?= @parent.getObjectTests(true, null) {
				for var test, index in tests {
					fragments
						.code(` && `) if index > 0
						.code(`\(test)()`)
				}
			}
			else {
				fragments.code(`\($runtime.type(this)).isDexObject(\(name), 1)`)
			}
		}

		var mut index = 0

		for var property, i in @properties {
			fragments.code(' && ') if i > 0 || !@isObject

			if ?property.value {
				property.value.toConditionFragments(fragments, `\(name).\(property.name)`, Junction.AND)
			}
			else {
				fragments.code(`!\($runtime.type(this)).isNull(\(name).\(property.name))`)
			}
		}

		fragments.code(')') if !@isObject && junction == Junction.OR
	} # }}}
	type() => @type
}

class MatchConditionRange extends AbstractNode {
	private {
		@from	= true
		@left
		@right
		@to		= true
	}
	analyse() { # {{{
		if ?@data.from {
			@left = $compile.expression(@data.from, this)
		}
		else {
			@left = $compile.expression(@data.then, this)
			@from = false
		}

		if ?@data.to {
			@right = $compile.expression(@data.to, this)
		}
		else {
			@right = $compile.expression(@data.til, this)
			@to = false
		}

		@left.analyse()
		@right.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@left.prepare()
		@right.prepare()
	} # }}}
	translate() { # {{{
		@left.translate()
		@right.translate()
	} # }}}
	isEnum() => false
	setCastingEnum(_)
	toConditionFragments(fragments, name, junction) { # {{{
		fragments.code('(') if junction == Junction.OR

		fragments
			.code(name, @from ? ' >= ' : '>')
			.compile(@left)
			.code(' && ')
			.code(name, @to ? ' <= ' : '<')
			.compile(@right)

		fragments.code(')') if junction == Junction.OR
	} # }}}
	type() => @scope.reference('Number')
}

class MatchConditionType extends AbstractNode {
	private late {
		@type: Type
	}
	analyse()
	override prepare(target, targetMode) { # {{{
		@type = Type.fromAST(@data.type, this)
	} # }}}
	translate()
	isEnum() => false
	setCastingEnum(_)
	toConditionFragments(fragments, name, junction) { # {{{
		@type.toPositiveTestFragments(fragments, Literal.new(false, this, @scope:Scope, name))
	} # }}}
	type() => @type
}

class MatchConditionValue extends AbstractNode {
	private late {
		@castingEnum: Boolean	= false
		@values: Expression[]	= []
		@type: Type
	}
	analyse() { # {{{
		if @data.kind == NodeKind.JunctionExpression {
			for var operand in @data.operands {
				var value = $compile.expression(operand, this)
				value.analyse()

				@values.push(value)
			}
		}
		else {
			var value = $compile.expression(@data, this)
			value.analyse()

			@values.push(value)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @values.length == 1 {
			var value = @values[0]

			value.prepare(target)

			@type = value.type()
		}
		else {
			var types = []

			for var value in @values {
				value.prepare(target)

				types.push(value.type())
			}

			@type = Type.union(@scope, ...types)
		}
	} # }}}
	translate() { # {{{
		for var value in @values {
			value.translate()
		}
	} # }}}
	isContainer() { # {{{
		if @values.length == 1 {
			return @type.isContainer()
		}
		else {
			for var value in @values {
				return false unless value.type().isContainer()
			}

			return true
		}
	} # }}}
	isEnum() => @type.isEnum()
	setCastingEnum(@castingEnum)
	toConditionFragments(fragments, name, junction) { # {{{
		if @values.length == 1 {
			var value = @values[0]

			if @type.isContainer() {
				@type.toPositiveTestFragments(fragments, Literal.new(false, this, @scope:Scope, name))
			}
			else {
				fragments.code(name, ' === ').compile(value)

				if @castingEnum {
					if @type.isEnum() {
						fragments.code('.value')
					}
					else if @type.isAny() {
						fragments.code('.valueOf()')
					}
				}
			}
		}
		else if @values.length > 1 {
			fragments.code('(') if junction == Junction.AND

			var mut literal = null

			for var value, index in @values {
				if index > 0 {
					fragments.code(' || ')
				}

				if value.type().isContainer() {
					literal ??= Literal.new(false, this, @scope:Scope, name)

					value.type().toPositiveTestFragments(fragments, literal)
				}
				else {
					fragments.code(name, ' === ').compile(value)

					if @castingEnum {
						if @type.isEnum() {
							fragments.code('.value')
						}
						else if @type.isAny() {
							fragments.code('.valueOf()')
						}
					}
				}
			}

			fragments.code(')') if junction == Junction.AND
		}
	} # }}}
	type() => @type
	values() => @values
}

class MatchFilter extends AbstractNode {
	private late {
		@conditions				= []
		@bindings				= []
		@enumConditions: Number	= 0
		@filter					= null
		@hasTest: Boolean		= false
		@kind: MatchClauseKind	= .DEFAULT
	}
	override analyse() { # {{{
		var scope = @scope()

		for var data in @data.bindings {
			var late binding

			match data.kind {
				NodeKind.ArrayBinding {
					if @kind == .DEFAULT {
						@kind = .ARRAY
					}
					else {
						throw NotSupportedException.new(this)
					}

					binding = MatchBindingArray.new(data, @parent, scope)

					@hasTest = true
				}
				NodeKind.ObjectBinding {
					if @kind == .DEFAULT {
						@kind = .OBJECT
					}
					else {
						throw NotSupportedException.new(this)
					}

					binding = MatchBindingObject.new(data, @parent, scope)

					@hasTest = true
				}
				else {
					binding = MatchBindingValue.new(data, @parent, scope)
				}
			}

			binding.analyse()

			@bindings.push(binding)
		}

		if #@data.conditions {
			@hasTest = true

			for var data in @data.conditions {
				var late condition

				match data.kind {
					NodeKind.MatchConditionArray {
						if @kind == .ARRAY {
							pass
						}
						else if @kind == .DEFAULT {
							@kind = .ARRAY
						}
						else {
							throw NotSupportedException.new(this)
						}

						condition = MatchConditionArray.new(data, @parent, scope)

						for var binding in @bindings {
							binding
								..unflagLengthTesting()
								..unflagTypeTesting()
						}
					}
					NodeKind.MatchConditionObject {
						if @kind == .OBJECT {
							pass
						}
						else if @kind == .DEFAULT {
							@kind = .OBJECT
						}
						else {
							throw NotSupportedException.new(this)
						}

						condition = MatchConditionObject.new(data, @parent, scope)

						for var binding in @bindings {
							binding.unflagTypeTesting()
						}
					}
					NodeKind.MatchConditionRange {
						if @kind == .NUMBER {
							pass
						}
						else if @kind == .DEFAULT {
							@kind = .NUMBER
						}
						else {
							throw NotSupportedException.new(this)
						}

						condition = MatchConditionRange.new(data, @parent, scope)
					}
					NodeKind.MatchConditionType {
						condition = MatchConditionType.new(data, @parent, scope)

						for var binding in @bindings {
							binding.unflagTypeTesting()
						}
					}
					else {
						condition = MatchConditionValue.new(data, @parent, scope)
					}
				}

				condition.analyse()

				@conditions.push(condition)
			}
		}

		if ?@data.filter {
			@filter = $compile.expression(@data.filter, this)
			@filter.analyse()

			@hasTest = true
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		var valueType = @parent().getValueType()

		match @kind {
			.ARRAY {
				if valueType.isArray() || valueType.canBeArray() {
					pass
				}
				else {
					@parent.throwExpectedType('Array')
				}
			}
			.NUMBER {
				if valueType.isNumber() || valueType.canBeNumber() {
					pass
				}
				else {
					@parent.throwExpectedType('Number')
				}
			}
			.OBJECT {
				if valueType.isObject() || valueType.canBeObject() {
					pass
				}
				else {
					@parent.throwExpectedType('Object')
				}
			}
		}

		var types = []

		for var condition in @conditions {
			condition.prepare()

			if condition is MatchConditionValue {
				if condition.isEnum() {
					@enumConditions += 1

					types.push(condition.type().reference(@scope))
				}
				else if condition.isContainer() {
					for var binding in @bindings {
						binding.unflagTypeTesting()
					}

					types.push(condition.type().reference(@scope))
				}
			}
			else {
				types.push(condition.type())
			}
		}

		var conditionType = Type.union(@scope, ...types)

		for var binding in @bindings {
			binding.prepare(conditionType)
		}

		@filter?.prepare(target)
	} # }}}
	override translate() { # {{{
		for var condition in @conditions {
			condition.translate()
		}

		for var binding in @bindings {
			binding.translate()
		}

		@filter?.translate()
	} # }}}
	conditions() => @conditions
	getEnumConditions(): Number => @enumConditions
	getMaxConditions(): Number => @conditions.length
	hasTest() => @hasTest
	isInitializingInstanceVariable(name) { # {{{
		return @filter?.isInitializingInstanceVariable(name)
	} # }}}
	isInitializingStaticVariable(name) { # {{{
		return @filter?.isInitializingStaticVariable(name)
	} # }}}
	setCastingEnum(castingEnum: Boolean) { # {{{
		for var condition in @conditions {
			condition.setCastingEnum(castingEnum)
		}
	} # }}}
	toBindingFragments(fragments, name) { # {{{
		for var binding in @bindings {
			binding.toBindingFragments(fragments, name)
		}
	} # }}}
	toConditionFragments(fragments, name) { # {{{
		var mut junction = Junction.NONE

		if #@conditions {
			if @conditions.length == 1 {
				@conditions[0].toConditionFragments(fragments, name, junction)
			}
			else {
				var wrap = #@bindings || ?@filter

				fragments.code('(') if wrap

				@conditions[0].toConditionFragments(fragments, name, Junction.NONE)

				for var condition in @conditions from 1 {
					fragments.code(' || ')

					condition.toConditionFragments(fragments, name, Junction.OR)
				}

				fragments.code(')') if wrap
			}

			junction = .AND
		}

		if #@bindings {
			for var binding in @bindings {
				binding.toConditionFragments(fragments, name, junction)
			}

			junction = .AND
		}

		if ?@filter {
			fragments.code(' && ') if junction == .AND

			if #@bindings {
				fragments.code('((')

				for var binding, i in @bindings {
					fragments.code(', ') if i != 0

					fragments.compile(binding)
				}

				fragments.code(') => ').compile(@filter).code(`)(\(name))`)
			}
			else {
				fragments.compile(@filter)
			}
		}
	} # }}}
}
