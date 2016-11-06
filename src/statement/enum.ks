class EnumDeclaration extends Statement {
	private {
		_members = []
		_new
		_variable
	}
	EnumDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._variable = $variable.define(this._scope, this._data.name, VariableKind::Enum, this._data.type)
		
		this._new = this._variable.new
		
		for member in this._data.members {
			this._members.push(new EnumMember(member, this))
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._new {
			let line = fragments.newLine().code($variable.scope(this), this._variable.name.name, $equals)
			let object = line.newObject()
			
			for member in this._members {
				member.toFragments(object.newLine())
			}
			
			object.done()
			line.done()
		}
		else {
			let line
			
			for member in this._members {
				member.toFragments(line = fragments.newLine())
				
				line.done()
			}
		}
	} // }}}
}

class EnumMember extends AbstractNode {
	EnumMember(data, parent) { // {{{
		super(data, parent)
	} // }}}
	toFragments(fragments) { // {{{
		let variable = this._parent._variable
		
		if this._parent._new {
			fragments.code(this._data.name.name, ': ', $variable.value(variable, this._data))
		}
		else {
			fragments.code(variable.name.name || variable.name, '.', this._data.name.name, ' = ', $variable.value(variable, this._data))
		}
	} // }}}
}