func toTreeFragments(buildPath: FunctionPathBuilder, args: String, tree: Tree, nIndex: Number, nLength: Number, continuous: Boolean, fallback: Boolean, helper, block: BlockBuilder, node: AbstractNode): Boolean { # {{{
	const allArgs = tree.min == 0 && tree.rest

	lateinit const fragments
	if !allArgs {
		if tree.rest && continuous {
			// no test needed
			fragments = block
		}
		else {
			fragments = block.newControl()

			if tree.rest {
				fragments.code(`if(\(args).length >= \(tree.min))`)
			}
			else if tree.min == tree.max {
				fragments.code(`if(\(args).length === \(tree.min))`)
			}
			else if tree.min == 0 {
				fragments.code(`if(\(args).length <= \(tree.max))`)
			}
			else {
				fragments.code(`if(\(args).length >= \(tree.min) && \(args).length <= \(tree.max))`)
			}

			fragments.step()
		}
	}
	else {
		fragments = block
	}

	let useAllArgs = allArgs

	if tree.order.length == 0 {
		const line = fragments.newLine()

		let comma = buildPath(tree.function, line.code('return '))

		if tree.function.hasVarargsParameter() {
			for const parameter in tree.function.parameters() {
				if comma {
					line.code($comma)
				}
				else {
					comma = true
				}

				if parameter.isVarargs() {
					line.code('[]')

					break
				}
				else {
					line.code('void 0')
				}
			}
		}

		line.code(')').done()
	}
	else if tree.order.length == 1 {
		const column = tree.columns[tree.order[0]]

		if isNeedingTestings(column) {
			useAllArgs = toTreeFragments(buildPath, args, tree, column, false, helper, fragments, 0, 1, Junction::NONE, continuous, -1, tree.min, node)
		}
		else {
			toCallFragments(buildPath, args, tree, column, fragments, node)

			fallback = true
		}
	}
	else {
		auto anyTested = false

		for const key, index in tree.order {
			const column = tree.columns[key]

			useAllArgs = toTreeFragments(buildPath, args, tree, column, anyTested, helper, fragments, index, tree.order.length, Junction::NONE, hasAlternative(tree, index), -1, tree.min, node)

			if !anyTested && column.type.isAny() {
				anyTested = true
			}
		}
	}

	if fragments is ControlBuilder {
		if nIndex + 1 != nLength && !useAllArgs && !fallback && tree.order.length != 0 {
			fragments.line(`throw \($runtime.helper(node)).badArgs()`)
		}

		fragments.done()
	}

	return useAllArgs
} # }}}

func isNeedingTestings(tree: TreeBranch): Boolean { # {{{
	return true
} # }}}

func isNeedingTestings(tree: TreeLeaf): Boolean { # {{{
	const parameters = tree.function.parameters()
	const async = tree.function.isAsync()

	for const argument in tree.arguments {
		if !async || argument.parameter < parameters.length {
			const type = parameters[argument.parameter].type()

			if type.isAny() && type.isNullable() {
				return false
			}
		}
	}

	return true
} # }}}

func hasAlternative(tree, index: Number): Boolean { # {{{
	if index + 1 == tree.order.length {
		return false
	}

	const { type } = tree.columns[tree.order[index]]

	for const key in tree.order from index + 1 {
		const column = tree.columns[key]

		if type.isAssignableToVariable(column.type) {
			return true
		}
	}

	return false
} # }}}

