class ThisExpression extends Expression {
	private {
		_assignment: AssignmentType	= AssignmentType::Neither
		_calling: Boolean			= false
		_class: NamedType
		_composite: Boolean			= false
		_fragment: String
		_instance: Boolean			= true
		_name: String
		_namesake: Boolean			= false
		_type: Type?				= null
	}
	analyse() { // {{{
		@name = @data.name.name

		let parent = @parent

		do {
			if parent is CallExpression && parent.data().callee == @data {
				@calling = true
			}
			else if parent is ClassMethodDeclaration ||	parent is ClassVariableDeclaration {
				@instance = parent.isInstance()

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
			else if parent is ImplementClassConstructorDeclaration {
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
		return unless @type == null

		if @instance {
			const name = @scope.getVariable('this').getSecureName()

			if @calling {
				if @type ?= @class.type().getInstantiableMethod(@name, @parent.arguments()) {
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
					ReferenceException.throwUndefinedInstanceField(@name, this)
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
					ReferenceException.throwUndefinedInstanceField(@name, this)
				}
			}
		}
		else {
			const name = @class.name()

			if @calling {
				NotImplementedException.throw(this)
			}
			else {
				if variable ?= @class.type().getClassVariable(@name) {
					@fragment = `\(name).\(@name)`

					@type = @scope.getChunkType(@fragment) ?? variable.type()
				}
				else if variable ?= @class.type().getClassVariable(`_\(@name)`) {
					@fragment = `\(name)._\(@name)`

					@type = @scope.getChunkType(@fragment) ?? variable.type()
				}
				else {
					ReferenceException.throwUndefinedClassField(@name, this)
				}
			}
		}
	} // }}}
	translate()
	getDeclaredType() { // {{{
		if !@calling {
			if @instance {
				if variable ?= @class.type().getInstanceVariable(@name) {
					return variable.type()
				}
				else if variable ?= @class.type().getInstanceVariable(`_\(@name)`) {
					return variable.type()
				}
			}
			else {
				NotImplementedException.throw(this)
			}
		}

		return @type
	} // }}}
	getUnpreparedType() { // {{{
		this.prepare()

		return @type
	} // }}}
	isAssignable() => !@calling && !@composite
	isComposite() => @composite
	isExpectingType() => true
	isInferable() => !@calling && !@composite
	isUsingVariable(name) => @instance && name == 'this'
	listAssignments(array) => array
	path() => @fragment
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		fragments.code(@fragment)
	} // }}}
	toQuote() => `@\(@name)`
	type() => @type
}