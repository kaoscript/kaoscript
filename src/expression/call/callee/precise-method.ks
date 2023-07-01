class PreciseMethodCallee extends MethodCallee {
	private {
		@alien: Boolean
		@instance: Boolean
		@curries
		@matches: CallMatch[]
		@object
		@objectType: ReferenceType
		@property: String
		@proxy: Boolean
	}
	constructor(@data, @object, @objectType, @property, assessment, @matches, @node) { # {{{
		super(data, MemberExpression.new(data.callee, node, node.scope(), object), false, assessment, matches[0], node)

		@alien = matches[0].function.isAlien()
		@instance = matches[0].function.isInstance()
		@proxy = matches[0].function.isProxy()
	} # }}}
	override buildHashCode() => `method:\(@property):\(@index):\(@alien):\(@instance):\(Callee.buildPositionHash(@positions))`
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			match @scope {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
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

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, true, fragments, mode)
				}
			}
		}
		else {
			match @scope {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
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

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, true, fragments, mode)
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		match @scope {
			ScopeKind.Argument {
				throw NotImplementedException.new()
			}
			ScopeKind.This {
				if @curries.length == 1 {
					fragments.code($runtime.helper(node), '.curry(')

					var [type, map] = @curries[0]

					var assessment = type.assessment('<router>', node)

					fragments.code(`(that, fn, `)

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

					fragments.code('(')

					for var _, index in type.parameters() {
						fragments.code($comma) if index != 0

						fragments.code(`__ks_\(index)`)
					}

					fragments.code(') => ')

					if @alien {
						fragments.compile(@object).code(`.\(@property)(`)
					}
					else if @instance {
						fragments.compile(@object).code(`.__ks_func_\(@property)_\(@index)(`)
					}
					else {
						fragments.compile(@object).code(`.__ks_sttc_\(@property)_\(@index)(`)
					}

					var arguments = @node.arguments()

					for var { parameter, value?, values? }, index in map {
							fragments.code($comma) if index != 0

							if ?value {
								if ?value.passthru {
									arguments[value.passthru].toArgumentFragments(fragments, mode)
								}
								else {
									fragments.code(`__ks_\(value.placeholder)`)
								}
							}
							else if ?values {
								fragments.code('[')

								for var { placeholder?, passthru? }, index in values {
									fragments.code($comma) if index != 0

									if ?passthru {
										arguments[passthru].toArgumentFragments(fragments, mode)
									}
									else {
										fragments.code(`...__ks_\(placeholder)`)
									}
								}

								fragments.code(']')
							}
							else {
							}
						}

					fragments.code(')')
				}
				else {
					fragments
						.code($runtime.helper(node), '.curry((that, fn, ...args) => ')
						.compile(@expression)
						.code('(...args)')

					for var [type, map] in @curries {
						fragments.code($comma)

						fragments.code('(')

						for var parameter, index in type.parameters() {
							fragments.code($comma) if index != 0

							fragments.code(`__ks_\(index)`)
						}

						fragments.code(') => ')

						if @alien {
							fragments.compile(@object).code(`.\(@property)(`)
						}
						else if @instance {
							fragments.compile(@object).code(`.__ks_func_\(@property)_\(@index)(`)
						}
						else {
							fragments.compile(@object).code(`.__ks_sttc_\(@property)_\(@index)(`)
						}

						var arguments = @node.arguments()

						for var { parameter, value?, values? }, index in map {
							fragments.code($comma) if index != 0

							if ?value {
								if ?value.passthru {
									arguments[value.passthru].toArgumentFragments(fragments, mode)
								}
								else {
									fragments.code(`__ks_\(value.placeholder)`)
								}
							}
							else if ?values {
								fragments.code('[')

								for var { placeholder?, passthru? }, index in values {
									fragments.code($comma) if index != 0

									if ?passthru {
										arguments[passthru].toArgumentFragments(fragments, mode)
									}
									else {
										fragments.code(`...__ks_\(placeholder)`)
									}
								}

								fragments.code(']')
							}
							else {
							}
						}

						fragments.code(')')
					}
				}
			}
		}
	} # }}}
	toCurryType() { # {{{
		@curries = []

		if @matches.length > 1 {
			var overloaded = OverloadedFunctionType.new(@node.scope())

			for var { function, positions }, index in @matches {
				var curry = CurryExpression.toCurryType(function, positions, true, @node)

				curry[0].index(function.index())

				@curries.push(curry)

				overloaded.addFunction(curry[0])
			}

			return overloaded
		}
		else {
			var { function, positions } = @matches[0]
			var curry = CurryExpression.toCurryType(function, positions, true, @node)

			curry[0].index(function.index())

			@curries.push(curry)

			return curry[0]
		}
	} # }}}
	toPositiveTestFragments(fragments, node) { # {{{
		@objectType.toPositiveTestFragments(fragments, @object)
	} # }}}
}
