class ThisExpression extends Expression {
	private lateinit {
		_assignment: AssignmentType	= AssignmentType::Neither
		_calling: Boolean			= false
		_class: NamedType
		_composite: Boolean			= false
		_declaration
		_fragment: String
		_immutable: Boolean			= false
		_instance: Boolean			= true
		_lateInit: Boolean			= false
		_name: String
		_namesake: Boolean			= false
		_sealed: Boolean			= false
		_type: Type?				= null
		_variableName: String?		= null
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
				@declaration = parent.parent()

				if parent is ClassMethodDeclaration && parent.parameters().length == 0{
					if parent.name() == @name {
						@namesake = true
					}
				}

				break
			}
			else if parent is ClassConstructorDeclaration || parent is ClassDestructorDeclaration {
				@class = parent.parent().type()
				@declaration = parent.parent()
				break
			}
			else if parent is ImplementClassMethodDeclaration {
				if !parent.isInstance() {
					SyntaxException.throwUnexpectedAlias(@name, this)
				}

				@class = parent.class()
				@declaration = parent.parent()
				break
			}
			else if parent is ImplementClassConstructorDeclaration {
				@class = parent.class()
				@declaration = parent.parent()
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

					@variableName = @name
					@immutable = @type.isImmutable()
					@lateInit = !@immutable && @type.isLateInit()
				}
				else if @type ?= @class.type().getInstanceVariable(`_\(@name)`) {
					if @type.isSealed() && @type.hasDefaultValue() && @assignment == AssignmentType::Neither {
						@fragment = `\(@class.getSealedName()).__ks_get_\(@name)(\(name))`
					}
					else {
						@fragment = `\(name)._\(@name)`
					}

					@variableName = `_\(@name)`
					@immutable = @type.isImmutable()
					@lateInit = !@immutable && @type.isLateInit()
				}
				else {
					ReferenceException.throwUndefinedInstanceField(@name, this)
				}
			}
			else {
				if variable ?= @class.type().getInstanceVariable(@name) {
					@fragment = `\(name).\(@name)`

					@type = @scope.getChunkType(@fragment) ?? variable.type()

					@variableName = @name
					@immutable = variable.isImmutable()
					@sealed = variable.isSealed()
					@lateInit = !@immutable && variable.isLateInit()
				}
				else if variable ?= @class.type().getInstanceVariable(`_\(@name)`) {
					if variable.isSealed() && variable.hasDefaultValue() && @assignment == AssignmentType::Neither {
						@fragment = `\(@class.getSealedName()).__ks_get_\(@name)(\(name))`
					}
					else {
						@fragment = `\(name)._\(@name)`
					}

					@type = @scope.getChunkType(@fragment) ?? variable.type()

					@variableName = `_\(@name)`
					@immutable = variable.isImmutable()
					@sealed = variable.isSealed()
					@lateInit = !@immutable && variable.isLateInit()
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

					@variableName = @name
					@immutable = variable.isImmutable()
					@sealed = variable.isSealed()
				}
				else if variable ?= @class.type().getClassVariable(`_\(@name)`) {
					@fragment = `\(name)._\(@name)`

					@type = @scope.getChunkType(@fragment) ?? variable.type()

					@variableName = `_\(@name)`
					@immutable = variable.isImmutable()
					@sealed = variable.isSealed()
				}
				else {
					ReferenceException.throwUndefinedClassField(@name, this)
				}
			}
		}
	} // }}}
	translate()
	checkIfAssignable() { // {{{
		if const variable = this.declaration() {
			if variable.isImmutable() {
				if variable.isLateInit() {
					if variable.isInitialized() {
						ReferenceException.throwImmutable(this)
					}
				}
				else {
					ReferenceException.throwImmutable(this)
				}
			}
		}
	} // }}}
	declaration() { // {{{
		if const node = @parent.getFunctionNode() {
			if node is ClassConstructorDeclaration {
				return node.parent().getInstanceVariable(@variableName)
			}
		}

		return null
	} // }}}
	fragment() => @fragment
	getClass() => @class
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
	getVariableDeclaration(class) { // {{{
		return class.getInstanceVariable(@variableName)
	} // }}}
	getVariableName() => @variableName
	getUnpreparedType() { // {{{
		this.prepare()

		return @type
	} // }}}
	initializeVariables(type: Type, node: Expression) { // {{{
		if @variableName != null {
			node.initializeVariable(VariableBrief(
				name: @variableName
				type
				instance: @instance
				immutable: @immutable
			))
		}
	} // }}}
	isAssignable() => !@calling && !@composite
	isComposite() => @composite
	isExpectingType() => true
	isInferable() => !@calling && !@composite
	isLateInit() => @lateInit
	isInitializable() => true
	isSealed() => @sealed
	isUsingVariable(name) => @instance && name == 'this'
	isUsingInstanceVariable(name) => @instance && @variableName == name
	listAssignments(array) { // {{{
		if @variableName != null {
			array.push(@variableName)
		}

		return array
	} // }}}
	name() => @name
	path() => @fragment
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		fragments.code(@fragment)
	} // }}}
	toQuote() => `@\(@name)`
	type() => @type
}