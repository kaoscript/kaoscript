var $switch = {
	length(elements) { # {{{
		var mut min = 0
		var mut max = 0

		for element in elements {
			if element.spread {
				max = Infinity
			}
			else {
				min += 1
				max += 1
			}
		}

		return {
			min: min,
			max: max
		}
	} # }}}
}

class SwitchStatement extends Statement {
	private late {
		@castingEnum: Boolean				= false
		@clauses							= []
		@hasDefaultClause: Boolean			= false
		@hasLateInitVariables: Boolean		= false
		@initializedVariables: Object		= {}
		@lateInitVariables					= {}
		@name: String?						= null
		@nextClauseIndex: Number
		@reusableValue: Boolean				= false
		@usingFallthrough: Boolean			= false
		@value								= null
		@valueType: Type
	}
	analyse() { # {{{
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
				scope: @newScope(@scope, ScopeType::InlineBlock)
			}

			@clauses.push(clause)

			clause.scope.index = index

			for var ccData in data.conditions {
				if ccData.kind == NodeKind::SwitchConditionArray {
					condition = new SwitchConditionArray(ccData, this, clause.scope)
				}
				else if ccData.kind == NodeKind::SwitchConditionEnum {
					throw new NotImplementedException(this)
				}
				else if ccData.kind == NodeKind::SwitchConditionObject {
					throw new NotImplementedException(this)
				}
				else if ccData.kind == NodeKind::SwitchConditionRange {
					condition = new SwitchConditionRange(ccData, this, clause.scope)
				}
				else if ccData.kind == NodeKind::SwitchConditionType {
					condition = new SwitchConditionType(ccData, this, clause.scope)
				}
				else {
					condition = new SwitchConditionValue(ccData, this, clause.scope)
				}

				condition.analyse()

				clause.conditions.push(condition)
			}

			if clause.conditions.length == 0 {
				@hasDefaultClause = true
			}

			for var bbData in data.bindings {
				if bbData.kind == NodeKind::ArrayBinding {
					binding = new SwitchBindingArray(bbData, this, clause.scope)

					clause.hasTest = true
				}
				else if bbData.kind == NodeKind::ObjectBinding {
					throw new NotImplementedException(this)
				}
				else if bbData.kind == NodeKind::SwitchTypeCasting {
					binding = new SwitchBindingType(bbData, this, clause.scope)
				}
				else {
					binding = new SwitchBindingValue(bbData, this, clause.scope)
				}

				binding.analyse()

				clause.bindings.push(binding)
			}

			clause.filter = new SwitchFilter(data, this, clause.scope)
			clause.filter.analyse()

