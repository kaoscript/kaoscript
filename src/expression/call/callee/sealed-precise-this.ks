class SealedPreciseThisCallee extends MethodCallee {
	private {
		@property: String
		@variable: NamedType<ClassType>
	}
	constructor(@data, @expression, @property, assessment, match: CallMatch, @variable, @node) { # {{{
		super(data, expression, true, assessment, match, node)
	} # }}}
	override buildHashCode() => null
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @function.isInstance() {
						fragments.code(`\(@variable.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(this, `)

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
					else {
						fragments.code(`\(@variable.getSealedPath()).__ks_sttc_\(@property)_\(@function.index()).apply(this, `)

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
				}
			}
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @function.isAlien() {
						throw new NotImplementedException(node)
					}
					else {
						if @function.isInstance() {
							fragments.code(`\(@variable.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(this, `)

							Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
						}
						else {
							fragments.code(`\(@variable.getSealedPath()).__ks_sttc_\(@property)_\(@function.index())(this, `)

							Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
						}
					}
				}
			}
		}
	} # }}}
}
