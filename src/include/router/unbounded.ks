namespace Unbounded {
	export {
		func expandUnboundeds(trees: Array<Tree>, node: AbstractNode): Void { # {{{
			for var tree in trees til -1 {
				update(tree, false)
			}

			update(trees.last(), true)
		} # }}}
	}

	func getMaxMinAfter(tree: TreeBranch): Number { # {{{
		var mut min = 0

		for var column of tree.columns {
			if column.type.isAssignableToVariable(tree.type, false, true, true) {
				min = Math.max(min, getMaxMinFromIndex(column))
			}
			else {
				min = Math.max(min, getMaxMinFromFunction(column))
			}
		}

		return min
	} # }}}
	func getMaxMinAfter(tree: TreeLeaf): Number { # {{{
		return tree.function.isAsync() ? 1 : 0
	} # }}}

	func getMaxMinFromIndex(tree: TreeBranch): Number { # {{{
		if tree.index < 0 {
			return -tree.index
		}
		else {
			return 0
		}
	} # }}}
	func getMaxMinFromIndex(tree: TreeLeaf): Number { # {{{
		if tree.index < 0 {
			return -tree.index
		}
		else {
			return tree.function.isAsync() ? 1 : 0
		}
	} # }}}

	func getMaxMinFromFunction(tree: TreeBranch): Number { # {{{
		var mut min = 0

		for var column of tree.columns {
			min = Math.max(min, getMaxMinFromFunction(column))
		}

		return min
	} # }}}
	func getMaxMinFromFunction(tree: TreeLeaf): Number { # {{{
		return getMinAfter(tree.function)
	} # }}}

	func getMinAfter(function: FunctionType): Number { # {{{
		return function.min(MinMax::AFTER_REST + MinMax::ASYNC)
	} # }}}

	func getRowType(row: Row, tree: TreeBranch | TreeLeaf): RowType? { # {{{
		for var type in row.types {
			if type.index == tree.index {
				return type
			}
		}

		return null
	} # }}}

	func reduceMinToZero(tree: TreeBranch | TreeLeaf): Void { # {{{
		if tree.min != 0 {
			if tree.variadic {
				tree.min = 0
			}
			else {
				NotImplementedException.throw()
			}
		}

		if tree.isNode {
			for var column of tree.columns {
				reduceMinToZero(column)
			}
		}
	} # }}}

	func update(tree: Tree, unlimited: Boolean): Void { # {{{
		if unlimited {
			for var hash in tree.order {
				if update(tree, tree.columns[hash], true, 0, {}) {
					tree.rest = true
					tree.variadic = true
					tree.max = Infinity
				}
			}
		}
		else {
			for var hash in tree.order {
				update(tree, tree.columns[hash], false, 0, {})
			}
		}
	} # }}}

	func update(tree: Tree, node: TreeBranch, unlimited: Boolean, mut min: Number, mut arguments: Object): Boolean { # {{{
		var mut unbounded = updateArguments(node, unlimited, min, arguments <- {...arguments})

		min += node.min

		for var hash in node.order {
			if update(tree, node.columns[hash], unlimited, min, arguments) {
				unbounded = true
			}
		}

		return unbounded
	} # }}}

	func update(tree: Tree, node: TreeLeaf, unlimited: Boolean, min: Number, mut arguments: Object): Boolean { # {{{
		var unbounded = updateArguments(node, unlimited, min, arguments <- {...arguments})

		var function = node.function.index()
		var row = node.rows[0]

		var mut from = { variadic: false, index: 0 }
		var mut to = null
		var mut last = null

		var rests = {}

		for var parameter in row.types {
			var mut argument = arguments[parameter.index]

			if !?argument {
				if parameter.index >= 0 {
					argument = arguments[parameter.index - row.types.length]
				}
				else {
					argument = arguments[row.types.length + parameter.index]
				}

				if !?argument {
					continue
				}
			}

			if last?.parameter == parameter.parameter {
				if argument.variadic {
					if last.to.variadic {
						last.to.index += 1 + argument.steps
					}
					else {
						last.to.variadic = true
						last.to.index = 1 + argument.steps
					}
				}
				else {
					if argument.steps == -1 {
						last.to = { variadic: false, index: 0 }
					}
					else if last.to.variadic {
						last.to.index += 1
					}
					else {
						last.to.index += argument.steps
					}
				}

				if last.to.variadic && rests[parameter.parameter] {
					argument.tree.max = argument.tree.min
				}
			}
			else {
				if from.variadic {
					if argument.variadic {
						to = { variadic: true, index: from.index + 1 + argument.steps }

						if argument.tree.min != 0 && argument.tree.max == Infinity {
							rests[parameter.parameter] = true
						}
					}
					else if argument.steps == -1 {
						from = { variadic: false, index: -getMinAfter(node.function) }
						to = { variadic: false, index: 0 }
					}
					else {
						to = { variadic: true, index: from.index + 1 }
					}
				}
				else if argument.variadic {
					to = { variadic: true, index: 1 + argument.steps }

					if argument.tree.min != 0 && argument.tree.max == Infinity {
						rests[parameter.parameter] = true
					}
				}
				else if argument.steps == -1 {
					to = { variadic: false, index: -getMinAfter(node.function) }
				}
				else if argument.steps == 0 {
					to = { variadic: false, index: from.index + 1 }
				}
				else {
					to = { variadic: false, index: from.index + argument.steps }
				}

				last = TreeArgument(
					parameter: parameter.parameter
					from
					to
				)

				node.arguments.push(last)
			}

			// TODO remove forced casting
			from = to!!
		}

		return unbounded
	} # }}}

	func updateArguments(tree: TreeBranch | TreeLeaf, unlimited: Boolean, min: Number, arguments: Object): Boolean { # {{{
		var parameter = getRowType(tree.rows[0], tree).parameter
		var mut unbounded = unlimited && tree.rest

		if tree.type.isAny() && tree.type.isNullable() {
			tree.variadic = unbounded || tree.min != tree.max

			if unbounded {
				var previousArgument = arguments[tree.index - 1]
				if !(previousArgument?.parameter == parameter && previousArgument.variadic) {
					tree.max = -(min + getMaxMinAfter(tree))
				}
			}

			if tree is TreeLeaf || tree.rest {
				arguments[tree.index] = {
					tree
					variadic: false
					steps: unbounded ? -1 : tree.min
					parameter
				}
			}
			else {
				arguments[tree.index] = {
					tree
					variadic: tree.variadic
					steps: tree.variadic ? 0 : tree.min
					parameter
				}
			}
		}
		else {
			if unbounded {
				for var type in tree.rows[0].types while unbounded when type.parameter == parameter {
					if var argument ?= arguments[type.index] {
						if argument.tree.max == Infinity {
							unbounded = false
						}
					}
				}
			}

			tree.variadic = unbounded || tree.min != tree.max

			if unbounded && tree.max >= 0 {
				var previousArgument = arguments[tree.index - 1]

				if !(previousArgument?.parameter == parameter && previousArgument.variadic) {
					tree.max = -(min + getMaxMinAfter(tree))
				}
			}

			arguments[tree.index] = {
				tree
				variadic: tree.variadic
				steps: tree.variadic ? 0 : tree.min
				parameter
			}
		}

		return unbounded
	} # }}}
}
