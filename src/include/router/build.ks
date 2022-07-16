func buildTree(group: Group, name: String, ignoreIndistinguishable: Boolean, excludes: Array<String>?, node: AbstractNode): Tree { // {{{
	if group.n == 0 {
		return buildZeroTree(group, name, node)
	}

	if group.n == 1 {
		expandOneGroup(group, name, ignoreIndistinguishable, excludes, node)
	}
	else {
		expandGroup(group, name, ignoreIndistinguishable, excludes, node)
	}

	if isFlattenable(group, excludes, node) {
		return buildFlatTree(group.functions[0], group.rows, group.n, excludes, node)
	}
	else {
		const tree = createTree(group.rows, group.n)

		if group.n > 1 {
			for const column, key of tree.columns when column.isNode {
				tree.columns[key] = buildNode(tree, column!!, 1, group.n, name, node)
			}
		}

		tree.order = sortNodes(tree.columns)

		if group.n == 1 {
			regroupLeaf_SiblingsEq(tree, node)
		}

		regroupBranch_Children_ForkAlike_SiblingsEq(tree, node)

		return tree
	}
} // }}}

func buildFlatTree(function: FunctionType, rows, n: Number, excludes: Array<String>?, node: AbstractNode) { // {{{
	const arguments = {}
	const parameters = {}
	auto lastIndex = 0

	let fnParameters = function.parameters(excludes)

	if function.isAsync() {
		const scope = node.scope()

		fnParameters = [...fnParameters, new ParameterType(scope, scope.reference('Function'))]
	}

	for const row of rows {
		for const type in row.types {
			if !?parameters[type.parameter] {
				parameters[type.parameter] = {
					index: type.parameter
					parameter: fnParameters[type.parameter]
					argIndex: type.index
				}

				if type.parameter > lastIndex {
					lastIndex = type.parameter
				}
			}
		}
	}

	for const row of rows {
		const args = {}

		for const type in row.types {
			if args[type.parameter]? {
				args[type.parameter] += 1
			}
			else {
				args[type.parameter] = 1
			}
		}

		auto last = -1

		for const { index } of parameters {
			while ++last < index {
				if const argument = arguments[last] {
					arguments[last].push(0)
				}
				else {
					arguments[last] = [0]
				}
			}

			const size = args[index] ?? 0

			if const argument = arguments[index] {
				arguments[index].push(size)
			}
			else {
				arguments[index] = [size]
			}
		}
	}

	let argCount = 0

	for const parameter of parameters {
		parameter.argIndex = argCount
		parameter.min = Math.min(...arguments[parameter.index])
		parameter.max = Math.max(...arguments[parameter.index])

		++argCount

		const type = parameter.parameter.getArgumentType()

		if type.isNullable() {
			const types = type.split([Type.Null])

			parameter.argType = Type.union(node.scope(), ...types).sort()
		}
		else {
			parameter.argType = type.sort()
		}
	}

	const row = Row(
		function
		key: ''
		types: []
	)

	let afterRest = false

	for const { parameter, index, argIndex, argType: type } of parameters {
		const hash = type.hashCode()
		const key = `;\(afterRest ? argIndex - argCount : argIndex);\(hash)`
		const rest = parameter.max() == Infinity

		row.key += key
		row.types.push(RowType(
			index: (afterRest ? argIndex - argCount : argIndex) as Number
			type: type as Type
			rest
			parameter: index as Number
		))

		if rest {
			afterRest = true
		}
	}

	const tree = Tree(n)
	let column = tree
	let variadic = false

	afterRest = false

	for const { parameter, index, argIndex, argType: type } of parameters {
		const hash = type.hashCode()
		const key = `:\(function.index()):\(index)`
		const rest = parameter.max() == Infinity
		const { min, max } = parameters[index]

		if !variadic && min != max {
			variadic = true
		}

		if index == lastIndex {
			column.columns[hash] = TreeLeaf(
				index: (afterRest ? argIndex - argCount : argIndex) as Number
				type: type as Type
				min: min as Number
				max: max as Number
				variadic
				rest
				isNode: false
				parameters: {
					[key]: TreeParameter(
						key
						function
						parameter: index as Number
						rows: [row.key]
					)
				}
				function
				arguments: []
				rows: [row]
			)
		}
		else {
			column.columns[hash] = TreeBranch(
				index: (afterRest ? argIndex - argCount : argIndex) as Number
				type: type as Type
				min: min as Number
				max: max as Number
				variadic
				rest
				parameters: {
					[key]: TreeParameter(
						key
						function
						parameter: index as Number
						rows: [row.key]
					)
				}
				rows: [row]
				columns: {}
				isNode: true
			)
		}

		column.order = [hash]

		column = column.columns[hash]

		if rest {
			afterRest = true
		}
	}

	tree.variadic = variadic

	return tree
} // }}}

func buildNode(tree: Tree, branch: TreeBranch, pIndex: Number, max: Number, name: String, node: AbstractNode): TreeColumn { // {{{
	const usages: Dictionary<Number> = {}
	for const row in branch.rows {
		const index = row.function.index()

		usages[index] = (usages[index] ?? 0) + 1
	}

	const next = pIndex + 1

	if next == max {
		for const row in branch.rows {
			const {type, index, rest, parameter} = row.types[pIndex]
			const hash = type.hashCode()

			if const match = branch.columns[hash] {
				SyntaxException.throwIndistinguishableFunctions(name, match.rows[0].types.map(({ type }, _, _) => type), [match:TreeLeaf.function, row.function], node)
			}

			const key = `:\(row.function.index()):\(parameter)`

			branch.columns[hash] = TreeLeaf(
				index
				type
				rest
				variadic: rest
				isNode: false
				parameters: {
					[key]: TreeParameter(
						key
						function: row.function
						parameter
						rows: [row.key]
					)
				}
				function: row.function
				arguments: []
				rows: [row]
			)
		}
	}
	else {
		for const row in branch.rows {
			const {type, index, rest, parameter} = row.types[pIndex]
			const hash = type.hashCode()
			const key = `:\(row.function.index()):\(parameter)`

			if !?branch.columns[hash] {
				branch.columns[hash] = TreeBranch(
					index
					type
					rest
					variadic: rest
					parameters: {
						[key]: TreeParameter(
							key
							function: row.function
							parameter
							rows: [row.key]
						)
					}
					rows: [row]
					columns: {}
					isNode: true
				)
			}
			else {
				const branch: TreeBranch = branch.columns[hash]!!

				branch.rows.push(row)

				if !?branch.parameters[key] {
					branch.parameters[key] = TreeParameter(
						key
						function: row.function
						parameter
						rows: [row.key]
					)
				}
				else {
					branch.parameters[key].rows.push(row.key)
				}
			}
		}

		for const child, key of branch.columns when child.isNode {
			branch.columns[key] = buildNode(tree, child!!, next, max, name, node)
		}
	}

	branch.order = sortNodes(branch.columns)

	resolveBackTracing(branch, max)

	if next == max {
		regroupLeaf_SiblingsEq(branch, node)
	}

	regroupBranch_TopForkEqLastChild(branch)

	regroupBranch_ForkEq_ChildrenEqFunc(branch)

	regroupBranch_SiblingsEqChildren(branch)

	regroupBranch_ChildrenEqFunc_Flatten(branch, node)

	regroupBranch_Children_ForkAlike_SiblingsEq(branch, node)

	branch = regroupBranch_EqParameter(branch)

	return branch
} // }}}

