struct CallMatchArgument {
	index: Number?		= null
	element: Number?	= null
	from: Number?		= null
	to: Number?			= null
	property: String?	= null
}

type CallMatchPosition = CallMatchArgument | CallMatchArgument[]

struct CallMatch {
	function: FunctionType
	positions: CallMatchPosition[]
}

struct PreciseCallMatchResult {
	matches: CallMatch[]
}

struct LenientCallMatchResult {
	possibilities: FunctionType[]
	positions: CallMatchPosition[]	= []
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

	struct NamingArgument {
		element: Number?	= null
		fitting: Boolean	= false
		index: Number
		name: String?		= null
		property: Boolean	= false
		spread: Boolean		= false
		strict: Boolean
		type: Type
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
		dynamicMax: Boolean						= false
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
		fitting: Boolean					= false
		fittingSpread: Boolean				= false
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
		'./router/build.ks'
		'./router/regroup.ks'
		'./router/unbounded.ks'
		'./router/matching.ks'
		'./router/generator.ks'
	}

	enum FooterType {
		MIGHT_THROW
		MUST_THROW
		NO_THROW
	}

	func assess(functions: FunctionType[], name: String, node: AbstractNode): Assessment { # {{{
		if !?#functions {
			return Assessment.new(
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
						var data = Label.new(
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
				perLabel.funcs.push(function)
			}
			else {
				perLabels[key] = {
					labels
					types
					funcs: [function]
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
			var { labels, types, funcs } = perLabels[labelKey]
			var functionKeys = [function.index() for var function in funcs]

			var key = `|\(functionKeys.sort((a, b) => a - b).join(','))`

			var route = Build.buildRoute(funcs, name, false, labels, node)

			routes[key] = route

			if ?#labels {
				route.labelable = true
				route.labels = types
			}

			mainRoutes.push(key)
		}

		return Assessment.new(
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

	func matchArguments(assessment: Assessment, thisType: Type?, arguments: Expression[], generics: AltType[], mode: ArgumentMatchMode = .BestMatch, node: AbstractNode): CallMatchResult { # {{{
		if assessment.length == 0 {
			if !?#arguments {
				return PreciseCallMatchResult.new([])
			}
			else {
				return LenientCallMatchResult.new([])
			}
		}

		var nameds = {}
		var shorthands = {}
		var indexeds = []
		var types = []

		var mut namedCount = 0
		var mut shortCount = 0
		var mut fitting = false
		var mut fittingSpread = false
		var invalids = {}

		if assessment.macro {
			for var argument, index in arguments {
				indexeds.push(NamingArgument.new(
					index
					type: argument
					strict: false
				))

				types.push(argument)
			}
		}
		else {
			for var argument, index in arguments {
				if argument is RestrictiveExpression | BinaryOperatorTypeAssertion | BinaryOperatorTypeCasting | UnaryOperatorTypeFitting | BinaryOperatorTypeSignalment {
					[namedCount, shortCount] = Matching.prepare(argument.expression(), index, argument.isFitting(), nameds, shorthands, indexeds, invalids, namedCount, shortCount, assessment, node)
				}
				else {
					[namedCount, shortCount] = Matching.prepare(argument, index, argument.isFitting(), nameds, shorthands, indexeds, invalids, namedCount, shortCount, assessment, node)
				}

				if argument.isFitting() {
					fitting = true
					fittingSpread ||= argument.isSpread()
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

		unless ?#functions {
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

			unless ?#functions {
				SyntaxException.throwNamedOnlyParameters([label], node)
			}
		}

		unless ?#functions {
			return NoMatchResult.NoArgumentMatch
		}

		var functionList = [assessment.functions[index] for var index in functions]

		var route = Build.getRoute(assessment, labels, functionList, node)

		var gg = { [name]: type for var { name, type } in generics }

		if namedCount > 0 || shortCount > 0 {
			return Matching.matchArguments(assessment, route, types, nameds, shorthands, indexeds, gg, fitting, fittingSpread, mode, node)
		}
		else {
			return Matching.matchArguments(assessment, route, types, [], indexeds, gg, fitting, fittingSpread, mode, node)
		}
	} # }}}

	func toFragments(
		buildPath: PathBuilder
		args!: String = 'args'
		assessment: Assessment
		hasDeferred: Boolean = false
		fragments: BlockBuilder
		footerType: FooterType = FooterType.MUST_THROW
		footer: Function = Generator.toDefaultFooter
		node: AbstractNode
	): Void { # {{{
		if !?#assessment.mainRoutes {
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
		var helper = Generator.buildHelper(mark, args, hasDeferred, node)
		var fallback = footerType != FooterType.MUST_THROW
		var mut continuous = true
		var mut useAllArgs = false

		for var route in assessment.mainRoutes {
			var { trees, labelable, labels } = assessment.routes[route]
			var mut block = fragments

			if labelable {
				block = Generator.toLabelFragments(labels, helper, fragments, node)
			}

			if trees.length == 1 && trees[0].min == 0 && trees[0].rest {
				var tree = trees[0]

				if tree.order.length == 1 && Generator.isNeedingTestings(tree.columns[tree.order[0]]) {
					Generator.toTreeFragments(buildPath, args, tree, labels, 0, 1, true, fallback, helper, block, node)
				}
				else {
					Generator.toTreeFragments(buildPath, args, tree, labels, 0, 1, true, false, helper, block, node)

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

					useAllArgs = Generator.toTreeFragments(buildPath, args, tree, labels, i, trees.length, continuous, fallback, helper, block, node)
				}
			}

			if labelable {
				block.done()
			}
		}

		if continuous {
			if !useAllArgs {
				if footerType == FooterType.MUST_THROW {
					Generator.toDefaultFooter(fragments, node)
				}
				else {
					footer(fragments, node)
				}
			}
		}
		else if !assessment.emptiable || !assessment.rest || !useAllArgs {
			if footerType == FooterType.MUST_THROW {
				Generator.toDefaultFooter(fragments, node)
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

			if !?#arguments && !?#labels {
				if ?#expressions {
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

			if ?#labels {
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

				if ?#arguments {
					fragments.code($comma)
				}
			}
			else if labelable {
				fragments.code('{}')

				if ?#arguments {
					fragments.code($comma)
				}
			}

			var parameters = function.parameters()
			var alien = function.isAlien()

			for var position, pIndex in arguments {
				var parameter = parameters[pIndex].type()

				if position is Array {
					if alien {
						if #position > 0 {
							fragments.code($comma) if pIndex != 0

							for var { index }, i in position {
								fragments.code($comma) if i != 0

								expressions[index].toArgumentFragments(fragments, mode)
							}
						}

						continue
					}

					fragments.code($comma) if pIndex != 0

					if #position == 1 {
						var expression = expressions[position[0].index]

						if ?position[0].from {
							expression.toArgumentFragments(fragments, position[0].from, position[0].to, mode)

							continue
						}
						else if expression is UnaryOperatorSpread && expression.type().isArray() {
							if precise {
								expression.toFlatArgumentFragments(false, fragments, mode)
							}
							else {
								expression.toArgumentFragments(fragments, mode)
							}

							continue
						}
					}

					fragments.code('[') if precise

					for var { index?, element?, from?, property? }, i in position {
						fragments.code($comma) if i != 0

						if ?element {
							expressions[index].toArgumentFragments(fragments, element, mode)
						}
						else if ?from {
							fragments.code('...')

							expressions[index].toArgumentFragments(fragments, from, mode)
						}
						else if ?property {
							expressions[index].toArgumentFragments(fragments, property, mode)
						}
						else {
							expressions[index].toArgumentFragments(fragments, parameter, mode)
						}
					}

					fragments.code(']') if precise
				}
				else {
					fragments.code($comma) if pIndex != 0

					var { index?, element?, property? } = position

					if !?index {
						fragments.code('void 0')
					}
					else if ?element {
						expressions[index].toArgumentFragments(fragments, element, mode)
					}
					else if ?property {
						expressions[index].toArgumentFragments(fragments, property, mode)
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

			var mut nullable = false

			for var expression in expressions {
				if expression.isSpread() {
					var type = expression.argument().type()

					if type.isNullable() {
						nullable = true
					}
				}
			}

			if !?#arguments && !?#labels && !?prefill && expressions.length == 1 {
				var expression = expressions[0]

				if !nullable || (expression is UnaryOperatorSpread && expression.useHelper()) {
					expression.toFlatArgumentFragments(false, fragments, mode)

					return
				}
			}

			if nullable {
				if ?prefill {
					fragments.code(`\($runtime.helper(expressions[0])).concatArray(\(nullable ? '1' : '0'), `).code('[').compile(prefill).code('], ')
				}
				else {
					fragments.code(`\($runtime.helper(expressions[0])).concatArray(\(nullable ? '1' : '0'), `)
				}
			}
			else {
				if ?prefill {
					fragments.code('[').compile(prefill).code('].concat(')
				}
				else {
					fragments.code(`[].concat(`)
				}
			}

			if !?#arguments && !?#labels {
				for var expression, i in expressions {
					fragments.code($comma) if i != 0

					expression.toFlatArgumentFragments(false, fragments, mode)
				}

				fragments.code(')')

				return
			}

			if ?#labels {
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

				if ?#arguments {
					fragments.code($comma)
				}
			}
			else if labelable {
				fragments.code('{}')

				if ?#arguments {
					fragments.code($comma)
				}
			}

			var parameters = function.parameters()
			var mut opened = false

			for var position, pIndex in arguments {
				if position is Array {
					if position.length == 1 && expressions[position[0].index].isSpread() {
						var expression = expressions[position[0].index]

						if opened {
							fragments.code('], ')

							opened = false
						}

						expression.toFlatArgumentFragments(false, fragments, mode)
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

					if argument.isSpread() {
						if opened {
							fragments.code('], ')

							opened = false
						}
						else if pIndex != 0 {
							fragments.code($comma)
						}

						argument.toFlatArgumentFragments(false, fragments, mode)
					}
					else {
						if pIndex != 0 {
							fragments.code($comma)
						}

						if !opened {
							fragments.code('[')

							opened = true
						}

						argument.toArgumentFragments(fragments, mode)
					}
				}
				else {
					if pIndex == 0 {
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

		RegroupTree for toSignature
	}
}
