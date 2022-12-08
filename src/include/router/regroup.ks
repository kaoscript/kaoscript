namespace RegroupTree {
	enum ShadowKind {
		None
		Soft
		Hard
	}

	export {
		func regroupTrees(trees: Tree[], node: AbstractNode): Void { # {{{
			var last = trees.last()
			var groups: Tree[]{} = {}

			for var tree in trees {
				for var hash in listEquivalentHashes(tree) {
					if var group ?= groups[hash] {
						group.push(tree)
					}
					else {
						groups[hash] = [tree]
					}
				}
			}

			var values = Object.values(groups).sort((a, b) => b.length - a.length)

			for var value, index in values when value.length > 0{
				for var val in values from index + 1 when val.length > 0 {
					val:Array.remove(...value)
				}
			}

			for var group, key of groups when group.length > 1 {
				regroupTreesByGroup(group, trees, last, [])
			}
		} # }}}

		func toSignature(tree: Tree): String { # {{{
			var mut s = ''

			for var key, i in tree.order {
				s += '/' + toSignature(tree.columns[key], `\(i)`)
			}

			return s
		} # }}}
		func toSignature(tree: TreeBranch, prefix: String): String { # {{{
			var mut s = `/\(prefix)=\(tree.index),\(tree.type.hashCode())(\(tree.min),\(tree.max))`

			for var key, i in tree.order {
				s += toSignature(tree.columns[key], `\(prefix).\(i)`)
			}

			return s
		} # }}}
		func toSignature(tree: TreeLeaf, prefix: String): String { # {{{
			return `/\(prefix)=\(tree.index),\(tree.type.hashCode())(\(tree.min),\(tree.max))>>\(tree.function.index())`
		} # }}}
	}

	func applyMin(tree: Tree, last: Tree, data: Array, shadows: Array): Void { # {{{
		tree.variadic = true

		if last.min < tree.min {
			tree.min = last.min
			tree.rest = last.rest || tree.rest
		}

		for var key in tree.order {
			applyMin(tree.columns[key], tree.max, data, shadows, [])
		}
	} # }}}
	func applyMin(tree: TreeBranch, max: Number, data: Array, shadows: Array, nodes: Array): Void { # {{{
		nodes.unshift(tree)

		for var key in tree.order {
			applyMin(tree.columns[key], max, data, shadows, nodes)
		}
	} # }}}
	func applyMin(tree: TreeLeaf, max: Number, data: Array, shadows: Array, nodes: Array): Void { # {{{
		nodes.unshift(tree)

		var i2p = {}
		for var type in tree.rows[0].types {
			i2p[type.index] = type.parameter
		}

		var shadow = shadows.shift()

		if ?shadow && shadow.length > 1 {
			if var node ?= nodes.find((node, _, _) => i2p[node.index] == shadow[1]) {
				if node.index >= 0 && node.max - max != 0 {
					node.max = node.max - max
				}
			}
		}

		if data.length == 0 {
			for var node in nodes {
				node.min = 0
			}
		}
		else {
			var d = data.shift()

			var mut lastType = null
			var mut lastMin = 0

			for var node in nodes {
				if d.length == 0 {
					node.min = 0
				}
				else if d[0] == i2p[node.index] && d[1] == node.type.hashCode(true) {
					d.shift()
					d.shift()

					node.min = d.shift()
				}
				else {
					node.min = 0
				}

				if node.min == 0 {
					if ?lastType && node.index >= 0 && node.max > 0 && node.max - max != 0  {
						if node.type.isAssignableToVariable(lastType, true, true, false) {
							node.max = node.max - max
						}
					}

					lastType = null
				}
				else {
					lastType = node.type
					lastMin = node.min
				}
			}
		}

		nodes.clear()
	} # }}}

	func buildMax(tree: Tree, last: Boolean): Array { # {{{
		var result = []

		for var key in tree.order {
			buildMax(tree.columns[key], last, result, {})
		}

		return result
	} # }}}
	func buildMax(tree: TreeBranch, last: Boolean, result: Array, nodes: Object): Void { # {{{
		nodes[tree.index] = {
			index: tree.index
			type: tree.type
			min: tree.min
			max: tree.max
			rest: tree.rest
		}

		for var key in tree.order {
			buildMax(tree.columns[key], last, result, nodes)
		}
	} # }}}
	func buildMax(tree: TreeLeaf, last: Boolean, result: Array, nodes: Object): Void { # {{{
		nodes[tree.index] = {
			index: tree.index
			type: tree.type
			min: tree.min
			max: tree.max
			rest: tree.rest
		}

		var parameters = {}

		for var type in tree.rows[0].types desc {
			if var parameter ?= nodes[type.index] {
				parameters[type.parameter] = parameter
			}
		}

		result.push(parameters)
	} # }}}

	func buildMin(tree: Tree): Array { # {{{
		var result = []

		for var key in tree.order {
			buildMin(tree.columns[key], result, [])
		}

		return result
	} # }}}
	func buildMin(tree: TreeBranch, result: Array, parameters: Array): Void { # {{{
		parameters.unshift(tree.index, tree.type.hashCode(true), tree.min)

		for var key in tree.order {
			buildMin(tree.columns[key], result, parameters)
		}
	} # }}}
	func buildMin(tree: TreeLeaf, result: Array, parameters: Array): Void { # {{{
		parameters.unshift(tree.index, tree.type.hashCode(true), tree.min)

		var mins = []

		for var type in tree.rows[0].types desc {
			if parameters[0] == type.index {
				parameters.shift()

				mins.push(type.parameter, parameters.shift(), parameters.shift())
			}
		}

		result.push(mins)

		parameters.clear()
	} # }}}

	func getArgumentsHash(tree: Tree): String { # {{{
		if tree.order.length == 0 {
			return `\(tree.function.index());`
		}
		else {
			var mut hash = ''

			for var key in tree.order {
				hash += getArgumentsHash(tree.columns[key])
			}

			return hash
		}
	} # }}}
	func getArgumentsHash(tree: TreeBranch): String { # {{{
		var mut hash = ''

		for var key in tree.order {
			hash += getArgumentsHash(tree.columns[key])
		}

		return hash
	} # }}}
	func getArgumentsHash(tree: TreeLeaf): String { # {{{
		var index = tree.function.index()

		return `\(index);`
	} # }}}

	func getValidNode(index: Number, data: Object, parameters: Object): Number { # {{{
		return getValidNodeLoop(index, data, parameters) ?? index
	} # }}}

	func getValidNodeLoop(index: Number, data: Object, parameters: Object): Number? { # {{{
		if var maximus ?= data[index] {
			if maximus.min != maximus.max || maximus.rest {
				return index
			}

			if var parameter ?= parameters[index] {
				if parameter.min != maximus.max {
					return index
				}
			}
			else {
				return index
			}
		}

		if index > 0 {
			return getValidNodeLoop(index - 1, data, parameters)
		}
		else {
			return null
		}
	} # }}}

	func isSameShadows(a: Array, b: Array): Boolean { # {{{
		return false unless a.length == b.length

		for var i from 0 til a.length {
			return false unless a[i].length == b[i].length
			return false unless a[i][0] == b[i][0]
			return false unless a[i][1] == b[i][1]
		}

		return true
	} # }}}

	func listEquivalentHashes(tree: Tree): String[] { # {{{
		if tree.order.length == 0 {
			return [`\(tree.function.index());`]
		}
		else if ?tree.equivalences {
			var mut orders = [tree.order]

			for var eq in tree.equivalences {
				orders = replaceOrder(eq, orders)
			}

			var result = []

			for var order in orders {
				var mut hashes = ['']

				for var key in order {
					hashes = listEquivalentHashes(tree.columns[key], hashes)
				}

				result.push(...hashes)
			}

			return result
		}
		else {
			var mut hashes = ['']

			for var key in tree.order {
				hashes = listEquivalentHashes(tree.columns[key], hashes)
			}

			return hashes
		}
	} # }}}
	func listEquivalentHashes(tree: TreeBranch, mut hashes: String[]): String[] { # {{{
		if ?tree.equivalences {
			var mut orders = [tree.order]

			for var eq in tree.equivalences {
				orders = replaceOrder(eq, orders)
			}

			var result = []

			for var order in orders {
				var mut h = [...hashes]

				for var key in order {
					h = listEquivalentHashes(tree.columns[key], h)
				}

				result.push(...h)
			}

			return result
		}
		else {
			for var key in tree.order {
				hashes = listEquivalentHashes(tree.columns[key], hashes)
			}

			return hashes
		}
	} # }}}
	func listEquivalentHashes(tree: TreeLeaf, hashes: String[]): String[] { # {{{
		var index = tree.function.index()

		for var hash, i in hashes {
			hashes[i] += `\(index);`
		}

		return hashes
	} # }}}

	func listShadows(tree: Tree, data: Array, ceiling: Number): Array { # {{{
		var newData = [...data]
		var results = [ShadowKind::None]

		for var key in tree.order {
			listShadows(tree.columns[key], tree.max, ceiling, newData, {}, results)
		}

		return results
	} # }}}
	func listShadows(tree: TreeBranch, max: Number, ceiling: Number, data: Array, nodes: Object, results: Array): Void { # {{{
		nodes[tree.index] = {
			type: tree.type
			min: tree.min
			max: tree.max
		}

		for var key in tree.order {
			listShadows(tree.columns[key], max, ceiling, data, nodes, results)
		}
	} # }}}
	func listShadows(tree: TreeLeaf, max: Number, ceiling: Number, data: Array, nodes: Object, results: Array): Void { # {{{
		nodes[tree.index] = {
			type: tree.type
			min: tree.min
			max: tree.max
		}

		var result = [ShadowKind::None, -1]

		if data.length != 0 {
			var data = data.shift()

			var parameters = {}

			for var type in tree.rows[0].types {
				if var parameter ?= nodes[type.index] {
					parameters[type.parameter] = parameter
				}
			}

			var arguments = []
			var dyn left = max
			var dyn lastIndex = -1
			var mut canNegLength0 = true
			var mut useNegLength0 = false
			var mut useNegLengthN = true
			var mut length = tree.rows[0].function.parameters().length

			if tree.rows[0].function.isAsync() {
				length += 1
			}

			for var index from 0 til length {
				if var maximus ?= data[index] {
					if var parameter ?= parameters[index] {

						if left < parameter.min {
							for var i from 1 to parameter.min {
								if var argType ?= arguments.shift() {
									if parameter.type.isAssignableToVariable(argType, false, false, false, true) || (argType.isNullable() && parameter.type.isNullable()) {
										if useNegLength0 {
											useNegLength0 = false

											setResult(result, ShadowKind::Soft, lastIndex, max, ceiling, data, parameters)
										}
										else if useNegLengthN {
											useNegLengthN = false

											if parameter.min != maximus.max {
												setResult(result, ShadowKind::Hard, lastIndex, max, ceiling, data, parameters)
											}
											else {
												setResult(result, ShadowKind::Soft, lastIndex, max, ceiling, data, parameters)
											}
										}
										else {
											setResult(result, ShadowKind::Hard, lastIndex, max, ceiling, data, parameters)
										}
									}
									else if argType.isAssignableToVariable(parameter.type, false, true, false) {
										if useNegLength0 {
											useNegLength0 = false
										}
										else if useNegLengthN {
											useNegLengthN = false

											if parameter.min != maximus.max && parameter.min != arguments.length + 1 {
												setResult(result, ShadowKind::Hard, lastIndex, max, ceiling, data, parameters)
											}
											else {
												setResult(result, ShadowKind::Soft, lastIndex, max, ceiling, data, parameters)
											}
										}
										else {
											setResult(result, ShadowKind::Hard, lastIndex, max, ceiling, data, parameters)
										}
									}
								}
							}
						}
						else if left > parameter.min {
							for var i from 1 to Math.min(parameter.min, arguments.length) {
								if var argType ?= arguments.shift() {
									var assignable = parameter.type.isAssignableToVariable(argType, false, false, false, true)
									if (assignable && argType.isNullable()) || (!assignable && parameter.type.isAssignableToVariable(argType, false, true, false, true)) {
										setResult(result, ShadowKind::Hard, lastIndex, max, ceiling, data, parameters)
									}
								}
							}
						}

						for var i from parameter.min til maximus.max {
							arguments.unshift(parameter.type)
						}

						canNegLength0 = false
					}
					else {
						for var i from 0 til maximus.max {
							arguments.unshift(maximus.type)
						}

						if useNegLength0 {
							useNegLength0 = false
						}
						else if canNegLength0 {
							useNegLength0 = true
							canNegLength0 = false
						}

						if !maximus.rest && maximus.max <= 1 {
							useNegLengthN = false
						}
					}

					lastIndex = index

					left -= maximus.max
				}
			}
		}

		results.push(result)

		if result[0] > results[0] {
			results[0] = result[0]
		}
	} # }}}

	func regroupTreesByGroup(mut group: Tree[], trees: Tree[], last: Tree, mut shadows: Array): Void { # {{{
		var tree = group.pop()
		var max = tree.max

		var maxs = buildMax(tree, tree == last)
		var mut lastMatches = null

		for var tree, index in group desc {
			var mut [kind, ...matches] = listShadows(tree, maxs, max)

			if kind == ShadowKind::Soft {
				shadows = matches
			}
			else if kind == ShadowKind::Hard {
				if !?lastMatches {
					lastMatches = matches
				}
				else {
					if isSameShadows(lastMatches, matches) {
						regroupTreesByGroup(group.slice(0, index + 2), trees, last, lastMatches)

						group = group.slice(index + 2)
					}
					else {
						regroupTreesByGroup(group.slice(0, index + 1), trees, last, [])

						group = group.slice(index + 1)

						shadows.push(...lastMatches)
					}

					lastMatches = null

					break
				}
			}
		}

		if ?lastMatches {
			regroupTreesByGroup(group.slice(0, 1), trees, last, [])

			group = group.slice(1)
		}

		return if group.length == 0

		var first = group[0]

		var mins = buildMin(first)

		trees.remove(...group)

		applyMin(tree, first, mins, shadows)
	} # }}}

	func replaceOrder(equivalences: String[], orders: String[][]): String[][] { # {{{
		var mut result = [...orders]

		for var eq1, index in equivalences {
			for var eq2 in equivalences from index + 1 {
				for var order in orders {
					var index1 = order.indexOf(eq1)

					if index1 != -1 {
						var index2 = order.indexOf(eq2)

						if index2 != -1 {
							var match = [...order]

							match[index1] = eq2
							match[index2] = eq1

							result.push(match)

							break
						}
					}
				}
			}
		}

		return result
	} # }}}

	func setResult(result: Array, mut kind: ShadowKind, mut index: Number, max: Number, ceiling: Number, data: Object, parameters: Object): Void { # {{{
		index = getValidNode(index, data, parameters)

		if kind == ShadowKind::Soft {
			if var maximus ?= data[index] {
				if ceiling - max > maximus.max && !maximus.rest {
					kind = ShadowKind::Hard
				}
			}
		}

		if kind == ShadowKind::Soft {
			if result[0] == ShadowKind::None {
				result[0] = ShadowKind::Soft
				result[1] = index
			}
		}
		else {
			if result[0] != ShadowKind::Hard {
				result[0] = ShadowKind::Hard
				result[1] = index
			}
		}
	} # }}}
}