func buildZeroTree(group: Group, name: String, node: AbstractNode): Tree { // {{{
	auto master = group.functions[0]
	const sameLength = []

	for const function in group.functions from 1 {
		if function.max() == master.max() {
			sameLength.push(function)
		}
		else if function.max() < master.max() {
			master = function
		}
	}

	if sameLength.length != 0 {
		let errors = []

		for const function in sameLength {
			if function.isMorePreciseThan(master) {
				// do nothing
			}
			else if master.isMorePreciseThan(function) {
				master = function

				errors = errors.filter((error, _, _) => !error.isMorePreciseThan(master))
			}
			else {
				errors.push(function)
			}
		}

		if master.max() != 0 && errors.length != 0 {
			SyntaxException.throwIndistinguishableFunctions(name, [], [master, ...errors], node)
		}
	}

	return Tree(
		min: 0
		function: master
	)
} // }}}

func createTree(rows: Dictionary<Row>, min: Number): Tree { // {{{
	const tree = Tree(min)

	const usages: Dictionary<Number> = {}
	for const _, key of rows {
		const index = rows[key].function.index()

		usages[index] = (usages[index] ?? 0) + 1
	}

	if min == 1 {
		for const row of rows {
			const {type, index, rest, parameter} = row.types[0]
			const hash = type.hashCode()

			if ?tree.columns[hash] {
				NotSupportedException.throw()
			}

			const key = `:\(row.function.index()):\(parameter)`

			tree.columns[hash] = TreeLeaf(
				index
				type
				rest
				variadic: rest
				isNode: false
				parameters: {
					[key]: TreeParameter(
						key
						function: row.function
						parameter
						rows: [row.key]
					)
				}
				function: row.function
				arguments: []
				rows: [row]
			)
		}
	}
	else {
		for const row of rows {
			const {type, index, rest, parameter} = row.types[0]
			const hash = type.hashCode()
			const key = `:\(row.function.index()):\(parameter)`

			if !?tree.columns[hash] {
				tree.columns[hash] = TreeBranch(
					index
					type
					rest
					variadic: rest
					parameters: {
						[key]: TreeParameter(
							key
							function: row.function
							parameter
							rows: [row.key]
						)
					}
					rows: [row]
					columns: {}
					isNode: true
				)
			}
			else {
				const branch: TreeBranch = tree.columns[hash]!!

				if branch.index < 0 && index >= 0 {
					for const row in branch.rows {
						for const type in row.types when type.index == branch.index {
							type.index = index
						}
					}

					branch.index = index
				}

				branch.rows.push(row)

				if !?branch.parameters[key] {
					branch.parameters[key] = TreeParameter(
						key
						function: row.function
						parameter
						rows: [row.key]
					)
				}
				else {
					branch.parameters[key].rows.push(row.key)
				}

				if !rest && branch.rest {
					branch.rest = false
					branch.variadic = false
				}
			}
		}
	}

	return tree
} // }}}

func expandOneGroup(group: Group, name: String, ignoreIndistinguishable: Boolean, excludes: Array<String>?, node: AbstractNode): Void { // {{{
	for const function in group.functions {
		let argIndex = 0
		let min = function.min(excludes)
		let parameters = function.parameters(excludes)

		if function.isAsync() {
			const scope = node.scope()

			++min
			parameters = [...parameters, new ParameterType(scope, scope.reference('Function'))]
		}

		if min == 1 {
			let nullTested = false

			for const parameter, index in parameters {
				if parameter.min() == 1 {
					const type = parameter.type()

					addOneGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, type, nullTested, null, index, argIndex)

					if type.isNullable() {
						nullTested = true
					}

					break
				}

				if parameter.max() == Infinity {
					argIndex = -1
				}
			}
		}
		else {
			const types = []
			let nullTested = false

			for const parameter, index in parameters {
				const type = parameter.type()
				let addable = true

				for const t in types while addable {
					if type.isAssignableToVariable(t, false, false, true) {
						addable = false
					}
				}

				if addable {
					addOneGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, type, nullTested, null, index, argIndex)

					types.push(type)

					if type.isNullable() {
						nullTested = true
					}
				}

				if parameter.max() == Infinity {
					argIndex = -1
				}
			}
		}
	}
} // }}}

func addOneGroupRow(group: Group, name: String, ignoreIndistinguishable: Boolean, node: AbstractNode, function: FunctionType, parameters: Array<ParameterType>, parameter: ParameterType, type: Type, nullTested: Boolean, union: UnionMatch?, paramIndex: Number, argIndex: Number) { // {{{
	if type.isSplittable() {
		const types = type.split([])
		const union = UnionMatch(
			function
			length: types.length
			matches: []
		)

		if nullTested {
			for const type in types when !type.isNull() {
				addOneGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, type, nullTested, union, paramIndex, argIndex)
			}
		}
		else {
			for const type in types {
				addOneGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, type, nullTested, union, paramIndex, argIndex)
			}
		}
	}
	else {
		const key = `;\(argIndex);\(type.hashCode())`
		const rest = parameter.max() == Infinity

		let addable = true

		if rest {
			for const parameter in parameters from paramIndex + 1 while addable {
				if type.isAssignableToVariable(parameter.type(), false, false, true) {
					addable = false
				}
			}
		}

		if addable {
			let matchFunction = null
			let matchUnion = null
			if ?group.rows[key] {
				matchFunction = group.rows[key].function
				matchUnion = group.rows[key].union
			}
			else if argIndex == -1 && ?group.rows[`;0;\(type.hashCode())`] {
				matchFunction = group.rows[`;0;\(type.hashCode())`].function
				matchUnion = group.rows[`;0;\(type.hashCode())`].union
			}
			else {
				group.rowCount++
			}

			if ?matchFunction {
				if function.max() == matchFunction.max() {
					if ?matchUnion {
						if ?union {
							SyntaxException.throwIndistinguishableFunctions(name, [type], [function, matchFunction], node) unless ignoreIndistinguishable
						}
						else {
							matchUnion.matches.push([type, function])

							if matchUnion.matches.length == matchUnion.length {
								SyntaxException.throwShadowFunction(name, matchFunction, node)
							}
						}
					}
					else {
						if ?union {
							union.matches.push([type, matchFunction])

							if union.matches.length == union.length {
								SyntaxException.throwShadowFunction(name, function, node)
							}

							addable = false
						}
						else {
							SyntaxException.throwIndistinguishableFunctions(name, [type], [function, matchFunction], node) unless ignoreIndistinguishable
						}
					}
				}
				else if function.max() >= matchFunction.max() {
					addable = false
				}
			}
		}

		if addable {
			group.rows[key] = Row(
				key
				function
				union
				types: [
					RowType(
						index: argIndex
						type
						rest
						parameter: paramIndex
					)
				]
			)
		}
	}
} // }}}

func expandGroup(group: Group, name: String, ignoreIndistinguishable: Boolean, excludes: Array<String>?, node: AbstractNode): Void { // {{{
	for const function in group.functions {
		let min = function.min(excludes)
		let minAfter = function.getMinAfter(excludes)
		let parameters = function.parameters(excludes)

		if function.isAsync() {
			const scope = node.scope()

			++min
			++minAfter
			parameters = [...parameters, new ParameterType(scope, scope.reference('Function'))]
		}

		expandFunction(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, group.n, group.n - min, 0, 0, 0, -1, '', [])
	}
} // }}}

