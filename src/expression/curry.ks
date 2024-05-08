class CurryExpression extends CallExpression {
	static {
		toArgumentFragments(map, arguments, precise: Boolean, fragments, mode) { # {{{
			for var { parameter, value?, values? }, index in map {
				fragments.code($comma) if index != 0

				if ?value {
					var { placeholder?, passthru?, element?, from?, to? } = value

					if ?passthru {
						if ?element {
							arguments[passthru].argument().toArgumentFragments(fragments, mode)

							fragments.code(`[\(element)]`)
						}
						else if ?from {
							arguments[passthru].argument().toArgumentFragments(fragments, mode)

							fragments.code(`.slice(\(from)`)

							if ?to {
								fragments.code(`, \(to + 1)`)
							}

							fragments.code(')')
						}
						else {
							arguments[passthru].argument().toArgumentFragments(fragments, mode)
						}
					}
					else {
						fragments.code(`__ks_\(placeholder)`)
					}
				}
				else if ?values {
					if precise && values.length == 1 {
						var { placeholder?, passthru?, element?, from?, to? } = values[0]

						if ?passthru {
							if ?element {
								fragments.code('[')

								arguments[passthru].argument().toArgumentFragments(fragments, mode)

								fragments
									..code(`[\(element)]`)
									..code(']')
							}
							else if ?from {
								arguments[passthru].argument().toArgumentFragments(fragments, mode)

								fragments.code(`.slice(\(from)`)

								if ?to {
									fragments.code(`, \(to + 1)`)
								}

								fragments.code(')')
							}
							else {
								arguments[passthru].argument().toArgumentFragments(fragments, mode)
							}
						}
						else {
							fragments.code(`__ks_\(placeholder)`)
						}

						continue
					}

					var concat = precise && ?values[0]?.from
					var first = if concat set 1 else 0

					if concat {
						var { passthru, from, to? } = values[0]

						arguments[passthru].argument().toArgumentFragments(fragments, mode)

						fragments.code(`.slice(\(from)`)

						if ?to {
							fragments.code(`, \(to + 1)`)
						}

						fragments.code(').concat(')
					}
					else if precise {
						fragments.code('[')
					}

					for var { placeholder?, passthru?, element?, from?, to? }, vIndex in values from first {
						fragments.code($comma) if vIndex != first

						if ?passthru {
							if ?element {
								fragments.code('[') if concat

								arguments[passthru].argument().toArgumentFragments(fragments, mode)

								fragments.code(`[\(element)]`)
							}
							else if ?from {
								fragments.code('...') if !concat

								arguments[passthru].argument().toArgumentFragments(fragments, mode)

								fragments.code(`.slice(\(from)`)

								if ?to {
									fragments.code(`, \(to + 1)`)
								}

								fragments.code(')')
							}
							else {
								arguments[passthru].toArgumentFragments(fragments, mode)
							}
						}
						else {
							fragments.code('...') if !concat

							fragments.code(`__ks_\(placeholder)`)
						}
					}

					if precise {
						fragments.code(if concat set ')' else ']')
					}
				}
				else {
					throw NotImplementedException.new()
				}
			}
		} # }}}
		toCurryType(function: FunctionType, positions: CallMatchPosition[], precise: Boolean, node: AbstractNode): [FunctionType, Array] { # {{{
			var type = FunctionType.new(node.scope())
				..setThisType(function.getThisType()) if !function.isMissingThis()
				..setReturnType(function.getReturnType())
				..addError(...function.listErrors()!?)
				..flagAuxiliary() if function._auxiliary
				..flagExhaustive() if function._exhaustive

			var map = []

			var parameters = function.parameters()
			var arguments = node.arguments()

			var mut placeholder = 0
			var mut spreadIndex = 0
			var mut spreadPosition = -1

			for var parameter, pIndex in parameters {
				var position = positions[pIndex]

				if !?position {
					if precise {
						map.push({ parameter: pIndex, values: [] })
					}
				}
				else if position is Array {
					var values = []

					for var { index, element?, from?, to? } in position {
						var argument = arguments[index]

						if argument is PlaceholderArgument {
							if argument.type().isRest() {
								type.addParameter(parameter.clone(), node)
							}
							else {
								throw NotImplementedException.new()
							}

							values.push({ placeholder })

							placeholder += 1
						}
						else {
							values.push({
								passthru: index
								element if ?element
								from if ?from
								to if ?to
							})
						}
					}

					map.push({ parameter: pIndex, values })
				}
				else if ?position.index {
					var argument = arguments[position.index]

					if argument is PlaceholderArgument {
						type.addParameter(parameter.clone(), node)

						map.push({ parameter: pIndex, value: { placeholder }})

						placeholder += 1
					}
					else {
						var { index, element?, from?, to? } = position

						map.push({ parameter: index, value: {
							passthru: index
							element if ?element
							from if ?from
							to if ?to
						}})
					}
				}
				else {
					map.push({ parameter: pIndex })
				}
			}

			return [type, map]
		} # }}}
	}
	override prepare(target, targetMode) { # {{{
		@matchingMode = .AllMatches

		super(target, targetMode)

		match @callees.length {
			1 {
				@type = @callees[0].toCurryType()
			}
			else {
				throw NotImplementedException.new(this)
			}
		}
	} # }}}
	override isExit(mode) => false
	override makeCallee(generics, node) { # {{{
		node.prepareArguments()

		node.addCallee(DefaultCallee.new(node.data(), null, null, node))
	} # }}}
	toCallFragments(fragments, mode) { # {{{
		match @callees.length {
			1 {
				@callees[0].toCurryFragments(fragments, mode, this)
			}
			else {
				throw NotImplementedException.new(this)
			}
		}
	} # }}}
}
