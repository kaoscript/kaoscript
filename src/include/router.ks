type CallMatchArgument = Number | Array<Number> | Null

struct CallMatch {
	function: FunctionType
	arguments: Array<CallMatchArgument>
}

struct PreciseCallMatchResult {
	matches: Array<CallMatch>
}

struct LenientCallMatchResult {
	possibilities: Array<FunctionType>
	arguments: Array<Number>			= null
}

type CallMatchResult = PreciseCallMatchResult | LenientCallMatchResult

namespace Router {
	struct Assessement {
		name: String
		min: Number
		max: Number
		async: Boolean
		rest: Boolean
		trees: Array<Tree>
		functions: Dictionary<FunctionType>
		names: Dictionary<NamedLength>
		macro: Boolean
		sealed: Boolean
	}

	struct NamedLength {
		functions: Array<String>
		parameters: Dictionary<NamedParameter>
	}

	struct NamedParameter {
		indexes: Dictionary<Number>
		types: Dictionary<NamedType>
		order: Array<String>
	}

	struct NamedType {
		type: Type
		functions: Array<String>
	}

	struct NamingArgument {
		index: Number
		name: String?		= null
		type: Type
		strict: Boolean
	}

	struct Tree {
		min: Number
		max: Number								= min
		variadic: Boolean						= false
		rest: Boolean							= false
		columns: Dictionary<TreeColumn>			= {}
		order: Array<String>					= []
		equivalences: Array<Array<String>>?		= null
		function: FunctionType?					= null
	}

	struct Group {
		n: Number
		functions: Array<FunctionType>		= []
		rows: Dictionary<Row>				= {}
		rowCount: Number					= 0
	}

	struct RowType {
		index: Number
		type: Type
		rest: Boolean
		parameter: Number
	}

	struct UnionMatch {
		function: FunctionType
		length: Number
		matches: Array
	}

	struct Row {
		key: String
		function: FunctionType
		types: Array<RowType>
		alternative: Boolean			= false
		union: UnionMatch				= null
	}

	struct TreeNode {
		index: Number
		type: Type
		rest: Boolean
		variadic: Boolean						= false
		min: Number								= 1
		max: Number								= 1
		parameters: Dictionary<TreeParameter>	= {}
		isNode: Boolean
		order: Array<String>					= []
		rows: Array<Row>
		backtracks: Array<BackTrack>			= []
	}

	struct BackTrack {
		index: Number
		type: Type
	}

	struct TreeParameter {
		key: String
		function: FunctionType
		parameter: Number
		rows: Array<String>
	}

	struct TreeArgument {
		parameter: Number
		from: { variadic: Boolean, index: Number }
		to: { variadic: Boolean, index: Number }
	}

	struct TreeLeaf extends TreeNode {
		function: FunctionType
		arguments: Array<TreeArgument>
	}

	struct TreeBranch extends TreeNode {
		columns: Dictionary<TreeColumn>			= {}
		equivalences: Array<Array<String>>?		= null
	}

	type TreeColumn = TreeBranch | TreeLeaf

	struct MatchContext {
		async: Boolean
		found: Boolean						= false
		arguments: Array<Type>
		excludes: Array<String>
		matches: Array<CallMatch>			= []
		possibilities: Array<FunctionType>	= []
	}

	type FunctionPathBuilder = (function: FunctionType, line: LineBuilder): Boolean

	include {
		'./router/build'
		'./router/regroup'
		'./router/unbounded'
		'./router/matching'
		'./router/fragment'
	}