func expandFunction(group: Group, name: String, ignoreIndistinguishable: Boolean, node: AbstractNode, function: FunctionType, parameters: Array<ParameterType>, minAfter: Number, target: Number, remaining: Number, paramIndex: Number, stepIndex: Number, stepCount: Number, argIndex: Number, key: String, types: Array<RowType>): Void { // {{{
	if types.length == target {
		if const match = group.rows[key] {
			if function == match.function {
				group.rows[key] = Row(
					key
					function
					types
				)
			}
			else if function.max() == match.function.max() {
				SyntaxException.throwIndistinguishableFunctions(name, match.types.map(({ type }, _, _) => type), [function, match.function], node) unless ignoreIndistinguishable
			}
			else if function.max() < match.function.max() {
				group.rows[key] = Row(
					key
					function
					types
				)
			}
		}
		else {
			group.rows[key] = Row(
				key
				function
				types
			)

			group.rowCount++
		}
	}
	else if paramIndex < parameters.length || (function.isAsync() && paramIndex == parameters.length) {
		const parameter = parameters[paramIndex]
		const type = parameter.getArgumentType()
		const min = parameter.min()
		const max = parameter.max()

		if stepIndex == 0 {
			if stepCount < min {
				expandParameter(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex, 0, stepCount + 1, max == Infinity, argIndex + 1, key, types, type)
			}
			else {
				const rest = max == Infinity

				if paramIndex + 1 < parameters.length {
					if rest {
						expandFunction(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, -remaining - minAfter - 1, key, types)
					}
					else {
						if stepCount == max || hasMin(type, paramIndex + 1, parameters, remaining) {
							expandFunction(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, argIndex, key, types)
						}
					}
				}

				if rest {
					for const i from 1 to getMaxRestExpand(paramIndex, parameters, remaining, function) {
						expandParameter(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining - 1, paramIndex, i, 1, rest, argIndex + 1, key, [...types], type)
					}
				}
				else {
					for const i from 1 to Math.min(max - min, remaining) {
						expandParameter(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining - 1, paramIndex, i, 1, rest, argIndex + 1, key, [...types], type)
					}
				}
			}
		}
		else if stepCount < stepIndex {
			expandParameter(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining - 1, paramIndex, stepIndex, stepCount + 1, max == Infinity, argIndex + 1, key, types, type)
		}
		else {
			if max == Infinity {
				expandFunction(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, -remaining - minAfter - 1, key, types)
			}
			else if remaining == 0 || stepCount + min >= max || hasMin2(type, paramIndex + 1, parameters) {
				expandFunction(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, argIndex, key, types)
			}
		}
	}
} // }}}

func getMaxRestExpand(restIndex: Number, parameters: Array<ParameterType>, remaining: Number, function: FunctionType): Number { // {{{
	let min = function.getMinAfter()
	let max = function.getMaxAfter()

	return remaining if min == max

	if function.isAsync() {
		++min
		++max
	}

	const restType = parameters[restIndex].type()
	auto count = remaining
	auto delta = 0
	auto addToCount = true

	for const parameter in parameters from restIndex + 1 {
		const d = parameter.max() - parameter.min()

		if d == 0 && delta != 0 {
			count += delta

			delta = 0
		}

		if restType.isAssignableToVariable(parameter.type(), false, false, true) {
			if addToCount {
				count -= d!?
			}
			else {
				delta -= d!?
			}
		}
		else {
			delta += parameter.min() as Number

			if d == 0 {
				addToCount = false
			}
		}
	}

	return Math.min(count, remaining)
} // }}}

func hasMin(type: Type, index: Number, parameters: Array<ParameterType>, remaining: Number): Boolean { // {{{
	for const parameter in parameters from index {
		if (remaining == 0 && parameter.min() > 0) || !parameter.type().isAssignableToVariable(type, false, false, true) {
			return true
		}
	}

	return false
} // }}}

func hasMin2(type: Type, index: Number, parameters: Array<ParameterType>): Boolean { // {{{
	for const parameter in parameters from index {
		if !parameter.type().isAssignableToVariable(type, false, false, true) {
			return true
		}
	}

	return false
} // }}}

func expandParameter(group: Group, name: String, ignoreIndistinguishable: Boolean, node: AbstractNode, function: FunctionType, parameters: Array<ParameterType>, minAfter: Number, target: Number, remaining: Number, paramIndex: Number, stepIndex: Number, stepCount: Number, rest: Boolean, argIndex: Number, key: String, types: Array<RowType>, type: Type): Void { // {{{
	if type.isUnion() {
		for const value in type.discard():UnionType.types() {
			expandParameter(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex, stepIndex, stepCount, rest, argIndex, key, types, value)
		}
	}
	else {
		const key = `\(key);\(argIndex);\(type.hashCode())`

		const types = [...types]

		types.push(RowType(
			index: argIndex
			type
			rest
			parameter: paramIndex
		))

		expandFunction(group, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex, stepIndex, stepCount, argIndex, key, types)
	}
} // }}}

func regroupBranch_EqParameter(branch: TreeBranch): TreeBranch { // {{{
	const columns = Dictionary.values(branch.columns)

	if	columns.length == 1 &&
		Dictionary.length(branch.parameters) == 1 &&
		Dictionary.length(columns[0].parameters) == 1 &&
		Dictionary.value(branch.parameters, 0).key == Dictionary.value(columns[0].parameters, 0).key &&
		branch.type.hashCode() == branch.order[0]
	{
		const child = columns[0]

		child.index = branch.index
		child.min += branch.min
		child.max += branch.max

		return child
	}
	else {
		return branch
	}
} // }}}

func regroupBranch_ForkEq_TopChildrenEqFunc(branch: TreeBranch) { // {{{
	if branch.order.length >= 2 {
		const type = branch.type.hashCode()

		if const column = branch.columns[type] {

			if isSameFork(branch, column) {
				if const column2 = Dictionary.values(branch.columns).find((c, _, _) => c != column && isSameFunction(column, c)) {
					let regroup = false

					if !column.isNode && !column2.isNode && column2.index > 0 {
						regroup = true
					}

					if regroup {
						branch.max += column.max
						branch.variadic = true

						column2.min = Math.max(0, column2.min - column.min)
						column2.variadic = true

						delete branch.columns[type]

						branch.order.remove(type)
					}
				}
			}
		}
	}
} // }}}

func regroupBranch_ForkEq_ChildrenEqFunc(branch: TreeBranch) { // {{{
	return unless branch.order.length >= 2

	const type = branch.type.hashCode()

	return unless branch.order[0] == type

	const column = branch.columns[type]!?

	if isSameFork(branch, column) {

		if isRegroupeableBranch2(branch, column, type) {
			branch.max += column.max
			branch.variadic = true

			const mins = {}

			for const key in column.order {
				mins[key] = buildMin(column.columns[key])
			}

			applyMin2(branch, mins, type)

			delete branch.columns[type]

			branch.order.remove(type)
		}
		else if !column.isNode {
			if const column2 = Dictionary.values(branch.columns).find((c, _, _) => c != column && !c.isNode && c.index > 0 && isSameFunction(column, c)) {
				branch.max += column.max
				branch.variadic = true

				column2.min = Math.max(0, column2.min - column.min)
				column2.variadic = true

				delete branch.columns[type]

				branch.order.remove(type)
			}
		}
	}
} // }}}

