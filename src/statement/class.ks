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
		_abstract: Boolean 		= false
		_abstractMethods		= {}
		_classMethods			= {}
		_classVariables			= {}
		_constructors			= []
		_constructorScope
		_destructor				= null
		_destructorScope
		_es5: Boolean			= false
		_extends: Boolean		= false
		_extendsName: String
		_extendsType: ClassType
		_instanceMethods		= {}
		_instanceVariables		= {}
		_instanceVariableScope
		_name
		_references				= {}
		_sealed: Boolean 		= false
		_type: ClassType
	}
	static callMethod(node, variable, fnName, argName, retCode, fragments, method, index) { // {{{
		if method.max() == 0 {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this)')
		}
		else {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this, ', argName, ')')
		}
	} // }}}
	static checkMethods(methods, parameters, index, node, fragments, call, argName, returns) { // {{{
		if !?parameters[index + 1] {
			SyntaxException.throwNotDifferentiableMethods(node)
		}
		
		const tree = []
		const usages = []
		
		let type, nf, item, usage
		for :type of parameters[index + 1].types {
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
		
		if tree.length == 1 {
			item = tree[0]
			
			if item.methods.length == 1 {
				call(fragments, item.methods[0], item.methods[0].index())
				
				return false
			}
			else {
				return ClassDeclaration.checkMethods(methods, parameters, index + 1, node, fragments, call, argName, returns)
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
						item.type.push(...type.type)
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
			let ne = true
			
			for item, i in tree {
				if i + 1 == tree.length {
					if !ctrl.isFirstStep() {
						ctrl.step().code('else')
						
						ne = false
					}
				}
				else {
					ctrl.step().code('else') if !ctrl.isFirstStep()
					
					ctrl.code('if(')
					
					item.type[0].toTestFragments(ctrl, new Literal(false, node, node.scope(), `\(argName)[\(index)]`))
					
					ctrl.code(')')
				}
				
				ctrl.step()
				
				if item.methods.length == 1 {
					call(ctrl, item.methods[0], item.methods[0].index())
				}
				else {
					ClassDeclaration.checkMethods(methods, parameters, index + 1, node, ctrl, call, argName, returns)
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
			}
		}
	} // }}}
	static toSwitchFragments(node, fragments, variable, methods, extend?, header, footer, call, argName, returns) { // {{{
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
			
			if method.min() == 0 && method.max() >= Infinity {
				call(block, method, 0)
			}
			else if method.min() == method.max() {
				const ctrl = block.newControl()
				
				ctrl.code(`if(\(argName).length === \(method.min()))`).step()
				
				call(ctrl, method, 0)
				
				if returns {
					if extend {
						extend(node, block, ctrl, variable)
					}
					else {
						ctrl.done()
						
						block.line('throw new SyntaxError("wrong number of arguments")')
					}
				}
				else {
					if extend {
						extend(node, block, ctrl, variable)
					}
					else {
						ctrl.step().code('else').step().line('throw new SyntaxError("wrong number of arguments")').done()
					}
				}
			}
			else if method.max() < Infinity {
				let ctrl = block.newControl()
				
				ctrl.code(`if(\(argName).length >= \(method.min()) && \(argName).length <= \(method.max()))`).step()
				
				call(ctrl, method, 0)
				
				if returns {
					ctrl.done()
					
					block.line('throw new SyntaxError("wrong number of arguments")')
				}
				else {
					ctrl.step().code('else').step().line('throw new SyntaxError("wrong number of arguments")').done()
				}
			}
			else {
				call(block, method, 0)
			}
		}
		else {
			let groups = {}
			let infinities = []
			let min = Infinity
			let max = 0
			
			for index from 0 til methods.length {
				method = methods[index]
				method.index(index)
				
				if method.max() == Infinity {
					infinities.push(method)
				}
				else {
					for n from method.min() to method.max() {
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
					
					min = Math.min(min, method.min())
					max = Math.max(max, method.max())
				}
			}
			
			if infinities.length {
				for method in infinities {
					for group of groups when method.min() >= group.n {
						group.methods.push(method)
					}
				}
			}
			
			if min == Infinity {
				throw new NotImplementedException(node)
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
				
				for k, group of groups {
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
						for :parameter of parameters {
							for hash, type of parameter.types {
								type.methods:Array.remove(...indexes)
								
								if type.methods.length == 0 {
									delete parameter.types[hash]
								}
							}
							
							for :type of parameter.types {
								if type.methods.length == 1 {
									indexes:Array.pushUniq(type.methods[0])
								}
							}
						}
						
						if ClassDeclaration.checkMethods(methods, parameters, 0, node, ctrl, call, argName, returns) {
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
					if returns {
						ctrl.done()
						
						block.line('throw new SyntaxError("wrong number of arguments")')
					}
					else {
						ctrl.step().code('else').step().line('throw new SyntaxError("wrong number of arguments")').done()
					}
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
	constructor(data, parent) { // {{{
		super(data, parent)
		
		@constructorScope = new Scope(parent.scope())
		@destructorScope = new Scope(parent.scope())
		@instanceVariableScope = new Scope(parent.scope())
		@es5 = @options.format.classes == 'es5'
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@type = new ClassType(@name, @scope)
		
		@scope.define(@name, true, @type, this)
		
		let variable = @constructorScope.define('this', true, @type.reference(), this)
		
		variable.replaceCall = (data, arguments) => new CallThisConstructorSubstitude(data, arguments, @type)
		
		@destructorScope.define('this', true, @type.reference(), this)
		@destructorScope.rename('this', 'that')
		
		@instanceVariableScope.define('this', true, @type.reference(), this)
		
		if @data.extends? {
			@extends = true
			@extendsName = @data.extends.name
			
			if variable !?= @scope.getVariable(@extendsName) {
				ReferenceException.throwNotDefined(@extendsName, this)
			}
			else if (@extendsType = variable.type()) is not ClassType {
				TypeException.throwNotClass(@extendsName, this)
			}
			
			@type.extends(@extendsType)
			
			const superVariable = @constructorScope.define('super', true, @extendsType.reference(), this)
			
			if @extendsType.isSealedAlien() {
				superVariable.replaceCall = (data, arguments) => {
					SyntaxException.throwNotCompatibleConstructor(@name, this)
				}
			}
			else {
				superVariable.replaceCall = (data, arguments) => new CallSuperConstructorSubstitude(data, arguments, @type)
			}
			
			@instanceVariableScope.define('super', true, @extendsType.reference(), this)
		}
		
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@abstract = true
				
				@type.abstract()
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true
				
				@type.seal()
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
				NodeKind::MethodDeclaration => {
					if @type.isConstructor(data.name.name) {
						declaration = new ClassConstructorDeclaration(data, this)
					}
					else if @type.isDestructor(data.name.name) {
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
	} // }}}
	prepare() { // {{{
		for name, variable of @classVariables {
			variable.prepare()
			
			@type.addClassVariable(name, variable.type())
		}
		
		for name, methods of @classMethods {
			for method in methods {
				method.prepare()
				
				@type.addClassMethod(name, method.type())
			}
		}
		
		for name, variable of @instanceVariables {
			variable.prepare()
			
			@type.addInstanceVariable(name, variable.type())
		}
		
		for name, methods of @instanceMethods {
			for method in methods {
				method.prepare()
				
				@type.addInstanceMethod(name, method.type())
			}
		}
		
		for name, methods of @abstractMethods {
			for method in methods {
				method.prepare()
				
				@type.addAbstractMethod(name, method.type())
			}
		}
		
		for method in @constructors {
			method.prepare()
			
			@type.addConstructor(method.type())
		}
		
		if @destructor? {
			@destructor.prepare()
			
			@type.addDestructor()
		}
		
		if @extends && !@abstract && (notImplemented = @type.getMissingAbstractMethods()).length != 0 {
			SyntaxException.throwMissingAbstractMethods(@name, notImplemented, this)
		}
	} // }}}
	translate() { // {{{
		for :variable of @classVariables {
			variable.translate()
		}
		
		for :variable of @instanceVariables {
			variable.translate()
		}
		
		for method in @constructors {
			method.translate()
		}
		
		@destructor.translate() if @destructor?
		
		for :methods of @instanceMethods {
			for method in methods {
				method.translate()
			}
		}
		
		for :methods of @abstractMethods {
			for method in methods {
				method.translate()
			}
		}
		
		for :methods of @classMethods {
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
			else {
				throw new NotImplementedException(this)
			}
		}
	} // }}}
	extends() => @extendsType
	hasInits() { // {{{
		for :field of @instanceVariables {
			if field.hasDefaultValue() {
				return true
			}
		}
		
		return false
	} // }}}
	isExtending() => @extends
	name() => @name
	newInstanceMethodScope(method: ClassMethodDeclaration) { // {{{
		let scope = new Scope(@scope)
		
		scope.define('this', true, @type.reference(), this)
		
		if @extends {
			const variable = scope.define('super', true, @extendsType.reference(), this)
			
			if @es5 {
				variable.replaceCall = (data, arguments) => new CallSuperMethodES5Substitude(data, arguments, method, @type)
				
				variable.replaceMemberCall= (property, arguments) => new MemberSuperMethodES5Substitude(property, arguments, @type)
			}
			else {
				variable.replaceCall = (data, arguments) => new CallSuperMethodES6Substitude(data, arguments, method, @type)
			}
		}
		
		return scope
	} // }}}
	toContinousES5Fragments(fragments) { // {{{
		this.module().flag('Helper')
		
		const line = fragments.newLine().code($runtime.scope(this), @name, ' = ', $runtime.helper(this), '.class(')
		const clazz = line.newObject()
		
		clazz.line('$name: ' + $quote(@name))
		
		if @data.version? {
			clazz.line(`$version: [\(@data.version.major), \(@data.version.minor), \(@data.version.patch)]`)
		}
		
		if @extends {
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
			
			for name, methods of @classMethods {
				m.clear()
				
				for method in methods {
					method.toFragments(ctrl, Mode::None)
					
					m.push(method.type())
				}
				
				ClassMethodDeclaration.toClassSwitchFragments(this, ctrl.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
			}
			
			ctrl.done()
		}
		
		if !@extends || @extendsType.isSealedAlien() {
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
			
			for :field of @instanceVariables {
				field.toFragments(ctrl)
			}
			
			ctrl = clazz.newControl().code('__ks_init: function()').step()
			
			if @extends && !@extendsType.isSealedAlien() {
				ctrl.line(@extendsName + '.prototype.__ks_init.call(this)')
			}
			
			ctrl.line(@name + '.prototype.__ks_init_1.call(this)')
		}
		else {
			if @extends {
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
		
		for name, methods of @instanceMethods {
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
		
		if @extends {
			clazz.code(' extends ', @extendsName)
		}
		
		clazz.step()
		
		let ctrl
		if !@extends {
			clazz
				.newControl()
				.code('constructor()')
				.step()
				.line('this.__ks_init()')
				.line('this.__ks_cons(arguments)')
				.done()
		}
		else if @extendsType.isSealedAlien() {
			clazz
				.newControl()
				.code('constructor()')
				.step()
				.line('super()')
				.line('this.__ks_init()')
				.line('this.__ks_cons(arguments)')
				.done()
		}
		
		if this.hasInits() {
			ctrl = clazz
				.newControl()
				.code('__ks_init_1()')
				.step()
			
			for :field of @instanceVariables {
				field.toFragments(ctrl)
			}
			
			ctrl.done()
			
			ctrl = clazz.newControl().code('__ks_init()').step()
			
			if @extends && !@extendsType.isSealedAlien() {
				ctrl.line(@extendsName + '.prototype.__ks_init.call(this)')
			}
			
			ctrl.line(@name + '.prototype.__ks_init_1.call(this)')
			
			ctrl.done()
		}
		else {
			if @extends {
				if @extendsType.isSealedAlien() {
					clazz
						.newControl()
						.code('__ks_init()')
						.step()
						.done()
				}
				else {
					clazz
						.newControl()
						.code('__ks_init()')
						.step()
						.line(@extendsName + '.prototype.__ks_init.call(this)')
						.done()
				}
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
		
		for name, methods of @instanceMethods {
			m.clear()
			
			for method in methods {
				method.toFragments(clazz, Mode::None)
				
				m.push(method.type())
			}
			
			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}
		
		for name, methods of @classMethods {
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
		
		if @extends {
			clazz.line('$extends: ', @extendsName)
		}
		
		const m = []
		
		let ctrl
		/* if node._destructor? || !Object.isEmpty(node._classMethods) {
			ctrl = clazz.newLine().code('$static: ').newObject()
			
			if node._destructor? {
				$class.destructor(node, ctrl, node._destructor)
				
				$helper.destructor(node, ctrl, node._variable)
			}
			
			for name, methods of node._classMethods {
				mets.clear()
				
				for method in methods {
					$class.classMethod(node, ctrl, method, method.signature(), name)
					
					mets.push(method.signature())
				}
				
				$helper.classMethod(node, ctrl.newControl(), node._variable, mets, name, $class.classMethodHeaderES5^^(name), $class.methodFooterES5)
			}
			
			ctrl.done()
		} */
		
		if @extends && !@extendsType.isSealedAlien() {
			ctrl = clazz
				.newControl()
				.code('__ks_init: function()')
				.step()
				
			ctrl.line(@extendsName, '.prototype.__ks_init.call(this)')
			
			if this.hasInits() {
				for :field of @instanceVariables {
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
				for :field of @instanceVariables {
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
		
		for name, methods of @instanceMethods {
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
		
		if @extends {
			clazz.code(' extends ', @extendsName)
		}
		
		clazz.step()
		
		let ctrl
		if @extends && !@extendsType.isSealedAlien() {
			ctrl = clazz
				.newControl()
				.code('__ks_init()')
				.step()
				
			ctrl.line(@extendsName, '.prototype.__ks_init.call(this)')
			
			if this.hasInits() {
				for :field of @instanceVariables {
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
				for :field of @instanceVariables {
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
		
		/* if node._destructor? {
			$class.destructor(node, clazz, node._destructor)
			
			$helper.destructor(node, clazz, node._variable)
		} */
		
		for name, methods of @instanceMethods {
			m.clear()
			
			for method in methods {
				method.toFragments(clazz, Mode::None)
				
				m.push(method.type())
			}
			
			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, name, func(node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}
		
		for name, methods of @classMethods {
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
			else {
				this.toContinousES6Fragments(fragments)
			}
		}
		
		for :variable of @classVariables {
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
			fragments.line(`var \(@type.sealName()) = {}`)
		}
	} // }}}
	type() => @type
	walk(fn) { // {{{
		fn(@name, @type)
	} // }}}
}

class CallThisConstructorSubstitude {
	private {
		_arguments
		_class: Type
		_data
	}
	constructor(@data, @arguments, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.name()).prototype.__ks_cons.call(this, [`)
		
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

class CallSuperConstructorSubstitude {
	private {
		_arguments
		_class: Type
		_data
	}
	constructor(@data, @arguments, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.extends().name()).prototype.__ks_cons.call(this, [`)
		
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

class CallSuperMethodES5Substitude {
	private {
		_arguments
		_class: Type
		_data
		_method: ClassMethodDeclaration
	}
	constructor(@data, @arguments, @method, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.extends().name()).prototype.\(@method.name()).call(this, [`)
		
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
		_class: Type
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
		_class: Type
		_property: String
	}
	constructor(@property, @arguments, @class)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.extends().name()).prototype.\(@property).apply(this, [`)
		
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
		_body: Array
		_instance: Boolean		= true
		_internalName: String
		_name: String
		_parameters: Array
		_statements: Array
		_type: Type
	}
	static toClassSwitchFragments(node, fragments, variable, methods, name, header, footer) { // {{{
		let extend = null
		if variable.isExtending() {
			extend = func(node, fragments, ctrl?, variable) {
				const extends = variable.extends().name()
				if node.scope().getVariable(extends).type().hasClassMethod(name) {
					ctrl.done()
					
					fragments.line(`return \(extends).\(name).apply(null, arguments)`)
				}
				else {
					ctrl
						.step()
						.code(`else if(\(extends).\(name))`)
						.step()
						.line(`return \(extends).\(name).apply(null, arguments)`)
						.done()
					
					fragments.line('throw new SyntaxError("wrong number of arguments")')
				}
			}
		}
		
		return ClassDeclaration.toSwitchFragments(node, fragments, variable, methods, extend, header, footer, ClassDeclaration.callMethod^^(node, variable, `__ks_sttc_\(name)_`, 'arguments', 'return '), 'arguments', true)
	} // }}}
	static toInstanceSwitchFragments(node, fragments, variable, methods, name, header, footer) { // {{{
		let extend = null
		if variable.isExtending() {
			extend = func(node, fragments, ctrl?, variable) {
				const extends = variable.extends().name()
				if node.scope().getVariable(extends).type().hasInstanceMethod(name) {
					ctrl.done()
					
					fragments.line(`return \(extends).prototype.\(name).apply(this, arguments)`)
				}
				else {
					ctrl
						.step()
						.code(`else if(\(extends).prototype.\(name))`)
						.step()
						.line(`return \(extends).prototype.\(name).apply(this, arguments)`)
						.done()
					
					fragments.line('throw new SyntaxError("wrong number of arguments")')
				}
			}
		}
		
		return ClassDeclaration.toSwitchFragments(node, fragments, variable, methods, extend, header, footer, ClassDeclaration.callMethod^^(node, variable, `prototype.__ks_func_\(name)_`, 'arguments', 'return '), 'arguments', true)
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
			@parent.addReference(Type.fromAST(parameter.type, this), this)
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
			for parameter in @parameters {
				parameter.prepare()
			}
			
			const arguments = [parameter.type() for parameter in @parameters]
			@type = new ClassMethodType(arguments, @data, this)
			
			if @parent._extends {
				if method ?= @parent._extendsType.getInstanceMethod(@name, arguments) {
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
		}
		
		for statement in @body {
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
	addAliasStatement(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@body, statement.name(), false, false) {
			@aliases.push(statement)
		}
	} // }}}
	isAbstract() => @abstract
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstance() => @instance
	isMethod() => true
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
		
		Parameter.toFragments(this, ctrl, false, func(node) {
			return node.code(')').step()
		})
		
		for statement in @statements {
			ctrl.compile(statement)
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
		_aliases: Array			= []
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
				const name = variable.extends().name()
				const extends = node.scope().getVariable(name).type()
				const constructorName = extends.isSealedAlien() ? 'constructor' : '__ks_cons'
				
				if ctrl? {
					ctrl
						.step()
						.code('else')
						.step()
						.line(`\(name).prototype.\(constructorName).call(this, args)`)
						.done()
				}
				else {
					fragments.line(`\(name).prototype.\(constructorName).call(this, args)`)
				}
			}
		}
		
		return ClassDeclaration.toSwitchFragments(node, fragments, variable, methods, extend, header, footer, ClassDeclaration.callMethod^^(node, variable, 'prototype.__ks_cons_', 'args', ''), 'args', false)
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent._constructorScope))
		
		@internalName = `__ks_cons_\(parent._constructors.length)`
		
		parent._constructors.push(this)
		
		for parameter in @data.parameters {
			@parent.addReference(Type.fromAST(parameter.type, this), this)
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
		
		let index = -1
		if @body.length == 0 {
			if @parent._extends {
				this.callParentConstructor(@body)
				
				index = 0
			}
		}
		else if (index = this.getConstructorIndex(@body)) == -1 && @parent._extends && (!@parent._extendsType.isSealed() || !@parent._extendsType.isSealedAlien()) {
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
			/* for statement in @body from 0 to index { */
			for statement, i in @body while i <= index {
				@statements.push(statement = $compile.statement(statement, this))
				
				statement.analyse()
			}
			
			for statement in @aliases {
				@statements.push(statement)
				
				statement.analyse()
			}
			
			/* for statement in @body from index + 1 { */
			for statement, i in @body when i > index {
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
		if !ClassDeclaration.isAssigningAlias(@body, statement.name(), true, @parent._extends) {
			@aliases.push(statement)
		}
	} // }}}
	private callParentConstructor(body) { // {{{
		// list maybe parent's variables
		const type = @parent.type()
		
		let parameters = [
			parameter
			for parameter in @parameters
			when	!parameter.isAnonymous() &&
					!parameter.isThisAlias()
		]
		
		if parameters.length == 0 {
			if @parent._extendsType.hasConstructors() {
				SyntaxException.throwNoSuperCall(this)
			}
		}
		else {
			// map parent's constructors
			// select constructors with most match
			// if only one, select it
			// if multiple, throw an error (ConflictConstructor)
			// if none, select empty constructor
			// if no empty constructor, throw an error (NoEmptyConstructor)
			// add call to parent's constructor
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
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}
		
		return false
	} // }}}
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isMethod() => true
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		if @parent._es5 {
			ctrl.code(`\(@internalName): function(`)
		}
		else {
			ctrl.code(`\(@internalName)(`)
		}
		
		Parameter.toFragments(this, ctrl, false, func(node) {
			return node.code(')').step()
		})
		
		for statement in @statements {
			ctrl.compile(statement)
		}
		
		ctrl.done() unless @parent._es5
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
		
		if node._extends {
			ctrl.line(`\(node._extendsName).__ks_destroy(that)`)
		}
		
		for i from 0 til variable.destructors() {
			ctrl.line(`\(node._name).__ks_destroy_\(i)(that)`)
		}
		
		ctrl.done() unless node._es5
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent._destructorScope))
		
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
	isMethod() => true
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		if @parent._es5 {
			ctrl.code(`\(@internalName): function(`)
		}
		else {
			ctrl.code(`static \(@internalName)(`)
		}
		
		Parameter.toFragments(this, ctrl, false, func(node) {
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
		
		@parent.addReference(@type = ClassVariableType.fromAST(@data, this), this)
	} // }}}
	analyse() { // {{{
		if @data.defaultValue? {
			@hasDefaultValue = true
			
			if @instance {
				let scope = @scope
				
				@scope = @parent._instanceVariableScope
				
				@defaultValue = $compile.expression(@data.defaultValue, this)
				@defaultValue.analyse()
				
				@scope = scope
			}
			else {
				@defaultValue = $compile.expression(@data.defaultValue, this)
				@defaultValue.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		if @hasDefaultValue {
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