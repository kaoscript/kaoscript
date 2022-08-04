class ThisExpression extends Expression {
	private late {
		_assignable: Boolean		= false
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
	analyse() { # {{{
		@name = @data.name.name

		var mut parent = @parent

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
	} # }}}
	prepare() { # {{{
		return unless @type == null

		var type = @class.type()

		if @instance {
			var name = @scope.getVariable('this').getSecureName()

			if @calling {
				var mut variable

				if variable ?= type.getInstanceVariable(@name) {
					@variableName = @name
					@fragment = `\(name).\(@variableName)`
				}
				else if variable ?= type.getInstanceVariable(`_\(@name)`) {
					@variableName = `_\(@name)`

					if variable.isSealed() && variable.hasDefaultValue() && @assignment == AssignmentType::Neither {
						@fragment = `\(@class.getSealedName()).__ks_get_\(@name)(\(name))`
					}
					else {
						@fragment = `\(name).\(@variableName)`
					}
				}

				if ?variable {
					@type = @scope.getChunkType(@fragment) ?? variable.type()

					if @type.canBeFunction() {
						@immutable = variable.isImmutable()
						@sealed = variable.isSealed()
						@lateInit = !@immutable && variable.isLateInit()
					}
					else {
						@type = null
						@variableName = null
						@fragment = ''
					}
				}

				if !?@variableName {
					if type.hasInstantiableMethod(@name) {
						var assessment = type.getInstantiableAssessment(@name, this)

						if var result = Router.matchArguments(assessment, @parent.arguments(), this) {
							@fragment = `\(name).\(@name)`

							if result is PreciseCallMatchResult {
								@type = Type.union(@scope, ...[match.function for var match in result.matches])
							}
							else {
								@type = Type.union(@scope, ...result.possibilities)
							}
						}
						else if type.isExhaustive(this) {
							ReferenceException.throwNoMatchingClassMethod(@name, @class.name(), [argument.type() for var argument in @parent.arguments()], this)
						}
						else {
							@fragment = `\(name).\(@name)`
							@type = @scope.getChunkType(@fragment) ?? Type.union(@scope, ...type.listInstantiableMethods(@name))
						}
					}
					else {
						ReferenceException.throwUndefinedInstanceField(@name, this)
					}
				}
			}
			else {
				var mut variable

				if variable ?= type.getInstanceVariable(@name) {
					@variableName = @name
					@fragment = `\(name).\(@variableName)`
				}
				else if variable ?= type.getInstanceVariable(`_\(@name)`) {
					@variableName = `_\(@name)`

					if variable.isSealed() && variable.hasDefaultValue() && @assignment == AssignmentType::Neither {
						@fragment = `\(@class.getSealedName()).__ks_get_\(@name)(\(name))`
					}
					else {
						@fragment = `\(name).\(@variableName)`
					}
				}

				if ?variable {
					@type = @scope.getChunkType(@fragment) ?? variable.type()

					@immutable = variable.isImmutable()
					@sealed = variable.isSealed()
					@lateInit = !@immutable && variable.isLateInit()
				}
				else if type.hasInstantiableMethod(@name) {
					@type = Type.union(@scope, ...type.listInstantiableMethods(@name))
					@fragment = `\($runtime.helper(this)).bindMethod(\(name), "\(@name)")`
				}
				else if type.isExhaustive(this) {
					if @assignable {
						ReferenceException.throwInvalidAssignment(this)
					}
					else {
						ReferenceException.throwNotDefinedProperty(@name, this)
					}
				}
				else {
					ReferenceException.throwUndefinedInstanceField(@name, this)
				}
			}
		}
		else {
			var name = @class.name()

			if @calling {
				NotImplementedException.throw(this)
			}
			else {
				var late variable

				if variable ?= type.getClassVariable(@name) {
					@variableName = @name
				}
				else if variable ?= type.getClassVariable(`_\(@name)`) {
					@variableName = `_\(@name)`
				}
				else {
					ReferenceException.throwUndefinedClassField(@name, this)
				}

				if ?variable {
					@fragment = `\(name).\(@variableName)`

					@type = @scope.getChunkType(@fragment) ?? variable.type()

					@immutable = variable.isImmutable()
					@sealed = variable.isSealed()
				}
				else {
					ReferenceException.throwUndefinedClassField(@name, this)
				}
			}
		}

		if @assignable {
			if var variable = this.declaration() {
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
		}
	} # }}}
	translate()
	declaration() { # {{{
		if var node = @parent.getFunctionNode() {
			if node is ClassConstructorDeclaration {
				return node.parent().getInstanceVariable(@variableName)
			}
		}

		return null
	} # }}}
	flagAssignable() { # {{{
		@assignable = true
	} # }}}
	fragment() => @fragment
	getClass() => @class
	getDeclaredType() { # {{{
		if @variableName? {
			if @instance {
				if var variable = @class.type().getInstanceVariable(@variableName) {
					return variable.type()
				}
			}
			else {
				if var variable = @class.type().getClassVariable(@variableName) {
					return variable.type()
				}
			}
		}

		return @type
	} # }}}
	getVariableName() => @variableName
	getUnpreparedType() { # {{{
		this.prepare()

		return @type
	} # }}}
	initializeVariables(type: Type, node: Expression) { # {{{
		if @variableName != null {
			node.initializeVariable(VariableBrief(
				name: @variableName
				type
				instance: @instance
				immutable: @immutable
			))
		}
	} # }}}
	isAssignable() => !@calling && !@composite
	isComposite() => @composite
	isExpectingType() => true
	isInferable() => !@calling && !@composite
	isLateInit() => @lateInit
	isInitializable() => true
	isSealed() => @sealed
	isUsingVariable(name) => @instance && name == 'this'
	isUsingInstanceVariable(name) => @instance && @variableName == name
	listAssignments(array: Array<String>) { # {{{
		if @variableName != null {
			array.push(@variableName)
		}

		return array
	} # }}}
	name() => @name
	path() => @fragment
	setAssignment(@assignment)
	toFragments(fragments, mode) { # {{{
		fragments.code(@fragment)
	} # }}}
	toQuote() => `@\(@name)`
	type() => @type
}