func applyMin2(tree: TreeBranch, mins, type) { // {{{
	for const key in tree.order when key != type {
		const node = tree.columns[key]

		if const m = mins[key] {
			applyMin(node, m as Array)
		}
		else {
			node.min = 0
			node.variadic = true

			if node.isNode {
				applyMin2(node as TreeBranch, mins, type)
			}
		}
	}
} // }}}

func toSignature3(tree: TreeBranch, withRoot: Boolean, type: String?) { // {{{
	let s = withRoot ? `/\(tree.type.hashCode())()` : ''

	if type? {
		for const key, i in tree.order when key != type {
			s += toSignature3(tree.columns[key], true, null)
		}
	}
	else {
		for const key, i in tree.order {
			s += toSignature3(tree.columns[key], true, null)
		}
	}

	return s
} // }}}

func toSignature3(tree: TreeLeaf, withRoot: Boolean, type: String?) { // {{{
	return `/\(tree.type.hashCode())()=\(tree.function.index())`
} // }}}

func isRegroupeableBranch2(tree1: TreeBranch, tree2: TreeBranch) { // {{{
	for const key in tree2.order {
		return false if tree2.columns[key].type.isAssignableToVariable(tree2.type, false, false, false)
		return false unless tree1.columns[key]?
		return false unless isRegroupeableBranch2(tree1.columns[key], tree2.columns[key])
	}

	return true
} // }}}

func isRegroupeableBranch2(tree1: TreeBranch, tree2: TreeBranch, type: String) { // {{{
	for const key in tree1.order when key != type {
		return false unless tree2.columns[key]?
		return false unless isRegroupeableBranch2(tree1.columns[key], tree2.columns[key])
	}

	return true
} // }}}

func isRegroupeableBranch2(tree1: TreeBranch, tree2: TreeLeaf, type: String) { // {{{
	for const key in tree1.order when key != type {
		return false
	}

	return true
} // }}}

func isRegroupeableBranch2(tree1: TreeBranch | TreeLeaf, tree2: TreeLeaf) { // {{{
	const val1 = tree1.type.hashCode()
	const val2 = tree2.type.hashCode()

	return false unless val1 == val2

	return isRegroupeableBranch2(tree1, tree2.function.index())
} // }}}

func isRegroupeableBranch2(tree1: TreeLeaf, tree2: TreeBranch) { // {{{
	return false
} // }}}

func isRegroupeableBranch2(tree: TreeBranch, function: Number) { // {{{
	for const key in tree.order {
		return false unless isRegroupeableBranch2(tree.columns[key], function)
	}

	return true
} // }}}

func isRegroupeableBranch2(tree: TreeLeaf, function: Number) { // {{{
	return tree.function.index() == function
} // }}}

func regroupBranch_ChildrenEqFunc_Flatten(branch: TreeBranch, node: AbstractNode) { // {{{
	return unless branch.order.length >= 2

	let first = branch.columns[branch.order[0]]

	if const function = getFunction(branch) {
		const param2row = {}
		for const parameter, key of branch.parameters {
			param2row[key] = parameter.rows
		}
		for const parameter, key of first.parameters {
			if const rows = param2row[key] {
				for const row in parameter.rows {
					return unless rows:Array.contains(row)
				}
			}
		}

		const rows = [...first.rows]

		for const key in branch.order from 1 {
			const column = branch.columns[key]

			if branch.type.isAssignableToVariable(column.type, false, true, false) {
				return
			}

			rows.pushUniq(...column.rows)
		}

		const column = buildBranchFromRows(rows, branch.index + 1, node)
		const type = column.type.hashCode()

		branch.columns = {
			[type]: column
		}
		branch.order = [type]
	}
} // }}}

func getFunction(tree: TreeBranch) { // {{{
	const function = getFunction(tree.columns[tree.order[0]])

	for const key in tree.order from 1 {
		if getFunction(tree.columns[key]) != function {
			return null
		}
	}

	return function
} // }}}

func getFunction(tree: TreeLeaf) { // {{{
	return tree.function
} // }}}

func applyMax2(tree: TreeBranch, maxs) { // {{{
	const setter = (node, value = null) => {
		if value != null && value > node.max {
			node.max = value
		}
	}

	applyMinMax(tree, setter, maxs, [], [])
} // }}}

func regroupBranch_SiblingsEqChildren(branch: TreeBranch) { // {{{
	for const type, index in branch.order from branch.order.length - 2 by -1 {
		const column = branch.columns[type]

		if getForkHash2(branch, index + 1) == getForkHash2(column, 0) && isSameParameter2(column, branch.columns[branch.order[index + 1]]) {
			column.min = 0
			column.variadic = true

			for const col, type of column.columns {
				col.max = branch.columns[type].max

				delete branch.columns[type]

				branch.order.remove(type)
			}
		}
	}
} // }}}

func isSameParameter2(branch: TreeBranch | TreeLeaf, node: TreeBranch | TreeLeaf): Boolean { // {{{
	for const _, key of branch.parameters {
		if !?node.parameters[key] {
			return false
		}
	}

	return true
} // }}}

func regroupLeaf_SiblingsEq(branch: TreeBranch | Tree, node: AbstractNode) { // {{{
	const groups = {}

	for const type, index in branch.order from branch.order.length - 2 by -1 {
		const column = branch.columns[type]

		if column.isNode {
			continue
		}

		const type2 = branch.order[index + 1]
		const column2 = branch.columns[type2]

		if column2.isNode {
			continue
		}

		if Array.same(Dictionary.keys(column.parameters), Dictionary.keys(column2.parameters)) {
			if groups[index + 1]? {
				groups[index] = groups[index + 1]

				delete groups[index + 1]

				groups[index].unshift(type)
			}
			else {
				groups[index] = [type, type2]
			}
		}
	}

	if groups.length != 0 {
		const scope = node.scope()

		for const group of groups {
			const column = branch.columns[group[0]]

			const type = Type.union(scope, ...[branch.columns[key].type for const key in group]).sort()

			for const key in group {
				delete branch.columns[key]
			}

			column.type = type

			branch.columns[type.hashCode()] = column
		}

		branch.order = sortNodes(branch.columns)
	}
} // }}}

func regroupTreeByIndex(tree: Tree | TreeBranch, node: AbstractNode) { // {{{
	const groups = {}

	for const column, key of tree.columns {
		const hash = getIndexHash(column)

		if const group = groups[hash] {
			group.keys.push(key)
			group.columns.push(column)
		}
		else {
			groups[hash] = {
				keys: [key]
				columns: [column]
			}
		}
	}

	const scope = node.scope()

	for const group of groups when group.columns.length > 1 {
		for const key in group.keys {
			delete tree.columns[key]
		}

		const type = Type.union(scope, ...[column.type for const column in group.columns]).sort()

		const column = group.columns[0]

		column.type = type

		tree.columns[type.hashCode()] = column

		tree.order = sortNodes(tree.columns)
	}
} // }}}

func regroupTreeByIndex(tree: TreeLeaf) { // {{{
	// do nothing
} // }}}

func getIndexHash(tree: TreeLeaf) { // {{{
	if tree.type.isAny() && tree.type.isNullable() {
		return ``
	}
	else {
		return `:\(tree.index)\(Dictionary.keys(tree.parameters).join(':')):\(tree.variadic):\(tree.min):\(tree.max);`
	}
} // }}}

func getIndexHash(tree: TreeBranch) { // {{{
	auto hash = ``

	for const column of tree.columns {
		hash += getIndexHash(column)
	}

	return hash
} // }}}

