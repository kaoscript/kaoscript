class LenientThisCallee extends Callee {
	private {
		@expression
		@flatten: Boolean
		@methods: Array<FunctionType>
		@node: CallExpression
		@property: String
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, @expression, @property, @methods, @node) { # {{{
		super(data)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		var types = []
		for var method in methods {
			@validate(method, node)

			types.push(method.getReturnType())
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
		var name = @node.scope().getVariable('this').getSecureName()

		if @flatten {
			match @scope {
				ScopeKind::Argument {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null {
					throw new NotImplementedException(node)
				}
				ScopeKind::This {
					fragments.code(`\(name).\(@property).apply(\(name)`)
				}
			}

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), node.arguments())
		}
		else {
			match @scope {
				ScopeKind::Argument {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null {
					throw new NotImplementedException(node)
				}
				ScopeKind::This {
					fragments.code(`\(name).\(@property)(`)

					for var argument, index in node.arguments() {
						fragments.code($comma) if index != 0

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
