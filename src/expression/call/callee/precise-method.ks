class PreciseMethodCallee extends MethodCallee {
	private {
		@alien: Boolean
		@instance: Boolean
		@object
		@objectType: ReferenceType
		@property: String
		@proxy: Boolean
	}
	constructor(@data, @object, @objectType, @property, assessment, match, @node) { # {{{
		super(data, new MemberExpression(data.callee, node, node.scope(), object), false, assessment, match, node)

		@alien = match.function.isAlien()
		@instance = match.function.isInstance()
		@proxy = match.function.isProxy()
	} # }}}
	override buildHashCode() => `method:\(@property):\(@index):\(@alien):\(@instance):\(@positions.join(','))`
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					fragments.compileReusable(@object)

					if @alien {
						fragments.code(`.\(@property).call(`)
					}
					else if @instance {
						fragments.code(`.__ks_func_\(@property)_\(@index).call(`)
					}
					else {
						fragments.code(`.__ks_sttc_\(@property)_\(@index).call(`)
					}

					fragments.compile(@object, mode)

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
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
					fragments.wrap(@object)

					if @alien {
						fragments.code(`.\(@property)(`)
					}
					else if @instance {
						if @proxy {
							fragments.code(`\(@function.getProxyPath()).__ks_func_\(@function.getProxyName())_\(@index)(`)
						}
						else {
							fragments.code(`.__ks_func_\(@property)_\(@index)(`)
						}
					}
					else {
						fragments.code(`.__ks_sttc_\(@property)_\(@index)(`)
					}

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		if @flatten {
			throw new NotImplementedException(this)
		}
		else {
			fragments.code($runtime.helper(node), '.vcurry(')

			if @alien {
				fragments.compile(@object).code(`.\(@property)`).code($comma)
			}
			else if @instance {
				fragments.compile(@object).code(`.__ks_func_\(@property)_\(@index)`).code($comma)
			}
			else {
				fragments.compile(@object).code(`.__ks_sttc_\(@property)_\(@index)`).code($comma)
			}

			switch @scope {
				ScopeKind::Argument => {
					fragments.compile(node.getCallScope())
				}
				ScopeKind::Null => {
					fragments.code('null')
				}
				ScopeKind::This => {
					fragments.compile(@object.caller())
				}
			}

			Router.Argument.toFragments(@positions, null, node.arguments(), @function, true, fragments, mode)
		}
	} # }}}
	toPositiveTestFragments(fragments, node) { # {{{
		@objectType.toPositiveTestFragments(fragments, @object)
	} # }}}
}