func resolveBackTracing(tree: TreeBranch, max: Number) { // {{{
	if tree.type.hashCode() != 'Any?' {
		const backtracing = []

		if const column = getBackTracing(tree, backtracing) {
			for const column of column.columns {
				applyBackTracking(column, max, backtracing)
			}
		}
	}
} // }}}

func getBackTracing(tree: TreeBranch, backtracing: Array, default: TreeBranch = null) { // {{{
	if const column = tree.columns['Any?'] {
		const index = tree.order.indexOf('Any?') + 1

		for const key in tree.order from index {
			const column = tree.columns[key]

			backtracing.push({
				index: column.index
				type: column.type
				rows: column.rows.map(({ key }, _, _) => key)
			})

			delete tree.columns[key]
		}

		tree.order.splice(index)

		if column.isNode {
			return getBackTracing(column, backtracing, column)
		}
		else {
			return column
		}
	}
	else {
		return default
	}
} // }}}

func applyBackTracking(tree: TreeBranch, max: Number, backtracing: Array) { // {{{
	const unmatched = []

	for const trace in backtracing {
		if tree.rows.every(({ key }, _, _) => trace.rows.includes(key)) {
			tree.backtracks.push(BackTrack(
				index: trace.index
				type: trace.type
			))
		}
		else {
			unmatched.push(trace)
		}
	}

	if unmatched.length != 0 {
		for const column of tree.columns {
			applyBackTracking(column, max, unmatched)
		}
	}
} // }}}

func applyBackTracking(tree: TreeLeaf, max: Number, backtracing: Array) { // {{{
	for const { index, type, rows } in backtracing {
		if tree.rows.every(({ key }, _, _) => rows.includes(key)) {
			let shift = false

			if tree.index >= 0 {
				shift = tree.index - index == 1
			}
			else {
				shift = (max + tree.index) - index == 1
			}

			if shift {
				tree.index = index
				tree.min++
				tree.max++
			}
			else {
				tree.backtracks.push(BackTrack(
					index
					type
				))
			}
		}
	}
} // }}}

func sortNodes(nodes: Dictionary<TreeColumn>): Array<String> { // {{{
	const items = []

	for const node, key of nodes {
		items.push({
			key
			node
			type: node.type
			usage: node.isNode ? node:TreeBranch.rows.length : 1
			children: []
			isAny: node.type.isAny() || node.type.isNull()
			variadic: node.index < 0 || node.variadic
			alternative: node.rows.every(({ alternative }, _, _) => alternative)
		})
	}

	if items.length == 1 {
		return [items[0].key]!!
	}

	for const node in items {
		if node.alternative {
			for const item in items when item != node {
				if !item.alternative || item.type.matchContentOf(node.type) {
					node.children.push(item)
				}
			}
		}
		else if node.isAny {
			for const item in items when item != node {
				if !item.isAny {
					node.children.push(item)
				}
			}
		}
		else {
			for const item in items when item != node {
				if !item.isAny && item.type.matchContentOf(node.type) {
					node.children.push(item)
				}
			}
		}
	}

	const levels = []

	while items.length != 0 {
		const level = []

		for const item in items desc when item.children.length == 0 {
			items.remove(item)

			level.push(item)
		}

		if level.length == 0 {
			items.sort((a, b) => b.children.length - a.children.length)

			level.push(items.shift())
		}

		for const item in items {
			item.children:Array.remove(...level)
		}

		levels.push(level)
	}

	const sorted = []

	for const level in levels {
		if level.length == 1 {
			sorted.push(level[0].key)
		}
		else {
			level.sort((a, b) => {

				const d = b.usage - a.usage

				if d == 0 {
					return a.type.compareToRef(b.type)
				}
				else {
					return d
				}
			})

			for const item in level {
				sorted.push(item.key)
			}
		}
	}

	return sorted!!
} // }}}

func isSameFunction(...nodes: TreeNode): Boolean { // {{{
	const function = nodes[0].rows[0].function

	for const node in nodes {
		if !node.rows.every((row, _, _) => row.function == function) {
			return false
		}
	}

	return true
} // }}}

func isSameFork(branch: TreeBranch, column: TreeNode) { // {{{
	return branch.type == column.type && isSameParameter([branch, column], column)
} // }}}

func isSameParameter(arguments: Array<TreeNode>, tree: TreeBranch) { // {{{
	for const column of tree.columns {
		if !isSameParameter(arguments, column) {
			return false
		}
	}

	return true
} // }}}

func isSameParameter(arguments: Array<TreeNode>, tree: TreeLeaf): Boolean { // {{{
	const map = {}
	for const { index, parameter } in tree.rows[0].types {
		map[index] = parameter
	}

	const parameter = map[arguments[0].index]

	for const { index } in arguments {
		if map[index] != parameter {
			return false
		}
	}

	return true
} // }}}

func getFunctions(tree: TreeBranch | TreeLeaf): Array<Number> { // {{{
	return tree.rows.map((row, _, _) => row.function.index()).sort((a, b) => b - a)
} // }}}

func regroupBranch_TopForkEqLastChild(branch: TreeBranch | Tree) { // {{{
	return unless branch.order.length == 2

	const first = branch.columns[branch.order[0]]
	const last = branch.columns[branch.order[1]]

	return unless Array.same(getFunctions(first), getFunctions(last))

	lateinit const type
	lateinit const node

	if isSameFork(branch, last) {
		return if last.type.isAssignableToVariable(first.type)
		return unless getParameterHash(first, getParameterHash(branch, [], false), true).join(':').startsWith(getParameterHash(last, [], true).join(':'))

		type = branch.order.pop()
		node = last
	}
	else if isSameFork(branch, first) {
		return if first.type.isAssignableToVariable(last.type)
		return unless getParameterHash(last, getParameterHash(branch, [], false), true).join(':').startsWith(getParameterHash(first, [], true).join(':'))

		type = branch.order.shift()
		node = first
	}
	else {
		return
	}

	delete branch.columns[type]

	branch.rest = node.rest
	branch.variadic = node.variadic
	branch.max += node.max

	const min = buildMin(node)

	applyMin(branch, min)
} // }}}

func getForkHash(tree: TreeBranch | Tree, index: Number = 0, from: Number = index + 1): String { // {{{
	let hash = ''

	if index + 1 == from {
		hash += `:\(tree.order[index])`
	}

	for const key, index in tree.order from from {
		hash += getForkHash(tree.columns[key], 0, 0)
	}

	return hash
} // }}}

func getForkHash(tree: TreeLeaf, index: Number = null, from: Number = null) { // {{{
	return `:\(tree.function.index()).\(tree.rows[0].types.filter(({ index }, _, _) => index == tree.index)[0].parameter).\(tree.type.hashCode())`
} // }}}

func getForkHash2(tree: TreeBranch, index: Number): String { // {{{
	const hashes = []

	for const key in tree.order from index {
		getParameterHash(tree.columns[key], hashes, true)
	}

	return hashes.join(';')
} // }}}

func getForkHash2(tree: TreeLeaf, index: Number): String { // {{{
	const hashes = getParameterHash(tree, [], true)

	return hashes.join(';')
} // }}}

func getParameterHash(tree: TreeLeaf, hashes: Array, _: Boolean) { // {{{
	for const _, key of tree.parameters {
		hashes.pushUniq(`\(key):\(tree.type.hashCode())`)
	}

	return hashes
} // }}}

