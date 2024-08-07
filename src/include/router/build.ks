namespace Build {
	export {
		func buildRoute(functions: FunctionType[], name: String, ignoreIndistinguishable: Boolean, excludes: String[], node: AbstractNode): Route { # {{{
			var parameters = {
				functions: {}
				names: {}
			}

			var mut min = Infinity
			var mut max = 0
			var mut maxRest = 0
			var mut rest = false

			var mmmin = MinMax.POSITIONAL + MinMax.ASYNC + MinMax.REST
			var mmmax = MinMax.POSITIONAL + MinMax.ASYNC

			for var function in functions {
				if var parameter ?= function.getRestParameter() {
					rest = true

					min = Math.min(function.min(mmmin, excludes), min)
					maxRest = Math.max(function.max(mmmax, excludes) + parameter.min() + 1, maxRest)
				}
				else {
					min = Math.min(function.min(mmmin, excludes), min)
					max = Math.max(function.max(mmmax, excludes), max)
				}
			}

			var groups: Object<Group> = {}

			if rest {
				if max == 0 {
					max = maxRest
				}
				else if max < maxRest {
					max = maxRest
				}
				else {
					max += 1
				}
			}

			for var n from min to max {
				groups[n] = Group.new(n)
			}

			for var function in functions {
				if function.hasRestParameter() {
					for var n from function.min(mmmin, excludes) to max {
						groups[n].functions.push(function)
					}
				}
				else {
					for var n from function.min(mmmin, excludes) to function.max(mmmax, excludes) {
						groups[n].functions.push(function)
					}
				}

				parameters.functions[function.index()] = function

				for var parameter in function.parameters() when !parameter.isOnlyLabeled() {
					var external = parameter.getExternalName() ?? '_'

					if var group ?= parameters.names[external] {
						group.push(`\(function.index())`)
					}
					else {
						parameters.names[external] = [`\(function.index())`]
					}
				}
			}

			var trees: Tree[] = []
			var aliases: Type{} = {}

			for var group of groups when group.functions.length > 0/*  && group.n == 1 */ {
				var tree = buildTree(group, aliases, name, ignoreIndistinguishable, excludes, node)

				trees.push(tree)
			}

			RegroupTree.regroupTrees(trees, node)

			Unbounded.expandUnboundeds(trees, node)

			if ?#aliases {
				for var tree in trees {
					replaceAliases(tree, aliases)
				}
			}

			var functionMap = {}

			for var function in functions {
				functionMap[function.index()] = function
			}

			return Route.new(
				functions: functionMap
				trees
			)
		} # }}}

		func getRoute(assessment: Assessment, labels: String[], functions: FunctionType[], node: AbstractNode): Route { # {{{
			var key = `\(labels.sort((a, b) => a.localeCompare(b)).join(','))|\(functions.map((function, ...) => function.index()).sort((a, b) => a - b).join(','))`

			if var route ?= assessment.routes[key] {
				return route
			}

			var route = Build.buildRoute(functions, assessment.name, true, labels, node)

			assessment.routes[key] = route

			return route
		} # }}}
	}

	namespace Zero {
		export func buildTree(group: Group, name: String, node: AbstractNode): Tree { # {{{
			var mut master = group.functions[0]
			var sameLength = []

			for var function in group.functions from 1 {
				if function.max() == master.max() {
					sameLength.push(function)
				}
				else if function.max() < master.max() {
					master = function
				}
			}

			if sameLength.length != 0 {
				var mut errors = []

				for var function in sameLength {
					if function.isMorePreciseThan(master) {
						pass
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

			return Tree.new(
				min: 0
				function: master
			)
		} # }}}
	}

	namespace One {
		export func expandGroup(group: Group, name: String, ignoreIndistinguishable: Boolean, excludes: String[]?, node: AbstractNode): Void { # {{{
			for var function in group.functions {
				var mut argIndex = 0
				var mut min = function.min(excludes)
				var mut parameters = function.parameters(excludes)

				if function.isAsync() {
					var scope = node.scope()

					var parameter = ParameterType.new(scope, scope.reference('Function')).index(parameters.length)

					parameters = [...parameters, parameter]

					min += 1
				}

				if min == 1 {
					var mut nullTested = false

					for var parameter in parameters {
						if parameter.min() == 1 {
							var type = parameter.type().toTestType()

							addGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, type, nullTested, null, parameter.index(), argIndex)

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
					var types = []
					var mut nullTested = false

					for var parameter in parameters {
						var type = parameter.type().toTestType()
						var mut addable = true

						for var t in types while addable {
							if type.isAssignableToVariable(t, false, false, true) {
								addable = false
							}
						}

						if addable {
							addGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, type, nullTested, null, parameter.index(), argIndex)

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
		} # }}}

		func addGroupRow(
			group: Group
			name: String
			ignoreIndistinguishable: Boolean
			node: AbstractNode
			function: FunctionType
			parameters: ParameterType[]
			parameter: ParameterType
			type: Type
			nullTested: Boolean
			union: UnionMatch?
			paramIndex: Number
			argIndex: Number
		): Void { # {{{
			if type.isSplittable() {
				var types = type.split([])
				var newUnion = UnionMatch.new(
					function
					length: types.length
					matches: []
				)

				if nullTested {
					for var subtype in types when !subtype.isNull() {
						addGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, subtype, nullTested, newUnion, paramIndex, argIndex)
					}
				}
				else {
					for var subtype in types {
						addGroupRow(group, name, ignoreIndistinguishable, node, function, parameters, parameter, subtype, nullTested, newUnion, paramIndex, argIndex)
					}
				}
			}
			else {
				var key = `;\(argIndex);\(type.hashCode())`
				var rest = parameter.max() == Infinity

				var mut addable = true

				if rest {
					for var param in parameters from paramIndex + 1 while addable {
						if type.isAssignableToVariable(param.type(), false, false, true) {
							addable = false
						}
					}
				}

				if addable {
					var mut matchFunction = null
					var mut matchUnion = null

					if ?group.rows[key] {
						matchFunction = group.rows[key].function
						matchUnion = group.rows[key].union
					}
					else if argIndex == -1 && ?group.rows[`;0;\(type.hashCode())`] {
						matchFunction = group.rows[`;0;\(type.hashCode())`].function
						matchUnion = group.rows[`;0;\(type.hashCode())`].union
					}
					else {
						group.rowCount += 1
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
					var mut names = null

					if parameter.isLabeled() {
						names = {
							[parameter.getExternalName()]: [type.hashCode()]
						}
					}

					group.rows[key] = Row.new(
						key
						function
						union
						types: [
							RowType.new(
								index: argIndex
								type
								rest
								parameter: paramIndex
							)
						]
						names
					)
				}
			}
		} # }}}
	}

	namespace Legion {
		export func expandGroup(group: Group, aliases: Type{}, name: String, ignoreIndistinguishable: Boolean, excludes: String[], node: AbstractNode): Void { # {{{
			for var function in group.functions {
				var min = function.min(MinMax.POSITIONAL + MinMax.ASYNC + MinMax.REST, excludes)
				var minAfter = function.min(MinMax.AFTER_REST + MinMax.ASYNC, excludes)
				var mut parameters = function.parameters(excludes)

				if function.isAsync() {
					var scope = node.scope()

					parameters = [...parameters, ParameterType.new(scope, scope.reference('Function')).index(parameters.length)]
				}

				expandFunction(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, group.n, group.n - min, 0, 0, 0, -1, '', [], {})
			}
		} # }}}

		func expandFunction(
			group: Group
			aliases: Type{}
			name: String
			ignoreIndistinguishable: Boolean
			node: AbstractNode
			function: FunctionType
			parameters: ParameterType[]
			minAfter: Number
			target: Number
			remaining: Number
			paramIndex: Number
			stepIndex: Number
			stepCount: Number
			argIndex: Number
			key: String
			types: RowType[]
			names: String[]{}?
		): Void { # {{{
			if types.length == target {
				if var match ?= group.rows[key] {
					if function == match.function {
						group.rows[key] = Row.new(
							key
							function
							types
							names
						)
					}
					else if function.max() == match.function.max() {
						SyntaxException.throwIndistinguishableFunctions(name, match.types.map(({ type }, _, _) => type), [function, match.function], node) unless ignoreIndistinguishable
					}
					else if function.max() < match.function.max() {
						group.rows[key] = Row.new(
							key
							function
							types
							names
						)
					}
				}
				else {
					group.rows[key] = Row.new(
						key
						function
						types
						names
					)

					group.rowCount += 1
				}
			}
			else if paramIndex < parameters.length || (function.isAsync() && paramIndex == parameters.length) {
				var parameter = parameters[paramIndex]
				var type = parameter.getArgumentType()
				var min = parameter.min()
				var max = parameter.max()

				if stepIndex == 0 {
					if stepCount < min {
						expandParameter(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex, 0, stepCount + 1, max == Infinity, argIndex + 1, key, types, names, type)
					}
					else {
						var rest = max == Infinity

						if paramIndex + 1 < parameters.length {
							if rest {
								expandFunction(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, -remaining - minAfter - 1, key, types, names)
							}
							else {
								if stepCount == max || hasMin(type, paramIndex + 1, parameters, remaining) {
									expandFunction(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, argIndex, key, types, names)
								}
							}
						}

						if rest {
							for var i from 1 to getMaxRestExpand(paramIndex, parameters, remaining, function) {
								expandParameter(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining - 1, paramIndex, i, 1, rest, argIndex + 1, key, types, names, type)
							}
						}
						else {
							for var i from 1 to Math.min(max - min, remaining) {
								expandParameter(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining - 1, paramIndex, i, 1, rest, argIndex + 1, key, types, names, type)
							}
						}
					}
				}
				else if stepCount < stepIndex {
					expandParameter(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining - 1, paramIndex, stepIndex, stepCount + 1, max == Infinity, argIndex + 1, key, types, names, type)
				}
				else {
					if max == Infinity {
						expandFunction(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, -remaining - minAfter - 1, key, types, names)
					}
					else if remaining == 0 || stepCount + min >= max || hasMin2(type, paramIndex + 1, parameters) {
						expandFunction(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex + 1, 0, 0, argIndex, key, types, names)
					}
				}
			}
		} # }}}

		func expandParameter(
			group: Group
			aliases: Type{}
			name: String
			ignoreIndistinguishable: Boolean
			node: AbstractNode
			function: FunctionType
			parameters: ParameterType[]
			minAfter: Number
			target: Number
			remaining: Number
			paramIndex: Number
			stepIndex: Number
			stepCount: Number
			rest: Boolean
			argIndex: Number
			mut key: String
			mut types: RowType[]
			mut names: String[]{}?
			type: Type
		): Void { # {{{
			if type.isUnion() {
				if type.isAlias() {
					var notNull = type.setNullable(false)
					var hash = notNull.discard().hashCode()

					aliases[hash] ??= notNull
					aliases[`\(hash)|Null`] ??= type.setNullable(true)
				}

				var mut union = type.discard():!!!(UnionType)

				if type.isNullable() && !union.isNullable() {
					union = union.setNullable(true)
				}

				for var value in union.types() {
					expandParameter(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex, stepIndex, stepCount, rest, argIndex, key, types, names, value)
				}
			}
			else {
				var parameter = parameters[paramIndex]

				key = `\(key);\(argIndex);\(type.hashCode())`

				types = [
					...types
					RowType.new(
						index: argIndex
						type
						rest
						parameter: parameter.index()
					)
				]

				if ?names {
					names = {...names}

					var external = parameter.getExternalName()

					if var hashes ?= names[external] {
						names[external] = [...hashes, type.hashCode()]
					}
					else {
						names[external] = [type.hashCode()]
					}
				}

				expandFunction(group, aliases, name, ignoreIndistinguishable, node, function, parameters, minAfter, target, remaining, paramIndex, stepIndex, stepCount, argIndex, key, types, names)
			}
		} # }}}

		func getMaxRestExpand(restIndex: Number, parameters: ParameterType[], remaining: Number, function: FunctionType): Number { # {{{
			var min = function.min(MinMax.AFTER_REST + MinMax.ASYNC)
			var max = function.max(MinMax.AFTER_REST + MinMax.ASYNC)

			return remaining if min == max

			var restType = parameters[restIndex].type()
			var mut count = remaining
			var mut delta = 0
			var mut addToCount = true

			for var parameter in parameters from restIndex + 1 {
				var d = parameter.max() - parameter.min()

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
					delta += parameter.min():!!!(Number)

					if d == 0 {
						addToCount = false
					}
				}
			}

			return Math.min(count, remaining)
		} # }}}

		func hasMin(type: Type, index: Number, parameters: ParameterType[], remaining: Number): Boolean { # {{{
			for var parameter in parameters from index {
				if (remaining == 0 && parameter.min() > 0) || !parameter.type().isAssignableToVariable(type, false, false, true) {
					return true
				}
			}

			return false
		} # }}}

		func hasMin2(type: Type, index: Number, parameters: ParameterType[]): Boolean { # {{{
			for var parameter in parameters from index {
				if !parameter.type().isAssignableToVariable(type, false, false, true) {
					return true
				}
			}

			return false
		} # }}}
	}

	namespace Flat {
		export func buildTree(function: FunctionType, rows, n: Number, excludes: String[], node: AbstractNode): Tree { # {{{
			var arguments = {}
			var parameters = {}
			var mut lastIndex = 0

			var mut fnParameters = function.parameters()

			if function.isAsync() {
				var scope = node.scope()

				fnParameters = [...fnParameters, ParameterType.new(scope, scope.reference('Function'))]
			}

			for var row of rows {
				for var type in row.types {
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

			for var row of rows {
				var args = {}

				for var type in row.types {
					if ?args[type.parameter] {
						args[type.parameter] += 1
					}
					else {
						args[type.parameter] = 1
					}
				}

				var mut last = -1

				for var { index } of parameters {
					last += 1

					while last < index {
						if var argument ?= arguments[last] {
							arguments[last].push(0)
						}
						else {
							arguments[last] = [0]
						}

						last += 1
					}

					var size = args[index] ?? 0

					if var argument ?= arguments[index] {
						arguments[index].push(size)
					}
					else {
						arguments[index] = [size]
					}
				}
			}

			var mut argCount = 0

			for var parameter of parameters {
				parameter.argIndex = argCount
				parameter.min = Math.min(...arguments[parameter.index]!?)
				parameter.max = Math.max(...arguments[parameter.index]!?)

				argCount += 1

				var type = parameter.parameter.getArgumentType().toTestType()

				if type.isNullable() {
					var types = type.split([Type.Null])

					parameter.argType = Type.union(node.scope(), ...types!?).sort()
				}
				else {
					parameter.argType = type.sort()
				}
			}

			var row = Row.new(
				function
				key: ''
				types: []
			)

			var mut afterRest = false
			var byNames = []

			for var { parameter, index, argIndex, argType % type } of parameters {
				var hash = type.hashCode()
				var key = `;\(if afterRest set argIndex - argCount else argIndex);\(hash)`
				var rest = parameter.max() == Infinity

				row.key += key
				row.types.push(RowType.new(
					index: (if afterRest set argIndex - argCount else argIndex):!!!(Number)
					type: type:!!!(Type)
					rest
					parameter: index:!!!(Number)
				))

				if rest {
					afterRest = true
				}

				if parameter.isOnlyLabeled() && parameter.min() > 0 {
					byNames.push(parameter.getExternalName())
				}
			}

			var tree = Tree.new(n)
			var dyn column = tree
			var mut variadic = false

			afterRest = false

			for var { parameter, index, argIndex, argType % type } of parameters {
				var hash = type.hashCode()
				var key = `:\(function.index()):\(index)`
				var rest = parameter.max() == Infinity
				var { min, max } = parameters[index]

				if !variadic && min != max {
					variadic = true
				}

				if index == lastIndex {
					column.columns[hash] = TreeLeaf.new(
						index: (if afterRest set argIndex - argCount else argIndex):!!!(Number)
						type: type:!!!(Type)
						min: min:!!!(Number)
						max: max:!!!(Number)
						variadic
						rest
						isNode: false
						parameters: {
							[key]: TreeParameter.new(
								key
								function
								parameter: index:!!!(Number)
								rows: [row.key]
							)
						}
						function
						arguments: []
						rows: [row]
						byNames
					)
				}
				else {
					column.columns[hash] = TreeBranch.new(
						index: (if afterRest set argIndex - argCount else argIndex):!!!(Number)
						type: type:!!!(Type)
						min: min:!!!(Number)
						max: max:!!!(Number)
						variadic
						rest
						parameters: {
							[key]: TreeParameter.new(
								key
								function
								parameter: index:!!!(Number)
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
		} # }}}

		export func isFlattenable(group: Group, excludes: String[], node: AbstractNode): Boolean { # {{{
			return false unless group.functions.length == 1

			var function = group.functions[0]
			var mut parameters = function.parameters(excludes)

			if function.isAsync() {
				var scope = node.scope()

				parameters = [...parameters, ParameterType.new(scope, scope.reference('Function'))]
			}

			var mut count = 0
			for var parameter in parameters {
				if parameter.isVarargs() || parameter.min() == 0 {
					count += 1
				}
			}

			return true unless count > 1

			for var parameter, index in parameters to~ -1 {
				var nextParameter = parameters[index + 1]
				var currType = parameters[index].type()
				var nextType = nextParameter.type()

				if
					((parameter.isVarargs() || parameter.min() == 0) && nextType.isAssignableToVariable(currType, false, true, false)) ||
					(parameter.min() == 0 && nextParameter.min() != 0 && currType.isNullable() && nextParameter.hasDefaultValue())
				{
					return false
				}
			}

			return true
		} # }}}
	}

	namespace Pyramid {
		export func buildNode(tree: Tree, mut branch: TreeBranch, pIndex: Number, max: Number, name: String, node: AbstractNode): TreeColumn { # {{{
			var usages: Object<Number> = {}
			for var row in branch.rows {
				var index = row.function.index()

				usages[index] = (usages[index] ?? 0) + 1
			}

			var next = pIndex + 1

			if next == max {
				for var row in branch.rows {
					var {type, index, rest, parameter} = row.types[pIndex]
					var hash = type.hashCode()

					if var match ?= branch.columns[hash] {
						SyntaxException.throwIndistinguishableFunctions(name, match.rows[0].types.map((val, _, _) => val.type), [match:!!!(TreeLeaf).function, row.function], node)
					}

					var key = `:\(row.function.index()):\(parameter)`

					branch.columns[hash] = TreeLeaf.new(
						index
						type
						rest
						variadic: rest
						isNode: false
						parameters: {
							[key]: TreeParameter.new(
								key
								function: row.function
								parameter
								rows: [row.key]
							)
						}
						function: row.function
						arguments: []
						rows: [row]
						byNames: []
					)
				}
			}
			else {
				for var row in branch.rows {
					var {type, index, rest, parameter} = row.types[pIndex]
					var hash = type.hashCode()
					var key = `:\(row.function.index()):\(parameter)`

					if !?branch.columns[hash] {
						branch.columns[hash] = TreeBranch.new(
							index
							type
							rest
							variadic: rest
							parameters: {
								[key]: TreeParameter.new(
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
						var builtBranch: TreeBranch = branch.columns[hash]!!

						builtBranch.rows.push(row)

						if !?builtBranch.parameters[key] {
							builtBranch.parameters[key] = TreeParameter.new(
								key
								function: row.function
								parameter
								rows: [row.key]
							)
						}
						else {
							builtBranch.parameters[key].rows.push(row.key)
						}
					}
				}

				for var child, key of branch.columns when child.isNode {
					branch.columns[key] = buildNode(tree, child!!, next, max, name, node)
				}
			}

			sortNodes(branch)

			if next == max {
				Regroup.regroupLeaf_SiblingsEq(branch, node)
			}

			Regroup.regroupBranch_TopForkEqLastChild(branch)

			Regroup.regroupBranch_ForkEq_ChildrenEqFunc(branch)

			Regroup.regroupBranch_SiblingsEqChildren(branch)

			Regroup.regroupBranch_ChildrenEqFunc_Flatten(branch, node)

			Regroup.regroupBranch_Children_ForkAlike_SiblingsEq(branch, node)

			return Regroup.regroupBranch_EqParameter(branch)
		} # }}}

		export func createTree(rows: Row{}, min: Number): Tree { # {{{
			var tree = Tree.new(min)

			var usages: Object<Number> = {}
			for var _, key of rows {
				var index = rows[key].function.index()

				usages[index] = (usages[index] ?? 0) + 1
			}

			if min == 1 {
				for var row of rows {
					var {type, index, rest, parameter} = row.types[0]
					var hash = type.hashCode()

					if ?tree.columns[hash] {
						NotSupportedException.throw()
					}

					var key = `:\(row.function.index()):\(parameter)`

					tree.columns[hash] = TreeLeaf.new(
						index
						type
						rest
						variadic: rest
						isNode: false
						parameters: {
							[key]: TreeParameter.new(
								key
								function: row.function
								parameter
								rows: [row.key]
							)
						}
						function: row.function
						arguments: []
						rows: [row]
						byNames: []
					)
				}
			}
			else {
				for var row of rows {
					var {type, index, rest, parameter} = row.types[0]
					var hash = type.hashCode()
					var key = `:\(row.function.index()):\(parameter)`

					if !?tree.columns[hash] {
						tree.columns[hash] = TreeBranch.new(
							index
							type
							rest
							variadic: rest
							parameters: {
								[key]: TreeParameter.new(
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
						var branch: TreeBranch = tree.columns[hash]!!

						if branch.index < 0 && index >= 0 {
							for var branchRow in branch.rows {
								for var rowType in branchRow.types when rowType.index == branch.index {
									rowType.index = index
								}
							}

							branch.index = index
						}

						branch.rows.push(row)

						if !?branch.parameters[key] {
							branch.parameters[key] = TreeParameter.new(
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
		} # }}}
	}

	namespace Regroup {
		export {
			func regroupBranch_Children_ForkAlike_SiblingsEq(branch: TreeBranch | Tree, node: AbstractNode): Void { # {{{
				return unless branch.order.length > 1

				var groups = {}

				for var key in branch.order {
					var column = branch.columns[key]

					var late hash: String

					if column.node {
						hash =	`:\(column.min):\(column.max):\(column.variadic):\(column.rest)`
								+ ';' + Object.keys(column.parameters).sort((a, b) => a.localeCompare(b)).join(';')
								+ ';' + getForkHash(column, 0)
					}
					else {
						hash = Object.keys(column.parameters).sort((a, b) => a.localeCompare(b)).join(';')
					}

					if var group ?= groups[hash] {
						group.push(key)
					}
					else {
						groups[hash] = [key]
					}
				}

				var scope = node.scope()
				var mut reorder = false

				for var group of groups when group.length > 1 {
					var main = branch.columns[group[0]]

					var types = []
					for var key, i in group {
						types.push(branch.columns[key].type)

						if i != 0 {
							main.rows.push(...branch.columns[key].rows)
						}

						branch.order.remove(key)

						Object.delete(branch.columns, key)
					}

					main.type = Type.union(scope, ...types).sort()

					branch.columns[main.type.hashCode()] = main

					reorder = true
				}

				if reorder {
					sortNodes(branch)
				}
			} # }}}

			func regroupBranch_ChildrenEqFunc_Flatten(branch: TreeBranch, node: AbstractNode): Void { # {{{
				return unless branch.order.length >= 2

				var mut first = branch.columns[branch.order[0]]

				if var function ?= getFunction(branch) {
					var param2row = {}
					for var parameter, key of branch.parameters {
						param2row[key] = parameter.rows
					}
					for var parameter, key of first.parameters {
						if var rows ?= param2row[key] {
							for var row in parameter.rows {
								return unless rows:!!!(Array).contains(row)
							}
						}
					}

					var rows = [...first.rows]

					for var key in branch.order from 1 {
						var column = branch.columns[key]

						if branch.type.isAssignableToVariable(column.type, false, true, false) {
							return
						}

						rows.pushUniq(...column.rows)
					}

					var column = buildBranchFromRows(rows, branch.index + 1, node)
					var type = column.type.hashCode()

					branch.columns = {
						[type]: column
					}
					branch.order = [type]
				}
			} # }}}

			func regroupBranch_EqParameter(branch: TreeBranch): TreeColumn { # {{{
				var columns = Object.values(branch.columns)

				if	columns.length == 1 &&
					Object.length(branch.parameters) == 1 &&
					Object.length(columns[0].parameters) == 1 &&
					Object.value(branch.parameters, 0).key == Object.value(columns[0].parameters, 0).key &&
					branch.type.hashCode() == branch.order[0]
				{
					var child = columns[0]

					child.index = branch.index
					child.min += branch.min
					child.max += branch.max

					return child
				}
				else {
					return branch
				}
			} # }}}

			func regroupBranch_ForkEq_ChildrenEqFunc(branch: TreeBranch): Void { # {{{
				return unless branch.order.length >= 2

				var type = branch.type.hashCode()

				return unless branch.order[0] == type

				var column = branch.columns[type]!?

				if isSameFork(branch, column) {

					if isRegroupeableBranch(branch, column, type) {
						branch.max += column.max
						branch.variadic = true

						var mins = {}

						for var key in column.order {
							mins[key] = buildMin(column.columns[key])
						}

						applyMin2(branch, mins, type)

						Object.delete(branch.columns, type)

						branch.order.remove(type)
					}
					else if !column.isNode {
						if var column2 ?= Object.values(branch.columns).find((c, _, _) => c != column && !c.isNode && c.index > 0 && isSameFunction(column, c)) {
							branch.max += column.max
							branch.variadic = true

							column2.min = Math.max(0, column2.min - column.min)
							column2.variadic = true

							Object.delete(branch.columns, type)

							branch.order.remove(type)
						}
					}
				}
			} # }}}

			func regroupBranch_SiblingsEqChildren(branch: TreeBranch): Void { # {{{
				for var type, index in branch.order from branch.order.length - 2 step -1 {
					var column = branch.columns[type]

					if getForkHash(branch, index + 1) == getForkHash(column, 0) && isSameParameter2(column, branch.columns[branch.order[index + 1]]) {
						column.min = 0
						column.variadic = true

						for var col, colType of column.columns {
							col.max = branch.columns[colType].max

							Object.delete(branch.columns, colType)

							branch.order.remove(colType)
						}
					}
				}
			} # }}}

			func regroupBranch_TopForkEqLastChild(branch: TreeBranch | Tree): Void { # {{{
				return unless branch.order.length == 2

				var first = branch.columns[branch.order[0]]
				var last = branch.columns[branch.order[1]]

				return unless Array.same(getFunctions(first), getFunctions(last))

				var late type
				var late node

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

				Object.delete(branch.columns, type)

				branch.rest = node.rest
				branch.variadic = node.variadic
				branch.max += node.max

				var min = buildMin(node)

				applyMin(branch, min)
			} # }}}

			func regroupLeaf_SiblingsEq(branch: TreeBranch | Tree, node: AbstractNode): Void { # {{{
				var groups = {}

				for var type, index in branch.order from branch.order.length - 2 step -1 {
					var column = branch.columns[type]

					if column.isNode {
						continue
					}

					var type2 = branch.order[index + 1]
					var column2 = branch.columns[type2]

					if column2.isNode {
						continue
					}

					if Array.same(Object.keys(column.parameters), Object.keys(column2.parameters)) {
						if ?groups[index + 1] {
							groups[index] = groups[index + 1]

							Object.delete(groups, index + 1)

							groups[index].unshift(type)
						}
						else {
							groups[index] = [type, type2]
						}
					}
				}

				if groups.length != 0 {
					var scope = node.scope()

					for var group of groups {
						var column = branch.columns[group[0]]

						var type = Type.union(scope, ...[branch.columns[key].type for var key in group]).sort()

						for var key in group {
							Object.delete(branch.columns, key)
						}

						column.type = type

						branch.columns[type.hashCode()] = column
					}

					sortNodes(branch)
				}
			} # }}}
		}

		func applyMin(tree: TreeBranch | TreeLeaf, data: Array): Void { # {{{
			var setter = (node, value? = null) => {
				if value != null {
					node.min = value
				}
				else {
					node.min = 0
				}
			}

			applyMinMax(tree, setter, data, [], [])
		} # }}}

		func applyMin2(tree: TreeBranch, mins, type): Void { # {{{
			for var key in tree.order when key != type {
				var node = tree.columns[key]

				if var m ?= mins[key] {
					applyMin(node, m:!!!(Array))
				}
				else {
					node.min = 0
					node.variadic = true

					if node.isNode {
						applyMin2(node:!!!(TreeBranch), mins, type)
					}
				}
			}
		} # }}}

		func applyMinMax(tree: TreeBranch, setter: Function, data: Array, nodes: TreeBranch[], ancestors: Array): Void { # {{{
			nodes.push(tree)

			applyMinMax(tree.columns[tree.order[0]], setter, data, nodes, ancestors)

			ancestors.pop()

			for var key in tree.order from 1 {
				applyMinMax(tree.columns[key], setter, data, [], ancestors)
			}
		} # }}}
		func applyMinMax(tree: TreeLeaf, setter: Function, data: Array, nodes: TreeBranch[], ancestors: Array): Void { # {{{
			var values = data.shift()
			var row = tree.rows[0]
			var function = row.function.index()

			nodes.push(tree)

			for var node in nodes {
				var parameters = [parameter for var parameter of node.parameters when parameter.function == row.function]
				var type = row.types.find(({parameter}, _, _) => parameter == parameters[0].parameter)

				if !?type {
					continue
				}

				ancestors.push(`\(function).\(type.parameter)`)

				if var m ?= values?[type.parameter] {
					if var value ?= m.shift() {
						if value is Array {
							var n = value.pop()
							if value.every((k, _, _) => ancestors.contains(k)) {
								setter(node, n)
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
		} # }}}

		func buildBranchFromRows(rows: Array, pIndex: Number, node: AbstractNode): TreeBranch | TreeLeaf { # {{{
			var scope = node.scope()
			var parameters = {}
			var keys = []

			for var row, i in rows {
				var params = {}

				for var type in row.types when type.index >= pIndex || type.index == -1 {
					if var param ?= params[type.parameter] {
						param.max += 1

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

				for var parameter, key of parameters {
					if var param ?= params[key] {
						if !param.type.isAssignableToVariable(parameter.type, true, false, false) {
							parameter.type = Type.union(scope, parameter.type, param.type).sort()
						}

						parameter.min = Math.min(parameter.min, param.min)
						parameter.max = Math.max(parameter.max, param.max)

						Object.delete(params, key)
					}
					else {
						parameter.min = 0
					}
				}

				for var parameter, key of params {
					parameters[key] = parameter

					if i != 0 {
						parameter.min = 0
					}

					keys.push(parseInt(key))
				}
			}

			var row = {...rows.last()!?}
			row.types = row.types.filter(({ index }, _, _) => pIndex > index >= 0)

			var lastParameter = keys.length - 1

			var mut branch = null
			var mut result = null
			var mut index = pIndex

			for var parameter, i in keys.sort((a, b) => a - b) {
				var { type, min, max, rest } = parameters[parameter]
				var hash = type.hashCode()
				var key = `:\(row.function.index()):\(parameter)`

				row.types.push(RowType.new(
					index
					type
					rest
					parameter
				))

				if i == lastParameter {
					var leaf = TreeLeaf.new(
						index
						type
						min
						max
						rest
						variadic: rest || min != max
						isNode: false
						parameters: {
							[key]: TreeParameter.new(
								key
								function: row.function
								parameter
								rows: [row.key]
							)
						}
						function: row.function
						arguments: []
						rows: [row]
						byNames: []
					)

					if result == null {
						result = leaf
					}
					else {
						branch.columns[hash] = leaf

						sortNodes(branch)
					}
				}
				else if i == 0 {
					branch = TreeBranch.new(
						index
						type
						min
						max
						rest
						variadic: true
						parameters: {
							[key]: TreeParameter.new(
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

					index += 1

					result = branch
				}
				else {
					branch.columns[hash] = TreeBranch.new(
						index
						type
						min
						max
						rest
						variadic: rest || min != max
						parameters: {
							[key]: TreeParameter.new(
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

					sortNodes(branch)

					branch = branch.columns[hash]
					index += 1
				}
			}

			return result!!
		} # }}}

		func buildMin(tree: TreeBranch | TreeLeaf): Array { # {{{
			var result = []

			buildMinMax(tree, 'min', result, [], [])

			return result
		} # }}}

		func buildMinMax(tree: TreeBranch, property: String, result: Array, nodes: TreeBranch[], ancestors: Array): Void { # {{{
			nodes.push(tree)

			buildMinMax(tree.columns[tree.order[0]], property, result, nodes, ancestors)

			ancestors.pop()

			for var key in tree.order from 1 {
				buildMinMax(tree.columns[key], property, result, [], ancestors)
			}
		} # }}}
		func buildMinMax(tree: TreeLeaf, property: String, result: Array, nodes: TreeBranch[], ancestors: Array): Void { # {{{
			var values = {}
			var row = tree.rows[0]
			var function = row.function.index()

			nodes.push(tree)

			var newAncestors = []

			for var node in nodes {
				var type = row.types.find(({index}, _, _) => index == node.index)

				if !?type {
					continue
				}

				if result.length == 0 || ancestors.length == 0 {
					if var m ?= values[type.parameter] {
						m.push(node[property])
					}
					else {
						values[type.parameter] = [node[property]]
					}
				}
				else {
					if var m ?= values[type.parameter] {
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
		} # }}}

		func getForkHash(tree: TreeBranch, index: Number): String { # {{{
			var hashes = []

			for var key in tree.order from index {
				getParameterHash(tree.columns[key], hashes, true)
			}

			return hashes.join(';')
		} # }}}
		func getForkHash(tree: TreeLeaf, index: Number): String { # {{{
			var hashes = getParameterHash(tree, [], true)

			return hashes.join(';')
		} # }}}

		func getFunction(tree: TreeBranch): FunctionType? { # {{{
			var function = getFunction(tree.columns[tree.order[0]])

			for var key in tree.order from 1 {
				if getFunction(tree.columns[key]) != function {
					return null
				}
			}

			return function
		} # }}}
		func getFunction(tree: TreeLeaf): FunctionType { # {{{
			return tree.function
		} # }}}

		func getFunctions(tree: TreeBranch | TreeLeaf): Array<Number> { # {{{
			return tree.rows.map((row, _, _) => row.function.index()).sort((a, b) => b - a)
		} # }}}

		func getParameterHash(tree: TreeLeaf, hashes: String[], all % _: Boolean): String[] { # {{{
			for var _, key of tree.parameters {
				hashes.pushUniq(`\(key):\(tree.type.hashCode())`)
			}

			return hashes
		} # }}}
		func getParameterHash(tree: TreeBranch, hashes: Array, all: Boolean): String[] { # {{{
			for var _, key of tree.parameters {
				hashes.pushUniq(`\(key):\(tree.type.hashCode())`)
			}

			if all {
				for var hash in tree.order {
					getParameterHash(tree.columns[hash], hashes, all)
				}
			}

			return hashes
		} # }}}

		func isRegroupeableBranch(tree1: TreeBranch, tree2: TreeBranch, type: String): Boolean { # {{{
			for var key in tree1.order when key != type {
				return false unless ?tree2.columns[key]
				return false unless isRegroupeableBranch(tree1.columns[key], tree2.columns[key])
			}

			return true
		} # }}}
		func isRegroupeableBranch(tree1: TreeBranch, tree2: TreeLeaf, type: String): Boolean { # {{{
			for var key in tree1.order when key != type {
				return false
			}

			return true
		} # }}}

		func isRegroupeableBranch(tree1: TreeBranch, tree2: TreeBranch): Boolean { # {{{
			for var key in tree2.order {
				return false if tree2.columns[key].type.isAssignableToVariable(tree2.type, false, false, false)
				return false unless ?tree1.columns[key]
				return false unless isRegroupeableBranch(tree1.columns[key], tree2.columns[key])
			}

			return true
		} # }}}
		func isRegroupeableBranch(tree1: TreeBranch | TreeLeaf, tree2: TreeLeaf): Boolean { # {{{
			var val1 = tree1.type.hashCode()
			var val2 = tree2.type.hashCode()

			return false unless val1 == val2

			return isRegroupeableBranch(tree1, tree2.function.index())
		} # }}}
		func isRegroupeableBranch(tree1: TreeLeaf, tree2: TreeBranch): Boolean { # {{{
			return false
		} # }}}

		func isRegroupeableBranch(tree: TreeBranch, function: Number): Boolean { # {{{
			for var key in tree.order {
				return false unless isRegroupeableBranch(tree.columns[key], function)
			}

			return true
		} # }}}
		func isRegroupeableBranch(tree: TreeLeaf, function: Number): Boolean { # {{{
			return tree.function.index() == function
		} # }}}

		func isSameFork(branch: TreeBranch, column: TreeColumn): Boolean { # {{{
			return branch.type == column.type && isSameParameter([branch, column], column)
		} # }}}

		func isSameFunction(...nodes: TreeColumn): Boolean { # {{{
			var function = nodes[0].rows[0].function

			for var node in nodes {
				if !node.rows.every((row, _, _) => row.function == function) {
					return false
				}
			}

			return true
		} # }}}

		func isSameParameter(arguments: TreeColumn[], tree: TreeBranch): Boolean { # {{{
			for var column of tree.columns {
				if !isSameParameter(arguments, column) {
					return false
				}
			}

			return true
		} # }}}
		func isSameParameter(arguments: TreeColumn[], tree: TreeLeaf): Boolean { # {{{
			var map = {}
			for var { index, parameter } in tree.rows[0].types {
				map[index] = parameter
			}

			var parameter = map[arguments[0].index]

			for var { index } in arguments {
				if map[index] != parameter {
					return false
				}
			}

			return true
		} # }}}

		func isSameParameter2(branch: TreeBranch | TreeLeaf, node: TreeBranch | TreeLeaf): Boolean { # {{{
			for var _, key of branch.parameters {
				if !?node.parameters[key] {
					return false
				}
			}

			return true
		} # }}}
	}

	func buildTree(group: Group, aliases: Type{}, name: String, ignoreIndistinguishable: Boolean, excludes: String[], node: AbstractNode): Tree { # {{{
		if group.n == 0 {
			return Zero.buildTree(group, name, node)
		}

		if group.n == 1 {
			One.expandGroup(group, name, ignoreIndistinguishable, excludes, node)
		}
		else {
			Legion.expandGroup(group, aliases, name, ignoreIndistinguishable, excludes, node)
		}

		var perNames = {}

		for var row of group.rows when ?row.names {
			var names = Object.keys(row.names).sort()
			var key = names.map((rowName, _, _) => `;\(rowName);\(row.names[rowName].sort().join('|'))`).join(',')

			if var function ?= perNames[key] {
				SyntaxException.throwIndistinguishableFunctions(name, [function, row.function], node) unless function == row.function
			}
			else {
				perNames[key] = row.function
			}
		}

		if Flat.isFlattenable(group, excludes, node) {
			return Flat.buildTree(group.functions[0], group.rows, group.n, excludes, node)
		}
		else {
			var tree = Pyramid.createTree(group.rows, group.n)

			if group.n > 1 {
				for var column, key of tree.columns when column.isNode {
					tree.columns[key] = Pyramid.buildNode(tree, column!!, 1, group.n, name, node)
				}
			}

			sortNodes(tree)

			if group.n == 1 {
				Regroup.regroupLeaf_SiblingsEq(tree, node)
			}

			Regroup.regroupBranch_Children_ForkAlike_SiblingsEq(tree, node)

			return tree
		}
	} # }}}

	func replaceAliases({ columns: TreeColumn{}, order: String[] }, aliases: Type{}): Void { # {{{
		for var name, index in order {
			if var alias ?= aliases[name] {
				var newName = alias.hashCode()

				order[index] = newName
				columns[newName] = columns[name]
				columns[newName].type = alias

				Object.delete(columns, name)
			}

			for var column of columns when column.isNode {
				replaceAliases(column, aliases)
			}
		}
	} # }}}

	func sortNodes(tree: { columns: TreeColumn{}, equivalences: String[][]?, order: String[] }): Void { # {{{
		var items = []

		for var node, key of tree.columns {
			items.push({
				key
				node
				type: node.type
				usage: if node.isNode set node:!!!(TreeBranch).rows.length else 1
				children: []
				isAny: node.type.isAny() || node.type.isNull()
				variadic: node.index < 0 || node.variadic
				alternative: node.rows.every(({ alternative }, _, _) => alternative)
			})
		}

		if #items == 1 {
			tree.order = [items[0].key]

			return
		}

		for var node in items {
			if node.alternative {
				for var item in items when item != node {
					if !item.alternative || item.type.isAssignableToVariable(node.type, true, true, false) {
						node.children.push(item)
					}
				}
			}
			else if node.isAny {
				for var item in items when item != node {
					if !item.isAny {
						node.children.push(item)
					}
				}
			}
			else {
				for var item in items when item != node {
					if !item.isAny && item.type.isAssignableToVariable(node.type, true, true, false) {
						node.children.push(item)
					}
				}
			}
		}

		var equivalences = []

		// echo([item.key for var item in items])
		items.sort((a, b) => {
			if a.children:!!!(Array).contains(b) {
				// echo(a.key, b.key, 1, 'b⊂a')
				return 1
			}
			if b.children:!!!(Array).contains(a) {
				// echo(a.key, b.key, -1, 'a⊂b')
				return -1
			}

			var d = b.usage - a.usage

			if d == 0 {
				// echo(a.key, b.key, a.type.compareToRef(b.type))
				return a.type.compareToRef(b.type)
			}
			else {
				// echo(a.key, b.key, d)
				return d
			}
		})
		// echo([item.key for var item in items])

		tree.order = [item.key for var item in items]

		if equivalences.length != 0 {
			tree.equivalences = equivalences
		}
	} # }}}
}
