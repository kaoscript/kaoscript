enum HelperTypeKind { // {{{
	Native
	Referenced
	Unreferenced
} // }}}

enum TypeStatus { // {{{
	Native
	Referenced
	Unreferenced
} // }}}

class ClassDeclaration extends Statement {
	private {
		_abstract: Boolean 			= false
		_abstractMethods			= {}
		_class: ClassType
		_classMethods				= {}
		_classVariables				= {}
		_constructors				= []
		_constructorScope
		_destructor					= null
		_destructorScope
		_es5: Boolean				= false
		_extending: Boolean			= false
		_extendingAlien: Boolean	= false
		_extendsName: String
		_extendsType: NamedType<ClassType>
		_hybrid: Boolean			= false
		_instanceMethods			= {}
		_instanceVariables			= {}
		_instanceVariableScope
		_macros						= {}
		_name
		_references					= {}
		_sealed: Boolean 			= false
		_type: NamedType<ClassType>
		_variable: Variable
	}
	static callMethod(node, variable, fnName, argName, retCode, fragments, method, index) { // {{{
		if method.max() == 0 && !method.isAsync() {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this)')
		}
		else {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this, ', argName, ')')
		}
	} // }}}
	static checkInfinityMethods(methods, parameters, index, node, fragments, call, argName) { // {{{
		if !?parameters[index + 1] {
			SyntaxException.throwNotDifferentiableMethods(node)
		}

		const tree = []
		const usages = []

		let type, nf, item, usage
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
			return ClassDeclaration.checkInfinityMethods(methods, parameters, index + 1, node, fragments, call, argName)
		}
		else if tree.length == 1 {
			item = tree[0]

			if item.methods.length == 1 {
				call(fragments, item.methods[0], item.methods[0].index())

				return false
			}
			else {
				return ClassDeclaration.checkInfinityMethods(methods, parameters, index + 1, node, fragments, call)
			}
		}
		else {
			for usage in usages {
				let count = usage.types.length

				for type in usage.types while count >= 0 {
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

			let ctrl = fragments.newControl()

			for item, i in tree {
				ctrl.step().code('else ') if !ctrl.isFirstStep()

				ctrl.code('if(')

				item.type[0].toTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(index)]`))

				ctrl.code(')')

				ctrl.step()

				if item.methods.length == 1 {
					if !call(ctrl, item.methods[0], item.methods[0].index()) {
						ctrl.line('return')
					}
				}
				else {
					ClassDeclaration.checkInfinityMethods(methods, parameters, index + 1, node, ctrl, call, argName)
				}
			}

			ctrl.done()
		}
	} // }}}
	static checkMethods(methods, parameters, index, node, fragments, call, argName) { // {{{
		if !?parameters[index + 1] {
			SyntaxException.throwNotDifferentiableMethods(node)
		}

		const tree = []
		const usages = []

		let type, nf, item, usage
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
			return ClassDeclaration.checkMethods(methods, parameters, index + 1, node, fragments, call, argName)
		}
		else if tree.length == 1 {
			item = tree[0]

			if item.methods.length == 1 {
				call(fragments, item.methods[0], item.methods[0].index())

				return false
			}
			else {
				return ClassDeclaration.checkMethods(methods, parameters, index + 1, node, fragments, call, argName)
			}
		}
		else {
			for usage in usages {
				let count = usage.types.length

				for type in usage.types while count >= 0 {
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

			let ctrl = fragments.newControl()
			let ne = true

			for item, i in tree {
				if i + 1 == tree.length {
					if !ctrl.isFirstStep() {
						ctrl.step().code('else')

						ne = false
					}
				}
				else {
					ctrl.step().code('else ') if !ctrl.isFirstStep()

					ctrl.code('if(')

					item.type[0].toTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(index)]`))

					ctrl.code(')')
				}

				ctrl.step()

				if item.methods.length == 1 {
					call(ctrl, item.methods[0], item.methods[0].index())
				}
				else {
					ClassDeclaration.checkMethods(methods, parameters, index + 1, node, ctrl, call, argName)
				}
			}

			ctrl.done()

			return ne
		}
	} // }}}
	static isAssigningAlias(data, name, constructor, extending) { // {{{
		if data is Array {
			for d in data {
				if ClassDeclaration.isAssigningAlias(d, name, constructor, extending) {
					return true
				}
			}
		}
		else {
			switch data.kind {
				NodeKind::BinaryExpression => {
					if data.operator.kind == BinaryOperatorKind::Assignment {
						if data.left.kind == NodeKind::ThisExpression && data.left.name.name == name {
							return true
						}
						else if data.left.kind == NodeKind::MemberExpression && data.left.object.kind == NodeKind::Identifier && data.left.object.name == 'this' && data.left.property.kind == NodeKind::Identifier && (data.left.property.name == name || data.left.property.name == `_\(name)`) {
							return true
						}
					}
				}
				NodeKind::CallExpression => {
					if constructor && data.callee.kind == NodeKind::Identifier {
						if data.callee.name == 'this' || (extending && data.callee.name == 'super') {
							for arg in data.arguments {
								if arg.kind == NodeKind::Identifier && arg.name == name {
									return true
								}
							}
						}
					}
				}
				NodeKind::ReturnStatement => {
					return ClassDeclaration.isAssigningAlias(data.value, name, constructor, extending)
				}
			}
		}

		return false
	} // }}}
	static mapMethod(method, target, map) { // {{{
		let index = 1
		let count = method.min()
		let item

		for parameter, p in method.parameters() {
			for i from 1 to parameter.min() {
				if item !?= map[index] {
					item = map[index] = {
						index: index
						types: {}
						weight: 0
					}
				}

				ClassDeclaration.mapParameter(parameter.type(), method.index(), item)

				++index
			}

			for i from parameter.min() + 1 to parameter.max() while count < target {
				if item !?= map[index] {
					item = map[index] = {
						index: index
						types: {}
						weight: 0
					}
				}

				ClassDeclaration.mapParameter(parameter.type(), method.index(), item)

				++index
				++count
			}
		}
	} // }}}
	static mapParameter(type, index, map) { // {{{
		if type is UnionType {
			for value in type.types() {
				ClassDeclaration.mapParameter(value, index, map)
			}
		}
		else {
			if map.types[type.hashCode()] is Object {
				map.types[type.hashCode()].methods.push(index)
			}
			else {
				map.types[type.hashCode()] = {
					type: type
					methods: [index]
				}

				if type.isAny() {
					map.weight += 1
				}
				else {
					map.weight += 1_000
				}
			}
		}
	} // }}}
	static toInfinitySwitchFragments(node, fragments, methods, async, call, wrongdoer, argName) { // {{{
		const begins = []
		const ends = []
		const others = []
		for method in methods {
			const parameters = method.parameters()

			if parameters[0].min() > 0 && parameters[0].max() < Infinity {
				begins.push(method)
			}
			else if parameters[parameters.length - 1].min() > 0 && parameters[parameters.length - 1].max() < Infinity {
				ends.push(method)
			}
			else {
				others.push(method)
			}
		}

		if others.length > 1 {
			SyntaxException.throwNotDifferentiableFunction(node)
		}

		if begins.length != 0 && ends.length != 0 {
			SyntaxException.throwNotDifferentiableFunction(node)
		}

		let groups = {}
		let min = Infinity
		let max = 0

		if begins.length != 0 {
			for const index from 0 til methods.length {
				method = methods[index]

				let nf = true
				let methodMin = 0
				let methodMax = 0
				for const parameter in method.parameters() while nf {
					if parameter.min() == 0 || parameter.max() == Infinity {
						if methodMin == 0 {
							methodMin = Infinity
						}

						nf = false
					}
					else {
						methodMin += parameter.min()
						methodMax += parameter.max()
					}
				}

				for n from methodMin to methodMax {
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
		}
		else {
			throw new NotImplementedException(node)
		}

		for i from min to max {
			if group ?= groups[i] {
				for j from i + 1 to max while (gg ?= groups[j]) && Array.same(gg.methods, group.methods) {
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

		let ctrl = fragments.newControl()

		if begins.length != 0 {
			for const group, k of groups {
				ctrl.step().code('else ') unless ctrl.isFirstStep()

				ctrl.code(`if(\(argName).length >= \(group.n))`).step()

				const parameters = {}
				for method in group.methods {
					ClassDeclaration.mapMethod(method, group.n, parameters)
				}

				let indexes = []
				for parameter in [value for const value of parameters].sort((a, b) => b.weight - a.weight) {
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

				ClassDeclaration.checkInfinityMethods(methods, parameters, 0, node, ctrl, call, argName)
			}
		}
		else {
			throw new NotImplementedException(node)
		}

		if others.length == 0 {
			wrongdoer(fragments, ctrl, async, true)
		}
		else {
			ctrl.done()

			call(fragments, others[0], others[0].index())
		}
	} // }}}
	static toSwitchFragments(node, fragments, variable, methods, name: String, extend?, header, footer, call, wrongdoer, argName, returns) { // {{{
		let block = header(node, fragments)

		let method
		if methods.length == 0 {
			if extend? {
				extend(node, block, null, variable)
			}
			else {
				block
					.newControl()
					.code(`if(\(argName).length !== 0)`)
					.step()
					.line('throw new SyntaxError("wrong number of arguments")')
					.done()
			}
		}
		else if methods.length == 1 {
			method = methods[0]

			const async = method.isAsync()
			const min = method.absoluteMin()
			const max = method.absoluteMax()

			if min == 0 && max >= Infinity {
				call(block, method, 0)
			}
			else if min == max {
				const ctrl = block.newControl()

				ctrl.code(`if(\(argName).length === \(min))`).step()

				call(ctrl, method, 0)

				if extend {
					extend(node, block, ctrl, variable)
				}
				else {
					wrongdoer(block, ctrl, async, returns)
				}
			}
			else if max < Infinity {
				let ctrl = block.newControl()

				ctrl.code(`if(\(argName).length >= \(min) && \(argName).length <= \(max))`).step()

				call(ctrl, method, 0)

				wrongdoer(block, ctrl, async, returns)
			}
			else {
				call(block, method, 0)
			}
		}
		else {
			const async = methods[0].isAsync()

			let groups = {}
			let infinities = []
			let min = Infinity
			let max = 0
			let asyncCount = 0
			let syncCount = 0

			for index from 0 til methods.length {
				method = methods[index]
				method.index(index)

				if method.isAsync() {
					++asyncCount
				}
				else {
					++syncCount
				}

				if method.absoluteMax() == Infinity {
					infinities.push(method)
				}
				else {
					for n from method.absoluteMin() to method.absoluteMax() {
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

			if asyncCount != 0 && syncCount != 0 {
				SyntaxException.throwInvalidSyncMethods(node.name(), name, node)
			}

			for method in infinities {
				for const :group of groups when method.absoluteMin() >= group.n {
					group.methods.push(method)
				}
			}

			if min == Infinity {
				ClassDeclaration.toInfinitySwitchFragments(node, block, infinities, async, call, wrongdoer, argName)
			}
			else {
				for i from min to max {
					if group ?= groups[i] {
						for j from i + 1 to max while (gg ?= groups[j]) && Array.same(gg.methods, group.methods) {
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

				let ctrl = block.newControl()

				for const group, k of groups {
					ctrl.step().code('else ') unless ctrl.isFirstStep()

					if group.n is Array {
						if group.n.length == 2 {
							ctrl.code(`if(\(argName).length === \(group.n[0]) || \(argName).length === \(group.n[1]))`).step()
						}
						else {
							ctrl.code(`if(\(argName).length >= \(group.n[0]) && \(argName).length <= \(group.n[group.n.length - 1]))`).step()
						}
					}
					else {
						ctrl.code(`if(\(argName).length === \(group.n))`).step()
					}

					if group.methods.length == 1 {
						call(ctrl, group.methods[0], group.methods[0].index())
					}
					else {
						const parameters = {}
						for method in group.methods {
							ClassDeclaration.mapMethod(method, group.n, parameters)
						}

						let indexes = []
						for parameter in [value for const value of parameters].sort((a, b) => b.weight - a.weight) {
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

						if ClassDeclaration.checkMethods(methods, parameters, 0, node, ctrl, call, argName) {
							if returns {
								fragments.line('throw new Error("Wrong type of arguments")')
							}
							else {
								fragments.step().code('else').step().code('throw new Error("Wrong type of arguments")')
							}
						}
					}
				}

				if infinities.length == 0 {
					wrongdoer(block, ctrl, async, returns)
				}
				else if infinities.length == 1 {
					ctrl.step().code('else').step()

					call(ctrl, infinities[0], infinities[0].index())

					ctrl.done()
				}
				else {
					throw new NotImplementedException(node)
				}
			}
		}

		footer(block)

		return fragments
	} // }}}
	static toWrongDoingFragments(block, ctrl, async, returns) { // {{{
		if async {
			ctrl.step().code('else').step()

			ctrl.line(`let __ks_cb, __ks_error = new SyntaxError("wrong number of arguments")`)

			ctrl
				.newControl()
				.code(`if(arguments.length > 0 && Type.isFunction((__ks_cb = arguments[arguments.length - 1])))`)
				.step()
				.line(`return __ks_cb(__ks_error)`)
				.step()
				.code(`else`)
				.step()
				.line(`throw __ks_error`)
				.done()

			ctrl.done()
		}
		else if returns {
			ctrl.done()

			block.line('throw new SyntaxError("wrong number of arguments")')
		}
		else {
			ctrl.step().code('else').step().line('throw new SyntaxError("wrong number of arguments")').done()
		}
	} // }}}
	constructor(data, parent, scope) { // {{{
		super(data, parent, scope)

		@constructorScope = this.newScope(@scope, ScopeType::Block)
		@destructorScope = this.newScope(@scope, ScopeType::Block)
		@instanceVariableScope = this.newScope(@scope, ScopeType::Block)
		@es5 = @options.format.classes == 'es5'
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@class = new ClassType(@scope)
		@type = new NamedType(@name, @class)

		@variable = @scope.define(@name, true, @type, this)

		let thisVariable = @constructorScope.define('this', true, @scope.reference(@name), this)

		thisVariable.replaceCall = (data, arguments) => new CallThisConstructorSubstitude(data, arguments, @type)

		@destructorScope.define('this', true, @scope.reference(@name), this)
		@destructorScope.rename('this', 'that')

		@instanceVariableScope.define('this', true, @scope.reference(@name), this)

		if @data.extends? {
			@extending = true

			let name = ''
			let member = @data.extends
			while member.kind == NodeKind::MemberExpression {
				name = `.\(member.property.name)` + name

				member = member.object
			}

			@extendsName = `\(member.name)` + name
		}

		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@abstract = true

				@class.flagAbstract()
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true

				@class.flagSealed()
			}
		}

		let declaration
		for data in @data.members {
			switch data.kind {
				NodeKind::CommentBlock => {
				}
				NodeKind::CommentLine => {
				}
				NodeKind::FieldDeclaration => {
					declaration = new ClassVariableDeclaration(data, this)

					declaration.analyse()
				}
				NodeKind::MacroDeclaration => {
					const name = data.name.name

					declaration = new MacroDeclaration(data, this, null)

					if @macros[name] is Array {
						@macros[name].push(declaration)
					}
					else {
						@macros[name] = [declaration]
					}
				}
				NodeKind::MethodDeclaration => {
					if @class.isConstructor(data.name.name) {
						declaration = new ClassConstructorDeclaration(data, this)
					}
					else if @class.isDestructor(data.name.name) {
						declaration = new ClassDestructorDeclaration(data, this)
					}
					else {
						declaration = new ClassMethodDeclaration(data, this)
					}

					declaration.analyse()
				}
				=> {
					throw new NotSupportedException(`Unknow kind \(data.kind)`, this)
				}
			}
		}

		if this.hasInits() {
			@class.init(1)
		}
	} // }}}
	prepare() { // {{{
		if @extending {
			if @extendsType !?= Type.fromAST(@data.extends, this) {
				ReferenceException.throwNotDefined(@extendsName, this)
			}
			else if @extendsType.discardName() is not ClassType {
				TypeException.throwNotClass(@extendsName, this)
			}

			@class.extends(@extendsType)

			@hybrid = @class.isHybrid()

			const superVariable = @constructorScope.define('super', true, @scope.reference(@extendsName), this)

			if @hybrid && !@es5 {
				const thisVariable = @constructorScope.getVariable('this')

				thisVariable.replaceCall = (data, arguments) => new CallHybridThisConstructorES6Substitude(data, arguments, @type)

				superVariable.replaceCall = (data, arguments) => new CallHybridSuperConstructorES6Substitude(data, arguments, @type)
			}
			else {
				if @es5 {
					superVariable.replaceCall = (data, arguments) => new CallSuperConstructorES5Substitude(data, arguments, @type)
				}
				else {
					superVariable.replaceCall = (data, arguments) => new CallSuperConstructorSubstitude(data, arguments, @type)
				}
			}

			@instanceVariableScope.define('super', true, @scope.reference(@extendsName), this)
		}

		for const variable, name of @classVariables {
			variable.prepare()

			@class.addClassVariable(name, variable.type())
		}

		for const methods, name of @classMethods {
			for method in methods {
				method.prepare()

				@class.addClassMethod(name, method.type())
			}
		}

		for const variable, name of @instanceVariables {
			variable.prepare()

			@class.addInstanceVariable(name, variable.type())
		}

		for const methods, name of @instanceMethods {
			for method in methods {
				method.prepare()

				@class.addInstanceMethod(name, method.type())
			}
		}

		for const methods, name of @abstractMethods {
			for method in methods {
				method.prepare()

				@class.addAbstractMethod(name, method.type())
			}
		}

		for method in @constructors {
			method.prepare()

			@class.addConstructor(method.type())
		}

		if @destructor? {
			@destructor.prepare()

			@class.addDestructor()
		}

		if @extending && !@abstract && (notImplemented = @class.getMissingAbstractMethods()).length != 0 {
			SyntaxException.throwMissingAbstractMethods(@name, notImplemented, this)
		}

		for const macros of @macros {
			for macro in macros {
				macro.export(this)
			}
		}
	} // }}}
	translate() { // {{{
		for const variable of @classVariables {
			variable.translate()
		}

		for const variable of @instanceVariables {
			variable.translate()
		}

		for method in @constructors {
			method.translate()
		}

		@destructor.translate() if @destructor?

		for const methods of @instanceMethods {
			for method in methods {
				method.translate()
			}
		}

		for const methods of @abstractMethods {
			for method in methods {
				method.translate()
			}
		}

		for const methods of @classMethods {
			for method in methods {
				method.translate()
			}
		}
	} // }}}
	addReference(type, node) { // {{{
		if !type.isAny() {
			if type is ReferenceType {
				const name = type.name()

				if !?@references[name] {
					if $typeofs[name] == true {
						@references[name] = {
							status: TypeStatus::Native
							type: type
						}
					}
					else if variable ?= @scope.getVariable(name) {
						@references[name] = {
							status: TypeStatus::Referenced
							type: type
							variable: variable
						}
					}
					else {
						@references[name] = {
							status: TypeStatus::Unreferenced
							type: type
						}
					}
				}
			}
			else if type is UnionType {
				for let type in type.types() {
					this.addReference(type, node)
				}
			}
			else if type is ClassVariableType {
				this.addReference(type.type(), node)
			}
			else {
				throw new NotImplementedException(this)
			}
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	exportMacro(name, macro) { // {{{
		@parent.exportMacro(`\(@name).\(name)`, macro)
	} // }}}
	extends() => @extendsType
	hasConstructors() => @constructors.length != 0
	hasInits() { // {{{
		for const field of @instanceVariables {
			if field.hasDefaultValue() {
				return true
			}
		}

		return false
	} // }}}
	isExtending() => @extending
	isHybrid() => @hybrid
	name() => @name
	newInstanceMethodScope(method: ClassMethodDeclaration) { // {{{
		const scope = this.newScope(@scope, ScopeType::Block)

		scope.define('this', true, @scope.reference(@name), this)

		if @extending {
			scope.define('super', true, null, this)
		}

		return scope
	} // }}}
	registerMacro(name, macro) { // {{{
		@scope.addMacro(name, macro)

		@parent.registerMacro(`\(@name).\(name)`, macro)
	} // }}}
	toContinousES5Fragments(fragments) { // {{{
		this.module().flag('Helper')

		const line = fragments.newLine().code($runtime.scope(this), @name, ' = ', $runtime.helper(this), '.class(')
		const clazz = line.newObject()

		clazz.line('$name: ' + $quote(@name))

		if @data.version? {
			clazz.line(`$version: [\(@data.version.major), \(@data.version.minor), \(@data.version.patch)]`)
		}

		if @extending {
			clazz.line('$extends: ', @extendsName)
		}

		const m = []

		let ctrl
		if @destructor? || !Object.isEmpty(@classMethods) {
			ctrl = clazz.newLine().code('$static: ').newObject()

			if @destructor? {
				@destructor.toFragments(ctrl, Mode::None)

				ClassDestructorDeclaration.toSwitchFragments(this, ctrl, @type)
			}

			for const methods, name of @classMethods {
				m.clear()

				for method in methods {
					method.toFragments(ctrl, Mode::None)

					m.push(method.type())
				}

				ClassMethodDeclaration.toClassSwitchFragments(this, ctrl.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
			}

			ctrl.done()
		}

		if !@extending || @extendsType.isSealedAlien() {
			clazz
				.newControl()
				.code('$create: function()')
				.step()
				.line('this.__ks_init()')
				.line('this.__ks_cons(arguments)')
		}

		if this.hasInits() {
			ctrl = clazz
				.newControl()
				.code('__ks_init_1: function()')
				.step()

			for const field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl = clazz.newControl().code('__ks_init: function()').step()

			if @extending && !@extendsType.isSealedAlien() {
				ctrl.line(@extendsName + '.prototype.__ks_init.call(this)')
			}

			ctrl.line(@name + '.prototype.__ks_init_1.call(this)')
		}
		else {
			if @extending {
				if @extendsType.isSealedAlien() {
					clazz
						.newControl()
						.code('__ks_init: function()')
						.step()
				}
				else {
					clazz
						.newControl()
						.code('__ks_init: function()')
						.step()
						.line(@extendsName + '.prototype.__ks_init.call(this)')
				}
			}
			else {
				clazz.newControl().code('__ks_init: function()').step()
			}
		}

		m.clear()

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toSwitchFragments(this, clazz.newControl(), @type, m, func(node, fragments) => fragments.code('__ks_cons: function(args)').step(), func(fragments) {})

		for const methods, name of @instanceMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
		}

		clazz.done()
		line.code(')').done()
	} // }}}
	toContinousES6Fragments(fragments) { // {{{
		const clazz = fragments
			.newControl()
			.code('class ', @name)

		if @extending {
			clazz.code(' extends ', @extendsName)
		}

		clazz.step()

		let ctrl
		if !@extending {
			clazz
				.newControl()
				.code('constructor()')
				.step()
				.line('this.__ks_init()')
				.line('this.__ks_cons(arguments)')
				.done()
		}

		if this.hasInits() {
			ctrl = clazz
				.newControl()
				.code('__ks_init_1()')
				.step()

			for const field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl.done()

			ctrl = clazz.newControl().code('__ks_init()').step()

			if @extending && !@extendsType.isSealedAlien() {
				ctrl.line(@extendsName + '.prototype.__ks_init.call(this)')
			}

			ctrl.line(@name + '.prototype.__ks_init_1.call(this)')

			ctrl.done()
		}
		else {
			if @extending {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.line(@extendsName + '.prototype.__ks_init.call(this)')
					.done()
			}
			else {
				clazz.newControl().code('__ks_init()').step().done()
			}
		}

		const m = []

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toSwitchFragments(this, clazz.newControl(), @type, m, func(node, fragments) => fragments.code('__ks_cons(args)').step(), func(fragments) {
			fragments.done()
		})

		if @destructor? {
			@destructor.toFragments(clazz, Mode::None)

			ClassDestructorDeclaration.toSwitchFragments(this, clazz, @type)
		}

		for const methods, name of @instanceMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		for const methods, name of @classMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toClassSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()
	} // }}}
	toHybridES6Fragments(fragments) { // {{{
		const clazz = fragments
			.newControl()
			.code('class ', @name, ' extends ', @extendsName)
			.step()

		const m = []

		let ctrl
		if @constructors.length == 0 {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()
				.line('super(...arguments)')

			if @extendsType.isSealedAlien() {
				ctrl.line('this.constructor.prototype.__ks_init()')
			}

			ctrl.done()
		}
		else if @constructors.length == 1 {
			@constructors[0].toHybridConstructorFragments(clazz)
		}
		else {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()

			for method in @constructors {
				method.toFragments(ctrl, Mode::None)

				m.push(method.type())
			}

			const line = ctrl
				.newLine()
				.code('const __ks_cons = (__ks_arguments) =>')

			ClassDeclaration.toSwitchFragments(
				this
				line.newBlock()
				@type
				m
				'constructor'
				func(node, fragments, ctrl, variable) {
				}
				func(node, fragments) => fragments
				func(fragments) {
					fragments.done()
				}
				(fragments, method, index) => {
					fragments.line(`__ks_cons_\(index)(__ks_arguments)`)
				}
				ClassDeclaration.toWrongDoingFragments
				'__ks_arguments'
				false
			)

			line.done()

			ctrl
				.line('__ks_cons(arguments)')
				.done()
		}

		if this.hasInits() {
			ctrl = clazz
				.newControl()
				.code('__ks_init_1()')
				.step()

			for const field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl.done()

			if @extendsType.isSealedAlien() {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.line(`\(@name).prototype.__ks_init_1.call(this)`)
					.done()
			}
			else {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.line(`\(@extendsName).prototype.__ks_init.call(this)`)
					.line(`\(@name).prototype.__ks_init_1.call(this)`)
					.done()
			}
		}
		else if @extendsType.isSealedAlien() {
			clazz.newControl().code('__ks_init()').step().done()
		}
		else {
			clazz
				.newControl()
				.code('__ks_init()')
				.step()
				.line(`\(@extendsName).prototype.__ks_init.call(this)`)
				.done()
		}

		if @destructor? {
			@destructor.toFragments(clazz, Mode::None)

			ClassDestructorDeclaration.toSwitchFragments(this, clazz, @type)
		}

		for const methods, name of @instanceMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		for const methods, name of @classMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toClassSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()
	} // }}}
	toSealedES5Fragments(fragments) { // {{{
		@module().flag('Helper')

		const line = fragments.newLine().code($runtime.scope(this), @name, ' = ', $runtime.helper(this), '.class(')
		const clazz = line.newObject()

		clazz.line('$name: ' + $quote(@name))

		if @data.version? {
			clazz.line(`$version: [\(@data.version.major), \(@data.version.minor), \(@data.version.patch)]`)
		}

		if @extending {
			clazz.line('$extends: ', @extendsName)
		}

		const m = []

		let ctrl
		if @destructor? || !Object.isEmpty(@classMethods) {
			ctrl = clazz.newLine().code('$static: ').newObject()

			if @destructor? {
				@destructor.toFragments(ctrl, Mode::None)

				ClassDestructorDeclaration.toSwitchFragments(this, ctrl, @type)
			}

			for const methods, name of @classMethods {
				m.clear()

				for method in methods {
					method.toFragments(ctrl, Mode::None)

					m.push(method.type())
				}

				ClassMethodDeclaration.toClassSwitchFragments(this, ctrl.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
			}

			ctrl.done()
		}

		if @extending && !@extendsType.isSealedAlien() {
			ctrl = clazz
				.newControl()
				.code('__ks_init: function()')
				.step()

			ctrl.line(@extendsName, '.prototype.__ks_init.call(this)')

			if this.hasInits() {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}
		}
		else {
			ctrl = clazz
				.newControl()
				.code('$create: function()')
				.step()

			if this.hasInits() {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}

			ctrl.line('this.__ks_cons(arguments)')
		}

		m.clear()

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toSwitchFragments(this, clazz.newControl(), @type, m, func(node, fragments) => fragments.code('__ks_cons: function(args)').step(), func(fragments) {})

		for const methods, name of @instanceMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
		}

		clazz.done()
		line.code(')').done()
	} // }}}
	toSealedES6Fragments(fragments) { // {{{
		const clazz = fragments
			.newControl()
			.code('class ', @name)

		if @extending {
			clazz.code(' extends ', @extendsName)
		}

		clazz.step()

		let ctrl
		if @extending && !@extendsType.isSealedAlien() {
			ctrl = clazz
				.newControl()
				.code('__ks_init()')
				.step()

			ctrl.line(@extendsName, '.prototype.__ks_init.call(this)')

			if this.hasInits() {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}

			ctrl.done()
		}
		else {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()

			if this.hasInits() {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}

			ctrl.line('this.__ks_cons(arguments)')

			ctrl.done()
		}

		const m = []

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toSwitchFragments(this, clazz.newControl(), @type, m, func(node, fragments) => fragments.code('__ks_cons(args)').step(), func(fragments) {
			fragments.done()
		})

		if @destructor? {
			@destructor.toFragments(clazz, Mode::None)

			ClassDestructorDeclaration.toSwitchFragments(this, clazz, @type)
		}

		for const methods, name of @instanceMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		for const methods, name of @classMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toClassSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @sealed {
			if @es5 {
				this.toSealedES5Fragments(fragments)
			}
			else {
				this.toSealedES6Fragments(fragments)
			}
		}
		else {
			if @es5 {
				this.toContinousES5Fragments(fragments)
			}
			else if @hybrid {
				this.toHybridES6Fragments(fragments)
			}
			else {
				this.toContinousES6Fragments(fragments)
			}
		}

		for const variable of @classVariables {
			variable.toFragments(fragments)
		}

		if !@es5 && @data.version? {
			let line = fragments.newLine()

			line
				.code(`Object.defineProperty(\(@name), 'version', `)
				.newObject()
				.line(`value: [\(@data.version.major), \(@data.version.minor), \(@data.version.patch)]`)
				.done()

			line.code(')').done()
		}

		if references ?= this.module().listReferences(@name) {
			for ref in references {
				fragments.line(ref)
			}
		}

		if @sealed {
			fragments.line(`var \(@type.getSealedName()) = {}`)
		}
	} // }}}
	type() => @type
	updateMethodScope(method) { // {{{
		if @extending {
			const variable = method.scope().getVariable('super').setDeclaredType(@scope.reference(@extendsName))

			if @es5 {
				variable.replaceCall = (data, arguments) => new CallSuperMethodES5Substitude(data, arguments, method, @type)

				variable.replaceMemberCall= (property, arguments) => new MemberSuperMethodES5Substitude(property, arguments, @type)
			}
			else {
				variable.replaceCall = (data, arguments) => new CallSuperMethodES6Substitude(data, arguments, method, @type)
			}
		}
	} // }}}
	walk(fn) { // {{{
		fn(@name, @type)
	} // }}}
}

class CallThisConstructorSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
	}
	constructor(@data, @arguments, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.path()).prototype.__ks_cons.call(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
	type() => Type.Void
}

class CallHybridThisConstructorES6Substitude extends CallThisConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		fragments.code(`__ks_cons([`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
}

class CallSuperConstructorSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
	}
	constructor(@data, @arguments, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons.call(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
	type() => Type.Void
}

class CallSuperConstructorES5Substitude extends CallSuperConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		if @class.type().extends().isAlien() {
			if @arguments.length == 0 {
				fragments.code('(1')
			}
			else {
				throw new NotSupportedException()
			}
		}
		else {
			fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons.call(this, [`)

			for argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}

			fragments.code(']')
		}
	} // }}}
}

class CallHybridSuperConstructorES6Substitude extends CallSuperConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		fragments.code(`super(`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}
	} // }}}
}

class CallSuperMethodES5Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_method: ClassMethodDeclaration
	}
	constructor(@data, @arguments, @method, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.type().extends().path()).prototype.\(@method.name()).call(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
	type() => @method.type().returnType()
}

class CallSuperMethodES6Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_method: ClassMethodDeclaration
	}
	constructor(@data, @arguments, @method, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`super.\(@method.name())(`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}
	} // }}}
	type() => @method.type().returnType()
}

class MemberSuperMethodES5Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_property: String
	}
	constructor(@property, @arguments, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.discardName().extends().name()).prototype.\(@property).apply(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
}

class ClassMethodDeclaration extends Statement {
	private {
		_abstract: Boolean		= false
		_aliases: Array			= []
		_analysed: Boolean		= false
		_awaiting: Boolean		= false
		_body: Array
		_exit: Boolean			= false
		_instance: Boolean		= true
		_internalName: String
		_name: String
		_parameters: Array
		_statements: Array
		_type: Type
	}
	static toClassSwitchFragments(node, fragments, variable, methods, name, header, footer) { // {{{
		let extend = null
		if variable.type().isExtending() {
			extend = func(node, fragments, ctrl?, variable) {
				const extends = variable.type().extends()
				const parent = extends.name()

				if extends.type().hasClassMethod(name) {
					ctrl.done()

					fragments.line(`return \(parent).\(name).apply(null, arguments)`)
				}
				else {
					ctrl
						.step()
						.code(`else if(\(parent).\(name))`)
						.step()
						.line(`return \(parent).\(name).apply(null, arguments)`)
						.done()

					fragments.line('throw new SyntaxError("wrong number of arguments")')
				}
			}
		}

		return ClassDeclaration.toSwitchFragments(node, fragments, variable, methods, name, extend, header, footer, ClassDeclaration.callMethod^^(node, variable, `__ks_sttc_\(name)_`, 'arguments', 'return '), ClassDeclaration.toWrongDoingFragments, 'arguments', true)
	} // }}}
	static toInstanceSwitchFragments(node, fragments, variable, methods, name, header, footer) { // {{{
		let extend = null
		if variable.type().isExtending() {
			extend = func(node, fragments, ctrl?, variable) {
				const extends = variable.type().extends()
				const parent = extends.name()

				if extends.type().hasInstanceMethod(name) {
					ctrl.done()

					fragments.line(`return \(parent).prototype.\(name).apply(this, arguments)`)
				}
				else {
					ctrl
						.step()
						.code(`else if(\(parent).prototype.\(name))`)
						.step()
						.line(`return \(parent).prototype.\(name).apply(this, arguments)`)
						.done()

					fragments.line('throw new SyntaxError("wrong number of arguments")')
				}
			}
		}

		return ClassDeclaration.toSwitchFragments(node, fragments, variable, methods, name, extend, header, footer, ClassDeclaration.callMethod^^(node, variable, `prototype.__ks_func_\(name)_`, 'arguments', 'return '), ClassDeclaration.toWrongDoingFragments, 'arguments', true)
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newInstanceMethodScope(this))

		@name = data.name.name

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@abstract = true
			}
			else if modifier.kind == ModifierKind::Static {
				@instance = false
			}
		}

		if @instance {
			if @abstract {
				if parent._abstract {
					if parent._abstractMethods[@name] is Array {
						parent._abstractMethods[@name].push(this)
					}
					else {
						parent._abstractMethods[@name] = [this]
					}
				}
				else {
					SyntaxException.throwNotAbstractClass(parent._name, @name, parent)
				}
			}
			else {
				if parent._instanceMethods[@name] is Array {
					@internalName = `__ks_func_\(@name)_\(parent._instanceMethods[@name].length)`

					parent._instanceMethods[@name].push(this)
				}
				else {
					@internalName = `__ks_func_\(@name)_0`

					parent._instanceMethods[@name] = [this]
				}
			}
		}
		else if @name == 'name' || @name == 'version' {
			SyntaxException.throwReservedClassMethod(@name, parent)
		}
		else {
			if parent._classMethods[@name] is Array {
				@internalName = `__ks_sttc_\(@name)_\(parent._classMethods[@name].length)`

				parent._classMethods[@name].push(this)
			}
			else {
				@internalName = `__ks_sttc_\(@name)_0`

				parent._classMethods[@name] = [this]
			}
		}

		for parameter in @data.parameters {
			@parent.addReference(Type.fromAST(parameter.type, @scope, false, this), this)
		}
	} // }}}
	analyse() { // {{{
		@body = $ast.body(@data.body)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		if !@analysed {
			@parent.updateMethodScope(this)

			for parameter in @parameters {
				parameter.prepare()
			}

			const arguments = [parameter.type() for parameter in @parameters]
			@type = new ClassMethodType(arguments, @data, this)

			if @parent.isExtending() {
				const extends = @parent.extends().type()
				if method ?= extends.getInstanceMethod(@name, arguments) ?? extends.getAsbtractMethod(@name, arguments) {
					if @data.type? {
						if !@type.returnType().isInstanceOf(method.returnType()) {
							SyntaxException.throwInvalidMethodReturn(@parent.name(), @name, this)
						}
					}
					else {
						@type.returnType(method.returnType())
					}
				}
			}

			@analysed = true
		}
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		@statements = []

		for statement in @aliases {
			@statements.push(statement)

			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}

		for statement in @body {
			@statements.push(statement = $compile.statement(statement, this))

			statement.analyse()
		}

		const rtype = @type.returnType()
		const na = !rtype.isAny()

		for statement in @statements {
			statement.prepare()

			if @exit {
				SyntaxException.throwDeadCode(statement)
			}
			else if na && !statement.isReturning(rtype) {
				TypeException.throwUnexpectedReturnedType(rtype, statement)
			}
			else {
				@exit = statement.isExit()
			}
		}

		for statement in @statements {
			statement.translate()
		}
	} // }}}
	addAliasStatement(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@body, statement.name(), false, false) {
			@aliases.push(statement)
		}
	} // }}}
	isAbstract() => @abstract
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstance() => @instance
	isInstanceMethod() => @instance
	length() => @parameters.length
	name() => @name
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()

		if @parent._es5 {
			ctrl.code(`\(@internalName): function(`)
		}
		else {
			ctrl.code('static ') if !@instance

			ctrl.code(`\(@internalName)(`)
		}

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
			return node.code(')').step()
		})

		if @awaiting {
			throw new NotImplementedException(this)
		}
		else {
			for statement in @statements {
				ctrl.compile(statement)
			}

			if !@exit && @type.isAsync() {
				ctrl.line('__ks_cb()')
			}
		}

		ctrl.done() unless @parent._es5
	} // }}}
	type() { // {{{
		if @analysed {
			return @type
		}
		else {
			this.prepare()

			return @type
		}
	} // }}}
}

class ClassConstructorDeclaration extends Statement {
	private {
		_aliases: Array				= []
		_body: Array
		_internalName: String
		_parameters
		_statements
		_type: Type
	}
	static toSwitchFragments(node, fragments, variable, methods, header, footer) { // {{{
		let extend = null
		if node.isExtending() {
			extend = func(node, fragments, ctrl?, variable) {
				if variable.type().hasConstructors() {
					ctrl
						.step()
						.code('else')
						.step()
						.line(`throw new SyntaxError("wrong number of arguments")`)
						.done()
				}
				else {
					const constructorName = variable.type().extends().isSealedAlien() ? 'constructor' : '__ks_cons'

					fragments.line(`\(variable.type().extends().path()).prototype.\(constructorName).call(this, args)`)
				}
			}
		}

		return ClassDeclaration.toSwitchFragments(node, fragments, variable, methods, 'constructor', extend, header, footer, ClassDeclaration.callMethod^^(node, variable, 'prototype.__ks_cons_', 'args', ''), ClassDeclaration.toWrongDoingFragments, 'args', false)
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope(parent._constructorScope, ScopeType::Block))

		@internalName = `__ks_cons_\(parent._constructors.length)`

		parent._constructors.push(this)

		for parameter in @data.parameters {
			@parent.addReference(Type.fromAST(parameter.type, @scope, false, this), this)
		}
	} // }}}
	analyse() { // {{{
		@body = $ast.body(@data.body)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}

		@type = new ClassConstructorType([parameter.type() for parameter in @parameters], @data, this)
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		let index = 1
		if @body.length == 0 {
			if @parent._extending {
				this.addCallToParentConstructor()

				index = 0
			}
		}
		else if (index = this.getConstructorIndex(@body)) == -1 && @parent._extending {
			SyntaxException.throwNoSuperCall(this)
		}

		@statements = []

		if @aliases.length == 0 {
			for statement in @body {
				@statements.push(statement = $compile.statement(statement, this))

				statement.analyse()
			}
		}
		else {
			for statement in @body to index {
				@statements.push(statement = $compile.statement(statement, this))

				statement.analyse()
			}

			for statement in @aliases {
				@statements.push(statement)

				statement.analyse()
			}

			for statement in @body from index + 1 {
				@statements.push(statement = $compile.statement(statement, this))

				statement.analyse()
			}
		}

		for statement in @statements {
			statement.prepare()
		}

		for statement in @statements {
			statement.translate()
		}
	} // }}}
	addAliasStatement(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@body, statement.name(), true, @parent._extending) {
			@aliases.push(statement)
		}
	} // }}}
	private addCallToParentConstructor() { // {{{
		// only add call if parent has an empty constructor
		const extendedType = @parent.extends().type()

		if extendedType.matchArguments([]) {
			if extendedType.hasConstructors() {
				@body.push({
					kind: NodeKind::CallExpression
					scope: {
						kind: ScopeKind::This
					}
					callee: {
						kind: NodeKind::Identifier
						name: 'super'
						start: @data.start
						end: @data.start
					}
					arguments: []
					nullable: false
					attributes: []
					start: @data.start
					end: @data.start
				})
			}
		}
		else {
			SyntaxException.throwNoSuperCall(this)
		}
	} // }}}
	private getConstructorIndex(body: Array) { // {{{
		for statement, index in body {
			if statement.kind == NodeKind::CallExpression {
				if statement.callee.kind == NodeKind::Identifier && (statement.callee.name == 'this' || statement.callee.name == 'super') {
					return index
				}
			}
			else if statement.kind == NodeKind::IfStatement {
				if statement.whenFalse? && this.getConstructorIndex(statement.whenTrue.statements) != -1 && this.getConstructorIndex(statement.whenFalse.statements) != -1 {
					return index
				}
			}
		}

		return -1
	} // }}}
	private getSuperIndex(body: Array) { // {{{
		for statement, index in body {
			if statement.kind == NodeKind::CallExpression {
				if statement.callee.kind == NodeKind::Identifier && statement.callee.name == 'super' {
					return index
				}
			}
			else if statement.kind == NodeKind::IfStatement {
				if statement.whenFalse? && this.getSuperIndex(statement.whenTrue.statements) != -1 && this.getSuperIndex(statement.whenFalse.statements) != -1 {
					return index
				}
			}
		}

		return -1
	} // }}}
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}

		return false
	} // }}}
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => true
	parameters() => @parameters
	toHybridConstructorFragments(fragments) { // {{{
		let ctrl = fragments
			.newControl()
			.code('constructor(')

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
			return node.code(')').step()
		})

		if @parent._extendsType.isSealedAlien() {
			const index = this.getSuperIndex(@body)

			if index == -1 {
				ctrl.line('super()')
				ctrl.line('this.constructor.prototype.__ks_init()')

				for statement in @statements {
					ctrl.compile(statement)
				}
			}
			else {
				for statement in @statements to index {
					ctrl.compile(statement)
				}

				ctrl.line('this.constructor.prototype.__ks_init()')

				for statement in @statements from index + 1 {
					ctrl.compile(statement)
				}
			}
		}
		else {
			for statement in @statements {
				ctrl.compile(statement)
			}
		}

		ctrl.done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if !@parent._es5 && @parent.isHybrid() {
			const ctrl = fragments
				.newLine()
				.code(`const \(@internalName) = (`)

			const block = Parameter.toFragments(this, ctrl, ParameterMode::HybridConstructor, func(node) {
				return node.code(') =>').newBlock()
			})

			const index = this.getSuperIndex(@body)

			if index == -1 {
				for statement in @statements {
					block.compile(statement)
				}
			}
			else {
				for statement in @statements to index {
					block.compile(statement)
				}

				block.line('this.__ks_init()')

				for statement in @statements from index + 1 {
					block.compile(statement)
				}
			}

			block.done()
			ctrl.done()
		}
		else {
			let ctrl = fragments.newControl()

			if @parent._es5 {
				ctrl.code(`\(@internalName): function(`)
			}
			else {
				ctrl.code(`\(@internalName)(`)
			}

			Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
				return node.code(')').step()
			})

			for statement in @statements {
				ctrl.compile(statement)
			}

			ctrl.done() unless @parent._es5
		}
	} // }}}
	type() => @type
}

class ClassDestructorDeclaration extends Statement {
	private {
		_internalName: String
		_parameters: Array
		_statements
		_type: Type
	}
	static toSwitchFragments(node, fragments, variable) { // {{{
		let ctrl = fragments.newControl()

		if node._es5 {
			ctrl.code('__ks_destroy: function(that)')
		}
		else {
			ctrl.code('static __ks_destroy(that)')
		}

		ctrl.step()

		if node._extending {
			ctrl.line(`\(node._extendsName).__ks_destroy(that)`)
		}

		for i from 0 til variable.type().destructors() {
			ctrl.line(`\(node._name).__ks_destroy_\(i)(that)`)
		}

		ctrl.done() unless node._es5
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope(parent._destructorScope, ScopeType::Block))

		@internalName = `__ks_destroy_0`

		parent._destructor = this
	} // }}}
	analyse() { // {{{
		const parameter = new Parameter({
			kind: NodeKind::Parameter
			modifiers: []
			name: $ast.identifier('that')
		}, this)

		parameter.analyse()

		@parameters = [parameter]
	} // }}}
	prepare() { // {{{
		@parameters[0].prepare()

		@type = new ClassDestructorType(@data, this)
	} // }}}
	translate() { // {{{
		@statements = []
		for statement in $ast.body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))

			statement.analyse()
		}

		for statement in @statements {
			statement.prepare()
		}

		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}

		return false
	} // }}}
	isInstance() => false
	isInstanceMethod() => true
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()

		if @parent._es5 {
			ctrl.code(`\(@internalName): function(`)
		}
		else {
			ctrl.code(`static \(@internalName)(`)
		}

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
			return node.code(')').step()
		})

		for statement in @statements {
			ctrl.compile(statement)
		}

		ctrl.done() unless @parent._es5
	} // }}}
	type() => @type
}

class ClassVariableDeclaration extends AbstractNode {
	private {
		_defaultValue				= null
		_hasDefaultValue: Boolean	= false
		_instance: Boolean			= true
		_name: String
		_type: ClassVariableType
	}
	constructor(data, parent) { // {{{
		super(data, parent)

		@name = data.name.name

		for i from 0 til data.modifiers.length while @instance {
			if data.modifiers[i].kind == ModifierKind::Static {
				@instance = false
			}
		}

		if @instance {
			parent._instanceVariables[@name] = this
		}
		else if @name == 'name' || @name == 'version' {
			SyntaxException.throwReservedClassVariable(@name, parent)
		}
		else {
			parent._classVariables[@name] = this
		}
	} // }}}
	analyse() { // {{{
		if @data.defaultValue? {
			@hasDefaultValue = true

			if !@instance {
				@defaultValue = $compile.expression(@data.defaultValue, this)
				@defaultValue.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		@parent.addReference(@type = ClassVariableType.fromAST(@data, this), this)

		if @parent.isExtending() {
			const type = @parent._extendsType.type()

			if @instance {
				if type.hasInstanceVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
			else {
				if type.hasClassVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
		}

		if @hasDefaultValue {
			if @instance {
				@defaultValue = $compile.expression(@data.defaultValue, this, @parent._instanceVariableScope)
				@defaultValue.analyse()
			}

			@defaultValue.prepare()
		}
	} // }}}
	translate() { // {{{
		if @hasDefaultValue {
			@defaultValue.translate()
		}
	} // }}}
	hasDefaultValue() => @hasDefaultValue
	isInstance() => @instance
	name() => @name
	toFragments(fragments) { // {{{
		if @hasDefaultValue {
			if @instance {
				fragments
					.newLine()
					.code(`this.\(@name) = `)
					.compile(@defaultValue)
					.done()
			}
			else {
				fragments
					.newLine()
					.code(`\(@parent.name()).\(@name) = `)
					.compile(@defaultValue)
					.done()
			}
		}
	} // }}}
	type() => @type
}