class PreciseThisCallee extends MethodCallee {
	private {
		@alien: Boolean
		@instance: Boolean
		@property: String
	}
	constructor(@data, @expression, @property, assessment, match: CallMatch, @node) { # {{{
		super(data, expression, true, assessment, match, node)

		@alien = match.function.isAlien()
		@instance = match.function.isInstance()
	} # }}}
	override buildHashCode() => `this:\(@property):\(@index):\(@alien):\(@instance):\(@positions.join(','))`
	toFragments(fragments, mode, node) { # {{{
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
	} # }}}
}
