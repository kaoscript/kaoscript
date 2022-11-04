namespace Matching {
	struct Matches {
		precise: Boolean					= true
		arguments: Array<CallMatchArgument>	= []
	}

	export {
		func matchArguments(
			assessment: Assessment
			route: Route
			// TODO active element testing
			// arguments: Type[]
			arguments: Array
			excludes: String[]
			indexeds: NamingArgument[]
			node: AbstractNode
		): CallMatchResult? { # {{{
			var combinations = splitArguments(arguments)

			if combinations.length == 1 {
				var context = MatchContext(combinations[0], excludes, async: assessment.async, indexeds, node)

				for var tree in route.trees {
					WithIndex.match(tree, context)

					if context.found && context.matches.length > 0 && context.possibilities.length == 0 {
						return PreciseCallMatchResult(context.matches)
					}
				}

				if context.found {
					for var { function } in context.matches {
						context.possibilities.pushUniq(function)
					}

					return LenientCallMatchResult(context.possibilities)
				}
			}
			else {
				var results = []

				for var combination in combinations {
					var context = MatchContext(combination, excludes, async: assessment.async, indexeds, node)

					var mut nf = true

					for var tree in route.trees while nf {
						WithIndex.match(tree, context)

						if context.found && context.matches.length > 0 && context.possibilities.length == 0 {
							results.push(PreciseCallMatchResult(context.matches))

							nf = false
						}
					}

					if context.found {
						if nf {
							for var { function } in context.matches {
								context.possibilities.pushUniq(function)
							}

							results.push(LenientCallMatchResult(context.possibilities))
						}
					}
					else {
						return null
					}
				}

				return mergeResults(results)
			}

			return null
		} # }}}

		func matchArguments(
			assessment: Assessment
			route: Route
			arguments: Type[]
			nameds: NamingArgument{}
			shorthands: NamingArgument{}
			indexeds: NamingArgument[]
			exhaustive: Boolean
			node: AbstractNode
		): CallMatchResult? { # {{{
			var combinations = splitArguments(arguments)

			var results = []

			for var combination in combinations {
				if var result ?= WithName.match(assessment, route, combination, nameds, shorthands, [...indexeds], exhaustive, node) {
					results.push(result)
				}
				else {
					return null
				}
			}

			return mergeResults(results)
		} # }}}
	}

	func isPreciseMatch(argument: Type, parameter: Type): Boolean { # {{{
		// console.log(argument.hashCode(), parameter.hashCode(), argument is DictionaryType, argument.isAssignableToVariable(parameter, false, false, false))
		return argument.isAssignableToVariable(parameter, false, false, false)
	} # }}}

	func isUnpreciseMatch(argument: Type, parameter: Type): Boolean { # {{{
		if argument.isStrict() {
			return argument.isAssignableToVariable(parameter, true, false, false)
		}
		else {
			return argument.isAssignableToVariable(parameter, true, true, true)
		}
	} # }}}

	func mergeResults(results: CallMatchResult[]): CallMatchResult? { # {{{
		if results.length == 0 {
			return null
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
						if !Array.same(result.positions, match.positions) {
							precise = false
						}
					}
					else {
						perFunctions[match.function.index()] = match
					}
				}
			}

			if precise {
				return PreciseCallMatchResult([match for var match of perFunctions])
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

		return LenientCallMatchResult(possibilities)
	} # }}}

	func splitArguments(types: Type[]): Type[][] { # {{{
		var mut combinations = [[]]

		for var type in types {
			if type.isSpread() {
				var parameters = splitArguments([type.parameter()])

				if parameters.length > 1 {
					var oldCombinations = combinations

					combinations = []

					for var oldCombination in oldCombinations {
						for var parameter in parameters {
							var ref = new ReferenceType(type.scope(), type.name(), type.isNullable(), parameter).flagSpread()

							combinations.push([...oldCombination, ref])
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
						var combination = [...oldCombination]

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
						var combination = [...oldCombination, Type.Null]

						combinations.push(combination)
					}
				}
			}
			else if type.isNullable() && !(type.isAny() || type.isNull()) {
				var oldCombinations = combinations

				combinations = []

				for var oldCombination in oldCombinations {
					var combination1 = [...oldCombination, type.setNullable(false)]
					var combination2 = [...oldCombination, Type.Null]

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
			func match(tree: Tree, context: MatchContext): Void { # {{{
				if context.arguments.length == 0 {
					if context.async {
						context.found = true

						var branch = getZeroBranch(tree)
						var function = branch.function
						var parameters = function.parameters()
						var positions = []

						for var type in branch.rows[0].types til -1 {
							if parameters[type.parameter].isVarargs() {
								positions[type.parameter] = []
							}
							else {
								positions[type.parameter] = null
							}
						}

						context.matches.push(CallMatch(
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
									positions.push(null)
								}
							}

							context.matches.push(CallMatch(
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
									positions[type.parameter] = null
								}
							}

							context.matches.push(CallMatch(
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
								if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor, type), Matches(), newContext) {
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
							if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor), Matches(), context) {
								return
							}
						}
					}
				}
			} # }}}

			func matchArguments(
				node: TreeNode
				arguments: Type[]
				mut cursor: Cursor
				argMatches: Matches
				context: MatchContext
			): { cursor: Cursor?, argMatches: Matches? } { # {{{
				var last = arguments.length - 1

				if node.min == 0 && cursor.index > last {
					argMatches.arguments.push([])

					return { cursor, argMatches }
				}
				if node.min != 0 && cursor.index + node.min - 1 > last {
					return {}
				}

				if node.max == 1 {
					if cursor.spread {
						var argument = cursor.argument.parameter()

						if isPreciseMatch(argument, node.type) {
							cursor.used += 1

							argMatches.arguments.push([cursor.index])

							return { cursor, argMatches }
						}
						else if isUnpreciseMatch(argument, node.type) {
							argMatches.precise = false

							cursor.used += 1

							argMatches.arguments.push([cursor.index])

							return { cursor, argMatches }
						}
					}
					else {
						if isPreciseMatch(cursor.argument, node.type) {
							var mut matched = true

							if var value ?= getRefinableValue(cursor, context) {
								if node.type.isUnion() {
									var mode = MatchingMode::FunctionSignature + MatchingMode::IgnoreRetained
									var types = []

									for var type in node.type.types() {
										if type.isSubsetOf(cursor.argument, mode) {
											types.push(type)
										}
									}

									matched = #types

									if matched {
										value.type(Type.union(context.node.scope(), ...types))
									}
								}
								else {
									value.type(node.type)
								}
							}

							if matched {
								cursor.used += 1

								argMatches.arguments.push([cursor.index])

								cursor = getNextCursor(cursor, arguments)

								return { cursor, argMatches }
							}
						}

						if var value ?= getRefinableValue(cursor, context) {
							var mode = MatchingMode::FunctionSignature
								+ MatchingMode::AnycastParameter
								+ MatchingMode::MissingReturn
								+ MatchingMode::IgnoreRetained
								+ MatchingMode::ShiftableParameters
								+ MatchingMode::RequireAllParameters
								+ MatchingMode::IgnoreNullable

							if node.type.isUnion() {
								var types = []

								for var type in node.type.types() {
									if type.isSubsetOf(cursor.argument, mode) {
										types.push(type)
									}
								}

								if #types {
									value.type(Type.union(context.node.scope(), ...types))

									cursor.used += 1

									argMatches.arguments.push([cursor.index])

									cursor = getNextCursor(cursor, arguments)

									return { cursor, argMatches }
								}
							}
							else if node.type.isSubsetOf(cursor.argument, mode) {
								value.type(node.type)

								cursor.used += 1

								argMatches.arguments.push([cursor.index])

								cursor = getNextCursor(cursor, arguments)

								return { cursor, argMatches }
							}
						}

						if isUnpreciseMatch(cursor.argument, node.type) {
							argMatches.precise = false

							cursor.used += 1

							argMatches.arguments.push([cursor.index])

							cursor = getNextCursor(cursor, arguments)

							return { cursor, argMatches }
						}
					}

					if cursor.length == Infinity {
						argMatches.precise = false

						return matchArguments(node, arguments, getNextCursor(cursor, arguments, true), argMatches, context)
					}

					if node.min == 0 {
						argMatches.arguments.push([])

						return { cursor, argMatches }
					}
					else {
						return {}
					}
				}
				else {
					var mut i = 0

					var matches = []

					while i < node.min {
						if cursor.spread {
							if cursor.argument.parameter().isAssignableToVariable(node.type) {
								cursor.used += 1

								matches.push(cursor.index)

								argMatches.arguments.push(matches)

								return { cursor, argMatches }
							}
							else {
								return {}
							}
						}
						else {
							if !cursor.argument.isAssignableToVariable(node.type, true, false, false) {
								return {}
							}
						}

						i += 1
						cursor.used += 1

						matches.push(cursor.index)

						cursor = getNextCursor(cursor, arguments)
					}

					if node.max <= 0 {
						var last = Math.min(arguments.length - 1, cursor.index + arguments.length - 1 + node.max)

						while cursor.index <= last {
							if cursor.argument.isSpread() {
								if !cursor.argument.parameter(0).isAssignableToVariable(node.type, true, false, false) {
									break
								}
							}
							else if !cursor.argument.isAssignableToVariable(node.type, true, false, false) {
								break
							}

							i += 1
							cursor.used += 1

							matches.push(cursor.index)

							if cursor.argument.isSpread() {
								cursor = getNextCursor(cursor, arguments, true)
							}
							else {
								cursor = getNextCursor(cursor, arguments)
							}
						}
					}
					else {
						while i < node.max && cursor?.index <= last {
							if !cursor.argument.isAssignableToVariable(node.type, true, false, false) {
								break
							}

							i += 1
							cursor.used += 1

							matches.push(cursor.index)

							cursor = getNextCursor(cursor, arguments)
						}
					}

					argMatches.arguments.push(matches)

					return { cursor, argMatches }
				}
			} # }}}
		}

		func duplicateContext(context: MatchContext): MatchContext { # {{{
			return MatchContext(
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
			return Cursor(
				argument: type
				index: cursor.index
				length: cursor.length
				spread: cursor.spread
				used: cursor.used
			)
		} # }}}

		func getCursor(index: Number, arguments: Type[]): Cursor { # {{{
			if index >= arguments.length {
				return Cursor(
					argument: Type.Any
					index
					length: 0
					spread: false
					used: 0
				)
			}

			var argument = arguments[index]
			var spread = argument.isSpread()

			if spread {
				return Cursor(
					argument
					index
					length: Infinity
					spread
					used: 0
				)
			}
			else {
				return Cursor(
					argument
					index
					length: 1
					spread
					used: 0
				)
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

		func matchTreeNode(tree: Tree, branch: TreeBranch, mut cursor: Cursor, mut argMatches: Matches, context: MatchContext): Boolean { # {{{
			// console.log('branch', toString(cursor))
			{ cursor, argMatches } = matchArguments(branch, context.arguments, cursor, argMatches, context)
			// console.log(toString(cursor), argMatches)
			return false if !?cursor

			for var key in branch.order {
				if matchTreeNode(tree, branch.columns[key], cursor, Matches(
					precise: argMatches.precise
					arguments: [...argMatches.arguments]
				), context) {
					return true
				}
			}

			return false
		} # }}}

		func matchTreeNode(tree: Tree, leaf: TreeLeaf, mut cursor: Cursor, mut argMatches: Matches, context: MatchContext): Boolean { # {{{
			if !leaf.function.isAsync() {
				// console.log('leaf', toString(cursor))
				{ cursor, argMatches } = matchArguments(leaf, context.arguments, cursor, argMatches, context)
				// console.log(toString(cursor), argMatches, context.arguments.length)
				return false if !?cursor || (cursor.index + 1 <= context.arguments.length && cursor.used == 0)
			}

			if leaf.byNames.length > 0 {
				SyntaxException.throwNamedOnlyParameters(leaf.byNames, context.node)
			}

			var parameters = leaf.function.parameters(context.excludes)
			var match = []

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
							pMatch.push(...arg)

							length += arg.length
						}
						else if parameter.isVarargs() {
							if ?arg {
								pMatch = arg

								length += Math.max(parameter.min(), arg.length)
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

				if !?pMatch && parameter.isVarargs() {
					pMatch = []
				}

				match.push(pMatch)
			}

			if leaf.function.isAsync() {
				return false unless length + 1 >= tree.min
			}
			else {
				return false unless length >= tree.min
			}

			context.found = true

			if !argMatches.precise || cursor.index < context.arguments.length {
				context.possibilities.pushUniq(leaf.function)

				return false
			}
			else {
				context.matches.push(CallMatch(
					function: leaf.function
					positions: match
				))

				return true
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
			exhaustive: Boolean, node: AbstractNode
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

			var mut possibleFunctions: Array = Dictionary.keys(route.functions)

			var preciseness = {}
			var excludes = Dictionary.keys(nameds)

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

					if exhaustive {
						if functions.length == 0 {
							return null
						}
						else {
							possibleFunctions = functions
						}
					}
					else {
						if functions.length != 0 {
							possibleFunctions = functions
						}
					}
				}
				else {
					return null
				}
			}

			if Dictionary.isEmpty(shorthands) {
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
					node
				)
			}
			else {
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
							if var { type } ?= parameters.find((data, _, _) => data.function == function) {
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
					var hash = Dictionary.keys(shorthands).join()

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

				if Dictionary.isEmpty(perArguments) {
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
						node
					)
				}
				else {
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
							[...excludes, ...Dictionary.keys(perArgument.shorthands)]
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
						node
					)
				}
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

			throw new NotSupportedException()
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
			node: AbstractNode
		): CallMatchResult? { # {{{
			if indexeds.length == 0 {
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

					var mut namedLefts = Dictionary.length(nameds) + Dictionary.length(shorthands)

					for var parameter in function.parameters() {
						var name = parameter.getExternalName()

						if var argument ?= nameds[name] {
							positions.push(argument.index)
							namedLefts -= 1
						}
						else if var argument ?= shorthands[name] {
							positions.push(argument.index)
							namedLefts -= 1
						}
						else {
							if namedLefts > 0 {
								positions.push(null)
							}
						}
					}

					var match = CallMatch(
						function
						positions
					)

					return PreciseCallMatchResult(matches: [match])
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

						var mut namedLefts = Dictionary.length(nameds) + Dictionary.length(shorthands)

						for var parameter in function.parameters() {
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
									newPositions.push(argument.index)
									namedLefts -= 1
								}
								else if var argument ?= shorthands[name] {
									newPositions.push(argument.index)
									namedLefts -= 1
								}
								else {
									if namedLefts > 0 {
										newPositions.push(null)
									}
								}
							}
						}

						if !rearrange {
							rearrange = true
							positions = newPositions
							labels = newLabels
						}
						else if !Array.same(positions, newPositions) {
							throw new NotSupportedException()
						}

						possibilities.push(function)
					}

					return LenientCallMatchResult(possibilities, positions, labels)
				}
			}
			else {
				indexeds.sort((a, b) => a.index - b.index)

				var arguments = [argumentTypes[index] for { index } in indexeds]
				var functions = [assessment.functions[key] for var key in possibleFunctions]

				var route = Build.getRoute(assessment, excludes, functions, node)

				if indexeds.length == argumentTypes.length {
					return matchArguments(assessment, route, arguments, excludes, indexeds, node)
				}
				else {
					if var result ?= matchArguments(assessment, route, arguments, excludes, indexeds, node) {
						if result is PreciseCallMatchResult {
							if possibleFunctions.every((key, _, _) => preciseness[key]) {
								for var match in result.matches {
									var indexes = {}
									var positions = []

									for var parameter in match.function.parameters() {
										var name = parameter.getExternalName()

										if var argument ?= nameds[name] {
											positions.push(argument.index)

											indexes[argument.index] = true
										}
										else if var argument ?= shorthands[name] {
											positions.push(argument.index)

											indexes[argument.index] = true
										}
										else if var mut index ?= match.positions.shift() {
											if index is Array {
												var args = []

												for var mut i in index {
													while indexes[i] {
														i += 1
													}

													args.push(i)

													indexes[i] = true
												}

												positions.push(args)
											}
											else {
												while indexes[index] {
													index += 1
												}

												positions.push(index)

												indexes[index] = true
											}
										}
										else {
											positions.push(null)
										}
									}

									match.positions = positions
								}

								return result
							}
							else {
								var possibilities = [result.matches[0].function]

								return LenientCallMatchResult(possibilities)
							}
						}
						else if result.possibilities.length == 1 {
							if #result.positions || #result.labels {
								throw new NotImplementedException()
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
											result.positions.push(argument.index)
											namedLefts -= 1
											lastIndexed = null
										}
										else if var argument ?= shorthands[name] {
											result.positions.push(argument.index)
											namedLefts -= 1
											lastIndexed = null
										}
										else if parameter.min() >= 1 {
											var argument = indexeds.shift()

											result.positions.push(argument.index)

											requiredLefts -= 1

											lastIndexed = null
											arguments.shift()
										}
										else if arguments.length > requiredLefts {
											var argument = indexeds.shift()

											result.positions.push(argument.index)

											lastIndexed = arguments.shift()
										}
										else {
											if namedLefts > 0 {
												if ?lastIndexed && lastIndexed.isAssignableToVariable(parameter.type(), true, true, false, true) {
													ReferenceException.throwConfusingArguments(assessment.name, node)
												}
												else {
													result.positions.push(null)
												}
											}
										}
									}
								}

								if arguments.length > 0 {
									throw new NotSupportedException()
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
				if a.children:Array.contains(b) {
					return 1
				}
				if b.children:Array.contains(a) {
					return -1
				}

				return a.type.compareToRef(b.type)
			})

			return [item.key for var item in items]
		} # }}}
	}
}
