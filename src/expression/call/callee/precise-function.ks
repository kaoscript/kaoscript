class PreciseFunctionCallee extends PreciseCallee {
	constructor(@data, assessment, match: CallMatch, @node) { # {{{
		super(data, $compile.expression(data.callee, node), false, assessment, match, node)
	} # }}}
	override buildHashCode() => `function:\(@index):\(@positions.join(','))`
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			if @scope == ScopeKind::Argument {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(node.getCallScope(), mode)
			}
			else if @scope == ScopeKind::Null || @expression is not MemberExpression {
				fragments
					.compileReusable(@expression)
					.code('.apply(null')
			}
			else {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(@expression.caller(), mode)
			}

			Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
		}
		else {
			match @scope {
				ScopeKind::Argument {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('.call(').compile(node.getCallScope(), mode)

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
				}
				ScopeKind::Null {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('.call(null')

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
				}
				ScopeKind::This {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('(')

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		if @flatten {
			match @scope {
				ScopeKind::Argument {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code($comma)
						.compile(node.getCallScope())
				}
				ScopeKind::Null {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', null')
				}
				ScopeKind::This {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', ')
						.compile(@expression.caller())
				}
			}

			Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, true, fragments, mode)
		}
		else {
			match @scope {
				ScopeKind::Argument {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code($comma)
						.compile(node.getCallScope())
				}
				ScopeKind::Null {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', null')
				}
				ScopeKind::This {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', ')
						.compile(@expression.caller())
				}
			}

			Router.Argument.toFragments(@positions, null, node.arguments(), @function, true, fragments, mode)
		}
	} # }}}
}
