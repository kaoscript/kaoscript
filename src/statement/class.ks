enum MemberAccess { // {{{
	Private = 1
	Protected
	Public
} // }}}

enum HelperTypeKind { // {{{
	Native
	Referenced
	Unreferenced
} // }}}

const $class = {
	abstractMethod(node, fragments, statement, signature, parameters, reflect, name) { // {{{
		if !(reflect.abstractMethods[name] is Array) {
			reflect.abstractMethods[name] = []
		}
		let index = reflect.abstractMethods[name].length
		
		reflect.abstractMethods[name].push({
			signature: signature
			parameters: parameters
		})
	} // }}}
	areAbstractMethodsImplemented(variable, parent, scope) { // {{{
		for name, methods of parent.abstractMethods {
			return false unless ?variable.instanceMethods[name]
			
			for method in methods {
				return false unless $signature.match(method, variable.instanceMethods[name])
			}
		}
		
		if parent.extends? {
			return $class.areAbstractMethodsImplemented(variable, scope.getVariable(parent.extends), scope)
		}
		else {
			return true
		}
	} // }}}
	continuous(node, fragments) { // {{{
		let reflect = {
			abstract: node._abstract
			inits: 0
			constructors: []
			destructors: 0
			instanceVariables: node._instanceVariables
			classVariables: node._classVariables
			instanceMethods: {}
			classMethods: {}
			abstractMethods: {}
		}
		
		let noinit = KSType.isEmptyObject(node._instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of node._instanceVariables while noinit {
				if field.data.defaultValue {
					noinit = false
				}
			}
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
					$class.destructor(node, ctrl, node._destructor.statement, reflect)
					
					$helper.destructor(node, ctrl, reflect)
				}
				
				for name, methods of node._classMethods {
					for method in methods {
						$class.classMethod(node, ctrl, method.statement, method.signature, method.parameters, reflect, name)
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
				
				for name, field of node._instanceVariables when field.data.defaultValue? {
					ctrl
						.newLine()
						.code('this.' + name + ' = ')
						.compile(field.defaultValue)
						.done()
				}
				
				ctrl = clazz.newControl().code($class.methodHeader('__ks_init', node), '()').step()
				
				if node._extends {
					ctrl.line(node._extendsName + '.prototype.__ks_init.call(this)')
				}
				
				ctrl.line(node._name + '.prototype.__ks_init_1.call(this)')
			}
			
			for method in node._constructors {
				$class.constructor(node, clazz, method.statement, method.signature, method.parameters, reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
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
				
				for name, field of node._instanceVariables when field.data.defaultValue? {
					ctrl
						.newLine()
						.code('this.' + name + ' = ')
						.compile(field.defaultValue)
						.done()
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
				$class.constructor(node, clazz, method.statement, method.signature, method.parameters, reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			if node._destructor? {
				$class.destructor(node, clazz, node._destructor.statement, reflect)
				
				$helper.destructor(node, clazz, reflect)
			}
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
				}
			}
			
			for name, methods of node._classMethods {
				for method in methods {
					$class.classMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
				}
				
				$helper.classMethod(node, clazz, reflect, name)
			}
			
			clazz.done()
		}
		
		return reflect
	} // }}}
	classMethod(node, fragments, statement, signature, parameters, reflect, name) { // {{{
		if !(reflect.classMethods[name] is Array) {
			reflect.classMethods[name] = []
		}
		let index = reflect.classMethods[name].length
		
		reflect.classMethods[name].push({
			signature: signature
			parameters: parameters
		})
		
		statement
			.name('__ks_sttc_' + name + '_' + index)
			.toFragments(fragments, Mode::None)
	} // }}}
	constructor(node, fragments, statement, signature, parameters, reflect) { // {{{
		let index = reflect.constructors.length
		
		reflect.constructors.push({
			signature: signature
			parameters: parameters
		})
	
		statement
			.name('__ks_cons_' + index)
			.toFragments(fragments, Mode::None)
	} // }}}
	destructor(node, fragments, statement, reflect) { // {{{
		statement
			.name('__ks_destroy_' + reflect.destructors)
			.toFragments(fragments, Mode::None)
		
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
	instanceMethod(node, fragments, statement, signature, parameters, reflect, name) { // {{{
		if !(reflect.instanceMethods[name] is Array) {
			reflect.instanceMethods[name] = []
		}
		let index = reflect.instanceMethods[name].length
		
		reflect.instanceMethods[name].push({
			signature: signature
			parameters: parameters
		})
		
		statement
			.name('__ks_func_' + name + '_' + index)
			.toFragments(fragments, Mode::None)
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
			instanceVariables: node._instanceVariables
			classVariables: node._classVariables
			instanceMethods: {}
			classMethods: {}
			abstractMethods: {}
		}
		
		let noinit = KSType.isEmptyObject(node._instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of node._instanceVariables while noinit {
				if field.data.defaultValue {
					noinit = false
				}
			}
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
					$class.destructor(node, ctrl, node._destructor.statement, reflect)
					
					$helper.destructor(node, ctrl, reflect)
				}
				
				for name, methods of node._classMethods {
					for method in methods {
						$class.classMethod(node, ctrl, method.statement, method.signature, method.parameters, reflect, name)
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
					for name, field of node._instanceVariables when field.data.defaultValue? {
						ctrl
							.newLine()
							.code('this.' + name + ' = ')
							.compile(field.defaultValue)
							.done()
					}
				}
			}
			else {
				ctrl = clazz
					.newControl()
					.code($class.methodHeader('$create', node), '()')
					.step()
			
				if !noinit {
					for name, field of node._instanceVariables when field.data.defaultValue? {
						ctrl
							.newLine()
							.code('this.' + name + ' = ')
							.compile(field.defaultValue)
							.done()
					}
				}
				
				ctrl.line('this.__ks_cons(arguments)')
			}
			
			for method in node._constructors {
				$class.constructor(node, clazz, method.statement, method.signature, method.parameters, reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
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
					for name, field of node._instanceVariables when field.data.defaultValue? {
						ctrl
							.newLine()
							.code('this.' + name + ' = ')
							.compile(field.defaultValue)
							.done()
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
					for name, field of node._instanceVariables when field.data.defaultValue? {
						ctrl
							.newLine()
							.code('this.' + name + ' = ')
							.compile(field.defaultValue)
							.done()
					}
				}
				
				ctrl.line('this.__ks_cons(arguments)')
				
				ctrl.done()
			}
			
			for method in node._constructors {
				$class.constructor(node, clazz, method.statement, method.signature, method.parameters, reflect)
			}
			
			$helper.constructor(node, clazz, reflect)
			
			if node._destructor? {
				$class.destructor(node, clazz, node._destructor.statement, reflect)
				
				$helper.destructor(node, clazz, reflect)
			}
			
			for name, methods of node._instanceMethods {
				for method in methods {
					$class.instanceMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
				}
				
				$helper.instanceMethod(node, clazz, reflect, name)
			}
			
			for name, methods of node._abstractMethods {
				for method in methods {
					$class.abstractMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
				}
			}
			
			for name, methods of node._classMethods {
				for method in methods {
					$class.classMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
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
			access: MemberAccess::Public
		}
		
		if data.modifiers {
			for modifier in data.modifiers {
				if modifier.kind == ModifierKind::Private {
					signature.access = MemberAccess::Private
				}
				else if modifier.kind == ModifierKind::Protected {
					signature.access = MemberAccess::Protected
				}
			}
		}
		
		signature.type = type if data.type && (type ?= $signature.type(data.type, node.scope()))
		
		return signature
	} // }}}
}

const $helper = {
	analyseType(type = null, node) { // {{{
		if !?type {
			return {
				kind: HelperTypeKind::Native
				type: 'Any'
			}
		}
		else if type is Array {
			return [$helper.analyseType(t, node) for t in type]
		}
		else if type == 'Any' || type == '...'  || $typeofs[type] {
			return {
				kind: HelperTypeKind::Native
				type: type
			}
		}
		else {
			if variable ?= $variable.fromReflectType(type, node) {
				return {
					kind: HelperTypeKind::Referenced
					type: type
				}
			}
			else {
				return {
					kind: HelperTypeKind::Unreferenced
					type: type
				}
			}
		}
	} // }}}
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
			method = methods[0].signature
			
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
				method = methods[index].signature
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
				methods: [methods[i].signature for i in type.methods]
				usage: type.methods.length
			})
			
			if name == 'Any' {
				item.weight = 0
			}
			else {
				item.weight = 1_000
			}
			
			for i in type.methods {
				method = methods[i].signature
				
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
			$helper.reflectMethod(node, a.newLine(), reflect.constructors[i].signature, reflect.constructors[i].parameters, classname + '.__ks_reflect.constructors[' + i + ']')
		}
		a.done()
		
		object.line('destructors: ', reflect.destructors)
		
		o = object.newLine().code('instanceVariables: ').newObject()
		for name, variable of reflect.instanceVariables {
			$helper.reflectVariable(node, o.newLine(), name, variable.signature, variable.type, classname + '.__ks_reflect.instanceVariables.' + name)
		}
		o.done()
		
		o = object.newLine().code('classVariables: ').newObject()
		for name, variable of reflect.classVariables {
			$helper.reflectVariable(node, o.newLine(), name, variable.signature, variable.type, classname + '.__ks_reflect.classVariables.' + name)
		}
		o.done()
		
		o = object.newLine().code('instanceMethods: ').newObject()
		for name, methods of reflect.instanceMethods {
			a = o.newLine().code(name + ': ').newArray()
			
			for i from 0 til methods.length {
				$helper.reflectMethod(node, a.newLine(), methods[i].signature, methods[i].parameters, classname + '.__ks_reflect.instanceMethods.' + name + '[' + i + ']')
			}
			
			a.done()
		}
		o.done()
		
		o = object.newLine().code('classMethods: ').newObject()
		for name, methods of reflect.classMethods {
			a = o.newLine().code(name + ': ').newArray()
			
			for i from 0 til methods.length {
				$helper.reflectMethod(node, a.newLine(), methods[i].signature, methods[i].parameters, classname + '.__ks_reflect.classMethods.' + name + '[' + i + ']')
			}
			
			a.done()
		}
		o.done()
		
		object.done()
		
		line.done()
	} // }}}
	reflectMethod(node, fragments, signature, parameters, path = null) { // {{{
		let object = fragments.newObject()
		
		object.newLine().code('access: ' + signature.access)
		object.newLine().code('min: ' + signature.min)
		object.newLine().code('max: ' + (signature.max == Infinity ? 'Infinity' : signature.max))
		
		let array = object.newLine().code('parameters: ').newArray()
		
		for i from 0 til signature.parameters.length {
			$helper.reflectParameter(node, array.newLine(), signature.parameters[i], parameters[i], path + '.parameters[' + i + ']')
		}
		
		array.done()
		
		object.done()
	} // }}}
	reflectParameter(node, fragments, signature, type, path = null) { // {{{
		let object = fragments.newObject()
		
		object.newLine().code('type: ' + $helper.type(type, node, path))
		object.newLine().code('min: ' + signature.min)
		object.newLine().code('max: ' + signature.max)
		
		object.done()
	} // }}}
	reflectVariable(node, fragments, name, signature, type = null, path = null) { // {{{
		let object = fragments.code(name, ': ').newObject()
		
		object.line('access: ' + signature.access)
		
		if type? {
			object.line('type: ' + $helper.type(type, node, path))
		}
		
		object.done()
	} // }}}
	type(type, node, path = null) { // {{{
		if type is Array {
			let src = ''
			
			for i from 0 til type.length {
				if i {
					src += ','
				}
				
				src += $helper.type(type[i], node, path)
			}
			
			return '[' + src + ']'
		}
		else if type.kind == HelperTypeKind::Native {
			return $quote(type.type)
		}
		else if type.kind == HelperTypeKind::Referenced {
			return type.type
		}
		else if type.kind == HelperTypeKind::Unreferenced {
			if path? {
				node.module().addReference(type.type, path + '.type = ' + type.type)
				
				return $quote('#' + type.type)
			}
			else {
				TypeException.throwInvalid(type.type, node)
			}
		}
	} // }}}
}

const $method = {
	isConstructor(name, variable) => name == 'constructor'
	isDestructor(name, variable) => name == 'destructor'
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
	signature(data, node) { // {{{
		let signature = {
			access: MemberAccess::Public
			min: 0,
			max: 0,
			parameters: []
			throws: data.throws ? [t.name for t in data.throws] : []
		}
		
		if data.modifiers {
			for modifier in data.modifiers {
				if modifier.kind == ModifierKind::Async {
					signature.async = true
				}
				else if modifier.kind == ModifierKind::Private {
					signature.access = MemberAccess::Private
				}
				else if modifier.kind == ModifierKind::Protected {
					signature.access = MemberAccess::Protected
				}
			}
		}
		
		let type, last, nf
		for parameter in data.parameters {
			type = $parameter.type(parameter, node)
			
			if !last || !$method.sameType(type, last.type) {
				if last {
					signature.min += last.min
					signature.max += last.max
				}
				
				last = {
					type: type,
					min: parameter.defaultValue? ? 0 : 1,
					max: 1
				}
				
				if parameter.modifiers {
					for modifier in parameter.modifiers {
						if modifier.kind == ModifierKind::Rest {
							if modifier.arity {
								last.min += modifier.arity.min
								last.max += modifier.arity.max
							}
							else {
								last.max = Infinity
							}
						}
					}
				}
				
				signature.parameters.push(last)
			}
			else {
				nf = true
				
				if parameter.modifiers {
					for modifier in parameter.modifiers {
						if modifier.kind == ModifierKind::Rest {
							if modifier.arity {
								last.min += modifier.arity.min
								last.max += modifier.arity.max
							}
							else {
								last.max = Infinity
							}
							
							nf = false
						}
					}
				}
				
				if nf {
					if !?parameter.defaultValue {
						++last.min
					}
					
					++last.max
				}
			}
		}
		
		if last {
			signature.min += last.min
			signature.max += last.max
		}
		
		return signature
	} // }}}
}

const $parameter = {
	type(data, node) { // {{{
		if data.name? {
			let nf = true
			let name = data.name.name
			
			for modifier in data.modifiers while nf {
				if modifier.kind == ModifierKind::Alias {
					if variable ?= node.getInstanceVariable(name) {
						return variable.type if variable.type?
					}
					else if variable ?= node.getInstanceVariable('_' + name) {
						return variable.type if variable.type?
					}
					else if variable ?= node.getInstanceMethod(name) {
						return variable.type if variable.type?
					}
					else {
						ReferenceException.throwNotDefinedMember(name, node)
					}
					
					nf = false
				}
			}
		}
		
		return $signature.type(data.type, node.scope())
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
		let data = @data
		let scope = @scope
		
		@name = data.name.name
		@variable = $variable.define(this, scope, data.name, VariableKind::Class, data.type)
		
		let classname = data.name
		
		let thisVariable = $variable.define(this, @constructorScope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(classname.name))
		
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
		}, VariableKind::Variable, $type.reference(classname.name))
		
		@destructorScope.rename('this', 'that')
		
		$variable.define(this, @instanceVariableScope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(classname.name))
		
		if data.extends? {
			@extends = true
			
			if @extendsVariable !?= @scope.getVariable(data.extends.name) {
				ReferenceException.throwNotDefined(data.extends.name, this)
			}
			else if @extendsVariable.kind != VariableKind::Class {
				TypeException.throwNotClass(data.extends.name, this)
			}
			
			@variable.extends = @extendsName = data.extends.name
			
			let extname = data.extends
			
			let superVariable = $variable.define(this, @constructorScope, {
				kind: NodeKind::Identifier
				name: 'super'
			}, VariableKind::Variable)
			
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
			}, VariableKind::Variable)
		}
		
		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@variable.abstract = @abstract = true
				
				@variable.abstractMethods = {}
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true
			}
		}
		
		let signature, method
		for member in data.members {
			switch member.kind {
				NodeKind::CommentBlock => {
				}
				NodeKind::CommentLine => {
				}
				NodeKind::FieldDeclaration => {
					let instance = true
					for i from 0 til member.modifiers.length while instance {
						if member.modifiers[i].kind == ModifierKind::Static {
							instance = false
						}
					}
					
					signature = $field.signature(member, this)
					
					let variable = {
						data: member
						signature: signature
						type: $helper.analyseType(signature.type, this)
					}
					
					if member.defaultValue? {
						@scope = @instanceVariableScope if instance
						
						variable.defaultValue = $compile.expression(member.defaultValue, this)
						
						@scope = scope if instance
					}
					
					if instance {
						@instanceVariables[member.name.name] = variable
						
						@variable.instanceVariables[member.name.name] = signature
					}
					else if member.name.name == 'name' || member.name.name == 'version' {
						SyntaxException.throwReservedClassVariable(member.name.name, this)
					}
					else {
						@classVariables[member.name.name] = variable
						
						@variable.classVariables[member.name.name] = signature
					}
				}
				NodeKind::MethodDeclaration => {
					if $method.isConstructor(member.name.name, @variable) {
						@scope = @constructorScope
						
						method = $compile.statement(member, this)
						
						signature = $method.signature(member, this)
						
						@constructors.push({
							data: member
							signature: signature
							statement: method
							parameters: [$helper.analyseType(parameter.type, this) for parameter in signature.parameters]
						})
						
						@variable.constructors.push(signature)
						
						@scope = scope
					}
					else if $method.isDestructor(member.name.name, @variable) {
						@scope = @destructorScope
						
						member.parameters.push({
							kind: NodeKind::Parameter
							modifiers: []
							name: $identifier('that')
						})
						
						method = $compile.statement(member, this)
						
						method.instance(false)
						
						@destructor = {
							data: member
							statement: method
						}
						
						@variable.destructors++
						
						@scope = scope
					}
					else {
						let instance = true
						for i from 0 til member.modifiers.length while instance {
							if member.modifiers[i].kind == ModifierKind::Static {
								instance = false
							}
						}
						
						@scope = this.newInstanceMethodScope(data, member) if instance
						
						signature = $method.signature(member, this)
						
						method = {
							data: member,
							signature: signature
							statement: $compile.statement(member, this)
							parameters: [$helper.analyseType(parameter.type, this) for parameter in signature.parameters]
						}
						
						if instance {
							if method.statement.isAbstract() {
								if @abstract {
									if !(@abstractMethods[member.name.name] is Array) {
										@abstractMethods[member.name.name] = []
										@variable.abstractMethods[member.name.name] = []
									}
									
									@abstractMethods[member.name.name].push(method)
									
									@variable.abstractMethods[member.name.name].push(signature)
								}
								else {
									SyntaxException.throwNotAbstractClass(@name, member.name.name, this)
								}
							}
							else {
								if !(@instanceMethods[member.name.name] is Array) {
									@instanceMethods[member.name.name] = []
									@variable.instanceMethods[member.name.name] = []
								}
								
								@instanceMethods[member.name.name].push(method)
								
								@variable.instanceMethods[member.name.name].push(signature)
							}
							
							@scope = scope
						}
						else if member.name.name == 'name' || member.name.name == 'version' {
							SyntaxException.throwReservedClassMethod(member.name.name, this)
						}
						else {
							method.statement.instance(false)
							
							if !(@classMethods[member.name.name] is Array) {
								@classMethods[member.name.name] = []
								@variable.classMethods[member.name.name] = []
							}
							
							@classMethods[member.name.name].push(method)
							
							@variable.classMethods[member.name.name].push(signature)
						}
					}
				}
				=> {
					throw new NotSupportedException(`Unknow kind \(member.kind)`, this)
				}
			}
		}
		
		if @extends && !@abstract && !$class.areAbstractMethodsImplemented(@variable, @extendsVariable, @scope) {
			SyntaxException.throwMissingAbstractMethods(@name, this)
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
	fuse() { // {{{
		for method in this._constructors {
			method.statement.analyse()
		}
		
		this._destructor.statement.analyse() if this._destructor?
		
		for name, methods of this._instanceMethods {
			for method in methods {
				method.statement.analyse()
			}
		}
		
		for name, methods of this._classMethods {
			for method in methods {
				method.statement.analyse()
			}
		}
		
		for name, variable of this._instanceVariables when variable.defaultValue? {
			variable.defaultValue.fuse()
		}
		
		for name, variable of this._classVariables when variable.defaultValue? {
			variable.defaultValue.fuse()
		}
		
		for method in this._constructors {
			method.statement.fuse()
		}
		
		this._destructor.statement.fuse() if this._destructor?
		
		for name, methods of this._instanceMethods {
			for method in methods {
				method.statement.fuse()
			}
		}
		
		for name, methods of this._classMethods {
			for method in methods {
				method.statement.fuse()
			}
		}
	} // }}}
	getInstanceMethod(name, variable = @variable) { // {{{
		if variable.instanceMethods[name]?['1']? {
			throw new NotImplementedException()
		}
		else if variable.extends? {
			return this.getInstanceMethod(name, @scope.getVariable(variable.extends))
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
	newInstanceMethodScope(data, member) { // {{{
		let scope = new Scope(this._scope)
		
		$variable.define(this, scope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(data.name.name))
		
		if this._extends {
			let variable = $variable.define(this, scope, {
				kind: NodeKind::Identifier
				name: 'super'
			}, VariableKind::Variable)
			
			if this._es5 {
				let extname = this._data.extends
				
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
							property: member.name
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
						property: member.name
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
		
		for name, field of @classVariables when field.defaultValue? {
			fragments
				.newLine()
				.code(`\(@name).\(name) = `)
				.compile(field.defaultValue)
				.done()
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
}

class MethodDeclaration extends Statement {
	private {
		_name
		_parameters
		_signature
		_statements
		_instance		= true
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@parameters = [new Parameter(parameter, this) for parameter in this._data.parameters]
		
		if @data.body? {
			@statements = [$compile.statement(statement, this) for statement in $body(@data.body)]
		}
		else {
			@statements = []
		}
	} // }}}
	fuse() { // {{{
		this.compile(@parameters)
		
		this.compile(@statements)
		
		@signature = new Signature(this)
	} // }}}
	getInstanceMethod(name) => @parent.getInstanceMethod(name)
	getInstanceVariable(name) => @parent.getInstanceVariable(name)
	instance(@instance) => this
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}
		
		return false
	} // }}}
	isConsumedError(name, variable): Boolean { // {{{
		if @data.throws.length > 0 {
			for x in @data.throws {
				return true if $error.isConsumed(x.name, name, variable, @scope)
			}
		}
		
		return false
	} // }}}
	isInstanceMethod(name) => @parent.isInstanceMethod(name)
	isInstanceVariable(name) => @parent.isInstanceVariable(name)
	isMethod() => true
	name(@name) => this
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		if @parent._es5 {
			ctrl.code($class.methodHeader(@name, @parent) + '(')
		}
		else {
			ctrl.code('static ') if !@instance
			
			ctrl.code(@name + '(')
		}
		
		$function.parameters(this, ctrl, func(node) {
			return node.code(')').step()
		})
		
		let nf, modifier, name
		for parameter, p in @data.parameters {
			nf = true
			
			for modifier in parameter.modifiers while nf {
				if modifier.kind == ModifierKind::Alias {
					name = parameter.name.name
					
					if this.isInstanceVariable(name) {
						ctrl.newLine().code('this.' + name + ' = ').compile(@parameters[p]).done()
					}
					else if this.isInstanceVariable('_' + name) {
						ctrl.newLine().code('this._' + name + ' = ').compile(@parameters[p]).done()
					}
					else if this.isInstanceMethod(name) {
						ctrl.newLine().code('this.' + name + '(').compile(@parameters[p]).code(')').done()
					}
					else {
						ReferenceException.throwNotDefinedMember(name, this)
					}
					
					nf = false
				}
			}
		}
		
		for statement in @statements {
			ctrl.compile(statement)
		}
		
		ctrl.done() unless @parent._es5
	} // }}}
}