	export {
		enum FooterType {
			MIGHT_THROW
			MUST_THROW
			NO_THROW
		}

		func assess(functions: Array<FunctionType>, name: String, node: AbstractNode): Assessement { # {{{
			if functions.length == 0 {
				return Assessement(
					name
					functions: {}
					min: 0
					max: 0
					async: false
					rest: false
					trees: []
					names: {}
					macro: false
					sealed: false
				)
			}

			var parameters = {
				functions: {}
				names: {}
			}

			var async = functions[0].isAsync()
			var asyncMin = async ? 1 : 0

			var mut min = Infinity
			var mut max = 0
			var mut maxRest = 0
			var mut rest = false
			var mut sealed = false

			for var function in functions {
				if var parameter = function.getRestParameter() {
					rest = true

					min = Math.min(function.getMinBefore() + parameter.min() + function.getMinAfter() + asyncMin, min)
					maxRest = Math.max(function.getMaxBefore() + parameter.min() + 1 + function.getMaxAfter() + asyncMin, maxRest)
				}
				else {
					min = Math.min(function.min() + asyncMin, min)
					max = Math.max(function.max() + asyncMin, max)
				}

				if function.isSealed() {
					sealed = true
				}
			}

			var groups: Dictionary<Group> = {}

			if rest {
				if max == 0 {
					max = maxRest
				}
				else if max < maxRest {
					max = maxRest
				}
				else {
					++max
				}
			}

			for var n from min to max {
				groups[n] = Group(n)
			}

			for var function in functions {
				if function.max() == Infinity {
					for var n from function.min() + asyncMin to max {
						groups[n].functions.push(function)
					}
				}
				else {
					for var n from function.min() + asyncMin to function.max() + asyncMin {
						groups[n].functions.push(function)
					}
				}

				parameters.functions[function.index()] = function

				for var parameter in function.parameters() {
					var name = parameter.name() ?? '_'

					if var group = parameters.names[name] {
						group.push(`\(function.index())`)
					}
					else {
						parameters.names[name] = [`\(function.index())`]
					}
				}
			}

			var trees: Array<Tree> = []
			var names = {}

			for var group of groups when group.functions.length > 0 {
				trees.push(buildTree(group, name, false, null, node))

				if group.n != 0 {
					names[group.n] = buildNames(group, name, node)
				}
			}

			regroupTrees(trees, node)

			expandUnboundeds(trees, node)

			var functionMap = {}

			for var function in functions {
				functionMap[function.index()] = function
			}

			return Assessement(
				name
				functions: functionMap
				async
				min
				max: rest ? Infinity : max
				rest
				trees
				names
				macro: false
				sealed
			)
		} # }}}

		func matchArguments(assessment: Assessement, arguments: Array<Expression>, exhaustive: Boolean = false, node: AbstractNode): CallMatchResult? { # {{{
			if assessment.trees.length == 0 && arguments.length == 0 {
				return PreciseCallMatchResult([])
			}

			var nameds = {}
			var shorthands = {}
			var indexeds = []
			var types = []

			var mut namedCount = 0
			var mut shortCount = 0
			var invalids = {}

			if assessment.macro {
				for var argument, index in arguments {
					indexeds.push(NamingArgument(
						index
						type: argument
						strict: false
					))

					types.push(argument)
				}
			}
			else {
				for var argument, index in arguments {
					if argument is NamedArgument {
						var name = argument.name()

						if ?nameds[name] {
							throw new NotSupportedException()
						}

						nameds[name] = NamingArgument(
							index
							name
							type: argument.type()
							strict: true
						)

						++namedCount

						if ?shorthands[name] {
							delete shorthands[name]

							--shortCount
						}
					}
					else if argument is IdentifierLiteral {
						var name = argument.name()

						if argument.variable().isPredefined() {
							indexeds.push(NamingArgument(
								index
								type: argument.type()
								strict: false
							))
						}
						else if !?nameds[name] && !?invalids[name] {
							if ?shorthands[name] {
								invalids[name] = true

								indexeds.push(shorthands[name], NamingArgument(
									index
									type: argument.type()
									strict: false
								))

								delete shorthands[name]

								--shortCount
							}
							else {
								++shortCount

								shorthands[name] = NamingArgument(
									index
									name
									type: argument.type()
									strict: false
								)
							}
						}
						else {
							indexeds.push(NamingArgument(
								index
								type: argument.type()
								strict: false
							))
						}
					}
					else {
						indexeds.push(NamingArgument(
							index
							type: argument.type()
							strict: false
						))
					}

					types.push(argument.type())
				}
			}

			if namedCount > 0 || shortCount > 0 {
				return matchNamedArguments3(assessment, types, nameds, shorthands, indexeds, exhaustive, node)
			}
			else {
				return matchArguments(assessment, types, [])
			}
		} # }}}

		func toFragments(buildPath: FunctionPathBuilder, args!: String = 'args', assessment: Assessement, fragments: BlockBuilder, footerType: FooterType = FooterType::MUST_THROW, footer: Function = toDefaultFooter, node: AbstractNode): Void { # {{{
			var mark = fragments.mark()
			var helper = buildHelper(mark, args, node)
			var fallback = footerType != FooterType::MUST_THROW

			if assessment.trees.length == 0 {
				if footerType == FooterType::NO_THROW {
					footer(fragments, node)
				}
				else {
					var ctrl = fragments
						.newControl()
						.code(`if(\(args).length !== 0)`)
						.step()

					footer(ctrl, node)

					ctrl.done()
				}
			}
			else if assessment.trees.length == 1 && assessment.trees[0].min == 0 && assessment.trees[0].rest {
				var tree = assessment.trees[0]

				if tree.order.length == 1 && isNeedingTestings(tree.columns[tree.order[0]]) {
					toTreeFragments(buildPath, args, tree, 0, 1, true, fallback, helper, fragments, node)

					footer(fragments, node)
				}
				else {
					toTreeFragments(buildPath, args, tree, 0, 1, true, false, helper, fragments, node)
				}
			}
			else {
				var mut continuous = true
				var mut previous = -1
				var mut useAllArgs = false

				for var tree, i in assessment.trees {
					if continuous {
						if previous + 1 != tree.min {
							continuous = false
						}
						else {
							previous = tree.max
						}
					}

					useAllArgs = toTreeFragments(buildPath, args, tree, i, assessment.trees.length, continuous, fallback, helper, fragments, node)
				}

				if continuous {
					if !useAllArgs {
						if footerType == FooterType::MUST_THROW {
							toDefaultFooter(fragments, node)
						}
						else {
							footer(fragments, node)
						}
					}
				}
				else if assessment.min != 0 || !assessment.rest || !useAllArgs {
					if footerType == FooterType::MUST_THROW {
						toDefaultFooter(fragments, node)
					}
					else {
						footer(fragments, node)
					}
				}
			}
		} # }}}

		func toArgumentsFragments(matchArguments: Array<CallMatchArgument>, expressions: Array<Expression>, function: FunctionType, hasContext: Boolean, fragments, mode) { # {{{
			var arguments = [...matchArguments]
			for var argument in arguments desc while !?argument {
				arguments.pop()
			}

			return if arguments.length == 0

			if hasContext {
				fragments.code($comma)
			}

			var parameters = function.parameters()

			for var argument, index in arguments {
				fragments.code($comma) if index != 0

				var parameter = parameters[index].type()

				if !?argument {
					fragments.code('void 0')
				}
				else if argument is Number {
					expressions[argument].toArgumentFragments(fragments, parameter, mode)
				}
				else if function.isAlien() {
					for var arg, i in argument {
						fragments.code($comma) if i != 0

						expressions[arg].toArgumentFragments(fragments, mode)
					}
				}
				else {
					if argument.length == 1 && expressions[argument[0]] is UnaryOperatorSpread && expressions[argument[0]].type().isArray() {
						expressions[argument[0]].argument().toArgumentFragments(fragments, mode)
					}
					else {
						fragments.code('[')

						for var arg, i in argument {
							fragments.code($comma) if i != 0

							expressions[arg].toArgumentFragments(fragments, mode)
						}

						fragments.code(']')
					}
				}
			}
		} # }}}
	}
}