func toTreeFragments(buildPath: FunctionPathBuilder, args: String, tree: Tree, leaf: TreeLeaf, anyTested: Boolean, helper, builder: BlockBuilder | ControlBuilder, nIndex: Number, nLength: Number, junction: Junction, hasAlternative: Boolean, startIndex: Number, min: Number, node: AbstractNode): Boolean { # {{{
	const type = leaf.type

	const isTest = !((anyTested || type.isAny()) && type.isNullable() && (startIndex == -1 || leaf.max <= 0))
	const isBacktrack = leaf.backtracks.length != 0

	lateinit const fragments: BlockBuilder | ControlBuilder
	let shouldClose = false
	if isTest || isBacktrack {
		if junction == Junction::AND {
			fragments = builder
			fragments.code(' && ')
		}
		else {
			fragments = builder.newControl()
			fragments.code('if(')

			shouldClose = true
		}
	}
	else {
		fragments = builder
	}

	if isBacktrack {
		let nf = false

		for const { index, type } in leaf.backtracks {
			if nf {
				fragments.code(' && ')
			}
			else {
				nf = true
			}

			const test = helper.tester(type)

			if startIndex == -1 {
				fragments.code(`\(test)(\(args)[\(index)])`)
			}
			else {
				fragments.code(`\($runtime.helper(node)).isVarargs(\(args), 1, 1, \(test), \(helper.points()), \(startIndex))`)
			}
		}

		fragments.code(' && ')
	}

	if isTest {
		const test = helper.tester(type)

		if startIndex == -1 && leaf.min == leaf.max != 0 {
			if leaf.min <= 5 {
				if leaf.index >= 0 {
					for const i from leaf.index til leaf.index + leaf.min {
						if i != leaf.index {
							fragments.code(' && ')
						}

						fragments.code(`\(test)(\(args)[\(i)])`)
					}
				}
				else if tree.min == tree.max {
					const index = tree.min + leaf.index

					for const i from index til index + leaf.min {
						if i != index {
							fragments.code(' && ')
						}

						fragments.code(`\(test)(\(args)[\(i)])`)
					}
				}
				else {
					const index = tree.min + leaf.index

					for const i from index til 0 by -1 {
						if i != index {
							fragments.code(' && ')
						}

						fragments.code(`\(test)(\(args)[\(args).length - \(i)])`)
					}
				}
			}
			else {
				fragments.code(`\($runtime.type(node)).isVarargs(\(args), \(leaf.index), \(leaf.index + leaf.min - 1), false, \(test))`)
			}
		}
		else {
			let max
			if leaf.max == Infinity {
				if tree.min > 0 {
					max = `\(args).length - \(tree.min - leaf.min)`
				}
				else {
					max = `\(args).length`
				}
			}
			else if leaf.max == 0 {
				max = `\(args).length`
			}
			else if leaf.max < 0 {
				max = `\(args).length - \(-leaf.max)`
			}
			else {
				max = leaf.max
			}

			fragments.code(`\($runtime.helper(node)).isVarargs(\(args), \(leaf.min), \(max), \(test), `)

			if startIndex == -1 {
				startIndex = 0

				fragments.code(`\(helper.points()) = [\(leaf.index)], \(startIndex))`)
			}
			else {
				++startIndex

				fragments.code(`\(helper.points()), \(startIndex))`)
			}

			if startIndex != -1 {
				fragments.code(` && \(helper.allArgs(startIndex + 1))`)
			}
		}

		fragments.code(')').step()

		toCallFragments(buildPath, args, tree, leaf, fragments, node)
	}
	else if isBacktrack {
		fragments.code(')').step()

		toCallFragments(buildPath, args, tree, leaf, fragments, node)
	}
	else {
		toCallFragments(buildPath, args, tree, leaf, fragments, node)
	}

	if shouldClose {
		fragments.done()
	}

	return !isTest
} # }}}

