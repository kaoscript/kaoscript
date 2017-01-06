class ThisExpression extends Expression {
	private {
		_class
		_variable
	}
	$create(data, parent, scope) { // {{{
		super(data, parent, scope)
		
		do {
			if parent is ClassDeclaration {
				this._class = this._scope.getVariable(parent._name)
				break
			}
			else if parent is ImplementClassMethodDeclaration {
				this._class = parent._variable
				break
			}
		}
		while parent ?= parent.parent()
		
		if !?parent {
			$throw(`The alias @\(data.name.name) must be inside a class, line \(data.start.line)`, this)
		}
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		let name = this._data.name.name
		
		if this._class.instanceVariables[name]? || this._class.instanceMethods[name]? {
			fragments.code('this.', name)
		}
		else if this._class.instanceVariables['_' + name]? {
			fragments.code('this._', name)
		}
		else {
			$throw(`Unknown member '\(name)' at line \(this._data.start.line)`, this)
		}
	} // }}}
}