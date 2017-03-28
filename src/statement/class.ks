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

const $class = {
	abstractMethod(node, fragments, statement, signature, reflect, name) { // {{{
		if !(reflect.abstractMethods[name] is Array) {
			reflect.abstractMethods[name] = []
		}
		
		reflect.abstractMethods[name].push(signature)
	} // }}}
	continuous(node, fragments) { // {{{
		let reflect = {
			abstract: node._abstract
			inits: 0
			constructors: []
			destructors: 0
			instanceVariables: {}
			classVariables: {}
			instanceMethods: {}
			classMethods: {}
			abstractMethods: {}
		}
		
		let noinit = Object.isEmpty(node._instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of node._instanceVariables while noinit {
				if field.hasDefaultValue() {
					noinit = false
				}
			}
		}
		
		for name, variable of node._instanceVariables {
			reflect.instanceVariables[name] = variable.signature()
		}
		
		for name, variable of node._classVariables {
			reflect.classVariables[name] = variable.signature()
		}
		
		if node._es5 {
			node.module().flag('Helper')
			
			let line = fragments.newLine().code($variable.scope(node), node._name, ' = ', $runtime.helper(node), '.class(')
			let clazz = line.newObject()
			
			clazz.line('$name: ' + $quote(node._name))
			
			if node._data.version? {
				clazz.line(`$version: [\(node._data.version.major), \(node._data.version.minor), \(node._data.version.patch)]`)
			}
			
			if node._extends {
				clazz.line('$extends: ', node._extendsName)
			}
			
			let ctrl
			if node._destructor? || !Object.isEmpty(node._classMethods) {
				ctrl = clazz.newLine().code('$static: ').newObject()
				
				if node._destructor? {
					$class.destructor(node, ctrl, node._destructor, reflect)
					
					$helper.destructor(node, ctrl, reflect)
				}
				
				for name, methods of node._classMethods {
					for method in methods {
						$class.classMethod(node, ctrl, method, method.signature(), reflect, name)
					}
					
					$helper.classMethod(node, ctrl, reflect, name)
				}
				
				ctrl.done()
			}
			
			if !node._extends || node._extendsVariable.sealed?.extern {
				clazz
					.newControl()
					.code($class.methodHeader('$create', node), '()')
					.step()
					.line('this.__ks_init()')
					.line('this.__ks_cons(arguments)')
			}
			
			if noinit {
				if node._extends {
					if node._extendsVariable.sealed?.extern {
						clazz
							.newControl()
							.code($class.methodHeader('__ks_init', node), '()')
							.step()
					}
					else {
						clazz
							.newControl()
							.code($class.methodHeader('__ks_init', node), '()')
							.step()
							.line(node._extendsName + '.prototype.__ks_init.call(this)')
					}
				}
				else {
					clazz.newControl().code($class.methodHeader('__ks_init', node), '()').step()
				}
			}
			else {
				++reflect.inits
				
				ctrl = clazz
					.newControl()
					.code($class.methodHeader('__ks_init_1', node), '()')
					.step()
				
				for :field of node._instanceVariables {
					field.toFragments(ctrl)
				}
				
				ctrl = clazz.newControl().code($class.methodHeader('__ks_init', node), '()').step()
				
				if node._extends {
					ctrl.line(node._extendsName + '.prototype.__ks_init.call(this)')
				}
				
				ctrl.line(node._name + '.prototype.__ks_init_1.call(this)')
			}
			
			for method in node._constructors {
				$class.constructor(node, clazz, method, method.signature(), reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method, method.signature(), reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method, method.signature(), reflect, name)
				}
			}
			
			clazz.done()
			line.code(')').done()
		}
		else {
			let clazz = fragments
				.newControl()
				.code('class ', node._name)
			
			if node._extends {
				clazz.code(' extends ', node._extendsName)
			}
			
			clazz.step()
			
			let ctrl
			if !node._extends {
				clazz
					.newControl()
					.code('constructor()')
					.step()
					.line('this.__ks_init()')
					.line('this.__ks_cons(arguments)')
					.done()
			}
			else if node._extendsVariable.sealed?.extern {
				clazz
					.newControl()
					.code('constructor()')
					.step()
					.line('super()')
					.line('this.__ks_init()')
					.line('this.__ks_cons(arguments)')
					.done()
			}
			
			if noinit {
				if node._extends {
					if node._extendsVariable.sealed?.extern {
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
							.line(node._extendsName + '.prototype.__ks_init.call(this)')
							.done()
					}
				}
				else {
					clazz.newControl().code('__ks_init()').step().done()
				}
			}
			else {
				++reflect.inits
				
				ctrl = clazz
					.newControl()
					.code('__ks_init_1()')
					.step()
				
				for :field of node._instanceVariables {
					field.toFragments(ctrl)
				}
				
				ctrl.done()
				
				ctrl = clazz.newControl().code('__ks_init()').step()
				
				if node._extends {
					ctrl.line(node._extendsName + '.prototype.__ks_init.call(this)')
				}
				
				ctrl.line(node._name + '.prototype.__ks_init_1.call(this)')
				
				ctrl.done()
			}
			
			for method in node._constructors {
				$class.constructor(node, clazz, method, method.signature(), reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			if node._destructor? {
				$class.destructor(node, clazz, node._destructor, reflect)
				
				$helper.destructor(node, clazz, reflect)
			}
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method, method.signature(), reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method, method.signature(), reflect, name)
				}
			}
			
			for name, methods of node._classMethods {
				for method in methods {
					$class.classMethod(node, clazz, method, method.signature(), reflect, name)
				}
				
				$helper.classMethod(node, clazz, reflect, name)
			}
			
			clazz.done()
		}
		
		return reflect
	} // }}}
	classMethod(node, fragments, statement, signature, reflect, name) { // {{{
		if reflect.classMethods[name] is not Array {
			reflect.classMethods[name] = []
		}
		
		reflect.classMethods[name].push(signature)
		
		statement.toFragments(fragments, Mode::None)
	} // }}}
	constructor(node, fragments, statement, signature, reflect) { // {{{
		let index = reflect.constructors.length
		
		reflect.constructors.push(signature)
	
		statement.toFragments(fragments, Mode::None)
	} // }}}
	destructor(node, fragments, statement, reflect) { // {{{
		statement.toFragments(fragments, Mode::None)
		
		reflect.destructors++
	} // }}}
	hierarchy(variable, node, hierarchy = []) { // {{{
		hierarchy.push(variable.name.name)
		
		if variable.extends? && (variable ?= node.scope().getVariable(variable.extends)) {
			return $class.hierarchy(variable, node, hierarchy)
		}
		else {
			return hierarchy
		}
	} // }}}
	instanceMethod(node, fragments, statement, signature, reflect, name) { // {{{
		if reflect.instanceMethods[name] is not Array {
			reflect.instanceMethods[name] = []
		}
		
		reflect.instanceMethods[name].push(signature)
		
		statement.toFragments(fragments, Mode::None)
	} // }}}
	listMissingAbstractMethods(variable, scope) { // {{{
		const abstractMethods = {}
		
		if variable.extends? {
			$class.listParentAbstractMethods(scope.getVariable(variable.extends), abstractMethods, scope)
		}
		
		let method, index
		for name, methods of abstractMethods when variable.instanceMethods[name]? {
			for method, index in methods desc {
				if $signature.match(method, variable.instanceMethods[name]) {
					methods.splice(index, 1)
				}
			}
			
			if methods.length == 0 {
				delete abstractMethods[name]
			}
		}
		
		return Object.keys(abstractMethods)
	} // }}}
	listParentAbstractMethods(variable, abstractMethods, scope) { // {{{
		if variable.extends? {
			$class.listParentAbstractMethods(scope.getVariable(variable.extends), abstractMethods, scope)
		}
		
		if variable.abstract {
			for name, methods of variable.abstractMethods {
				abstractMethods[name] ??= []
				
				abstractMethods[name]:Array.append(methods)
			}
		}
		
		let method, index
		for name, methods of abstractMethods when variable.instanceMethods[name]? {
			for method, index in methods desc {
				if $signature.match(method, variable.instanceMethods[name]) {
					methods.splice(index, 1)
				}
			}
			
			if methods.length == 0 {
				delete abstractMethods[name]
			}
		}
	} // }}}
	methodCall(node, fnName, argName, retCode, fragments, method, index) { // {{{
		if method.max == 0 {
			fragments.line(retCode, node._data.name.name, '.', fnName, index, '.apply(this)')
		}
		else {
			fragments.line(retCode, node._data.name.name, '.', fnName, index, '.apply(this, ', argName, ')')
		}
	} // }}}
	methodHeader(name, node) { // {{{
		if node._es5 {
			return name + ': function'
		}
		else {
			return name
		}
	} // }}}
	sealed(node, fragments) { // {{{
		let reflect = {
			abstract: node._abstract
			sealed: true
			inits: 0
			constructors: []
			destructors: 0
			instanceVariables: {}
			classVariables: {}
			instanceMethods: {}
			classMethods: {}
			abstractMethods: {}
		}
		
		let noinit = Object.isEmpty(node._instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of node._instanceVariables while noinit {
				if field.hasDefaultValue {
					noinit = false
				}
			}
		}
		
		for name, variable of node._instanceVariables {
			reflect.instanceVariables[name] = variable.signature()
		}
		
		for name, variable of node._classVariables {
			reflect.classVariables[name] = variable.signature()
		}
		
		if node._es5 {
			node.module().flag('Helper')
			
			let line = fragments.newLine().code($variable.scope(node), node._name, ' = ', $runtime.helper(node), '.class(')
			let clazz = line.newObject()
			
			clazz.line('$name: ' + $quote(node._name))
			
			if node._data.version? {
				clazz.line(`$version: [\(node._data.version.major), \(node._data.version.minor), \(node._data.version.patch)]`)
			}
			
			if node._extends {
				clazz.line('$extends: ', node._extendsName)
			}
			
			let ctrl
			if node._destructor? || !Object.isEmpty(node._classMethods) {
				ctrl = clazz.newLine().code('$static: ').newObject()
				
				if node._destructor? {
					$class.destructor(node, ctrl, node._destructor, reflect)
					
					$helper.destructor(node, ctrl, reflect)
				}
				
				for name, methods of node._classMethods {
					for method in methods {
						$class.classMethod(node, ctrl, method, method.signature(), reflect, name)
					}
					
					$helper.classMethod(node, ctrl, reflect, name)
				}
				
				ctrl.done()
			}
			
			if node._extends {
				ctrl = clazz
					.newControl()
					.code($class.methodHeader('__ks_init', node), '()')
					.step()
					
				ctrl.line(node._extendsName, '.prototype.__ks_init.call(this)')
				
				if !noinit {
					for :field of node._instanceVariables {
						field.toFragments(ctrl)
					}
				}
			}
			else {
				ctrl = clazz
					.newControl()
					.code($class.methodHeader('$create', node), '()')
					.step()
			
				if !noinit {
					for :field of node._instanceVariables {
						field.toFragments(ctrl)
					}
				}
				
				ctrl.line('this.__ks_cons(arguments)')
			}
			
			for method in node._constructors {
				$class.constructor(node, clazz, method, method.signature(), reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method, method.signature(), reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method, method.signature(), reflect, name)
				}
			}
			
			clazz.done()
			line.code(')').done()
		}
		else {
			let clazz = fragments
				.newControl()
				.code('class ', node._name)
			
			if node._extends {
				clazz.code(' extends ', node._extendsName)
			}
			
			clazz.step()
			
			let ctrl
			if node._extends {
				ctrl = clazz
					.newControl()
					.code('__ks_init()')
					.step()
					
				ctrl.line(node._extendsName, '.prototype.__ks_init.call(this)')
				
				if !noinit {
					for :field of node._instanceVariables {
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
			
				if !noinit {
					for :field of node._instanceVariables {
						field.toFragments(ctrl)
					}
				}
				
				ctrl.line('this.__ks_cons(arguments)')
				
				ctrl.done()
			}
			
			for method in node._constructors {
				$class.constructor(node, clazz, method, method.signature(), reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			if node._destructor? {
				$class.destructor(node, clazz, node._destructor, reflect)
				
				$helper.destructor(node, clazz, reflect)
			}
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method, method.signature(), reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method, method.signature(), reflect, name)
				}
			}
			
			for name, methods of node._classMethods {
				for method in methods {
					$class.classMethod(node, clazz, method, method.signature(), reflect, name)
				}
				
				$helper.classMethod(node, clazz, reflect, name)
			}
			
			clazz.done()
		}
		
		return reflect
	} // }}}
}

