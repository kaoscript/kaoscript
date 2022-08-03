struct ArgCursor {
	argument: Type
	index: Number
	length: Number
	spread: Boolean
	used: Number
}

struct ArgMatches {
	precise: Boolean					= true
	arguments: Array<CallMatchArgument>	= []
}

func getCursor(index: Number, arguments: Array<Type>): ArgCursor { # {{{
	if index >= arguments.length {
		return ArgCursor(
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
		return ArgCursor(
			argument
			index
			length: Infinity
			spread
			used: 0
		)
	}
	else {
		return ArgCursor(
			argument
			index
			length: 1
			spread
			used: 0
		)
	}
} # }}}

func getNextCursor(current: ArgCursor, arguments: Array<Type>, force: Boolean = false): ArgCursor { # {{{
	if current.used >= current.length || (force && current.length != 0) {
		return getCursor(current.index + 1, arguments)
	}
	else {
		return current
	}
} # }}}

func toString(cursor: ArgCursor): String => `\(cursor.index),\(cursor.argument.hashCode()),\(cursor.spread),\(cursor.length),\(cursor.used)`
func toString(cursor?): String => 'null'

func matchTree(tree: Tree, context: MatchContext): Void { # {{{
	if context.arguments.length == 0 {
		if context.async {
			context.found = true

			var branch = getZeroBranch(tree)
			var function = branch.function
			var parameters = function.parameters()
			var arguments = []

			for var type in branch.rows[0].types til -1 {
				if parameters[type.parameter].isVarargs() {
					arguments[type.parameter] = []
				}
				else {
					arguments[type.parameter] = null
				}
			}

			context.matches.push(CallMatch(
				function
				arguments
			))
		}
		else {
			return if tree.min > 0

			context.found = true

			if tree.order.length == 0 {
				var function = tree.function
				var parameters = function.parameters()
				var arguments = []

				for var parameter in parameters {
					if parameter.isVarargs() {
						arguments.push([])
					}
					else {
						arguments.push(null)
					}
				}

				context.matches.push(CallMatch(
					function
					arguments
				))
			}
			else {
				var branch = getZeroBranch(tree)
				var function = branch.function
				var parameters = function.parameters()
				var arguments = []

				for var type in branch.rows[0].types {
					if parameters[type.parameter].isVarargs() {
						arguments[type.parameter] = []
					}
					else {
						arguments[type.parameter] = null
					}
				}

				context.matches.push(CallMatch(
					function
					arguments
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
					if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor, type), ArgMatches(), newContext) {
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
				if matchTreeNode(tree, tree.columns[key], duplicateCursor(cursor), ArgMatches(), context) {
					return
				}
			}
		}
	}
} # }}}

func pushUniqCallMatch(matches, newMatch) { # {{{
	for var match in matches {
		if match.function != newMatch.funcion || match.arguments.length != newMatch.arguments.length {
			return
		}

		for var value, index in newMatch.arguments {
			if match.arguments[index] != value {
				return
			}
		}
	}

	matches.push(newMatch)
} # }}}

func duplicateContext(context: MatchContext) { # {{{
	return MatchContext(
		async: context.async
		found: false
		arguments: context.arguments
		excludes: context.excludes
		matches: []
		possibilities: []
	)
} # }}}

func duplicateCursor(cursor: ArgCursor, type: Type = cursor.argument) { # {{{
	return ArgCursor(
		argument: type
		index: cursor.index
		length: cursor.length
		spread: cursor.spread
		used: cursor.used
	)
} # }}}

func getZeroBranch(tree: Tree | TreeBranch) { # {{{
	var column = tree.columns[tree.order.last()]

	if column.isNode {
		return getZeroBranch(column)
	}
	else {
		return column
	}
} # }}}

func matchTreeNode(tree: Tree, branch: TreeBranch, mut cursor: ArgCursor, mut argMatches: ArgMatches, context: MatchContext): Boolean { # {{{
	{ cursor, argMatches } = matchArguments(branch, context.arguments, cursor, argMatches)
	return false if !?cursor

	for var key in branch.order {
		if matchTreeNode(tree, branch.columns[key], cursor, ArgMatches(
			precise: argMatches.precise
			arguments: [...argMatches.arguments]
		), context) {
			return true
		}
	}

	return false
} # }}}

func matchTreeNode(tree: Tree, leaf: TreeLeaf, mut cursor: ArgCursor, mut argMatches: ArgMatches, context: MatchContext): Boolean { # {{{
	if !leaf.function.isAsync() {
		{ cursor, argMatches } = matchArguments(leaf, context.arguments, cursor, argMatches)
		return false if !?cursor || (cursor.index + 1 <= context.arguments.length && cursor.used == 0)
	}

	var parameters = leaf.function.parameters(context.excludes)
	var match = []

	var dyn length = 0

	var types = leaf.rows[0].types

	for var parameter, pIndex in parameters {
		var mut pMatch = null

		for var type in types when type.parameter == pIndex {
			var index = type.index >= 0 ? type.index : parameters.length + type.index

			if index < argMatches.arguments.length {
				var arg = argMatches.arguments[index]

				if pMatch? && pMatch is Array {
					pMatch.push(...arg)

					length += arg.length
				}
				else if parameter.isVarargs() {
					if arg? {
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

					++length
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
			arguments: match
		))

		return true
	}
} # }}}

func matchArguments(node: TreeNode, arguments: Array<Type>, mut cursor: ArgCursor, argMatches: ArgMatches): { cursor: ArgCursor?, argMatches: ArgMatches? } { # {{{
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

			if argument.isAssignableToVariable(node.type, false, false, false) {
				++cursor.used

				argMatches.arguments.push([cursor.index])

				return { cursor, argMatches }
			}
			else if argument.isAssignableToVariable(node.type, true, true, false) {
				argMatches.precise = false

				++cursor.used

				argMatches.arguments.push([cursor.index])

				return { cursor, argMatches }
			}
		}
		else {
			if cursor.argument.isAssignableToVariable(node.type, false, false, false) {
				++cursor.used

				argMatches.arguments.push([cursor.index])

				cursor = getNextCursor(cursor, arguments)

				return { cursor, argMatches }
			}
			else if cursor.argument.isAssignableToVariable(node.type, true, false, false) {
				argMatches.precise = false

				++cursor.used

				argMatches.arguments.push([cursor.index])

				cursor = getNextCursor(cursor, arguments)

				return { cursor, argMatches }
			}
		}

		if cursor.length == Infinity {
			argMatches.precise = false

			return matchArguments(node, arguments, getNextCursor(cursor, arguments, true), argMatches)
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
					++cursor.used

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

			++i
			++cursor.used

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

				++i
				++cursor.used

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

				++i
				++cursor.used

				matches.push(cursor.index)

				cursor = getNextCursor(cursor, arguments)
			}
		}

		argMatches.arguments.push(matches)

		return { cursor, argMatches }
	}
} # }}}

func matchArguments(assessment: Assessement, arguments: Array<Expression>, excludes: Array<String>) { # {{{
	var mut combinations = [[]]

	for var argument in arguments {
		if argument.isUnion() {
			var oldCombinations = combinations

			combinations = []

			for var oldCombination in oldCombinations {
				for var type in argument.discardAlias().types() {
					combinations.push([...oldCombination, type])
				}
			}
		}
		else {
			for var combination in combinations {
				combination.push(argument)
			}
		}
	}

	if combinations.length == 1 {
		var context = MatchContext(combinations[0], excludes, async: assessment.async)

		for var tree in assessment.trees {
			matchTree(tree, context)

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
			var context = MatchContext(combination, excludes, async: assessment.async)

			var mut nf = true

			for var tree in assessment.trees while nf {
				matchTree(tree, context)

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

func mergeResults(results: Array<CallMatchResult>) { # {{{
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
				if var result = perFunctions[match.function.index()] {
					if !Array.same(result.arguments, match.arguments) {
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

func matchNamedArguments3(assessment: Assessement, arguments: Array<Type>, nameds: Dictionary<NamingArgument>, shorthands: Dictionary<NamingArgument>, indexeds: Array<NamingArgument>, exhaustive: Boolean, node: AbstractNode) { # {{{
	var mut combinations = [[]]

	for var type in arguments {
		if type.isUnion() {
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

	var results = []

	for var combination in combinations {
		if var result = matchNamedArguments4(assessment, combination, nameds, shorthands, [...indexeds], exhaustive, node) {
			results.push(result)
		}
		else {
			return null
		}
	}

	return mergeResults(results)
} # }}}

func matchNamedArguments4(assessment: Assessement, argumentTypes: Array<Type>, nameds: Dictionary<NamingArgument>, shorthands: Dictionary<NamingArgument>, indexeds: Array<NamingArgument>, exhaustive: Boolean, node: AbstractNode) { # {{{
	var perNames = {}

	for var function, key of assessment.functions {
		for var parameter, index in function.parameters() {
			var name = parameter.name()
			var type = parameter.type()

			if var parameters = perNames[name] {
				parameters.push({
					function: key
					type
					index
				})
			}
			else {
				perNames[name] = [{
					function: key
					type
					index
				}]
			}
		}
	}

	var mut possibleFunctions: Array = Dictionary.keys(assessment.functions)

	var preciseness = {}
	var excludes = Dictionary.keys(nameds)

	for var key in possibleFunctions {
		preciseness[key] = true
	}

	for var argument, name of nameds {
		if var parameters = perNames[name] {
			var argumentType = argumentTypes[argument.index]
			var matchedFunctions = []

			for var { function, type } in parameters {
				if argumentType.isAssignableToVariable(type, false, false, false, true) {
					matchedFunctions.push(function)
				}
				else if type.isAssignableToVariable(argumentType, true, false, false, true) {
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
		return matchNamedArguments5(
			assessment
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
			if var parameters = perNames[name] {
				var argumentType = argumentTypes[argument.index]

				var mut matched = false

				for var function in possibleFunctions {
					if var { type } = parameters.find((data, _, _) => data.function == function) {
						if argumentType.isAssignableToVariable(type, false, false, false, true) {
							matched = true

							perFunctions[function].shorthands[name] = argument
						}
						else if type.isAssignableToVariable(argumentType, true, true, false, true) {
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
				if var perArgument = perArguments[hash] {
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
			return matchNamedArguments5(
				assessment
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
				if var result = matchNamedArguments5(
					assessment
					argumentTypes
					nameds
					perArgument.shorthands
					[...indexeds, ...perArgument.indexeds]
					perArgument.functions
					perArgument.preciseness
					[...excludes, ...Dictionary.keys(perArgument.shorthands)]
					node
				) {
					return result
				}
			}

			return matchNamedArguments5(
				assessment
				argumentTypes
				nameds
				{}
				[...indexeds, ...Dictionary.values(shorthands)]
				possibleFunctions
				preciseness
				excludes
				node
			)
		}
	}
} # }}}

func matchNamedArguments5(assessment: Assessement, argumentTypes: Array<Type>, nameds: Dictionary<NamingArgument>, shorthands: Dictionary<NamingArgument>, indexeds: Array<NamingArgument>, mut possibleFunctions: Array, preciseness: Dictionary, excludes: Array<String>, node: AbstractNode) { # {{{
	if indexeds.length == 0 {
		possibleFunctions = possibleFunctions.filter((key, _, _) => assessment.functions[key].min(excludes) == 0)

		if possibleFunctions.length == 0 {
			return null
		}

		var preciseFunctions = possibleFunctions.filter((key, _, _) => preciseness[key])

		if preciseFunctions.length == possibleFunctions.length {
			var mut max = Infinity

			for var key in preciseFunctions {
				var m = assessment.functions[key].max()

				if m < max {
					max = m
				}
			}

			var shortestFunctions = preciseFunctions.filter((key, _, _) => assessment.functions[key].max() == max)

			var function = getMostPreciseFunction([assessment.functions[key] for var key in shortestFunctions], nameds, shorthands)
			var arguments = []

			var mut namedLefts = Dictionary.length(nameds) + Dictionary.length(shorthands)

			for var parameter in function.parameters() {
				var name = parameter.name()

				if var argument = nameds[name] {
					arguments.push(argument.index)
					--namedLefts
				}
				else if var argument = shorthands[name] {
					arguments.push(argument.index)
					--namedLefts
				}
				else {
					if namedLefts > 0 {
						arguments.push(null)
					}
				}
			}

			var match = CallMatch(
				function
				arguments
			)

			return PreciseCallMatchResult(matches: [match])
		}
		else {
			var possibilities = []
			// TODO rename variable
			var mut arguments2 = null

			for var key in possibleFunctions {
				var function = assessment.functions[key]
				var args = []

				var mut namedLefts = Dictionary.length(nameds) + Dictionary.length(shorthands)

				for var parameter in function.parameters() {
					var name = parameter.name()

					if var argument = nameds[name] {
						args.push(argument.index)
						--namedLefts
					}
					else if var argument = shorthands[name] {
						args.push(argument.index)
						--namedLefts
					}
					else {
						if namedLefts > 0 {
							args.push(null)
						}
					}
				}

				if arguments2 == null {
					arguments2 = args
				}
				else if !Array.same(arguments2, args) {
					throw new NotSupportedException()
				}

				possibilities.push(function)
			}

			if arguments2 == null {
				return LenientCallMatchResult(possibilities)
			}
			else {
				return LenientCallMatchResult(possibilities, arguments: arguments2)
			}
		}
	}
	else {
		indexeds.sort((a, b) => a.index - b.index)

		var arguments = indexeds.map(({ index }, _, _) => argumentTypes[index])

		if indexeds.length == argumentTypes.length {
			return matchArguments(assessment, arguments, excludes)
		}
		else {
			var functions = [assessment.functions[key] for var key in possibleFunctions]
			var reducedAssessment = assess(functions, excludes, assessment.name, node)

			if var result = matchArguments(reducedAssessment, arguments, excludes) {

				if result is PreciseCallMatchResult {
					for var match in result.matches {
						var arguments = []
						var indexes = {}

						for var parameter, index in match.function.parameters() {
							var name = parameter.name()

							if var argument = nameds[name] {
								arguments.push(argument.index)

								indexes[argument.index] = true
							}
							else if var argument = shorthands[name] {
								arguments.push(argument.index)

								indexes[argument.index] = true
							}
							else if var mut index = match.arguments.shift() {
								if index is Array {
									var args = []

									for var i in index {
										while indexes[i] {
											++i
										}

										args.push(i)

										indexes[i] = true
									}

									arguments.push(args)
								}
								else {
									while indexes[index] {
										++index
									}

									arguments.push(index)

									indexes[index] = true
								}
							}
							else {
								arguments.push(null)
							}
						}

						match.arguments = arguments
					}

					if possibleFunctions.every((key, _, _) => preciseness[key]) {
						return result
					}
					else {
						var possibilities = [result.matches[0].function]
						// TODO rename variable
						var arguments3 = result.matches[0].arguments

						for var match in result.matches from 1 {
							if Array.same(arguments3, match.arguments) {
								possibilities.push(match.function)
							}
							else {
								throw new NotSupportedException()
							}
						}

						return LenientCallMatchResult(possibilities, arguments: arguments3)
					}
				}
				else if result.possibilities.length == 1 {
					if var arguments = result.arguments {
						throw new NotImplementedException()
					}
					else {
						var function = result.possibilities[0]
						result.arguments = []

						var mut namedLefts = excludes.length
						var mut requiredLefts = 0

						for var parameter in function.parameters(excludes) {
							if parameter.min() > 0 {
								++requiredLefts
							}
						}

						var mut lastIndexed = null

						for var parameter, index in function.parameters() {
							var name = parameter.name()

							if var argument = nameds[name] {
								result.arguments.push(argument.index)
								--namedLefts
								lastIndexed = null
							}
							else if var argument = shorthands[name] {
								result.arguments.push(argument.index)
								--namedLefts
								lastIndexed = null
							}
							else if parameter.min() >= 1 {
								var argument = indexeds.shift()

								result.arguments.push(argument.index)

								--requiredLefts

								lastIndexed = null
								arguments.shift()
							}
							else if arguments.length > requiredLefts {
								var argument = indexeds.shift()

								result.arguments.push(argument.index)

								lastIndexed = arguments.shift()
							}
							else {
								if namedLefts > 0 {
									if ?lastIndexed && lastIndexed.isAssignableToVariable(parameter.type(), true, true, false, true) {
										ReferenceException.throwConfusingArguments(assessment.name, node)
									}
									else {
										result.arguments.push(null)
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

func getMostPreciseFunction(mut functions: Array<FunctionType>, nameds: Dictionary<NamingArgument>, shorthands: Dictionary<NamingArgument>) { # {{{
	for var parameter in functions[0].parameters() {
		var name = parameter.name()

		if nameds[name]? || shorthands[name]? {
			var types = []
			var perType = {}

			for var function in functions {
				for var parameter in function.parameters() {
					if parameter.name() == name {
						types.push(parameter.type())

						var key = parameter.type().hashCode()

						if var types = perType[key] {
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
