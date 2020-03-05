namespace Router {
	#![rules(dont-ignore-misfit, dont-assert-parameter)]

	struct Assessement {
		async: Boolean			= false
		flattenable: Boolean	= false
		routes: Array<Route>	= []
	}

	struct Route {
		function: FunctionType
		index: Number
		min: Number
		max: Number
		filters: Array<Filter>					= []
		matchingFilters: Array<RouteFilter>		= []
		rest: Filter?							= null
		done: Boolean							= false
	}

	struct Filter {
		index: Number
		type: Type
	}

	struct RouteFilter {
		min: Number
		max: Number
		filters: Array<Filter>	= []
		rest: Filter?			= null
	}

	struct Group {
		n: Number
		functions: Array<FunctionType>		= []
	}

	namespace Bounded { // {{{
		struct UniqueRow {
			index: Number
			type: Type
			function: FunctionType
			rows: Array<String>
		}

		struct Row {
			function: FunctionType
			types: Array<Type>
		}

		struct Tree {
			columns: Dictionary<TreeNode>	= {}
			indexes: Dictionary<Array>		= {}
			order: Array<String>			= []
		}

		struct TreeNode {
			index: Number
			type: Type
			isNode: Boolean
			weight: Number
			isFilter: Boolean?		= null
			order: Array<String>	= []
		}

		struct TreeLeaf extends TreeNode {
			function: FunctionType
		}

		struct TreeBranch extends TreeNode {
			rows: Array<Row>
			columns: Dictionary<TreeNode>	= {}
		}

		func addMatchingFilter(matchingFilters: Array<RouteFilter>, min: Number, max: Number, filter: Filter): Void { // {{{
			for const arg in matchingFilters {
				if arg.min == min && arg.max == max {
					arg.filters.push(filter)

					return
				}
			}

			matchingFilters.push(RouteFilter(
				min: min
				max: max
				filters: [filter]
			))
		} // }}}

		func buildFilters(filters: Array<Filter>, matchingFilters: Array<RouteFilter>, node: TreeNode, index: Number, max: Number, routes: Array<Route>): Void { // {{{
			if node.isFilter {
				if !(node.type.isAny() && node.type.isNullable()) {
					filters = [...filters]

					filters.push(Filter(
						index: index - 1
						type: node.type
					))
				}
			}
			else {
				matchingFilters = [cloneRouteFilter(filter) for const filter in matchingFilters]

				addMatchingFilter(matchingFilters, max, max, Filter(
					index: index - 1
					type: node.type
				))
			}

			if index == max {
				const leaf = node as TreeLeaf

				routes.push(Route(
					function: leaf.function
					index: leaf.function.index()
					min: max
					max: max
					filters
					matchingFilters
				))
			}
			else {
				const next = index + 1

				for const name in node.order {
					buildFilters(filters, matchingFilters, node:TreeBranch.columns[name], next, max, routes)
				}
			}
		} // }}}

		func buildMatchingFiltersFromNode(filters: Array<Filter>, node: TreeNode, excludedIndex: Number, route: Route) { // {{{
			if node.index != excludedIndex {
				if !(node.type.isAny() && node.type.isNullable()) {
					filters = [...filters]

					filters.push(Filter(
						index: node.index - 1
						type: node.type
					))
				}
			}

			if node is TreeLeaf {
				route.matchingFilters.push(RouteFilter(
					min: route.min
					max: route.max
					filters
				))
			}
			else {
				for const node of node:TreeBranch.columns {
					buildMatchingFiltersFromNode(filters, node, excludedIndex, route)
				}
			}
		} // }}}

		func buildNode(node: TreeBranch, index: Number, max: Number, indexes: Dictionary<Array>): Void { // {{{
			const usages: Dictionary<Number> = {}
			for const row in node.rows {
				const index = row.function.index()

				usages[index] = (usages[index] ?? 0) + 1
			}

			const next = index + 1

			if next == max {
				for const row in node.rows {
					const type = row.types[index]
					const hash = type.hashCode()

					if ?node.columns[hash] {
						NotSupportedException.throw()
					}

					node.columns[hash] = TreeLeaf(
						index: next
						type
						function: row.function
						isNode: false
						weight: 1 / usages[row.function.index()]
					)

					indexes[index].push(node.columns[hash])
				}

				node.order = sortNodes(node.columns)
			}
			else {
				for const row in node.rows {
					const type = row.types[index]
					const hash = type.hashCode()

					if !?node.columns[hash] {
						node.columns[hash] = TreeBranch(
							index: next
							type
							rows: [row]
							columns: {}
							isNode: true
							weight: 1 / usages[row.function.index()]
						)

						indexes[index].push(node.columns[hash])
					}
					else {
						const branch: TreeBranch = node.columns[hash]!!

						branch.rows.push(row)
						branch.weight += 1 / usages[row.function.index()]
					}
				}

				for const child of node.columns {
					buildNode(child!!, next, max, indexes)
				}

				node.order = sortNodes(node.columns)
			}
		} // }}}

		func buildRoutes(group, routes: Array<Route>, overflow): Void { // {{{
			let rowCount: Number = group.rowCount
			let rows: Dictionary<Row> = {...group.rows}

			while rowCount > 1 && !usingSameFunction(rows) {
				const uniques: Array<UniqueRow> = []

				for const index from 0 til group.n {
					resolveUniqueRows(index, rowCount, rows, uniques)
				}

				if uniques.length == 0 {
					break
				}

				if uniques.length > 1 {
					uniques.sort(sortUniques)
				}

				const uniq = uniques[0]

				const route = Route(
					function: uniq.function
					index: uniq.function.index()
					min: group.n
					max: group.n
					filters: [
						Filter(
							index: uniq.index
							type: uniq.type
						)
					]
				)

				if !overflow && uniq.index + 1 < group.n {
					const tree = createTree(uniq.rows, rows, group.n)

					for const node of tree.columns {
						if node is TreeBranch {
							buildNode(node, 1, group.n, tree.indexes)
						}
					}

					tree.order = sortNodes(tree.columns)

					filterOutNodes(tree, false)

					for const node of tree.columns {
						buildMatchingFiltersFromNode([], node:!TreeBranch, uniq.index + 1, route)
					}
				}

				for const key in uniq.rows {
					delete rows[key]
				}

				routes.push(route)

				rowCount -= uniq.rows.length
			}

			const keys: Array = Dictionary.keys(rows)

			if keys.length == 1 {
				const row = rows[keys[0]]

				const filters = []
				for const type, index in row.types {
					if !(type.isAny() && type.isNullable()) {
						filters.push(Filter(
							index
							type
						))
					}
				}

				if overflow {
					routes.push(Route(
						function: row.function
						index: row.function.index()
						min: group.n
						max: group.n
						filters
					))
				}
				else {
					const matchingFilters = []

					if filters.length != 0 {
						matchingFilters.push(RouteFilter(
							min: group.n
							max: group.n
							filters
						))
					}

					routes.push(Route(
						function: row.function
						index: row.function.index()
						min: group.n
						max: group.n
						matchingFilters
					))
				}
			}
			else if keys.length > 0 {
				const tree = createTree(keys, rows, group.n)

				if group.n > 1 {
					for const node of tree.columns {
						if node is TreeBranch {
							buildNode(node, 1, group.n, tree.indexes)
						}
					}
				}

				tree.order = sortNodes(tree.columns)

				filterOutCommonTypes(keys, tree, rows, group.n)

				filterOutNodes(tree, false)

				if usingSameFunction(rows) {
					const row = rows[keys[0]]

					const route = Route(
						function: row.function
						index: row.function.index()
						min: group.n
						max: group.n
					)

					for const node of tree.columns {
						buildMatchingFiltersFromNode([], node:!TreeBranch, -1, route)
					}

					routes.push(route)
				}
				else {
					for const name in tree.order {
						buildFilters([], [], tree.columns[name], 1, group.n, routes)
					}

					if !overflow {
						const route: Route = routes.last()

						for const filter in route.filters {
							addMatchingFilter(route.matchingFilters, route.min, route.max, filter)
						}

						route.filters.clear()
					}
				}
			}
		} // }}}

		func cloneRouteFilter(filter: RouteFilter): RouteFilter => RouteFilter( // {{{
			min: filter.min
			max: filter.max
			filters: [...filter.filters]
			rest: filter.rest
		) // }}}

		func compareTypes(aType: Type, bType: Type): Number => compareTypes([aType], [bType])
		func compareTypes(aType: Type, bTypes: Array<Type>): Number => compareTypes([aType], bTypes)
		func compareTypes(aTypes: Array<Type>, bType: Type): Number => compareTypes(aTypes, [bType])
		func compareTypes(aTypes: Array<Type>, bTypes: Array<Type>): Number { // {{{
			if aTypes.length == 1 && bTypes.length == 1 {
				return aTypes[0].compareTo(bTypes[0])
			}
			else {
				for const aType in aTypes {
					for const bType in bTypes {
						if aType.isMorePreciseThan(bType) {
							return -1
						}
						else if bType.isMorePreciseThan(aType) {
							return 1
						}
					}
				}

				return aTypes.length - bTypes.length
			}
		} // }}}

		func createTree(keys: Array<String>, rows: Dictionary<Row>, length: Number): Tree { // {{{
			const tree = Tree()
			for const i from 0 til length {
				tree.indexes[i] = []
			}

			const usages: Dictionary<Number> = {}
			for const key in keys {
				const index = rows[key].function.index()

				usages[index] = (usages[index] ?? 0) + 1
			}

			if length == 1 {
				for const key in keys {
					const row = rows[key]
					const type = row.types[0]
					const hash = type.hashCode()

					if ?tree.columns[hash] {
						NotSupportedException.throw()
					}

					tree.columns[hash] = TreeLeaf(
						index: 1
						type
						function: row.function
						isNode: false
						weight: 1 / usages[row.function.index()]
					)

					tree.indexes['0'].push(tree.columns[hash])
				}
			}
			else {
				for const key in keys {
					const row = rows[key]
					const type = row.types[0]
					const hash = type.hashCode()

					if !?tree.columns[hash] {
						tree.columns[hash] = TreeBranch(
							index: 1
							type
							rows: [row]
							columns: {}
							isNode: true
							weight: 1 / usages[row.function.index()]
							isFilter: null
						)

						tree.indexes['0'].push(tree.columns[hash])
					}
					else {
						const branch: TreeBranch = tree.columns[hash]!!

						branch.rows.push(row)
						branch.weight += 1 / usages[row.function.index()]
					}
				}
			}

			return tree
		} // }}}

		func expandGroup(group, name: String, node: AbstractNode): Void { // {{{
			group.rows = {}
			group.rowCount = 0

			for const function in group.functions {
				expandFunction(group, name, node, function, function.parameters(), group.n, function.min(), 0, 0, '', [])
			}
		} // }}}

		func expandFunction(group, name: String, node: AbstractNode, function: FunctionType, parameters: Array<ParameterType>, target: Number, count: Number, pIndex: Number, pCount: Number, key: String, types: Array<Type>): Void { // {{{
			if pIndex == parameters.length {
				if types.length != target {
					// do nothing
				}
				else if const match = group.rows[key] {
					if function == match.function {
						// do nothing
					}
					else if function.max() == match.function.max() {
						SyntaxException.throwIndistinguishableFunctions(name, [function, match.function], target, node)
					}
					else if function.max() < match.function.max() {
						group.rows[key] = Row(
							function
							types
						)
					}
				}
				else {
					group.rows[key] = Row(
						function
						types
					)

					group.rowCount++
				}
			}
			else {
				const parameter = parameters[pIndex]

				if pCount < parameter.min() {
					const type = parameter.type()

					expandParameter(group, name, node, function, parameters, target, count, pIndex, pCount + 1, key, types, type)
				}
				else if parameter.max() == Infinity {
					if count < target {
						const type = parameter.type()

						expandParameter(group, name, node, function, parameters, target, count + 1, pIndex, pCount + 1, key, types, type)
					}
					else {
						expandFunction(group, name, node, function, parameters, target, count, pIndex + 1, 0, key, types)
					}
				}
				else {
					if count < target && pCount < parameter.max() {
						const type = parameter.type()

						expandParameter(group, name, node, function, parameters, target, count + 1, pIndex, pCount + 1, key, types, type)
					}
					else {
						expandFunction(group, name, node, function, parameters, target, count, pIndex + 1, 0, key, types)
					}
				}

				if pCount == 0 && parameter.hasDefaultValue() {
					expandFunction(group, name, node, function, parameters, target, count, pIndex + 1, 0, key, [...types])
				}
			}
		} // }}}

		func expandParameter(group, name: String, node: AbstractNode, function: FunctionType, parameters: Array<ParameterType>, target: Number, count: Number, pIndex: Number, pCount: Number, key: String, types: Array<Type>, type: Type): Void { // {{{
			if type.isUnion() {
				for const value in type.discard():UnionType.types() {
					expandParameter(group, name, node, function, parameters, target, count, pIndex, pCount, key, types, value)
				}
			}
			else {
				const key = `\(key);\(type.hashCode())`

				const types = [...types]

				types.push(type)

				expandFunction(group, name, node, function, parameters, target, count, pIndex, pCount, key, types)
			}
		} // }}}

		func filterOutCommonTypes(keys: Array<String>, tree: Tree, rows: Dictionary<Row>, length: Number): Void { // {{{
			for const index from 0 til length {
				if const hash = findCommonType(index, keys, rows) {
					for const type in tree.indexes[index] {
						type.isFilter = false
					}
				}
			}
		} // }}}

		func filterOutNodes(node, forceFilter: Boolean): Void { // {{{
			let n = 0
			while n < node.order.length {
				const name = node.order[n]
				const child = node.columns[name]

				if child.isFilter != null {
					// do nothing
				}
				else if n == 0 {
					if n + 1 == node.order.length {
						child.isFilter = forceFilter

						if child.type.isAny() {
							child.isFilter = false
						}
					}
					else {
						child.isFilter = true
					}

					if child.isNode {
						for const name in node.order from n + 1 {
							const type = node.columns[name].type

							if type.isAny() || type.matchContentOf(child.type) {
								forceFilter = true

								break
							}
						}
					}
					else {
						const types = [child.type]
						const names = [name]

						for const key in node.order from n + 1 {
							if node.columns[key].isNode || node.columns[key].function != child.function {
								break
							}
							else {
								types.push(node.columns[key].type)
								names.push(key)

								child.weight += node.columns[key].weight
							}
						}

						if names.length > 1 {
							child.isFilter = forceFilter

							child.type = Type.union(child.type.scope(), ...types)

							const name = child.type.hashCode()

							node.order.splice(n, names.length, name)

							for const key in names {
								delete node.columns[key]
							}

							node.columns[name] = child
						}
					}
				}
				else if n + 1 == node.order.length {
					child.isFilter = forceFilter

					if child.type.isAny() {
						child.isFilter = false
					}
				}
				else {
					child.isFilter = true

					if child.isNode {
						for const name in node.order from n + 1 {
							const type = node.columns[name].type

							if type.isAny() {
								break
							}
							else if type.matchContentOf(child.type) {
								child.isFilter = false
								forceFilter = true

								break
							}
						}
					}
					else {
						const types = [child.type]
						const names = [name]

						for const key in node.order from n + 1 {
							if node.columns[key].isNode || node.columns[key].function != child.function {
								break
							}
							else {
								types.push(node.columns[key].type)
								names.push(key)

								child.weight += node.columns[key].weight
							}
						}

						if names.length > 1 {
							child.isFilter = forceFilter

							child.type = Type.union(child.type.scope(), ...types)

							const name = child.type.hashCode()

							node.order.splice(n, names.length, name)

							for const key in names {
								delete node.columns[key]
							}

							node.columns[name] = child
						}
					}
				}

				if child.isNode {
					filterOutNodes(child, forceFilter)
				}

				++n
			}
		} // }}}

		func findCommonType(index: Number, keys: Array<String>, rows: Dictionary<Row>): String? { // {{{
			let hash = null

			for const key in keys {
				const type = rows[key].types[index]

				if hash == null {
					hash = type.hashCode()
				}
				else if hash != type.hashCode() {
					return null
				}
			}

			return hash
		} // }}}

		func regroupRoutes(routes: Array<Route>): Array<Route> { // {{{
			const flattenable = isFlattenable(routes)
			const max = routes[routes.length - 1].max

			let min = -1
			let index = 0

			while index < routes.length {
				const route = routes[index]

				if route.min > min {
					min = route.min

					const matches = []
					let next = route.min + 1

					for const rt in routes from index + 1 when rt.min >= next {
						if rt.function == route.function && sameFilters(route.filters, rt.filters) && rt.matchingFilters.length >= route.matchingFilters.length {
							matches.push(rt)

							next = rt.min + 1
						}
						else {
							break
						}
					}

					if matches.length != 0 {
						for const match in matches {
							if match.max > route.max {
								route.max = match.max
							}

							if match.matchingFilters.length != 0 {
								if route.matchingFilters.length == 0 {
									route.matchingFilters.push(RouteFilter(
										min: route.min
										max: route.min
									))
								}

								route.matchingFilters.push(...match.matchingFilters)
							}
						}

						routes.remove(...matches)
					}
				}

				if route.max == max {
					min = -1
				}

				++index
			}

			return routes
		} // }}}

		func resolveUniqueRows(index: Number, rowCount: Number, rows: Dictionary<Row>, uniques: Array<UniqueRow>): Void { // {{{
			const items = {}
			const usages = {}
			const methods = {}

			for const row, key of rows {
				const type = row.types[index]

				if type.isAny() {
					return
				}

				const hash = type.hashCode()
				const methodIndex = row.function.index()

				if const item = items[hash] {
					if const methods = item[methodIndex] {
						methods.push(key)
					}
					else {
						item.indexes.push(methodIndex)
						item[methodIndex] = [key]
					}
				}
				else {
					items[hash] = {
						indexes: [methodIndex]
						[methodIndex]: [key]
					}
				}

				usages[methodIndex] = (usages[methodIndex] ?? 0) + 1
				methods[methodIndex] = row.function
			}

			const uniqs = []
			for const item of items when item.indexes.length == 1 {
				const methodIndex = item.indexes[0]

				if usages[methodIndex] == item[methodIndex].length {
					uniqs.push(UniqueRow(
						index
						type: rows[item[methodIndex][0]].types[index]
						function: methods[methodIndex]
						rows: item[methodIndex]
					))
				}
			}

			if uniqs.length == 0 {
				return
			}
			else if uniqs.length > 1 {
				uniqs.sort((a, b) => a.type.compareTo(b.type))
			}

			uniques.push(uniqs[0])
		} // }}}

		func sameFilters(a: Array<Filter>, b: Array<Filter>): Boolean { // {{{
			if a.length != b.length {
				return false
			}
			else if a.length == 0 {
				return true
			}

			for const filter, index in a {
				if !sameFilter(filter, b[index]) {
					return false
				}
			}

			return true
		} // }}}

		func sameFilter(a: Filter, b: Filter): Boolean { // {{{
			return a.index == b.index && a.type == b.type
		} // }}}

		func sortNodes(nodes: Dictionary): Array<String> { // {{{
			const sorted = []

			const weights = []
			const weighted = {}
			for const node of nodes {
				if const list = weighted[node.weight] {
					list.push(node.type)
				}
				else {
					weighted[node.weight] = [node.type]

					weights.push(node.weight)
				}
			}

			weights.sort((a, b) => a < b)

			for const weight in weights {
				const list: Array = weighted[weight]

				if list.length == 1 {
					sorted.push(list[0].hashCode())
				}
				else {
					list.sort(compareTypes)

					for const type in list {
						sorted.push(type.hashCode())
					}
				}
			}

			return sorted
		} // }}}

		func sortUniques(a: UniqueRow, b: UniqueRow): Number { // {{{
			const r = a.type.compareTo(b.type)

			if r == 0 {
				return a.index - b.index
			}
			else {
				return r
			}
		} // }}}

		func usingSameFunction(rows: Dictionary<Row>): Boolean { // {{{
			let function = null

			for const row of rows {
				if function == null {
					function = row.function
				}
				else if function != row.function {
					return false
				}
			}

			return true
		} // }}}

		export func resolveRoutes(functions: Array<FunctionType>, groups: Dictionary, min: Number, max: Number, overflow: Boolean, name: String, node: AbstractNode): Array<Route> { // {{{
			const routes: Array<Route> = []

			for const group of groups {
				expandGroup(group, name, node)

				if group.n == 0 {
					const function = group.rows[''].function

					routes.push(Route(
						function
						index: function.index()
						min: 0
						max: 0
					))
				}
				else {
					group.isNode = true

					buildRoutes(group, routes, overflow)
				}
			}

			return regroupRoutes(routes)
		} // }}}
	} // }}}

	namespace Fragment { // {{{
		func toFlatTestFragments(route: Route, ctrl: ControlBuilder, wrap: Boolean, argName: String, node: AbstractNode) { // {{{
			wrap = wrap && route.filters.length != 0

			if wrap {
				ctrl.code('(')
			}

			if route.min == route.max {
				ctrl.code(`\(argName).length === \(route.min)`)
			}
			else if route.max == Infinity {
				ctrl.code(`\(argName).length >= \(route.min)`)
			}
			else if route.min + 1 == route.max {
				ctrl.code(`\(argName).length === \(route.min) || \(argName).length === \(route.max)`)
			}
			else {
				ctrl.code(`\(argName).length >= \(route.min) && \(argName).length <= \(route.max)`)
			}

			route.filters.sort((a, b) => a.index > b.index)

			for const filter in route.filters {
				ctrl.code(' && ')

				if filter.index >= 0 {
					filter.type.toPositiveTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(filter.index)]`))
				}
				else {
					filter.type.toPositiveTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(argName).length - \(-filter.index - 1)]`))
				}
			}

			route.done = true

			if wrap {
				ctrl.code(')')
			}
		} // }}}

		func toTestTreeFragments(route: Route, ctrl: ControlBuilder, argName: String, call: Function, node: AbstractNode): Boolean { // {{{
			if route.filters.length == 0 {
				unless ctrl.isFirstStep() {
					ctrl.step().code('else').step()
				}
			}
			else {
				unless ctrl.isFirstStep() {
					ctrl.step().code('else ')
				}

				ctrl.code(`if(`)

				for const filter, index in route.filters {
					if index != 0 {
						ctrl.code(' && ')
					}

					if filter.index >= 0 {
						filter.type.toPositiveTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(filter.index)]`))
					}
					else {
						filter.type.toPositiveTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(argName).length - \(-filter.index - 1)]`))
					}
				}

				ctrl.code(`)`).step()
			}

			call(ctrl, route.function, route.index)

			return true
		} // }}}

		export func sortTreeMin(routes: Array<Route>, max: Number) { // {{{
			const tree = {
				equal: []
				midway: {
					keys: []
				}
			}

			for const route in routes {
				if route.min == max {
					tree.equal.push(route)
				}
				else {
					if tree.midway[route.min]? {
						tree.midway[route.min].push(route)
					}
					else {
						tree.midway[route.min] = [route]

						tree.midway.keys.push(route.min)
					}
				}
			}

			if tree.equal.length == 1 && tree.midway.keys.length == 0 {
				return tree.equal
			}
			else {
				return tree
			}
		} // }}}

		export func toEqLengthFragments(routes: Array<Route>, ctrl: ControlBuilder, argName: String, delta: Number, call: Function, node: AbstractNode): Boolean { // {{{
			const route = routes[0]

			if route.max == Infinity && route.min == 0 {
				unless ctrl.isFirstStep() {
					ctrl.step().code('else').step()
				}
			}
			else {
				unless ctrl.isFirstStep() {
					ctrl.step().code('else ')
				}

				ctrl.code(`if(`)

				if route.min == route.max {
					ctrl.code(`\(argName).length === \(route.min + delta)`)
				}
				else if route.max == Infinity {
					ctrl.code(`\(argName).length >= \(route.min + delta)`)
				}
				else if route.min + 1 == route.max {
					ctrl.code(`\(argName).length === \(route.min + delta) || \(argName).length === \(route.max + delta)`)
				}
				else {
					ctrl.code(`\(argName).length >= \(route.min + delta) && \(argName).length <= \(route.max + delta)`)
				}

				ctrl.code(`)`).step()
			}

			if routes.length == 1 && route.filters.length == 0 {
				call(ctrl, route.function, route.index)

				return !(route.max == Infinity && route.min == 0)
			}
			else {
				const ctrl2 = ctrl.newControl()

				let ne = false

				for const route in routes {
					ne = toTestTreeFragments(route, ctrl2, argName, call, node)
				}

				ctrl2.done()

				return ne
			}
		} // }}}

		export func toFlatFragments(assessment: Assessement, route: Route, ctrl: ControlBuilder, argName: String, call: Function, node: AbstractNode): Boolean { // {{{
			const matchs = [r for const r in assessment.routes when r.done != true && r.index == route.index]

			if matchs.length == 1 && matchs[0].min == 0 && matchs[0].max == Infinity && matchs[0].filters.length == 0 {
				unless ctrl.isFirstStep() {
					ctrl.step().code('else').step()
				}

				call(ctrl, route.function, route.index)

				return false
			}
			else {
				unless ctrl.isFirstStep() {
					ctrl.step().code('else ')
				}

				ctrl.code(`if(`)

				if matchs.length == 1 {
					toFlatTestFragments(matchs[0], ctrl, false, argName, node)
				}
				else {
					let nf = false

					for const match in matchs {
						if nf {
							ctrl.code(' || ')
						}
						else {
							nf = true
						}

						toFlatTestFragments(match, ctrl, true, argName, node)
					}
				}

				ctrl.code(`)`).step()

				call(ctrl, route.function, route.index)

				return true
			}
		} // }}}

		export func toMixLengthFragments(tree, ctrl: ControlBuilder, argName: String, delta: Number, call: Function, node: AbstractNode) { // {{{
			let ne = false

			if tree.equal.length != 0 {
				ne = toEqLengthFragments(tree.equal, ctrl, argName, delta, call, node)
			}

			if tree.midway.keys.length == 1 {
				ne = toEqLengthFragments(tree.midway[tree.midway.keys[0]], ctrl, argName, delta, call, node)
			}
			else if tree.midway.keys.length > 1 {
				throw new NotImplementedException(node)
			}

			return ne
		} // }}}

		export func toTestCallFragments(route: Route, ctrl, argName: String, call: Function, node: AbstractNode): Void { // {{{
			if route.filters.length == 0 {
				call(ctrl, route.function, route.index)
			}
			else {
				const ctrl2 = ctrl.newControl()

				ctrl2.code(`if(`)

				for const filter, index in route.filters {
					if index != 0 {
						ctrl2.code(' && ')
					}

					if filter.index >= 0 {
						filter.type.toPositiveTestFragments(ctrl2, new Literal(false, node, node.scope(), `\(argName)[\(filter.index)]`))
					}
					else {
						filter.type.toPositiveTestFragments(ctrl2, new Literal(false, node, node.scope(), `\(argName)[\(argName).length - \(-filter.index - 1)]`))
					}
				}

				ctrl2.code(`)`).step()

				call(ctrl2, route.function, route.index)

				ctrl2.done()
			}
		} // }}}
	} // }}}

	namespace Individual { // {{{
		func buildFilters(function: FunctionType, routes: Array<Route>, min: Number, max: Number): Void { // {{{
			const route = Route(
				function
				index: function.index()
				min
				max
			)

			buildFilters(function, function.parameters(), 0, routes, route, 0, function.min(), min)
		} // }}}

		func buildFilters(function: FunctionType, parameters: Array<ParameterType>, pIndex: Number, routes: Array<Route>, route: Route, index: Number, count: Number, limit: Number): Void { // {{{
			if pIndex == parameters.length {
				if count == limit {
					routes.push(route)
				}

				return
			}

			const parameter = parameters[pIndex]

			let type = parameter.type()

			if parameter.hasDefaultValue() {
				type = type.setNullable(true)
			}

			for const i from 1 to parameter.min() {
				route.filters.push(Filter(
					index
					type
				))

				++index
			}

			if parameter.max() == Infinity {
				route.rest = Filter(
					index
					type
				)

				index = count - limit

				buildFilters(function, parameters, pIndex + 1, routes, route, index, count, limit)
			}
			else if count < limit && parameter.max() > parameter.min() {
				buildFilters(function, parameters, pIndex + 1, routes, Route(
					function
					index: function.index()
					min: route.min
					max: route.max
					filters: [...route.filters]
				), index, count, limit)

				for const i from parameter.min() + 1 to parameter.max() while count < limit {
					route.filters.push(Filter(
						index
						type
					))

					++index
					++count

					buildFilters(function, parameters, pIndex + 1, routes, Route(
						function
						index: function.index()
						min: route.min
						max: route.max
						filters: [...route.filters]
					), index, count, limit)
				}
			}
			else {
				buildFilters(function, parameters, pIndex + 1, routes, route, index, count, limit)
			}
		} // }}}

		func buildMatchingFilters(function: FunctionType, routes: Array<RouteFilter>, min: Number, max: Number): Void { // {{{
			const route = RouteFilter(
				min
				max
			)

			buildMatchingFilters(function.parameters(), 0, routes, route, 0, function.min(), min)
		} // }}}

		func buildMatchingFilters(parameters: Array<ParameterType>, pIndex: Number, routes: Array<RouteFilter>, route: RouteFilter, index: Number, count: Number, limit: Number): Void { // {{{
			if pIndex == parameters.length {
				if count == limit {
					routes.push(route)
				}

				return
			}

			const parameter = parameters[pIndex]

			let type = parameter.type()

			if parameter.hasDefaultValue() {
				type = type.setNullable(true)
			}

			for const i from 1 to parameter.min() {
				route.filters.push(Filter(
					index
					type
				))

				++index
			}

			if parameter.max() == Infinity {
				route.rest = Filter(
					index
					type
				)

				index = count - limit

				buildMatchingFilters(parameters, pIndex + 1, routes, route, index, count, limit)
			}
			else if count < limit && parameter.max() > parameter.min() {
				buildMatchingFilters(parameters, pIndex + 1, routes, RouteFilter(
					min: route.min
					max: route.max
					filters: [...route.filters]
				), index, count, limit)

				for const i from parameter.min() + 1 to parameter.max() while count < limit {
					route.filters.push(Filter(
						index
						type
					))

					++index
					++count

					buildMatchingFilters(parameters, pIndex + 1, routes, RouteFilter(
						min: route.min
						max: route.max
						filters: [...route.filters]
					), index, count, limit)
				}
			}
			else {
				buildMatchingFilters(parameters, pIndex + 1, routes, route, index, count, limit)
			}
		} // }}}

		export func assess(function: FunctionType, flattenable: Boolean, overflow: Boolean = false): Assessement { // {{{
			function.index(0)

			if overflow {
				const routes = []

				if function.absoluteMax() == Infinity {
					const rest = function.restIndex()
					const min = function.absoluteMin()

					if rest < min {
						buildFilters(function, routes, min, Infinity)
					}
					else {
						for const n from min til rest {
							buildFilters(function, routes, n, n)
						}

						buildFilters(function, routes, min, Infinity)
					}
				}
				else {
					for const n from function.absoluteMin() to function.absoluteMax() {
						buildFilters(function, routes, n, n)
					}
				}

				return Assessement(
					async: function.isAsync()
					flattenable: flattenable && isFlattenable(routes)
					routes
				)
			}
			else {
				const matchingFilters = []

				if function.absoluteMax() == Infinity {
					const rest = function.restIndex()
					const min = function.absoluteMin()

					if rest < min {
						buildMatchingFilters(function, matchingFilters, min, Infinity)
					}
					else {
						for const n from min til rest {
							buildMatchingFilters(function, matchingFilters, n, n)
						}

						buildMatchingFilters(function, matchingFilters, min, Infinity)
					}
				}
				else {
					for const n from function.absoluteMin() to function.absoluteMax() {
						buildMatchingFilters(function, matchingFilters, n, n)
					}
				}

				return Assessement(
					async: function.isAsync()
					flattenable
					routes: [
						Route(
							function
							index: 0
							min: function.absoluteMin()
							max: function.absoluteMax()
							matchingFilters
						)
					]
				)
			}
		} // }}}
	} // }}}

	namespace Unbounded { // {{{
		func checkFunctions(functions: Array<FunctionType>, parameters: Dictionary, min: Number, index: Number, routes: Array<Route>, filters: Array): Void { // {{{
			if !?parameters[index + 1] {
				NotSupportedException.throw()
			}
			else if parameters[index + 1] is Number {
				index = parameters[index + 1]:Number - 1
			}

			const tree = []
			const usages = []

			let type, nf, item, usage, i, function
			for const type of parameters[index + 1].types {
				tree.push(item = {
					type: type.type
					functions: [functions[i] for i in type.functions]
					usage: type.functions.length
				})

				if type.type.isAny() {
					item.weight = 0
				}
				else {
					item.weight = 1_000
				}

				for i in type.functions {
					function = functions[i]

					nf = true
					for usage in usages while nf {
						if usage.function == function {
							nf = false
						}
					}

					if nf {
						usages.push(usage = {
							function,
							types: [item]
						})
					}
					else {
						usage!?.types.push(item)
					}
				}
			}

			if tree.length == 0 {
				checkFunctions(functions, parameters, min, index + 1, routes, filters)
			}
			else if tree.length == 1 {
				item = tree[0]

				if item.functions.length == 1 {
					routes.push(Route(
						function: item.functions[0]
						index: item.functions[0].index()
						min
						max: Infinity
						filters
					))
				}
				else {
					checkFunctions(functions, parameters, min, index + 1, routes, filters)
				}
			}
			else {
				for const usage in usages {
					let count = usage.types.length

					for const type in usage.types while count >= 0 {
						count -= type.usage
					}

					if count == 0 {
						let item = {
							type: [],
							path: [],
							functions: [usage.function]
							usage: 0
							weight: 0
						}

						for type in usage.types {
							item.type.push(type.type)
							item.usage += type.usage
							item.weight += type.weight

							tree.remove(type)
						}

						tree.push(item)
					}
				}

				tree.sort(func(a, b) {
					if a.weight == 0 && b.weight != 0 {
						return 1
					}
					else if b.weight == 0 {
						return -1
					}
					else if a.type.length == b.type.length {
						if a.usage == b.usage {
							return b.weight - a.weight
						}
						else {
							return b.usage - a.usage
						}
					}
					else {
						return a.type.length - b.type.length
					}
				})

				for const item, i in tree {
					if item.type[0].isAny() {
						if item.functions.length == 1 {
							routes.push(Route(
								function: item.functions[0]
								index: item.functions[0].index()
								min
								max: Infinity
								filters
							))
						}
						else {
							checkFunctions(functions, parameters, min, index + 1, routes, filters)
						}
					}
					else {
						const filters = filters.slice()

						filters.push({
							index
							type: item.type[0]
						})

						if item.functions.length == 1 {
							routes.push(Route(
								function: item.functions[0]
								index: item.functions[0].index()
								min
								max: Infinity
								filters
							))
						}
						else {
							checkFunctions(functions, parameters, min, index + 1, routes, filters)
						}
					}
				}
			}
		} // }}}

		func mapFunction(function: FunctionType, target: Number, map: Dictionary): Void { // {{{
			let index = 1
			let count = function.min()
			let item
			let fi = false

			for const parameter, p in function.parameters() {
				for const i from 1 to parameter.min() {
					if item !?= map[index] {
						item = map[index] = {
							index: index
							types: {}
							weight: 0
						}
					}

					mapParameter(parameter.type(), function.index(), item, target)

					++index
				}

				if parameter.max() == Infinity {
					if !fi {
						fi = true

						const oldIndex = index

						index -= function.min() + 1
						map[oldIndex] = index
					}
					else {
						NotImplementedException.throw()
					}
				}
				else {
					for const i from parameter.min() + 1 to parameter.max() while count < target {
						if item !?= map[index] {
							item = map[index] = {
								index: index
								types: {}
								weight: 0
							}
						}

						mapParameter(parameter.type(), function.index(), item, target)

						++index
						++count
					}
				}
			}
		} // }}}

		func mapParameter(type: Type, function: Number, map: Dictionary, target: Number): Void { // {{{
			if type is UnionType {
				for value in type.types() {
					mapParameter(value, function, map, target)
				}
			}
			else {
				if map.types[type.hashCode()] is Dictionary {
					map.types[type.hashCode()].functions.push(function)
				}
				else {
					let weight = 0
					if type.isAny() {
						weight = 1
					}
					else {
						weight = 1_00

						if map.index == target {
							weight += 1_00_00
						}
					}

					map.types[type.hashCode()] = {
						type: type
						functions: [function]
						weight
					}

					map.weight += weight
				}
			}
		} // }}}

		export func resolveRoutes(functions: Array<FunctionType>, infinities: Array<FunctionType>, async: Boolean): Array<Route> { // {{{
			const groups = {}

			let min = Infinity
			let max = 0

			for const function in functions {
				let functionMin = 0
				let functionMax = 0

				for const parameter in function.parameters() {
					if parameter.min() != 0 && parameter.max() != Infinity {
						functionMin += parameter.min()
						functionMax += parameter.max()
					}
				}

				for const n from functionMin to functionMax {
					if groups[n]? {
						groups[n].functions.push(function)
					}
					else {
						groups[n] = {
							n
							functions: [function]
						}
					}
				}

				min = Math.min(min, functionMin)
				max = Math.max(max, functionMax)
			}

			for const i from min to max {
				if const group = groups[i] {
					for const j from i + 1 to max while (gg ?= groups[j]) && Array.same(gg.functions, group.functions) {
						if group.n is Array {
							group.n.push(j)
						}
						else {
							group.n = [i, j]
						}

						delete groups[j]
					}
				}
			}

			const assessment = []

			for const group, k of groups {
				const parameters = {}

				for const function in group.functions {
					mapFunction(function, group.n, parameters)
				}

				let indexes = []
				for const parameter in [value for const value of parameters].sort((a, b) => b.weight - a.weight) {
					for const type, hash of parameter.types {
						type.functions:Array.remove(...indexes)

						if type.functions.length == 0 {
							delete parameter.types[hash]
						}
					}

					for const type of parameter.types {
						if type.functions.length == 1 {
							indexes:Array.pushUniq(type.functions[0])
						}
					}
				}

				checkFunctions(functions, parameters, group.n, 0, assessment, [])
			}

			return assessment
		} // }}}
	} // }}}

	func isFlattenable(routes: Array<Route>): Boolean { // {{{
		if routes.length <= 1 {
			return true
		}

		const done = {}
		let min = 0

		for const route in routes when done[route.index] != true {
			done[route.index] = true

			for const m in routes when m.index == route.index {
				if m.filters.length == 0 {
					min = m.min
				}
				else if m.min <= min {
					return false
				}
			}
		}

		return true
	} // }}}

	export {
		#![rules(assert-parameter)]

		func assess(functions: Array<FunctionType>, flattenable: Boolean, name: String, node: AbstractNode, overflow: Boolean = false, filterGroups: Function = null): Assessement { // {{{
			if functions.length == 0 {
				return Assessement()
			}
			else if functions.length == 1 {
				return Individual.assess(functions[0], flattenable, overflow)
			}

			const groups: Dictionary<Group> = {}
			const infinities: Array<FunctionType> = []
			let min = Infinity
			let max = 0

			for const function, index in functions {
				function.index(index)

				if function.max() == Infinity {
					infinities.push(function)
				}
				else {
					for const n from function.min() to function.max() {
						if groups[n]? {
							groups[n].functions.push(function)
						}
						else {
							groups[n] = Group(
								n
								functions: [function]
							)
						}
					}

					min = Math.min(min, function.min())
					max = Math.max(max, function.max())
				}
			}

			const async = functions[0].isAsync()

			if min == Infinity {
				const assessment = Assessement(
					async
					routes: Unbounded.resolveRoutes(functions, infinities, async)
				)

				assessment.flattenable = flattenable && isFlattenable(assessment.routes)

				return assessment
			}
			else {
				for const function in infinities {
					for const group of groups when function.absoluteMin() <= group.n {
						group.functions.push(function)
					}
				}

				if filterGroups != null {
					filterGroups(groups)
				}

				const assessment = Assessement(
					async
					routes: Bounded.resolveRoutes(functions, groups, min, max, overflow, name, node)
				)

				if infinities.length == 1 {
					const function = infinities[0]

					for const map, index in assessment.routes desc {
						if map.function == function && map.filters.length == 0 {
							assessment.routes.splice(index, 1)
						}
					}

					assessment.routes.push(Route(
						function
						index: function.index()
						min: 0
						max: Infinity
					))
				}
				else if infinities.length > 1 {
					const indexes = []
					for const function, index in infinities {
						indexes.push([function._index, index])

						function._index = index
					}

					const unbounds = Unbounded.resolveRoutes(infinities, infinities, async)

					for const [old, new] in indexes {
						infinities[new]._index = old
					}

					for const route in unbounds when route.max == Infinity {
						route.index = route.function.index()

						assessment.routes.push(route)
					}
				}

				assessment.flattenable = flattenable && isFlattenable(assessment.routes)

				return assessment
			}
		} // }}}

		func matchArguments(assessment: Assessement, arguments: Array<Type>): Array<FunctionType> { // {{{
			const matches: Array<FunctionType> = []

			let spreadIndex: Number = -1

			for const argument, index in arguments {
				if argument.isSpread() {
					spreadIndex = index

					break
				}
			}

			const length = arguments.length

			if spreadIndex != -1 {
				for const route in assessment.routes when length <= route.max {
					matches.push(route.function)
				}

				return matches
			}

			let routes = []

			for const route in assessment.routes when route.min <= length <= route.max {
				if route.filters.length == 0 && route.matchingFilters.length == 0 {
					matches.push(route.function)
				}
				else {
					let matched = true
					let perfect = true
					let union = true

					for const filter in route.filters {
						if arguments[filter.index].isAny() {
							perfect = false
						}
						else if !arguments[filter.index].matchContentOf(filter.type) {
							matched = false

							if !arguments[filter.index].isUnion() {
								union = false

								break
							}
						}
					}

					if matched && route.matchingFilters.length != 0 {
						let notFound = true

						for const line in route.matchingFilters while notFound when line.min <= length <= line.max {
							let isMatched = true
							let isPerfect = perfect

							for const filter in line.filters {
								if arguments[filter.index].isAny() {
									isPerfect = false
								}
								else if !arguments[filter.index].matchContentOf(filter.type) {
									isMatched = false

									if !arguments[filter.index].isUnion() {
										union = false

										break
									}
								}
							}

							if isMatched {
								notFound = false
								perfect = isPerfect
							}
						}

						if notFound {
							matched = false
						}
					}

					if matched {
						if perfect {
							return [route.function]
						}
						else {
							matches.push(route.function)
						}
					}
					else if union {
						routes.push(route)
					}
				}
			}

			if routes.length != 0 {
				for const argument, index in arguments when argument.isUnion() {
					const types = argument.discard():UnionType.types()

					const newRoutes = []

					for const type in types {
						let typeIsMatched = true

						for const route in routes {
							let matched = true

							for const filter in route.filters when filter.index == index {
								if !type.matchContentOf(filter.type) {
									matched = false
								}
							}

							if route.matchingFilters.length != 0 {
								let notFound = true

								for const line in route.matchingFilters while notFound when line.min <= length <= line.max {
									let isMatched = true

									for const filter in line.filters when filter.index == index {
										if !type.matchContentOf(filter.type) {
											isMatched = false
										}
									}

									if isMatched {
										notFound = false
									}
								}

								if notFound {
									matched = false
								}
							}

							if matched {
								newRoutes.pushUniq(route)

								typeIsMatched = true
							}
						}

						if !typeIsMatched {
							newRoutes.clear()

							break
						}
					}

					if newRoutes.length == 0 {
						routes.clear()

						break
					}
					else {
						routes = newRoutes
					}
				}

				for const route in routes {
					matches.push(route.function)
				}
			}

			return matches
		} // }}}

		func toFragments(assessment: Assessement, fragments, argName: String, returns: Boolean, header: Function, footer: Function, call: Function, wrongdoer: Function, node: AbstractNode) { // {{{
			const block = header(node, fragments)

			if assessment.routes.length == 0 {
				wrongdoer(block, null, argName, assessment.async, returns)
			}
			else if assessment.flattenable {
				const ctrl = block.newControl()

				let ne = false

				for const route in assessment.routes when route.done != true {
					ne = Fragment.toFlatFragments(assessment, route, ctrl, argName, call, node)
				}

				if ne {
					wrongdoer(block, ctrl, argName, assessment.async, returns)
				}
				else {
					ctrl.done()
				}
			}
			else if assessment.routes.length == 1 {
				const route = assessment.routes[0]
				const delta = assessment.async ? 1 : 0
				const min = route.function.min()
				const max = route.function.max()

				if min == 0 && max >= Infinity {
					call(block, route.function, route.index)
				}
				else if min == max {
					const ctrl = block.newControl()

					ctrl.code(`if(\(argName).length === \(min + delta))`).step()

					Fragment.toTestCallFragments(route, ctrl, argName, call, node)

					wrongdoer(block, ctrl, argName, assessment.async, returns)
				}
				else if max < Infinity {
					const ctrl = block.newControl()

					ctrl.code(`if(\(argName).length >= \(min + delta) && \(argName).length <= \(max + delta))`).step()

					Fragment.toTestCallFragments(route, ctrl, argName, call, node)

					wrongdoer(block, ctrl, argName, assessment.async, returns)
				}
				else {
					Fragment.toTestCallFragments(route, block, argName, call, node)
				}
			}
			else {
				const delta = assessment.async ? 1 : 0

				const tree = {}
				for const route in assessment.routes {
					if tree[route.max]? {
						tree[route.max].push(route)
					}
					else {
						tree[route.max] = [route]
					}
				}

				for const routes, max of tree {
					tree[max] = Fragment.sortTreeMin(routes!!, routes[0].max)
				}

				const ctrl = block.newControl()

				let ne = false

				for const item of tree {
					if item is Array {
						ne = Fragment.toEqLengthFragments(item, ctrl, argName, delta, call, node)
					}
					else {
						ne = Fragment.toMixLengthFragments(item, ctrl, argName, delta, call, node)
					}
				}

				if ne {
					wrongdoer(block, ctrl, argName, assessment.async, returns)
				}
				else {
					ctrl.done()
				}
			}

			footer(block)

			return fragments
		} // }}}
	}
}