const $field = {
	signature(data, node) { // {{{
		let signature = {
			access: Accessibility::Public
		}
		
		if data.modifiers {
			for modifier in data.modifiers {
				if modifier.kind == ModifierKind::Private {
					signature.access = Accessibility::Private
				}
				else if modifier.kind == ModifierKind::Protected {
					signature.access = Accessibility::Protected
				}
			}
		}
		
		if data.type {
			signature.type = $signature.type(data.type, node.scope())
			
			if data.type.nullable {
				signature.nullable = true
			}
		}
		else {
			signature.type = 'Any'
		}
		
		return signature
	} // }}}
}

const $helper = {
	classMethod(node, fragments, reflect, name) { // {{{
		let extend = false
		if node._extends {
			extend = func(node, fragments, ctrl) {
				if node._extendsVariable.classMethods[name] {
					ctrl.done()
					
					fragments.line('return ' + node._extendsName + '.' + name + '.apply(null, arguments)')
				}
				else {
					ctrl
						.step()
						.code('else if(' + node._extendsName + '.' + name + ')')
						.step()
						.line('return ' + node._extendsName + '.' + name + '.apply(null, arguments)')
						.done()
					
					fragments.line('throw new SyntaxError("wrong number of arguments")')
				}
			}
		}
		
		$helper.methods(extend, node, fragments.newControl(), node._es5 ? $class.methodHeader(name, node) + '()' : 'static ' + name + '()', reflect.classMethods[name], $class.methodCall^^(node, '__ks_sttc_' + name + '_', 'arguments', 'return '), 'arguments', 'classMethods.' + name, true)
	} // }}}
	constructor(node, fragments, reflect) { // {{{
		let extend = false
		if node._extends {
			extend = func(node, fragments, ctrl = null) {
				let constructorName = node._extendsVariable.sealed?.extern ? 'constructor' : '__ks_cons'
				
				if ctrl? {
					ctrl
						.step()
						.code('else')
						.step()
						.line(`\(node._extendsName).prototype.\(constructorName).call(this, args)`)
						.done()
				}
				else {
					fragments.line(`\(node._extendsName).prototype.\(constructorName).call(this, args)`)
				}
			}
		}
		
		$helper.methods(extend, node, fragments.newControl(), $class.methodHeader('__ks_cons', node) + '(args)', reflect.constructors, $class.methodCall^^(node, 'prototype.__ks_cons_', 'args', ''), 'args', 'constructors', false)
	} // }}}
	decide(node, fragments, type, index, path, argName) { // {{{
		node.module().flag('Type')
		
		if tof = $runtime.typeof(type, node) {
			fragments.code(tof + '(' + argName + '[' + index + '])')
		}
		else {
			fragments.code($runtime.type(node), '.is(' + argName + '[' + index + '], ' + path + ')')
		}
	} // }}}
	destructor(node, fragments, reflect) { // {{{
		let ctrl = fragments.newControl()
		
		if node._es5 {
			ctrl.code($class.methodHeader('__ks_destroy', node) + '(that)')
		}
		else {
			ctrl.code('static __ks_destroy(that)')
		}
		
		ctrl.step()
		
		if node._extends {
			ctrl.line(`\(node._extendsName).__ks_destroy(that)`)
		}
		
		for i from 0 til reflect.destructors {
			ctrl.line(`\(node._name).__ks_destroy_\(i)(that)`)
		}
		
		ctrl.done() unless node._es5
	} // }}}
	instanceMethod(node, fragments, reflect, name) { // {{{
		let extend = false
		if node._extends {
			extend = func(node, fragments, ctrl) {
				if node._extendsVariable.instanceMethods[name] {
					ctrl.done()
					
					fragments.line('return ' + node._extendsName + '.prototype.' + name + '.apply(this, arguments)')
				}
				else {
					ctrl
						.step()
						.code('else if(' + node._extendsName + '.prototype.' + name + ')')
						.step()
						.line('return ' + node._extendsName + '.prototype.' + name + '.apply(this, arguments)')
						.done()
					
					fragments.line('throw new SyntaxError("wrong number of arguments")')
				}
			}
		}
		
		$helper.methods(extend, node, fragments.newControl(), $class.methodHeader(name, node) + '()', reflect.instanceMethods[name], $class.methodCall^^(node, 'prototype.__ks_func_' + name + '_', 'arguments', 'return '), 'arguments', 'instanceMethods.' + name, true)
	} // }}}
	methods(extend, node, fragments, header, methods, call, argName, refName, returns) { // {{{
		fragments.code(header).step()
		
		let method
		if methods.length == 0 {
			if extend {
				extend(node, fragments)
			}
			else {
				fragments
					.newControl()
					.code('if(' + argName + '.length !== 0)')
					.step()
					.line('throw new SyntaxError("wrong number of arguments")')
					.done()
			}
		}
		else if methods.length == 1 {
			method = methods[0]
			
			if method.min == 0 && method.max >= Infinity {
				call(fragments, method, 0)
			}
			else if method.min == method.max {
				let ctrl = fragments.newControl()
				
				ctrl.code('if(' + argName + '.length === ' + method.min + ')').step()
				
				call(ctrl, method, 0)
				
				if returns {
					if extend {
						extend(node, fragments, ctrl)
					}
					else {
						ctrl.done()
						
						fragments.line('throw new SyntaxError("wrong number of arguments")')
					}
				}
				else {
					if extend {
						extend(node, fragments, ctrl)
					}
					else {
						ctrl.step().code('else').step().line('throw new SyntaxError("wrong number of arguments")').done()
					}
				}
			}
			else if method.max < Infinity {
				let ctrl = fragments.newControl()
				
				ctrl.code('if(' + argName + '.length >= ' + method.min + ' && ' + argName + '.length <= ' + method.max + ')').step()
				
				call(ctrl, method, 0)
				
				if returns {
					ctrl.done()
					
					fragments.line('throw new SyntaxError("wrong number of arguments")')
				}
				else {
					ctrl.step().code('else').step().line('throw new SyntaxError("wrong number of arguments")').done()
				}
			}
			else {
				call(fragments, method, 0)
			}
		}
		else {
			let groups = {}
			let infinities = []
			let min = Infinity
			let max = 0
			
			for index from 0 til methods.length {
				method = methods[index]
				method.index = index
				
				if method.max == Infinity {
					infinities.push(method)
				}
				else {
					for n from method.min to method.max {
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
					
					min = Math.min(min, method.min)
					max = Math.max(max, method.max)
				}
			}
			
			if infinities.length {
				for method in infinities {
					for group of groups when method.min >= group.n {
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
				
				let ctrl = fragments.newControl()
				
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
						call(ctrl, group.methods[0], group.methods[0].index)
					}
					else {
						let types = {}
						for method in group.methods {
							$helper.methodTypes(node, method, group.n, types)
						}
						
						let indexes = []
						for p, parameter of types {
							for t, type of parameter.types {
								type.methods:Array.remove(...indexes)
								
								if type.methods.length == 0 {
									delete parameter.types[t]
								}
							}
							
							for t, type of parameter.types {
								if type.methods.length == 1 {
									indexes:Array.pushUniq(type.methods[0])
								}
							}
						}
						
						if $helper.methodCheckTree(methods, types, 0, node, ctrl, call, argName, refName, returns) {
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
						
						fragments.line('throw new SyntaxError("wrong number of arguments")')
					}
					else {
						ctrl.step().code('else').step().line('throw new SyntaxError("wrong number of arguments")').done()
					}
				}
				else if infinities.length == 1 {
					ctrl.step().code('else').step()
					
					call(ctrl, infinities[0], infinities[0].index)
					
					ctrl.done()
				}
				else {
					throw new NotImplementedException(node)
				}
			}
		}
		
		fragments.done() unless node._es5
	} // }}}
	methodCheckTree(methods, types, index, node, fragments, call, argName, refName, returns) { // {{{
		if !?types[index + 1] {
			SyntaxException.throwNotDifferentiableMethods(node)
		}
		
		const tree = []
		const usages = []
		
		let type, nf, item, usage
		for name, type of types[index + 1].types {
			tree.push(item = {
				type: [name]
				path: [`this.constructor.__ks_reflect.\(refName)\(type.path)`]
				methods: [methods[i] for i in type.methods]
				usage: type.methods.length
			})
			
			if name == 'Any' {
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
				call(fragments, item.methods[0], item.methods[0].index)
				
				return false
			}
			else {
				return $helper.methodCheckTree(methods, types, index + 1, node, fragments, call, argName, refName, returns)
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
						item.path.push(...type.path)
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
					
					$helper.decide(node, ctrl, item.type[0], index, item.path[0], argName)
					
					ctrl.code(')')
				}
				
				ctrl.step()
				
				if item.methods.length == 1 {
					call(ctrl, item.methods[0], item.methods[0].index)
				}
				else {
					$helper.methodCheckTree(methods, types, index + 1, node, ctrl, call, argName, refName, returns)
				}
			}
			
			ctrl.done()
			
			return ne
		}
	} // }}}
	methodTypes(node, method, target, types) { // {{{
		let index = 1
		let count = method.min
		for parameter, p in method.parameters {
			for i from 1 to parameter.min {
				if type !?= types[index] {
					type = types[index] = {
						index: index
						types: {}
					}
				}
				
				if parameter.type is Array {
					for j from 0 til parameter.type.length {
						if type.types[parameter.type[j]] {
							type.types[parameter.type[j]].methods.push(method.index)
						}
						else {
							type.types[parameter.type[j]] = {
								name: parameter.type[j]
								path: `[\(method.index)].parameters[\(p)].type`
								methods: [method.index]
							}
						}
					}
				}
				else {
					if type.types[parameter.type] {
						type.types[parameter.type].methods.push(method.index)
					}
					else {
						type.types[parameter.type] = {
							name: parameter.type
							path: `[\(method.index)].parameters[\(p)].type`
							methods: [method.index]
						}
					}
				}
				
				++index
			}
			
			for i from parameter.min + 1 to parameter.max while count < target {
				if type !?= types[index] {
					type = types[index] = {
						index: index
						types: {}
					}
				}
				
				if parameter.type is Array {
					for j from 0 til parameter.type.length {
						if type.types[parameter.type[j]] {
							type.types[parameter.type[j]].methods.push(method.index)
						}
						else {
							type.types[parameter.type[j]] = {
								name: parameter.type[j]
								path: `[\(method.index)].parameters[\(p)].type`
								methods: [method.index]
							}
						}
					}
				}
				else {
					if type.types[parameter.type] {
						type.types[parameter.type].methods.push(method.index)
					}
					else {
						type.types[parameter.type] = {
							name: parameter.type
							path: `[\(method.index)].parameters[\(p)].type`
							methods: [method.index]
						}
					}
				}
				
				++index
				++count
			}
		}
	} // }}}
	reflect(node, fragments, reflect) { // {{{
		let classname = node._name
		
		let line = fragments.newLine()
		
		line.code(classname + '.__ks_reflect = ')
		
		let object = line.newObject()
		
		if reflect.sealed {
			object.line('sealed: true')
		}
		
		if reflect.abstract {
			object.line('abstract: true')
		}
		
		object.newLine().code('inits: ' + reflect.inits)
		
		a = object.newLine().code('constructors: ').newArray()
		for i from 0 til reflect.constructors.length {
			$helper.reflectMethod(node, a.newLine(), reflect.constructors[i], classname + '.__ks_reflect.constructors[' + i + ']')
		}
		a.done()
		
		object.line('destructors: ', reflect.destructors)
		
		o = object.newLine().code('instanceVariables: ').newObject()
		for name, variable of reflect.instanceVariables {
			$helper.reflectVariable(node, o.newLine(), name, variable, classname + '.__ks_reflect.instanceVariables.' + name)
		}
		o.done()
		
		o = object.newLine().code('classVariables: ').newObject()
		for name, variable of reflect.classVariables {
			$helper.reflectVariable(node, o.newLine(), name, variable, classname + '.__ks_reflect.classVariables.' + name)
		}
		o.done()
		
		o = object.newLine().code('instanceMethods: ').newObject()
		for name, methods of reflect.instanceMethods {
			a = o.newLine().code(name + ': ').newArray()
			
			for i from 0 til methods.length {
				$helper.reflectMethod(node, a.newLine(), methods[i], classname + '.__ks_reflect.instanceMethods.' + name + '[' + i + ']')
			}
			
			a.done()
		}
		o.done()
		
		o = object.newLine().code('classMethods: ').newObject()
		for name, methods of reflect.classMethods {
			a = o.newLine().code(name + ': ').newArray()
			
			for i from 0 til methods.length {
				$helper.reflectMethod(node, a.newLine(), methods[i], classname + '.__ks_reflect.classMethods.' + name + '[' + i + ']')
			}
			
			a.done()
		}
		o.done()
		
		object.done()
		
		line.done()
	} // }}}
	reflectMethod(node, fragments, signature, path = null) { // {{{
		let object = fragments.newObject()
		
		object.newLine().code('access: ' + signature.access)
		object.newLine().code('min: ' + signature.min)
		object.newLine().code('max: ' + (signature.max == Infinity ? 'Infinity' : signature.max))
		
		let array = object.newLine().code('parameters: ').newArray()
		
		for i from 0 til signature.parameters.length {
			$helper.reflectParameter(node, array.newLine(), signature.parameters[i], path + '.parameters[' + i + ']')
		}
		
		array.done()
		
		object.done()
	} // }}}
	reflectParameter(node, fragments, signature, path = null) { // {{{
		let object = fragments.newObject()
		
		object.newLine().code('type: ' + node.toTypeString(signature.type, path))
		object.newLine().code('min: ' + signature.min)
		object.newLine().code('max: ' + signature.max)
		
		object.done()
	} // }}}
	reflectVariable(node, fragments, name, signature, path = null) { // {{{
		let object = fragments.code(name, ': ').newObject()
		
		object.line('access: ' + signature.access)
		
		object.line('type: ' + node.toTypeString(signature.type, path))
		
		if signature.nullable {
			object.line('nullable: true')
		}
		
		object.done()
	} // }}}
}

const $method = {
	/* isConstructor(name, variable) => name == 'constructor'
	isDestructor(name, variable) => name == 'destructor' */
	isUsingProperty(data, name) { // {{{
		if data is Array {
			for d in data {
				if $method.isUsingProperty(d, name) {
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
					if data.arguments.length == 2 && data.arguments[0].kind == NodeKind::Identifier && data.arguments[0].name == 'this' && data.arguments[1].kind == NodeKind::ArrayExpression && data.callee.kind == NodeKind::MemberExpression && data.callee.property.kind == NodeKind::Identifier && data.callee.property.name == 'call' && data.callee.object.kind == NodeKind::MemberExpression && data.callee.object.property.kind == NodeKind::Identifier && data.callee.object.property.name == '__ks_cons' {
						for arg in data.arguments[1].values {
							if arg.kind == NodeKind::Identifier && arg.name == name {
								return true
							}
						}
					}
				}
				NodeKind::ReturnStatement => {
					return $method.isUsingProperty(data.value, name)
				}
			}
		}
		
		return false
	} // }}}
	sameType(s1, s2) { // {{{
		if s1 is Array {
			if s2 is Array && s1.length == s2.length {
				for i from 0 til s1.length {
					if !$method.sameType(s1[i], s2[i]) {
						return false
					}
				}
				
				return true
			}
			else {
				return false
			}
		}
		else {
			return s1 == s2
		}
	} // }}}
}

class ClassDeclaration extends Statement {
	private {
		_abstract 			= false
		_abstractMethods	= {}
		_classMethods		= {}
		_classVariables		= {}
		_constructors		= []
		_constructorScope
		_destructor			= null
		_destructorScope
		_es5				= false
		_extends			= false
		_extendsName
		_extendsVariable
		_instanceMethods	= {}
		_instanceVariables	= {}
		_instanceVariableScope
		_name
		_references			= {}
		_sealed 			= false
		_variable
	}
	constructor(data, parent) { // {{{
		super(data, parent)
		
		this._constructorScope = new Scope(parent.scope())
		this._destructorScope = new Scope(parent.scope())
		this._instanceVariableScope = new Scope(parent.scope())
		this._es5 = this._options.format.classes == 'es5'
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@variable = $variable.define(this, @scope, @data.name, true, VariableKind::Class, @data.type)
		
		let classname = @data.name
		
		let thisVariable = $variable.define(this, @constructorScope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, true, VariableKind::Variable, $type.reference(classname.name))
		
		thisVariable.callable = func(data) {
			data.arguments = [{
				kind: NodeKind::Identifier
				name: 'this'
			}, {
				kind: NodeKind::ArrayExpression
				values: data.arguments
			}]
			
			data.callee = {
				kind: NodeKind::MemberExpression
				object: {
					kind: NodeKind::MemberExpression
					object: {
						kind: NodeKind::MemberExpression
						object: classname
						property: {
							kind: NodeKind::Identifier
							name: 'prototype'
						}
						computed: false
						nullable: false
					}
					property: {
						kind: NodeKind::Identifier
						name: '__ks_cons'
					}
					computed: false
					nullable: false
				}
				property: {
					kind: NodeKind::Identifier
					name: 'call'
				}
				computed: false
				nullable: false
			}
		}
		
		thisVariable = $variable.define(this, @destructorScope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, true, VariableKind::Variable, $type.reference(classname.name))
		
		@destructorScope.rename('this', 'that')
		
		$variable.define(this, @instanceVariableScope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, true, VariableKind::Variable, $type.reference(classname.name))
		
		if @data.extends? {
			@extends = true
			
			if @extendsVariable !?= @scope.getVariable(@data.extends.name) {
				ReferenceException.throwNotDefined(@data.extends.name, this)
			}
			else if @extendsVariable.kind != VariableKind::Class {
				TypeException.throwNotClass(@data.extends.name, this)
			}
			
			@variable.extends = @extendsName = @data.extends.name
			
			let extname = @data.extends
			
			let superVariable = $variable.define(this, @constructorScope, {
				kind: NodeKind::Identifier
				name: 'super'
			}, true, VariableKind::Variable)
			
			if @extendsVariable.sealed?.extern {
				superVariable.callable = (data) => {
					SyntaxException.throwNotCompatibleConstructor(classname, this)
				}
			}
			else {
				superVariable.callable = func(data) {
					data.arguments = [{
						kind: NodeKind::Identifier
						name: 'this'
					}, {
						kind: NodeKind::ArrayExpression
						values: data.arguments
					}]
					
					data.callee = {
						kind: NodeKind::MemberExpression
						object: {
							kind: NodeKind::MemberExpression
							object: {
								kind: NodeKind::MemberExpression
								object: extname
								property: {
									kind: NodeKind::Identifier
									name: 'prototype'
								}
								computed: false
								nullable: false
							}
							property: {
								kind: NodeKind::Identifier
								name: '__ks_cons'
							}
							computed: false
							nullable: false
						}
						property: {
							kind: NodeKind::Identifier
							name: 'call'
						}
						computed: false
						nullable: false
					}
				}
			}
			
			$variable.define(this, @instanceVariableScope, {
				kind: NodeKind::Identifier
				name: 'super'
			}, true, VariableKind::Variable)
		}
		
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@variable.abstract = @abstract = true
				
				@variable.abstractMethods = {}
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true
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
					if $method.isConstructor(data.name.name, @variable) {
						declaration = new ClassConstructorDeclaration(data, this)
					}
					else if $method.isDestructor(data.name.name, @variable) {
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
		
		if @sealed {
			@variable.sealed = {
				name: '__ks_' + @variable.name.name
				constructors: false
				instanceMethods: {}
				classMethods: {}
			}
		}
	} // }}}
	prepare() { // {{{
		for name, variable of @classVariables {
			variable.prepare()
			
			@variable.classVariables[name] = variable.signature()
		}
		
		for name, variable of @instanceVariables {
			variable.prepare()
			
			@variable.instanceVariables[name] = variable.signature()
		}
		
		for method in @constructors {
			method.prepare()
			
			@variable.constructors.push(method.signature())
		}
		
		@destructor.prepare() if @destructor?
		
		for name, methods of @instanceMethods {
			for method in methods {
				method.prepare()
				
				@variable.instanceMethods[name].push(method.signature())
			}
		}
		
		for name, methods of @abstractMethods {
			for method in methods {
				method.prepare()
				
				@variable.abstractMethods[name].push(method.signature())
			}
		}
		
		for name, methods of @classMethods {
			for method in methods {
				method.prepare()
				
				@variable.classMethods[name].push(method.signature())
			}
		}
		
		if @extends && !@abstract && (notImplemented = $class.listMissingAbstractMethods(@variable, @scope)).length != 0 {
			SyntaxException.throwMissingAbstractMethods(@name, notImplemented, this)
		}
	} // }}}
	translate() { // {{{
		for :variable of this._classVariables {
			variable.translate()
		}
		
		for :variable of this._instanceVariables {
			variable.translate()
		}
		
		for method in this._constructors {
			method.translate()
		}
		
		this._destructor.translate() if this._destructor?
		
		for :methods of this._instanceMethods {
			for method in methods {
				method.translate()
			}
		}
		
		for :methods of this._abstractMethods {
			for method in methods {
				method.translate()
			}
		}
		
		for :methods of this._classMethods {
			for method in methods {
				method.translate()
			}
		}
	} // }}}
	addReference(type?, node) { // {{{
		if type? {
			if type is Array {
				for item in type {
					this.addReference(item, node)
				}
			}
			else if type.typeName? {
				let signature = $signature.type(type, @scope)
				
				if !?@references[signature] {
					if signature == 'Any' || type.typeName.name == '...' || $typeofs[signature] == true {
						@references[signature] = {
							status: TypeStatus::Native
							type: type
						}
					}
					else if variable ?= @scope.getVariable(type.typeName.name) {
						@references[signature] = {
							status: TypeStatus::Referenced
							type: type
							variable: variable
						}
					}
					else {
						@references[signature] = {
							status: TypeStatus::Unreferenced
							type: type
						}
					}
				}
			}
			else if type.types {
				for item in type.types {
					this.addReference(item, node)
				}
			}
			else {
				throw new NotImplementedException(node)
			}
		}
	} // }}}
	getAliasType(name, parameter) { // {{{
		let variable
		
		if parameter._setterAlias {
			variable = this.getInstanceMethod(name)
		}
		else {
			variable = this.getInstanceVariable(name) ?? this.getInstanceVariable('_' + name)
		}
		
		if variable? {
			let type = $type.reference(variable.type ?? 'Any')
			
			if variable.nullable {
				type.nullable = true
			}
			
			return type
		}
		
		ReferenceException.throwNotDefinedMember(name, parameter)
	} // }}}
	getInstanceMethod(name, variable = null) { // {{{
		if variable == null {
			for method in @instanceMethods[name] {
				signature = method.signature()
				
				if signature.min == 1 && signature.max == 1 {
					return signature.parameters[0]
				}
			}
		}
		else {
			if variable.instanceMethods[name]? {
				throw new NotImplementedException()
			}
			else if variable.extends? {
				return this.getInstanceMethod(name, @scope.getVariable(variable.extends))
			}
		}
		
		return null
	} // }}}
	getInstanceVariable(name, variable = @variable) { // {{{
		if variable.instanceVariables[name]? {
			return variable.instanceVariables[name]
		}
		else if variable.extends? {
			return this.getInstanceVariable(name, @scope.getVariable(variable.extends))
		}
		
		return null
	} // }}}
	isInstanceMethod(name, variable = @variable) { // {{{
		if variable.instanceMethods[name]?['1']? {
			return true
		}
		else if variable.extends? {
			return this.getInstanceMethod(name, @scope.getVariable(variable.extends))
		}
		
		return false
	} // }}}
	isInstanceVariable(name, variable = @variable) { // {{{
		if variable.instanceVariables[name]? {
			return true
		}
		else if variable.extends? {
			return this.isInstanceVariable(name, @scope.getVariable(variable.extends))
		}
		
		return false
	} // }}}
	name() => @name
	newInstanceMethodScope(method) { // {{{
		let scope = new Scope(this._scope)
		
		$variable.define(this, scope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, true, VariableKind::Variable, $type.reference(@data.name.name))
		
		if this._extends {
			let variable = $variable.define(this, scope, {
				kind: NodeKind::Identifier
				name: 'super'
			}, true, VariableKind::Variable)
			
			if this._es5 {
				let extname = @data.extends
				
				variable.callable = func(data) {
					data.arguments = [{
						kind: NodeKind::Identifier
						name: 'this'
					}, {
						kind: NodeKind::ArrayExpression
						values: data.arguments
					}]
					
					data.callee = {
						kind: NodeKind::MemberExpression
						object: {
							kind: NodeKind::MemberExpression
							object: {
								kind: NodeKind::MemberExpression
								object: extname
								property: {
									kind: NodeKind::Identifier
									name: 'prototype'
								}
								computed: false
								nullable: false
							}
							property: method.name
							computed: false
							nullable: false
						}
						property: {
							kind: NodeKind::Identifier
							name: 'call'
						}
						computed: false
						nullable: false
					}
				}
				
				variable.reduce = func(data) {
					data.arguments = [{
						kind: NodeKind::Identifier
						name: 'this'
					}, {
						kind: NodeKind::ArrayExpression
						values: data.arguments
					}]
					
					data.callee = {
						kind: NodeKind::MemberExpression
						object: {
							kind: NodeKind::MemberExpression
							object: {
								kind: NodeKind::MemberExpression
								object: extname
								property: {
									kind: NodeKind::Identifier
									name: 'prototype'
								}
								computed: false
								nullable: false
							}
							property: data.callee.property
							computed: false
							nullable: false
						}
						property: {
							kind: NodeKind::Identifier
							name: 'apply'
						}
						computed: false
						nullable: false
					}
				}
			}
			else {
				variable.callable = func(data) {
					data.callee = {
						kind: NodeKind::MemberExpression
						object: data.callee
						property: method.name
						computed: false
						nullable: false
					}
				}
			}
		}
		
		return scope
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let reflect = @sealed ? $class.sealed(this, fragments) : $class.continuous(this, fragments)
		
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
		
		$helper.reflect(this, fragments, reflect)
		
		if references ?= this.module().listReferences(@name) {
			for ref in references {
				fragments.line(ref)
			}
		}
		
		if @sealed {
			fragments.line('var ' + @variable.sealed.name + ' = {}')
		}
	} // }}}
	toTypeString(type, path) { // {{{
		if type is Array {
			let src = ''
			
			for i from 0 til type.length {
				if i {
					src += ','
				}
				
				src += this.toTypeString(type[i], path)
			}
			
			return '[' + src + ']'
		}
		else if type is String {
			if reference ?= @references[type] {
				if reference.status == HelperTypeKind::Native {
					return $quote(type)
				}
				else if reference.status == HelperTypeKind::Referenced {
					return type
				}
				else if reference.status == HelperTypeKind::Unreferenced {
					if path? {
						this.module().addReference(type, path + '.type = ' + type)
						
						return $quote('#' + type)
					}
					else {
						TypeException.throwInvalid(type, this)
					}
				}
			}
			else if type == 'Any' || $typeofs[type] == true {
				return $quote(type)
			}
			else if @scope.hasVariable(type) {
				return type
			}
			else {
				if path? {
					this.module().addReference(type, path + '.type = ' + type)
					
					return $quote('#' + type)
				}
				else {
					TypeException.throwInvalid(type, this)
				}
			}
		}
		else if type.name? {
			return this.toTypeString(type.name, path)
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
}

class ClassMethodDeclaration extends Statement {
	private {
		_abstract: Boolean		= false
		_analysed: Boolean		= false
		_instance: Boolean		= true
		_internalName: String
		_name: String
		_parameters
		_signature
		_statements
	}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newInstanceMethodScope(data))
		
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
					
						parent._variable.abstractMethods[@name] = []
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
					
					parent._variable.instanceMethods[@name] = []
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
				
				parent._variable.classMethods[@name] = []
			}
		}
		
		for parameter in @data.parameters {
			@parent.addReference($type.type(parameter.type, @scope, this), this)
		}
	} // }}}
	analyse() { // {{{
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
			
			@signature = Signature.fromNode(this)
			
			@analysed = true
		}
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		@statements = []
		for statement in $body(@data.body) {
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
	getAliasType(name, node) => @parent.getAliasType(name, node)
	isAbstract() => @abstract
	isConsumedError(name, variable): Boolean { // {{{
		if @data.throws.length > 0 {
			for x in @data.throws {
				return true if $error.isConsumed(x.name, name, variable, @scope)
			}
		}
		
		return false
	} // }}}
	isInstance() => @instance
	isInstanceMethod(name) => @parent.isInstanceMethod(name)
	isInstanceVariable(name) => @parent.isInstanceVariable(name)
	isMethod() => true
	length() => @parameters.length
	name() => @name
	signature() {
		if @analysed {
			return @signature
		}
		else {
			this.prepare()
			
			return @signature
		}
	}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		if @parent._es5 {
			ctrl.code($class.methodHeader(@internalName, @parent) + '(')
		}
		else {
			ctrl.code('static ') if !@instance
			
			ctrl.code(@internalName + '(')
		}
		
		$function.parameters(this, ctrl, false, func(node) {
			return node.code(')').step()
		})
		
		for parameter in @parameters {
			if parameter._thisAlias && !$method.isUsingProperty($body(@data.body), parameter._name) {
				if parameter._setterAlias {
					if (@name != parameter._name || @signature.min != 1 || @signature.max != 1) && this.isInstanceMethod(parameter._name) {
						ctrl.newLine().code('this.' + parameter._name + '(').compile(parameter).code(')').done()
					}
					else {
						ReferenceException.throwNotDefinedMember(parameter._name, this)
					}
				}
				else {
					if this.isInstanceVariable(parameter._name) {
						ctrl.newLine().code('this.' + parameter._name + ' = ').compile(parameter).done()
					}
					else if this.isInstanceVariable('_' + parameter._name) {
						ctrl.newLine().code('this._' + parameter._name + ' = ').compile(parameter).done()
					}
					else if (@name != parameter._name || @signature.min != 1 || @signature.max != 1) && this.isInstanceMethod(parameter._name) {
						ctrl.newLine().code('this.' + parameter._name + '(').compile(parameter).code(')').done()
					}
					else {
						ReferenceException.throwNotDefinedMember(parameter._name, this)
					}
				}
			}
		}
		
		for statement in @statements {
			ctrl.compile(statement)
		}
		
		ctrl.done() unless @parent._es5
	} // }}}
}

