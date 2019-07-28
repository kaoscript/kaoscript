namespace Router {
	export func assess(methods, flattenable) { // {{{
		if methods.length == 0 {
			return {
				async: false
				methods: []
			}
		}
		else if methods.length == 1 {
			const method = methods[0]

			method.index(0)

			const argFilters = []

			if method.absoluteMax() == Infinity {
				const rest = method.restIndex()
				const min = method.absoluteMin()

				if rest < min {
					argFilters.push(buildArgFilter(method, min, Infinity))
				}
				else {
					for const n from min til rest {
						argFilters.push(buildArgFilter(method, n, n))
					}

					argFilters.push(buildArgFilter(method, min, Infinity))
				}
			}
			else {
				for const n from method.absoluteMin() to method.absoluteMax() {
					argFilters.push(buildArgFilter(method, n, n))
				}
			}

			return {
				async: method.isAsync()
				methods: [{
					method
					index: 0
					min: method.absoluteMin()
					max: method.absoluteMax()
					filters: []
					argFilters
				}]
			}
		}

		const groups = {}
		const infinities = []
		let min = Infinity
		let max = 0

		for const method, index in methods {
			method.index(index)

			if method.absoluteMax() == Infinity {
				infinities.push(method)
			}
			else {
				for const n from method.absoluteMin() to method.absoluteMax() {
					if groups[n]? {
						groups[n].methods.push(method)
					}
					else {
						groups[n] = {
							n: n
							methods: [method]
						}
					}
				}

				min = Math.min(min, method.absoluteMin())
				max = Math.max(max, method.absoluteMax())
			}
		}

		const async = methods[0].isAsync()

		if min == Infinity {
			const assessment = {
				async
				methods: assessUnbounded(methods, infinities, async)
			}

			assessment.flattenable = flattenable && isFlattenable(assessment.methods)

			return assessment
		}
		else {
			// for const method in infinities {
			// 	for const group of groups when method.absoluteMin() <= group.n {
			// 		group.methods.push(method)
			// 	}
			// }

			const assessment = {
				async
				methods: assessBounded(methods, groups, min, max)
			}

			if infinities.length == 1 {
				const method = infinities[0]

				assessment.methods.push({
					method
					index: method.index()
					min: 0
					max: Infinity
					filters: []
				})
			}
			else if infinities.length > 1 {
				throw new NotImplementedException()
			}

			assessment.flattenable = flattenable && isFlattenable(assessment.methods)

			return assessment
		}
	} // }}}

	func assessBounded(methods, groups, min, max) { // {{{
		for const i from min to max {
			if const group = groups[i] {
				for const j from i + 1 to max while (gg ?= groups[j]) && gg.methods.length == 1 == group.methods.length && Array.same(gg.methods, group.methods) {
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
			let min, max

			if group.n is Array {
				min = group.n[0]
				max = group.n[group.n.length - 1]
			}
			else {
				min = max = group.n
			}


			if group.methods.length == 1 {
				assessment.push({
					method: group.methods[0]
					index: group.methods[0].index()
					min
					max
					filters: []
				})
			}
			else {
				const parameters = {}
				if group.n is Array {
					for const n in group.n {
						for const method in group.methods {
							mapMethod(method, n, parameters)
						}
					}
				}
				else {
					for const method in group.methods {
						mapMethod(method, group.n, parameters)
					}
				}

				const length = group.methods.length

				for const parameter, name of parameters {
					for const type, name of parameter.types {
						if type.methods.length == length {
							parameter.weight -= type.weight

							delete parameter[name]
						}
					}
				}

				const sortedParameters = [value for const value of parameters].sort((a, b) => b.weight - a.weight)
				const sortedIndexes = [value.index - 1 for const value in sortedParameters]

				let indexes = []
				for const parameter in sortedParameters {
					for const type, hash of parameter.types {
						type.methods:Array.remove(...indexes)

						if type.methods.length == 0 {
							delete parameter.types[hash]

							parameter.weight -= type.weight
						}
					}

					for const type, hash of parameter.types {
						if type.methods.length == 1 {
							indexes:Array.pushUniq(type.methods[0])
						}
					}
				}

				checkMethods(methods, parameters, min, max, 0, sortedIndexes, assessment, [])
			}
		}

		return assessment
	} // }}}

	func assessUnbounded(methods, infinities, async) { // {{{
		let groups = {}
		let min = Infinity
		let max = 0

		for const method in methods {
			let methodMin = 0
			let methodMax = 0

			for const parameter in method.parameters() {
				if parameter.min() != 0 && parameter.max() != Infinity {
					methodMin += parameter.min()
					methodMax += parameter.max()
				}
			}

			for const n from methodMin to methodMax {
				if groups[n]? {
					groups[n].methods.push(method)
				}
				else {
					groups[n] = {
						n: n
						methods: [method]
					}
				}
			}

			min = Math.min(min, methodMin)
			max = Math.max(max, methodMax)
		}

		for const i from min to max {
			if const group = groups[i] {
				for const j from i + 1 to max while (gg ?= groups[j]) && Array.same(gg.methods, group.methods) {
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
			for method in group.methods {
				mapMethod(method, group.n, parameters)
			}

			let indexes = []
			for const parameter in [value for const value of parameters].sort((a, b) => b.weight - a.weight) {
				for const type, hash of parameter.types {
					type.methods:Array.remove(...indexes)

					if type.methods.length == 0 {
						delete parameter.types[hash]
					}
				}

				for const type of parameter.types {
					if type.methods.length == 1 {
						indexes:Array.pushUniq(type.methods[0])
					}
				}
			}

			checkInfinityMethods(methods, parameters, group.n, 0, assessment, [])
		}

		return assessment
	} // }}}

	func buildArgFilter(method, min, max) { // {{{
		const line = {
			min
			max
			filters: []
		}

		let count = method.min()
		let index = 0

		for const parameter, p in method.parameters() {
			const type = parameter.type()

			for const i from 1 to parameter.min() {
				line.filters.push({
					index
					type
				})

				++index
			}

			if parameter.max() == Infinity {
				line.rest = {
					index
					type
				}

				index = count - min
			}
			else {
				for const i from parameter.min() + 1 to parameter.max() while count < min {
					line.filters.push({
						index
						type
					})

					++index
					++count
				}
			}
		}

		return line
	} // }}}

	func checkMethods(methods, parameters, min, max, sortedIndex, sortedIndexes, assessment, filters) { // {{{
		const index = sortedIndexes[sortedIndex]

		if !?parameters[index + 1] {
			NotSupportedException.throw()
		}

		const tree = []
		const usages = []

		for const type of parameters[index + 1].types {
			const item = {
				type: type.type
				methods: [methods[i] for const i in type.methods]
				usage: type.methods.length
			}

			tree.push(item)

			if type.type.isAny() {
				item.weight = 0
			}
			else {
				item.weight = 1_00
			}

			for const i in type.methods {
				const method = methods[i]

				let nf = true

				let usage
				for usage in usages while nf {
					if usage.method == method {
						nf = false
					}
				}

				if nf {
					usages.push({
						method: method,
						types: [item]
					})
				}
				else {
					usage.types.push(item)
				}
			}
		}

		if tree.length == 0 {
			checkMethods(methods, parameters, min, max, sortedIndex + 1, sortedIndexes, assessment, filters)
		}
		else if tree.length == 1 {
			item = tree[0]

			if item.methods.length == 1 {
				assessment.push({
					method: item.methods[0]
					index: item.methods[0].index()
					min
					max
					filters
				})
			}
			else if item.methods.length == 2 && sortedIndex + 1 == max {
				let maxed = null

				for const method in item.methods {
					if method.max() == max {
						if maxed == null {
							maxed = method
						}
						else {
							NotSupportedException.throw()
						}
					}
				}

				if maxed != null {
					assessment.push({
						method: maxed
						index: maxed.index()
						min
						max
						filters
					})
				}
				else {
					NotSupportedException.throw()
				}
			}
			else {
				checkMethods(methods, parameters, min, max, sortedIndex + 1, sortedIndexes, assessment, filters)
			}
		}
		else {
			for const usage in usages {
				let count = usage.types.length

				for const type in usage.types while count >= 0 {
					count -= type.usage
				}

				if count == 0 {
					const item = {
						type: [],
						path: [],
						methods: [usage.method]
						usage: 0
						weight: 0
					}

					for const type in usage.types {
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
					if a.type.length == 1 && b.type.length == 1 {
						const ac = a.type[0].type()
						const bc = b.type[0].type()

						if ac.isClass() && bc.isClass() {
							if ac.matchInheritanceOf(bc) {
								return -1
							}
							else if bc.matchInheritanceOf(ac) {
								return 1
							}
						}
					}

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
				if i + 1 == tree.length {
					if item.methods.length == 1 {
						assessment.push({
							method: item.methods[0]
							index: item.methods[0].index()
							min
							max
							filters
							argFilters: [
								{
									min
									max
									filters: [
										{
											index
											type: item.type[0]
										}
									]
								}
							]
						})
					}
					else {
						checkMethods(methods, parameters, min, max, sortedIndex + 1, sortedIndexes, assessment, filters)
					}
				}
				else {
					const filters = filters.slice()

					filters.push({
						index
						type: item.type[0]
					})

					if item.methods.length == 1 {
						assessment.push({
							method: item.methods[0]
							index: item.methods[0].index()
							min
							max
							filters
						})
					}
					else {
						checkMethods(methods, parameters, min, max, sortedIndex + 1, sortedIndexes, assessment, filters)
					}
				}
			}
		}
	} // }}}

	func checkInfinityMethods(methods, parameters, min, index, assessment, filters) { // {{{
		if !?parameters[index + 1] {
			NotSupportedException.throw()
		}
		else if parameters[index + 1] is Number {
			index = parameters[index + 1] - 1
		}

		const tree = []
		const usages = []

		let type, nf, item, usage, i
		for const type of parameters[index + 1].types {
			tree.push(item = {
				type: type.type
				methods: [methods[i] for i in type.methods]
				usage: type.methods.length
			})

			if type.type.isAny() {
				item.weight = 0
			}
			else {
				item.weight = 1_000
			}

			for i in type.methods {
				method = methods[i]

				nf = true
				for usage in usages while nf {
					if usage.method == method {
						nf = false
					}
				}

				if nf {
					usages.push(usage = {
						method: method,
						types: [item]
					})
				}
				else {
					usage.types.push(item)
				}
			}
		}

		if tree.length == 0 {
			checkInfinityMethods(methods, parameters, min, index + 1, assessment, filters)
		}
		else if tree.length == 1 {
			item = tree[0]

			if item.methods.length == 1 {
				assessment.push({
					method: item.methods[0]
					index: item.methods[0].index()
					min
					max: Infinity
					filters
				})
			}
			else {
				checkInfinityMethods(methods, parameters, min, index + 1, assessment, filters)
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
						methods: [usage.method]
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
					if item.methods.length == 1 {
						assessment.push({
							method: item.methods[0]
							index: item.methods[0].index()
							min
							max: Infinity
							filters
						})
					}
					else {
						checkInfinityMethods(methods, parameters, min, index + 1, assessment, filters)
					}
				}
				else {
					const filters = filters.slice()

					filters.push({
						index
						type: item.type[0]
					})

					if item.methods.length == 1 {
						assessment.push({
							method: item.methods[0]
							index: item.methods[0].index()
							min
							max: Infinity
							filters
						})
					}
					else {
						checkInfinityMethods(methods, parameters, min, index + 1, assessment, filters)
					}
				}
			}
		}
	} // }}}

	func isFlattenable(methods) { // {{{
		if methods.length <= 1 {
			return true
		}

		const done = {}
		let min = 0

		for const method in methods when done[method.index] != true {
			done[method.index] = true

			for const m in methods when m.index == method.index {
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

	func mapMethod(method, target, map) { // {{{
		let index = 1
		let count = method.min()
		let item
		let fi = false

		for const parameter, p in method.parameters() {
			for const i from 1 to parameter.min() {
				if item !?= map[index] {
					item = map[index] = {
						index: index
						types: {}
						weight: 0
					}
				}

				mapParameter(parameter.type(), method.index(), item, target)

				++index
			}

			if parameter.max() == Infinity {
				if !fi {
					fi = true

					const oldIndex = index

					index -= method.min() + 1
					map[oldIndex] = index
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

					mapParameter(parameter.type(), method.index(), item, target)

					++index
					++count
				}
			}
		}
	} // }}}

	func mapParameter(type, method, map, target) { // {{{
		if type is UnionType {
			for value in type.types() {
				mapParameter(value, method, map, target)
			}
		}
		else {
			if map.types[type.hashCode()] is Object {
				map.types[type.hashCode()].methods.push(method)
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
					methods: [method]
					weight
				}

				map.weight += weight
			}
		}
	} // }}}

	export func matchArguments(assessment, arguments) { // {{{
		const matches = []

		const length = arguments.length

		for const method in assessment.methods when method.min <= length <= method.max {
			if method.filters.length == 0 && !?method.argFilters {
				matches.push(method.method)
			}
			else {
				let matched = true
				let perfect = true

				for const filter in method.filters while matched {
					if arguments[filter.index].isAny() {
						perfect = false
					}
					else if !arguments[filter.index].matchContentOf(filter.type) {
						matched = false
					}
				}

				if method.argFilters? {
					let notFound = true

					for const line in method.argFilters while notFound when line.min <= length <= line.max {
						let isMatched = true
						let isPerfect = perfect

						for const filter in line.filters while isMatched {
							if arguments[filter.index].isAny() {
								isPerfect = false
							}
							else if !arguments[filter.index].matchContentOf(filter.type) {
								isMatched = false
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
						return [method.method]
					}
					else {
						matches.push(method.method)
					}
				}
			}
		}

		return matches
	} // }}}

	func sortTreeMin(methods, max) { // {{{
		if max == Infinity {
			const tree = {
				keys: []
			}

			for const method in methods {
				if tree[method.min]? {
					tree[method.min].push(method)
				}
				else {
					tree[method.min] = [method]

					tree.keys.push(method.min)
				}
			}

			if tree.keys.length == 1 && tree.keys[0] == 0 {
				return tree['0']
			}
			else {
				return tree
			}
		}
		else {
			const tree = {
				equal: []
				midway: {
					keys: []
				}
			}

			for const method in methods {
				if method.min == max {
					tree.equal.push(method)
				}
				else {
					if tree.midway[method.min]? {
						tree.midway[method.min].push(method)
					}
					else {
						tree.midway[method.min] = [method]

						tree.midway.keys.push(method.min)
					}
				}
			}

			if tree.equal.length == 1 && tree.midway.keys.length == 0 {
				return tree.equal
			}
			else {
				return tree
			}
		}
	} // }}}

	export func toFragments(assessment, fragments, argName, returns, header, footer, call, wrongdoer, node) { // {{{
		const block = header(node, fragments)

		if assessment.methods.length == 0 {
			wrongdoer(block, null, argName, assessment.async, returns)
		}
		else if assessment.methods.length == 1 {
			const method = assessment.methods[0].method
			const min = method.absoluteMin()
			const max = method.absoluteMax()

			if min == 0 && max >= Infinity {
				call(block, method, 0)
			}
			else if min == max {
				const ctrl = block.newControl()

				ctrl.code(`if(\(argName).length === \(min))`).step()

				call(ctrl, method, 0)

				wrongdoer(block, ctrl, argName, assessment.async, returns)
			}
			else if max < Infinity {
				const ctrl = block.newControl()

				ctrl.code(`if(\(argName).length >= \(min) && \(argName).length <= \(max))`).step()

				call(ctrl, method, 0)

				wrongdoer(block, ctrl, argName, assessment.async, returns)
			}
			else {
				call(block, method, 0)
			}
		}
		else if assessment.flattenable {
			const ctrl = block.newControl()

			let ne = false

			for const method in assessment.methods when method.done != true {
				ne = toFlatFragments(assessment, method, ctrl, argName, call, node)
			}

			if ne {
				wrongdoer(block, ctrl, argName, assessment.async, returns)
			}
			else {
				ctrl.done()
			}
		}
		else {
			const tree = {}
			for const method in assessment.methods {
				if tree[method.max]? {
					tree[method.max].push(method)
				}
				else {
					tree[method.max] = [method]
				}
			}

			for const methods, max of tree {
				tree[max] = sortTreeMin(methods, methods[0].max)
			}

			const ctrl = block.newControl()

			let ne = false

			for const item of tree {
				if item is Array {
					ne = toEqLengthFragments(item, ctrl, argName, call, node)
				}
				else {
					ne = toMixLengthFragments(item, ctrl, argName, call, node)
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

	func toEqLengthFragments(methods, ctrl, argName, call, node) { // {{{
		const method = methods[0]

		if method.max == Infinity && method.min == 0 {
			unless ctrl.isFirstStep() {
				ctrl.step().code('else').step()
			}
		}
		else {
			unless ctrl.isFirstStep() {
				ctrl.step().code('else ')
			}

			ctrl.code(`if(`)

			if method.min == method.max {
				ctrl.code(`\(argName).length === \(method.min)`)
			}
			else if method.max == Infinity {
				ctrl.code(`\(argName).length >= \(method.min)`)
			}
			else if method.min + 1 == method.max {
				ctrl.code(`\(argName).length === \(method.min) || \(argName).length === \(method.max)`)
			}
			else {
				ctrl.code(`\(argName).length >= \(method.min) && \(argName).length <= \(method.max)`)
			}

			ctrl.code(`)`).step()
		}

		if methods.length == 1 {
			call(ctrl, method.method, method.index)

			return !(method.max == Infinity && method.min == 0)
		}
		else {
			const ctrl2 = ctrl.newControl()

			let ne = false

			for const method in methods {
				ne = toTreeTestFragments(method, ctrl2, argName, call, node)
			}

			ctrl2.done()

			return ne
		}
	} // }}}

	func toFlatFragments(assessment, method, ctrl, argName, call, node) { // {{{
		const matchs = [m for const m in assessment.methods when m.done != true && m.index == method.index]

		if matchs.length == 1 && matchs[0].min == 0 && matchs[0].max == Infinity && matchs[0].filters.length == 0 {
			unless ctrl.isFirstStep() {
				ctrl.step().code('else').step()
			}

			call(ctrl, method.method, method.index)

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

			call(ctrl, method.method, method.index)

			return true
		}
	} // }}}

	func toFlatTestFragments(match, ctrl, wrap, argName, node) { // {{{
		wrap = wrap && match.filters.length != 0

		if wrap {
			ctrl.code('(')
		}

		if match.min == match.max {
			ctrl.code(`\(argName).length === \(match.min)`)
		}
		else if match.max == Infinity {
			ctrl.code(`\(argName).length >= \(match.min)`)
		}
		else if match.min + 1 == match.max {
			ctrl.code(`\(argName).length === \(match.min) || \(argName).length === \(match.max)`)
		}
		else {
			ctrl.code(`\(argName).length >= \(match.min) && \(argName).length <= \(match.max)`)
		}

		if match.filters.length == 1{
			ctrl.code(' && ')

			const index = match.filters[0].index
			if index >= 0 {
				match.filters[0].type.toTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(index)]`))
			}
			else {
				match.filters[0].type.toTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(argName).length - \(-index - 1)]`))
			}
		}
		else if match.filters.length > 1 {
			throw new NotImplementedException(node)
		}

		match.done = true

		if wrap {
			ctrl.code(')')
		}
	} // }}}

	func toMixLengthFragments(tree, ctrl, argName, call, node) { // {{{
		let ne = false

		if tree.equal.length != 0 {
			ne = toEqLengthFragments(tree.equal, ctrl, argName, call, node)
		}

		if tree.midway.keys.length == 1 {
			ne = toEqLengthFragments(tree.midway[tree.midway.keys[0]], ctrl, argName, call, node)
		}
		else if tree.midway.keys.length > 1 {
			throw new NotImplementedException(node)
		}

		return ne
	} // }}}

	func toTreeTestFragments(method, ctrl, argName, call, node) { // {{{
		if method.filters.length == 0 {
			unless ctrl.isFirstStep() {
				ctrl.step().code('else').step()
			}
		}
		else {
			unless ctrl.isFirstStep() {
				ctrl.step().code('else ')
			}

			ctrl.code(`if(`)

			if method.filters.length == 1 {
				const index = method.filters[0].index
				if index >= 0 {
					method.filters[0].type.toTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(index)]`))
				}
				else {
					method.filters[0].type.toTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(argName).length - \(-index - 1)]`))
				}
			}
			else if method.filters.length > 1 {
				throw new NotImplementedException(node)
			}

			ctrl.code(`)`).step()
		}

		call(ctrl, method.method, method.index)

		return true
	} // }}}
}