func getParameterHash(tree: TreeBranch, hashes: Array, all: Boolean): Array { // {{{
	for const _, key of tree.parameters {
		hashes.pushUniq(`\(key):\(tree.type.hashCode())`)
	}

	if all {
		for const hash in tree.order  {
			getParameterHash(tree.columns[hash], hashes, all)
		}
	}

	return hashes
} // }}}

func buildMax(tree: TreeBranch | TreeLeaf) { // {{{
	const result = []

	buildMinMax(tree, 'max', result, [], [])

	return result
} // }}}

func buildMin(tree: TreeBranch | TreeLeaf) { // {{{
	const result = []

	buildMinMax(tree, 'min', result, [], [])

	return result
} // }}}

func buildMinMax(tree: TreeBranch, property: String, result: Array, nodes: Array<TreeBranch>, ancestors: Array) { // {{{
	nodes.push(tree)

	buildMinMax(tree.columns[tree.order[0]], property, result, nodes, ancestors)

	ancestors.pop()

	for const key in tree.order from 1 {
		buildMinMax(tree.columns[key], property, result, [], ancestors)
	}
} // }}}

func buildMinMax(tree: TreeLeaf, property: String, result: Array, nodes: Array<TreeBranch>, ancestors: Array) { // {{{
	const values = {}
	const row = tree.rows[0]
	const function = row.function.index()

	nodes.push(tree)

	const newAncestors = []

	for const node in nodes {
		const type = row.types.find(({index}, _, _) => index == node.index)

		if !?type {
			continue
		}

		if result.length == 0 || ancestors.length == 0 {
			if const m = values[type.parameter] {
				m.push(node[property])
			}
			else {
				values[type.parameter] = [node[property]]
			}
		}
		else {
			if const m = values[type.parameter] {
				m.push([...ancestors, node[property]])
			}
			else {
				values[type.parameter] = [[...ancestors, node[property]]]
			}
		}

		newAncestors.push(`\(function).\(type.parameter)`)
	}

	ancestors.clear()
	ancestors.pushUniq(...newAncestors)

	result.push(values)
} // }}}

func applyMax(tree: TreeBranch | TreeLeaf, data: Array) { // {{{
	const setter = (node, value = null) => {
		if value != null {
			node.max = value
		}
	}

	applyMinMax(tree, setter, data, [], [])
} // }}}

func applyMin(tree: TreeBranch | TreeLeaf, data: Array) { // {{{
	const setter = (node, value = null) => {
		if value != null {
			node.min = value
		}
		else {
			node.min = 0
		}
	}

	applyMinMax(tree, setter, data, [], [])
} // }}}

func applyMinMax(tree: TreeBranch, setter: Function, data: Array, nodes: Array<TreeBranch>, ancestors: Array) { // {{{
	nodes.push(tree)

	applyMinMax(tree.columns[tree.order[0]], setter, data, nodes, ancestors)

	ancestors.pop()

	for const key in tree.order from 1 {
		applyMinMax(tree.columns[key], setter, data, [], ancestors)
	}
} // }}}

func applyMinMax(tree: TreeLeaf, setter: Function, data: Array, nodes: Array<TreeBranch>, ancestors: Array) { // {{{
	const values = data.shift()
	const row = tree.rows[0]
	const function = row.function.index()

	nodes.push(tree)

	for const node in nodes {
		const parameters = [parameter for const parameter of node.parameters when parameter.function == row.function]
		const type = row.types.find(({parameter}, _, _) => parameter == parameters[0].parameter)

		if !?type {
			continue
		}

		ancestors.push(`\(function).\(type.parameter)`)

		if const m = values?[type.parameter] {
			if const value = m.shift() {
				if value is Array {
					const m = value.pop()
					if value.every((m, _, _) => ancestors.contains(m)) {
						setter(node, m)
					}
				}
				else {
					setter(node, value)
				}
			}
			else {
				setter(node)
			}
		}
		else {
			setter(node)
		}
	}
} // }}}

func regroupBranch_ChildrenEqFunc(branch: TreeBranch | Tree, node: AbstractNode): void { // {{{
	return unless isRegroupeableBranch(branch, node)

	const groups = {}
	for const key in branch.order {
		const column = branch.columns[key]
		const functions = column.rows.map(({ function }, _, _) => function.index()).filter((value, index, array) => array.indexOf(value) == index).sort((a, b) => a - b)

		if functions.length > 1 {
			continue
		}

		const function = functions[0]

		if const group = groups[function] {
			group.push(key)
		}
		else {
			groups[function] = [key]
		}
	}

	auto reorder = false

	for const group of groups when group.length > 1 {
		if hasShadow(branch, group) {
			continue
		}

		const rows = []
		for const key in group {
			rows.push(...branch.columns[key].rows)
		}

		const column = buildBranchFromRows(rows, branch.index + 1, node)

		for const key in group {
			delete branch.columns[key]
		}

		branch.columns[column.type.hashCode()] = column

		reorder = true
	}

	if reorder {
		branch.order = sortNodes(branch.columns)
	}
} // }}}

func hasShadow(branch: TreeBranch | Tree, group: Array<String>): Boolean { // {{{
	for const key, index in group {
		const type = branch.columns[key].type

		for const k, i in group from index + 1 {
			const t = branch.columns[k].type

			if t.isAssignableToVariable(type, false, true, true) {
				return true
			}
		}
	}

	return false
} // }}}

func buildBranchFromRows(rows: Array, pIndex: Number, node: AbstractNode): TreeBranch | TreeLeaf { // {{{
	const scope = node.scope()
	const parameters = {}
	const keys = []

	for const row, i in rows {
		const params = {}

		for const type in row.types when type.index >= pIndex || type.index == -1 {
			if const param = params[type.parameter] {
				param.max++

				if !type.type.isAssignableToVariable(param.type, true, false, false) {
					param.type = Type.union(scope, param.type, type.type).sort()
				}
			}
			else {
				params[type.parameter] = {
					type: type.type
					min: 1
					max: 1
					rest: type.rest
				}
			}
		}

		for const parameter, key of parameters {
			if const param = params[key] {
				if !param.type.isAssignableToVariable(parameter.type, true, false, false) {
					parameter.type = Type.union(scope, parameter.type, param.type).sort()
				}

				parameter.min = Math.min(parameter.min, param.min)
				parameter.max = Math.max(parameter.max, param.max)

				delete params[key]
			}
			else {
				parameter.min = 0
			}
		}

		for const parameter, key of params {
			parameters[key] = parameter

			if i != 0 {
				parameter.min = 0
			}

			keys.push(parseInt(key))
		}
	}

	const row = {...rows.last()}
	row.types = row.types.filter(({ index }, _, _) => pIndex > index >= 0)

	const lastParameter = keys.length - 1

	let branch
	let result = null
	let index = pIndex

	for const parameter, i in keys.sort((a, b) => a - b) {
		const { type, min, max, rest } = parameters[parameter]
		const hash = type.hashCode()
		const key = `:\(row.function.index()):\(parameter)`

		row.types.push(RowType(
			index
			type
			rest
			parameter
		))

		if i == lastParameter {
			const leaf = TreeLeaf(
				index
				type
				min
				max
				rest
				variadic: rest || min != max
				isNode: false
				parameters: {
					[key]: TreeParameter(
						key
						function: row.function
						parameter
						rows: [row.key]
					)
				}
				function: row.function
				arguments: []
				rows: [row]
			)

			if result == null {
				result = leaf
			}
			else {
				branch.columns[hash] = leaf
				branch.order = sortNodes(branch.columns)
			}
		}
		else if i == 0 {
			branch = TreeBranch(
				index
				type
				min
				max
				rest
				variadic: true
				parameters: {
					[key]: TreeParameter(
						key
						function: row.function
						parameter
						rows: [row.key]
					)
				}
				rows: [row]
				columns: {}
				isNode: true
			)

			index++

			result = branch
		}
		else {
			branch.columns[hash] = TreeBranch(
				index
				type
				min
				max
				rest
				variadic: rest || min != max
				parameters: {
					[key]: TreeParameter(
						key
						function: row.function
						parameter
						rows: [row.key]
					)
				}
				rows: [row]
				columns: {}
				isNode: true
			)

			branch.order = sortNodes(branch.columns)

			branch = branch.columns[hash]
			index++
		}
	}

	return result
} // }}}