class ClassConstructorDeclaration extends Statement {
	private {
		_internalName
		_parameters
		_signature
		_statements
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent._constructorScope))
		
		@internalName = `__ks_cons_\(parent._constructors.length)`
		
		parent._constructors.push(this)
		
		for parameter in @data.parameters {
			//console.log(Parameter.type(parameter, this))
			@parent.addReference($type.type(parameter.type, @scope, this), this)
		}
	} // }}}
	analyse() { // {{{
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
		
		@signature = Signature.fromNode(this)
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		let body = $body(@data.body)
		if @parent._extends && (!?@parent._extendsVariable.sealed || !@parent._extendsVariable.sealed.extern) {
			if body.length == 0 {
				this.callParentConstructor(body)
			}
			else if !this.isCallingParentConstructor(body) {
				SyntaxException.throwNoSuperCall(this)
			}
		}
		
		@statements = []
		for statement in body {
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
	private callParentConstructor(body) { // {{{
		// list maybe parent's variables
		const instanceVariables = @parent._variable.instanceVariables
		
		let parameters = [
			parameter
			for parameter in @parameters
			when	!parameter.isAnonymous() &&
					!parameter.isSetterAlias() &&
					!?instanceVariables[parameter.name()] &&
					!?instanceVariables[`_\(parameter.name())`]
		]
		
		if parameters.length == 0 {
			const constructors = @parent._extendsVariable.constructors
			
			if constructors.length != 0 {
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
	getAliasType(name, node) => @parent.getAliasType(name, node)
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}
		
		return false
	} // }}}
	private isCallingParentConstructor(body) { // {{{
		// walk body to find super call
		for statement in body {
			if statement.kind == NodeKind::CallExpression {
				if statement.callee.kind == NodeKind::Identifier && statement.callee.name == 'super' {
					return true
				}
			}
			else if statement.kind == NodeKind::IfStatement {
				throw new NotImplementedException(this)
			}
		}
		
		return false
	} // }}}
	isInstanceMethod(name) => @parent.isInstanceMethod(name)
	isInstanceVariable(name) => @parent.isInstanceVariable(name)
	isMethod() => true
	signature() => @signature
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		if @parent._es5 {
			ctrl.code($class.methodHeader(@internalName, @parent) + '(')
		}
		else {
			ctrl.code(@internalName + '(')
		}
		
		$function.parameters(this, ctrl, false, func(node) {
			return node.code(')').step()
		})
		
		for parameter in @parameters {
			if parameter._thisAlias && !$method.isUsingProperty($body(@data.body), parameter._name) {
				if parameter._setterAlias {
					if this.isInstanceMethod(parameter._name) {
						ctrl.newLine().code('this.' + parameter._name + '(').compile(parameter).code(')').done()
					}
					else {
						ReferenceException.throwNotDefinedMember(parameter._name, this)
					}
				}
				else {
					if this.isInstanceVariable(parameter._name) {
						ctrl.newLine().code('this.' + parameter._name + ' = ').compile(parameter).done()
					}
					else if this.isInstanceVariable('_' + parameter._name) {
						ctrl.newLine().code('this._' + parameter._name + ' = ').compile(parameter).done()
					}
					else if this.isInstanceMethod(parameter._name) {
						ctrl.newLine().code('this.' + parameter._name + '(').compile(parameter).code(')').done()
					}
					else {
						ReferenceException.throwNotDefinedMember(parameter._name, this)
					}
				}
			}
		}
		
		for statement in @statements {
			ctrl.compile(statement)
		}
		
		ctrl.done() unless @parent._es5
	} // }}}
}

class ClassDestructorDeclaration extends Statement {
	private {
		_internalName
		_parameters		= []
		_signature
		_statements
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent._destructorScope))
		
		@internalName = `__ks_destroy_0`
		
		parent._destructor = this
		
		parent._variable.destructors++
	} // }}}
	analyse() { // {{{
		const parameter = new Parameter({
			kind: NodeKind::Parameter
			modifiers: []
			name: $identifier('that')
		}, this)
		
		parameter.analyse()
		
		@parameters = [parameter]
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}
		
		@signature = Signature.fromNode(this)
	} // }}}
	translate() { // {{{
		@statements = []
		for statement in $body(@data.body) {
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
	getAliasType(name, node) => @parent.getAliasType(name, node)
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}
		
		return false
	} // }}}
	isInstance() => false
	isInstanceMethod(name) => @parent.isInstanceMethod(name)
	isInstanceVariable(name) => @parent.isInstanceVariable(name)
	isMethod() => true
	signature() => @signature
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		if @parent._es5 {
			ctrl.code($class.methodHeader(@internalName, @parent) + '(')
		}
		else {
			ctrl.code(`static \(@internalName)(`)
		}
		
		$function.parameters(this, ctrl, false, func(node) {
			return node.code(')').step()
		})
		
		for statement in @statements {
			ctrl.compile(statement)
		}
		
		ctrl.done() unless @parent._es5
	} // }}}
}

class ClassVariableDeclaration extends AbstractNode {
	private {
		_defaultValue			= null
		_hasDefaultValue		= false
		_instance: Boolean		= true
		_name
		_signature
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
		
		@parent.addReference($type.type(@data.type, @scope, this), this)
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
		@signature = $field.signature(@data, @parent)
		
		@defaultValue.prepare() if @defaultValue?
	} // }}}
	translate() { // {{{
		@defaultValue.translate() if @defaultValue?
	} // }}}
	hasDefaultValue() => @hasDefaultValue
	isInstance() => @instance
	name() => @name
	signature() => @signature
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
}