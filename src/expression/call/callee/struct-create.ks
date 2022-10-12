class StructCreateCallee extends PreciseCallee {
	constructor(@data, assessment, match: CallMatch, @node) { # {{{
		super(data, $compile.expression(data.callee, node), false, assessment, match, node)
	} # }}}
	override buildHashCode() => `struct:\(@index):\(@positions.join(','))`
	toFragments(fragments, mode, node) { # {{{
		fragments.wrap(@expression, mode).code(`.__ks_new`).code('(')

		Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
	} # }}}
}
