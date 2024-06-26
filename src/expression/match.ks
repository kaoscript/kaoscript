class MatchExpression extends Expression {
	private late {
		@bindingScope: Scope
		@bodyScope: Scope
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
		@path: String?						= null
		@reusableValue: Boolean				= false
		@tests								= {}
		@type: Type
		@usingFallthrough: Boolean			= false
		@value								= null
		@valueName: String?					= null
		@valueType: Type
	}
	override initiate() { # {{{
		if ?@data.declaration {
			@hasDeclaration = true

			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@declaration = VariableDeclaration.new(@data.declaration, this, @bindingScope, @scope:!!!(Scope), false)
				..flagUseExpression()
				..initiate()
		}
		else {
			@bindingScope = @scope!?
		}

		@bodyScope = @newScope(@bindingScope, ScopeType.InlineBlock)
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
				throw NotSupportedException.new()
			}

			@path = @name
		}
		else {
			@value.prepare(AnyType.NullableUnexplicit)

			@valueType = @value.type()

			if @reusableValue {
				@name = @scope.acquireTempName(false)
				@path = @value.path()
			}
			else {
				@name = @scope.getVariable(@data.expression.name).getSecureName()
				@path = @name
			}
		}

		@bodyScope.setImplicitVariable(@name, @valueType)

		var late tracker: PossibilityTracker

		if @hasDefaultClause {
			tracker = PossibilityTracker.dummy()
		}
		else {
			tracker = PossibilityTracker.create(@valueType.discard())
		}

		var lastIndex = #@clauses - 1

		var mut maxConditions = 0
		var mut valueType = @valueType
		var types = []

		for var clause, index in @clauses {
			clause.filter.prepare(valueType)

			valueType = clause.filter.inferTypes(@path, @bodyScope, index == lastIndex) ?? valueType

			maxConditions += clause.filter:!!!(MatchFilter).getMaxConditions()

			for var condition in clause.filter.conditions() {
				tracker.exclude(condition)
			}

			clause.body.analyse()
			clause.body.prepare(target)

			if @usingFallthrough {
				clause.name = @scope.acquireTempName(false)
			}
			else {
				types.push(clause.body.type())
			}
		}

		for var test of @tests when test.count > 1 {
			test.name = @scope.acquireTempName(false)

			test.tests = [test.name]
		}

		unless tracker.isFullyMatched() {
			if tracker.isFinite() {
				SyntaxException.throwNotMatchedPossibilities(tracker.listUnmatched(), this)
			}
			else {
				SyntaxException.throwNotMatchedPossibilities(this)
			}
		}

		@type = Type.union(@scope, ...types)

		for var data, name of @initializedVariables {
			var varTypes = []
			var mut initializable = true

			for var clause, index in data.clauses {
				if clause.initializable {
					varTypes.push(clause.type)
				}
				else if !!@clauses[index].body:!!!(Block).isExit(.Expression + .Statement + .Always) {
					initializable = false

					break
				}
			}

			if initializable {
				data.variable.type = Type.union(@scope, ...varTypes)

				@parent.initializeVariable(data.variable, this, this)
			}
		}

		for var data, name of @lateInitVariables {
			var varTypes = []

			for var clause, index in data.clauses {
				if clause.initializable {
					varTypes.push(clause.type)
				}
				else if !@clauses[index].body:!!!(Block).isExit(.Expression + .Statement + .Always) {
					SyntaxException.throwMissingAssignmentMatchClause(name, @clauses[index].body)
				}
			}

			var type = Type.union(@scope, ...varTypes)

			@parent.initializeVariable(VariableBrief.new(name, type), this, this)
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
	assignTempVariables(scope: Scope) => @statement().assignTempVariables(scope)
	flagImplementedTest(type, details? = null) { # {{{
		if var data ?= @tests[type] {
			if ?details || ?data.details {
				if data.details == details {
					data.implemented = true
				}
			}
			else {
				data.implemented = true
			}
		}
	} # }}}
	getArrayTests(testingType: Boolean, minmax: Object?, type: Type?) { # {{{
		var hash = `$Array,\(testingType),\(JSON.stringify(minmax ?? '')),\(type?.hashCode() ?? '')`

		if var data ?= @tests[hash] ;; ?data.tests {
			return data.tests
		}
		else {
			return null
		}
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
	getValueName() => @valueName
	getValueType() => @valueType
	isInline() => false
	isInSituStatement() => @insitu
	name() => @name
	path() => @path
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
			fragments.newLine().code($runtime.scope(this), @name, ' = ').compile(@value).done()
		}

		for var test of @tests when test.count > 1 {
			var line = fragments.newLine()

			line.code(`\($runtime.scope(this))\(test.name) = \($runtime.helper(this)).memo(`)

			if test.kind == TestKind.ARRAY {
				var { testingType, minmax, type } = test

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
				var { testingType, type } = test

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
	type() => @type
}

abstract class PossibilityTracker {
	static {
		create(type: Type): PossibilityTracker { # {{{
			if type is EnumType {
				return EnumPossibilityTracker.new(type)
			}
			if type is ObjectType && type.isVariant() {
				return EnumPossibilityTracker.new(type.getVariantType().getEnumType())
			}

			return DummyPossibilityTracker.new()
		} # }}}
		dummy(): PossibilityTracker { # {{{
			return DummyPossibilityTracker.new()
		} # }}}
	}
	abstract {
		isFinite(): Boolean
		isFullyMatched(): Boolean
		listUnmatched(): String[]
	}
	exclude(condition) { # {{{
		throw NotSupportedException.new()
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
		@type: BitmaskType | EnumType
	}
	constructor(@type) { # {{{
		super()

		@possibilities = type.listValueNames()
	} # }}}
	exclude(condition: MatchConditionType) { # {{{
		for var { name } in condition.type().getSubtypes() {
			if var value ?= @type.getValue(name) {
				if value.isAlias() {
					@possibilities.remove(...value.originals()!?)
				}
				else {
					@possibilities.remove(name)
				}
			}
		}
	} # }}}
	exclude(condition: MatchConditionValue) { # {{{
		for var value in condition.values() {
			match value {
				UnaryOperatorImplicit, MemberExpression {
					if var property ?= @type.getValue(value.property()) {
						if property.isAlias() {
							@possibilities.remove(...property.originals()!?)
						}
						else {
							@possibilities.remove(property.name())
						}
					}
				}
				else {
					throw NotImplementedException.new()
				}
			}
		}
	} # }}}
	override isFinite() => true
	override isFullyMatched() => !?#@possibilities
	override listUnmatched() => @possibilities
}