func toCallFragments(buildPath: FunctionPathBuilder, args: String, tree: Tree, leaf: TreeLeaf, fragments, node: AbstractNode): void { # {{{
	const { function, arguments } = leaf
	const async = function.isAsync()
	const parameters = function.parameters()
	const scope = node.scope()

	const line = fragments.newLine()

	let comma = buildPath(function, line.code('return '))

	const lastIndex = arguments.length - 1
	auto lastParameter = -1
	auto anyTested = false
	auto variadic = false

	for const { parameter, from, to }, index in arguments {
		if comma {
			line.code($comma)
		}
		else {
			comma = true
		}

		for const param in parameters from lastParameter + 1 til parameter {
			if param.isVarargs() {
				line.code('[], ')
			}
			else {
				line.code('void 0, ')
			}
		}

		const varargs = async && parameter >= parameters.length ? false : parameters[parameter].isVarargs()
		const type = async && parameter >= parameters.length ? scope.reference('Function') : parameters[parameter].type()

		if !((anyTested || type.isAny()) && type.isNullable()) {
			if from.variadic || to.variadic || to.index - from.index > 5 {
				if varargs {
					line.code(`\($runtime.helper(node)).getVarargs(\(args)`)
				}
				else {
					line.code(`\($runtime.helper(node)).getVararg(\(args)`)
				}

				if from.variadic {
					line.code(`, pts[\(from.index)]`)
				}
				else {
					line.code(`, \(from.index)`)
				}

				if to.variadic {
					line.code(`, pts[\(to.index)]`)
				}
				else {
					line.code(`, \(to.index)`)
				}

				line.code(`)`)
			}
			else if to.index <= 0 {
				if varargs {
					NotImplementedException.throw()
				}
				else {
					line.code(`\(args)[\(args).length - \(-from.index)]`)
				}
			}
			else {
				if varargs {
					line.code(`[`)

					for const i from 0 til to.index - from.index {
						if i != 0 {
							line.code($comma)
						}

						line.code(`\(args)[\(from.index + i)]`)
					}

					line.code(`]`)
				}
				else {
					line.code(`\(args)[\(from.index)]`)
				}
			}

			variadic = true
		}
		else {
			if from.variadic || to.variadic {
				if varargs {
					line.code(`\($runtime.helper(node)).getVarargs(\(args)`)
				}
				else {
					line.code(`\($runtime.helper(node)).getVararg(\(args)`)
				}

				if from.variadic {
					line.code(`, pts[\(from.index)]`)
				}
				else {
					line.code(`, \(from.index)`)
				}

				if to.variadic {
					line.code(`, pts[\(to.index)]`)
				}
				else {
					line.code(`, \(to.index)`)
				}

				line.code(`)`)
			}
			else if to.index <= 0 {
				if varargs {
					if to.index == 0 {
						if from.index == 0 {
							line.code(`Array.from(\(args))`)
						}
						else {
							line.code(`Array.from(\(args)).slice(\(from.index))`)
						}
					}
					else {
						line.code(`Array.from(\(args)).slice(\(from.index), \(args).length - \(1 - to.index))`)
					}
				}
				else {
					line.code(`\(args)[\(args).length - \(-from.index)]`)
				}
			}
			else {
				if varargs {
					if from.index == 0 {
						if to.index == 0 || to.index == tree.max {
							line.code(`Array.from(\(args))`)
						}
						else {
							line.code(`Array.from(\(args)).slice(\(from.index), \(to.index - from.index))`)
						}
					}
					else {
						if to.index == 0 {
							line.code(`Array.from(\(args)).slice(\(from.index))`)
						}
						else {
							line.code(`Array.from(\(args)).slice(\(from.index), \(to.index - from.index))`)
						}
					}
				}
				else {
					line.code(`\(args)[\(from.index)]`)
				}
			}
		}

		lastParameter = parameter

		if !anyTested && type.isAny() {
			anyTested = true
		}
	}

	for const parameter in parameters from lastParameter + 1 {
		if parameter.isVarargs() {
			line.code(', []')
		}
		else {
			line.code(', void 0')
		}
	}

	line.code(`)`).done()
} # }}}