func isRegroupeableBranch(branch: TreeBranch, node: AbstractNode): Boolean { // {{{
	return false unless branch.order.length > 1

	if Dictionary.length(branch.parameters) > 1 {
		if const column = branch.columns[branch.type.hashCode()] {
			for const _, key of column.parameters {
				if branch.parameters[key]? {
					return false
				}
			}
		}
	}

	const arguments = {}
	for const row in branch.rows {
		const fnIndex = row.function.index()
		const fnArguments = arguments[fnIndex] ?? (arguments[fnIndex] = { function: row.function, args: {} })

		for const type in row.types when type.index > branch.index {
			if const types = fnArguments.args[type.index] {
				if !types.some((b, _, _) => type.index == b.index && type.parameter == b.parameter && type.type.hashCode() == b.type.hashCode()) {
					types.push(type)
				}
			}
			else {
				fnArguments.args[type.index] = [type]
			}
		}
	}
	auto regroupeable = false

	for const { function, args } of arguments {
		let parameters = function.parameters()

		if function.isAsync() {
			const scope = node.scope()

			parameters = [...parameters, new ParameterType(scope, scope.reference('Function'))]
		}

		for const types of args when types.length > 1 {
			regroupeable = true

			types.sort((a, b) => a.parameter - b.parameter)

			for const { type, parameter }, index in types til -1 {
				const nextType = types[index + 1].type

				if type.hashCode() != nextType.hashCode() && nextType.isAssignableToVariable(type, false, false, true) {
					const param = parameters[parameter]

					if param.isVarargs() || param.min() == 0 {
						return false
					}
				}
			}
		}
	}

	return regroupeable
} // }}}

func isRegroupeableBranch(branch: TreeLeaf, node: AbstractNode): Boolean { // {{{
	return false
} // }}}

func isFlattenable(group: Group, excludes: Array<String>?, node: AbstractNode): Boolean { // {{{
	return false unless group.functions.length == 1

	const function = group.functions[0]
	let parameters = function.parameters(excludes)

	if function.isAsync() {
		const scope = node.scope()

		parameters = [...parameters, new ParameterType(scope, scope.reference('Function'))]
	}

	auto count = 0
	for const parameter in parameters {
		if parameter.isVarargs() || parameter.min() == 0 {
			++count
		}
	}

	return true unless count > 1

	for const parameter, index in parameters til -1 {
		const nextParameter = parameters[index + 1]
		const currType = parameters[index].type()
		const nextType = nextParameter.type()

		if
			((parameter.isVarargs() || parameter.min() == 0) && nextType.isAssignableToVariable(currType, false, true, false)) ||
			(parameter.min() == 0 && nextParameter.min() != 0 && currType.isNullable() && nextParameter.hasDefaultValue())
		{
			return false
		}
	}

	return true
} // }}}

func regroupBranch_Children_ForkAlike_SiblingsEq(branch: TreeBranch | Tree, node: AbstractNode): void { // {{{
	return unless branch.order.length > 1

	const groups = {}

	for const key in branch.order {
		const column = branch.columns[key]

		lateinit const hash: String

		if column.node {
			hash =	`:\(column.min):\(column.max):\(column.variadic):\(column.rest)`
					+ ';' + Dictionary.keys(column.parameters).sort((a, b) => a.localeCompare(b)).join(';')
					+ ';' + getForkHash2(column, 0)
		}
		else {
			hash = Dictionary.keys(column.parameters).sort((a, b) => a.localeCompare(b)).join(';')
		}

		if const group = groups[hash] {
			group.push(key)
		}
		else {
			groups[hash] = [key]
		}
	}

	const scope = node.scope()
	auto reorder = false

	for const group of groups when group.length > 1 {
		const main = branch.columns[group[0]]

		const types = []
		for const key, i in group {
			types.push(branch.columns[key].type)

			if i != 0 {
				main.rows.push(...branch.columns[key].rows)
			}

			branch.order.remove(key)

			delete branch.columns[key]
		}

		main.type = Type.union(scope, ...types).sort()

		branch.columns[main.type.hashCode()] = main

		reorder = true
	}

	if reorder {
		branch.order = sortNodes(branch.columns)
	}
} // }}}

func buildNames(group: Group, name: String, node: AbstractNode): NamedLength { // {{{
	const functions = []
	const parameters = {}

	if group.n == 1 {
		expandOneName(group, name, node, functions, parameters)
	}
	else {
		expandName(group, name, node, functions, parameters)
	}

	return NamedLength(functions, parameters)
} // }}}

func expandOneName(group: Group, name: String, node: AbstractNode, functions: Array, parameters: Dictionary) { // {{{
	const rows = {}

	for const function in group.functions {
		const required = []

		for const parameter, index in function.parameters() {
			if parameter.min() != 0 {
				required.push({ parameter, index })
			}
		}

		if required.length == 0 {
			for const parameter, index in function.parameters() {
				addOneNameRow(group, name, node, function, parameter, parameter.type(), null, index, rows)
			}
		}
		else if required.length == 1 {
			addOneNameRow(group, name, node, function, required[0].parameter, required[0].parameter.type(), null, required[0].index, rows)
		}
	}

	for const row, name of rows {
		const indexes = {}
		const types = {}

		for const { type, function, index }, hash of row {
			types[hash] = NamedType(
				type
				functions: [function.index()]
			)

			functions.pushUniq(function.index())

			indexes[function.index()] = index
		}

		const order = sortNodes([r.type for const r of row])

		parameters[name] = NamedParameter(indexes, types, order)
	}
} // }}}

func sortNodes(types: Array<Type>): Array<String> { // {{{
	if types.length == 1 {
		return [types[0].hashCode()]
	}

	const items = [{
		key: type.hashCode()
		type
		children: []
		isAny: type.isAny() || type.isNull()
	} for const type in types]

	for const node in items {
		if node.isAny {
			for const item in items when item != node {
				if !item.isAny {
					node.children.push(item)
				}
			}
		}
		else {
			for const item in items when item != node {
				if !item.isAny && item.type.matchContentOf(node.type) {
					node.children.push(item)
				}
			}
		}
	}

	const levels = []

	while items.length != 0 {
		const level = []

		for const item in items desc when item.children.length == 0 {
			items.remove(item)

			level.push(item)
		}

		if level.length == 0 {
			items.sort((a, b) => b.children.length - a.children.length)

			level.push(items.shift())
		}

		for const item in items {
			item.children:Array.remove(...level)
		}

		levels.push(level)
	}

	const sorted = []

	for const level in levels {
		if level.length == 1 {
			sorted.push(level[0].key)
		}
		else {
			level.sort((a, b) => a.type.compareToRef(b.type))

			for const item in level {
				sorted.push(item.key)
			}
		}
	}

	return sorted
} // }}}

