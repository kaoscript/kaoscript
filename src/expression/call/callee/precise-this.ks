class PreciseThisCallee extends MethodCallee {
	private {
		@alien: Boolean
		@instance: Boolean
		@objectType: ReferenceType
		@property: String
		@sealed: Boolean					= false
	}
	constructor(@data, @expression, @objectType, @property, assessment, match: CallMatch, @node) { # {{{
		super(data, expression, true, assessment, match, node)

		@alien = match.function.isAlien()
		@instance = match.function.isInstance()
		@sealed = match.function.isSealed()
	} # }}}
	override buildHashCode() => `this:\(@property):\(@index):\(@alien):\(@instance):\(@positions.join(','))`
	toFragments(fragments, mode, node) { # {{{
		if @sealed {
			var name = @objectType.getSealedPath()

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
							fragments.code(`\(name).__ks_func_\(@property)_\(@function.index()).call(this`)
						}
						else {
							fragments.code(`\(name).__ks_sttc_\(@property)_\(@function.index()).apply(this`)
						}

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
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
						if @alien {
							throw new NotImplementedException(node)
						}
						else if @instance {
							fragments.code(`\(name).__ks_func_\(@property)_\(@function.index()).call(this`)
						}
						else {
							fragments.code(`\(name).__ks_sttc_\(@property)_\(@function.index())(this`)
						}

						Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
				}
			}
		}
		else {
			var name = @node.scope().getVariable('this').getSecureName()

			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @alien {
						fragments.code(`\(name).\(@property)(`)
					}
					else if @instance {
						fragments.code(`\(name).__ks_func_\(@property)_\(@index)(`)
					}
					else {
						fragments.code(`\(name).__ks_sttc_\(@property)_\(@index)(`)
					}

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
				}
			}
		}

	} # }}}
}
