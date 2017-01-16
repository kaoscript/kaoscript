class ObjectExpression extends Expression {
	private {
		_properties = []
		_templates = []
	}
	analyse() { // {{{
		for property in this._data.properties {
			if property.name.kind == NodeKind::Identifier || property.name.kind == NodeKind::Literal {
				this._properties.push(property = new ObjectMember(property, this))
			}
			else {
				this._templates.push(property = new ObjectTemplateMember(property, this))
			}
			
			property.analyse()
		}
	} // }}}
	fuse() { // {{{
		for property in this._properties {
			property.fuse()
		}
		
		for property in this._templates {
			property.fuse()
		}
	} // }}}
	reference() => this._parent.reference()
	toFragments(fragments, mode) { // {{{
		if this._properties.length {
			let object = fragments.newObject()
			
			for property in this._properties {
				object.newLine().compile(property)
			}
			
			object.done()
		}
		else {
			fragments.code('{}')
		}
	} // }}}
}

class ObjectMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
		if this._data.name.kind == NodeKind::Identifier	{
			this._name = new IdentifierLiteral(this._data.name, this, this.scope(), false)
			
			this.reference('.' + this._data.name.name)
		}
		else {
			this._name = new StringLiteral(this._data.name, this)
			
			this.reference('[' + $quote(this._data.name.value) + ']')
		}
		
		this._name.analyse()
		
		this._value = $compile.expression(this._data.value, this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._name)
		
		if this._data.value.kind != NodeKind::FunctionExpression {
			fragments.code(': ')
		}
		
		fragments.compile(this._value)
	} // }}}
}

class ObjectTemplateMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
		this._name = new TemplateExpression(this._data.name, this)
		
		this._name.analyse()
		
		this._value = $compile.expression(this._data.value, this)
		
		this.statement().afterward(this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		fragments
			.newLine()
			.code(this.parent().reference(), '[')
			.compile(this._name)
			.code('] = ')
			.compile(this._value)
			.done()
	} // }}}
}