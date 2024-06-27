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
		@bodyScope: Scope
		@clauses							= []
		@declaration: VariableDeclaration?
		@declareTemp: Boolean				= false
		@hasDeclaration: Boolean			= false
		@hasDefaultClause: Boolean			= false
		@hasLateInitVariables: Boolean		= false
		@initializedVariables: Object		= {}
		@lateInitVariables					= {}
		@name: String?						= null
		@nextClauseIndex: Number
		@path: String?						= null
		@reusableValue: Boolean				= false
		@tests								= {}
		@usingFallthrough: Boolean			= false
		@usingTempName: Boolean				= false
		@value								= null
		@valueType: Type
	}
	override initiate() { # {{{
		if ?@data.declaration {
			@hasDeclaration = true

			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@declaration = VariableDeclaration.new(@data.declaration, this, @bindingScope, @scope:!!!(Scope), false)
				..initiate()
		}
		else {
			@bindingScope = @scope!?
		}

		@bodyScope = @newScope(@bindingScope, ScopeType.InlineBlock)
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
				binding: null
				conditions: []
				scope: @newScope(@bodyScope, ScopeType.InlineBlock)
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

			@path = @name
		}
		else {
			@value.prepare(AnyType.NullableUnexplicit)

			@valueType = @value.type()

			if @reusableValue {
				@name = @scope.acquireTempName()
				@usingTempName = true
				@path = @value.path()
			}
			else {
				@name = @scope.getVariable(@data.expression.name).getSecureName()
				@path = @name
			}
		}

		@assignTempVariables(@scope)

		if @reusableValue {
			var index = @assignments.indexOf(@name)

			if index != -1 {
				@declareTemp = true
				@assignments.splice(index, 1)
			}
		}

		@bodyScope.setImplicitVariable(@name, @valueType)

		var inferables = {}
		var lastIndex = #@clauses - 1
		var path = @path ?? @name

		var mut maxConditions = 0
		var mut maxInferables = #@clauses
		var mut valueType = @valueType

		for var clause, index in @clauses {
			clause.filter.prepare(valueType)

			valueType = clause.filter.inferTypes(path, @bodyScope, index == lastIndex) ?? valueType

			maxConditions += clause.filter:!!!(MatchFilter).getMaxConditions()

			clause.body.analyse()
			clause.body.prepare(target)

			if @usingFallthrough {
				clause.name = @scope.acquireTempName(false)
			}

			if clause.body:!!!(Block).isExit(.Statement + .Always) {
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
					var conditionHash = `$Array,\(testingType),\(JSON.stringify(minmax)),`
					var bindingHash = `$Array,false,"",\(type?.hashCode() ?? '')`

					if {
						var condition ?= @tests[conditionHash]
						var binding ?= @tests[bindingHash]
					}
					then {
						condition.count += 1
						binding.count += 1

						condition.name ??= @scope.acquireTempName(false)
						binding.name ??= @scope.acquireTempName(false)

						test.tests = [condition.name, binding.name]
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
				else if !@clauses[index].body:!!!(Block).isExit(.Expression + .Statement + .Always) {
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
				else if !@clauses[index].body:!!!(Block).isExit(.Expression + .Statement + .Always) {
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
	flagUsingFallthrough() { # {{{
		@usingFallthrough = true

		return this
	} # }}}
	getArrayTests(testingType: Boolean, minmax: Object?, type: Type?) { # {{{
		var hash = `$Array,\(testingType),\(JSON.stringify(minmax ?? '')),\(type?.hashCode() ?? '')`

		if var data ?= @tests[hash] ;; ?data.tests {
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

			if var data ?= @tests[hash1] ;; ?data.tests {
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

		if var data ?= @tests[hash] ;; ?data.tests {
			return data.tests
		}
		else {
			return null
		}
	} # }}}
	getSubject() => if @hasDeclaration set @declaration else @value
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

			unless ?clause {
				NotImplementedException.throw(this)
			}

			if ?clause.type {
				if variable.immutable {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(clause.type) {
					TypeException.throwInvalidAssignment(name, clause.type, type, expression)
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

			var var = node.scope().replaceVariable(name, clone)

			return var.getRealType()
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

			if ?clause.type {
				if variable.immutable {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(clause.type) {
					TypeException.throwInvalidAssignment(name, clause.type, type, expression)
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
	isContinuousInlineReturn() { # {{{
		unless @hasDefaultClause {
			return false
		}

		for var clause in @clauses {
			if !clause.body.isContinuousInlineReturn() {
				return false
			}
		}

		return true
	} # }}}
	override isExit(mode) { # {{{
		if mode ~~ .Always {
			return false unless @hasDefaultClause

			for var clause in @clauses {
				return false unless clause.body.isExit(mode)
			}

			return true
		}
		else {
			for var clause in @clauses {
				return true if clause.body.isExit(mode)
			}

			return false
		}
	} # }}}
	isJumpable() => true
	override isInitializingVariableAfter(name, statement) { # {{{
		for var { body } in @clauses {
			if body.isInitializingVariableAfter(name, statement) {
				return true
			}
		}

		return false
	} # }}}
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
	isUsingTempName() => @usingTempName
	override isUsingVariable(name, bleeding) { # {{{
		if @hasDeclaration {
			if @declaration.isDeclararingVariable(name) {
				return false
			}
			else if @declaration.isUsingVariable(name) {
				return true
			}
		}
		else {
			if @value.isUsingVariable(name) {
				return true
			}
		}

		return false if bleeding

		for var clause in @clauses {
			if clause.body.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	name() => @name
	path() => @path
	override setExitLabel(label) { # {{{
		for var { body } in @clauses {
			body.setExitLabel(label)
		}
	} # }}}
	throwExpectedType(type: String): Never ~ TypeException { # {{{
		TypeException.throwExpectedType(if @hasDeclaration set @name else @value.toQuote(), type, this)
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
			fragments.newLine()
				..code(`\(if @declareTemp set $runtime.scope(this) else '')\(@name) = `)
				..compile(@value)
				..done()
		}

		for var test of @tests when test.count > 1 {
			var line = fragments.newLine()

			line.code(`\($runtime.scope(this))\(test.name) = \($runtime.helper(this)).memo(`)

			if test.kind == TestKind.ARRAY {
				var { testingType, minmax?, type? } = test

				if ?type {
					type.toBlindTestFragments(null, @name, false, testingType, ?minmax, null, null, Junction.NONE, line, this)
				}
				else if ?minmax {
					var { min, max } = minmax

					line.code(`\($runtime.type(this)).isDexArray(\(@name), \(if testingType set 1 else 0), \(min), \(if max == Infinity set 0 else max))`)
				}
				else {
					line.code(`\($runtime.type(this)).isDexArray(\(@name), \(if testingType set 1 else 0))`)
				}
			}
			else {
				var { testingType, type? } = test

				if ?type {
					type.toBlindTestFragments(null, @name, false, testingType, null, null, Junction.NONE, line, this)
				}
				else {
					line.code(`\($runtime.type(this)).isDexObject(\(@name), \(if testingType set 1 else 0))`)
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
	type() { # {{{
		if @hasDefaultClause {
			var types = []

			for var { body } in @clauses {
				types.push(body.type())
			}

			return Type.union(@scope, ...types)
		}
		else {
			return Type.Void
		}
	} # }}}
	value() => @value
}

class MatchBindingArray extends AbstractNode {
	private late {
		@binding
		@declaration: Boolean			= false
		@minmax
		@testingLength: Boolean			= true
		@testingProperties: Boolean		= true
		@testingType: Boolean			= true
	}
	analyse() { # {{{
		var mut immutable = true

		if @data.kind == AstKind.ArrayBinding {
			@binding = $compile.expression(@data, this)
		}
		else {
			for var modifier in @data.modifiers {
				if modifier.kind == ModifierKind.Declarative {
					@declaration = true
				}
				else if modifier.kind == ModifierKind.Mutable {
					immutable = false
				}
			}

			@binding = $compile.expression(@data.name, this, @scope)
		}

		@binding.setAssignment(AssignmentType.Declaration)
		@binding.analyse()

		@minmax = $match.length(@binding)

		if @minmax.max == Infinity {
			@testingLength = false
		}

		if @declaration {
			for var { name } in @binding.listAssignments([]) {
				@scope.define(name, immutable, AnyType.NullableUnexplicit, true, this)
			}
		}
		else {
			for var { name } in @binding.listAssignments([]) {
				@scope.checkVariable(name, true, this)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @declaration && ?@data.type {
			var type = Type.fromAST(@data.type, this)

			if @binding is IdentifierLiteral {
				if @declaration {
					@binding.type(type, @scope, this)
				}
				else {
					@scope.replaceVariable(@binding.name(), type, this)
				}
			}
			else if @binding is ArrayBinding {
				@binding.type(type)
			}
			else {
				for var { name } in @binding.listAssignments([]) {
					@scope.replaceVariable(name, type.getProperty(name), this)
				}
			}
		}

		@binding.prepare()

		@testingType &&= !@parent.getValueType().isArray()
		@testingProperties = @binding.type().isTestingProperties()

		if @testingType || @testingLength || @testingProperties {
			@parent.addArrayTest(@testingType, @minmax, if @testingProperties set @binding.type() else null)
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
		if @declaration {
			fragments.newLine().code($runtime.scope(this)).compile(@binding).code(` = \(name)`).done()
		}
		else {
			fragments.newLine().compile(@binding).code(` = \(name)`).done()
		}
	} # }}}
	toConditionFragments(fragments, name, junction) { # {{{
		return unless @testingLength || @testingType || @testingProperties

		var { min, max } = @minmax
		var type = @binding.type()

		if var tests ?= @parent.getArrayTests(@testingType, @minmax, if @testingProperties set type else null) {
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

			type.toBlindTestFragments(null, name, false, @testingType, true, null, null, junction, fragments, this)
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
		@declaration: Boolean			= false
		@testingProperties: Boolean		= false
		@testingType: Boolean			= true
	}
	analyse() { # {{{
		var mut immutable = true

		if @data.kind == AstKind.ObjectBinding {
			@binding = $compile.expression(@data, this)
		}
		else {
			for var modifier in @data.modifiers {
				if modifier.kind == ModifierKind.Declarative {
					@declaration = true
				}
				else if modifier.kind == ModifierKind.Mutable {
					immutable = false
				}
			}

			@binding = $compile.expression(@data.name, this, @scope)
		}

		@binding.setAssignment(AssignmentType.Declaration)
		@binding.analyse()

		if @declaration {
			for var { name } in @binding.listAssignments([]) {
				@scope.define(name, immutable, AnyType.NullableUnexplicit, true, this)
			}
		}
		else {
			for var { name } in @binding.listAssignments([]) {
				@scope.checkVariable(name, true, this)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if ?@data.type {
			var type = Type.fromAST(@data.type, this)

			if @binding is IdentifierLiteral {
				if @declaration {
					@binding.type(type, @scope, this)
				}
				else {
					@scope.replaceVariable(@binding.name(), type, this)
				}
			}
			else if @binding is ObjectBinding {
				@binding.type(type)
			}
			else {
				for var { name } in @binding.listAssignments([]) {
					@scope.replaceVariable(name, type.getProperty(name), this)
				}
			}
		}

		@binding.prepare()

		var bindingType = @binding.type()
		var valueType = @parent.getValueType()

		@testingType &&= !(valueType.isBroadObject() || target.isBroadObject())

		if bindingType.isBinding() && bindingType.isTestingProperties() {
			if target.isBroadObject() && !valueType.isAny() && valueType.isBroadObject() {
				for var _, name of bindingType.properties() {
					if target.hasProperty(name) || valueType.hasProperty(name) {
						var property = target.getProperty(name) ?? valueType.getProperty(name)
						var type = property.discardVariable()

						@binding.setPropertyType(name, type)
					}
					else {
						@testingProperties = true
					}
				}
			}
			else if target.isBroadObject() {
				for var _, name of bindingType.properties() {
					if target.hasProperty(name) {
						var property = target.getProperty(name)
						var type = property.discardVariable()

						@binding.setPropertyType(name, type)
					}
					else {
						@testingProperties = true
					}
				}
			}
			else {
				@testingProperties = true
			}
		}

		if @testingType || @testingProperties {
			@parent.addObjectTest(@testingType, if @testingProperties set bindingType else null)
		}
	} # }}}
	translate() { # {{{
		@binding.translate()
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@binding)
	} # }}}
	toBindingFragments(fragments, name) { # {{{
		if @declaration {
			fragments.newLine().code($runtime.scope(this)).compile(@binding).code(` = \(name)`).done()
		}
		else {
			fragments.newLine().compile(@binding).code(` = \(name)`).done()
		}
	} # }}}
	toConditionFragments(fragments, name, junction) { # {{{
		return unless @testingType || @testingProperties

		var type = @binding.type()

		if var tests ?= @parent.getObjectTests(@testingType, if @testingProperties set type else null) {
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

			if type is ObjectType {
				type.toBlindTestFragments(null, name, false, false, @testingType, null, null, junction, fragments, this)
			}
			else {
				type.toBlindTestFragments(null, name, false, null, null, junction, fragments, this)
			}
		}
	} # }}}
	unflagTypeTesting() { # {{{
		@testingType = false
	} # }}}
}

class MatchBindingValue extends AbstractNode {
	private late {
		@binding
		@declaration: Boolean			= false
	}
	analyse() { # {{{
		var mut immutable = true

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind.Mutable {
				immutable = false
			}
		}

		@binding = $compile.expression(@data.name, this, @scope)
		@binding.setAssignment(AssignmentType.Declaration)
		@binding.analyse()

		if @declaration {
			for var { name } in @binding.listAssignments([]) {
				@scope.define(name, immutable, AnyType.NullableUnexplicit, true, this)
			}
		}
		else {
			for var { name } in @binding.listAssignments([]) {
				@scope.checkVariable(name, true, this)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @declaration && ?@data.type {
			var type = Type.fromAST(@data.type, this)

			if @binding is IdentifierLiteral {
				if @declaration {
					@binding.type(type, @scope, this)
				}
				else {
					@scope.replaceVariable(@binding.name(), type, this)
				}
			}
			else if @binding is ArrayBinding | ObjectBinding {
				@binding.type(type)
			}
			else {
				for var { name } in @binding.listAssignments([]) {
					@scope.replaceVariable(name, type.getProperty(name), this)
				}
			}
		}

		@binding.prepare()
	} # }}}
	translate() { # {{{
		@binding.translate()
	} # }}}
	toBindingFragments(fragments, name) { # {{{
		if @declaration {
			fragments.newLine().code($runtime.scope(this)).compile(@binding).code(` = \(name)`).done()
		}
		else {
			fragments.newLine().compile(@binding).code(` = \(name)`).done()
		}
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
			if value.kind != AstKind.OmittedExpression {
				if value.kind == AstKind.MatchConditionRange {
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
		for var value in @values {
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

		if var tests ?= @parent.getArrayTests(true, @minmax, null) {
			for var test, index in tests {
				fragments
					.code(` && `) if index > 0
					.code(`\(test)()`)
			}
		}
		else {
			fragments.code(`\($runtime.type(this)).isDexArray(\(name), 1, \(min), \(if max == Infinity set 0 else max))`)
		}

		var mut index = 0

		for var value, i in @data.values when value.kind != AstKind.OmittedExpression {
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
				AstKind.ObjectMember {
					var property = {
						name: data.name.name
					}

					if ?data.value {
						property.value = MatchConditionValue.new(data.value, this)
						property.value.analyse()
					}

					@properties.push(property)
				}
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = ObjectType.new(@scope)

		if ?#@properties {
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

		@isObject = target.isBroadObject()

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
			.code(name, if @from set ' >= ' else '>')
			.compile(@left)
			.code(' && ')
			.code(name, if @to set ' <= ' else '<')
			.compile(@right)

		fragments.code(')') if junction == Junction.OR
	} # }}}
	type() => @scope.reference('Number')
}

class MatchConditionType extends AbstractNode {
	private late {
		@skipTest: Boolean		= false
		@type: Type
	}
	analyse()
	override prepare(target, targetMode) { # {{{
		@type = @confirmType(Type.fromAST(@data.type, @parent.getValueType(), this), target)
	} # }}}
	translate()
	isEnum() => false
	setCastingEnum(_)
	toConditionFragments(fragments, name, junction) { # {{{
		if @skipTest {
			fragments.code('true')
		}
		else {
			@type.toPositiveTestFragments(fragments, Literal.new(false, this, @scope:!!!(Scope), name, @parent.getValueType()))
		}
	} # }}}
	type() => @type
	private confirmType(type: Type, subjectType: Type): Type { # {{{
		if subjectType.isNull() {
			TypeException.throwNullTypeChecking(type, this)
		}

		if type.isVirtual() {
			if !subjectType.isAny() && !subjectType.canBeVirtual(type.name()) {
				TypeException.throwInvalidTypeChecking(@parent.getSubject(), type, this)
			}
		}
		else {
			if subjectType.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				@skipTest = true
			}

			unless type.isAssignableToVariable(subjectType, false, false, true) {
				TypeException.throwInvalidTypeChecking(@parent.getSubject(), type, this)
			}
		}

		return type
	} # }}}
}

class MatchConditionValue extends AbstractNode {
	private late {
		@skipTest: Boolean		= false
		@type: Type
		@container: Boolean		= false
		@values: Expression[]	= []
		@variant: Boolean		= false
		@variantName: String?
	}
	analyse() { # {{{
		if @data.kind == AstKind.JunctionExpression {
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

			value.prepare()

			@type = value.type()

			if @type is ValueType && @type.value() == 'true' | 'false' {
				var valueType = @parent().getValueType()

				if valueType.isVariant() {
					var root = valueType.discard()
					var variant = root.getVariantType()

					if variant.canBeBoolean() {
						@variant = true
						@variantName = root.getVariantName()
						@type = valueType.clone()
							..addSubtype(@type.value(), @scope.reference('Boolean'), this)
					}
					else {
						NotImplementedException.throw(this)
					}
				}
			}
		}
		else {
			var types = []

			for var value in @values {
				value.prepare()

				types.push(value.type())
			}

			@type = Type.union(@scope, ...types)
		}

		if @type.isContainer() {
			@container = true

			@type = @confirmType(@type.reference(), target)
		}
	} # }}}
	translate() { # {{{
		for var value in @values {
			value.translate()
		}
	} # }}}
	isContainer() => @container
	isEnum() => @type.isEnum()
	isVariant() => @type.isVariant()
	toConditionFragments(fragments, name, junction) { # {{{
		if @skipTest {
			fragments.code('true')
		}
		else if @container {
			@type.toPositiveTestFragments(fragments, Literal.new(false, this, @scope:!!!(Scope), name, @scope.getImplicitType()))
		}
		else if @values.length == 1 {
			var value = @values[0]

			if @variant {
				if value.value() == 'false' {
					fragments.code('!')
				}

				fragments.code(`\(name).\(@variantName)`)
			}
			else if @type.isVariant() {
				var object = @type.discard()
				var variant = object.getVariantType()
				var subtypes = @type.getSubtypes()
				var operand = `\(name).\(object.getVariantName()) === `

				fragments.code('(') if junction == Junction.AND && subtypes.length > 1

				for var { name % varname, type }, index in subtypes {
					fragments.code(' || ') if index > 0

					var generic = type.discard().getValue(varname)

					if generic.isAlias() {
						if generic.isDerivative() {
							fragments.compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(varname))(\(name).\(object.getVariantName()))`)
						}
						else {
							fragments.code(operand).compile(type).code(`.\(generic.original())`)
						}
					}
					else {
						fragments.code(operand).compile(type).code(`.\(varname)`)
					}
				}

				fragments.code(')') if junction == Junction.AND && subtypes.length > 1
			}
			else if value.isDerivative() {
				var type = value.type().discardValue()

				fragments
					.compile(type)
					.code(`.__ks_eq_\(type.discard().getTopProperty(value.property()))(\(name))`)
			}
			else {
				fragments.code(name, ' === ').compile(value)
			}
		}
		else if @values.length > 1 {
			fragments.code('(') if junction == Junction.AND

			var mut literal = null

			for var value, index in @values {
				if index > 0 {
					fragments.code(' || ')
				}

				if @type.isVariant() {
					var object = @type.discard()
					var variant = object.getVariantType()
					var subtypes = @type.getSubtypes()
					var operand = `\(name).\(object.getVariantName()) === `

					for var subtype, sIndex in subtypes {
						fragments
							..code(' || ') if sIndex != 0
							..code(operand).compile(subtype.type).code(`.\(subtype.name)`)
					}
				}
				else {
					fragments.code(name, ' === ').compile(value)
				}
			}

			fragments.code(')') if junction == Junction.AND
		}
	} # }}}
	type() => @type
	values() => @values
	private confirmType(type: Type, subjectType: Type): Type { # {{{
		if subjectType.isNull() {
			TypeException.throwNullTypeChecking(type, this)
		}

		if type.isVirtual() {
			if !subjectType.isAny() && !subjectType.canBeVirtual(type.name()) {
				TypeException.throwInvalidTypeChecking(@parent.getSubject(), type, this)
			}
		}
		else {
			if subjectType.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				@skipTest = true
			}

			unless type.isAssignableToVariable(subjectType, false, false, true) {
				TypeException.throwInvalidTypeChecking(@parent.getSubject(), type, this)
			}
		}

		return type
	} # }}}
}

class MatchFilter extends AbstractNode {
	private late {
		@conditions				= []
		@binding				= null
		@falseType: Type?		= null
		@filter					= null
		@hasTest: Boolean		= false
		@hasWhenFalse: Boolean	= true
		@kind: MatchClauseKind	= .DEFAULT
		@testType: Type?		= null
		@trueType: Type?		= null
	}
	override analyse() { # {{{
		var scope = @scope()

		if ?@data.binding {
			if @data.binding.kind == AstKind.ArrayBinding || @data.binding.name?.kind == AstKind.ArrayBinding {
				if @kind == .DEFAULT {
					@kind = .ARRAY
				}
				else {
					throw NotSupportedException.new(this)
				}

				@binding = MatchBindingArray.new(@data.binding, @parent, scope)

				@hasTest = true
			}
			else if @data.binding.kind == AstKind.ObjectBinding || @data.binding.name?.kind == AstKind.ObjectBinding {
				if @kind == .DEFAULT {
					@kind = .OBJECT
				}
				else {
					throw NotSupportedException.new(this)
				}

				@binding = MatchBindingObject.new(@data.binding, @parent, scope)

				@hasTest = true
			}
			else {
				@binding = MatchBindingValue.new(@data.binding, @parent, scope)
			}

			@binding.analyse()
		}

		if ?#@data.conditions {
			@hasTest = true

			for var data in @data.conditions {
				var late condition

				match data.kind {
					AstKind.MatchConditionArray {
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

						@binding?
							..unflagLengthTesting()
							..unflagTypeTesting()
					}
					AstKind.MatchConditionObject {
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

						@binding?.unflagTypeTesting()
					}
					AstKind.MatchConditionRange {
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
					AstKind.MatchConditionType {
						condition = MatchConditionType.new(data, @parent, scope)

						@binding?.unflagTypeTesting()
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
		match @kind {
			.ARRAY {
				if target.isArray() || target.canBeArray() {
					pass
				}
				else {
					@parent.throwExpectedType('Array')
				}
			}
			.NUMBER {
				if target.isNumber() || target.canBeNumber() {
					pass
				}
				else {
					@parent.throwExpectedType('Number')
				}
			}
			.OBJECT {
				if target.isObject() || target.canBeObject() {
					pass
				}
				else {
					@parent.throwExpectedType('Object')
				}
			}
		}

		@hasWhenFalse = !?@filter

		var types = []

		for var condition in @conditions {
			condition.prepare(target)

			if condition is MatchConditionType {
				types.push(condition.type())

				@hasWhenFalse &&= true
			}
			else if condition is MatchConditionValue {
				if condition.isContainer() {
					@binding?.unflagTypeTesting()

					types.push(condition.type().reference(@scope))

					@hasWhenFalse &&= true
				}
				else if condition.isVariant() {
					types.push(condition.type())

					@hasWhenFalse &&= true
				}
				else {
					@hasWhenFalse = false
				}
			}
			else {
				types.push(condition.type())

				@hasWhenFalse = false
			}
		}

		if ?#types {
			@testType = Type.union(@scope, ...types)

			var name = @parent().name()

			@binding?.prepare(@testType)

			@scope.setImplicitVariable(@parent().name(), @testType)

			if @hasWhenFalse {
				@trueType = target.limitTo(@testType)
				@falseType = target.trimOff(@trueType)
			}
		}
		else {
			@binding?.prepare(target)
		}

		@filter?.prepare(@scope.reference('Boolean'))
	} # }}}
	override translate() { # {{{
		for var condition in @conditions {
			condition.translate()
		}

		@binding?.translate()
		@filter?.translate()
	} # }}}
	conditions() => @conditions
	getMaxConditions(): Number => @conditions.length
	hasTest() => @hasTest
	inferTypes(path, scope, last) { # {{{
		if ?@testType && @hasWhenFalse {
			var isVariable = scope.hasVariable(path)

			@scope.updateInferable(path, { isVariable, type: @trueType }, this)

			if !last {
				scope
					..line(@data.end.line + 1)
					..updateInferable(path, { isVariable, type: @falseType }, this)
					..line(@data.start.line)

				return @falseType
			}
		}

		return null
	} # }}}
	isEnum() { # {{{
		return false unless ?#@conditions

		for var condition in @conditions {
			if !condition.isEnum() {
				return false
			}
		}

		return true
	} # }}}
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
		@binding?.toBindingFragments(fragments, name)
	} # }}}
	toConditionFragments(fragments, name) { # {{{
		var mut junction = Junction.NONE

		if ?#@conditions {
			if @conditions.length == 1 {
				@conditions[0].toConditionFragments(fragments, name, junction)
			}
			else {
				var wrap = ?@binding || ?@filter

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

		if ?@binding {
			@binding.toConditionFragments(fragments, name, junction)

			junction = .AND
		}

		if ?@filter {
			fragments.code(' && ') if junction == .AND

			if ?@binding {
				fragments.code('((').compile(@binding).code(') => ').compile(@filter).code(`)(\(name))`)
			}
			else {
				fragments.compileCondition(@filter, null, junction)
			}
		}
	} # }}}
}
