class ThisExpression extends Expression {
	private late {
		@assignable: Boolean		= false
		@assignment: AssignmentType	= AssignmentType.Neither
		@calling: Boolean			= false
		@class: NamedType
		@composite: Boolean			= false
		@declaration
		@fragment: String
		@immutable: Boolean			= false
		@instance: Boolean			= true
		@lateInit: Boolean			= false
		@name: String
		@namesake: Boolean			= false
		@nonNullable: Boolean		= false
		@prepared: Boolean			= false
		@sealed: Boolean			= false
		@type: Type					= AnyType.NullableUnexplicit
		@variableName: String?		= null
	}
	analyse() { # {{{
		@name = @data.name.name

		var mut parent = @parent

		do {
			if parent is CallExpression && parent.data().callee == @data {
				@calling = true
			}
			else if parent is ClassMethodDeclaration | ClassVariableDeclaration | ClassProxyDeclaration | ClassProxyGroupDeclaration {
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
			else if parent is ImplementDividedClassMethodDeclaration {
				if !parent.isInstance() {
					SyntaxException.throwUnexpectedAlias(@name, this)
				}

				@class = parent.class()
				@declaration = parent.parent()
				break
			}
			else if parent is ImplementDividedClassConstructorDeclaration {
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
	override prepare(target, targetMode) { # {{{
		return if @prepared

		@prepared = true

		var type = @class.type()

		if @instance {
			var name = @scope.getVariable('this').getSecureName()

			if @calling {
				var mut variable = null

				if variable ?= type.getInstanceVariable(@name) {
					@variableName = @name
					@fragment = `\(name).\(@variableName)`
				}
				else if variable ?= type.getInstanceVariable(`_\(@name)`) {
					@variableName = `_\(@name)`

					if variable.isSealed() && variable.hasDefaultValue() && @assignment == AssignmentType.Neither {
						@fragment = `\(@class.getSealedName()).__ks_get_\(@name)(\(name))`
					}
					else {
						@fragment = `\(name).\(@variableName)`
					}
				}

				if ?variable {
					@type = @scope.getChunkType(@fragment) ?? variable.type()

					if @type.canBeFunction() {
						if type.hasInstanceMethod(@name) {
							SyntaxException.throwAmbiguousClassCall(@name, this)
						}

						@immutable = variable.isImmutable()
						@sealed = variable.isSealed()
						@lateInit = !@immutable && variable.isLateInit()
					}
					else {
						@type = AnyType.NullableUnexplicit
						@variableName = null
						@fragment = ''
					}
				}

				if !?@variableName {
					if type.hasInstantiableMethod(@name) {
						var assessment = type.getInstantiableAssessment(@name, null, this)

						match Router.matchArguments(assessment, null, @parent.getArgumentsWith(assessment), this) {
							is LenientCallMatchResult | PreciseCallMatchResult with var result {
								var late functions: FunctionType[]

								if result is PreciseCallMatchResult {
									functions = [match.function for var match in result.matches]
								}
								else {
									functions = result.possibilities
								}

								@type = Type.union(@scope, ...functions)

								if functions.some((fn, ...) => fn.isSealed()) {
									@sealed = true
									@fragment = `\(@class.getSealedName()).__ks_get_\(@name)`
								}
								else {
									@fragment = `\(name).\(@name)`
								}
							}
							else {
								if type.isExhaustive(this) && @parent is not CurryExpression {
									ReferenceException.throwNoMatchingStaticMethod(@name, @class.name(), [argument.type() for var argument in @parent.arguments()], this)
								}
								else {
									@fragment = `\(name).\(@name)`
									@type = @scope.getChunkType(@fragment) ?? Type.union(@scope, ...type.listInstantiableMethods(@name)!?)
								}
							}
						}
					}
					else if type.isExhaustive(this) {
						ReferenceException.throwUndefinedInstanceField(@name, this)
					}
					else {
						@fragment = `\(name).\(@name)`
					}
				}
			}
			else {
				var mut variable = null

				if variable ?= type.getInstanceVariable(@name) {
					@variableName = @name
					@fragment = `\(name).\(@variableName)`
				}
				else if variable ?= type.getInstanceVariable(`_\(@name)`) {
					@variableName = `_\(@name)`

					if variable.isSealed() && variable.hasDefaultValue() && @assignment == AssignmentType.Neither {
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
					@type = Type.union(@scope, ...type.listInstantiableMethods(@name)!?)
					@fragment = `\($runtime.helper(this)).bindMethod(\(name), "\(@name)")`
				}
				else if type.isExhaustive(this) {
					if @assignable {
						ReferenceException.throwUndefinedInstanceField(@name, this)
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

				if variable ?= type.getStaticVariable(@name) {
					@variableName = @name
				}
				else if variable ?= type.getStaticVariable(`_\(@name)`) {
					@variableName = `_\(@name)`
				}
				else {
					ReferenceException.throwUndefinedStaticField(@name, this)
				}

				if ?variable {
					@fragment = `\(name).\(@variableName)`

					@type = @scope.getChunkType(@fragment) ?? variable.type()

					@immutable = variable.isImmutable()
					@sealed = variable.isSealed()
				}
				else if type.isExhaustive(this) {
					ReferenceException.throwUndefinedStaticField(@name, this)
				}
				else {
					@fragment = `\(name).\(@variableName)`
				}
			}
		}

		if @assignable {
			if var variable ?= this.declaration() {
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
	caller() => 'this'
	declaration() { # {{{
		if var node ?= @parent.getFunctionNode() {
			if node is ClassConstructorDeclaration {
				return node.parent().getInstanceVariable(@variableName)
			}
		}

		return null
	} # }}}
	flagAssignable() { # {{{
		@assignable = true
	} # }}}
	flagNonNullable() { # {{{
		@nonNullable = true
		@type = @type.setNullable(false)
	} # }}}
	fragment() => @fragment
	getClass() => @class
	getDeclaredType() { # {{{
		if ?@variableName {
			if @instance {
				if var variable ?= @class.type().getInstanceVariable(@variableName) {
					return @nonNullable ? variable.type().setNullable(false) : variable.type()
				}
			}
			else {
				if var variable ?= @class.type().getStaticVariable(@variableName) {
					return @nonNullable ? variable.type().setNullable(false) : variable.type()
				}
			}
		}

		return @type
	} # }}}
	getVariableName() => @variableName
	getUnpreparedType() { # {{{
		@prepare(AnyType.NullableUnexplicit)

		return @type
	} # }}}
	initializeVariables(type: Type, node: Expression) { # {{{
		if @variableName != null {
			node.initializeVariable(VariableBrief.new(
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
	isInitializable() => true
	isLateInit() => @lateInit
	isRedeclared() => false
	isSealed() => @sealed
	isUsingVariable(name) => @instance && name == 'this'
	isUsingInstanceVariable(name) => @instance && @variableName == name
	listAssignments(array: Array, immutable: Boolean? = null) { # {{{
		if @variableName != null {
			array.push({ name: @variableName })
		}

		return array
	} # }}}
	override makeCallee(generics, node) { # {{{
		if !@type.isFunction() {
			node.addCallee(DefaultCallee.new(node.data(), null, null, node))
		}
		else if @type.isReference() {
			if @isSealed() {
				var object = IdentifierLiteral.new($ast.identifier('this'), node, @scope)
				var reference = @scope.reference(@class)

				node.addCallee(SealedMethodCallee.new(node.data(), null, reference, @name, true, node))

			}
			else {
				node.addCallee(DefaultCallee.new(node.data(), this, node))
			}
		}
		else {
			var assessment = @type.assessment(@name, node)

			match node.matchArguments(assessment) {
				is LenientCallMatchResult with var { possibilities } {
					node.addCallee(LenientThisCallee.new(node.data(), this, @name, possibilities, node))
				}
				is PreciseCallMatchResult with var { matches } {
					if matches.length == 1 {
						var match = matches[0]
						var reference = @scope.reference(@class)

						node.addCallee(PreciseThisCallee.new(node.data(), this, reference, @name, assessment, match, node))
					}
					else {
						var functions = [match.function for var match in matches]

						node.addCallee(LenientThisCallee.new(node.data(), this, @name, functions, node))
					}
				}
				else {
					if @type.isExhaustive(node) {
						ReferenceException.throwNoMatchingStaticMethod(@name, @class.name(), [argument.type() for var argument in node.arguments()], node)
					}
					else {
						node.addCallee(DefaultCallee.new(node.data(), this, node))
					}
				}
			}
		}
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
