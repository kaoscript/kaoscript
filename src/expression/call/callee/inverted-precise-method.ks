class InvertedPreciseMethodCallee extends MethodCallee {
	private {
		@auxiliary: Boolean
		@name: NamedType
		@property: String
	}
	constructor(@data, @name, @property, @auxiliary, assessment, match: CallMatch, node) { # {{{
		super(data, MemberExpression.new(data.callee, node, node.scope(), node._object), false, assessment, match, node)
	} # }}}
	override buildHashCode() => null
	toFragments(fragments, mode, node) { # {{{
		match @scope {
			ScopeKind.Argument {
				throw NotImplementedException.new(node)
			}
			ScopeKind.This {
				var name = if @auxiliary set @name.getAuxiliaryName() else @name.name()

				fragments.code(`\(name)`)

				if @function.isInstance() {
					fragments.code(`.__ks_func_\(@property)_\(@function.index())(`)
				}
				else {
					fragments.code(`.__ks_sttc_\(@property)_\(@function.index())(`)
				}

				fragments.wrap(@expression._object, mode)

				Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, true, fragments, mode)
			}
		}
	} # }}}
}
