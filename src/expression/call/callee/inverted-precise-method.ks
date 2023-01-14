class InvertedPreciseMethodCallee extends MethodCallee {
	private {
		@name: NamedType
		@property: String
	}
	constructor(@data, @name, @property, assessment, match: CallMatch, node) { # {{{
		super(data, new MemberExpression(data.callee, node, node.scope(), node._object), false, assessment, match, node)
	} # }}}
	override buildHashCode() => null
	toFragments(fragments, mode, node) { # {{{
		match @scope {
			ScopeKind::Argument {
				throw new NotImplementedException(node)
			}
			ScopeKind::Null {
				throw new NotImplementedException(node)
			}
			ScopeKind::This {
				fragments.code(`\(@name.name())`)

				if @function.isInstance() {
					fragments.code(`.__ks_func_\(@property)_\(@function.index())(`)
				}
				else {
					fragments.code(`.__ks_sttc_\(@property)_\(@function.index())(`)
				}

				fragments.wrap(@expression._object, mode)

				Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
			}
		}
	} # }}}
}
