// TODO!
// type CallMatchArgument = Number | ArrayElementMatch | Array<Number | ArrayElementMatch | ArraySliceMatch> | Null

struct CallMatchArgument {
	index: Number?		= null
	element: Number?	= null
	from: Number?		= null
	to: Number?			= null
}

// TODO!
// type CallMatchPosition = CallMatchArgument | CallMatchArgument[]
type CallMatchPosition = CallMatchArgument | Array<CallMatchArgument>

struct CallMatch {
	function: FunctionType
	positions: CallMatchPosition[]
}

struct PreciseCallMatchResult {
	matches: CallMatch[]
}

struct LenientCallMatchResult {
	possibilities: FunctionType[]
	positions: Number[]				= []
	labels: Number{}				= {}
	matches: CallMatch[]?			= null
}

enum NoMatchResult {
	NoArgumentMatch
	NoThisMatch
}

enum ArgumentMatchMode {
	AllMatches
	BestMatch
}

type CallMatchResult = PreciseCallMatchResult | LenientCallMatchResult | NoMatchResult

namespace Router {
	struct Assessment {
		name: String
		async: Boolean
		emptiable: Boolean
		labelable: Boolean
		macro: Boolean
		sealed: Boolean
		rest: Boolean
		length: Number
		functions: FunctionType{}
		labels: Label{}
		routes: Route{}
		mainRoutes: String[]
	}

	struct Label {
		all: Number[]
		mandatories: Number[]
	}

	struct Route {
		functions: FunctionType{}
		trees: Tree[]
		labelable: Boolean			= false
		labels: Type{}				= {}
	}

	struct NamedLength {
		functions: Array<String>
		parameters: Object<NamedParameter>
	}

	struct NamedParameter {
		indexes: Object<Number>
		types: Object<NamedType>
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
		value: Expression?	= null
	}

	struct Tree {
		min: Number
		max: Number								= min
		variadic: Boolean						= false
		rest: Boolean							= false
		columns: TreeColumn{}					= {}
		order: String[]							= []
		equivalences: String[][]?				= null
		function: FunctionType?					= null
	}

	struct Group {
		n: Number
		functions: Array<FunctionType>		= []
		rows: Object<Row>					= {}
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
		union: UnionMatch?				= null
		names: Object<String[]>?		= null
	}

	struct TreeNode {
		index: Number
		type: Type
		rest: Boolean
		variadic: Boolean						= false
		min: Number								= 1
		max: Number								= 1
		parameters: Object<TreeParameter>		= {}
		isNode: Boolean
		order: Array<String>					= []
		rows: Array<Row>
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
		arguments: TreeArgument[]
		byNames: String[]
	}

	struct TreeBranch extends TreeNode {
		columns: TreeColumn{}			= {}
		equivalences: String[][]?		= null
	}

	type TreeColumn = TreeBranch | TreeLeaf

	struct MatchContext {
		async: Boolean
		found: Boolean						= false
		arguments: Array<Type>
		excludes: Array<String>
		matches: Array<CallMatch>			= []
		possibilities: Array<FunctionType>	= []
		indexeds: NamingArgument[]
		mode: ArgumentMatchMode
		node: AbstractNode
	}

	type PathBuilder = (function: FunctionType, line: LineBuilder): Boolean

	include {
		'./router/build'
		'./router/regroup'
		'./router/unbounded'
		'./router/matching'
		'./router/fragment'
	}

	enum FooterType {
		MIGHT_THROW
		MUST_THROW
		NO_THROW
	}

	func assess(functions: FunctionType[], name: String, node: AbstractNode): Assessment { # {{{
		if !#functions {
			return new Assessment(
				name
				async: false
				emptiable: true
				labelable: false
				macro: false
				rest: false
				sealed: false
				functions: {}
				labels: {}
				routes: {}
				mainRoutes: []
				length: 0
			)
		}

		var async = functions[0].isAsync()
		var mut emptiable = false
		var mut labelable = false
		var mut rest = false
		var mut sealed = false
		var perLabels = {}
		var functionMap = {}
		var labelMap = {}

		for var function in functions {
			rest ||= function.hasRestParameter()
			sealed ||= function.isSealed()
			emptiable ||= function.min() == 0

			var labels = []
			var types = {}

			for var parameter, index in function.parameters() {
				if parameter.isOnlyLabeled() {
					labelable ||= true

					var label = parameter.getExternalName()

					if var data ?= labelMap[label] {
						data.all.push(function.index())

						if parameter.min() > 0 {
							data.mandatories.push(function.index())
						}
					}
					else {
						var data = new Label(
							all: [function.index()]
							mandatories: []
						)

						if parameter.min() > 0 {
							data.mandatories.push(function.index())
						}

						labelMap[label] = data
					}

					labels.push(label)

					types[label] = parameter.type()
				}
			}

			labels.sort((a, b) => a.localeCompare(b))

			var mut key = ''

			for var label in labels {
				key += `\(label):\(types[label].hashCode());`
			}

			if var perLabel ?= perLabels[key] {
				perLabel.functions.push(function)
			}
			else {
				perLabels[key] = {
					labels
					types
					functions: [function]
				}
			}

			functionMap[function.index()] = function
		}

