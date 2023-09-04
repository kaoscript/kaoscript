class LenientThisCallee extends Callee {
	private {
		@expression
		@flatten: Boolean
		@instance: Boolean
		@methods: Array<FunctionType>
		@node: CallExpression
		@property: String
		@scope: ScopeKind
		@sealed: Boolean					= false
		@type: Type
	}
	constructor(@data, @expression, @property, @methods, @node) { # {{{
		super(data)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind
		@instance = methods[0].isInstance()

		var types = []

		for var method in methods {
			@validate(method, node)

			types.push(method.getReturnType())

			@sealed ||= method.isSealed()
		}

		@type = Type.union(@node.scope(), ...types)
	} # }}}
	override hashCode() { # {{{
		return `this`
	} # }}}
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		for var method in @methods {
			if method.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			if @sealed {
				var path = @expression.getClass().getSealedPath()

				if @instance {
					fragments.code(`\(path)._im_\(@property)`)
				}
				else {
					fragments.code(`\(path)._sm_\(@property)`)
				}

				fragments.code('.apply(null')

				CallExpression.toFlattenArgumentsFragments(fragments.code($comma), node.arguments(), 'this')
			}
			else {
				if @scope == ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				else {
					var name = @node.scope().getVariable('this').getSecureName()

					fragments.code(`\(name).\(@property).apply(\(name)`)
				}

				CallExpression.toFlattenArgumentsFragments(fragments.code($comma), node.arguments())
			}
		}
		else {
			if @sealed {
				var path = @expression.getClass().getSealedPath()

				if @instance {
					fragments.code(`\(path)._im_\(@property)`)
				}
				else {
					fragments.code(`\(path)._sm_\(@property)`)
				}
			}
			else {
				var name = @node.scope().getVariable('this').getSecureName()

				fragments.code(`\(name).\(@property)`)
			}

			if @scope == ScopeKind.Argument {
				throw NotImplementedException.new(node)
			}
			else {
				fragments.code('(')

				if @sealed && @instance {
					fragments.code('this')

					for var argument, index in node.arguments() {
						fragments.code($comma)

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
				else {
					for var argument, index in node.arguments() {
						fragments.code($comma) if index != 0

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
