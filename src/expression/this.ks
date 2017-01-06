class ThisExpression extends Expression {
	private {
		_class
		_method		= false
		_variable
	}
	$create(data, parent, scope) { // {{{
		super(data, parent, scope)
		
		do {
			if parent is ClassDeclaration {
				@class = this._scope.getVariable(parent._name)
				break
			}
			else if parent is ImplementClassMethodDeclaration {
				@class = parent._variable
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
	isInstanceMethod(name, variable) { // {{{
		return true if variable.instanceMethods[name]?
		
		if variable.extends? {
			return @isInstanceMethod(name, @scope.getVariable(variable.extends))
		}
		
		return false
	} // }}}
	isInstanceVariable(name, variable) { // {{{
		return true if variable.instanceVariables[name]?
		
		if variable.extends? {
			return @isInstanceVariable(name, @scope.getVariable(variable.extends))
		}
		
		return false
	} // }}}
	isMethod(@method) => this
	toFragments(fragments, mode) { // {{{
		let name = @data.name.name
		
		if @method {
			if @isInstanceMethod(name, @class) {
				fragments.code('this.', name)
			}
			else if @isInstanceMethod('_' + name, @class) {
				fragments.code('this._', name)
			}
			else {
				$throw(`Unknown method '\(name)' at line \(@data.start.line)`, this)
			}
		}
		else {
			if @isInstanceVariable(name, @class) {
				fragments.code('this.', name)
			}
			else if @isInstanceVariable('_' + name, @class) {
				fragments.code('this._', name)
			}
			else {
				$throw(`Unknown field '\(name)' at line \(@data.start.line)`, this)
			}
		}
	} // }}}
}