func toTreeFragments(buildPath: FunctionPathBuilder, args: String, tree: Tree, branch: TreeBranch, anyTested: Boolean, helper, builder: BlockBuilder | ControlBuilder, nIndex: Number, nLength: Number, junction: Junction, alternative: Boolean, startIndex: Number, min: Number, node: AbstractNode): Boolean { # {{{
	const type = branch.type
	let useAllArgs = false

	const isTest = !((anyTested || type.isAny()) && type.isNullable() && startIndex == -1 && (branch.max == branch.min || branch.rest))

	if !isTest {
		if branch.order.length == 1 {
			useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[branch.order[0]], false, helper, builder, 0, branch.order.length, junction, true, startIndex, min - branch.min, node)
		}
		else {
			if junction == Junction::AND {
				builder.code(')').step()
			}

			for const key, index in branch.order {
				useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[key], false, helper, builder, index, branch.order.length, Junction::NONE, true, startIndex, min - branch.min, node)
			}
		}
	}
	else {
		lateinit const fragments: BlockBuilder | ControlBuilder
		let shouldClose = false

		if junction == Junction::AND {
			fragments = builder
			fragments.code(' && ')
		}
		else {
			fragments = builder.newControl()
			fragments.code('if(')

			shouldClose = true
		}

		const test = helper.tester(type)

		if startIndex == -1 && branch.min == branch.max != 0 {
			if branch.min <= 5 {
				if branch.index >= 0 {
					for const i from branch.index til branch.index + branch.min {
						if i != branch.index {
							fragments.code(' && ')
						}

						fragments.code(`\(test)(\(args)[\(i)])`)
					}
				}
				else if tree.min == tree.max {
					const index = tree.min + branch.index

					for const i from index til index + branch.min {
						if i != index {
							fragments.code(' && ')
						}

						fragments.code(`\(test)(\(args)[\(i)])`)
					}
				}
				else {
					throw new NotImplementedException()
				}
			}
			else {
				throw new NotImplementedException()
			}
		}
		else {
			let max
			if branch.max == Infinity {
				if tree.min > 0 {
					max = `\(args).length - \(tree.min - branch.min)`
				}
				else {
					max = `\(args).length`
				}
			}
			else if branch.max == 0 {
				max = `\(args).length`
			}
			else if branch.max < 0 {
				max = `\(args).length - \(-branch.max)`
			}
			else {
				max = branch.max
			}

			fragments.code(`\($runtime.helper(node)).isVarargs(\(args), \(branch.min), \(max), \(test), `)

			if startIndex == -1 {
				startIndex = 0

				fragments.code(`\(helper.points()) = [\(branch.index)], \(startIndex))`)
			}
			else {
				++startIndex

				fragments.code(`\(helper.points()), \(startIndex))`)
			}
		}

		if isUsingTestings(branch, startIndex) {
			if nIndex + 1 == nLength && branch.order.length == 1 {
				toTreeFragments(buildPath, args, tree, branch.columns[branch.order[0]], false, helper, fragments, 0, 1, Junction::AND, alternative, startIndex, min - branch.min, node)
			}
			else {
				fragments.code(')').step()

				auto useAllArgs = false
				auto nullTested = false

				for const key, index in branch.order {
					useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[key], nullTested, helper, fragments, index, branch.order.length, Junction::NONE, alternative || hasAlternative(branch, index), startIndex, min - branch.min, node)

					if !nullTested && branch.columns[key].type.isNull() {
						nullTested = true
					}
				}

				if !alternative && !useAllArgs {
					fragments.line(`throw \($runtime.helper(node)).badArgs()`)
				}
			}
		}
		else {
			fragments.code(')').step()

			const useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[branch.order[0]], false, helper, fragments, 0, 1, Junction::NONE, alternative || hasAlternative(branch, 0), startIndex, min - branch.min, node)

			if !alternative && !useAllArgs {
				fragments.line(`throw \($runtime.helper(node)).badArgs()`)
			}
		}

		if shouldClose {
			fragments.done()
		}
	}

	return useAllArgs
} # }}}

func isUsingTestings(branch: TreeBranch, startIndex: Number): Boolean { # {{{
	if branch.order.length != 1 || startIndex != -1 {
		return true
	}

	const column = branch.columns[branch.order[0]]

	const type = column.type

	if type.isAny() && type.isNullable() {
		if column.isNode {
			return isUsingTestings(column, startIndex)
		}
		else {
			return false
		}
	}
	else {
		return true
	}
} # }}}

func isVarargs(assessement: Assessement) { # {{{
	for const tree in assessement.trees {
		if tree.variadic {
			return true
		}
	}

	return false
} # }}}

func getTester(fragments: MarkWriter, node: AbstractNode, type: Type): string { # {{{
	const hash = type.hashCode(true)

	if const name = this.testers[hash] {
		return name
	}

	const index = ++this.index

	const name = `t\(index)`

	const line = fragments.newLine()

	line.code(`\($runtime.immutableScope(node))\(name) = `)

	type.toTestFunctionFragments(line, node)

	line.done()

	this.testers[hash] = name

	return name
} # }}}

func toDefaultFooter(fragments, node: AbstractNode) { # {{{
	fragments.line(`throw \($runtime.helper(node)).badArgs()`)
} # }}}

func buildHelper(fragments: MarkWriter, args: String, node: AbstractNode) { # {{{
	const allArgsMark = fragments.mark()
	const pointsMark = allArgsMark.mark()

	const context = {
		allArgs: false
		allArgsMark
		points: false
		pointsMark
		index: -1
		testers: {}
	}

	return {
		allArgs(index) {
			if !context.allArgs {
				context.allArgsMark.line(`\($runtime.immutableScope(node))te = (pts, idx) => \($runtime.helper(node)).isUsingAllArgs(\(args), pts, idx)`)

				context.allArgs = true
			}

			return `te(pts, \(index))`
		}
		points() {
			if !context.points {
				context.pointsMark.line(`\($runtime.scope(node))pts`)

				context.points = true
			}

			return `pts`
		}
		tester: getTester^$(context, fragments, node)
	}
} # }}}
