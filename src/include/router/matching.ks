namespace Matching {
	struct Matches {
		precise: Boolean					= true
		arguments: CallMatchPosition[]		= []
	}

	export {
		func matchArguments(
			assessment: Assessment
			route: Route
			arguments: Type[]
			excludes: String[]
			indexeds: NamingArgument[]
			generics: Type{}
			fitting: Boolean
			fittingSpread: Boolean
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult { # {{{
			var combinations = splitArguments(arguments, null, null, indexeds, fitting)

			if #combinations == 1 {
				var context = MatchContext.new(
					arguments: combinations[0]
					excludes
					async: assessment.async
					fitting
					fittingSpread
					indexeds
					mode
					node
				)
				var length = getLength(context.arguments) + (if assessment.async set 1 else 0)

				for var tree in route.trees {
					if length != Infinity && (length < tree.min || (!fittingSpread && 0 < tree.max < length)) {
						continue
					}

					WithIndex.match(tree, context, {...generics})

					if !fitting && mode == .BestMatch && context.found && ?#context.matches && !?#context.possibilities {
						return PreciseCallMatchResult.new(context.matches)
					}
				}

				if context.found {
					if ?#context.matches {
						if !?#context.possibilities {
							return PreciseCallMatchResult.new(context.matches)
						}

						if mode == .BestMatch {
							for var { function } in context.matches {
								context.possibilities.pushUniq(function)
							}
						}

						return LenientCallMatchResult.new(context.possibilities, matches: context.matches)
					}
					else {
						return LenientCallMatchResult.new(context.possibilities)
					}
				}
			}
			else {
				var results = []

				for var combination in combinations {
					var context = MatchContext.new(combination, excludes, async: assessment.async, indexeds, mode, node)
					var length = getLength(context.arguments)

					var mut nf = true

					for var tree in route.trees while nf {
						if length != Infinity && (length < tree.min || (!fittingSpread && 0 < tree.max < length)) {
							continue
						}

						WithIndex.match(tree, context, {...generics})

						if context.found && ?#context.matches && !?#context.possibilities {
							results.push(PreciseCallMatchResult.new(context.matches))

							nf = false
						}
					}

					if context.found {
						if nf {
							for var { function } in context.matches {
								context.possibilities.pushUniq(function)
							}

							results.push(LenientCallMatchResult.new(context.possibilities, matches: context.matches))
						}
					}
					else {
						return NoMatchResult.NoArgumentMatch
					}
				}

				return mergeResults(results)
			}

			return NoMatchResult.NoArgumentMatch
		} # }}}

		func matchArguments(
			assessment: Assessment
			route: Route
			arguments: Type[]
			nameds: NamingArgument{}
			shorthands: NamingArgument{}
			indexeds: NamingArgument[]
			generics: Type{}
			fitting: Boolean
			fittingSpread: Boolean
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult { # {{{
			var combinations = splitArguments(arguments, nameds, shorthands, indexeds, fitting)

			var results = []

			for var combination in combinations {
				match var result = WithName.match(assessment, route, combination, nameds, shorthands, [...indexeds], {...generics}, fitting, fittingSpread, mode, node) {
					is LenientCallMatchResult | PreciseCallMatchResult {
						results.push(result)
					}
					else {
						return NoMatchResult.NoArgumentMatch
					}
				}
			}

			return mergeResults(results)
		} # }}}

		func prepare(argument, index, fitting: Boolean, nameds, shorthands, indexeds, invalids, mut namedCount, mut shortCount, assessment: Assessment, node: AbstractNode) { # {{{
			var type = argument.type()

			match argument {
				is NamedArgument {
					var name = argument.name()

					if var existing ?= nameds[name] {
						unless existing.spread && existing.fitting {
							SyntaxException.throwDuplicateNamedArgument(name, node)
						}
					}

					nameds[name] = NamingArgument.new(
						fitting
						index
						name
						type
						strict: true
					)

					namedCount += 1

					if ?shorthands[name] {
						Object.delete(shorthands, name)

						shortCount -= 1
					}
				}
				is IdentifierLiteral {
					var name = argument.name()

					if argument.variable().isPredefined() {
						indexeds.push(NamingArgument.new(
							fitting
							index
							type
							strict: false
						))
					}
					else if !?nameds[name] && !?invalids[name] {
						if ?shorthands[name] {
							invalids[name] = true

							indexeds.push(shorthands[name], NamingArgument.new(
								fitting
								index
								type
								strict: false
							))

							Object.delete(shorthands, name)

							shortCount -= 1
						}
						else {
							shortCount += 1

							shorthands[name] = NamingArgument.new(
								fitting
								index
								name
								type
								strict: false
							)
						}
					}
					else {
						indexeds.push(NamingArgument.new(
							fitting
							index
							type
							strict: false
						))
					}
				}
				is UnaryOperatorSpread {
					if type.isObject() {
						if type.isReference() {
							var rest = type.parameter()

							for var function of assessment.functions {
								for var parameter in function.parameters() when parameter.isLabeled() {
									var name = parameter.getExternalName()

									nameds[name] = NamingArgument.new(
										fitting
										index
										name
										property: true
										spread: true
										strict: false
										type: rest
									)

									namedCount += 1

									if ?shorthands[name] {
										Object.delete(shorthands, name)

										shortCount -= 1
									}
								}
							}
						}
						else {
							var finite = type.isFinite()
							var root = type.discard()
							var rest = root.getRestType()

							for var function of assessment.functions {
								for var parameter in function.parameters() when parameter.isLabeled() {
									var name = parameter.getExternalName()

									if var property ?= root.getProperty(name) {
										nameds[name] = NamingArgument.new(
											fitting
											index
											name
											property: true
											spread: true
											strict: true
											type: property
										)
									}
									else if finite {
										continue
									}
									else {
										nameds[name] = NamingArgument.new(
											fitting
											index
											name
											property: true
											spread: true
											strict: false
											type: rest
										)
									}

									namedCount += 1

									if ?shorthands[name] {
										Object.delete(shorthands, name)

										shortCount -= 1
									}
								}
							}
						}
					}
					else {
						indexeds.push(NamingArgument.new(
							fitting
							index
							type
							strict: false
							value: argument
						))
					}
				}
				else {
					indexeds.push(NamingArgument.new(
						fitting
						index
						type
						strict: false
						value: argument
					))
				}
			}

			return [namedCount, shortCount]
		} # }}}
	}

	func getLength(arguments: Type[]): Number { # {{{
		var mut length = 0

		for var argument in arguments {
			if !argument.isSpread() {
				length += 1
			}
			else if argument is ArrayType && !argument.hasRest() {
				length += argument.length():!!!(Number)
			}
			else {
				return Infinity
			}
		}

		return length
	} # }}}

	func getSpreadParameter(type: Type): Type { # {{{
		if type is ArrayType && type.length() > 0 {
			var parameter = type.parameter()

			if parameter.isUnion() {
				return AnyType.NullableUnexplicit
			}
			else {
				return parameter
			}
		}
		else {
			return type.parameter()
		}
	} # }}}

	func isFitting(
		index: Number
		nameds: NamingArgument{}?
		shorthands: NamingArgument{}?
		indexeds: NamingArgument[]?
	): Boolean { # {{{
		if ?nameds {
			for var arg of nameds {
				return arg.fitting if arg.index == index
			}
		}

		if ?shorthands {
			for var arg of shorthands {
				return arg.fitting if arg.index == index
			}
		}

		if ?indexeds {
			for var arg in indexeds {
				return arg.fitting if arg.index == index
			}
		}

		return false
	} # }}}

	func isPreciseMatch(argument: Type, parameter: Type): Boolean { # {{{
		return argument.isAssignableToVariable(parameter, false, false, false)
	} # }}}

	func isSameArgument(a: CallMatchArgument, b: CallMatchArgument): Boolean { # {{{
		if ?a.index {
			return false unless ?b.index
			return false unless a.index == b.index

			if ?a.element {
				return false unless ?b.element
				return false unless a.element == b.element
			}
			else {
				return false unless !?b.element
			}

			if ?a.from {
				return false unless ?b.from
				return false unless a.from == b.from
			}
			else {
				return false unless !?b.from
			}
		}
		else {
			return false unless !?b.index
		}

		return true
	} # }}}

	func isSamePositions(aPositions: CallMatchPosition[], bPositions: CallMatchPosition[]): Boolean { # {{{
		return false unless aPositions.length == bPositions.length

		for var a, index in aPositions {
			var b = bPositions[index]

			if a is Array {
				return false unless b is Array
				return false unless a.length == b.length

				for var k, i in a {
					return false unless isSameArgument(k, b[i])
				}
			}
			else {
				return false unless b is CallMatchArgument
				return false unless isSameArgument(a, b)
			}
		}

		return true
	} # }}}

	func isUnpreciseMatch(argument: Type, parameter: Type): Boolean { # {{{
		if argument.isStrict() {
			return argument.isAssignableToVariable(parameter, true, false, false)
		}
		else {
			return argument.isAssignableToVariable(parameter, true, true, true)
		}
	} # }}}

	func mergeResults(results: CallMatchResult[]): CallMatchResult { # {{{
		if results.length == 0 {
			return NoMatchResult.NoArgumentMatch
		}
		else if results.length == 1 {
			return results[0]
		}

		if results.every((result, _, _) => result is PreciseCallMatchResult) {
			var perFunctions = {}

			var mut precise = true

			for var { matches } in results while precise {
				for var match in matches while precise {
					if var result ?= perFunctions[match.function.index()] {
						if !isSamePositions(result.positions, match.positions) {
							precise = false
						}
					}
					else {
						perFunctions[match.function.index()] = match
					}
				}
			}

			if precise {
				return PreciseCallMatchResult.new([match for var match of perFunctions])
			}
		}

		var possibilities = []

		for var result in results {
			if result is LenientCallMatchResult {
				possibilities.pushUniq(...result.possibilities)
			}
			else {
				for var { function } in result.matches {
					possibilities.pushUniq(function)
				}
			}
		}

		return LenientCallMatchResult.new(possibilities)
	} # }}}

	func splitArguments(
		types: Type[]
		nameds: NamingArgument{}?
		shorthands: NamingArgument{}?
		indexeds: NamingArgument[]?
		fitting: Boolean
	): Type[][] { # {{{
		var mut combinations = [[]]

		for var type, index in types {
			if fitting && isFitting(index, nameds, shorthands, indexeds) {
				for var combination in combinations {
					combination.push(type)
				}
			}
			else if type.isSpread() && type.type().isArray() {
				// TODO split by properties if array
				var parameters = splitArguments([getSpreadParameter(type)], null, null, null, false)

				if parameters.length > 1 {
					var scope = type.scope()
					var nullable = type.isNullable()
					var oldCombinations = combinations

					combinations = []

					if type.isArray() {
						for var oldCombination in oldCombinations {
							for var parameter in parameters {
								var ref = Type.arrayOf(parameter[0], scope).setNullable(nullable).flagSpread()

								combinations.push([...oldCombination, ref])
							}
						}
					}
					else {
						for var oldCombination in oldCombinations {
							for var parameter in parameters {
								var ref = Type.objectOf(parameter[0], scope).setNullable(nullable).flagSpread()

								combinations.push([...oldCombination, ref])
							}
						}
					}
				}
				else {
					for var combination in combinations {
						combination.push(type)
					}
				}
			}
			else if type.isUnion() {
				var oldCombinations = combinations

				combinations = []

				var mut nullable = false

				for var oldCombination in oldCombinations {
					for var subtype in type.discardAlias().types() {
						var combination = [...oldCombination!?]

						if subtype.isNullable() && !(subtype.isAny() || subtype.isNull()) {
							combination.push(subtype.setNullable(false))

							nullable = true
						}
						else {
							combination.push(subtype)
						}

						combinations.push(combination)
					}

					if nullable {
						var combination = [...oldCombination!?, Type.Null]

						combinations.push(combination)
					}
				}
			}
			else if type.isNullable() && !(type.isAny() || type.isNull()) {
				var oldCombinations = combinations

				combinations = []

				for var oldCombination in oldCombinations {
					var combination1 = [...oldCombination!?, type.setNullable(false)]
					var combination2 = [...oldCombination!?, Type.Null]

					combinations.push(combination1, combination2)
				}
			}
			else {
				for var combination in combinations {
					combination.push(type)
				}
			}
		}

		return combinations
	} # }}}

	namespace WithIndex {
		struct Cursor {
			argument: Type
			index: Number
			length: Number
			spread: Boolean
			used: Number

			// TODO! add methods
		}

		export {
			func match(tree: Tree, context: MatchContext, generics: Type{}): Void { # {{{
				if context.arguments.length == 0 {
					if context.async {
						context.found = true

						var branch = getZeroBranch(tree)
						var function = branch.function
						var parameters = function.parameters()
						var positions = []

						for var type in branch.rows[0].types to~ -1 {
							if parameters[type.parameter].isVarargs() {
								positions[type.parameter] = []
							}
							else {
								positions[type.parameter] = CallMatchArgument.new()
							}
						}

						context.matches.push(CallMatch.new(
							function
							positions
						))
					}
					else {
						return if tree.min > 0

						context.found = true

						if tree.order.length == 0 {
							var function = tree.function
							var parameters = function.parameters()
							var positions = []

							for var parameter in parameters {
								if parameter.isVarargs() {
									positions.push([])
								}
								else {
									positions.push(CallMatchArgument.new())
								}
							}

							context.matches.push(CallMatch.new(
								function
								positions
							))
						}
						else {
							var branch = getZeroBranch(tree)
							var function = branch.function
							var parameters = function.parameters()
							var positions = []

							for var type in branch.rows[0].types {
								if parameters[type.parameter].isVarargs() {
									positions[type.parameter] = []
								}
								else {
									positions[type.parameter] = CallMatchArgument.new()
								}
							}

							context.matches.push(CallMatch.new(
								function
								positions
							))
						}
					}
				}
				else {
					var cursor = getCursor(0, context)

					if !isFitting(cursor, context) && cursor.argument.isUnion() {
						var newContext = duplicateContext(context)

						for var type in cursor.argument.discardAlias().types() {
							var mut nf = true

							for var key in tree.order while nf {
								if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor, type), Matches.new(), newContext, {...generics}) {
									nf = false
								}
							}

							if nf {
								return
							}
						}

						if newContext.found {
							context.found = true

							for var function in newContext.possibilities {
								context.possibilities.pushUniq(function)
							}

							for var m in newContext.matches {
								pushUniqCallMatch(context.matches, m)
							}
						}
					}
					else {
						for var key in tree.order {
							// echo('---', key)
							if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor), Matches.new(), context, {...generics}) && !context.fitting {
								return
							}
						}
					}
				}
			} # }}}

			func matchArguments(
				node: TreeColumn
				mut cursor: Cursor
				argMatches: Matches
				context: MatchContext
				generics: Type{}
			): { cursor: Cursor, argMatches: Matches }? { # {{{
				var { arguments } = context
				var last = #arguments - 1

				if node.min == 0 && cursor.index > last {
					argMatches.arguments.push([])

					return { cursor, argMatches }
				}

				if node.max == 1 {
					if cursor.spread {
						if cursor.argument.isPlaceholder() {
							cursor.used += 1

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

							cursor = getNextCursor(cursor, context)

							return { cursor, argMatches }
						}

						var argument = getSpreadParameter(cursor.argument)

						var mut fullType = node.type
						var mut fullMatch = false

						if fullType.isDeferrable() {
							{ type % fullType, match % fullMatch } = fullType.matchDeferred(argument.discardValue(), generics)
						}

						var fitting = isFittedMatch(cursor, context, argument, fullType)

						if fullMatch || fitting || isPreciseMatch(argument, fullType) {
							argMatches.precise = fitting || cursor.length != Infinity

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index, element: cursor.used)])

							cursor.used += 1

							cursor = getNextCursor(cursor, context)

							return { cursor, argMatches }
						}
						else if isUnpreciseMatch(argument, fullType) {
							argMatches.precise = false

							cursor.used += 1

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index, element: cursor.used)])

							cursor = getNextCursor(cursor, context)

							return { cursor, argMatches }
						}
					}
					else {
						var mut fullType = node.type
						var mut fullMatch = false

						if fullType.isDeferrable() {
							{ type % fullType, match % fullMatch } = fullType.matchDeferred(cursor.argument.discardValue(), generics)
						}

						if fullMatch || isFittedMatch(cursor, context, null, fullType) || isPreciseMatch(cursor.argument, fullType) {
							var mut matched = true

							if var value ?= getRefinableValue(cursor, context) {
								if fullType.isUnion() {
									var mode = MatchingMode.FunctionSignature + MatchingMode.IgnoreRetained
									var types = []

									for var type in fullType.types() {
										if type.isSubsetOf(cursor.argument, mode) {
											types.push(type)
										}
									}

									matched = ?#types

									if matched {
										value.type(Type.union(context.node.scope(), ...types))
									}
								}
								else {
									value.type(fullType)
								}
							}

							if matched {
								cursor.used += 1

								argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

								cursor = getNextCursor(cursor, context)

								return { cursor, argMatches }
							}
						}

						if var value ?= getRefinableValue(cursor, context) {
							var mode = MatchingMode.FunctionSignature
								+ MatchingMode.AnycastParameter
								+ MatchingMode.MissingReturn
								+ MatchingMode.IgnoreRetained
								+ MatchingMode.ShiftableParameters
								+ MatchingMode.RequireAllParameters
								+ MatchingMode.IgnoreNullable

							if fullType.isUnion() {
								var types = []

								for var type in fullType.types() {
									if type.isSubsetOf(cursor.argument, mode) {
										types.push(type)
									}
								}

								if ?#types {
									value.type(Type.union(context.node.scope(), ...types))

									cursor.used += 1

									argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

									cursor = getNextCursor(cursor, context)

									return { cursor, argMatches }
								}
							}
							else if fullType.isSubsetOf(cursor.argument, mode) {
								value.type(fullType)

								cursor.used += 1

								argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

								cursor = getNextCursor(cursor, context)

								return { cursor, argMatches }
							}
						}

						if isUnpreciseMatch(cursor.argument, fullType) {
							argMatches.precise = false

							cursor.used += 1

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

							cursor = getNextCursor(cursor, context)

							return { cursor, argMatches }
						}
					}

					if cursor.length == Infinity {
						if cursor.used == 0 {
							return null
						}

						cursor = getNextCursor(cursor, context, true)

						if cursor.index < arguments.length {
							argMatches.precise = false

							return matchArguments(node, cursor, argMatches, context)
						}
						else {
							return { cursor, argMatches }
						}
					}

					if node.min == 0 {
						argMatches.arguments.push([])

						return { cursor, argMatches }
					}
					else {
						return null
					}
				}
				else {
					var initialIndex = cursor.index
					var mut i = 0

					var matches = []

					while i < node.min {
						var argument = if cursor.spread set getSpreadParameter(cursor.argument) else cursor.argument

						var mut fullType = node.type
						var mut fullMatch = false

						if fullType.isDeferrable() {
							{ type % fullType, match % fullMatch } = fullType.matchDeferred(argument.discardValue(), generics)
						}

						if isFittedMatch(cursor, context, argument, fullType) {
							pass
						}
						else if fullMatch || isPreciseMatch(argument, fullType) {
							if cursor.used + 1 > getMinParameter(cursor.argument) {
								argMatches.precise = false
							}
						}
						else if isUnpreciseMatch(argument, fullType) {
							argMatches.precise = false
						}
						else {
							return null
						}

						i += 1

						cursor = pushCursor(cursor, context, matches)
					}

					if node.max <= 0 {
						var lastIndex = Math.min(arguments.length - 1, cursor.index + arguments.length - 1 + node.max)

						if cursor.index <= lastIndex {
							while cursor.index <= lastIndex {
								if cursor.argument is not PlaceholderType {
									var argument = if cursor.spread set getSpreadParameter(cursor.argument) else cursor.argument

									var mut fullType = node.type
									var mut fullMatch = false

									if fullType.isDeferrable() {
										{ type % fullType, match % fullMatch } = fullType.matchDeferred(argument.discardValue(), generics)
									}

									if fullMatch || isFittedMatch(cursor, context, argument, fullType) || isPreciseMatch(argument, fullType) {
										pass
									}
									else if isUnpreciseMatch(argument, fullType) {
										argMatches.precise = false
									}
									else {
										break
									}
								}

								i += 1

								cursor = pushCursor(cursor, context, matches, cursor.index == lastIndex || cursor.spread && cursor.length == Infinity)
							}
						}
						else {
							if 0 < cursor.used <= cursor.length {
								var mut matched = true

								if cursor.argument is not PlaceholderType {
									var argument = if cursor.spread set getSpreadParameter(cursor.argument) else cursor.argument

									var mut fullType = node.type
									var mut fullMatch = false

									if fullType.isDeferrable() {
										{ type % fullType, match % fullMatch } = fullType.matchDeferred(argument.discardValue(), generics)
									}

									if fullMatch || isFittedMatch(cursor, context, argument, fullType) || isPreciseMatch(argument, fullType) {
										pass
									}
									else if isUnpreciseMatch(argument, fullType) {
										argMatches.precise = false
									}
									else {
										matched = false
									}
								}

								if matched {
									if node.max == Infinity {
										matches.push(CallMatchArgument.new(index: cursor.index, from: cursor.used))

										cursor = getNextCursor(cursor, context, true)
									}
									else {
										var to = cursor.length + node.max + cursor.used - 1

										matches.push(CallMatchArgument.new(
											index: cursor.index
											from: cursor.used
											:to if to + 1 < cursor.length
										))

										cursor.used += 1 - node.max

										cursor = getNextCursor(cursor, context)
									}

									if cursor.spread && cursor.argument is PlaceholderType {
										matches.push(CallMatchArgument.new(index: cursor.index))

										cursor = getNextCursor(cursor, context, true)
									}
								}
							}
						}
					}
					else {
						while i < node.max && cursor?.index <= last {
							var argument = if cursor.spread set getSpreadParameter(cursor.argument) else cursor.argument

							var mut fullType = node.type
							var mut fullMatch = false

							if fullType.isDeferrable() {
								{ type % fullType, match % fullMatch } = fullType.matchDeferred(argument.discardValue(), generics)
							}

							if fullMatch || isFittedMatch(cursor, context, argument, fullType) || isPreciseMatch(argument, fullType) {
								pass
							}
							else if isUnpreciseMatch(argument, fullType) {
								argMatches.precise = false
							}
							else {
								break
							}

							i += 1

							cursor = pushCursor(cursor, context, matches)
						}
					}

					if cursor.spread && cursor.index == initialIndex {
						if var next ?= arguments[cursor.index + 1] ;; next.isSpread() {
							if node.max != Infinity {
								argMatches.precise = false
							}

							cursor = getNextCursor(cursor, context, true)
						}
					}

					argMatches.arguments.push(matches)

					return { cursor, argMatches }
				}
			} # }}}
		}

		func duplicateContext(context: MatchContext): MatchContext { # {{{
			return MatchContext.new(
				async: context.async
				fitting: context.fitting
				fittingSpread: context.fittingSpread
				found: false
				arguments: context.arguments
				excludes: context.excludes
				matches: []
				possibilities: []
				node: context.node
				indexeds: context.indexeds
			)
		} # }}}

		func duplicateCursor(cursor: Cursor, type: Type = cursor.argument): Cursor { # {{{
			return Cursor.new(
				argument: type
				index: cursor.index
				length: cursor.length
				spread: cursor.spread
				used: cursor.used
			)
		} # }}}

		func getCursor(index: Number, { arguments }: MatchContext): Cursor { # {{{
			if index >= #arguments {
				return Cursor.new(
					argument: Type.Void
					index
					length: 0
					spread: false
					used: 0
				)
			}

			var argument = arguments[index]
			var spread = argument.isSpread()

			if spread {
				return Cursor.new(
					argument
					index
					length: getLength(argument)
					spread
					used: 0
				)
			}
			else {
				return Cursor.new(
					argument
					index
					length: 1
					spread
					used: 0
				)
			}
		} # }}}

		func getLength(type: Type): Number { # {{{
			if !type.isSpread() {
				return 1
			}
			else if type is ArrayType && !type.hasRest() {
				return type.length()
			}
			else {
				return Infinity
			}
		} # }}}

		func getMinParameter(type: Type): Number { # {{{
			if type is ArrayType {
				return type.length()
			}
			else if type.isSpread() {
				return 0
			}
			else {
				return 1
			}
		} # }}}

		func getNextCursor(current: Cursor, context: MatchContext, force: Boolean = false): Cursor { # {{{
			if current.used >= current.length || (force && current.length != 0) {
				return getCursor(current.index + 1, context)
			}
			else {
				return current
			}
		} # }}}

		func getRefinableValue(cursor: Cursor, context: MatchContext): Expression? { # {{{
			for var argument in context.indexeds {
				if argument.index == cursor.index {
					if argument.type == cursor.argument && argument.value?.isRefinable() {
						return argument.value
					}
					else {
						return null
					}
				}
			}

			return null
		} # }}}

		func getZeroBranch(tree: Tree | TreeBranch): TreeLeaf { # {{{
			var column = tree.columns[tree.order.last()]

			if column.isNode {
				return getZeroBranch(column)
			}
			else {
				return column!!
			}
		} # }}}

		func isFittedMatch(cursor: Cursor, context: MatchContext, argument: Type?, parameter: Type): Boolean { # {{{
			return false unless context.fitting

			for var arg in context.indexeds {
				if arg.index == cursor.index && arg.fitting {
					return parameter.isAssignableToVariable(argument ?? cursor.argument, true, false, false)
				}
			}

			return false
		} # }}}

		func isFitting(cursor: Cursor, { indexeds }: MatchContext): Boolean { # {{{
			for var argument in indexeds {
				if argument.index == cursor.index {
					return argument.fitting
				}
			}

			return false
		} # }}}

		func matchTreeNode(tree: Tree, branch: TreeBranch, mut cursor: Cursor, mut argMatches: Matches, context: MatchContext, generics: Type{}): Boolean { # {{{
			// echo('-- branch', toString(cursor), cursor.spread && context.mode == .AllMatches, argMatches.precise, branch.type.hashCode(), branch.min, branch.max)
			if cursor.spread && context.mode == .AllMatches  {
				if var result ?= matchArguments(branch, cursor, Matches.new(
						precise: argMatches.precise
						arguments: [...argMatches.arguments]
					), context, generics)
				{

					for var key in branch.order {
						if matchTreeNode(tree, branch.columns[key], result.cursor, Matches.new(
							precise: result.argMatches.precise
							arguments: [...result.argMatches.arguments]
						), context, generics) {
							if context.mode == .BestMatch {
								return true
							}
						}
					}

					if !context.found && cursor.argument is PlaceholderType {
						cursor = getNextCursor(cursor, context, true)
						// echo('branch', toString(cursor))

						if { cursor, argMatches } !?= matchArguments(branch, cursor, argMatches, context, generics) {
							return false
						}
						// echo(toString(cursor), argMatches, context.arguments.length)

						for var key in branch.order {
							if matchTreeNode(tree, branch.columns[key], cursor, Matches.new(
								precise: argMatches.precise
								arguments: [...argMatches.arguments]
							), context, generics) {
								if context.mode == .BestMatch {
									return true
								}
							}
						}
					}
				}
				else if cursor.argument is PlaceholderType {
					cursor = getNextCursor(cursor, context, true)
					// echo('branch', toString(cursor))

					if { cursor, argMatches } !?= matchArguments(branch, cursor, argMatches, context, generics) {
						return false
					}
					// echo(toString(cursor), argMatches, context.arguments.length)

					for var key in branch.order {
						if matchTreeNode(tree, branch.columns[key], cursor, Matches.new(
							precise: argMatches.precise
							arguments: [...argMatches.arguments]
						), context, generics) {
							if context.mode == .BestMatch {
								return true
							}
						}
					}
				}
			}
			else {
				var outOfBound = cursor.index >= #context.arguments

				if { cursor, argMatches } !?= matchArguments(branch, cursor, argMatches, context, generics) {
					// echo(null)
					return false
				}
				// echo(toString(cursor), JSON.stringify(argMatches), context.arguments.length)

				if !outOfBound && branch.min == 0 && cursor.index >= #context.arguments {
					var argument = context.arguments.last()

					for var key in branch.order {
						var node = branch.columns[key]

						if node.min != 0 {
							continue
						}

						if matchTreeNode(tree, branch.columns[key], cursor, Matches.new(
							precise: argMatches.precise
							arguments: [...argMatches.arguments]
						), context, generics) {
							if context.mode == .BestMatch {
								return true
							}
						}
					}
				}
				else if cursor.spread && cursor.index + 1 < #context.arguments {
					var oldCursor = duplicateCursor(cursor)

					for var key in branch.order {
						if matchTreeNode(tree, branch.columns[key], cursor, Matches.new(
							precise: argMatches.precise
							arguments: [...argMatches.arguments]
						), context, generics) {
							if context.mode == .BestMatch {
								return true
							}
						}
					}

					if cursor.spread && cursor.index + 1 < #context.arguments {
						cursor = getNextCursor(oldCursor, context, true)
						// echo('branch', toString(cursor))

						for var key in branch.order {
							if matchTreeNode(tree, branch.columns[key], cursor, Matches.new(
								precise: argMatches.precise
								arguments: [...argMatches.arguments]
							), context, generics) {
								if context.mode == .BestMatch {
									return true
								}
							}
						}
					}
				}
				else {
					for var key in branch.order {
						if matchTreeNode(tree, branch.columns[key], cursor, Matches.new(
							precise: argMatches.precise
							arguments: [...argMatches.arguments]
						), context, generics) {
							if context.mode == .BestMatch {
								return true
							}
						}
					}
				}
			}

			return false
		} # }}}

		func matchTreeNode(tree: Tree, leaf: TreeLeaf, mut cursor: Cursor, mut argMatches: Matches, context: MatchContext, generics: Type{}): Boolean { # {{{
			if !leaf.function.isAsync() {
				// echo('-- leaf', toString(cursor), leaf.function.hashCode(), cursor.spread && context.mode == .AllMatches, leaf.type.hashCode(), leaf.min, leaf.max)
				if cursor.spread && context.mode == .AllMatches  {
					var result = matchArguments(leaf, cursor, Matches.new(
						precise: argMatches.precise
						arguments: [...argMatches.arguments]
					), context, generics)
					// echo(toString(result.cursor), JSON.stringify(result.argMatches), context.arguments.length)

					if !?result || result.cursor.index + 1 < context.arguments.length || (result.cursor.index + 1 == context.arguments.length && result.cursor.used == 0) {
						cursor = getNextCursor(cursor, context, true)
						// echo('leaf', toString(cursor), leaf.function.hashCode())

						if { cursor, argMatches } !?= matchArguments(leaf, cursor, argMatches, context, generics) {
							return false
						}
						// echo(toString(result.cursor), JSON.stringify(result.argMatches), context.arguments.length)
					}
					else {
						{ cursor, argMatches } = result
					}
				}
				else {
					if { cursor, argMatches } !?= matchArguments(leaf, cursor, argMatches, context, generics) {
						// echo(null)
						return false
					}
				}
				// echo(toString(cursor), JSON.stringify(argMatches), context.arguments.length)

				return false if cursor.index + 1 < context.arguments.length || (cursor.index + 1 == context.arguments.length && cursor.used == 0)
			}

			if leaf.byNames.length > 0 {
				SyntaxException.throwNamedOnlyParameters(leaf.byNames, context.node)
			}

			var parameters = leaf.function.parameters(context.excludes)
			var positions = []

			var dyn length = 0

			var types = leaf.rows[0].types

			for var parameter in parameters {
				var pIndex = parameter.index()
				var mut pMatch = null

				for var type in types when type.parameter == pIndex {
					var index = if type.index >= 0 set type.index else parameters.length + type.index

					if index < argMatches.arguments.length {
						var arg = argMatches.arguments[index]
						if ?pMatch && pMatch is Array {
							// TODO
							pMatch.push(...arg:!!!(Array))

							length += arg.length
						}
						else if parameter.isVarargs() {
							if ?arg {
								pMatch = arg

								var mut l = 0

								for var a in arg:!!!(Array) {
									var argument = context.arguments[a.index]

									if argument.isSpread() {
										if ?a.element {
											l += 1
										}
										else if a is { from: Number, to: Number } {
											l += a.to - a.from
										}
										else {
											l += getLength(argument)
										}
									}
									else {
										l += 1
									}
								}

								length += Math.max(parameter.min(), l)
							}
							else {
								pMatch = []

								length += parameter.min()
							}
						}
						else {
							pMatch = arg[0]

							length += 1
						}
					}
				}

				if !?pMatch {
					if parameter.isVarargs() {
						positions.push([])
					}
					else if argMatches.precise {
						positions.push(CallMatchArgument.new())
					}
				}
				else {
					positions.push(pMatch)
				}
			}

			if leaf.function.isAsync() {
				return false unless length + 1 >= tree.min
			}
			else {
				return false unless length >= tree.min
			}

			context.found = true

			if !argMatches.precise {
				context.possibilities.pushUniq(leaf.function)

				context.matches.push(CallMatch.new(
					function: leaf.function
					positions
				))

				return false
			}
			else {
				context.matches.push(CallMatch.new(
					function: leaf.function
					positions
				))

				return true
			}
		} # }}}

		func pushCursor(cursor: Cursor, context: MatchContext, matches: CallMatchArgument[], force: Boolean = false): Cursor { # {{{
			if cursor.spread {
				if var last ?= matches.last() ;; last.index == cursor.index {
					if ?last.to {
						last.to = cursor.used + 1
					}
					else if ?last.element {
						last.from = last.element
						last.to = cursor.used + 1

						Object.delete(last, 'element')
					}

					if last.from == 0 && last.to == cursor.length {
						Object.delete(last, 'from')
						Object.delete(last, 'to')
					}
				}
				else {
					matches.push(CallMatchArgument.new(
						index: cursor.index
						element: cursor.used if cursor.length != Infinity
					))
				}

				cursor.used += 1

				return getNextCursor(cursor, context, force)
			}
			else {
				matches.push(CallMatchArgument.new(
					index: cursor.index
				))

				cursor.used += 1

				return getNextCursor(cursor, context, force)
			}
		} # }}}

		func pushUniqCallMatch(matches, newMatch): Void { # {{{
			for var { function, arguments } in matches {
				if function != newMatch.function || !Array.same(arguments, newMatch.arguments) {
					return
				}
			}

			matches.push(newMatch)
		} # }}}

		func toString(cursor: Cursor): String => `\(cursor.index),\(cursor.argument.hashCode()),\(cursor.spread),\(cursor.length),\(cursor.used)`
		func toString(cursor?): String => 'null'
	}

	namespace WithName {
		export func match(
			assessment: Assessment
			route: Route
			argumentTypes: Type[]
			nameds: NamingArgument{}
			shorthands: NamingArgument{}
			indexeds: NamingArgument[]
			generics: Type{}
			fitting: Boolean
			fittingSpread: Boolean
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult? { # {{{
			var perNames = {}

			for var function, key of route.functions {
				for var parameter, index in function.parameters() {
					var name = parameter.getExternalName()
					var type = if parameter.isVarargs() set Type.arrayOf(parameter.getArgumentType(), node.scope()) else parameter.getArgumentType()
					var positional = parameter.isOnlyPositional()

					if var parameters ?= perNames[name] {
						parameters.push({
							function: key
							type
							index
							positional
						})
					}
					else {
						perNames[name] = [{
							function: key
							type
							index
							positional
						}]
					}
				}
			}

			var mut possibleFunctions: Array = Object.keys(route.functions)
			var preciseness = {}
			var excludes = Object.keys(nameds)

			for var key in possibleFunctions {
				preciseness[key] = true
			}

			for var argument, name of nameds {
				if var parameters ?= perNames[name] {
					var argumentType = if argument.property set argumentTypes[argument.index].getProperty(argument.name) else argumentTypes[argument.index]
					var matchedFunctions = []

					for var { function, type, positional } in parameters {
						SyntaxException.throwPositionalOnlyParameter(name, node) if positional

						var mut fullType = type
						var mut fullMatch = false

						if fullType.isDeferrable() {
							{ type % fullType, match % fullMatch } = fullType.matchDeferred(argumentType.discardValue(), generics)
						}

						if fullMatch || node.isMisfit() || isPreciseMatch(argumentType, fullType) {
							matchedFunctions.pushUniq(function)
						}
						else if argument.fitting && fullType.isAssignableToVariable(argumentType, true, false, false) {
							matchedFunctions.pushUniq(function)
						}
						else if isUnpreciseMatch(argumentType, fullType) {
							matchedFunctions.pushUniq(function)

							preciseness[function] = false
						}
					}

					possibleFunctions = possibleFunctions:!!!(Array).intersection(matchedFunctions)

					if !?#possibleFunctions {
						return null
					}
				}
				else {
					return null
				}
			}

			if ?#shorthands {
				var perFunctions = {}

				for var function in possibleFunctions {
					perFunctions[function] = {
						preciseness: preciseness[function]
						shorthands: {}
						indexeds: []
					}
				}

				for var argument, name of shorthands {
					if var parameters ?= perNames[name] {
						var argumentType = argumentTypes[argument.index]

						var mut matched = false

						for var function in possibleFunctions {
							if var { type } ?= parameters.find((data, _, _) => !data.positional && data.function == function) {
								var mut fullType = type
								var mut fullMatch = false

								if fullType.isDeferrable() {
									{ type % fullType, match % fullMatch } = fullType.matchDeferred(argumentType.discardValue(), generics)
								}

								if fullMatch || argument.fitting || isPreciseMatch(argumentType, fullType) {
									matched = true

									perFunctions[function].shorthands[name] = argument
								}
								else if isUnpreciseMatch(argumentType, fullType) {
									matched = true

									perFunctions[function].shorthands[name] = argument
									perFunctions[function].preciseness = false
								}
								else {
									perFunctions[function].indexeds.push(argument)
								}
							}
							else {
								perFunctions[function].indexeds.push(argument)
							}
						}

						if !matched {
							indexeds.push(argument)
						}
					}
					else {
						indexeds.push(argument)
					}
				}

				var perArguments = {}
				for var function, key of perFunctions {
					var hash = Object.keys(function.shorthands).join()

					if hash.length > 0 {
						if var perArgument ?= perArguments[hash] {
							perArgument.functions.push(key)
							perArgument.preciseness[key] = function.preciseness
						}
						else {
							perArguments[hash] = {
								functions: [key]
								preciseness: {
									[key]: function.preciseness
								}
								shorthands: function.shorthands
								indexeds: function.indexeds
							}
						}
					}
				}

				if ?#perArguments {
					for var perArgument of perArguments {
						var newIndexeds = [...indexeds]

						for var argument in perArgument.indexeds {
							newIndexeds.pushUniq(argument)
						}

						if var result ?= matchIndex(
							assessment
							route
							argumentTypes
							nameds
							perArgument.shorthands
							newIndexeds
							perArgument.functions
							perArgument.preciseness
							[...excludes, ...Object.keys(perArgument.shorthands)]
							{...generics}
							fitting
							fittingSpread
							mode
							node
						) {
							return result
						}
					}

					var newIndexeds = [...indexeds]
					for var argument of shorthands {
						newIndexeds.pushUniq(argument)
					}

					return matchIndex(
						assessment
						route
						argumentTypes
						nameds
						{}
						newIndexeds
						possibleFunctions
						preciseness
						excludes
						generics
						fitting
						fittingSpread
						mode
						node
					)
				}
				else {
					return matchIndex(
						assessment
						route
						argumentTypes
						nameds
						{}
						indexeds
						possibleFunctions
						preciseness
						excludes
						generics
						fitting
						fittingSpread
						mode
						node
					)
				}
			}
			else {
				return matchIndex(
					assessment
					route
					argumentTypes
					nameds
					shorthands
					indexeds
					possibleFunctions
					preciseness
					excludes
					generics
					fitting
					fittingSpread
					mode
					node
				)
			}
		} # }}}

		func getMostPreciseFunction(mut functions: FunctionType[], nameds: NamingArgument{}, shorthands: NamingArgument{}): FunctionType { # {{{
			for var parameter in functions[0].parameters() {
				var name = parameter.getExternalName()

				if ?nameds[name] || ?shorthands[name] {
					var types = []
					var perType = {}

					for var function in functions {
						for var param in function.parameters() {
							if param.getExternalName() == name {
								types.push(param.type())

								var key = param.type().hashCode()

								if var funcs ?= perType[key] {
									funcs.push(function)
								}
								else {
									perType[key] = [function]
								}

								break
							}
						}
					}

					var sorted = sortNodes(types)

					functions = perType[sorted[0]]
				}

				if functions.length == 1 {
					return functions[0]
				}
			}

			throw NotSupportedException.new()
		} # }}}

		func matchIndex(
			assessment: Assessment
			route: Route
			argumentTypes: Type[]
			nameds: NamingArgument{}
			shorthands: NamingArgument{}
			indexeds: NamingArgument[]
			mut possibleFunctions: []
			preciseness: {}
			excludes: String[]
			generics: Type{}
			fitting: Boolean
			fittingSpread: Boolean
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult? { # {{{
			if !?#indexeds {
				possibleFunctions = possibleFunctions.filter((key, _, _) => route.functions[key].min(excludes) == 0)

				if !?#possibleFunctions {
					return null
				}

				var preciseFunctions = possibleFunctions.filter((key, _, _) => preciseness[key])

				if #preciseFunctions == #possibleFunctions && (fitting -> #possibleFunctions == 1) {
					var mut max = Infinity

					for var key in preciseFunctions {
						var m = route.functions[key].max()

						if m < max {
							max = m
						}
					}

					var shortestFunctions = preciseFunctions.filter((key, _, _) => route.functions[key].max() == max)
					var function = getMostPreciseFunction([route.functions[key] for var key in shortestFunctions], nameds, shorthands)
					var positions = []

					var mut namedLefts = Object.length(nameds) + Object.length(shorthands)

					for var parameter in function.parameters() {
						var name = parameter.getExternalName()

						if var argument ?= nameds[name] {
							var arg = CallMatchArgument.new(argument.index)

							if argument.property {
								arg.property = argument.name
							}

							positions.push(arg)
							namedLefts -= 1
						}
						else if var argument ?= shorthands[name] {
							positions.push(CallMatchArgument.new(argument.index))
							namedLefts -= 1
						}
						else {
							if namedLefts > 0 {
								positions.push(CallMatchArgument.new())
							}
						}
					}

					return PreciseCallMatchResult.new(matches: [CallMatch.new(function, positions)])
				}
				else {
					var possibilities = []
					var mut rearrange = false
					var mut positions = []
					var mut labels = {}

					for var key in possibleFunctions {
						var function = route.functions[key]
						var newPositions = []
						var newLabels = {}

						var mut namedLefts = Object.length(nameds) + Object.length(shorthands)

						for var parameter, index in function.parameters() {
							var name = parameter.getExternalName()

							if parameter.isOnlyLabeled() {
								if var argument ?= nameds[name] {
									newLabels[name] = argument.index
									namedLefts -= 1
								}
								else if var argument ?= shorthands[name] {
									newLabels[name] = argument.index
									namedLefts -= 1
								}
							}
							else {
								if var argument ?= nameds[name] {
									var arg = CallMatchArgument.new(argument.index)

									if argument.property {
										arg.property = argument.name
									}

									newPositions.push(arg)

									namedLefts -= 1
								}
								else if var argument ?= shorthands[name] {
									newPositions.push(CallMatchArgument.new(argument.index))
									namedLefts -= 1
								}
								else {
									if namedLefts > 0 {
										newPositions.push(CallMatchArgument.new())
									}
								}
							}
						}

						if !rearrange {
							rearrange = true
							positions = newPositions
							labels = newLabels
						}
						else if !isSamePositions(positions, newPositions) {
							throw NotSupportedException.new()
						}

						possibilities.push(function)
					}

					return LenientCallMatchResult.new(possibilities, positions, labels)
				}
			}
			else {
				indexeds.sort((a, b) => a.index - b.index)

				var arguments = [argumentTypes[index] for var { index } in indexeds]
				var functions = [assessment.functions[key] for var key in possibleFunctions]
				var newRoute = Build.getRoute(assessment, excludes, functions, node)

				if #indexeds == #argumentTypes {
					return matchArguments(assessment, newRoute, arguments, excludes, indexeds, generics, fitting, fittingSpread, mode, node)
				}
				else {
					match var result = matchArguments(assessment, newRoute, arguments, excludes, indexeds, generics, fitting, fittingSpread, mode, node) {
						is PreciseCallMatchResult {
							var precise = possibleFunctions.every((key, _, _) => preciseness[key])

							if mode == .AllMatches {
								for var m in result.matches {
									resolveCurryMatch(m, nameds, shorthands)
								}

								if precise {
									return result
								}
								else {
									var possibilities = [result.matches[0].function]

									return LenientCallMatchResult.new(possibilities, matches: result.matches)
								}
							}
							else if precise {
								for var m in result.matches {
									resolveCallMatch(m, nameds, shorthands, arguments, true)
								}

								return result
							}
							else {
								var possibilities = [result.matches[0].function]

								return LenientCallMatchResult.new(possibilities)
							}
						}
						is LenientCallMatchResult {
							if result.possibilities.length == 1 {
								if result.matches.length == 1 {
									var m = result.matches[0]

									if !resolveCallMatch(m, nameds, shorthands, arguments, false) {
										return null
									}

									var possibilities = [m.function]

									return LenientCallMatchResult.new(possibilities, m.positions)
								}
								else if ?#result.positions || ?#result.labels {
									throw NotImplementedException.new()
								}
								else {
									var function = result.possibilities[0]
									result.positions = []
									result.labels = {}

									var mut namedLefts = excludes.length
									var mut requiredLefts = 0

									for var parameter in function.parameters(excludes) {
										if parameter.min() > 0 {
											requiredLefts += 1
										}
									}

									var mut lastIndexed = null

									for var parameter, index in function.parameters() {
										var name = parameter.getExternalName()

										if parameter.isOnlyLabeled() {
											if var argument ?= nameds[name] {
												result.labels[name] = argument.index
												namedLefts -= 1
												lastIndexed = null
											}
											else if var argument ?= shorthands[name] {
												result.labels[name] = argument.index
												namedLefts -= 1
												lastIndexed = null
											}
										}
										else {
											if var argument ?= nameds[name] {
												result.positions.push(CallMatchArgument.new(
													index: argument.index
													property: argument.name if argument.property
												))

												namedLefts -= 1
												lastIndexed = null
											}
											else if var argument ?= shorthands[name] {
												result.positions.push(CallMatchArgument.new(argument.index))
												namedLefts -= 1
												lastIndexed = null
											}
											else if parameter.min() >= 1 {
												var argument = indexeds.shift()

												if argument.type.isSpread() {
													indexeds.unshift(argument)
												}

												result.positions.push(CallMatchArgument.new(argument.index))

												requiredLefts -= 1

												lastIndexed = null
												arguments.shift()
											}
											else if arguments.length > requiredLefts {
												var argument = indexeds.shift()

												result.positions.push(CallMatchArgument.new(argument.index))

												lastIndexed = arguments.shift()
											}
											else {
												if namedLefts > 0 {
													if ?lastIndexed && lastIndexed.isAssignableToVariable(parameter.type(), true, true, false, true) {
														ReferenceException.throwConfusingArguments(assessment.name, node)
													}
													else {
														result.positions.push(CallMatchArgument.new())
													}
												}
											}
										}
									}

									if indexeds.length > 0 {
										if indexeds.length == 1 && indexeds[0].type.isSpread() {
											pass
										}
										else {
											throw NotSupportedException.new()
										}
									}
									if arguments.length > 0 {
										throw NotSupportedException.new()
									}
								}

								return result
							}
							else {
								return result
							}
						}
						else {
							return null
						}
					}
				}
			}
		} # }}}

		func resolveCallMatch(#[overwrite] match: CallMatch, nameds: NamingArgument{}, shorthands: NamingArgument{}, arguments: Type[], precise: Boolean): Boolean { # {{{
			var indexes = {}
			var positions = []
			var lefts = []
			var mut latest: Type? = null

			for var parameter, index in match.function.parameters() {
				var name = parameter.getExternalName()

				if var argument ?= nameds[name] {
					var mut fill = true

					if !precise && ?latest {

						for var left in lefts while fill {
							if isUnpreciseMatch(latest, left.type()) {
								fill = false
							}

							if isUnpreciseMatch(argument.type, left.type()) {
								return false
							}
						}
					}

					if fill {
						while positions.length + 1 <= index {
							positions.push(CallMatchArgument.new())
						}
					}

					positions.push(CallMatchArgument.new(
						index: argument.index
						property: argument.name if argument.property
					))

					indexes[argument.index] = true
					latest = null
				}
				else if var argument ?= shorthands[name] {
					var mut fill = true

					if !precise && ?latest {
						for var left in lefts while fill {
							if isUnpreciseMatch(latest, left.type()) {
								fill = false
							}

							if isUnpreciseMatch(argument.type, left.type()) {
								return false
							}
						}
					}

					if fill {
						while positions.length + 1 <= index {
							positions.push(CallMatchArgument.new())
						}
					}

					positions.push(CallMatchArgument.new(argument.index))

					indexes[argument.index] = true
					latest = null
				}
				else if var mut position ?= match.positions.shift() {
					latest = null

					if position is Array {
						var args = []
						var currents = {}

						for var argument in position {
							var mut current = argument.index

							if current !?= currents[argument.index] {
								while indexes[current] {
									current += 1
								}

								currents[argument.index] = current
								indexes[current] = true
							}

							argument.index = current

							args.push(argument)
						}

						positions.push(args)
					}
					else if ?position.index {
						if parameter.min() == 0 {
							latest = arguments[position.index]
						}

						while indexes[position.index] {
							position.index += 1
						}

						positions.push(position)

						indexes[position.index] = true
					}
					else {
						positions.push(position)
					}
				}
				else {
					lefts.push(parameter)
				}
			}

			match.positions = positions

			return true
		} # }}}

		func resolveCurryMatch(#[overwrite] match: CallMatch, nameds: NamingArgument{}, shorthands: NamingArgument{}): Void { # {{{
			var indexes = {}
			var positions = []
			var mut shift = 0

			for var parameter in match.function.parameters() {
				var name = parameter.getExternalName()

				if var argument ?= nameds[name] {
					positions.push(CallMatchArgument.new(
						index: argument.index
						property: argument.name if argument.property
					))

					indexes[argument.index] = 'n'
					shift += 1
				}
				else if var argument ?= shorthands[name] {
					positions.push(CallMatchArgument.new(argument.index))

					indexes[argument.index] = 's'
					shift += 1
				}
				else if var position ?= match.positions.shift() {
					if position is Array {
						var args = []
						var currents = {}

						for var pos, j in position {
							var mut index = pos.index + shift

							if index !?= currents[index] {
								while indexes[index] == 'n' | 's' {
									index += 1
								}

								currents[pos.index] = index
								indexes[index] = 'i'
							}

							pos.index = index

							args.push(pos)
						}

						positions.push(args)
					}
					else {
						var mut index = position.index + shift

						while indexes[index] == 'n' | 's' {
							index += 1
						}

						position.index = index

						positions.push(position)

						indexes[index] = 'i'
					}
				}
				else {
					positions.push(CallMatchArgument.new())
				}
			}

			match.positions = positions
		} # }}}

		func sortNodes(types: Type[]): String[] { # {{{
			if types.length == 1 {
				return [types[0].hashCode()]
			}

			var items = [{
				key: type.hashCode()
				type
				children: []
				isAny: type.isAny() || type.isNull()
			} for var type in types]

			for var node in items {
				if node.isAny {
					for var item in items when item != node {
						if !item.isAny {
							node.children.push(item)
						}
					}
				}
				else {
					for var item in items when item != node {
						if !item.isAny && item.type.isAssignableToVariable(node.type, true, true, false) {
							node.children.push(item)
						}
					}
				}
			}

			items.sort((a, b) => {
				if a.children:!!!(Array).contains(b) {
					return 1
				}
				if b.children:!!!(Array).contains(a) {
					return -1
				}

				return a.type.compareToRef(b.type)
			})

			return [item.key for var item in items]
		} # }}}
	}
}
