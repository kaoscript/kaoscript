class ImplementUnifiedClassFieldDeclaration extends ClassVariableDeclaration {
	private {
		@implement: ImplementDeclaration
	}
	constructor(data, parent, @implement) { # {{{
		super(data, parent)
	} # }}}
	isImplementing() => true
}

class ImplementUnifiedClassConstructorDeclaration extends ClassConstructorDeclaration {
	private {
		@implement: ImplementDeclaration
	}
	constructor(data, parent, @implement) { # {{{
		super(data, parent)
	} # }}}
	override prepare(target, targetMode) {
		@scope.line(@implement.line())

		super(target, targetMode)
	}
}

class ImplementUnifiedClassDestructorDeclaration extends ClassDestructorDeclaration {
}

class ImplementUnifiedClassMethodDeclaration extends ClassMethodDeclaration {
	private {
		@implement: ImplementDeclaration
		@overwrite: Boolean					= false
	}
	constructor(data, parent, @implement) { # {{{
		super(data, parent)

		for var modifier in data.modifiers {
			if modifier.kind == ModifierKind.Overwrite {
				@overwrite = true
				break
			}
		}
	} # }}}
	protected {
		override resolveOver() { # {{{
			var class = @parent.class()

			if @instance {
				if @override {
					if var { method % overridden, type, exact } ?= @getOveriddenMethod(Method.instance(class)!!, @type.isUnknownReturnType()!!) {
						for var method, index in @parent._instanceMethods[@name] {
							if method.type() == overridden {
								@parent._instanceMethods[@name].splice(index, 1)

								break
							}
						}

						for var method, index in class._instanceMethods[@name] {
							if method == overridden {
								class._instanceMethods[@name].splice(index, 1)

								break
							}
						}

						return { overridden, overloaded: [] }
					}
				}
				else if @overwrite {
					NotImplementedException.throw(this)
				}
				else {
					if class.hasMatchingInstanceMethod(@name, @type, MatchingMode.ExactParameter + MatchingMode.IgnoreName + MatchingMode.Superclass) {
						SyntaxException.throwDuplicateMethod(@name, this)
					}
				}
			}
			else {
				if @override {
					NotImplementedException.throw(this)
				}
				else if @overwrite {
					NotImplementedException.throw(this)
				}
				else {
					if class.hasMatchingStaticMethod(@name, @type, MatchingMode.ExactParameter) {
						SyntaxException.throwDuplicateMethod(@name, this)
					}
				}
			}

			return { overridden: null, overloaded: [] }
		} # }}}
	}
}