		var labelKeys = Object.keys(perLabels).sort((a, b) => {
			var perLabelA = perLabels[a]
			var perLabelB = perLabels[b]

			for var i from 0 to~ Math.min(perLabelA.labels.length, perLabelB.labels.length) {
				var labelA = perLabelA.labels[i]
				var labelB = perLabelB.labels[i]

				var ld = labelA.localeCompare(labelB)

				return ld unless ld == 0

				var td = perLabelA.types[labelA].compareToRef(perLabelB.types[labelB])

				return td unless td == 0
			}

			return perLabelA.labels.length < perLabelB.labels.length ? -1 : 1
		})

		var routes = {}
		var mainRoutes = []

		for var labelKey in labelKeys {
			var { labels, types, functions } = perLabels[labelKey]
			var functionKeys = [function.index() for var function in functions]

			var key = `|\(functionKeys.sort((a, b) => a - b).join(','))`

			var route = Build.buildRoute(functions, name, false, labels, node)

			routes[key] = route

			if #labels {
				route.labelable = true
				route.labels = types
			}

			mainRoutes.push(key)
		}

		return new Assessment(
			name
			async
			emptiable
			labelable
			macro: false
			rest
			sealed
			functions: functionMap
			labels: labelMap
			routes
			mainRoutes
			length: functions.length
		)
	} # }}}

	// TODO!
	// func matchArguments(assessment: Assessment, thisType: Type?, arguments: Expression[], mode: ArgumentMatchMode = .BestMatch, node: AbstractNode): CallMatchResult { # {{{
	func matchArguments(assessment: Assessment, thisType: Type?, arguments: Expression[], mode: ArgumentMatchMode = ArgumentMatchMode.BestMatch, node: AbstractNode): CallMatchResult { # {{{
		if assessment.length == 0 {
			if !#arguments {
				return new PreciseCallMatchResult([])
			}
			else {
				return new LenientCallMatchResult([])
			}
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
				indexeds.push(new NamingArgument(
					index
					type: argument
					strict: false
				))

				types.push(argument)
			}
		}
		else {
			for var argument, index in arguments {
				match argument {
					is NamedArgument {
						var name = argument.name()

						if ?nameds[name] {
							throw new NotSupportedException()
						}

						nameds[name] = new NamingArgument(
							index
							name
							type: argument.type()
							strict: true
						)

						namedCount += 1

						if ?shorthands[name] {
							drop shorthands[name]

							shortCount -= 1
						}
					}
					is IdentifierLiteral {
						var name = argument.name()

						if argument.variable().isPredefined() {
							indexeds.push(new NamingArgument(
								index
								type: argument.type()
								strict: false
							))
						}
						else if !?nameds[name] && !?invalids[name] {
							if ?shorthands[name] {
								invalids[name] = true

								indexeds.push(shorthands[name], new NamingArgument(
									index
									type: argument.type()
									strict: false
								))

								drop shorthands[name]

								shortCount -= 1
							}
							else {
								shortCount += 1

								shorthands[name] = new NamingArgument(
									index
									name
									type: argument.type()
									strict: false
								)
							}
						}
						else {
							indexeds.push(new NamingArgument(
								index
								type: argument.type()
								strict: false
							))
						}
					}
					else {
						indexeds.push(new NamingArgument(
							index
							type: argument.type()
							strict: false
							value: argument
						))
					}
				}

				types.push(argument.type())
			}
		}

		var mut functions: Number[] = []

		if ?thisType {
			for var function of assessment.functions {
				if function.hasAssignableThis() && thisType.isAssignableToVariable(function.getThisType(), true, false, false) {
					functions.push(function.index())
				}
			}
		}
		else {
			for var function of assessment.functions {
				if function.isMissingThis() || !function.hasAssignableThis() || function.getThisType().isAny() {
					functions.push(function.index())
				}
			}
		}

		unless #functions {
			return NoMatchResult.NoThisMatch
		}

		var labels = []

		for var data, label of assessment.labels {
			if ?nameds[label] || ?shorthands[label] {
				functions = functions.intersection(data.all)
			}
			else {
				functions = functions.remove(...data.mandatories)
			}

			unless #functions {
				SyntaxException.throwNamedOnlyParameters([label], node)
			}
		}

		unless #functions {
			return NoMatchResult.NoArgumentMatch
		}

		var functionList = [assessment.functions[index] for var index in functions]

		var route = Build.getRoute(assessment, labels, functionList, node)

		if namedCount > 0 || shortCount > 0 {
			return Matching.matchArguments(assessment, route, types, nameds, shorthands, indexeds, mode, node)
		}
		else {
			return Matching.matchArguments(assessment, route, types, [], indexeds, mode, node)
		}
	} # }}}

	func toFragments(
		buildPath: PathBuilder
		args!: String = 'args'
		assessment: Assessment
		fragments: BlockBuilder
		footerType: FooterType = FooterType.MUST_THROW
		footer: Function = Fragment.toDefaultFooter
		node: AbstractNode
	): Void { # {{{
		if !#assessment.mainRoutes {
			if footerType == FooterType.NO_THROW {
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

			return
		}

		var mark = fragments.mark()
		var helper = Fragment.buildHelper(mark, args, node)
		var fallback = footerType != FooterType.MUST_THROW
		var mut continuous = true
		var mut useAllArgs = false

		for var route in assessment.mainRoutes {
			var { trees, labelable, labels } = assessment.routes[route]
			var mut block = fragments

			if labelable {
				block = Fragment.toLabelFragments(labels, helper, fragments, node)
			}

			if trees.length == 1 && trees[0].min == 0 && trees[0].rest {
				var tree = trees[0]

				if tree.order.length == 1 && Fragment.isNeedingTestings(tree.columns[tree.order[0]]) {
					Fragment.toTreeFragments(buildPath, args, tree, labels, 0, 1, true, fallback, helper, block, node)
				}
				else {
					Fragment.toTreeFragments(buildPath, args, tree, labels, 0, 1, true, false, helper, block, node)

					useAllArgs = true
				}
			}
			else {
				var mut previous = -1

				for var tree, i in trees {
					if continuous {
						if previous + 1 != tree.min {
							continuous = false
						}
						else {
							previous = tree.max
						}
					}

					useAllArgs = Fragment.toTreeFragments(buildPath, args, tree, labels, i, trees.length, continuous, fallback, helper, block, node)
				}
			}

			if labelable {
				block.done()
			}
		}

		if continuous {
			if !useAllArgs {
				if footerType == FooterType.MUST_THROW {
					Fragment.toDefaultFooter(fragments, node)
				}
				else {
					footer(fragments, node)
				}
			}
		}
		else if !assessment.emptiable || !assessment.rest || !useAllArgs {
			if footerType == FooterType.MUST_THROW {
				Fragment.toDefaultFooter(fragments, node)
			}
			else {
				footer(fragments, node)
			}
		}
	} # }}}

	namespace Argument {
		export func toFragments(
			positions!: CallMatchPosition[] = []
			labels: Number{}?
			expressions: Expression[]
			function: FunctionType
			labelable: Boolean
			needSeparator: Boolean
			precise: Boolean
			fragments
			mode
		): Void { # {{{
			var arguments = [...positions]
			for var argument in arguments down {
				if argument is Array {
					break
				}
				else if !?argument.index {
					arguments.pop()
				}
				else {
					break
				}
			}

			if !#arguments && !#labels {
				if #expressions {
					if needSeparator {
						fragments.code($comma)
					}

					if labelable {
						fragments.code('{}', $comma)
					}

					for var expression, i in expressions {
						fragments.code($comma) if i != 0

						expression.toArgumentFragments(fragments, mode)
					}
				}
				else if labelable {
					if needSeparator {
						fragments.code($comma)
					}

					fragments.code('{}')
				}

				return
			}

			if needSeparator {
				fragments.code($comma)
			}

			if #labels {
				fragments.code('{')

				var mut nf = false

				for var arg, label of labels {
					if nf {
						fragments.code($comma)
					}
					else {
						nf = true
					}

					fragments.code(`\(label): `)

					expressions[arg].toArgumentFragments(fragments, mode)
				}

				fragments.code('}')

				if #arguments {
					fragments.code($comma)
				}
			}
			else if labelable {
				fragments.code('{}')

				if #arguments {
					fragments.code($comma)
				}
			}

			var parameters = function.parameters()

			for var position, index in arguments {
				fragments.code($comma) if index != 0

				var parameter = parameters[index].type()

				// TODO!
				// match argument {
				// 	Null {
				// 	}
				// 	Number {
				// 	}
				// 	Array with [argument: Number] when expressions[argument] is UnaryOperatorSpread && expressions[argument].type().isArray() {
				// 	}
				// 	Array with [{ argument, from }: ArraySliceMatch] {
				// 	}
				// 	Array {
				// 	}
				// 	ArrayElementMatch with { argument, index } {
				// 	}
				// }

				if position is Array {
					if function.isAlien() {
						for var { index }, i in position {
							fragments.code($comma) if i != 0

							expressions[index].toArgumentFragments(fragments, mode)
						}

						continue
					}

					if position.length == 1 {
						if ?position[0].from {
							expressions[position[0].index].argument().toArgumentFragments(fragments, mode)

							fragments.code(`.slice(\(position[0].from)`)

							if ?position[0].to {
								fragments.code(`, \(position[0].to + 1)`)
							}

							fragments.code(')')

							continue
						}
						else if expressions[position[0].index] is UnaryOperatorSpread && expressions[position[0].index].type().isArray() {
							if precise {
								expressions[position[0].index].argument().toArgumentFragments(fragments, mode)
							}
							else {
								expressions[position[0].index].toArgumentFragments(fragments, mode)
							}

							continue
						}
					}

					fragments.code('[') if precise

					for var { index, element, from }, i in position {
						fragments.code($comma) if i != 0

						if ?element {
							expressions[index].argument().toArgumentFragments(fragments, mode)

							fragments.code(`[\(element)]`)
						}
						else if ?from {
							fragments.code('...')

							expressions[index].argument().toArgumentFragments(fragments, mode)

							fragments.code(`.slice(\(from))`)
						}
						else {
							expressions[index].toArgumentFragments(fragments, parameter, mode)
						}
					}

					fragments.code(']') if precise
				}
				else {
					var { index, element } = position

					if !?index {
						fragments.code('void 0')
					}
					else if ?element {
						expressions[index].argument().toArgumentFragments(fragments, mode)

						fragments.code(`[\(element)]`)
					}
					else {
						expressions[index].toArgumentFragments(fragments, parameter, mode)
					}
				}
			}
		} # }}}

		export func toFlatFragments(
			positions!: CallMatchPosition[] = []
			labels: Number{}?
			expressions: Expression[]
			function: FunctionType
			labelable: Boolean
			needSeparator: Boolean
			prefill?
			fragments
			mode
		): Void { # {{{
			var arguments = [...positions]
			for var argument in arguments down {
				if argument is Array {
					break
				}
				else if !?argument.index {
					arguments.pop()
				}
				else {
					break
				}
			}

			if needSeparator {
				fragments.code($comma)
			}

			if ?prefill {
				fragments.code('[').compile(prefill).code('].concat(')
			}
			else {
				fragments.code(`[].concat(`)
			}

			if !#arguments && !#labels {
				for var expression, i in expressions {
					fragments.code($comma) if i != 0

					if expression is UnaryOperatorSpread && expression.type().isArray() {
						expression.argument().toArgumentFragments(fragments, mode)
					}
					else {
						expression.toArgumentFragments(fragments, mode)
					}
				}

				fragments.code(')')

				return
			}

			if #labels {
				fragments.code('{')

				var mut nf = false

				for var arg, label of labels {
					if nf {
						fragments.code($comma)
					}
					else {
						nf = true
					}

					fragments.code(`\(label): `)

					expressions[arg].toArgumentFragments(fragments, mode)
				}

				fragments.code('}')

				if #arguments {
					fragments.code($comma)
				}
			}
			else if labelable {
				fragments.code('{}')

				if #arguments {
					fragments.code($comma)
				}
			}

			var parameters = function.parameters()
			var mut opened = false

			for var position, index in arguments {
				if position is Array {
					if position.length == 1 && expressions[position[0].index] is UnaryOperatorSpread && expressions[position[0].index].type().isArray() {
						if opened {
							fragments.code('], ')

							opened = false
						}

						expressions[position[0].index].argument().toArgumentFragments(fragments, mode)
					}
					else {
						if !opened {
							fragments.code('[')
						}

						for var { index }, i in position {
							fragments.code($comma) if i != 0

							expressions[index].toArgumentFragments(fragments, mode)
						}

						if !opened {
							fragments.code(']')
						}
					}
				}
				else if ?position.index {
					var argument = expressions[position.index]

					if argument is UnaryOperatorSpread {
						if opened {
							fragments.code('], ')

							opened = false
						}
						else if index != 0 {
							fragments.code($comma)
						}

						argument.argument().toArgumentFragments(fragments)
					}
					else {
						if index != 0 {
							fragments.code($comma)
						}

						if !opened {
							fragments.code('[')

							opened = true
						}

						argument.toArgumentFragments(fragments)
					}
				}
				else {
					if index == 0 {
						fragments.code('void 0')
					}
					else {
						fragments.code(', void 0')
					}
				}
			}

			if opened {
				fragments.code(']')
			}

			fragments.code(')')
		} # }}}
	}

	export {
		Argument
		Assessment
		FooterType

		assess
		matchArguments
		toFragments

		// TODO
		// RegroupTree for toSignature
	}
}
