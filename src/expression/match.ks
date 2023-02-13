class MatchExpression extends Expression {
	private late {
		@bindingScope: Scope
		@castingEnum: Boolean				= false
		@clauses							= []
		@declaration: VariableDeclaration?
		@declarator
		@hasDeclaration: Boolean			= false
		@hasDefaultClause: Boolean			= false
		@hasLateInitVariables: Boolean		= false
		@initializedVariables: Object		= {}
		@insitu: Boolean					= false
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
		@valueName: String?					= null
		@valueType: Type
	}
	override initiate() { # {{{
		if ?@data.declaration {
			@hasDeclaration = true

			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@declaration = new VariableDeclaration(@data.declaration, this, @bindingScope, @scope:Scope, false)
			@declaration.initiate()
		}
		else {
			@bindingScope = @scope!?
		}
	} # }}}
	override analyse() { # {{{
		@initiate()

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

			if data.body.kind == NodeKind.Block {
				clause.body = $compile.block(data.body, this, clause.scope)
			}
			else {
				clause.body = $compile.block($ast.pick(data.body), this, clause.scope)
			}
		}

		for var clause in @clauses {
			clause.body.analyse()
		}

		if @hasLateInitVariables && !@hasDefaultClause {
			for var value, name of @lateInitVariables when value.variable.isImmutable() {
				SyntaxException.throwMissingAssignmentMatchNoDefault(name, this)
			}
		}

		var mut statement = @parent
		var mut declaration = null

		while statement is not Statement {
			if statement is VariableDeclaration {
				declaration = statement
			}

			statement = statement.parent()
		}

		if ?declaration {
			var declarators = declaration.declarators()
			var declarator = declarators[0]

			if declarators.length == 1 && declarator is VariableIdentifierDeclarator {
				@declarator = declarator
				@insitu = true
			}
		}

		if @insitu {
			statement.addAfterward(this)
		}
		else {
			statement.addBeforehand(this)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @insitu {
			@valueName = @declarator.variable().getSecureName()
		}
		else {
			var statement = @statement()

			@valueName = statement.scope().acquireTempName()

			statement.assignTempVariables(statement.scope())
		}

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

		var late tracker: PossibilityTracker

		if @hasDefaultClause {
			tracker = PossibilityTracker.dummy()
		}
		else {
			tracker = PossibilityTracker.create(@valueType.discard())
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

		var mut enumConditions = 0
		var mut maxConditions = 0

		for var clause, index in @clauses {
			clause.filter.prepare(@scope.reference('Boolean'))

			enumConditions += clause.filter:MatchFilter.getEnumConditions()
			maxConditions += clause.filter:MatchFilter.getMaxConditions()

			for var condition in clause.filter.conditions() {
				tracker.exclude(condition)
			}

			clause.body.prepare(target)

			if @usingFallthrough {
				clause.name = @scope.acquireTempName(false)
			}
		}

		unless tracker.isFullyMatched() {
			if tracker.isFinite() {
				SyntaxException.throwNotMatchedPossibilities(tracker.listUnmatched(), this)
			}
			else {
				SyntaxException.throwNotMatchedPossibilities(this)
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

			@parent.initializeVariable(new VariableBrief(name, type), this, this)
		}

		if @reusableValue {
			@scope.releaseTempName(@name)
		}
		else {
			@name = @scope.getVariable(@data.expression.name).getSecureName()
		}
	} # }}}
	override translate() { # {{{
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
	getValueName() => @valueName
	getValueType() => @valueType
	isInline() => false
	isInSituStatement() => @insitu
	toFragments(fragments, mode) { # {{{
		fragments.code(@valueName)
	} # }}}
	toAfterwardFragments(fragments, mode) { # {{{
		@toStatementFragments(fragments, mode)
	} # }}}
	toBeforehandFragments(fragments, mode) { # {{{
		@toStatementFragments(fragments, mode)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
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
		var mut we = false

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

				we = true

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

abstract class PossibilityTracker {
	static {
		create(type: Type): PossibilityTracker { # {{{
			if type is EnumType {
				return new EnumPossibilityTracker(type)
			}

			return new DefaultPossibilityTracker()
		} # }}}
		dummy(): PossibilityTracker { # {{{
			return new DummyPossibilityTracker()
		} # }}}
	}
	abstract {
		isFinite(): Boolean
		isFullyMatched(): Boolean
		listUnmatched(): String[]
	}
	exclude(condition) { # {{{
		throw new NotSupportedException()
	} # }}}
}

class DefaultPossibilityTracker extends PossibilityTracker {
	override exclude(_)
	override isFinite() => false
	override isFullyMatched() => false
	override listUnmatched() => []
}

class DummyPossibilityTracker extends PossibilityTracker {
	override exclude(_)
	override isFinite() => false
	override isFullyMatched() => true
	override listUnmatched() => []
}

class EnumPossibilityTracker extends PossibilityTracker {
	private {
		@possibilities: String[]
	}
	constructor(type: EnumType) { # {{{
		super()

		@possibilities = type.listVariables()
	} # }}}
	exclude(condition: MatchConditionValue) { # {{{
		for var value in condition.values() {
			match value {
				is UnaryOperatorImplicit {
					@possibilities.remove(value.property())
				}
				else {
					console.log(value)
					throw new NotImplementedException()
				}
			}
		}
	} # }}}
	override isFinite() => true
	override isFullyMatched() => !#@possibilities
	override listUnmatched() => @possibilities
}
