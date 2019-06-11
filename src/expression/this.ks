class ThisExpression extends Expression {
	private {
		_calling: Boolean			= false
		_class: ClassType
		_composite: Boolean			= false
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
			else if parent is ClassMethodDeclaration ||	parent is ClassVariableDeclaration {
				if !parent.isInstance() {
					SyntaxException.throwUnexpectedAlias(@name, this)
				}

				@class = parent.parent().type()
				break
			}
			else if parent is ClassConstructorDeclaration || parent is ClassDestructorDeclaration {
				@class = parent.parent().type()
				break
			}
			else if parent is ImplementClassMethodDeclaration {
				if !parent.isInstance() {
					SyntaxException.throwUnexpectedAlias(@name, this)
				}

				@class = parent.class()
				break
			}
		}
		while parent ?= parent.parent()

		if !?@class {
			SyntaxException.throwUnexpectedAlias(@name, this)
		}
	} // }}}
	prepare() { // {{{
		if @calling {
			if @type ?= @class.type().getInstanceMethod(@name, [argument.type() for argument in @parent.arguments()]) {
				@fragment = `this.\(@name)`
			}
			else if @type ?= @class.type().getInstanceVariable(@name) {
				@fragment = `this.\(@name)`
			}
			else if @type ?= @class.type().getInstanceVariable(`_\(@name)`) {
				@fragment = `this._\(@name)`
			}
			else {
				ReferenceException.throwNotDefinedField(@name, this)
			}
		}
		else {
			if variable ?= @class.type().getInstanceVariable(@name) {
				@fragment = `this.\(@name)`
				@type = variable.type()
			}
			else if variable ?= @class.type().getInstanceVariable(`_\(@name)`) {
				@fragment = `this._\(@name)`
				@type = variable.type()
			}
			else if @type ?= @class.type().getPropertyGetter(@name) {
				@fragment = `this.\(@name)()`
				@composite = true
			}
			else {
				ReferenceException.throwNotDefinedField(@name, this)
			}
		}
	} // }}}
	translate()
	isComposite() => @composite
	isUsingVariable(name) => false
	listAssignments(array) => array
	setAssignment(assignment)
	toFragments(fragments, mode) { // {{{
		fragments.code(@fragment)
	} // }}}
	type() => @type
}