class PreciseThisCallee extends MethodCallee {
	private {
		@alien: Boolean
		@curries
		@instance: Boolean
		@objectType: ReferenceType
		@property: String
		@sealed: Boolean					= false
		@variable
	}
	constructor(@data, @expression, @objectType, @property, assessment, match: CallMatch, @node) { # {{{
		super(data, expression, true, assessment, match, node)

		@alien = match.function.isAlien()
		@instance = match.function.isInstance()
		@sealed = match.function.isSealed()

		@variable = @node.scope().getVariable('this')
	} # }}}
	override buildHashCode() => `this:\(@property):\(@index):\(@alien):\(@instance):\(Callee.buildPositionHash(@positions))`
	toCurryFragments(fragments, mode, node) { # {{{
		match @scope {
			ScopeKind.Argument {
				throw NotImplementedException.new()
			}
			ScopeKind.This {
				var name = @variable.getSecureName()

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
					fragments.code(`\(name).\(@property)(`)
				}
				else if @instance {
					fragments.code(`\(name).__ks_func_\(@property)_\(@index)(`)
				}
				else {
					fragments.code(`\(name).__ks_sttc_\(@property)_\(@index)(`)
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

							for var { placeholder?, passthru? }, vIndex in values {
								fragments.code($comma) if vIndex != 0

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
	} # }}}
	toCurryType() { # {{{
		@curries = []

		var curry = CurryExpression.toCurryType(@function, @positions, true, @node)

		curry[0].index(@function.index())

		@curries.push(curry)

		return curry[0]
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @sealed {
			var name = @objectType.getSealedPath()

			if @flatten {
				match node._data.scope.kind {
					ScopeKind.Argument {
						throw NotImplementedException.new(node)
					}
					ScopeKind.This {
						if @function.isInstance() {
							fragments.code(`\(name).__ks_func_\(@property)_\(@function.index()).call(this`)
						}
						else {
							fragments.code(`\(name).__ks_sttc_\(@property)_\(@function.index()).apply(this`)
						}

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, null, fragments, mode)
					}
				}
			}
			else {
				match @scope {
					ScopeKind.Argument {
						throw NotImplementedException.new(node)
					}
					ScopeKind.This {
						if @alien {
							throw NotImplementedException.new(node)
						}
						else if @instance {
							fragments.code(`\(name).__ks_func_\(@property)_\(@function.index()).call(this`)
						}
						else {
							fragments.code(`\(name).__ks_sttc_\(@property)_\(@function.index())(this`)
						}

						Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, true, fragments, mode)
					}
				}
			}
		}
		else {
			var name = @variable.getSecureName()

			match @scope {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
					if @alien {
						fragments.code(`\(name).\(@property)(`)
					}
					else if @instance {
						fragments.code(`\(name).__ks_func_\(@property)_\(@index)(`)
					}
					else {
						fragments.code(`\(name).__ks_sttc_\(@property)_\(@index)(`)
					}

					Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, true, fragments, mode)
				}
			}
		}

	} # }}}
}
