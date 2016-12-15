class ArrayBinding extends Expression {
	private {
		_elements			= []
		_existing			= {}
		_existingCount		= 0
		_nonexisting		= {}
		_nonexistingCount	= 0
		_variables			= {}
	}
	analyse() { // {{{
		for element in this._data.elements {
			if element.kind == Kind::BindingElement && !element.name.computed {
				if this._scope.hasVariable(element.name.name) {
					this._existing[element.name.name] = true
					++this._existingCount
				}
				else {
					this._nonexisting[element.name.name] = true
					++this._nonexistingCount
				}
			}
			
			this._elements.push($compile.expression(element, this))
		}
	} // }}}
	fuse() { // {{{
		for element in this._elements {
			element.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._existingCount && this._nonexistingCount {
			fragments.code('[')
			
			let name
			for element, i in this._data.elements {
				fragments.code(', ') if i
				
				if element.kind == Kind::BindingElement && !element.name.computed && this._existing[element.name.name] {
					name = this._scope.acquireTempName()
					
					this._elements[i].toFragments(fragments, Kind::ArrayBinding, name)
					
					this._variables[name] = element.name.name
				}
				else {
					this._elements[i].toFragments(fragments)
				}
			}
			
			fragments.code(']')
			
			this.statement().afterward(this)
		}
		else {
			fragments.code('[')
			
			for i from 0 til this._elements.length {
				fragments.code(', ') if i
				
				this._elements[i].toFragments(fragments)
			}
			
			fragments.code(']')
		}
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		for name, variable of this._variables {
			fragments.line(variable, ' = ', name)
			
			this._scope.releaseTempName(name)
		}
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		if this._nonexistingCount {
			fragments.code('var ')
		}
		
		this.toFragments(fragments, Mode::None)
	} // }}}
}

class BindingElement extends Expression {
	private {
		_alias
		_defaultValue
		_name
	}
	BindingElement(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
		$variable.define(this.statement(), this.statement().scope(), this._data.name, VariableKind::Variable)
		
		if this._data.alias? {
			$variable.define(this, this._scope, this._data.alias, VariableKind::Variable)
			
			this._alias = $compile.expression(this._data.alias, this)
		}
		
		this._name = $compile.expression(this._data.name, this)
		this._defaultValue = $compile.expression(this._data.defaultValue, this) if this._data.defaultValue?
	} // }}}
	fuse() { // {{{
		this._alias.fuse() if this._alias?
		this._name.fuse()
		this._defaultValue.fuse() if this._defaultValue?
	} // }}}
	toFragments(fragments) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
		
		if this._alias? {
			if this._data.alias.computed {
				fragments.code('[').compile(this._alias).code(']: ')
			}
			else {
				fragments.compile(this._alias).code(': ')
			}
		}
		
		fragments.compile(this._name)
		
		if this._defaultValue? {
			fragments.code(' = ').compile(this._defaultValue)
		}
	} // }}}
	toFragments(fragments, kind, name) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
		
		if this._alias? {
			if this._data.alias.computed {
				fragments.code('[').compile(this._alias).code(']: ')
			}
			else {
				fragments.compile(this._alias).code(': ')
			}
		}
		
		if kind == Kind::ArrayBinding {
			fragments.code(name)
		}
		else {
			fragments.compile(this._name).code(': ', name)
		}
		
		if this._defaultValue? {
			fragments.code(' = ').compile(this._defaultValue)
		}
	} // }}}
}

class ObjectBinding extends Expression {
	private {
		_elements			= []
		_exists				= false
		_existing			= {}
		_variables			= {}
	}
	analyse() { // {{{
		for element in this._data.elements {
			if !element.name.computed && element.name.name? && this._scope.hasVariable(element.name.name) {
				this._exists = true
				this._existing[element.name.name] = true
			}
			
			this._elements.push($compile.expression(element, this))
		}
	} // }}}
	fuse() { // {{{
		for element in this._elements {
			element.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._exists {
			fragments.code('{')
			
			let name
			for element, i in this._data.elements {
				fragments.code(', ') if i
				
				if this._existing[element.name.name] {
					name = this._scope.acquireTempName()
					
					this._elements[i].toFragments(fragments, Kind::ObjectBinding, name)
					
					this._variables[name] = element.name.name
				}
				else {
					this._elements[i].toFragments(fragments)
				}
			}
			
			fragments.code('}')
			
			this.statement().afterward(this)
		}
		else {
			fragments.code('{')
			
			for i from 0 til this._elements.length {
				fragments.code(', ') if i
				
				this._elements[i].toFragments(fragments)
			}
			
			fragments.code('}')
		}
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		for name, variable of this._variables {
			fragments.line(variable, ' = ', name)
			
			this._scope.releaseTempName(name)
		}
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		fragments.code('var ')
		
		this.toFragments(fragments, Mode::None)
	} // }}}
}