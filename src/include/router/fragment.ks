namespace Fragment {
	export {
		type FragmentHelper = {
			allArgs(index: Number): String
			points(): String
			tester(type: Type): String
		}

		func buildHelper(fragments: MarkWriter, args: String, node: AbstractNode): FragmentHelper { # {{{
			var allArgsMark = fragments.mark()
			var pointsMark = allArgsMark.mark()

			var context = {
				allArgs: false
				allArgsMark
				points: false
				pointsMark
				index: -1
				testers: {}
			}

			return {
				allArgs: (index) => {
					if !context.allArgs {
						context.allArgsMark.line(`\($runtime.immutableScope(node))te = (pts, idx) => \($runtime.helper(node)).isUsingAllArgs(\(args), pts, idx)`)

						context.allArgs = true
					}

					return `te(pts, \(index))`
				}
				points: () => {
					if !context.points {
						context.pointsMark.line(`\($runtime.scope(node))pts`)

						context.points = true
					}

					return `pts`
				}
				tester: getTester^$(context, fragments, node, ^)
			}
		} # }}}

		func isNeedingTestings(tree: TreeBranch): Boolean { # {{{
			return true
		} # }}}

		func isNeedingTestings(tree: TreeLeaf): Boolean { # {{{
			var parameters = tree.function.parameters()
			var async = tree.function.isAsync()

			for var argument in tree.arguments {
				if !async || argument.parameter < parameters.length {
					var type = parameters[argument.parameter].type()

					if type.isAny() && type.isNullable() {
						return false
					}
				}
			}

			return true
		} # }}}

		func toDefaultFooter(fragments, node: AbstractNode): Void { # {{{
			fragments.line(`throw \($runtime.helper(node)).badArgs()`)
		} # }}}

		func toLabelFragments(labels: Type{}, helper: FragmentHelper, block: BlockBuilder, node: AbstractNode): BlockBuilder { # {{{
			var fragments = block.newControl().code('if(')

			var mut nf = false

			for var type, label of labels {
				var test = helper.tester(type)

				if nf {
					fragments.code(' && ')
				}
				else {
					nf = true
				}

				fragments.code(`\(test)(kws.\(label))`)
			}

			fragments.code(')').step()

			return fragments
		} # }}}

		func toTreeFragments(
			buildPath: PathBuilder
			args: String
			tree: Tree
			labels: Type{}
			nIndex: Number
			nLength: Number
			continuous: Boolean
			mut fallback: Boolean
			helper: FragmentHelper
			block: BlockBuilder
			node: AbstractNode
		): Boolean { # {{{
			var allArgs = tree.min == 0 && tree.rest

			var late fragments
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

			var mut useAllArgs = allArgs

			if tree.order.length == 0 {
				var line = fragments.newLine()

				var mut comma = buildPath(tree.function, line.code('return '))

				var mut varargs = tree.function.hasVarargsParameter()
				if varargs || #labels {
					var todoLabels = Object.keys(labels)

					for var parameter in tree.function.parameters() {
						if comma {
							line.code($comma)
						}
						else {
							comma = true
						}

						if parameter.isOnlyLabeled() && ?labels[parameter.getExternalName()] {
							line.code(`kws.\(parameter.getExternalName())`)

							todoLabels.remove(parameter.getExternalName())

							if !#todoLabels && !varargs {
								break
							}
						}
						else if parameter.isVarargs() {
							line.code('[]')

							if !#todoLabels {
								break
							}
							else {
								varargs = false
							}
						}
						else {
							line.code('void 0')
						}
					}
				}

				line.code(')').done()
			}
			else if tree.order.length == 1 {
				var column = tree.columns[tree.order[0]]

				if isNeedingTestings(column) {
					useAllArgs = toTreeFragments(buildPath, args, tree, column, false, helper, fragments, 0, 1, Junction.NONE, continuous, -1, tree.min, node)
				}
				else {
					toCallFragments(buildPath, args, tree, column, fragments, node)

					fallback = true
				}
			}
			else {
				var mut anyTested = false

				for var key, index in tree.order {
					var column = tree.columns[key]

					useAllArgs = toTreeFragments(buildPath, args, tree, column, anyTested, helper, fragments, index, tree.order.length, Junction.NONE, hasAlternative(tree, index), -1, tree.min, node)

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
	}

	func getTester(this, fragments: MarkWriter, node: AbstractNode, type: Type): String { # {{{
		var hash = type.hashCode(true)

		if var name ?= this.testers[hash] {
			return name
		}

		this.index += 1

		var name = `t\(this.index)`

		var line = fragments.newLine()

		line.code(`\($runtime.immutableScope(node))\(name) = `)

		type.toAwareTestFunctionFragments('value', false, null, null, line, node)

		line.done()

		this.testers[hash] = name

		return name
	} # }}}

	func hasAlternative(tree, index: Number): Boolean { # {{{
		if index + 1 == tree.order.length {
			return false
		}

		var { type } = tree.columns[tree.order[index]]

		for var key in tree.order from index + 1 {
			var column = tree.columns[key]

			if type.isAssignableToVariable(column.type) {
				return true
			}
		}

		return false
	} # }}}

	func isUsingTestings(branch: TreeBranch, startIndex: Number): Boolean { # {{{
		if branch.order.length != 1 || startIndex != -1 {
			return true
		}

		var column = branch.columns[branch.order[0]]

		var type = column.type

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

	func toCallFragments(buildPath: PathBuilder, args: String, tree: Tree, leaf: TreeLeaf, fragments, node: AbstractNode): Void { # {{{
		var { function, arguments } = leaf
		var async = function.isAsync()
		var parameters = function.parameters()
		var scope = node.scope()

		var line = fragments.newLine()

		var mut comma = buildPath(function, line.code('return '))

		var lastIndex = arguments.length - 1
		var mut lastParameter = -1
		var mut anyTested = false
		var mut variadic = false

		for var { parameter, from, to }, index in arguments {
			if comma {
				line.code($comma)
			}
			else {
				comma = true
			}

			for var param in parameters from lastParameter + 1 to~ parameter {
				if param.isOnlyLabeled() {
					line.code(`kws.\(param.getExternalName()), `)
				}
				else if param.isVarargs() {
					line.code('[], ')
				}
				else {
					line.code('void 0, ')
				}
			}

			var varargs = async && parameter >= parameters.length ? false : parameters[parameter].isVarargs()
			var type = async && parameter >= parameters.length ? scope.reference('Function') : parameters[parameter].type()

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

						for var i from 0 to~ to.index - from.index {
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

		for var parameter in parameters from lastParameter + 1 {
			if parameter.isOnlyLabeled() {
				line.code(`, kws.\(parameter.getExternalName())`)
			}
			else if parameter.isVarargs() {
				line.code(', []')
			}
			else {
				line.code(', void 0')
			}
		}

		line.code(`)`).done()
	} # }}}

	func toTreeFragments(
		buildPath: PathBuilder
		args: String
		tree: Tree
		branch: TreeBranch
		anyTested: Boolean
		helper: FragmentHelper
		builder: BlockBuilder | ControlBuilder
		nIndex: Number
		nLength: Number
		junction: Junction
		alternative: Boolean
		mut startIndex: Number
		min: Number
		node: AbstractNode
	): Boolean { # {{{
		var type = branch.type
		var mut useAllArgs = false

		var isTest = !((anyTested || type.isAny()) && type.isNullable() && startIndex == -1 && (branch.max == branch.min || branch.rest))

		if !isTest {
			if branch.order.length == 1 {
				useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[branch.order[0]], false, helper, builder, 0, branch.order.length, junction, true, startIndex, min - branch.min, node)
			}
			else {
				if junction == Junction.AND {
					builder.code(')').step()
				}

				for var key, index in branch.order {
					useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[key], false, helper, builder, index, branch.order.length, Junction.NONE, true, startIndex, min - branch.min, node)
				}
			}
		}
		else {
			var late fragments: BlockBuilder | ControlBuilder
			var mut shouldClose = false

			if junction == Junction.AND {
				fragments = builder
				fragments.code(' && ')
			}
			else {
				fragments = builder.newControl()
				fragments.code('if(')

				shouldClose = true
			}

			var test = helper.tester(type)

			if startIndex == -1 && branch.min == branch.max != 0 {
				if branch.min <= 5 {
					if branch.index >= 0 {
						for var i from branch.index to~ branch.index + branch.min {
							if i != branch.index {
								fragments.code(' && ')
							}

							fragments.code(`\(test)(\(args)[\(i)])`)
						}
					}
					else if tree.min == tree.max {
						var index = tree.min + branch.index

						for var i from index to~ index + branch.min {
							if i != index {
								fragments.code(' && ')
							}

							fragments.code(`\(test)(\(args)[\(i)])`)
						}
					}
					else {
						throw NotImplementedException.new()
					}
				}
				else {
					throw NotImplementedException.new()
				}
			}
			else {
				var late max
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
					startIndex += 1

					fragments.code(`\(helper.points()), \(startIndex))`)
				}
			}

			if isUsingTestings(branch, startIndex) {
				if nIndex + 1 == nLength && branch.order.length == 1 {
					toTreeFragments(buildPath, args, tree, branch.columns[branch.order[0]], false, helper, fragments, 0, 1, Junction.AND, alternative, startIndex, min - branch.min, node)
				}
				else {
					fragments.code(')').step()

					var mut useAllArgs = false
					var mut nullTested = false

					for var key, index in branch.order {
						useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[key], nullTested, helper, fragments, index, branch.order.length, Junction.NONE, alternative || hasAlternative(branch, index), startIndex, min - branch.min, node)

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

				var useAllArgs = toTreeFragments(buildPath, args, tree, branch.columns[branch.order[0]], false, helper, fragments, 0, 1, Junction.NONE, alternative || hasAlternative(branch, 0), startIndex, min - branch.min, node)

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

	func toTreeFragments(
		buildPath: PathBuilder
		args: String
		tree: Tree
		leaf: TreeLeaf
		anyTested: Boolean
		helper: FragmentHelper
		builder: BlockBuilder | ControlBuilder
		nIndex: Number
		nLength: Number
		junction: Junction
		alternative: Boolean
		mut startIndex: Number
		min: Number
		node: AbstractNode
	): Boolean { # {{{
		var type = leaf.type

		var isTest = !((anyTested || type.isAny()) && type.isNullable() && (startIndex == -1 || leaf.max <= 0))

		if isTest {
			var late fragments: BlockBuilder | ControlBuilder
			var mut shouldClose = false

			if junction == Junction.AND {
				fragments = builder
				fragments.code(' && ')
			}
			else {
				fragments = builder.newControl()
				fragments.code('if(')

				shouldClose = true
			}

			var test = helper.tester(type)

			if startIndex == -1 && leaf.min == leaf.max != 0 {
				if leaf.min <= 5 {
					if leaf.index >= 0 {
						for var i from leaf.index to~ leaf.index + leaf.min {
							if i != leaf.index {
								fragments.code(' && ')
							}

							fragments.code(`\(test)(\(args)[\(i)])`)
						}
					}
					else if tree.min == tree.max {
						var index = tree.min + leaf.index

						for var i from index to~ index + leaf.min {
							if i != index {
								fragments.code(' && ')
							}

							fragments.code(`\(test)(\(args)[\(i)])`)
						}
					}
					else {
						var index = tree.min + leaf.index

						for var i from index to~ 0 step -1 {
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
				var late max
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
					startIndex += 1

					fragments.code(`\(helper.points()), \(startIndex))`)
				}

				if startIndex != -1 {
					fragments.code(` && \(helper.allArgs(startIndex + 1))`)
				}
			}

			fragments.code(')').step()

			toCallFragments(buildPath, args, tree, leaf, fragments, node)

			if shouldClose {
				fragments.done()
			}
		}
		else {
			toCallFragments(buildPath, args, tree, leaf, builder, node)
		}

		return !isTest
	} # }}}
}
