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
	continuous(node, fragments) { // {{{
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
		
		let reflect = {
			inits: 0
			constructors: []
			destructors: 0
			instanceVariables: node._instanceVariables
			classVariables: node._classVariables
			instanceMethods: {}
			classMethods: {}
		}
		
		let noinit = Type.isEmptyObject(node._instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of node._instanceVariables while noinit {
				if field.data.defaultValue {
					noinit = false
				}
			}
		}
		
		if noinit {
			if node._extends {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.line(node._extendsName + '.prototype.__ks_init.call(this)')
					.done()
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
		
		for name, methods of node._classMethods {
			for method in methods {
				$class.classMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
			}
			
			$helper.classMethod(node, clazz, reflect, name)
		}
		
		clazz.done()
		
		for name, field of node._classVariables when field.defaultValue? {
			fragments
				.newLine()
				.code(`\(node._name).\(name) = `)
				.compile(field.defaultValue)
				.done()
		}
		
		$helper.reflect(node, fragments, reflect)
		
		if references ?= node.module().listReferences(node._name) {
			for ref in references {
				fragments.line(ref)
			}
		}
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
			.name('static __ks_sttc_' + name + '_' + index)
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
			.name('static __ks_destroy_' + reflect.destructors)
			.toFragments(fragments, Mode::None)
		
		reflect.destructors++
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
	sealed(node, fragments) { // {{{
		let clazz = fragments
			.newControl()
			.code('class ', node._name)
		
		if node._extends {
			clazz.code(' extends ', node._extendsName)
		}
		
		clazz.step()
		
		let noinit = Type.isEmptyObject(node._instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of node._instanceVariables while noinit {
				if field.data.defaultValue {
					noinit = false
				}
			}
		}
		
		let ctrl
		if node._extends {
			ctrl = fragments
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
		
		let reflect = {
			sealed: true
			inits: 0
			constructors: []
			destructors: 0
			instanceVariables: node._instanceVariables
			classVariables: node._classVariables
			instanceMethods: {}
			classMethods: {}
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
		
		for name, methods of node._classMethods {
			for method in methods {
				$class.classMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
			}
			
			$helper.classMethod(node, clazz, reflect, name)
		}
		
		clazz.done()
		
		for name, field of node._classVariables when field.defaultValue? {
			fragments
				.newLine()
				.code(`\(node._name).\(name) = `)
				.compile(field.defaultValue)
				.done()
		}
		
		$helper.reflect(node, fragments, reflect)
		
		if references ?= node.module().listReferences(node._name) {
			for ref in references {
				fragments.line(ref)
			}
		}
	} // }}}
}

const $field = {
	signature(data, node) { // {{{
		let signature = {
			access: MemberAccess::Public
		}
		
		if data.modifiers {
			for modifier in data.modifiers {
				if modifier.kind == MemberModifier::Private {
					signature.access = MemberAccess::Private
				}
				else if modifier.kind == MemberModifier::Protected {
					signature.access = MemberAccess::Protected
				}
			}
		}
		
		signature.type = type if data.type && (type ?= $signature.type(data.type, node.scope()))
		
		return signature
	} // }}}
}

const $helper = {
	analyseType(type?, node) { // {{{
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
						.code('return ' + node._extendsName + '.' + name + '.apply(null, arguments)')
						.done()
					
					fragments.line('throw new Error("Wrong number of arguments")')
				}
			}
		}
		
		$helper.methods(extend, node, fragments.newControl(), 'static ' + name + '()', reflect.classMethods[name], $class.methodCall^^(node, '__ks_sttc_' + name + '_', 'arguments', 'return '), 'arguments', 'classMethods.' + name, true)
	} // }}}
	constructor(node, fragments, reflect) { // {{{
		let extend = false
		if node._extends {
			extend = func(node, fragments, ctrl?) {
				if ctrl? {
					ctrl
						.step()
						.code('else')
						.step()
						.line(node._extendsName + '.prototype.__ks_cons.call(this, args)')
						.done()
				}
				else {
					fragments.line(node._extendsName + '.prototype.__ks_cons.call(this, args)')
				}
			}
		}
		
		$helper.methods(extend, node, fragments.newControl(), '__ks_cons(args)', reflect.constructors, $class.methodCall^^(node, 'prototype.__ks_cons_', 'args', ''), 'args', 'constructors', false)
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
		
		ctrl.code('static __ks_destroy(that)').step()
		
		if node._extends {
			ctrl.line(`\(node._extendsName).__ks_destroy(that)`)
		}
		
		for i from 0 til reflect.destructors {
			ctrl.line(`\(node._name).__ks_destroy_\(i)(that)`)
		}
		
		ctrl.done()
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
					
					fragments.line('throw new Error("Wrong number of arguments")')
				}
			}
		}
		
		$helper.methods(extend, node, fragments.newControl(), name + '()', reflect.instanceMethods[name], $class.methodCall^^(node, 'prototype.__ks_func_' + name + '_', 'arguments', 'return '), 'arguments', 'instanceMethods.' + name, true)
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
					.line('throw new Error("Wrong number of arguments")')
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
						
						fragments.line('throw new Error("Wrong number of arguments")')
					}
				}
				else {
					if extend {
						extend(node, fragments, ctrl)
					}
					else {
						ctrl.step().code('else').step().line('throw new Error("Wrong number of arguments")').done()
					}
				}
			}
			else if method.max < Infinity {
				let ctrl = fragments.newControl()
				
				ctrl.code('if(' + argName + '.length >= ' + method.min + ' && ' + argName + '.length <= ' + method.max + ')').step()
				
				call(ctrl, method, 0)
				
				if returns {
					ctrl.done()
					
					fragments.line('throw new Error("Wrong number of arguments")')
				}
				else {
					ctrl.step().code('else').step().line('throw new Error("Wrong number of arguments")').done()
				}
			}
			else {
				call(fragments, method, 0)
			}
		}
		else {
			let groups = []
			
			let nf, group
			for index from 0 til methods.length {
				method = methods[index].signature
				method.index = index
				
				nf = true
				for group in groups while nf {
					if (method.min <= group.min && method.max >= group.min) || (method.min >= group.min && method.max <= group.max) || (method.min <= group.max && method.max >= group.max) {
						nf = false
					}
				}
				
				if nf {
					groups.push({
						min: method.min,
						max: method.max,
						methods: [method]
					})
				}
				else {
					group.min = Math.min(group.min, method.min)
					group.max = Math.max(group.max, method.max)
					group.methods.push(method)
				}
			}
			
			let ctrl = fragments.newControl()
			nf = true
			
			for group in groups {
				if group.min == group.max {
					ctrl.step().code('else ') if !ctrl.isFirstStep()
					
					ctrl.code('if(' + argName + '.length === ' + group.min + ')').step()
					
					if group.methods.length == 1 {
						call(ctrl, group.methods[0], group.methods[0].index)
					}
					else {
						$helper.methodCheck(node, ctrl, group, call, argName, refName, returns)
					}
				}
				else if group.max < Infinity {
					ctrl.step().code('else ') if !ctrl.isFirstStep()
					
					ctrl.code('if(' + argName + '.length >= ' + group.min + ' && arguments.length <= ' + group.max + ')').step()
					
					if group.methods.length == 1 {
						call(ctrl, group.methods[0], group.methods[0].index)
					}
					else {
						$helper.methodCheck(node, ctrl, group, call, argName, refName, returns)
					}
				}
				else {
					ctrl.step().code('else').step() if !ctrl.isFirstStep()
					
					nf = false
					
					if group.methods.length == 1 {
						call(ctrl, group.methods[0], group.methods[0].index)
					}
					else {
						$helper.methodCheck(node, ctrl, group, call, argName, refName, returns)
					}
				}
			}
			
			if nf {
				if returns {
					ctrl.done()
					
					fragments.line('throw new Error("Wrong number of arguments")')
				}
				else {
					ctrl.step().code('else').step().line('throw new Error("Wrong number of arguments")').done()
				}
			}
			else {
				ctrl.done()
			}
		}
		
		fragments.done()
	} // }}}
	methodCheck(node, fragments, group, call, argName, refName, returns) { // {{{
		if $helper.methodCheckTree(group.methods, 0, node, fragments, call, argName, refName, returns) {
			if returns {
				fragments.line('throw new Error("Wrong type of arguments")')
			}
			else {
				fragments.step().code('else').step().code('throw new Error("Wrong type of arguments")')
			}
		}
	} // }}}
	methodCheckTree(methods, index, node, fragments, call, argName, refName, returns) { // {{{
		//console.log(index)
		//console.log(JSON.stringify(methods, null, 2))
		let tree = []
		let usages = []
		
		let types, usage, type, nf, t, item
		for i from 0 til methods.length {
			types = $helper.methodTypes(methods[i], index)
			usage = {
				method: methods[i],
				usage: 0,
				tree: []
			}
			
			for type in types {
				nf = true
				for tt in tree while nf {
					if $method.sameType(type.type, tt.type) {
						tt.methods.push(methods[i])
						nf = false
					}
				}
				
				if nf {
					item = {
						type: type.type,
						path: 'this.constructor.__ks_reflect.' + refName + '[' + methods[i].index + '].parameters[' + type.index + ']' + type.path,
						methods: [methods[i]]
					}
					
					tree.push(item)
					usage.tree.push(item)
					
					++usage.usage
				}
			}
			
			usages.push(usage)
		}
		
		if tree.length == 1 {
			let item = tree[0]
			
			if item.methods.length == 1 {
				call(fragments, item.methods[0], item.methods[0].index)
				
				return false
			}
			else {
				return $helper.methodCheckTree(item.methods, index + 1, node, fragments, call, argName, refName, returns)
			}
		}
		else {
			let ctrl = fragments.newControl()
			let ne = true
			
			usages.sort(func(a, b) {
				return a.usage - b.usage
			})
			//console.log(JSON.stringify(usages, null, 2))
			
			for usage, u in usages {
				if usage.tree.length == usage.usage {
					item = usage.tree[0]
					
					if u + 1 == usages.length {
						if !ctrl.isFirstStep() {
							ctrl.step().code('else')
							
							ne = false
						}
					}
					else {
						ctrl.step().code('else') if !ctrl.isFirstStep()
						
						ctrl.code('if(')
						
						$helper.decide(node, ctrl, item.type, index, item.path, argName)
						
						ctrl.code(')')
					}
					
					ctrl.step()
					
					if item.methods.length == 1 {
						call(ctrl, item.methods[0], item.methods[0].index)
					}
					else {
						$helper.methodCheckTree(item.methods, index + 1, node, ctrl, call, argName, refName, returns)
					}
				}
				else {
					$throw('Not Implemented', node)
				}
			}
			
			ctrl.done()
			
			return ne
		}
	} // }}}
	methodTypes(method, index) { // {{{
		let types = []
		
		let k = -1
		
		let parameter
		for parameter, i in method.parameters when k < index {
			if k + parameter.max >= index {
				if parameter.type is Array {
					for j from 0 til parameter.type.length {
						types.push({
							type: parameter.type[j],
							index: i,
							path: '.type[' + j + ']'
						})
					}
				}
				else {
					types.push({
						type: parameter.type,
						index: i,
						path: '.type'
					})
				}
			}
			
			k += parameter.min
		}
		
		return types
	} // }}}
	reflect(node, fragments, reflect) { // {{{
		let classname = node._name
		
		let line = fragments.newLine()
		
		line.code(classname + '.__ks_reflect = ')
		
		let object = line.newObject()
		
		if reflect.sealed {
			object.line('sealed: true')
		}
		
		object.newLine().code('inits: ' + reflect.inits)
		
		a = object.newLine().code('constructors: ').newArray()
		for i from 0 til reflect.constructors.length {
			$helper.reflectMethod(node, a.newLine(), reflect.constructors[i].signature, reflect.constructors[i].parameters, classname + '.__ks_reflect.constructors[' + i + '].type')
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
	reflectMethod(node, fragments, signature, parameters, path?) { // {{{
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
	reflectParameter(node, fragments, signature, type, path?) { // {{{
		let object = fragments.newObject()
		
		object.newLine().code('type: ' + $helper.type(type, node, path))
		object.newLine().code('min: ' + signature.min)
		object.newLine().code('max: ' + signature.max)
		
		object.done()
	} // }}}
	reflectVariable(node, fragments, name, signature, type?, path?) { // {{{
		let object = fragments.code(name, ': ').newObject()
		
		object.line('access: ' + signature.access)
		
		if type? {
			object.line('type: ' + $helper.type(type, node, path))
		}
		
		object.done()
	} // }}}
	type(type, node, path?) { // {{{
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
				$throw(`Invalid type \(type.type)`, node)
			}
		}
	} // }}}
}