			clause.body = $compile.block(data.body, this, clause.scope)
		}

		for var clause in @clauses {
			clause.body.analyse()
		}

		if @hasLateInitVariables && !@hasDefaultClause {
			for var value, name of @lateInitVariables when value.variable.isImmutable() {
				SyntaxException.throwMissingAssignmentSwitchNoDefault(name, this)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(AnyType.NullableUnexplicit)

		@valueType = @value.type()

		if @reusableValue {
			@name = @scope.acquireTempName(false)
		}

		var enumValue = @valueType.isEnum()

		var inferables = {}
		var mut enumConditions = 0
		var mut maxConditions = 0

		var mut maxInferables = @clauses.length

		for var clause, index in @clauses {
			for var condition in clause.conditions {
				condition.prepare(@valueType)

				if condition.isEnum() {
					enumConditions += 1
				}

				maxConditions += 1
			}

			for var binding in clause.bindings {
				binding.prepare()
			}

			clause.filter.prepare(@scope.reference('Boolean'))

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
					SyntaxException.throwMissingAssignmentSwitchClause(name, @clauses[index].body)
				}
			}

			var type = Type.union(@scope, ...types)

			@parent.initializeVariable(VariableBrief(name, type), this, this)
		}

		for var inferable, name of inferables {
			if inferable.count == maxInferables {
				@scope.updateInferable(name, inferable.data, this)
			}
			else if inferable.data.isVariable {
				@scope.replaceVariable(name, inferable.data.type, true, false, this)
			}
		}

		if @reusableValue {
			@scope.releaseTempName(@name)
		}
		else {
			@name = @scope.getVariable(@data.expression.name).getSecureName()
		}
	} # }}}
	translate() { # {{{
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
	addInitializableVariable(variable, node) { # {{{
		var name = variable.name()

		if !@hasDefaultClause {
			SyntaxException.throwMissingAssignmentSwitchNoDefault(name, this)
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
		if @value.isUsingVariable(name) {
			return true
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

class SwitchBindingArray extends AbstractNode {
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
	toFragments(fragments) { # {{{
		var mut line = fragments.newLine()

		line.code($runtime.scope(this))

		@array.toAssignmentFragments(line, new Literal(@parent._name, this))

		line.done()
	} # }}}
}

class SwitchBindingType extends AbstractNode {
	analyse() { # {{{
		@scope.define(@data.name.name, false, Type.fromAST(@data.type, this), true, this)
	} # }}}
	override prepare(target, targetMode)
	translate()
	toFragments(fragments) { # {{{
		fragments.line($runtime.scope(this), @data.name.name, ' = ', @parent._name)
	} # }}}
}

class SwitchBindingValue extends AbstractNode {
	analyse() { # {{{
		@scope.define(@data.name, false, this)
	} # }}}
	override prepare(target, targetMode)
	translate()
	toFragments(fragments) { # {{{
		fragments.line($runtime.scope(this), @data.name, ' = ', @parent._name)
	} # }}}
}

class SwitchConditionArray extends AbstractNode {
	private {
		@flatten: Boolean	= false
		@name: String?		= null
		@values				= []
	}
	analyse() { # {{{
		@flatten = @options.format.destructuring == 'es5'

		for var mut value in @data.values {
			if value.kind != NodeKind::OmittedExpression {
				if value.kind == NodeKind::SwitchConditionRange {
					value = new SwitchConditionRange(value, this)
				}
				else {
					value = new SwitchConditionValue(value, this)
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
	toConditionFragments(fragments, name) { # {{{
		@module().flag('Type')

		fragments.code('(', $runtime.typeof('Array', this), '(', name, ')')

		var mut mm = $switch.length(@data.values)
		if mm.min == mm.max {
			if mm.min != Infinity {
				fragments.code(' && ', name, '.length === ', mm.min)
			}
		}
		else {
			fragments.code(' && ', name, '.length >= ', mm.min)

			if mm.max != Infinity {
				fragments.code(' && ', name, '.length <= ', mm.max)
			}
		}

		if ?@name {
			fragments.code(' && ', @name, '(', name, ')')
		}

		fragments.code(')')
	} # }}}
	toStatementFragments(fragments) { # {{{
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

				for value, i in @data.values {
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
				for value, i in @data.values {
					if value.kind != NodeKind::OmittedExpression {
						if index != 0 {
							line.code(' && ')
						}

						@values[index].toConditionFragments(line, '__ks_' + i)

						index += 1
					}
				}
			}

			line.done()
		}
	} # }}}
}

class SwitchConditionRange extends AbstractNode {
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
	toConditionFragments(fragments, name) { # {{{
		fragments
			.code(name, @from ? ' >= ' : '>')
			.compile(@left)
			.code(' && ')
			.code(name, @to ? ' <= ' : '<')
			.compile(@right)
	} # }}}
	toStatementFragments(fragments) { # {{{
	} # }}}
}

class SwitchConditionType extends AbstractNode {
	private late {
		@type: Type
	}
	analyse()
	override prepare(target, targetMode) { # {{{
		@type = Type.fromAST(@data.type, this)
	} # }}}
	translate()
	isEnum() => false
	toConditionFragments(fragments, name) { # {{{
		@type.toPositiveTestFragments(fragments, new Literal(false, this, @scope:Scope, name))
	} # }}}
	toStatementFragments(fragments)
}

class SwitchConditionValue extends AbstractNode {
	private late {
		@castingEnum: Boolean	= false
		@value
		@type: Type
	}
	analyse() { # {{{
		@value = $compile.expression(@data, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target)

		@type = @value.type()
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	isEnum() => @type.isEnum()
	setCastingEnum(@castingEnum)
	toConditionFragments(fragments, name) { # {{{
		fragments.code(name, ' === ').compile(@value)

		if @castingEnum {
			if @type.isEnum() {
				fragments.code('.value')
			}
			else if @type.isAny() {
				fragments.code('.valueOf()')
			}
		}
	} # }}}
	toStatementFragments(fragments) { # {{{
	} # }}}
}

class SwitchFilter extends AbstractNode {
	private {
		@bindings			= []
		@filter				= null
		@flatten: Boolean	= false
		@name				= null
	}
	analyse() { # {{{
		@flatten = @options.format.destructuring == 'es5'

		if ?@data.filter {
			if @data.bindings.length > 0 {
				@name = @scope.parent().acquireTempName(false)

				for var data in @data.bindings {
					var binding = $compile.expression(data, this)

					binding.analyse()

					@bindings.push(binding)
				}
			}

			@filter = $compile.expression(@data.filter, this)
			@filter.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @filter != null {
			for binding in @bindings {
				binding.prepare()
			}

			@filter.prepare(target)
		}
	} # }}}
	translate() { # {{{
		if ?@filter {
			for binding in @bindings {
				binding.translate()
			}

			@filter.translate()
		}
	} # }}}
	toConditionFragments(fragments, mut nf) { # {{{
		for binding in @data.bindings {
			if binding.kind == NodeKind::ArrayBinding {
				@module().flag('Type')

				if nf {
					fragments.code(' && ')
				}
				else {
					nf = true
				}

				fragments.code($runtime.typeof('Array', this), '(', @parent._name, ')')

				var mm = $switch.length(binding.elements)
				if mm.min == mm.max {
					if mm.min != Infinity {
						fragments.code(' && ', @parent._name, '.length === ', mm.min)
					}
				}
				else {
					fragments.code(' && ', @parent._name, '.length >= ', mm.min)

					if mm.max != Infinity {
						fragments.code(' && ', @parent._name, '.length <= ', mm.max)
					}
				}
			}
		}

		if ?@name {
			fragments.code(' && ') if nf

			fragments.code(@name, '(', @parent._name, ')')

			@scope.parent().releaseTempName(@name)
		}
		else if ?@filter {
			if nf {
				fragments.code(' && ').wrapCondition(@filter, Mode::None, Junction::AND)
			}
			else {
				fragments.compileCondition(@filter)
			}
		}
	} # }}}
	toStatementFragments(fragments) { # {{{
		if @name != null {
			var mut line = fragments.newLine()

			if @flatten {
				var name = new Literal('__ks__', this)

				line.code($runtime.scope(this), @name, ' = function(__ks__)')

				var block = line.newBlock()

				var ln = block.newLine().code($runtime.scope(this))

				var mut comma = false
				for var binding in @bindings {
					if comma {
						line.code(', ')
					}
					else {
						comma = true
					}

					binding.toFlatFragments(ln, name)
				}

				ln.done()

				block.newLine().code('return ').compile(@filter).done()

				block.done()
			}
			else {
				line.code($runtime.scope(this), @name, ' = (')

				for binding, i in @bindings {
					line.code(', ') if i != 0

					line.compile(binding)
				}

				line.code(') => ').compile(@filter)
			}

			line.done()
		}
	} # }}}
}
