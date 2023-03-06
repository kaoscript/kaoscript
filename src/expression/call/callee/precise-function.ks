class PreciseFunctionCallee extends PreciseCallee {
	private {
		@curries
		@direct
		@matches: CallMatch[]
	}
	constructor(@data, assessment, @matches, @node) { # {{{
		super(data, $compile.expression(data.callee, node), false, assessment, matches[0], node)
	} # }}}
	constructor(@data, @expression, assessment, @matches, @node) { # {{{
		super(data, expression, true, assessment, matches[0], node)
	} # }}}
	override buildHashCode() => `function:\(@index):\(Callee.buildPositionHash(@positions))`
	flagDirect() { # {{{
		@direct = true
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @direct {
			fragments.code('((')

			var block = Parameter.toFragments(@expression, fragments, ParameterMode.Default, (fragments) => fragments.code(') =>').newBlock())

			block.compile(@expression._block)

			if !@expression._awaiting && !@expression._exit && @expression._type.isAsync() {
				block.line('__ks_cb()')
			}

			block.done()

			fragments.code(')(')

			Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, true, fragments, mode)
		}
		else if @flatten {
			if @scope == ScopeKind.Argument {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(node.getCallScope(), mode)
			}
			else {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(@expression.caller(), mode)
			}

			Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, null, fragments, mode)
		}
		else {
			match @scope {
				ScopeKind.Argument {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('.call(').compile(node.getCallScope(), mode)

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, true, fragments, mode)
				}
				ScopeKind.This {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('(')

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, true, fragments, mode)
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		if @curries.length == 1 {
			fragments.code($runtime.helper(node), '.curry(')

			var [type, map] = @curries[0]

			var assessment = type.assessment('<router>', node)

			fragments.code(`(fn, `)

			if assessment.labelable {
				fragments.code('kws, ')
			}

			var blockRouter = fragments.code(`...args) =>`).newBlock()

			Router.toFragments(
				(function, line) => {
					line.code(`fn[0](`)

					return false
				}
				null
				assessment
				blockRouter
				node
			)

			blockRouter.done()

			fragments.code($comma)

			match @expression {
				is ArrowFunctionExpression {
					fragments.code('(')

					for var parameter, index in type.parameters() {
						fragments.code($comma) if index != 0

						fragments.code(parameter.getExternalName())
					}

					fragments.code(') =>')

					var block = fragments.newBlock()

					var parameters = @function.parameters()
					var arguments = @node.arguments()

					for var { parameter, value: { passthru } }, index in map when ?passthru {
						block
							.newLine()
							.code($runtime.scope(@node))
							.code(parameters[parameter].getInternalName())
							.code($equals)
							.compile(arguments[passthru])
							.done()
					}

					@expression.toBlockFragments(block)

					block.done()
				}
				else {
					fragments.code('(')

					for var _, index in type.parameters() {
						// TODO!
						// fragments
						// 	..code($comma) if index != 0
						// 	..code(`__ks_\(index)`)
						fragments.code($comma) if index != 0
						fragments.code(`__ks_\(index)`)
					}

					fragments.code(') => ')

					var arguments = @node.arguments()

					match @scope {
						ScopeKind.Argument {
							fragments
								.compile(@expression)
								.code(`.__ks_\(type.index() == -1 ? 0 : type.index()).call(`)
								.compile(@node.getCallScope())
							// TODO!
							// .code($comma) if #arguments

							// TODO!
							// if #arguments {
							if arguments.length > 0 {
								fragments.code($comma)
							}
						}
						ScopeKind.This {
							fragments.compile(@expression).code(`.__ks_\(type.index() == -1 ? 0 : type.index())(`)
						}
					}

					CurryExpression.toArgumentFragments(map, arguments, true, fragments, mode)

					fragments.code(')')
				}
			}
		}
		else {
			fragments
				.code($runtime.helper(node), '.curry((fn, ...args) => ')
				.compile(@expression)
				.code('(...args)')

			for var [type, map] in @curries {
				fragments.code($comma)

				fragments.code('(')

				for var _, index in type.parameters() {
					fragments.code($comma) if index != 0

					fragments.code(`__ks_\(index)`)
				}

				fragments.code(') => ').compile(@expression).code(`.__ks_\(type.index())(`)

				var arguments = @node.arguments()

				CurryExpression.toArgumentFragments(map, arguments, true, fragments, mode)

				fragments.code(')')
			}
		}
	} # }}}
	toCurryType() { # {{{
		@curries = []

		if @matches.length > 1 {
			var overloaded = new OverloadedFunctionType(@node.scope())

			for var { function, positions }, index in @matches {
				var curry = CurryExpression.toCurryType(function, positions, true, @node)

				curry[0].index(function.index())

				@curries.push(curry)

				overloaded.addFunction(curry[0])
			}

			return overloaded
		}
		else {
			var curry = CurryExpression.toCurryType(@function, @positions, true, @node)

			curry[0].index(@function.index())

			@curries.push(curry)

			return curry[0]
		}
	} # }}}
}
