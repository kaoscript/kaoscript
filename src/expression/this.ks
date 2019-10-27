class ThisExpression extends Expression {
	private {
		_assignment: AssignmentType	= AssignmentType::Neither
		_calling: Boolean			= false
		_class: ClassType
		_composite: Boolean			= false
		_fragment: String
		_name: String
		_namesake: Boolean			= false
		_type: Type
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

				if parent is ClassMethodDeclaration && parent.parameters().length == 0{
					if parent.name() == @name {
						@namesake = true
					}
				}

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
		const name = @scope.getVariable('this').getSecureName()

		if @calling {
			if @type ?= @class.type().getInstanceMethod(@name, @parent.arguments()) {
				@fragment = `\(name).\(@name)`
			}
			else if @type ?= @class.type().getInstanceVariable(@name) {
				@fragment = `\(name).\(@name)`
			}
			else if @type ?= @class.type().getInstanceVariable(`_\(@name)`) {
				if @type.isInitiatable() && @assignment == AssignmentType::Neither {
					@fragment = `\(@class.getSealedName()).__ks_get_\(@name)(\(name))`
				}
				else {
					@fragment = `\(name)._\(@name)`
				}
			}
			else {
				ReferenceException.throwNotDefinedField(@name, this)
			}
		}
		else {
			if variable ?= @class.type().getInstanceVariable(@name) {
				@fragment = `\(name).\(@name)`

				@type = @scope.getChunkType(@fragment) ?? variable.type()
			}
			else if variable ?= @class.type().getInstanceVariable(`_\(@name)`) {
				if variable.isInitiatable() && @assignment == AssignmentType::Neither {
					@fragment = `\(@class.getSealedName()).__ks_get_\(@name)(\(name))`
				}
				else {
					@fragment = `\(name)._\(@name)`
				}

				@type = @scope.getChunkType(@fragment) ?? variable.type()
			}
			else if @type ?= @class.type().getPropertyGetter(@name) {
				if @namesake {
					ReferenceException.throwLoopingAlias(@name, this)
				}

				@fragment = `\(name).\(@name)()`
				@composite = true
			}
			else {
				ReferenceException.throwNotDefinedField(@name, this)
			}
		}
	} // }}}
	translate()
	isAssignable() => !@calling && !@composite
	isComposite() => @composite
	isInferable() => !@calling && !@composite
	isUsingVariable(name) => name == 'this'
	listAssignments(array) => array
	path() => @fragment
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		fragments.code(@fragment)
	} // }}}
	toQuote() => `@\(@name)`
	type() => @type
}