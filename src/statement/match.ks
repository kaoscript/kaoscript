var $match = {
	length(elements) { # {{{
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
		@testArray: String?
		@testData							= {
			array: 0
			number: 0
			object: 0
		}
		@testNumber: String?
		@testObject: String?
		@usingFallthrough: Boolean			= false
		@value								= null
		@valueType: Type
	}
	override initiate() { # {{{
		if ?@data.declaration {
			@hasDeclaration = true

			@bindingScope = @newScope(@scope!?, ScopeType::Bleeding)

			@declaration = new VariableDeclaration(@data.declaration, this, @bindingScope, @scope:Scope, false)
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
				scope: @newScope(@bindingScope, ScopeType::InlineBlock)
			}

			@clauses.push(clause)

			clause.scope.index = index

			var filter = new MatchFilter(data, this, clause.scope)

			filter.analyse()

			if filter.hasTest() {
				clause.hasTest = true

				var data = filter.getTestData()

				@testData.array += data.array
				@testData.number += data.number
				@testData.object += data.object
			}
			else if @hasDefaultClause {
				throw new NotSupportedException(this)
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
				throw new NotSupportedException()
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

		if @testData.array > 1 {
			if @valueType.isArray() {
				pass
			}
			else if @valueType.canBeNumber() {
				@testArray = @scope.acquireTempName(false)
			}
			else {
				TypeException.throwExpectedType(@hasDeclaration ? @name : @value.toQuote(), 'Array', this)
			}
		}
		if @testData.number > 1 {
			if @valueType.isNumber() {
				pass
			}
			else if @valueType.canBeNumber() {
				@testNumber = @scope.acquireTempName(false)
			}
			else {
				TypeException.throwExpectedType(@hasDeclaration ? @name : @value.toQuote(), 'Number', this)
			}
		}
		if @testData.object > 1 {
			if @valueType.isObject() {
				pass
			}
			else if @valueType.canBeObject() {
				@testObject = @scope.acquireTempName(false)
			}
			else {
				TypeException.throwExpectedType(@hasDeclaration ? @name : @value.toQuote(), 'Object', this)
			}
		}

		var enumValue = @valueType.isEnum()

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

		if enumConditions != 0 || enumValue {
			if enumValue && enumConditions == maxConditions {
				pass
			}
			else {
				for var clause in @clauses {
					clause.filter.setCastingEnum(true)
				}

				if enumValue || @valueType.isAny() {
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
				else if !!@clauses[index].body.isExit() {
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

			@parent.initializeVariable(VariableBrief(name, type), this, this)
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

		for clause in @clauses {
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
	defineVariables(left, scope) { # {{{
		for var name in left.listAssignments([]) {
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
	getTypeTester(fragments, type) { # {{{
		match type {
			'array' {
				if ?@testArray {
					return () => {
						fragments.code(@testArray)
					}
				}
			}
			'number' {
				if ?@testNumber {
					return () => {
						fragments.code(@testNumber)
					}
				}
			}
			'object' {
				if ?@testObject {
					return () => {
						fragments.code(@testObject)
					}
				}
			}
		}

		return null
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
			var line = fragments.newLine().code($runtime.scope(this), @name, ' = ').compile(@value)

			if @castingEnum {
				if @valueType.isEnum() {
					line.code('.value')
				}
				else if @valueType.isAny() {
					line.code('.valueOf()')
				}
			}

			line.done()
		}
		else if @castingEnum {
			var line = fragments.newLine().code($runtime.scope(this), @name, ' = ', @data.expression.name)

			if @valueType.isEnum() {
				line.code('.value')
			}
			else if @valueType.isAny() {
				line.code('.valueOf()')
			}

			line.done()
		}

		if ?@testArray {
			fragments
				.newLine()
				.code($runtime.scope(this), @testArray, ' = ', $runtime.typeof('Array', this), `(\(@name))`)
				.done()
		}
		if ?@testNumber {
			fragments
				.newLine()
				.code($runtime.scope(this), @testNumber, ' = ', $runtime.typeof('Number', this), `(\(@name))`)
				.done()
		}
		if ?@testObject {
			fragments
				.newLine()
				.code($runtime.scope(this), @testObject, ' = ', $runtime.typeof('Object', this), `(\(@name))`)
				.done()
		}

		for var clause, clauseIdx in @clauses {
			clause.filter.toBeforehandFragments(fragments, @name)

			if @usingFallthrough {
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
}

class MatchBindingArray extends AbstractNode {
	private {
		@array
	}
	analyse() { # {{{
		@array = $compile.expression(@data, this)
		@array.setAssignment(AssignmentType::Expression)
		@array.analyse()

		@parent.defineVariables(@array, @scope)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@array.prepare()
	} # }}}
	translate() { # {{{
		@array.translate()
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@array)
	} # }}}
	toBeforehandFragments(fragments)
	toBindingFragments(fragments, name) { # {{{
		var mut line = fragments.newLine()

		line.code($runtime.scope(this))

		@array.toAssignmentFragments(line, new Literal(name, this))

		line.done()
	} # }}}
	toConditionFragments(fragments, name, junction, precondition) { # {{{
		var check = precondition?(junction, 'array')

		fragments.code('(') if junction == Junction::OR

		if ?check {
			check()

			fragments.code(' && ')
		}

		var mm = $match.length(@data.elements)
		if mm.min == mm.max {
			if mm.min != Infinity {
				fragments.code(name, '.length === ', mm.min)
			}
		}
		else {
			fragments.code(name, '.length >= ', mm.min)

			if mm.max != Infinity {
				fragments.code(' && ', name, '.length <= ', mm.max)
			}
		}

		fragments.code(')') if junction == Junction::OR
	} # }}}
}

class MatchBindingObject extends AbstractNode {
	private {
		@binding
		@name: String?		= null
		@properties			= []
	}
	analyse() { # {{{
		@binding = $compile.expression(@data, this)
		@binding.setAssignment(AssignmentType::Declaration)
		@binding.analyse()

		@parent.defineVariables(@binding, @scope)

		for var data in @data.elements {
			match data.kind {
				NodeKind::BindingElement {
					@properties.push({
						name: data.name.name
					})
				}
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@binding.prepare()

		if #@properties {
			@name = @scope.parent().acquireTempName(false)
		}
	} # }}}
	translate() { # {{{
		@binding.translate()
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.code('{')

		for var { name }, i in @properties {
			if i != 0 {
				fragments.code(', ')
			}

			fragments.code(name)
		}

		fragments.code('}')
	} # }}}
	toBeforehandFragments(fragments) { # {{{
		if #@properties {
			var line = fragments.newLine()

			line.code($runtime.scope(this), @name, ' = ({')

			for var { name }, i in @properties {
				if i != 0 {
					line.code(', ')
				}

				line.code(name)
			}

			line.code('}) => ')

			for var { name, value }, i in @properties {
				if i != 0 {
					line.code(' && ')
				}

				line.code(`!\($runtime.type(this)).isNull(\(name))`)
			}

			line.done()
		}
	} # }}}
	toBindingFragments(fragments, name) { # {{{
		var line = fragments.newLine()

		line.code($runtime.scope(this))

		@binding.toAssignmentFragments(line, new Literal(name, this))

		line.done()
	} # }}}
	toConditionFragments(fragments, name, junction, precondition) { # {{{
		if ?@name {
			if var check ?= precondition?(junction, 'object') {
				check()

				fragments.code(` && \(@name)(\(name))`)
			}
			else {
				fragments.code(`\(@name)(\(name))`)
			}
		}
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
			if modifier.kind == ModifierKind::Mutable {
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
	toBeforehandFragments(fragments)
	toBindingFragments(fragments, name) { # {{{
		fragments.line($runtime.scope(this), @name, ' = ', name)
	} # }}}
	toConditionFragments(fragments, name, junction, precondition)
}

class MatchConditionArray extends AbstractNode {
	private {
		@flatten: Boolean	= false
		@name: String?		= null
		@values				= []
	}
	analyse() { # {{{
		@flatten = @options.format.destructuring == 'es5'

		for var mut value in @data.values {
			if value.kind != NodeKind::OmittedExpression {
				if value.kind == NodeKind::MatchConditionRange {
					value = new MatchConditionRange(value, this)
				}
				else {
					value = new MatchConditionValue(value, this)
				}

				value.analyse()

				@values.push(value)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @values.length > 0 {
			@name = @scope.parent().acquireTempName(false)
		}

		for var value in @values {
			value.prepare()
		}
	} # }}}
	translate() { # {{{
		for value in @values {
			value.translate()
		}
	} # }}}
	isEnum() => false
	toBeforehandFragments(fragments) { # {{{
		if @values.length > 0 {
			var mut line = fragments.newLine()

			if @flatten {
				var name = new Literal('__ks__', this)

				line.code($runtime.scope(this), @name, ' = function(__ks__)')

				var block = line.newBlock()

				block.done()
			}
			else {
				line.code($runtime.scope(this), @name, ' = ([')

				for var value, i in @data.values {
					if i != 0 {
						line.code(', ')
					}

					if value.kind == NodeKind::OmittedExpression {
						if value.spread {
							line.code('...')
						}
					}
					else {
						line.code('__ks_', i)
					}
				}

				line.code(']) => ')

				var mut index = 0
				for var value, i in @data.values {
					if value.kind != NodeKind::OmittedExpression {
						if index != 0 {
							line.code(' && ')
						}

						@values[index].toConditionFragments(line, `__ks_\(i)`, Junction::AND, null)

						index += 1
					}
				}
			}

			line.done()
		}
	} # }}}
	toConditionFragments(fragments, name, junction, precondition) { # {{{
		var check = precondition?(junction, 'array')

		fragments.code('(') if junction == Junction::OR

		if ?check {
			check()

			fragments.code(' && ')
		}

		var mut and = false

		var mm = $match.length(@data.values)
		if mm.min == mm.max {
			if mm.min != Infinity {
				fragments.code(name, '.length === ', mm.min)

				and = true
			}
		}
		else {
			fragments.code(name, '.length >= ', mm.min)

			if mm.max != Infinity {
				fragments.code(' && ', name, '.length <= ', mm.max)
			}

			and = true
		}

		if ?@name {
			fragments.code(' && ') if and

			fragments.code(@name, '(', name, ')')
		}

		fragments.code(')') if junction == Junction::OR
	} # }}}
}

class MatchConditionObject extends AbstractNode {
	private {
		@name: String?		= null
		@properties			= []
	}
	analyse() { # {{{
		for var data in @data.properties {
			match data.kind {
				NodeKind::ObjectMember {
					var property = {
						name: data.name.name
					}

					if ?data.value {
						property.value = value = new MatchConditionValue(data.value, this)
						property.value.analyse()
					}

					@properties.push(property)
				}
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if #@properties {
			@name = @scope.parent().acquireTempName(false)

			for var property in @properties when ?property.value {
				property.value.prepare()
			}
		}
	} # }}}
	translate() { # {{{
		for var property in @properties when ?property.value {
			property.value.translate()
		}
	} # }}}
	isEnum() => false
	toBeforehandFragments(fragments) { # {{{
		if #@properties {
			var line = fragments.newLine()

			line.code($runtime.scope(this), @name, ' = ({')

			for var { name }, i in @properties {
				if i != 0 {
					line.code(', ')
				}

				line.code(name)
			}

			line.code('}) => ')

			for var { name, value }, i in @properties {
				if i != 0 {
					line.code(' && ')
				}

				if ?value {
					value.toConditionFragments(line, name, Junction::AND, null)
				}
				else {
					line.code(`!\($runtime.type(this)).isNull(\(name))`)
				}
			}

			line.done()
		}
	} # }}}
	toConditionFragments(fragments, name, junction, precondition?) { # {{{
		if ?@name {
			if var check ?= precondition?(junction, 'object') {
				fragments.code('(') if junction == Junction::OR

				check()

				fragments.code(` && \(@name)(\(name))`)

				fragments.code(')') if junction == Junction::OR
			}
			else {
				fragments.code(`\(@name)(\(name))`)
			}
		}
	} # }}}
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
	toBeforehandFragments(fragments)
	toConditionFragments(fragments, name, junction, precondition?) { # {{{
		var check = precondition?(junction, 'number')

		fragments.code('(') if junction == Junction::OR

		if ?check {
			check()

			fragments.code(' && ')
		}

		fragments
			.code(name, @from ? ' >= ' : '>')
			.compile(@left)
			.code(' && ')
			.code(name, @to ? ' <= ' : '<')
			.compile(@right)

		fragments.code(')') if junction == Junction::OR
	} # }}}
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
	toBeforehandFragments(fragments)
	toConditionFragments(fragments, name, junction, precondition?) { # {{{
		precondition?(junction, 'any')

		@type.toPositiveTestFragments(fragments, new Literal(false, this, @scope:Scope, name))
	} # }}}
}

class MatchConditionValue extends AbstractNode {
	private late {
		@castingEnum: Boolean	= false
		@values: Expression[]	= []
		@type: Type
	}
	analyse() { # {{{
		if @data.kind == NodeKind::JunctionExpression {
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
	isEnum() => @type.isEnum()
	setCastingEnum(@castingEnum)
	toBeforehandFragments(fragments)
	toConditionFragments(fragments, name, junction, precondition?) { # {{{
		precondition?(junction, 'any')

		if @values.length == 1 {
			var value = @values[0]

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
		else if @values.length > 1 {
			fragments.code('(') if junction == Junction::AND

			for var value, index in @values {
				if index > 0 {
					fragments.code(' || ')
				}

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

			fragments.code(')') if junction == Junction::AND
		}
	} # }}}
	values() => @values
}

class MatchFilter extends AbstractNode {
	private late {
		@conditions				= []
		@bindings				= []
		@enumConditions: Number	= 0
		@filter					= null
		@hasTest: Boolean		= false
		@inlineFilter: Boolean	= true
		@isArray: Boolean		= false
		@isObject: Boolean		= false
		@name: String?
		@testData				= {
			array: 0
			number: 0
			object: 0
		}
	}
	override analyse() { # {{{
		var scope = @scope()

		for var data in @data.bindings {
			var late binding

			match data.kind {
				NodeKind::ArrayBinding {
					if @isObject {
						throw new NotSupportedException(this)
					}

					binding = new MatchBindingArray(data, @parent, scope)

					@hasTest = true
					@isArray = true
					@testData.array += 1
					@inlineFilter = false
				}
				NodeKind::ObjectBinding {
					if @isArray {
						throw new NotSupportedException(this)
					}

					binding = new MatchBindingObject(data, @parent, scope)

					@hasTest = true
					@isObject = true
					@testData.object += 1
					@inlineFilter = false
				}
				else {
					binding = new MatchBindingValue(data, @parent, scope)
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
					NodeKind::MatchConditionArray {
						if @isObject {
							throw new NotSupportedException(this)
						}

						condition = new MatchConditionArray(data, @parent, scope)

						@testData.array += 1
					}
					NodeKind::MatchConditionObject {
						if @isArray {
							throw new NotSupportedException(this)
						}

						condition = new MatchConditionObject(data, @parent, scope)

						@testData.object += 1
					}
					NodeKind::MatchConditionRange {
						if @isArray || @isObject {
							throw new NotSupportedException(this)
						}

						condition = new MatchConditionRange(data, @parent, scope)

						@testData.number += 1
					}
					NodeKind::MatchConditionType {
						condition = new MatchConditionType(data, @parent, scope)
					}
					else {
						condition = new MatchConditionValue(data, @parent, scope)
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
		for var condition in @conditions {
			condition.prepare()

			if condition.isEnum() {
				@enumConditions += 1
			}
		}

		for var binding in @bindings {
			binding.prepare()
		}

		if ?@filter {
			@filter.prepare(target)

			if !@inlineFilter {
				@name = @scope.parent().acquireTempName(false)
			}
		}
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
	getTestData() => @testData
	hasTest() => @hasTest
	setCastingEnum(castingEnum: Boolean) { # {{{
		for var condition in @conditions {
			condition.setCastingEnum(castingEnum)
		}
	} # }}}
	toBeforehandFragments(fragments, name) { # {{{
		for var condition in @conditions {
			condition.toBeforehandFragments(fragments)
		}

		for var binding in @bindings {
			binding.toBeforehandFragments(fragments)
		}

		if ?@name {
			var line = fragments.newLine()

			line.code($runtime.scope(this), @name, ' = (')

			for var binding, i in @bindings {
				line.code(', ') if i != 0

				line.compile(binding)
			}

			line.code(') => ').compile(@filter).done()
		}
	} # }}}
	toBindingFragments(fragments, name) { # {{{
		for var binding in @bindings {
			binding.toBindingFragments(fragments, name)
		}
	} # }}}
	toConditionFragments(fragments, name) { # {{{
		var mut junction = Junction::NONE

		var precondition = (jun: Junction, type: String) => {
			match jun {
				.AND {
					if junction == .AND {
						fragments.code(' && ')
					}
				}
				.NONE {
					junction = .AND
				}
				.OR {
					fragments.code(' || ')
				}
			}

			return @parent.getTypeTester(fragments, type)
		}

		if #@conditions {
			if @conditions.length == 1 {
				@conditions[0].toConditionFragments(fragments, name, junction, precondition)
			}
			else if @conditions.length > 1 {
				var wrap = #@bindings || ?@filter

				fragments.code('(') if wrap

				@conditions[0].toConditionFragments(fragments, name, Junction::NONE, precondition)

				for var condition in @conditions from 1 {
					condition.toConditionFragments(fragments, name, Junction::OR, precondition)
				}

				fragments.code(')') if wrap
			}
		}

		if #@bindings {
			for var binding in @bindings {
				binding.toConditionFragments(fragments, name, junction, precondition)
			}
		}

		if ?@filter {
			fragments.code(' && ') if junction == .AND

			if @inlineFilter {
				fragments.compile(@filter)
			}
			else {
				fragments.code(`\(@name)(\(name))`)
			}
		}
	} # }}}
}
