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
		for element, index in this._data.elements {
			if element.kind == NodeKind::BindingElement && !element.name.computed {
				if this._scope.hasVariable(element.name.name) {
					this._existing[element.name.name] = true
					++this._existingCount
				}
				else {
					this._nonexisting[element.name.name] = true
					++this._nonexistingCount
				}
			}
			
			this._elements.push(element = $compile.expression(element, this))
			
			if element is BindingElement {
				element.index(index)
			}
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
				
				if element.kind == NodeKind::BindingElement && !element.name.computed && this._existing[element.name.name] {
					name = this._scope.acquireTempName()
					
					this._elements[i].toExistFragments(fragments, name)
					
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
	toAssignmentFragments(fragments, value) { // {{{
		if this._nonexistingCount {
			fragments.code('var ')
		}
		
		if this._options.format.destructuring == 'es5' {
			this.toFlatFragments(fragments, value)
		}
		else {
			fragments
				.compile(this)
				.code($equals)
				.compile(value)
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if value.isComposite() {
			if this._elements.length == 1 {
				this._elements[0].toFlatFragments(fragments, value)
			}
			else {
				let variable = new IdentifierLiteral({
					kind: NodeKind::Identifier
					name: this._name
				}, this, this._scope, false)
				
				this._elements[0].toFlatFragments(fragments, new TempBinding(variable, value, this))
				
				for i from 1 til this._elements.length {
					fragments.code(', ')
					
					this._elements[i].toFlatFragments(fragments, variable)
				}
			}
		}
		else {
			for i from 0 til this._elements.length {
				fragments.code(', ') if i
				
				this._elements[i].toFlatFragments(fragments, value)
			}
		}
	} // }}}
}

class BindingElement extends Expression {
	private {
		_alias
		_defaultValue	 = null
		_index			= -1
		_name
		_variable
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
		$variable.define(this.statement(), this.statement().scope(), this._data.name, VariableKind::Variable)
		
		if this._data.alias? {
			$variable.define(this, this._scope, this._data.alias, VariableKind::Variable)
			
			this._alias = $compile.expression(this._data.alias, this)
		}
		
		this._name = $compile.expression(this._data.name, this)
		
		if this._data.defaultValue? {
			this._defaultValue = $compile.expression(this._data.defaultValue, this)
			
			if this._options.format.destructuring == 'es5' {
				this._variable = this._scope.acquireTempName(this.statement())
				
				this._scope.releaseTempName(this._variable)
			}
		}
	} // }}}
	fuse() { // {{{
		this._alias.fuse() if this._alias?
		this._name.fuse()
		this._defaultValue.fuse() if this._defaultValue?
	} // }}}
	index(@index) => this
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
	toExistFragments(fragments, name) { // {{{
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
		
		if this._index == -1 {
			fragments.compile(this._name).code(': ', name)
		}
		else {
			fragments.code(name)
		}
		
		if this._defaultValue != null {
			fragments.code(' = ').compile(this._defaultValue)
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if this._name is ObjectBinding {
			this._name.toFlatFragments(fragments, new FlatBindingElement(value, this._alias ?? this._name, this))
		}
		else if this._defaultValue? {
			let variable = new IdentifierLiteral({
				kind: NodeKind::Identifier
				name: this._variable
			}, this, this._scope, false)
			
			fragments
				.compile(this._name)
				.code($equals, 'Type.isValue(')
				.compile(variable)
				.code($equals)
				.compile(new FlatBindingElement(value, this._alias ?? this._name, this))
				.code(') ? ')
				.compile(variable)
				.code(' : ')
				.compile(this._defaultValue)
		}
		else if this._index == -1 {
			fragments
				.compile(this._name)
				.code($equals)
				.wrap(value)
				.code('.')
				.compile(this._alias ?? this._name)
		}
		else {
			fragments
				.compile(this._name)
				.code($equals)
				.wrap(value)
				.code(`[\(this._index)]`)
		}
	} // }}}
}

class FlatBindingElement extends Expression {
	private {
		_item
		_property
	}
	constructor(@item, @property, parent) { // {{{
		super({}, parent)
	} // }}}
	isComposite() => false
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(this._item)
			.code('.')
			.compile(this._property)
	} // }}}
}

class ObjectBinding extends Expression {
	private {
		_elements			= []
		_exists				= false
		_existing			= {}
		_name				= null
		_variables			= {}
	}
	analyse() { // {{{
		if this._options.format.destructuring == 'es5' && this._data.elements.length > 1 {
			this._name = this._scope.acquireTempName(this.statement())
		}
		
		for element in this._data.elements {
			if !element.name.computed && element.name.name? && this._scope.hasVariable(element.name.name) {
				this._exists = true
				this._existing[element.name.name] = true
			}
			
			this._elements.push($compile.expression(element, this))
		}
		
		if this._name != null {
			this._scope.releaseTempName(this._name)
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
					
					this._elements[i].toExistFragments(fragments, name)
					
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
	toAssignmentFragments(fragments, value) { // {{{
		fragments.code('var ')
		
		if this._options.format.destructuring == 'es5' {
			this.toFlatFragments(fragments, value)
		}
		else {
			fragments
				.compile(this)
				.code($equals)
				.compile(value)
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if value.isComposite() {
			if this._elements.length == 1 {
				this._elements[0].toFlatFragments(fragments, value)
			}
			else {
				let variable = new IdentifierLiteral({
					kind: NodeKind::Identifier
					name: this._name
				}, this, this._scope, false)
				
				this._elements[0].toFlatFragments(fragments, new TempBinding(variable, value, this))
				
				for i from 1 til this._elements.length {
					fragments.code(', ')
					
					this._elements[i].toFlatFragments(fragments, variable)
				}
			}
		}
		else {
			for i from 0 til this._elements.length {
				fragments.code(', ') if i
				
				this._elements[i].toFlatFragments(fragments, value)
			}
		}
	} // }}}
}

class TempBinding extends Expression {
	private {
		_name
		_value
	}
	constructor(@name, @value, parent) { // {{{
		super({}, parent)
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		fragments
			.compile(this._name)
			.code($equals)
			.compile(this._value)
	} // }}}
}