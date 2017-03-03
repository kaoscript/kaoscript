class ThisExpression extends Expression {
	private {
		_class
		_method		= false
		_variable
	}
	constructor(data, parent, scope) { // {{{
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
			SyntaxException.throwOutOfClassAlias(data.name.name, this)
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
			else {
				ReferenceException.throwNotDefinedMethod(name, this)
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
				let parent = @parent
				while parent? && parent is not ClassMethodDeclaration {
					parent = parent.parent()
				}
				
				if (!?parent || parent.name() != name || parent.length() != 0) && @isInstanceMethod(name, @class) {
					fragments.code('this.', name, '()')
				}
				else {
					ReferenceException.throwNotDefinedField(name, this)
				}
			}
		}
	} // }}}
}