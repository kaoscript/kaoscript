class MatchExpression extends Expression {
	private late {
		@castingEnum: Boolean				= false
		@clauses							= []
		@declarator
		@hasDefaultClause: Boolean			= false
		@hasLateInitVariables: Boolean		= false
		@initializedVariables: Object		= {}
		@insitu: Boolean					= false
		@lateInitVariables					= {}
		@name: String?						= null
		@nextClauseIndex: Number
		@reusableValue: Boolean				= false
		@usingFallthrough: Boolean			= false
		@value								= null
		@valueName: String?						= null
		@valueType: Type
	}
	override analyse() { # {{{
		@value = $compile.expression(@data.expression, this)
		@value.analyse()

		@reusableValue = @value is not IdentifierLiteral
		@hasDefaultClause = false

		var dyn condition, binding
		for var data, index in @data.clauses {
			var clause = {
				hasTest: ?data.filter
				bindings: []
				conditions: []
				scope: @newScope(@scope!?, ScopeType::InlineBlock)
			}

			@clauses.push(clause)

			clause.scope.index = index

			for var ccData in data.conditions {
				if ccData.kind == NodeKind::MatchConditionArray {
					condition = new MatchConditionArray(ccData, this, clause.scope)
				}
				else if ccData.kind == NodeKind::MatchConditionObject {
					throw new NotImplementedException(this)
				}
				else if ccData.kind == NodeKind::MatchConditionRange {
					condition = new MatchConditionRange(ccData, this, clause.scope)
				}
				else if ccData.kind == NodeKind::MatchConditionType {
					condition = new MatchConditionType(ccData, this, clause.scope)
				}
				else {
					condition = new MatchConditionValue(ccData, this, clause.scope)
				}

				condition.analyse()

				clause.conditions.push(condition)
			}

			if clause.conditions.length == 0 {
				@hasDefaultClause = true
			}

			for var bbData in data.bindings {
				if bbData.kind == NodeKind::ArrayBinding {
					binding = new MatchBindingArray(bbData, this, clause.scope)

					clause.hasTest = true
				}
				else if bbData.kind == NodeKind::ObjectBinding {
					throw new NotImplementedException(this)
				}
				else {
					binding = new MatchBindingValue(bbData, this, clause.scope)
				}

				binding.analyse()

				clause.bindings.push(binding)
			}

			clause.filter = new MatchFilter(data, this, clause.scope)
			clause.filter.analyse()

			if data.body.kind == NodeKind::Block {
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

			// TODO!
			// if declarators.length == 1 && declarator is VariableIdentifierDeclarator {
			if declarators.length == 1 {
				if declarator is VariableIdentifierDeclarator {
					@declarator = declarator
					@insitu = true
				}
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

		@value.prepare(AnyType.NullableUnexplicit)

		@valueType = @value.type()

		var late tracker: PossibilityTracker

		if @hasDefaultClause {
			tracker = PossibilityTracker.dummy()
		}
		else {
			if @valueType.isFinite() {
				tracker = PossibilityTracker.create(@valueType.discard())
			}
			else {
				SyntaxException.throwMissingElseClause(this)
			}
		}

		if @reusableValue {
			@name = @scope.acquireTempName(false)
		}

		var enumValue = @valueType.isEnum()

		var mut enumConditions = 0
		var mut maxConditions = 0

		for var clause, index in @clauses {
			for var condition in clause.conditions {
				condition.prepare(@valueType)

				if condition.isEnum() {
					enumConditions += 1
				}

				maxConditions += 1

				tracker.exclude(condition)
			}

			for var binding in clause.bindings {
				binding.prepare()
			}

			clause.filter.prepare(@scope.reference('Boolean'))

			clause.body.prepare(target)

			if @usingFallthrough {
				clause.name = @scope.acquireTempName(false)
			}
		}

		unless tracker.isFullyMatched() {
			if @valueType.isFinite() {
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
					for var condition in clause.conditions {
						condition.setCastingEnum(true)
					}
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

		if @reusableValue {
			@scope.releaseTempName(@name)
		}
		else {
			@name = @scope.getVariable(@data.expression.name).getSecureName()
		}
	} # }}}
	override translate() { # {{{
		@value.translate()

		for clause in @clauses {
			for condition in clause.conditions {
				condition.translate()
			}

			for binding in clause.bindings {
				binding.translate()
			}

			clause.filter.translate()

			clause.body.translate()
		}
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
		if @reusableValue {
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

		for var clause, clauseIdx in @clauses {
			for var condition in clause.conditions {
				condition.toStatementFragments(fragments)
			}

			clause.filter.toStatementFragments(fragments)

			if @usingFallthrough {
				var line = fragments.newLine().code(`\($runtime.scope(this))\(clause.name) = () =>`)
				var block = line.newBlock()

				@nextClauseIndex = clauseIdx + 1

				for binding in clause.bindings {
					binding.toFragments(block)
				}

				clause.body.toFragments(block, mode)

				block.done()
				line.done()
			}
		}

		var mut ctrl = fragments.newControl()
		var mut we = false

		for var clause, clauseIdx in @clauses {
			if clause.conditions.length != 0 {
				if we {
					SyntaxException.throwAfterDefaultClause(this)
				}

				if clauseIdx != 0 {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}

				for var condition, i in clause.conditions {
					ctrl.code(' || ') if i != 0

					condition.toConditionFragments(ctrl, @name)
				}

				clause.filter.toConditionFragments(ctrl, true)

				ctrl.code(')').step()

				if @usingFallthrough {
					ctrl.line(`\(clause.name)()`)
				}
				else {
					for var binding in clause.bindings {
						binding.toFragments(ctrl)
					}

					clause.body.toFragments(ctrl, mode)
				}
			}
			else if clause.hasTest {
				if clauseIdx != 0 {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}

				clause.filter.toConditionFragments(ctrl, false)

				ctrl.code(')').step()

				if @usingFallthrough {
					ctrl.line(`\(clause.name)()`)
				}
				else {
					for var binding in clause.bindings {
						binding.toFragments(ctrl)
					}

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
					for var binding in clause.bindings {
						binding.toFragments(ctrl)
					}

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

			throw new NotImplementedException()
		} # }}}
		dummy(): PossibilityTracker { # {{{
			return new DummyPossibilityTracker()
		} # }}}
	}
	abstract {
		isFullyMatched(): Boolean
		// TODO!
		// listUnmatched(): String[]
	}
	exclude(condition) { # {{{
		throw new NotSupportedException()
	} # }}}
}

class DummyPossibilityTracker extends PossibilityTracker {
	override exclude(_)
	override isFullyMatched() => true
	listUnmatched() => []
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
	override isFullyMatched() => !#@possibilities
	listUnmatched() => @possibilities
}
