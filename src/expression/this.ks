class ThisExpression extends Expression {
	private {
		_calling: Boolean			= false
		_class: ClassType
		_entangled: Boolean			= false
		_fragment
		_method: ClassMethodType
		_name: String
		_type
	}
	analyse() { // {{{
		@name = @data.name.name
		
		let parent = @parent
		
		do {
			if parent is CallExpression && parent.data().callee == @data {
				@calling = true
			}
			else if parent is ClassDeclaration {
				@class = parent.type()
				break
			}
			else if parent is ImplementClassMethodDeclaration {
				@class = parent.class()
				break
			}
		}
		while parent ?= parent.parent()
		
		if !?parent {
			SyntaxException.throwOutOfClassAlias(@name, this)
		}
	} // }}}
	prepare() { // {{{
		if @calling {
			if type ?= @class.getInstanceMethod(@name, [argument.type() for argument in @parent.arguments()]) {
				@fragment = `this.\(@name)`
			}
			else if @type ?= @class.getInstanceVariable(@name) {
				@fragment = `this.\(@name)`
			}
			else if @type ?= @class.getInstanceVariable(`_\(@name)`) {
				@fragment = `this._\(@name)`
			}
			else {
				ReferenceException.throwNotDefinedField(@name, this)
			}
		}
		else {
			if @type ?= @class.getInstanceVariable(@name) {
				@fragment = `this.\(@name)`
			}
			else if @type ?= @class.getInstanceVariable(`_\(@name)`) {
				@fragment = `this._\(@name)`
			}
			else if @type ?= @class.getPropertyGetter(@name) {
				@fragment = `this.\(@name)()`
				@entangled = true
			}
			else {
				ReferenceException.throwNotDefinedField(@name, this)
			}
		}
	} // }}}
	translate()
	isEntangled() => @entangled
	toFragments(fragments, mode) { // {{{
		fragments.code(@fragment)
	} // }}}
	type() => @type
}