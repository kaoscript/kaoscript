const $switch = {
	length(elements) { // {{{
		let min = 0
		let max = 0

		for element in elements {
			if element.spread {
				max = Infinity
			}
			else {
				++min
				++max
			}
		}

		return {
			min: min,
			max: max
		}
	} // }}}
}

class SwitchStatement extends Statement {
	private lateinit {
		_castingEnum: Boolean				= false
		_clauses							= []
		_hasDefaultClause: Boolean			= false
		_hasLateInitVariables: Boolean		= false
		_initializedVariables: Dictionary	= {}
		_lateInitVariables					= {}
		_name: String?						= null
		_nextClauseIndex: Number
		_usingFallthrough: Boolean			= false
		_value								= null
		_valueType: Type
	}
	analyse() { // {{{
		if @data.expression.kind != NodeKind::Identifier {
			@value = $compile.expression(@data.expression, this)
			@value.analyse()
		}

		@hasDefaultClause = false

		let condition, binding
		for const data, index in @data.clauses {
			const clause = {
				hasTest: data.filter?
				bindings: []
				conditions: []
				scope: this.newScope(@scope, ScopeType::InlineBlock)
			}

			@clauses.push(clause)

			clause.scope.index = index

			for const ccData in data.conditions {
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

			for const bbData in data.bindings {
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

		for const clause in @clauses {
			clause.body.analyse()
		}

		if @hasLateInitVariables && !@hasDefaultClause {
			for const value, name of @lateInitVariables when value.variable.isImmutable() {
				SyntaxException.throwMissingAssignmentSwitchNoDefault(name, this)
			}
		}
	} // }}}
	prepare() { // {{{
		if @value == null {
			@valueType = @scope.getVariable(@data.expression.name).getRealType()
		}
		else {
			@value.prepare()

			@name = @scope.acquireTempName(false)
			@valueType = @value.type()
		}

		const enumValue = @valueType.isEnum()

		const inferables = {}
		auto enumConditions = 0
		auto maxConditions = 0
		auto first = true

		let maxInferables = @clauses.length

		for const clause, index in @clauses {
			for const condition in clause.conditions {
				condition.prepare()

				if condition.isEnum() {
					++enumConditions
				}

				++maxConditions
			}

			for const binding in clause.bindings {
				binding.prepare()
			}

			clause.filter.prepare()

			clause.body.prepare()

			if @usingFallthrough {
				clause.name = @scope.acquireTempName(false)
			}

			if clause.body.isExit() {
				--maxInferables
			}
			else if first {
				for const data, name of clause.body.scope().listUpdatedInferables() {
					inferables[name] = {
						count: 1
						union: false
						data
					}
				}

				first = false
			}
			else {
				for const data, name of clause.body.scope().listUpdatedInferables() when inferables[name]? {
					if inferables[name].union {
						inferables[name].data.type.addType(data.type)
					}
					else if !data.type.equals(inferables[name].data.type) {
						inferables[name].data.type = Type.union(@scope, inferables[name].data.type, data.type)
						inferables[name].union = inferables[name].data.type.isUnion()
					}

					inferables[name].count++
				}
			}
		}

		if enumConditions != 0 || enumValue {
			if enumValue && enumConditions == maxConditions {
				// do nothing
			}
			else {
				for const clause in @clauses {
					for const condition in clause.conditions {
						condition.setCastingEnum(true)
					}
				}

				if enumValue || @valueType.isAny() {
					@castingEnum = true

					if @name == null {
						@name = @scope.acquireTempName(false)
					}
				}
			}
		}

		for const data, name of @initializedVariables {
			const types = []
			let initializable = true

			for const clause, index in data.clauses {
				if clause.initializable {
					types.push(clause.type)
				}
				else if !clause.body.isExit() {
					initializable = false

					break
				}
			}

			if initializable {
				data.variable.type = Type.union(@scope, ...types)

				@parent.initializeVariable(data.variable, this, this)
			}
		}

		for const data, name of @lateInitVariables {
			const types = []

			for const clause, index in data.clauses {
				if clause.initializable {
					types.push(clause.type)
				}
				else if !@clauses[index].body.isExit() {
					SyntaxException.throwMissingAssignmentSwitchClause(name, @clauses[index].body)
				}
			}

			const type = Type.union(@scope, ...types)

			@parent.initializeVariable(VariableBrief(name, type), this, this)
		}

		for const inferable, name of inferables when inferable.count == maxInferables {
			@scope.updateInferable(name, inferable.data, this)
		}

		if @name != null {
			@scope.releaseTempName(@name)
		}
		else {
			@name = @data.expression.name
		}
	} // }}}
	translate() { // {{{
		if @value != null {
			@value.translate()
		}

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
	} // }}}
	addInitializableVariable(variable, node) { // {{{
		const name = variable.name()

		if !@hasDefaultClause {
			SyntaxException.throwMissingAssignmentSwitchNoDefault(name, this)
		}

		let clauseIndex
		for const clause, index in @clauses {
			if clause.body == node {
				clauseIndex = index

				break
			}
		}

		if const map = @lateInitVariables[name] {
			map.clauses[clauseIndex] = {
				initializable: true
				type: null
			}
		}
		else {
			const map = {
				variable
				clauses: []
			}

			for const i from 0 til @data.clauses.length {
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
	} // }}}
	defineVariables(declarator, scope) { // {{{
		let alreadyDeclared

		for const name in declarator.listAssignments([]) {
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
	} // }}}
	checkReturnType(type: Type) { // {{{
		for const clause in @clauses {
			clause.body.checkReturnType(type)
		}
	} // }}}
	flagUsingFallthrough() { // {{{
		@usingFallthrough = true

		return this
	} // }}}
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { // {{{
		const {name, type} = variable

		if const map = @lateInitVariables[name] {
			let clause = null

			for const cc, i in @clauses {
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

			const clone = node.scope().getVariable(name).clone()

			if clone.isDefinitive() {
				clone.setRealType(type)
			}
			else {
				clone.setDeclaredType(type, true).flagDefinitive()
			}

			node.scope().replaceVariable(name, clone)
		}
		else if !@hasDefaultClause {
			// do nothing
		}
		else if const map = @initializedVariables[name] {
			let clause = null

			for const cc, i in @clauses {
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
			const map = {
				variable
				clauses: []
			}

			for const clause, index in @clauses {
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
	} // }}}
	isJumpable() => true
	isLateInitializable() => true
	isUsingVariable(name) { // {{{
		if @value.isUsingVariable(name) {
			return true
		}

		for const clause in @clauses {
			if clause.body.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	toFallthroughFragments(fragments) { // {{{
		if @nextClauseIndex < @clauses.length {
			fragments.line(`\(@clauses[@nextClauseIndex].name)()`)
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @clauses.length == 0 {
			return
		}

		if @value != null {
			const line = fragments.newLine().code($runtime.scope(this), @name, ' = ').compile(@value)

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
			const line = fragments.newLine().code($runtime.scope(this), @name, ' = ', @data.expression.name)

			if @valueType.isEnum() {
				line.code('.value')
			}
			else if @valueType.isAny() {
				line.code('.valueOf()')
			}

			line.done()
		}

		for const clause, clauseIdx in @clauses {
			for const condition in clause.conditions {
				condition.toStatementFragments(fragments)
			}

			clause.filter.toStatementFragments(fragments)

			if @usingFallthrough {
				const line = fragments.newLine().code(`\($runtime.scope(this))\(clause.name) = () =>`)
				const block = line.newBlock()

				@nextClauseIndex = clauseIdx + 1

				for binding in clause.bindings {
					binding.toFragments(block)
				}

				clause.body.toFragments(block, mode)

				block.done()
				line.done()
			}
		}

		let ctrl = fragments.newControl()
		let we = false

		for const clause, clauseIdx in @clauses {
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

				for const condition, i in clause.conditions {
					ctrl.code(' || ') if i != 0

					condition.toBooleanFragments(ctrl, @name)
				}

				clause.filter.toBooleanFragments(ctrl, true)

				ctrl.code(')').step()

				if @usingFallthrough {
					ctrl.line(`\(clause.name)()`)
				}
				else {
					for const binding in clause.bindings {
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

				clause.filter.toBooleanFragments(ctrl, false)

				ctrl.code(')').step()

				if @usingFallthrough {
					ctrl.line(`\(clause.name)()`)
				}
				else {
					for const binding in clause.bindings {
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
					for const binding in clause.bindings {
						binding.toFragments(ctrl)
					}

					clause.body.toFragments(ctrl, mode)
				}
			}
		}

		ctrl.done()
	} // }}}
}

class SwitchBindingArray extends AbstractNode {
	private {
		_array
	}
	analyse() { // {{{
		@array = $compile.expression(@data, this)
		@array.setAssignment(AssignmentType::Expression)
		@array.analyse()

		@parent.defineVariables(@array, @scope)
	} // }}}
	prepare() { // {{{
		@array.prepare()
	} // }}}
	translate() { // {{{
		@array.translate()
	} // }}}
	toFragments(fragments) { // {{{
		let line = fragments.newLine()

		line.code($runtime.scope(this))

		@array.toAssignmentFragments(line, new Literal(@parent._name, this))

		line.done()
	} // }}}
}

class SwitchBindingType extends AbstractNode {
	analyse() { // {{{
		@scope.define(@data.name.name, false, Type.fromAST(@data.type, this), true, this)
	} // }}}
	prepare()
	translate()
	toFragments(fragments) { // {{{
		fragments.line($runtime.scope(this), @data.name.name, ' = ', @parent._name)
	} // }}}
}

class SwitchBindingValue extends AbstractNode {
	analyse() { // {{{
		@scope.define(@data.name, false, this)
	} // }}}
	prepare()
	translate()
	toFragments(fragments) { // {{{
		fragments.line($runtime.scope(this), @data.name, ' = ', @parent._name)
	} // }}}
}

class SwitchConditionArray extends AbstractNode {
	private {
		_flatten: Boolean	= false
		_name: String?		= null
		_values				= []
	}
	analyse() { // {{{
		@flatten = @options.format.destructuring == 'es5'

		for let value in @data.values {
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
	} // }}}
	prepare() { // {{{
		if @values.length > 0 {
			@name = @scope.parent().acquireTempName(false)
		}

		for value in @values {
			value.prepare()
		}
	} // }}}
	translate() { // {{{
		for value in @values {
			value.translate()
		}
	} // }}}
	isEnum() => false
	toBooleanFragments(fragments, name) { // {{{
		this.module().flag('Type')

		fragments.code('(', $runtime.typeof('Array', this), '(', name, ')')

		let mm = $switch.length(@data.values)
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

		if @name? {
			fragments.code(' && ', @name, '(', name, ')')
		}

		fragments.code(')')
	} // }}}
	toStatementFragments(fragments) { // {{{
		if @values.length > 0 {
			let line = fragments.newLine()

			if @flatten {
				const name = new Literal('__ks__', this)

				line.code($runtime.scope(this), @name, ' = function(__ks__)')

				const block = line.newBlock()

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

				let index = 0
				for value, i in @data.values {
					if value.kind != NodeKind::OmittedExpression {
						if index != 0 {
							line.code(' && ')
						}

						@values[index].toBooleanFragments(line, '__ks_' + i)

						index++
					}
				}
			}

			line.done()
		}
	} // }}}
}

class SwitchConditionRange extends AbstractNode {
	private {
		_from	= true
		_left
		_right
		_to		= true
	}
	analyse() { // {{{
		if @data.from? {
			@left = $compile.expression(@data.from, this)
		}
		else {
			@left = $compile.expression(@data.then, this)
			@from = false
		}

		if @data.to? {
			@right = $compile.expression(@data.to, this)
		}
		else {
			@right = $compile.expression(@data.til, this)
			@to = false
		}

		@left.analyse()
		@right.analyse()
	} // }}}
	prepare() { // {{{
		@left.prepare()
		@right.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
		@right.translate()
	} // }}}
	isEnum() => false
	toBooleanFragments(fragments, name) { // {{{
		fragments
			.code(name, @from ? ' >= ' : '>')
			.compile(@left)
			.code(' && ')
			.code(name, @to ? ' <= ' : '<')
			.compile(@right)
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchConditionType extends AbstractNode {
	private lateinit {
		_type: Type
	}
	analyse()
	prepare() { // {{{
		@type = Type.fromAST(@data.type, this)
	} // }}}
	translate()
	isEnum() => false
	toBooleanFragments(fragments, name) { // {{{
		@type.toTestFragments(fragments, new Literal(false, this, @scope:Scope, name))
	} // }}}
	toStatementFragments(fragments)
}

class SwitchConditionValue extends AbstractNode {
	private lateinit {
		_castingEnum: Boolean	= false
		_value
		_type: Type
	}
	analyse() { // {{{
		@value = $compile.expression(@data, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()

		@type = @value.type()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	isEnum() => @type.isEnum()
	setCastingEnum(@castingEnum)
	toBooleanFragments(fragments, name) { // {{{
		fragments.code(name, ' === ').compile(@value)

		if @castingEnum {
			if @type.isEnum() {
				fragments.code('.value')
			}
			else if @type.isAny() {
				fragments.code('.valueOf()')
			}
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchFilter extends AbstractNode {
	private {
		_bindings			= []
		_filter				= null
		_flatten: Boolean	= false
		_name				= null
	}
	analyse() { // {{{
		@flatten = @options.format.destructuring == 'es5'

		if @data.filter? {
			if @data.bindings.length > 0 {
				@name = @scope.parent().acquireTempName(false)

				for const data in @data.bindings {
					const binding = $compile.expression(data, this)

					binding.analyse()

					@bindings.push(binding)
				}
			}

			@filter = $compile.expression(@data.filter, this)
			@filter.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @filter != null {
			for binding in @bindings {
				binding.prepare()
			}

			@filter.prepare()
		}
	} // }}}
	translate() { // {{{
		if @filter? {
			for binding in @bindings {
				binding.translate()
			}

			@filter.translate()
		}
	} // }}}
	toBooleanFragments(fragments, nf) { // {{{
		let mm
		for binding in @data.bindings {
			if binding.kind == NodeKind::ArrayBinding {
				this.module().flag('Type')

				if nf {
					fragments.code(' && ')
				}
				else {
					nf = true
				}

				fragments.code($runtime.typeof('Array', this), '(', @parent._name, ')')

				mm = $switch.length(binding.elements)
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

		if @name? {
			fragments.code(' && ') if nf

			fragments.code(@name, '(', @parent._name, ')')

			@scope.parent().releaseTempName(@name)
		}
		else if @filter? {
			fragments.code(' && ') if nf

			fragments.compile(@filter)
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		if @name != null {
			let line = fragments.newLine()

			if @flatten {
				const name = new Literal('__ks__', this)

				line.code($runtime.scope(this), @name, ' = function(__ks__)')

				const block = line.newBlock()

				const ln = block.newLine().code($runtime.scope(this))

				let comma = false
				for const binding in @bindings {
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
	} // }}}
}