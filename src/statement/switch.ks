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
		let scope = this._scope
		
		if this._data.expression.kind == NodeKind::Identifier {
			this._name = this._data.expression.name
		}
		else {
			this._name = this._scope.acquireTempName()
			this._value = $compile.expression(this._data.expression, this)
		}
		
		let clause, condition, name, exp, value
		for data in this._data.clauses {
			clause = {
				hasTest: false
				bindings: []
				conditions: []
				scope: this.newScope()
			}
			
			this._scope = clause.scope
			
			for condition, conditionIdx in data.conditions {
				if condition.kind == NodeKind::SwitchConditionArray {
					condition = new SwitchConditionArray(condition, this)
				}
				else if condition.kind == NodeKind::SwitchConditionEnum {
					$throw('Not Implemented', this)
				}
				else if condition.kind == NodeKind::SwitchConditionObject {
					$throw('Not Implemented', this)
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
					$throw('Not Implemented', this)
					
					clause.hasTest = true
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
			
			clause.body = $compile.expression($block(data.body), this)
			
			this._clauses.push(clause)
			
			this._scope = scope
		}
	} // }}}
	fuse() { // {{{
		for clause in this._clauses {
			for condition in clause.conditions {
				condition.fuse()
			}
			
			clause.filter.fuse()
			
			clause.body.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._value? {
			fragments
				.newLine()
				.code($variable.scope(this), this._name, ' = ')
				.compile(this._value)
				.done()
		}
		
		let condition
		for clause in this._clauses {
			for condition in clause.conditions {
				condition.toStatementFragments(fragments)
			}
			
			clause.filter.toStatementFragments(fragments)
		}
		
		let ctrl = fragments.newControl()
		let we = false
		
		let i, binding
		for clause, clauseIdx in this._clauses {
			if clause.conditions.length {
				if we {
					$throw('The default clause is before this clause', this)
				}
				
				if clauseIdx {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}
				
				for condition, i in clause.conditions {
					ctrl.code(' || ') if i
					
					condition.toBooleanFragments(ctrl, this._name)
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
		
		this._scope.releaseTempName(this._name) if this._value?
	} // }}}
}

class SwitchBindingArray extends AbstractNode {
	private {
		_array
	}
	analyse() { // {{{
		this._array = $compile.expression(this._data, this)
	} // }}}
	fuse() { // {{{
		this._array.fuse()
	} // }}}
	toFragments(fragments) { // {{{
		let line = fragments.newLine()
		
		this._array.toAssignmentFragments(line, this._parent._name)
		
		line.done()
	} // }}}
}

class SwitchBindingType extends AbstractNode {
	analyse() { // {{{
		$variable.define(this, this._scope, this._data.name, VariableKind::Variable)
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments) { // {{{
		fragments.line($variable.scope(this), this._data.name.name, ' = ', this._parent._name)
	} // }}}
}

class SwitchBindingValue extends AbstractNode {
	analyse() { // {{{
		$variable.define(this, this._scope, this._data, VariableKind::Variable)
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments) { // {{{
		fragments.line($variable.scope(this), this._data.name, ' = ', this._parent._name)
	} // }}}
}

class SwitchConditionArray extends AbstractNode {
	private {
		_name
		_values = []
	}
	analyse() { // {{{
		let nv = true
		for i from 0 til this._data.values.length while nv {
			if this._data.values[i].kind != NodeKind::OmittedExpression {
				nv = false
			}
		}
		
		if !nv {
			this._name = this._scope.parent().acquireTempName()
			
			for value in this._data.values {
				if value.kind != NodeKind::OmittedExpression {
					if value.kind == NodeKind::SwitchConditionRange {
						value = new SwitchConditionRange(value, this)
					}
					else {
						value = new SwitchConditionValue(value, this)
					}
					
					value.analyse()
					
					this._values.push(value)
				}
			}
		}
	} // }}}
	fuse() { // {{{
		for value in this._values {
			value.fuse()
		}
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		this.module().flag('Type')
		
		fragments.code('(', $runtime.typeof('Array', this), '(', name, ')')
		
		let mm = $switch.length(this._data.values)
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
		
		if this._name? {
			fragments.code(' && ', this._name, '(', name, ')')
		}
		
		fragments.code(')')
		
		this._scope.parent().releaseTempName(this._name) if this._name?
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._values.length > 0 {
			let line = fragments.newLine()
			
			line.code($variable.scope(this), this._name, ' = ([')
			
			for value, i in this._data.values {
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
			for value, i in this._data.values {
				if value.kind != NodeKind::OmittedExpression {
					line.code(' && ') if index
					
					this._values[index].toBooleanFragments(line, '__ks_' + i)
					
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
		if this._data.from? {
			this._left = $compile.expression(this._data.from, this)
		}
		else {
			this._left = $compile.expression(this._data.then, this)
			this._from = false
		}
		
		if this._data.to? {
			this._right = $compile.expression(this._data.to, this)
		}
		else {
			this._right = $compile.expression(this._data.til, this)
			this._to = false
		}
	} // }}}
	fuse() { // {{{
		this._left.fuse()
		this._right.fuse()
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		fragments
			.code(name, this._from ? ' >= ' : '>')
			.compile(this._left)
			.code(' && ')
			.code(name, this._to ? ' <= ' : '<')
			.compile(this._right)
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchConditionType extends AbstractNode {
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		$type.check(this, fragments, name, this._data.type)
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchConditionValue extends AbstractNode {
	private {
		_value
	}
	analyse() { // {{{
		this._value = $compile.expression(this._data, this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		fragments
			.code(name, ' === ')
			.compile(this._value)
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
		if this._data.filter? {
			if this._data.bindings.length > 0 {
				this._name = this._scope.parent().acquireTempName()
				
				for binding in this._data.bindings {
					this._bindings.push($compile.expression(binding, this))
				}
			}
			
			this._filter = $compile.expression(this._data.filter, this)
		}
	} // }}}
	fuse() { // {{{
		this._filter.fuse() if this._filter?
	} // }}}
	toBooleanFragments(fragments, nf) { // {{{
		let mm
		for binding in this._data.bindings {
			if binding.kind == NodeKind::ArrayBinding {
				this.module().flag('Type')
				
				if nf {
					fragments.code(' && ')
				}
				else {
					nf = true
				}
				
				fragments.code($runtime.typeof('Array', this), '(', this._parent._name, ')')
				
				mm = $switch.length(binding.elements)
				if mm.min == mm.max {
					if mm.min != Infinity {
						fragments.code(' && ', this._parent._name, '.length === ', mm.min)
					}
				}
				else {
					fragments.code(' && ', this._parent._name, '.length >= ', mm.min)
					
					if mm.max != Infinity {
						fragments.code(' && ', this._parent._name, '.length <= ', mm.max)
					}
				}
			}
		}
		
		if this._name? {
			fragments.code(' && ') if nf
			
			fragments.code(this._name, '(', this._parent._name, ')')
			
			this._scope.parent().releaseTempName(this._name)
		}
		else if this._filter? {
			fragments.code(' && ') if nf
			
			fragments.compile(this._filter)
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._name? {
			let line = fragments.newLine()
			
			line.code($variable.scope(this), this._name, ' = (')
		
			for binding, i in this._bindings {
				line.code(', ') if i
				
				line.compile(binding)
			}
			
			line.code(') => ').compile(this._filter)
			
			line.done()
		}
	} // }}}
}