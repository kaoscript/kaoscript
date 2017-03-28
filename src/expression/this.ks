class ThisExpression extends Expression {
	private {
		_class
		_fragment
		_method		= false
		_type
	}
	analyse() {
		let parent = @parent
		
		do {
			if parent is ClassDeclaration {
				@class = @scope.getVariable(parent._name)
				break
			}
			else if parent is ImplementClassMethodDeclaration {
				@class = parent._variable
				break
			}
		}
		while parent ?= parent.parent()
		
		if !?parent {
			SyntaxException.throwOutOfClassAlias(@data.name.name, this)
		}
	}
	prepare() {
		let name = @data.name.name
		let variable
		
		if @method {
			if variable ?= @getInstanceMethod(name) {
				@fragment = `this.\(name)`
			}
			else {
				ReferenceException.throwNotDefinedMethod(name, this)
			}
		}
		else {
			if variable ?= @getInstanceVariable(name) {
				@fragment = `this.\(name)`
			}
			else if variable ?= @getInstanceVariable('_' + name) {
				@fragment = `this._\(name)`
			}
			else {
				let parent = @parent
				while parent? && parent is not ClassMethodDeclaration {
					parent = parent.parent()
				}
				
				if (!?parent || parent.name() != name || parent.length() != 0) && (variable ?= @getInstanceMethod(name)) {
					@fragment = `this.\(name)()`
				}
				else {
					ReferenceException.throwNotDefinedField(name, this)
				}
			}
		}
		
		@type = variable.type
	}
	translate()
	getInstanceMethod(name, variable = @class) { // {{{
		return variable.instanceMethods[name] if variable.instanceMethods[name]?
		
		if variable.extends? {
			return @getInstanceMethod(name, @scope.getVariable(variable.extends))
		}
		
		return null
	} // }}}
	getInstanceVariable(name, variable = @class) { // {{{
		return variable.instanceVariables[name] if variable.instanceVariables[name]?
		
		if variable.extends? {
			return @getInstanceVariable(name, @scope.getVariable(variable.extends))
		}
		
		return null
	} // }}}
	isMethod(@method) => this
	/* toFragments(fragments, mode) { // {{{
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
	} // }}} */
	toFragments(fragments, mode) { // {{{
		fragments.code(@fragment)
	} // }}}
	type() => @type
}