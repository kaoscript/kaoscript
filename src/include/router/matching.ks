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
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult { # {{{
			var combinations = splitArguments(arguments)

			if combinations.length == 1 {
				var context = MatchContext.new(
					arguments: combinations[0]
					excludes
					async: assessment.async
					indexeds
					mode
					node
				)
				var length = getLength(context.arguments) + (assessment.async ? 1 : 0)

				for var tree in route.trees {
					if length != Infinity && (length < tree.min || 0 < tree.max < length) {
						continue
					}

					WithIndex.match(tree, context, generics)

					if mode == .BestMatch && context.found && ?#context.matches && !?#context.possibilities {
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
						if length != Infinity && (length < tree.min || 0 < tree.max < length) {
							continue
						}

						WithIndex.match(tree, context, generics)

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
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult { # {{{
			var combinations = splitArguments(arguments)

			var results = []

			for var combination in combinations {
				match var result = WithName.match(assessment, route, combination, nameds, shorthands, [...indexeds], generics, mode, node) {
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

		func prepare(argument, index, nameds, shorthands, indexeds, invalids, mut namedCount, mut shortCount) { # {{{
			match argument {
				is NamedArgument {
					var name = argument.name()

					if ?nameds[name] {
						throw NotSupportedException.new()
					}

					nameds[name] = NamingArgument.new(
						index
						name
						type: argument.type()
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
							index
							type: argument.type()
							strict: false
						))
					}
					else if !?nameds[name] && !?invalids[name] {
						if ?shorthands[name] {
							invalids[name] = true

							indexeds.push(shorthands[name], NamingArgument.new(
								index
								type: argument.type()
								strict: false
							))

							Object.delete(shorthands, name)

							shortCount -= 1
						}
						else {
							shortCount += 1

							shorthands[name] = NamingArgument.new(
								index
								name
								type: argument.type()
								strict: false
							)
						}
					}
					else {
						indexeds.push(NamingArgument.new(
							index
							type: argument.type()
							strict: false
						))
					}
				}
				else {
					indexeds.push(NamingArgument.new(
						index
						type: argument.type()
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
				length += argument.length():!(Number)
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

				for var k, index in a {
					return false unless isSameArgument(k, b[index])
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

	func splitArguments(types: Type[]): Type[][] { # {{{
		var mut combinations = [[]]

		for var type in types {
			if type.isSpread() {
				// TODO split by properties if array
				var parameters = splitArguments([getSpreadParameter(type)])

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
					for var type in type.discardAlias().types() {
						var combination = [...oldCombination!?]

						if type.isNullable() && !(type.isAny() || type.isNull()) {
							combination.push(type.setNullable(false))

							nullable = true
						}
						else {
							combination.push(type)
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

			// TODO add methods
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
					var cursor = getCursor(0, context.arguments)

					if cursor.argument.isUnion() {
						var newContext = duplicateContext(context)

						for var type in cursor.argument.discardAlias().types() {
							var mut nf = true

							for var key in tree.order while nf {
								if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor, type), Matches.new(), newContext, generics) {
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

							for var match in newContext.matches {
								pushUniqCallMatch(context.matches, match)
							}
						}
					}
					else {
						for var key in tree.order {
							// echo('---', key)
							if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor), Matches.new(), context, generics) {
								return
							}
						}
					}
				}
			} # }}}

			func matchArguments(
				node: TreeColumn
				arguments: Type[]
				mut cursor: Cursor
				argMatches: Matches
				context: MatchContext
				generics: Type{}
			): { cursor: Cursor, argMatches: Matches }? { # {{{
				var last = arguments.length - 1

				if node.min == 0 && cursor.index > last {
					argMatches.arguments.push([])

					return { cursor, argMatches }
				}

				if node.max == 1 {
					if cursor.spread {
						if cursor.argument.isPlaceholder() {
							cursor.used += 1

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

							cursor = getNextCursor(cursor, arguments)

							return { cursor, argMatches }
						}

						var argument = getSpreadParameter(cursor.argument)

						if isPreciseMatch(argument, node.type) {
							argMatches.precise = cursor.length != Infinity

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index, element: cursor.used)])

							cursor.used += 1

							cursor = getNextCursor(cursor, arguments)

							return { cursor, argMatches }
						}
						else if isUnpreciseMatch(argument, node.type) {
							argMatches.precise = false

							cursor.used += 1

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index, element: cursor.used)])

							cursor = getNextCursor(cursor, arguments)

							return { cursor, argMatches }
						}
					}
					else {
						var mut fullType = node.type
						var mut fullMatch = false

						if fullType.isDeferrable() {
							{ type % fullType, match % fullMatch } = fullType.matchDeferred(cursor.argument.discardValue(), generics)
						}
						// echo(node.type.hashCode(), fullType.hashCode(), cursor.argument.hashCode(), fullMatch)

						if fullMatch || isPreciseMatch(cursor.argument, fullType) {
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

								cursor = getNextCursor(cursor, arguments)

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

									cursor = getNextCursor(cursor, arguments)

									return { cursor, argMatches }
								}
							}
							else if fullType.isSubsetOf(cursor.argument, mode) {
								value.type(fullType)

								cursor.used += 1

								argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

								cursor = getNextCursor(cursor, arguments)

								return { cursor, argMatches }
							}
						}

						if isUnpreciseMatch(cursor.argument, fullType) {
							argMatches.precise = false

							cursor.used += 1

							argMatches.arguments.push([CallMatchArgument.new(index: cursor.index)])

							cursor = getNextCursor(cursor, arguments)

							return { cursor, argMatches }
						}
					}

					if cursor.length == Infinity {
						if cursor.used == 0 {
							return null
						}

						cursor = getNextCursor(cursor, arguments, true)

						if cursor.index < arguments.length {
							argMatches.precise = false

							return matchArguments(node, arguments, cursor, argMatches, context)
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
						var argument = cursor.spread ? getSpreadParameter(cursor.argument) : cursor.argument

						if isPreciseMatch(argument, node.type) {
							if cursor.used + 1 > getMinParameter(cursor.argument) {
								argMatches.precise = false
							}
						}
						else if isUnpreciseMatch(argument, node.type) {
							argMatches.precise = false
						}
						else {
							return null
						}

						i += 1

						cursor = pushCursor(cursor, arguments, matches)
					}

					if node.max <= 0 {
						var last = Math.min(arguments.length - 1, cursor.index + arguments.length - 1 + node.max)

						if cursor.index <= last {
							while cursor.index <= last {
								if cursor.argument is not PlaceholderType {
									var argument = cursor.spread ? getSpreadParameter(cursor.argument) : cursor.argument

									if isPreciseMatch(argument, node.type) {
										pass
									}
									else if isUnpreciseMatch(argument, node.type) {
										argMatches.precise = false
									}
									else {
										break
									}
								}

								i += 1

								cursor = pushCursor(cursor, arguments, matches, cursor.index == last || cursor.spread && cursor.length == Infinity)
							}
						}
						else {
							if 0 < cursor.used <= cursor.length {
								var mut match = true

								if cursor.argument is not PlaceholderType {
									var argument = cursor.spread ? getSpreadParameter(cursor.argument) : cursor.argument

									if isPreciseMatch(argument, node.type) {
										pass
									}
									else if isUnpreciseMatch(argument, node.type) {
										argMatches.precise = false
									}
									else {
										match = false
									}
								}

								if match {
									if node.max == Infinity {
										matches.push(CallMatchArgument.new(index: cursor.index, from: cursor.used))

										cursor = getNextCursor(cursor, arguments, true)
									}
									else {
										var to = cursor.length + node.max + cursor.used - 1

										matches.push(CallMatchArgument.new(
											index: cursor.index
											from: cursor.used
											:to if to + 1 < cursor.length
										))

										cursor.used += 1 - node.max

										cursor = getNextCursor(cursor, arguments)
									}

									if cursor.spread && cursor.argument is PlaceholderType {
										matches.push(CallMatchArgument.new(index: cursor.index))

										cursor = getNextCursor(cursor, arguments, true)
									}
								}
							}
						}
					}
					else {
						while i < node.max && cursor?.index <= last {
							var argument = cursor.spread ? getSpreadParameter(cursor.argument) : cursor.argument

							if isPreciseMatch(argument, node.type) {
								pass
							}
							else if isUnpreciseMatch(argument, node.type) {
								argMatches.precise = false
							}
							else {
								break
							}

							i += 1

							cursor = pushCursor(cursor, arguments, matches)
						}
					}

					if cursor.spread && cursor.index == initialIndex {
						if var next ?= arguments[cursor.index + 1] ;; next.isSpread() {
							if node.max != Infinity {
								argMatches.precise = false
							}

							cursor = getNextCursor(cursor, arguments, true)
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

		func getCursor(index: Number, arguments: Type[]): Cursor { # {{{
			if index >= arguments.length {
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

		func getNextCursor(current: Cursor, arguments: Type[], force: Boolean = false): Cursor { # {{{
			if current.used >= current.length || (force && current.length != 0) {
				return getCursor(current.index + 1, arguments)
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

		func matchTreeNode(tree: Tree, branch: TreeBranch, mut cursor: Cursor, mut argMatches: Matches, context: MatchContext, generics: Type{}): Boolean { # {{{
			// echo('-- branch', toString(cursor), cursor.spread && context.mode == .AllMatches, argMatches.precise, branch.type.hashCode(), branch.min, branch.max)
			if cursor.spread && context.mode == .AllMatches  {
				if var result ?= matchArguments(branch, context.arguments, cursor, Matches.new(
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
						cursor = getNextCursor(cursor, context.arguments, true)
						// echo('branch', toString(cursor))

						if { cursor, argMatches } !?= matchArguments(branch, context.arguments, cursor, argMatches, context, generics) {
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
					cursor = getNextCursor(cursor, context.arguments, true)
					// echo('branch', toString(cursor))

					if { cursor, argMatches } !?= matchArguments(branch, context.arguments, cursor, argMatches, context, generics) {
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
				var outOfBound = cursor.index >= context.arguments.length

				if { cursor, argMatches } !?= matchArguments(branch, context.arguments, cursor, argMatches, context, generics) {
					// echo(null)
					return false
				}
				// echo(toString(cursor), JSON.stringify(argMatches), context.arguments.length)

				if !outOfBound && branch.min == 0 && cursor.index >= context.arguments.length {
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
					var result = matchArguments(leaf, context.arguments, cursor, Matches.new(
						precise: argMatches.precise
						arguments: [...argMatches.arguments]
					), context, generics)
					// echo(toString(result.cursor), JSON.stringify(result.argMatches), context.arguments.length)

					if !?result || result.cursor.index + 1 < context.arguments.length || (result.cursor.index + 1 == context.arguments.length && result.cursor.used == 0) {
						cursor = getNextCursor(cursor, context.arguments, true)
						// echo('leaf', toString(cursor), leaf.function.hashCode())

						if { cursor, argMatches } !?= matchArguments(leaf, context.arguments, cursor, argMatches, context, generics) {
							return false
						}
						// echo(toString(result.cursor), JSON.stringify(result.argMatches), context.arguments.length)
					}
					else {
						{ cursor, argMatches } = result
					}
				}
				else {
					if { cursor, argMatches } !?= matchArguments(leaf, context.arguments, cursor, argMatches, context, generics) {
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
					var index = type.index >= 0 ? type.index : parameters.length + type.index

					if index < argMatches.arguments.length {
						var arg = argMatches.arguments[index]
						if ?pMatch && pMatch is Array {
							// TODO
							pMatch.push(...arg:!(Array))

							length += arg.length
						}
						else if parameter.isVarargs() {
							if ?arg {
								pMatch = arg

								var mut l = 0

								for var a in arg:!(Array) {
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

		func pushCursor(cursor: Cursor, arguments: Type[], matches: CallMatchArgument[], force: Boolean = false): Cursor { # {{{
			// echo(cursor.spread, cursor.index, matches.last()?.index, force)
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

				return getNextCursor(cursor, arguments, force)
			}
			else {
				matches.push(CallMatchArgument.new(
					index: cursor.index
				))

				cursor.used += 1

				return getNextCursor(cursor, arguments, force)
			}
		} # }}}

		func pushUniqCallMatch(matches, newMatch): Void { # {{{
			for var match in matches {
				if match.function != newMatch.function || !Array.same(match.arguments, newMatch.arguments) {
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
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult? { # {{{
			var perNames = {}

			for var function, key of route.functions {
				for var parameter, index in function.parameters() {
					var name = parameter.getExternalName()
					var type = parameter.type()
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
					var argumentType = argumentTypes[argument.index]
					var matchedFunctions = []

					for var { function, type, positional } in parameters {
						if isPreciseMatch(argumentType, type) {
							SyntaxException.throwPositionalOnlyParameter(name, node) if positional

							matchedFunctions.push(function)

						}
						else if isUnpreciseMatch(argumentType, type) {
							SyntaxException.throwPositionalOnlyParameter(name, node) if positional

							matchedFunctions.push(function)

							preciseness[function] = false
						}
					}

					var functions = possibleFunctions.intersection(matchedFunctions)

					if functions.length != 0 {
						possibleFunctions = functions
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
								if isPreciseMatch(argumentType, type) {
									matched = true

									perFunctions[function].shorthands[name] = argument
								}
								else if isUnpreciseMatch(argumentType, type) {
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
				for var { shorthands, indexeds, preciseness }, key of perFunctions {
					var hash = Object.keys(shorthands).join()

					if hash.length > 0 {
						if var perArgument ?= perArguments[hash] {
							perArgument.functions.push(key)
							perArgument.preciseness[key] = preciseness
						}
						else {
							perArguments[hash] = {
								functions: [key]
								preciseness: {
									[key]: preciseness
								}
								shorthands
								indexeds
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
							generics
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
						for var parameter in function.parameters() {
							if parameter.getExternalName() == name {
								types.push(parameter.type())

								var key = parameter.type().hashCode()

								if var types ?= perType[key] {
									types.push(function)
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
			mode: ArgumentMatchMode
			node: AbstractNode
		): CallMatchResult? { # {{{
			if !?#indexeds {
				possibleFunctions = possibleFunctions.filter((key, _, _) => route.functions[key].min(excludes) == 0)

				if possibleFunctions.length == 0 {
					return null
				}

				var preciseFunctions = possibleFunctions.filter((key, _, _) => preciseness[key])

				if preciseFunctions.length == possibleFunctions.length {
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
							positions.push(CallMatchArgument.new(argument.index))
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

					var match = CallMatch.new(
						function
						positions
					)

					return PreciseCallMatchResult.new(matches: [match])
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
									newPositions.push(CallMatchArgument.new(argument.index))
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

				var route = Build.getRoute(assessment, excludes, functions, node)

				if indexeds.length == argumentTypes.length {
					return matchArguments(assessment, route, arguments, excludes, indexeds, generics, mode, node)
				}
				else {
					match var result = matchArguments(assessment, route, arguments, excludes, indexeds, generics, mode, node) {
						is PreciseCallMatchResult {
							var precise = possibleFunctions.every((key, _, _) => preciseness[key])

							if mode == .AllMatches {
								for var match in result.matches {
									resolveCurryMatch(match, nameds, shorthands)
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
								for var match in result.matches {
									resolveCallMatch(match, nameds, shorthands, arguments, true)
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
									var match = result.matches[0]

									if !resolveCallMatch(match, nameds, shorthands, arguments, false) {
										return null
									}

									var possibilities = [match.function]

									return LenientCallMatchResult.new(possibilities, match.positions)
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
												result.positions.push(CallMatchArgument.new(argument.index))
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

		func resolveCallMatch(match: CallMatch, nameds: NamingArgument{}, shorthands: NamingArgument{}, arguments: Type[], precise: Boolean): Boolean { # {{{
			var indexes = {}
			var positions = []
			var lefts = []
			var mut latest: Type? = null

			for var parameter, index in match.function.parameters() {
				var name = parameter.getExternalName()

				if var argument ?= nameds[name] {
					var mut fill = true

					if !precise && ?latest {

						for var left, index in lefts while fill {
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
				else if var argument ?= shorthands[name] {
					var mut fill = true

					if !precise && ?latest {
						for var left, index in lefts while fill {
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

		func resolveCurryMatch(match: CallMatch, nameds: NamingArgument{}, shorthands: NamingArgument{}): Void { # {{{
			var indexes = {}
			var positions = []
			var mut shift = 0

			for var parameter in match.function.parameters() {
				var name = parameter.getExternalName()

				if var argument ?= nameds[name] {
					positions.push(CallMatchArgument.new(argument.index))

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
				if a.children:!(Array).contains(b) {
					return 1
				}
				if b.children:!(Array).contains(a) {
					return -1
				}

				return a.type.compareToRef(b.type)
			})

			return [item.key for var item in items]
		} # }}}
	}
}