func addOneNameRow(group: Group, name: String, node: AbstractNode, function: FunctionType, parameter: ParameterType, type: Type, union: UnionMatch?, paramIndex: Number, rows: Dictionary) { // {{{
	if type.isSplittable() {
		const types = type.split([])
		const union = UnionMatch(
			function
			length: types.length
			matches: []
		)

		for const type in types {
			addOneNameRow(group, name, node, function, parameter, type, union, paramIndex, rows)
		}
	}
	else if const row = rows[parameter.name()] {
		const hash = type.hashCode()
		let addable = true

		if const match = row[hash] {
			if function.max() == match.function.max() {
				if ?match.union {
					if ?union {
						SyntaxException.throwIndistinguishableFunctions(name, [type], [function, match.function], node)
					}
					else {
						match.union.matches.push([type, function])

						if match.union.matches.length == match.union.length {
							SyntaxException.throwShadowFunction(name, match.function, node)
						}
					}
				}
				else {
					if ?union {
						union.matches.push([type, match.function])

						if union.matches.length == union.length {
							SyntaxException.throwShadowFunction(name, function, node)
						}

						addable = false
					}
					else {
						SyntaxException.throwIndistinguishableFunctions(name, [type], [function, match.function], node)
					}
				}
			}
			else if function.max() > match.function.max() {
				addable = false
			}
		}

		if addable {
			row[hash] = {
				type
				function
				union
				index: paramIndex
			}
		}
	}
	else {
		rows[parameter.name()] = {
			[type.hashCode()]: {
				type
				function
				union
				index: paramIndex
			}
		}
	}
} // }}}

func expandName(group: Group, name: String, node: AbstractNode, functions: Array, parameters: Dictionary) { // {{{
	const rows = {}

	for const function in group.functions {
		const requireds = []
		const optionals = []

		for const parameter, index in function.parameters() {
			if parameter.min() != 0 {
				requireds.push({parameter, index})
			}
			else {
				optionals.push({parameter, index})
			}
		}

		let currents = [{}]

		if requireds.length == group.n {
			for const {parameter, index} in requireds {
				currents = expandNameRow(parameter, index, parameter.type(), currents, node)
			}
		}
		else if requireds.length < group.n {
			for const {parameter, index} in requireds {
				currents = expandNameRow(parameter, index, parameter.type(), currents, node)
			}

			const fulls = []

			for const {parameter, index}, i in optionals {
				fulls.push(...expandNameOptionalRow(optionals, group.n - requireds.length, i, parameter, index, currents, node))
			}

			currents = fulls
		}

		addNameRow(function, name, node, currents, rows)
	}

	const names = {}

	for const row of rows {
		for const {index, type}, name of row.parameters {
			names[name] ??= {
				indexes: {}
				types: {}
			}

			if const types = names[name].types[type.hashCode()] {
				types.functions:Array.pushUniq(row.function.index())
			}
			else {
				names[name].types[type.hashCode()] = NamedType(
					type
					functions: [row.function.index()]
				)
			}

			if !?names[name].indexes[row.function.index()] {
				names[name].indexes[row.function.index()] = index
			}
		}

		functions.pushUniq(row.function.index())
	}

	for const {indexes, types}, name of names {
		const order = sortNodes([r.type for const r of types])

		parameters[name] = NamedParameter(indexes, types, order)
	}
} // }}}

func expandNameRow(parameter: ParameterType, paramIndex: Number, type: Type, rows: Array, node: AbstractNode) { // {{{
	if type.isSplittable() {
		const types = type.split([])

		for const type in types {
			rows = expandNameRow(parameter, paramIndex, type, rows, node)
		}

		return rows
	}
	else {
		const result = []

		for const row in rows {
			const r = {...row}

			if const rx = r[parameter.name()] {
				rx.type = Type.union(node.scope(), rx.type, type).sort()
			}
			else {
				r[parameter.name()] = {
					index: paramIndex
					type
				}
			}

			result.push(r)
		}

		return result
	}
} // }}}

func expandNameOptionalRow(optionals: Array, left: Number, index: Number, parameter: ParameterType, paramIndex: Number, rows: Array, node: AbstractNode) { // {{{
	rows = expandNameRow(parameter, paramIndex, parameter.type(), rows, node)

	if left == 1 {
		return rows
	}
	else {
		const fulls = []

		for const optional, i in optionals from index + 1 {
			fulls.push(...expandNameOptionalRow(optionals, left - 1, i, optional.parameter, optional.index, rows, node))
		}

		return fulls
	}
} // }}}

func addNameRow(function: FunctionType, name: String, node: AbstractNode, rows: Array, container: Dictionary) { // {{{
	for const row in rows {
		const names = Dictionary.keys(row).sort()
		const key = names.map((name, _, _) => `;\(name);\(row[name].type.hashCode())`).join()

		if const match = container[key] {
			if function.max() == match.function.max() {
				SyntaxException.throwIndistinguishableFunctions(name, [function, match.function], node)
			}
			else if function.max() < match.function.max() {
				container[key] = {
					function
					parameters: row
				}
			}
		}
		else {
			container[key] = {
				function
				parameters: row
			}
		}
	}
} // }}}

func assess(functions: Array<FunctionType>, excludes: Array<String>, name: String, node: AbstractNode): Assessement { // {{{
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

	const parameters = {
		functions: {}
		names: {}
	}

	const async = functions[0].isAsync()
	const asyncMin = async ? 1 : 0

	let min = Infinity
	let max = 0
	let maxRest = 0
	let rest = false
	let sealed = false

	for const function in functions {
		if const parameter = function.getRestParameter() {
			rest = true

			min = Math.min(function.getMinBefore(excludes) + parameter.min() + function.getMinAfter(excludes) + asyncMin, min)
			maxRest = Math.max(function.getMaxBefore(excludes) + parameter.min() + 1 + function.getMaxAfter(excludes) + asyncMin, maxRest)
		}
		else {
			min = Math.min(function.min(excludes) + asyncMin, min)
			max = Math.max(function.max(excludes) + asyncMin, max)
		}

		if function.isSealed() {
			sealed = true
		}
	}

	const groups: Dictionary<Group> = {}

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

	for const n from min to max {
		groups[n] = Group(n)
	}

	for const function in functions {
		if function.max(excludes) == Infinity {
			for const n from function.min(excludes) + asyncMin to max {
				groups[n].functions.push(function)
			}
		}
		else {
			for const n from function.min(excludes) + asyncMin to function.max(excludes) + asyncMin {
				groups[n].functions.push(function)
			}
		}

		parameters.functions[function.index()] = function

		for const parameter in function.parameters(excludes) {
			const name = parameter.name() ?? '_'

			if const group = parameters.names[name] {
				group.push(`\(function.index())`)
			}
			else {
				parameters.names[name] = [`\(function.index())`]
			}
		}
	}

	const trees: Array<Tree> = []

	for const group of groups when group.functions.length > 0 {
		trees.push(buildTree(group, name, true, excludes, node))
	}

	regroupTrees(trees, node)

	expandUnboundeds(trees, node)

	const functionMap = {}

	for const function in functions {
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
		names: {}
		macro: false
		sealed
	)
} // }}}