const $method = {
	isConstructor(name, variable) => name == '$create'
	isDestructor(name, variable) => name == '$destroy'
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
		}
		
		if data.modifiers {
			for modifier in data.modifiers {
				if modifier.kind == FunctionModifier.Async {
					signature.async = true
				}
				else if modifier.kind == MemberModifier::Private {
					signature.access = MemberAccess::Private
				}
				else if modifier.kind == MemberModifier::Protected {
					signature.access = MemberAccess::Protected
				}
			}
		}
		
		let type, last, nf
		for parameter in data.parameters {
			type = $signature.type(parameter.type, node.scope())
			
			if !last || !$method.sameType(type, last.type) {
				if last {
					signature.min += last.min
					signature.max += last.max
				}
				
				last = {
					type: $signature.type(parameter.type, node.scope()),
					min: parameter.defaultValue || (parameter.type && parameter.type.nullable) ? 0 : 1,
					max: 1
				}
				
				if parameter.modifiers {
					for modifier in parameter.modifiers {
						if modifier.kind == ParameterModifier.Rest {
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
						if modifier.kind == ParameterModifier.Rest {
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
					if !(parameter.defaultValue || (parameter.type && parameter.type.nullable)) {
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

class ClassDeclaration extends Statement {
	private {
		_classMethods		= {}
		_classVariables		= {}
		_constructors		= []
		_constructorScope
		_destructor			= null
		_destructorScope
		_extends
		_extendsName
		_extendsVariable
		_sealed 			= false
		_instanceMethods	= {}
		_instanceVariables	= {}
		_instanceVariableScope
		_name
		_variable
	}
	$create(data, parent) { // {{{
		super(data, parent)
		
		this._constructorScope = new Scope(parent.scope())
		this._destructorScope = new Scope(parent.scope())
		this._instanceVariableScope = new Scope(parent.scope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		let scope = this._scope
		
		this._name = data.name.name
		this._variable = $variable.define(this, scope, data.name, VariableKind::Class, data.type)
		
		let classname = data.name
		
		let thisVariable = $variable.define(this, this._constructorScope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(classname.name))
		
		thisVariable.callable = func(data) {
			data.arguments = [{
				kind: Kind::Identifier
				name: 'this'
			}, {
				kind: Kind::ArrayExpression
				values: data.arguments
			}]
			
			data.callee = {
				kind: Kind::MemberExpression
				object: {
					kind: Kind::MemberExpression
					object: {
						kind: Kind::MemberExpression
						object: classname
						property: {
							kind: Kind::Identifier
							name: 'prototype'
						}
						computed: false
						nullable: false
					}
					property: {
						kind: Kind::Identifier
						name: '__ks_cons'
					}
					computed: false
					nullable: false
				}
				property: {
					kind: Kind::Identifier
					name: 'call'
				}
				computed: false
				nullable: false
			}
		}
		
		thisVariable = $variable.define(this, this._destructorScope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(classname.name))
		
		this._destructorScope.rename('this', 'that')
		
		$variable.define(this, this._instanceVariableScope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(classname.name))
		
		if this._extends = data.extends? {
			if !(this._extendsVariable ?= this._scope.getVariable(data.extends.name)) {
				$throw(`Undefined class \(data.extends.name) at line \(data.extends.start.line)`, this)
			}
			
			this._extendsName = data.extends.name
			
			let extname = data.extends
			
			let superVariable = $variable.define(this, this._constructorScope, {
				kind: Kind::Identifier
				name: 'super'
			}, VariableKind::Variable)
			
			superVariable.callable = func(data) {
				data.arguments = [{
					kind: Kind::Identifier
					name: 'this'
				}, {
					kind: Kind::ArrayExpression
					values: data.arguments
				}]
				
				data.callee = {
					kind: Kind::MemberExpression
					object: {
						kind: Kind::MemberExpression
						object: {
							kind: Kind::MemberExpression
							object: extname
							property: {
								kind: Kind::Identifier
								name: 'prototype'
							}
							computed: false
							nullable: false
						}
						property: {
							kind: Kind::Identifier
							name: '__ks_cons'
						}
						computed: false
						nullable: false
					}
					property: {
						kind: Kind::Identifier
						name: 'call'
					}
					computed: false
					nullable: false
				}
			}
			
			$variable.define(this, this._instanceVariableScope, {
				kind: Kind::Identifier
				name: 'super'
			}, VariableKind::Variable)
		}
		
		let signature, method
		for member in data.members {
			switch member.kind {
				Kind::CommentBlock => {
				}
				Kind::CommentLine => {
				}
				Kind::FieldDeclaration => {
					let instance = true
					for i from 0 til member.modifiers.length while instance {
						if member.modifiers[i].kind == MemberModifier::Static {
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
						this._scope = this._instanceVariableScope if instance
						
						variable.defaultValue = $compile.expression(member.defaultValue, this)
						
						this._scope = scope if instance
					}
					
					if instance {
						this._instanceVariables[member.name.name] = variable
						
						this._variable.instanceVariables[member.name.name] = signature
					}
					else {
						this._classVariables[member.name.name] = variable
						
						this._variable.classVariables[member.name.name] = signature
					}
				}
				Kind::MethodDeclaration => {
					if $method.isConstructor(member.name.name, this._variable) {
						this._scope = this._constructorScope
						
						method = $compile.statement(member, this)
						
						signature = $method.signature(member, this)
						
						this._constructors.push({
							data: member
							signature: signature
							statement: method
							parameters: [$helper.analyseType(parameter.type, this) for parameter in signature.parameters]
						})
						
						this._variable.constructors.push(signature)
						
						this._scope = scope
					}
					else if $method.isDestructor(member.name.name, this._variable) {
						this._scope = this._destructorScope
						
						member.parameters.push({
							kind: Kind::Parameter
							modifiers: []
							name: $identifier('that')
						})
						
						method = $compile.statement(member, this)
						
						this._destructor = {
							data: member
							statement: method
						}
						
						this._variable.destructors++
						
						this._scope = scope
					}
					else {
						let instance = true
						for i from 0 til member.modifiers.length while instance {
							if member.modifiers[i].kind == MemberModifier::Static {
								instance = false
							}
						}
						
						this._scope = this.newInstanceMethodScope(data, member) if instance
						
						signature = $method.signature(member, this)
						
						method = {
							data: member,
							signature: signature
							statement: $compile.statement(member, this)
							parameters: [$helper.analyseType(parameter.type, this) for parameter in signature.parameters]
						}
						
						if instance {
							if !(this._instanceMethods[member.name.name] is Array) {
								this._instanceMethods[member.name.name] = []
								this._variable.instanceMethods[member.name.name] = []
							}
							
							this._instanceMethods[member.name.name].push(method)
							
							this._variable.instanceMethods[member.name.name].push(signature)
							
							this._scope = scope
						}
						else {
							if !(this._classMethods[member.name.name] is Array) {
								this._classMethods[member.name.name] = []
								this._variable.classMethods[member.name.name] = []
							}
							
							this._classMethods[member.name.name].push(method)
							
							this._variable.classMethods[member.name.name].push(signature)
						}
					}
				}
				=> {
					$throw('Unknow kind ' + member.kind, this)
				}
			}
		}
		
		this._sealed = !!data.sealed
		
		if this._sealed {
			this._variable.sealed = {
				name: '__ks_' + this._variable.name.name
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
	newInstanceMethodScope(data, member) { // {{{
		let scope = new Scope(this._scope)
		
		$variable.define(this, scope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(data.name.name))
		
		if this._extends {
			let variable = $variable.define(this, scope, {
				kind: Kind::Identifier
				name: 'super'
			}, VariableKind::Variable)
			
			variable.callable = func(data) {
				data.callee = {
					kind: Kind::MemberExpression
					object: data.callee
					property: member.name
					computed: false
					nullable: false
				}
			}
		}
		
		return scope
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._sealed {
			$class.sealed(this, fragments)
			
			fragments.line('var ' + this._variable.sealed.name + ' = {}')
		}
		else {
			$class.continuous(this, fragments)
		}
	} // }}}
}

class MethodDeclaration extends Statement {
	private {
		_name
		_parameters
		_statements
	}
	$create(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		this._parameters = [new Parameter(parameter, this) for parameter in this._data.parameters]
		
		if this._data.body? {
			this._statements = [$compile.statement(statement, this) for statement in $body(this._data.body)]
		}
		else {
			this._statements = []
		}
	} // }}}
	fuse() { // {{{
		this.compile(this._parameters)
		this.compile(this._statements)
	} // }}}
	name(@name) => this
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code(this._name + '(')
		
		$function.parameters(this, ctrl, func(node) {
			return node.code(')').step()
		})
		
		let variable = this._parent._variable
		
		let nf, modifier
		for parameter, p in this._data.parameters {
			nf = true
			
			for modifier in parameter.modifiers while nf {
				if modifier.kind == ParameterModifier::Member {
					let name = parameter.name.name
					
					if variable.instanceVariables[name] {
						ctrl.newLine().code('this.' + name + ' = ').compile(this._parameters[p]._name).done()
					}
					else if variable.instanceVariables['_' + name] {
						ctrl.newLine().code('this._' + name + ' = ').compile(this._parameters[p]._name).done()
					}
					else if variable.instanceMethods[name] && variable.instanceMethods[name]['1'] {
						ctrl.newLine().code('this.' + name + '(').compile(this._parameters[p]._name).code(')').done()
					}
					else {
						$throw('Can\'t set member ' + name + ' (line ' + parameter.start.line + ')', this)
					}
					
					nf = false
				}
			}
		}
		
		for statement in this._statements {
			ctrl.compile(statement)
		}
		
		ctrl.done()
	} // }}}
}