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
	private {
		_clauses	= []
		_name
		_value
	}
	analyse() { // {{{
		let scope = @scope
		
		if @data.expression.kind == NodeKind::Identifier {
			@name = @data.expression.name
		}
		else {
			@value = $compile.expression(@data.expression, this)
			@value.analyse()
		}
		
		let clause, condition, name, exp, value
		for data in @data.clauses {
			clause = {
				hasTest: false
				bindings: []
				conditions: []
				scope: this.newScope()
			}
			
			@scope = clause.scope
			
			for condition, conditionIdx in data.conditions {
				if condition.kind == NodeKind::SwitchConditionArray {
					condition = new SwitchConditionArray(condition, this)
				}
				else if condition.kind == NodeKind::SwitchConditionEnum {
					throw new NotImplementedException(this)
				}
				else if condition.kind == NodeKind::SwitchConditionObject {
					throw new NotImplementedException(this)
				}
				else if condition.kind == NodeKind::SwitchConditionRange {
					condition = new SwitchConditionRange(condition, this)
				}
				else if condition.kind == NodeKind::SwitchConditionType {
					condition = new SwitchConditionType(condition, this)
				}
				else {
					condition = new SwitchConditionValue(condition, this)
				}
				
				condition.analyse()
				
				clause.conditions.push(condition)
			}
			
			for binding in data.bindings {
				if binding.kind == NodeKind::ArrayBinding {
					binding = new SwitchBindingArray(binding, this)
					
					clause.hasTest = true
				}
				else if binding.kind == NodeKind::ObjectBinding {
					throw new NotImplementedException(this)
				}
				else if binding.kind == NodeKind::SwitchTypeCasting {
					binding = new SwitchBindingType(binding, this)
				}
				else {
					binding = new SwitchBindingValue(binding, this)
				}
				
				binding.analyse()
				
				clause.bindings.push(binding)
			}
			
			clause.filter = new SwitchFilter(data, this)
			clause.filter.analyse()
			
			clause.hasTest = true if data.filter?
			
			clause.body = $compile.expression($ast.block(data.body), this)
			clause.body.analyse()
			
			@clauses.push(clause)
			
			@scope = scope
		}
	} // }}}
	prepare() { // {{{
		if @data.expression.kind == NodeKind::Identifier {
			@name = @data.expression.name
		}
		else {
			@name = @scope.acquireTempName()
		}
		
		@value.prepare() if @value?
		
		for clause in @clauses {
			for condition in clause.conditions {
				condition.prepare()
			}
			
			for binding in clause.bindings {
				binding.prepare()
			}
			
			clause.filter.prepare()
			
			clause.body.prepare()
		}
		
		if @data.expression.kind != NodeKind::Identifier {
			@scope.releaseTempName(@name)
		}
	} // }}}
	translate() { // {{{
		@value.translate() if @value?
		
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
	toStatementFragments(fragments, mode) { // {{{
		if @value? {
			fragments
				.newLine()
				.code($runtime.scope(this), @name, ' = ')
				.compile(@value)
				.done()
		}
		
		let condition
		for clause in @clauses {
			for condition in clause.conditions {
				condition.toStatementFragments(fragments)
			}
			
			clause.filter.toStatementFragments(fragments)
		}
		
		let ctrl = fragments.newControl()
		let we = false
		
		let i, binding
		for clause, clauseIdx in @clauses {
			if clause.conditions.length {
				if we {
					SyntaxException.throwAfterDefaultClause(this)
				}
				
				if clauseIdx {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}
				
				for condition, i in clause.conditions {
					ctrl.code(' || ') if i
					
					condition.toBooleanFragments(ctrl, @name)
				}
				
				clause.filter.toBooleanFragments(ctrl, true)
				
				ctrl.code(')').step()
				
				for binding in clause.bindings {
					binding.toFragments(ctrl)
				}
				
				clause.body.toFragments(ctrl, mode)
			}
			else if clause.hasTest {
				if clauseIdx {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}
				
				clause.filter.toBooleanFragments(ctrl, false)
				
				ctrl.code(')').step()
				
				for binding in clause.bindings {
					binding.toFragments(ctrl)
				}
				
				clause.body.toFragments(ctrl, mode)
			}
			else {
				if clauseIdx {
					ctrl.step().code('else')
				}
				else {
					ctrl.code('if(true)')
				}
				
				we = true
				
				ctrl.step()
				
				for binding in clause.bindings {
					binding.toFragments(ctrl)
				}
				
				clause.body.toFragments(ctrl, mode)
			}
		}
		
		ctrl.done()
		
		@scope.releaseTempName(@name) if @value?
	} // }}}
}

class SwitchBindingArray extends AbstractNode {
	private {
		_array
	}
	analyse() { // {{{
		@array = $compile.expression(@data, this)
		@array.analyse()
	} // }}}
	prepare() { // {{{
		@array.prepare()
	} // }}}
	translate() { // {{{
		@array.translate()
	} // }}}
	toFragments(fragments) { // {{{
		let line = fragments.newLine()
		
		@array.toAssignmentFragments(line, @parent._name)
		
		line.done()
	} // }}}
}

class SwitchBindingType extends AbstractNode {
	analyse() { // {{{
		@scope.define(@data.name.name, false, this)
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
		_name
		_values = []
	}
	analyse() { // {{{
		let nv = true
		for i from 0 til @data.values.length while nv {
			if @data.values[i].kind != NodeKind::OmittedExpression {
				nv = false
			}
		}
		
		if !nv {
			@name = @scope.parent().acquireTempName()
			
			for value in @data.values {
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
		}
	} // }}}
	prepare() { // {{{
		for value in @values {
			value.prepare()
		}
	} // }}}
	translate() { // {{{
		for value in @values {
			value.translate()
		}
	} // }}}
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
		
		@scope.parent().releaseTempName(@name) if @name?
	} // }}}
	toStatementFragments(fragments) { // {{{
		if @values.length > 0 {
			let line = fragments.newLine()
			
			line.code($runtime.scope(this), @name, ' = ([')
			
			for value, i in @data.values {
				line.code(', ') if i
				
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
					line.code(' && ') if index
					
					@values[index].toBooleanFragments(line, '__ks_' + i)
					
					index++
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
	private {
		_type: Type
	}
	analyse()
	prepare() { // {{{
		@type = Type.fromAST(@data.type, this)
	} // }}}
	translate()
	toBooleanFragments(fragments, name) { // {{{
		@type.toTestFragments(fragments, new Literal(false, this, @scope, name))
	} // }}}
	toStatementFragments(fragments)
}

class SwitchConditionValue extends AbstractNode {
	private {
		_value
	}
	analyse() { // {{{
		@value = $compile.expression(@data, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		fragments
			.code(name, ' === ')
			.compile(@value)
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchFilter extends AbstractNode {
	private {
		_bindings = []
		_filter
		_name
	}
	analyse() { // {{{
		if @data.filter? {
			if @data.bindings.length > 0 {
				@name = @scope.parent().acquireTempName()
				
				for binding in @data.bindings {
					@bindings.push(binding = $compile.expression(binding, this))
					
					binding.analyse()
				}
			}
			
			@filter = $compile.expression(@data.filter, this)
			@filter.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @filter? {
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
		if @name? {
			let line = fragments.newLine()
			
			line.code($runtime.scope(this), @name, ' = (')
		
			for binding, i in @bindings {
				line.code(', ') if i
				
				line.compile(binding)
			}
			
			line.code(') => ').compile(@filter)
			
			line.done()
		}
	} // }}}
}