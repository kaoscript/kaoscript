/**
 * compiler.ks
 * Version 0.1.1
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![cfg(variables='es5')]

import {
	*				from @kaoscript/runtime
	
	*				from @kaoscript/ast
	* as fs			from ./fs.js
	* as metadata	from ../package.json
	parse			from @kaoscript/parser
	* as path		from path
}

extern console, JSON, process, require

func $clone(value?) { // {{{
	if value == null {
		return null
	}
	else if value is Array {
		return (value as Array).clone()
	}
	else if value is Object {
		return Object.clone(value)
	}
	else {
		return value
	}
} // }}}

const $merge = {
	merge(source, key, value) { // {{{
		if value is Array {
			source[key] = (value as Array).clone()
		}
		else if value is Object {
			if source[key] is Object {
				$merge.object(source[key], value)
			}
			else {
				source[key] = $clone(value)
			}
		}
		else {
			source[key] = value
		}
		return source
	} // }}}
	object(source, current) { // {{{
		for key of current {
			if source[key] {
				$merge.merge(source, key, current[key])
			}
			else {
				source[key] = current[key]
			}
		}
	} // }}}
}

impl Array {
	append(...args) { // {{{
		if args.length == 1 {
			this.push.apply(this, Array.from(args[0]))
		}
		else {
			for i from 0 til args.length {
				this.push.apply(this, Array.from(args[i]))
			}
		}
		return this
	} // }}}
	appendUniq(...args) { // {{{
		if args.length == 1 {
			this.pushUniq.apply(this, args[0])
		}
		else {
			for i from 0 til args.length {
				this.pushUniq.apply(this, Array.from(args[i]))
			}
		}
		return this
	} // }}}
	clone() { // {{{
		let i = this.length
		let clone = new Array(i)
		
		while i {
			clone[--i] = $clone(this[i])
		}
		
		return clone
	} // }}}
	contains(item, from = 0) { // {{{
		return this.indexOf(item, from) != -1
	} // }}}
	static from(item) { // {{{
		if(Type.isEnumerable(item) && !Type.isString(item)) {
			return (item is array) ? item : Array.prototype.slice.call(item)
		}
		else {
			return [item]
		}
	} // }}}
	last(index = 1) { // {{{
		return this.length ? this[this.length - index] : null
	} // }}}
	pushUniq(...args) { // {{{
		if args.length == 1 {
			if !this.contains(args[0]) {
				this.push(args[0])
			}
		}
		else {
			for item in args {
				if !this.contains(item) {
					this.push(item)
				}
			}
		}
		return this
	} // }}}
}

impl Object {
	static {
		clone(object) { // {{{
			if object.constructor.clone is Function && object.constructor.clone != this {
				return object.constructor.clone(object)
			}
			if object.constructor.prototype.clone is Function {
				return object.clone()
			}
			
			let clone = {}
			
			for key, value of object {
				clone[key] = $clone(value)
			}
			
			return clone
		} // }}}
		merge(...args) { // {{{
			let source
			
			let i = 0
			let l = args.length
			while i < l && !((source ?= args[i]) && source is Object) {
				++i
			}
			++i
			
			while i < l {
				if args[i] is Object {
					for key, value of args[i] {
						$merge.merge(source, key, value)
					}
				}
				
				++i
			}
			
			return source
		} // }}}
	}
}

enum MemberAccess { // {{{
	Private = 1
	Protected
	Public
} // }}}

const Mode = { // {{{
	Assignment: 1 << 0,
	Declaration: 1 << 1,
	Variable: 1 << 2,
	Key: 1 << 3,
	PrepareAll: 1 << 4,
	NoIndent: 1 << 5,
	Statement: 1 << 6,
	NoLine: 1 << 7,
	Operand: 1 << 8,
	PrepareNone: 1 << 9,
	NoRest: 1 << 10,
	IndentBlock: 1 << 11,
	Await: 1 << 12,
	Async: 1 << 13
	BooleanExpression: 1 << 14
	ObjectMember: 1 << 15
} // }}}

enum VariableKind { // {{{
	Class = 1
	Enum
	Function
	TypeAlias
	Variable
} // }}}

const $defaultTypes = { // {{{
	Array: 'Array'
	Boolean: 'Boolean'
	Function: 'Function'
	Number: 'Number'
	Object: 'Object'
	String: 'String'
} // }}}

const $extensions = { // {{{
	binary: '.ksb',
	hash: '.ksh',
	metadata: '.ksm',
	source: '.ks'
} // }}}

const $generics = { // {{{
	Array: true
} // }}}

const $literalTypes = { // {{{
	false: 'Boolean'
	Infinity: 'Number'
	NaN: 'Number'
	true: 'Boolean'
} // }}}

const $nodeModules = { // {{{
	assert: true
	buffer: true
	child_process: true
	cluster: true
	constants: true
	crypto: true
	dgram: true
	dns: true
	domain: true
	events: true
	fs: true
	http: true
	https: true
	net: true
	os: true
	path: true
	punycode: true
	querystring: true
	readline: true
	repl: true
	stream: true
	string_decoder: true
	tls: true
	tty: true
	url: true
	util: true
	v8: true
	vm: true
	zlib: true
} // }}}

const $predefined = { // {{{
	false: 1
	null: 1
	string: 1
	true: 1
	Error: 1
	Function: 1
	Infinity: 1
	Math: 1
	NaN: 1
	Object: 1
	String: 1
	Type: 1
} // }}}

const $types = { // {{{
	any: 'Any'
	array: 'Array'
	bool: 'Boolean'
	class: 'Class'
	enum: 'Enum'
	func: 'Function'
	number: 'Number'
	object: 'Object'
	string: 'String'
} // }}}

const $typekinds = { // {{{
	'Class': VariableKind::Class
	'Enum': VariableKind::Enum
	'Function': VariableKind::Function
} // }}}

const $typeofs = { // {{{
	Array: 'Type.isArray'
	Boolean: 'Type.isBoolean'
	Function: 'Type.isFunction'
	NaN: 'isNaN'
	Number: 'Type.isNumber'
	Object: 'Type.isObject'
	String: 'Type.isString'
} // }}}

func $caller(data) { // {{{
	if data.kind == Kind.MemberExpression {
		return data.object
	}
	else {
		console.error(data)
		throw new Error('Not Implemented')
	}
} // }}}

func $class(data, variable, node) { // {{{
	switch data.kind {
		Kind.CommentBlock => {
		}
		Kind.CommentLine => {
		}
		Kind.FieldDeclaration => {
			let instance = true
			for i from 0 til data.modifiers.length while instance {
				if data.modifiers[i].kind == MemberModifier::Static {
					instance = false
				}
			}
			
			if instance {
				variable.instanceVariables[data.name.name] = $field.prepare(data, node)
			}
			else {
				variable.classVariables[data.name.name] = $field.prepare(data, node)
			}
		}
		Kind.MethodDeclaration => {
			if data.name.name == variable.name.name {
				$method.prepare(data, variable.constructors, node)
			}
			else {
				let instance = true
				for i from 0 til data.modifiers.length while instance {
					if data.modifiers[i].kind == MemberModifier::Static {
						instance = false
					}
				}
				
				if instance {
					$method.prepare(data, variable.instanceMethods[data.name.name] || (variable.instanceMethods[data.name.name] = []), node)
				}
				else {
					$method.prepare(data, variable.classMethods[data.name.name] || (variable.classMethods[data.name.name] = []), node)
				}
			}
		}
		=> {
			console.error(data)
			throw new Error('Unknow kind ' + data.kind)
		}
	}
} // }}}

func $compile(node, data, config, mode, variable = null) {
	if data.attributes && data.attributes.length { // {{{
		for attr in data.attributes {
			if attr.declaration.kind == Kind::AttributeExpression && attr.declaration.name.name == 'cfg' {
				config = Object.clone(config)
				
				for arg in attr.declaration.arguments {
					if(arg.kind == Kind::AttributeOperator) {
						config[arg.name.name] = arg.value.value
					}
				}
			}
		}
	} // }}}
	
	switch data.kind {
		Kind::ArrayBinding => { // {{{
			node.code('[')
			
			for i from 0 til data.elements.length {
				if i {
					node.code(', ')
				}
				
				node.compile(data.elements[i], config, mode | Mode.Key)
			}
			
			node.code(']')
		} // }}}
		Kind::ArrayComprehension => { // {{{
			if data.loop.kind == Kind.ForInStatement {
				node
					.code('__ks_Array._cm_map(')
					.compile(data.loop.value, config)
					.code(', ')
				
				ctrl = node
					.newControl()
					.addMode(Mode.NoIndent)
					.code('(')
					.parameter(data.loop.variable, config)
				
				if data.loop.index {
					ctrl
						.code(', ')
						.parameter(data.loop.index, config)
				}
				
				ctrl
					.code(') =>')
					.step()
					.newExpression().code('return ').compile(data.body, config)
				
				if data.loop.when {
					node.code(', ')
					
					ctrl = node
						.newControl()
						.addMode(Mode.NoIndent)
						.code('(')
						.parameter(data.loop.variable, config)
					
					if data.loop.index {
						ctrl
							.code(', ')
							.parameter(data.loop.index, config)
					}
					
					ctrl
						.code(') =>')
						.step()
						.newExpression().code('return ').compile(data.loop.when, config)
				}
				
				node.code(')')
			}
			else if data.loop.kind == Kind.ForOfStatement {
				node
					.code('__ks_Object._cm_map(')
					.compile(data.loop.value, config)
					.code(', ')
				
				ctrl = node
					.newControl()
					.addMode(Mode.NoIndent)
					.code('(')
					.parameter(data.loop.variable, config)
				
				if(data.loop.index) {
					ctrl
						.code(', ')
						.parameter(data.loop.index, config)
				}
				
				ctrl
					.code(') =>')
					.step()
					.newExpression().code('return ').compile(data.body, config)
				
				if data.loop.when {
					node.code(', ')
					
					ctrl = node
						.newControl()
						.addMode(Mode.NoIndent)
						.code('(')
						.parameter(data.loop.variable, config)
					
					if data.loop.index {
						ctrl
							.code(', ')
							.parameter(data.loop.index, config)
					}
					
					ctrl
						.code(') =>')
						.step()
						.newExpression().code('return ').compile(data.loop.when, config)
				}
				
				node.code(')')
			}
			else if data.loop.kind == Kind.ForRangeStatement {
				node
					.code('__ks_Array._cm_map(')
					.code('Array_Integer.range(')
					.compile(data.loop.from, config)
					.code(', ')
					.compile(data.loop.to, config)
				
				if data.loop.by {
					node.code(', ').compile(data.loop.by, config)
				}
				
				node
					.code('), ')
					.newControl()
					.addMode(Mode.NoIndent)
					.code('(')
					.parameter(data.loop.variable, config)
					.code(') =>')
					.step()
					.newExpression().code('return ').compile(data.body, config)
				
				if data.loop.when {
					node.code(', ')
					
					node
						.newControl()
						.addMode(Mode.NoIndent)
						.code('(')
						.parameter(data.loop.variable, config)
						.code(') =>')
						.step()
						.newExpression().code('return ').compile(data.loop.when, config)
				}
				
				node.code(')')
			}
			else {
				console.error(data)
				throw new Error('Not Implemented')
			}
		} // }}}
		Kind::ArrayExpression => { // {{{
			node.code('[')
			
			for i from 0 til data.values.length {
				if i {
					node.code(', ')
				}
				
				node.compile(data.values[i], config)
			}
			
			node.code(']')
		} // }}}
		Kind::ArrayRange => { // {{{
			node
				.code('_ks_Array._cm_range(')
				.compile(data.from || data.then, config)
				.code(', ')
				.compile(data.to || data.til, config)
			
			if data.by {
				node.code(', ').compile(data.by, config)
			}
			else {
				node.code(', 1')
			}
			
			node.code(', ', !!data.from, ', ', !!data.to, ')')
		} // }}}
		Kind::AwaitExpression => { // {{{
			let ctrl = node.newExpression().newControl().addMode(Mode.NoIndent)
			
			ctrl.compile(data.operation, config, Mode.Await)
			
			ctrl.code('(__ks_e')
			
			for variable in data.variables {
				ctrl.code(', ').parameter(variable.name, config, variable.type)
			}
			
			ctrl.code(') =>').step()
			
			ctrl
				.newControl()
				.code('if(__ks_e)')
				.step()
				.newExpression()
				.code('return __ks_cb(__ks_e)')
			
			return {
				node: ctrl,
				mode: Mode.Async,
				close: func(node) {
					node.step().addMode(Mode.NoLine).code(')')
				}
			}
		} // }}}
		Kind::BinaryOperator => { // {{{
			exp = node.newExpression()
			
			if mode & Mode.Operand {
				exp.code('(')
			}
			
			if data.operator.kind == BinaryOperator.Assignment {
				$operator.assignment(exp, data, config, mode)
			}
			else {
				$operator.binary(exp, data, config, mode)
			}
			
			if mode & Mode.Operand {
				exp.code(')')
			}
		} // }}}
		Kind::BindingElement => { // {{{
			if data.spread {
				node.code('...')
			}
			
			if data.alias {
				if data.alias.computed {
					node.code('[').compile(data.alias, config, mode).code(']: ')
				}
				else {
					node.compile(data.alias, config, mode).code(': ')
				}
			}
			
			node.compile(data.name, config, mode)
			
			$variable.define(node, data.name, VariableKind::Variable)
			
			if data.defaultValue {
				node.code(' = ').compile(data.defaultValue, config, mode)
			}
		} // }}}
		Kind::Block => { // {{{
			node = node.newBlock()
			
			let stack = []
			let r
			for i from 0 til data.statements.length {
				if (r = node.compile(data.statements[i], config, mode)) && r.node && r.close {
					node = r.node
					mode = r.mode
					stack.push(r)
				}
			}
			
			for item in stack {
				item.close(item.node)
			}
		} // }}}
		Kind::BreakStatement => node.newExpression().code('break')
		Kind::CallExpression => { // {{{
			let list = true
			
			for argument in data.arguments while list {
				if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
					list = false
				}
			}
			
			node = node.newExpression()
			
			let callee
			if data.callee.kind == Kind::MemberExpression && !data.callee.computed && data.callee.object.kind == Kind::MemberExpression && !data.callee.object.computed && data.callee.property.kind == Kind::Identifier && (data.callee.property.name == 'apply') && (callee = $final.callee(data.callee.object, node)) {
				if callee.variable {
					if data.callee.property.name == 'apply' {
						node.code((callee.variable.accessPath || ''), callee.variable.final.name, (callee.instance ? '._im_' : '._cm_'), data.callee.object.property.name, '.apply(', (callee.variable.accessPath || ''), callee.variable.final.name, ', ')
						
						if data.arguments.length == 1 {
							node.compile(data.arguments[0], config)
						}
						else if data.arguments.length == 2 {
							if data.arguments[1].kind == Kind::ArrayExpression {
								node.code('[').compile(data.arguments[0], config)
								
								for value in data.arguments[1].values {
									node.code(', ').compile(value, config)
								}
								
								node.code(']')
							}
							else {
								node.code('[').compile(data.arguments[0], config).code('].concat(').compile(data.arguments[1], config).code(')')
							}
						}
						else {
							throw new Error('Wrong number of arguments for apply() at line ' + data.callee.property.start.line)
						}
						
						node.code(')')
					}
				}
				else {
					console.error(callee)
					throw new Error('Not Implemented')
				}
			}
			else if data.callee.kind == Kind::MemberExpression && !data.callee.computed && (callee = $final.callee(data.callee, node)) {
				if callee.variable {
					if callee.instance {
						node
							.code((callee.variable.accessPath || ''), callee.variable.final.name, '._im_' + data.callee.property.name + '(')
							.compile(data.callee.object, config)
						
						for i from 0 til data.arguments.length {
							node.code(', ').compile(data.arguments[i], config)
						}
						
						if mode & Mode.Await {
							node.code(', ')
						}
						else {
							node.code(')')
						}
					}
					else {
						node.code((callee.variable.accessPath || ''), callee.variable.final.name + '._cm_' + data.callee.property.name + '(')
						
						for i from 0 til data.arguments.length {
							if i {
								node.code(', ')
							}
							
							node.compile(data.arguments[i], config)
						}
						
						if mode & Mode.Await {
							if data.arguments.length {
								node.code(', ')
							}
						}
						else {
							node.code(')')
						}
					}
				}
				else if callee.variables.length == 2 {
					node.code('(') if mode & Mode.Operand
					
					let name = null
					if(data.callee.object.kind == Kind::Identifier) {
						if $typeofs[callee.variables[0].name] {
							node.code($typeofs[callee.variables[0].name], '(').compile(data.callee.object, config).code(')')
						}
						else {
							node.code('Type.is(').compile(data.callee.object, config).code(', ', callee.variables[0].name, ')')
						}
					}
					else {
						name = node.newTempName()
						
						if $typeofs[callee.variables[0].name] {
							node.code($typeofs[callee.variables[0].name], '(', name, ' = ').compile(data.callee.object, config).code(')')
						}
						else {
							node.code('Type.is(', name, ' = ').compile(data.callee.object, config).code(', ', callee.variables[0].name, ')')
						}
					}
					
					node.code(' ? ')
					
					node
						.code((callee.variables[0].accessPath || ''), callee.variables[0].final.name + '._im_' + data.callee.property.name + '(')
						.compile(name ? name : data.callee.object, config)
					
					for i from 0 til data.arguments.length {
						node.code(', ').compile(data.arguments[i], config)
					}
					
					node.code(') : ')
					
					node
						.code((callee.variables[1].accessPath || ''), callee.variables[1].final.name + '._im_' + data.callee.property.name + '(')
						.compile(name ? name : data.callee.object, config)
					
					for i from 0 til data.arguments.length {
						node.code(', ').compile(data.arguments[i], config)
					}
					
					node.code(')')
					
					node.code(')') if mode & Mode.Operand
				}
				else {
					console.error(callee)
					throw new Error('Not Implemented')
				}
			}
			else {
				if list {
					if data.scope.kind == ScopeModifier::This {
						let variable = node.getVariable(data.callee.name) if data.callee.kind == Kind::Identifier
						
						if variable && variable.callReplacement {
							variable.callReplacement(node, data, list)
						}
						else {
							node
								.compile(data.callee, config)
								.code('(')
							
							for i from 0 til data.arguments.length {
								if i {
									node.code(', ')
								}
								
								node.compile(data.arguments[i], config)
							}
							
							if mode & Mode.Await {
								if data.arguments.length {
									node.code(', ')
								}
							}
							else {
								node.code(')')
							}
						}
					}
					else {
						console.error(data)
						throw new Error('Not Implemented')
					}
				}
				else if data.arguments.length == 1 {
					node
						.compile(data.callee, config)
						.code('.apply(')
					
					if data.scope.kind == ScopeModifier::Null {
						node.code('null')
					}
					else if data.scope.kind == ScopeModifier::This {
						let caller = $caller(data.callee)
						if caller {
							node.compile(caller, config)
						}
						else {
							node.code('null')
						}
					}
					else {
						node.compile(data.scope.value, config)
					}
					
					node
						.code(', ')
						.compile(data.arguments[0].argument, config)
						
					if mode & Mode.Await {
						node.code(', ')
					}
					else {
						node.code(')')
					}
				}
				else {
					console.error(data)
					throw new Error('Not Implemented')
				}
			}
		} // }}}
		Kind::ClassDeclaration => { // {{{
			variable = $variable.define(node, data.name, VariableKind.Class, data.type)
			
			if variable.new {
				for i from 0 til data.members.length {
					$class(data.members[i], variable, node)
				}
				
				let continuous = true
				for i from 0 til data.modifiers.length while continuous {
					if data.modifiers[i].kind == ClassModifier::Final {
						continuous = false
					}
				}
				
				if continuous {
					$continuous.class(node, data, config, mode, variable)
				}
				else {
					variable.final = {
						constructors: false,
						instanceMethods: {},
						classMethods: {}
					}
					
					$final.class(node, data, config, mode, variable)
				}
			}
			else {
				console.error(data)
				throw new Error('Not Implemented')
			}
		} // }}}
		Kind::CommentBlock => { // {{{
		} // }}}
		Kind::CommentLine => { // {{{
		} // }}}
		Kind::ContinueStatement => node.newExpression().code('continue')
		Kind::CurryExpression => { // {{{
			let list = true
			
			for argument in data.arguments while list {
				if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
					list = false
				}
			}
			
			node = node.newExpression()
			
			if list {
				if data.scope.kind == ScopeModifier::Null {
					node
						.code('__ks_Function._cm_vcurry(')
						.compile(data.callee, config)
						.code(', null')
					
					for i from 0 til data.arguments.length {
						node.code(', ').compile(data.arguments[i], config)
					}
					
					node.code(')')
				}
				else if data.scope.kind == ScopeModifier::This {
					node
						.code('__ks_Function._cm_vcurry(')
						.compile(data.callee, config)
						.code(', ')
					
					let caller = $caller(data.callee)
					if caller {
						node.compile(caller, config)
					}
					else {
						node.code('null')
					}
					
					for i from 0 til data.arguments.length {
						node.code(', ').compile(data.arguments[i], config)
					}
					
					node.code(')')
				}
				else {
					console.error(data)
					throw new Error('Not Implemented')
				}
			}
			else if data.arguments.length == 1 {
				console.error(data)
				throw new Error('Not Implemented')
			}
			else {
				console.error(data)
				throw new Error('Not Implemented')
			}
		} // }}}
		Kind::DoUntilStatement => { // {{{
			node
				.newControl()
				.code('do')
				.step()
				.compile(data.body, config)
				.step()
				.code('while(!(')
				.compile(data.condition, config)
				.code('))')
		} // }}}
		Kind::DoWhileStatement => { // {{{
			node
				.newControl()
				.code('do')
				.step()
				.compile(data.body, config)
				.step()
				.code('while(')
				.compile(data.condition, config)
				.code(')')
		} // }}}
		Kind::EnumDeclaration => { // {{{
			variable = $variable.define(node, data.name, VariableKind.Enum, data.type)
			
			if(variable.new) {
				let statement = node
					.newExpression()
					.code($variable.scope(config))
					.compile(variable.name, config, Mode.Key)
					.code(' = {')
					.indent()
					
				for i from 0 til data.members.length {
					if i {
						statement.code(',')
					}
					
					statement.compile(data.members[i], config, 0, variable)
				}
				
				statement
					.unindent()
					.newline()
					.code('}')
			}
			else {
				for i from 0 til data.members.length {
					node.compile(data.members[i], config, 0, variable)
				}
			}
		} // }}}
		Kind::EnumExpression => node.compile(data.enum, config).code('.').compile(data.member, config, Mode.Key)
		Kind::EnumMember => { // {{{
			if variable.new {
				node
					.newline()
					.code(data.name.name, ': ', $variable.value(variable, data))
			}
			else {
				node
					.newExpression()
					.code(variable.name.name || variable.name, '.', data.name.name, ' = ', $variable.value(variable, data))
			}
		} // }}}
		Kind::ExportDeclaration => { // {{{
			let module = node.module()
			
			for declaration in data.declarations {
				switch declaration.kind {
					Kind::ClassDeclaration		=> {
						node.compile(declaration, config)
						
						module.export(declaration.name)
					}
					Kind::EnumDeclaration		=> {
						node.compile(declaration, config)
						
						module.export(declaration.name)
					}
					Kind::ExportAlias			=> module.export(declaration.name, declaration.alias)
					Kind::FunctionDeclaration	=> {
						node.compile(declaration, config)
						
						module.export(declaration.name)
					}
					Kind::Identifier			=> module.export(declaration)
					Kind::TypeAliasDeclaration	=> {
						$variable.define(node, declaration.name, VariableKind::TypeAlias, declaration.type)
						
						module.export(declaration.name)
					}
					Kind::VariableDeclaration	=> {
						node.compile(declaration, config)
						
						for j from 0 til declaration.declarations.length {
							module.export(declaration.declarations[j].name)
						}
					}
					=> {
						console.error(declaration)
						throw new Error('Not Implemented')
					}
				}
			}
		} // }}}
		Kind::ExternDeclaration => { // {{{
			for declaration in data.declarations {
				switch declaration.kind {
					Kind::ClassDeclaration => {
						variable = $variable.define(node, declaration.name, VariableKind.Class, declaration)
						
						let continuous = true
						for i from 0 til declaration.modifiers.length while continuous {
							continuous = false if declaration.modifiers[i].kind == ClassModifier::Final
						}
						
						if !continuous {
							variable.final = {
								constructors: false,
								instanceMethods: {},
								classMethods: {}
							}
						}
						
						for i from 0 til declaration.members.length {
							$extern.classMember(declaration.members[i], variable, node)
						}
					}
					Kind::VariableDeclarator => {
						variable = $variable.define(node, declaration.name, $variable.kind(declaration.type), declaration.type)
					}
					=> {
						console.error(declaration)
						throw new Error('Unknow kind ' + declaration.kind)
					}
				}
			}
		}
		// }}}
		Kind::ForFromStatement => { // {{{
			let ctrl = node.newControl()
			
			ctrl.code('for(', $variable.scope(config), data.variable.name, ' = ').compile(data.from, config)
			
			let bound
			if data.til {
				if data.til.kind != Kind::NumericExpression {
					bound = ctrl.newTempName()
					ctrl.code(', ', bound, ' = ').compile(data.til, config)
				}
			}
			else {
				if data.to.kind != Kind::NumericExpression {
					bound = ctrl.newTempName()
					ctrl.code(', ', bound, ' = ').compile(data.to, config)
				}
			}
			
			let by
			if data.by && !(data.by.kind == Kind::NumericExpression || data.by.kind == Kind::Identifier) {
				by = ctrl.newTempName()
				ctrl.code(', ', by, ' = ').compile(data.by, config)
			}
			
			ctrl.code('; ')
			
			if data.until {
				ctrl.code('!(').compile(data.until, config).code(') && ')
			}
			else if data.while {
				ctrl.compile(data.while, config).code(' && ')
			}
			
			ctrl.code(data.variable.name)
			
			let desc = (data.by && data.by.kind == Kind::NumericExpression && data.by.value < 0) || (data.from.kind == Kind::NumericExpression && ((data.to && data.to.kind == Kind::NumericExpression && data.from.value > data.to.value) || (data.til && data.til.kind == Kind::NumericExpression && data.from.value > data.til.value)))
			
			if data.til {
				if desc {
					ctrl.code(' > ')
				}
				else {
					ctrl.code(' < ')
				}
				
				if data.til.kind == Kind::NumericExpression {
					ctrl.code(data.til.value)
				}
				else {
					ctrl.code(bound)
				}
			}
			else {
				if desc {
					ctrl.code(' >= ')
				}
				else {
					ctrl.code(' <= ')
				}
				
				if data.to.kind == Kind::NumericExpression {
					ctrl.code(data.to.value)
				}
				else {
					ctrl.code(bound)
				}
			}
			
			ctrl.code('; ')
			
			if data.by {
				if data.by.kind == Kind::NumericExpression {
					if data.by.value == 1 {
						ctrl.code('++', data.variable.name)
					}
					else if data.by.value == -1 {
						ctrl.code('--', data.variable.name)
					}
					else if data.by.value >= 0 {
						ctrl.code(data.variable.name, ' += ', data.by.value)
					}
					else {
						ctrl.code(data.variable.name, ' -= ', -data.by.value)
					}
				}
				else if data.by.kind == Kind::Identifier {
					ctrl.code(data.variable.name, ' += ').compile(data.by, config)
				}
				else {
					ctrl.code(data.variable.name, ' += ', by)
				}
			}
			else if desc {
				ctrl.code('--', data.variable.name)
			}
			else {
				ctrl.code('++', data.variable.name)
			}
			
			ctrl.code(')').step()
			
			$variable.define(ctrl, data.variable, VariableKind::Variable)
			
			ctrl.compile(data.body, config)
		} // }}}
		Kind::ForInStatement => { // {{{
			let value, index, ctrl, bound
			if data.value.kind == Kind::Identifier {
				value = data.value.name
			}
			else {
				value = node.newTempName()
				
				node
					.newExpression()
					.code($variable.scope(config), value, ' = ')
					.compile(data.value, config)
			}
			
			if data.desc {
				if data.index && node.hasVariable(data.index.name) {
					index = data.index.name
					
					node.newExpression().code(index, ' = ', value, '.length - 1')
					
					ctrl = node
						.newControl()
						.code('for(')
						
					if !node.hasVariable(data.variable.name) {
						ctrl.code($variable.scope(config), data.variable.name)
					}
				}
				else {
					ctrl = node.newControl()
					
					index = data.index ? data.index.name : ctrl.newTempName()
					
					ctrl.code('for(', $variable.scope(config), index, ' = ', value, '.length - 1')
					
					if !node.hasVariable(data.variable.name) {
						ctrl.code(', ', data.variable.name)
					}
				}
			}
			else {
				if data.index && node.hasVariable(data.index.name) {
					index = data.index.name
					
					node.newExpression().code(index, ' = 0')
					
					ctrl = node
						.newControl()
						.code('for(', $variable.scope(config))
				}
				else {
					ctrl = node.newControl()
					
					index = data.index ? data.index.name : ctrl.newTempName()
					
					ctrl.code('for(', $variable.scope(config), index, ' = 0, ')
				}
				
				bound = ctrl.newTempName()
				
				ctrl.code(bound, ' = ', value, '.length')
				
				if !node.hasVariable(data.variable.name) {
					ctrl.code(', ', data.variable.name)
				}
			}
			
			ctrl.code('; ')
			
			if data.until {
				ctrl.code('!(').compile(data.until, config).code(') && ')
			}
			else if data.while {
				ctrl.compile(data.while, config).code(' && ')
			}
			
			if data.desc {
				ctrl.code(index, ' >= 0; --', index, ')').step()
			}
			else {
				ctrl.code(index, ' < ', bound, '; ++', index, ')').step()
			}
			
			if data.index {
				$variable.define(ctrl, data.index, VariableKind::Variable)
			}
			
			ctrl
				.newExpression()
				.code(data.variable.name, ' = ', value, '[', index, ']')
			
			$variable.define(ctrl, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
			
			if data.when {
				ctrl
					.newControl()
					.code('if(').compile(data.when, config).code(')').step()
					.compile(data.body, config)
			}
			else {
				ctrl.compile(data.body, config)
			}
		} // }}}
		Kind::ForOfStatement => { // {{{
			let value
			if data.value.kind == Kind::Identifier {
				value = data.value.name
			}
			else {
				value = node.newTempName()
				
				node.newExpression().code($variable.scope(config), value, ' = ').compile(data.value, config)
			}
			
			let ctrl = node.newControl()
			
			ctrl.code('for(')
			if !node.hasVariable(data.variable.name) {
				ctrl.code($variable.scope(config))
			}
			ctrl.code(data.variable.name, ' in ', value, ')')
			
			ctrl.step()
			
			$variable.define(ctrl, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
			
			if data.index {
				if !node.hasVariable(data.variable.name) {
					ctrl.code($variable.scope(config))
				}
				
				ctrl.code(data.index.name, ' = ', value, '[', data.variable.name, ']')
				
				$variable.define(ctrl, data.index, VariableKind::Variable)
			}
			
			if data.until {
				ctrl
					.newControl()
					.code('if(')
					.compile(data.until, config)
					.code(')')
					.step()
					.newExpression()
					.code('break')
			}
			else if data.while {
				ctrl
					.newControl()
					.code('if(!(')
					.compile(data.while, config)
					.code('))')
					.step()
					.newExpression()
					.code('break')
			}
			
			ctrl.compile(data.body, config)
		} // }}}
		Kind::ForRangeStatement => { // {{{
			let ctrl = node.newControl()
			
			ctrl.code('for(', $variable.scope(config), data.variable.name, ' = ').compile(data.from, config).code('; ')
			
			if data.until {
				ctrl.code('!(').compile(data.until, config).code(') && ')
			}
			else if data.while {
				ctrl.compile(data.while, config).code(' && ')
			}
			
			ctrl.code(data.variable.name, ' <= ')
			
			if data.to.kind == Kind.NumericExpression {
				ctrl.code(data.to.value)
			}
			else {
				ctrl.code(data.to)
			}
			
			ctrl.code('; ')
			
			if data.by {
				ctrl.code(data.variable.name, ' += ', data.by.value)
			}
			else {
				ctrl.code('++', data.variable.name)
			}
			
			$variable.define(ctrl, data.variable.name, VariableKind::Variable)
			
			ctrl
				.code(')')
				.step()
				.compile(data.body, config)
		} // }}}
		Kind::FunctionDeclaration => { // {{{
			variable = $variable.define(node, data.name, VariableKind::Function, data.type)
			
			for modifier in data.modifiers {
				if modifier.kind == FunctionModifier::Async {
					variable.async = true
				}
			}
			
			node.newFunction().operation(func(ctrl) {
				ctrl.code('function ', data.name.name, '(')
				
				$function.parameters(ctrl, data, config, func(node) {
					node.code(')').step()
				})
				
				$variable.define(ctrl, {
					kind: Kind::Identifier,
					name: 'this'
				}, VariableKind::Variable)
				
				if data.body.kind == Kind::Block {
					ctrl.compile(data.body, config)
				}
				else {
					ctrl.newExpression().code('return ').compile(data.body, config)
				}
			})
		} // }}}
		Kind::FunctionExpression => { // {{{
			node.newFunction().operation(func(ctrl) {
				ctrl.addMode(mode | Mode.NoIndent)
				
				if mode & Mode.ObjectMember {
					ctrl.code('(')
				}
				else {
					ctrl.code('function(')
				}
				
				$function.parameters(ctrl, data, config, func(node) {
					ctrl.code(')').step()
					
					if mode & Mode.IndentBlock {
						ctrl.indent()
					}
				})
				
				if data.body.kind == Kind.Block {
					ctrl.compile(data.body, config)
				}
				else {
					ctrl.newExpression().code('return ').compile(data.body, config)
				}
			})
		} // }}}
		Kind::Identifier => { // {{{
			if !((mode & Mode.Key) || $predefined[data.name]) {
				node.use(data)
				
				node.codeVariable(data)
			}
			else {
				node.code(data.name)
			}
		} // }}}
		Kind::IfExpression => { // {{{
			if data.else {
				node
					.newExpression()
					.compile(data.condition, config, Mode.BooleanExpression)
					.code(' ? ')
					.compile(data.then, config)
					.code(' : ')
					.compile(data.else, config)
			}
			else if mode & Mode.Assignment {
				node
					.newExpression()
					.compile(data.condition, config, Mode.BooleanExpression)
					.code(' ? ')
					.compile(data.then, config)
					.code(' : undefined')
			}
			else {
				node
					.newControl(Mode.PrepareAll)
					.code('if(')
					.compile(data.condition, config, Mode.BooleanExpression)
					.code(')')
					.step()
					.compile(data.then, config)
			}
		} // }}}
		Kind::IfStatement => { // {{{
			let ctrl = node.newControl()
			
			ctrl
				.code('if(')
				.compile(data.condition, config, Mode.BooleanExpression)
				.code(')')
				.step()
				.compile(data.then, config)
			
			if data.elseifs {
				for elseif in data.elseifs {
					ctrl
						.step()
						.code('else if(')
						.compile(elseif.condition, config, Mode.BooleanExpression)
						.code(')')
						.step()
						.compile(elseif.body, config)
				}
			}
			
			if data.else {
				ctrl
					.step()
					.code('else')
					.step()
					.compile(data.else.body, config)
			}
		} // }}}
		Kind::ImplementDeclaration => { // {{{
			variable = node.getVariable(data.class.name)
			
			if variable.kind != VariableKind.Class {
				throw new Error('Invalid class for impl at line ' + data.start.line)
			}
			
			if variable.final {
				if !variable.final.name {
					variable.final.name = '__ks_' + variable.name.name
					
					node.newExpression().code('var ' + variable.final.name + ' = {}')
				}
			}
			
			for i from 0 til data.members.length {
				$implement(node, data.members[i], config, variable)
			}
		} // }}}
		Kind::ImportDeclaration => { // {{{
			for declaration in data.declarations {
				node.compile(declaration, config)
			}
		} // }}}
		Kind::ImportDeclarator => { // {{{
			let module = node.module()
			
			$import.resolve(data, module.parent(), module, node)
		} // }}}
		Kind::Literal => node.code($quote(data.value))
		Kind::MemberExpression => { // {{{
			node = node.newExpression()
			
			node.compile(data.object, config, mode | Mode.Operand)
			
			if data.computed {
				node
					.code('[')
					.compile(data.property, config)
					.code(']')
			}
			else {
				node.code('.', data.property.name)
			}
		} // }}}
		Kind::NumericExpression => node.code(data.value)
		Kind::ObjectBinding => { // {{{
			node.code('{')
			
			for i from 0 til data.elements.length {
				if(i) {
					node.code(', ')
				}
				
				node.compile(data.elements[i], config, mode | Mode.Key)
			}
			
			node.code('}')
		} // }}}
		Kind::ObjectExpression => { // {{{
			let obj = node.newObject()
			
			if data.properties.length {
				for i from 0 til data.properties.length {
					obj.compile(data.properties[i], config)
				}
			}
		} // }}}
		Kind::ObjectMember => { // {{{
			if data.name.kind == Kind::Identifier || data.name.kind == Kind::Literal {
				if data.value.kind == Kind::FunctionExpression {
					node
						.newExpression()
						.reference(data.name.kind == Kind::Identifier ? '.' + data.name.name : '[' + $quote(data.name.value) + ']')
						.compile(data.name, config, Mode.Key)
						.compile(data.value, config, Mode.NoIndent | Mode.ObjectMember)
				}
				else {
					node
						.newExpression()
						.reference(data.name.kind == Kind::Identifier ? '.' + data.name.name : '[' + $quote(data.name.value) + ']')
						.compile(data.name, config, Mode.Key)
						.code(': ')
						.compile(data.value, config, Mode.NoIndent)
				}
			}
			else {
				let {block, reference} = node.block()
				
				block.newExpression().code(reference, '[').compile(data.name, config, Mode.Key).code('] = ').compile(data.value, config)
			}
		} // }}}
		Kind::OmittedExpression => { // {{{
			if data.spread {
				node.code('...')
			}
		} // }}}
		Kind::PolyadicOperator => { // {{{
			let exp = node.newExpression()
			
			if mode & Mode.Operand {
				exp.code('(')
				
				$operator.polyadic(exp, data, config, mode)
				
				exp.code(')')
			}
			else {
				$operator.polyadic(exp, data, config, mode)
			}
		} // }}}
		Kind::RegularExpression => node.code(data.value)
		Kind::RequireDeclaration => { // {{{
			let module = node.module()
			
			let type
			for declaration in data.declarations {
				switch declaration.kind {
					Kind::VariableDeclarator => {
						$variable.define(node, declaration.name, type = $variable.kind(declaration.type), declaration.type)
						
						module.require(declaration.name.name, type)
					}
					=> {
						console.error(declaration)
						throw new Error('Unknow kind ' + declaration.kind)
					}
				}
			}
		} // }}}
		Kind::ReturnStatement => { // {{{
			if mode & Mode.Async {
				if data.value {
					node
						.newExpression()
						.code('return __ks_cb(null, ')
						.compile(data.value, config)
						.code(')')
				}
				else {
					node.newExpression().code('return __ks_cb()')
				}
			}
			else {
				if data.value {
					node
						.newExpression()
						.code('return ')
						.compile(data.value, config)
				}
				else {
					node.newExpression().code('return')
				}
			}
		} // }}}
		Kind::SwitchStatement => { // {{{
			let conditions = {}
			let filters = {}
			
			let condition, name, exp, value
			for clause, clauseIdx in data.clauses {
				for condition, conditionIdx in clause.conditions {
					if condition.kind == Kind::SwitchConditionArray {
						if !conditions[clauseIdx] {
							conditions[clauseIdx] = {}
						}
						
						let nv = true
						for i from 0 til condition.values.length while nv {
							if condition.values[i].kind != Kind::OmittedExpression {
								nv = false
							}
						}
						
						if !nv {
							name = conditions[clauseIdx][conditionIdx] = node.newTempName()
							
							exp = node.newExpression().code($variable.scope(config), name, ' = ([')
							
							let names = {}
							for i from 0 til condition.values.length {
								if i {
									exp.code(', ')
								}
								
								if condition.values[i].kind == Kind::OmittedExpression {
									if condition.values[i].spread {
										exp.code('...')
									}
								}
								else {
									exp.code('__ks_', i)
								}
							}
							
							exp.code(']) => ')
							
							nv = false
							for value, i in condition.values {
								if value.kind != Kind::OmittedExpression {
									if nv {
										exp.code(' && ')
									}
									else {
										nv = true
									}
									
									if value.kind == Kind::SwitchConditionRange {
										exp.code('__ks_', i)
										if value.from {
											exp.code(' >= ').compile(value.from, config)
										}
										else {
											exp.code(' > ').compile(value.then, config)
										}
										
										exp.code(' && ')
										
										exp.code('__ks_', i)
										if value.to {
											exp.code(' <= ').compile(value.to, config)
										}
										else {
											exp.code(' < ').compile(value.til, config)
										}
									}
									else {
										exp.code('__ks_', i, ' === ').compile(value, config)
									}
								}
							}
						}
					}
				}
				
				if clause.filter && clause.bindings.length {
					name = filters[clauseIdx] = node.newTempName()
					
					exp = node.newExpression().code($variable.scope(config), name, ' = (')
					
					for i from 0 til clause.bindings.length {
						if i {
							exp.code(', ')
						}
						
						exp.compile(clause.bindings[i], config)
					}
					
					exp.code(') => ').compile(clause.filter, config)
				}
			}
			
			if data.expression.kind == Kind::Identifier {
				name = data.expression.name
			}
			else {
				name = node.newTempName()
				node.newExpression().code($variable.scope(config), name, ' = ').compile(data.expression, config)
			}
			
			let ctrl = node.newControl()
			let we = false
			
			let binding, mm
			for clause, clauseIdx in data.clauses {
				if clause.conditions.length {
					if we {
						throw new Error('The default clause is before this clause')
					}
					
					if clauseIdx {
						ctrl.code('else if(')
					}
					else {
						ctrl.code('if(')
					}
					
					for condition, i in clause.conditions {
						if i {
							ctrl.code(' || ')
						}
						
						if condition.kind == Kind::SwitchConditionArray {
							ctrl.code('(', $typeofs.Array, '(', name, ')')
				
							mm = $switch.length(condition.values)
							if mm.min == mm.max {
								if mm.min != Infinity {
									ctrl.code(' && ', name, '.length === ', mm.min)
								}
							}
							else {
								ctrl.code(' && ', name, '.length >= ', mm.min)
								
								if mm.max != Infinity {
									ctrl.code(' && ', name, '.length <= ', mm.max)
								}
							}
							
							if conditions[clauseIdx][i] {
								ctrl.code(' && ', conditions[clauseIdx][i], '(', name, ')')
							}
							
							ctrl.code(')')
						}
						else if condition.kind == Kind::SwitchConditionEnum {
							let variable = node.getVariable(data.expression.name)
							
							if !variable || variable.type.kind != VariableKind::Enum {
								throw new Error('Switch condition is not an Enum at line ' + condition.start.line)
							}
							
							ctrl.code(name, ' === ').compile(variable.type.name, config).code('.').compile(condition.name, config, Mode.Key)
						}
						else if condition.kind == Kind::SwitchConditionObject {
							console.error(condition)
							throw new Error('Not Implemented')
						}
						else if condition.kind == Kind::SwitchConditionRange {
							if clause.conditions.length > 1 {
								ctrl.code('(')
							}
							
							ctrl.code(name)
							if condition.from {
								ctrl.code(' >= ').compile(condition.from, config)
							}
							else {
								ctrl.code(' > ').compile(condition.then, config)
							}
							
							ctrl.code(' && ')
							
							ctrl.code(name)
							if condition.to {
								ctrl.code(' <= ').compile(condition.to, config)
							}
							else {
								ctrl.code(' < ').compile(condition.til, config)
							}
							
							if clause.conditions.length > 1 {
								ctrl.code(')')
							}
						}
						else if condition.kind == Kind::SwitchConditionType {
							$type.check(ctrl, {
								kind: Kind::Identifier,
								name: name
							}, condition.type, config)
						}
						else {
							ctrl.code(name, ' === ').compile(condition, config)
						}
					}
					
					$switch.test(clause, ctrl, name, filters[clauseIdx], true, config)
					
					ctrl.code(')').step()
					
					$switch.binding(clause, ctrl, name, config)
					
					ctrl.compile(clause.body, config).step()
				}
				else if clause.bindings.length {
					if clauseIdx {
						ctrl.code('else if(')
					}
					else {
						ctrl.code('if(')
					}
					
					$switch.test(clause, ctrl, name, filters[clauseIdx], false, config)
					
					ctrl.code(')').step()
					
					$switch.binding(clause, ctrl, name, config)
					
					ctrl.compile(clause.body, config).step()
				}
				else if clause.filter {
					console.error(clause)
					throw new Error('Not Implemented')
				}
				else {
					if clauseIdx {
						ctrl.code('else')
					}
					else {
						ctrl.code('if(true)')
					}
					
					we = true
					
					ctrl.step().compile(clause.body, config).step()
				}
			}
		} // }}}
		Kind::TemplateExpression => { // {{{
			for i from 0 til data.elements.length {
				if i {
					node.code(' + ')
				}
				
				node.compile(data.elements[i], config)
			}
		} // }}}
		Kind::TernaryConditionalExpression => { // {{{
			if mode & Mode.Operand {
				node
					.code('(')
					.compile(data.condition, config)
					.code(' ? ')
					.compile(data.then, config, Mode.Operand)
					.code(' : ')
					.compile(data.else, config, Mode.Operand)
					.code(')')
			}
			else {
				node
					.code('(')
					.compile(data.condition, config)
					.code(') ? (')
					.compile(data.then, config)
					.code(') : (')
					.compile(data.else, config)
					.code(')')
			}
		} // }}}
		Kind::ThrowStatement => node.newExpression().code('throw ').compile(data.value, config)
		Kind::TryStatement => { // {{{
			let finalizer = null
			
			if data.finalizer {
				finalizer = node.newTempName()
				
				node
					.newExpression()
					.code($variable.scope(config), finalizer, ' = ')
					.newControl()
					.addMode(Mode.NoIndent)
					.code('() =>')
					.step()
					.compile(data.finalizer, config)
			}
			
			let ctrl = node
				.newControl()
				.code('try')
				.step()
				.compile(data.body, config)
			
			if finalizer {
				ctrl.newExpression().code(finalizer, '()')
			}
			
			ctrl.step()
			
			if data.catchClauses.length {
				let error = node.newTempName()
				
				ctrl.code('catch(', error, ')').step()
				
				$variable.define(ctrl, error, VariableKind::Variable)
				
				if finalizer {
					ctrl.newExpression().code(finalizer, '()')
				}
				
				let ifs = ctrl.newControl()
				
				for catchClause, i in data.catchClauses {
					if i {
						ifs.code('else ')
					}
					
					ifs.code('if(Type.is(', error, ', ').compile(catchClause.type, config).code(')').step()
					
					if catchClause.binding {
						ifs.newExpression().code($variable.scope(config), catchClause.binding.name, ' = ', error)
						
						$variable.define(ctrl, catchClause.binding, VariableKind::Variable)
					}
					
					ifs.compile(catchClause.body, config).step()
				}
				
				if data.catchClause {
					ifs.code('else').step()
					
					if data.catchClause.binding {
						ifs.newExpression().code($variable.scope(config), data.catchClause.binding.name, ' = ', error)
						
						$variable.define(ctrl, data.catchClause.binding, VariableKind::Variable)
					}
					
					ifs.compile(data.catchClause.body, config).step()
				}
			}
			else if data.catchClause {
				if data.catchClause.binding {
					ctrl.code('catch(', data.catchClause.binding.name, ')').step()
					
					$variable.define(ctrl, data.catchClause.binding, VariableKind::Variable)
				}
				else {
					ctrl.code('catch(', node.newTempName(), ')').step()
				}
				
				if finalizer {
					ctrl.newExpression().code(finalizer, '()')
				}
				
				ctrl.compile(data.catchClause.body, config)
			}
			else {
				ctrl.code('catch(', node.newTempName(), ')').step()
				
				if finalizer {
					ctrl.newExpression().code(finalizer, '()')
				}
			}
		} // }}}
		Kind::TypeAliasDeclaration => $variable.define(node, data.name, VariableKind::TypeAlias, data.type)
		Kind::TypeReference => node.code($types[data.typeName.name] || data.typeName.name)
		Kind::UnaryExpression => $operator.unary(node.newExpression(), data, config, mode)
		Kind::UnlessExpression => { // {{{
			if data.else {
				node
					.newExpression()
					.compile(data.condition, config)
					.code(' ? ')
					.compile(data.else, config)
					.code(' : ')
					.compile(data.then, config)
			}
			else if mode & Mode.Assignment {
				node
					.newExpression()
					.compile(data.condition, config)
					.code(' ? undefined : ')
					.compile(data.then, config)
			}
			else {
				node
					.newControl(Mode.PrepareAll)
					.code('if(!(')
					.compile(data.condition, config)
					.code('))')
					.step()
					.compile(data.then, config)
			}
		} // }}}
		Kind::UnlessStatement => { // {{{
			node
				.newControl()
				.code('if(!(')
				.compile(data.condition, config)
				.code('))')
				.step()
				.compile(data.then, config)
		} // }}}
		Kind::UntilStatement => { // {{{
			node
				.newControl()
				.code('while(!(')
				.compile(data.condition, config)
				.code('))')
				.step()
				.compile(data.body, config)
		} // }}}
		Kind::VariableDeclaration => { // {{{
			if data.declarations.length == 1 {
				return node.compile(data.declarations[0], config, mode, data.modifiers.kind)
			}
			else {
				for i from 0 til data.declarations.length {
					node.compile(data.declarations[i], config, mode, data.modifiers.kind)
				}
			}
		} // }}}
		Kind::VariableDeclarator => { // {{{
			let exp = node.newExpression()
			
			if data.name.kind == Kind::Identifier {
				if config.variables == 'es6' {
					if variable == VariableModifier.Let {
						exp.code('let ')
					}
					else {
						exp.code('const ')
					}
				}
				else {
					exp.code('var ')
					
					node.rename(data.name.name)
				}
				
				exp.compile(data.name, config)
			}
			else {
				if data.name.kind == Kind::ArrayBinding || data.name.kind == Kind::ObjectBinding || config.variables == 'es5' {
					exp.code('var ')
				}
				else {
					if variable == VariableModifier.Let {
						exp.code('let ')
					}
					else {
						exp.code('const ')
					}
				}
				
				exp.compile(data.name, config)
			}
			
			if(data.autotype) {
				let type = data.type
				
				if !type && data.init {
					type = data.init
				}
				
				$variable.define(exp, data.name, $variable.kind(data.type), type)
			}
			else {
				$variable.define(exp, data.name, $variable.kind(data.type), data.type)
			}
			
			if data.init {
				if data.name.kind == Kind::Identifier {
					exp.reference(data.name.name)
				}
				
				exp.code(' = ').compile(data.init, config, Mode.NoIndent | Mode.Assignment)
			}
		} // }}}
		Kind::WhileStatement => { // {{{:
			node
				.newControl()
				.code('while(')
				.compile(data.condition, config)
				.code(')')
				.step()
				.compile(data.body, config)
		} // }}}
		=> { // {{{
			console.error(data)
			throw new Error('Unknow kind ' + data.kind)
		} // }}}
	}
}

const $continuous = {
	class(node, data, config, mode, variable) { // {{{
		let clazz = node
			.newControl()
			.code('class ')
			.compile(variable.name, config, Mode.Key)
		
		if data.extends {
			variable.extends = node.getVariable(data.extends.name)
		
			if variable.extends {
				clazz.code(' extends ', variable.extends.name.name)
			}
			else {
				throw new Error('Undefined class ' + data.extends.name + ' at line ' + data.extends.start.line)
			}
		}
		
		clazz.step()
		
		let ctrl
		if !variable.extends {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()
			
			ctrl.newExpression().code('this.__ks_init()')
			ctrl.newExpression().code('this.__ks_cons(arguments)')
		}
		
		let reflect = {
			inits: 0
			constructors: []
			instanceVariables: {}
			classVariables: {}
			instanceMethods: {}
			classMethods: {}
		}
		
		let noinit = Type.isEmptyObject(variable.instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of variable.instanceVariables while noinit {
				if field.data.defaultValue {
					noinit = false
				}
			}
		}
		
		if noinit {
			if variable.extends {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.newExpression()
					.code(variable.extends.name.name, '.prototype.__ks_init.call(this)')
			}
			else {
				clazz.newControl().code('__ks_init()').step()
			}
		}
		else {
			++reflect.inits
			
			ctrl = clazz
				.newControl()
				.code('__ks_init_1()')
				.step()
			
			$variable.define(ctrl, {
				kind: Kind::Identifier
				name: 'this'
			}, VariableKind::Variable, {
				kind: Kind::TypeReference
				typeName: variable.name
			})
			
			for name, field of variable.instanceVariables {
				if field.data.defaultValue {
					ctrl
						.newExpression()
						.code('this.' + name + ' = ')
						.compile(field.data.defaultValue, config)
				}
			}
			
			ctrl = clazz.newControl().code('__ks_init()').step()
			
			if variable.extends {
				ctrl.newExpression().code(variable.extends.name.name, '.prototype.__ks_init.call(this)')
			}
			
			ctrl.newExpression().code(variable.name.name, '.prototype.__ks_init_1.call(this)')
		}
		
		for method in variable.constructors {
			$continuous.constructor(clazz, method.data, config, method.signature, reflect, variable)
		}
		
		$helper.constructor(clazz, reflect, variable)
		
		for name, methods of variable.instanceMethods {
			for method in methods {
				$continuous.instanceMethod(clazz, method.data, config, method.signature, reflect, name, variable)
			}
			
			$helper.instanceMethod(clazz, reflect, name, variable)
		}
		
		for name, methods of variable.classMethods {
			for method in methods {
				$continuous.classMethod(clazz, method.data, config, method.signature, reflect, name, variable)
			}
			
			$helper.classMethod(clazz, reflect, name, variable)
		}
		
		for name, field of variable.instanceVariables {
			reflect.instanceVariables[name] = field.signature
		}
		
		for name, field of variable.classVariables {
			$continuous.classVariable(node, field.data, config, field.signature, reflect, name, variable)
		}
		
		$helper.reflect(node, variable.name, reflect)
		
		let references = node.module().listReferences(variable.name.name)
		if references {
			for ref in references {
				node.newExpression().code(ref)
			}
		}
		
		variable.constructors = reflect.constructors
		variable.instanceVariables = reflect.instanceVariables
		variable.classVariables = reflect.classVariables
		variable.instanceMethods = reflect.instanceMethods
		variable.classMethods = reflect.classMethods
	} // }}}
	classMethod(node, data, config, signature, reflect, name, clazz) { // {{{
		if !reflect.classMethods[name] {
			reflect.classMethods[name] = []
		}
		let index = reflect.classMethods[name].length
		
		reflect.classMethods[name].push(signature)
		
		node.newFunction().operation(func(node) {
			node.code('static __ks_sttc_' + name + '_' + index + '(')
			
			$function.parameters(node, data, config, func(node) {
				node.code(')').step()
			})
			
			$method.fields(node, data.parameters, config, clazz)
			
			if data.body.kind == Kind.Block {
				node.compile(data.body, config)
			}
			else {
				node.newExpression().code('return ').compile(data.body, config)
			}
		})
	} // }}}
	classVariable(node, data, config, signature, reflect, name, clazz) { // {{{
		reflect.classVariables[name] = signature
		
		if data.defaultValue {
			node.newExpression().compile(clazz.name, config).code(`.\(name) = `).compile(data.defaultValue, config)
		}
	} // }}}
	constructor(node, data, config, signature, reflect, clazz) { // {{{
		let index = reflect.constructors.length
		
		reflect.constructors.push(signature)
		
		node.newFunction().operation(func(node) {
			node.code('__ks_cons_' + index + '(')
			
			$function.parameters(node, data, config, func(node) {
				node.code(')').step()
			})
			
			let variable = $variable.define(node, {
				kind: Kind::Identifier
				name: 'this'
			}, VariableKind::Variable, {
				kind: Kind::TypeReference
				typeName: clazz.name
			})
			
			variable.callReplacement = func(node, data, list) {
				node.code(clazz.name.name, '.prototype.__ks_cons.call(this, [')
				
				for i from 0 til data.arguments.length {
					if i {
						node.code(', ')
					}
					
					node.compile(data.arguments[i], config)
				}
				
				node.code('])')
			}
			
			if clazz.extends {
				variable = $variable.define(node, {
					kind: Kind::Identifier,
					name: 'super'
				}, VariableKind::Variable)
				
				variable.callReplacement = func(node, data, list) {
					node.code(clazz.extends.name.name, '.prototype.__ks_cons.call(this, [')
					
					for i from 0 til data.arguments.length {
						if i {
							node.code(', ')
						}
						
						node.compile(data.arguments[i], config)
					}
					
					node.code('])')
				}
			}
			
			$method.fields(node, data.parameters, config, clazz)
			
			if data.body {
				if data.body.kind == Kind.Block {
					node.compile(data.body, config)
				}
				else {
					node.newExpression().compile(data.body, config)
				}
			}
		})
	} // }}}
	instanceMethod(node, data, config, signature, reflect, name, clazz) { // {{{
		if !reflect.instanceMethods[name] {
			reflect.instanceMethods[name] = []
		}
		let index = reflect.instanceMethods[name].length
		
		reflect.instanceMethods[name].push(signature)
		
		node.newFunction().operation(func(node) {
			node.code('__ks_func_' + name + '_' + index + '(')
			
			$function.parameters(node, data, config, func(node) {
				node.code(')').step()
			})
			
			$variable.define(node, {
				kind: Kind::Identifier
				name: 'this'
			}, VariableKind::Variable, {
				kind: Kind::TypeReference
				typeName: clazz.name
			})
			
			if clazz.extends {
				variable = $variable.define(node, {
					kind: Kind::Identifier,
					name: 'super'
				}, VariableKind::Variable)
				
				variable.callReplacement = func(node, data, list) {
					node.code('super.' + name + '(')
					
					for i from 0 til data.arguments.length {
						if i {
							node.code(', ')
						}
						
						node.compile(data.arguments[i], config)
					}
					
					node.code(')')
				}
			}
			
			$method.fields(node, data.parameters, config, clazz)
			
			if data.body.kind == Kind.Block {
				node.compile(data.body, config)
			}
			else {
				node.newExpression().code('return ').compile(data.body, config)
			}
		})
	} // }}}
	methodCall(variable, fnName, argName, retCode, node, method, index) { // {{{
		if method.max == 0 {
			node.code(retCode, variable.name.name, '.', fnName, index, '.apply(this)')
		}
		else {
			node.code(retCode, variable.name.name, '.', fnName, index, '.apply(this, ', argName, ')')
		}
	} // }}}
}

const $extern = {
	classMember(data, variable, node) { // {{{
		switch(data.kind) {
			Kind::FieldDeclaration => {
				console.error(data)
				throw new Error('Not Implemented')
			}
			Kind::MethodAliasDeclaration => {
				if data.name.name == variable.name.name {
					console.error(data)
					throw new Error('Not Implemented')
				}
				else {
				}
			}
			Kind::MethodDeclaration => {
				if data.name.name == variable.name.name {
					variable.constructors.push($function.signature(data, node))
				}
				else {
					let instance = true
					for i from 0 til data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == MemberModifier::Static
					}
					
					let methods
					if instance {
						methods = variable.instanceMethods[data.name.name] || (variable.instanceMethods[data.name.name] = [])
					}
					else {
						methods = variable.classMethods[data.name.name] || (variable.classMethods[data.name.name] = [])
					}
					
					methods.push($function.signature(data, node))
				}
			}
			=> {
				console.error(data)
				throw new Error('Unknow kind ' + data.kind)
			}
		}
	} // }}}
}

const $field = {
	prepare(data, node) { // {{{
		return {
			data: data,
			signature: $field.signature(data, node)
		}
	} // }}}
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
		
		signature.type = type if data.type && (type ?= $signature.type(data.type, node))
		
		return signature
	} // }}}
}

const $final = {
	callee(data, node) { // {{{
		let variable = $variable.fromAST(data, node)
		//console.log('callee.data', data)
		//console.log('callee.variable', variable)
		
		if variable {
			if variable is Array {
				return {
					variables: variable,
					instance: true
				}
			}
			else if variable.kind == VariableKind::Class && variable.final {
				if variable.final.classMethods[data.property.name] {
					return {
						variable: variable,
						instance: false
					}
				}
				else if variable.final.instanceMethods[data.property.name] {
					return {
						variable: variable,
						instance: true
					}
				}
			}
		}
		
		return false
	} // }}}
	class(node, data, config, mode, variable) { // {{{
		let clazz = node
			.newControl()
			.code('class ')
			.compile(variable.name, config, Mode.Key)
		
		if data.extends {
			variable.extends = node.getVariable(data.extends.name)
		
			if variable.extends {
				clazz.code(' extends ', variable.extends.name.name)
			}
			else {
				throw new Error('Undefined class ' + data.extends.name + ' at line ' + data.extends.start.line)
			}
		}
		
		clazz.step()
		
		let noinit = Type.isEmptyObject(variable.instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of variable.instanceVariables while noinit {
				if field.data.defaultValue {
					noinit = false
				}
			}
		}
		
		let ctrl
		if variable.extends {
			ctrl = clazz
				.newControl()
				.code('__ks_init()')
				.step()
				
			ctrl.newExpression().code(variable.extends.name.name, '.prototype.__ks_init.call(this)')
			
			if !noinit {
				$variable.define(ctrl, {
					kind: Kind::Identifier
					name: 'this'
				}, VariableKind::Variable, {
					kind: Kind::TypeReference
					typeName: variable.name
				})
				
				for name, field of variable.instanceVariables {
					if field.data.defaultValue {
						ctrl
							.newExpression()
							.code('this.' + name + ' = ')
							.compile(field.data.defaultValue, config)
					}
				}
			}
		}
		else {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()
		
			if !noinit {
				$variable.define(ctrl, {
					kind: Kind::Identifier
					name: 'this'
				}, VariableKind::Variable, {
					kind: Kind::TypeReference
					typeName: variable.name
				})
				
				for name, field of variable.instanceVariables {
					if field.data.defaultValue {
						ctrl
							.newExpression()
							.code('this.' + name + ' = ')
							.compile(field.data.defaultValue, config)
					}
				}
			}
			ctrl.newExpression().code('this.__ks_cons(arguments)')
		}
		
		let reflect = {
			final: true
			inits: 0
			constructors: []
			instanceVariables: {}
			classVariables: {}
			instanceMethods: {}
			classMethods: {}
		}
		
		for method in variable.constructors {
			$continuous.constructor(clazz, method.data, config, method.signature, reflect, variable)
		}
		
		$helper.constructor(clazz, reflect, variable)
		
		for name, methods of variable.instanceMethods {
			for method in methods {
				$continuous.instanceMethod(clazz, method.data, config, method.signature, reflect, name, variable)
			}
			
			$helper.instanceMethod(clazz, reflect, name, variable)
		}
		
		for name, methods of variable.classMethods {
			for method in methods {
				$continuous.classMethod(clazz, method.data, config, method.signature, reflect, name, variable)
			}
			
			$helper.classMethod(clazz, reflect, name, variable)
		}
		
		for name, field of variable.instanceVariables {
			reflect.instanceVariables[name] = field.signature
		}
		
		for name, field of variable.classVariables {
			$continuous.classVariable(node, field.data, config, field.signature, reflect, name, variable)
		}
		
		$helper.reflect(node, variable.name, reflect)
		
		let references = node.module().listReferences(variable.name.name)
		if references {
			for ref in references {
				node.newExpression().code(ref)
			}
		}
		
		variable.constructors = reflect.constructors
		variable.instanceVariables = reflect.instanceVariables
		variable.classVariables = reflect.classVariables
		variable.instanceMethods = reflect.instanceMethods
		variable.classMethods = reflect.classMethods
	} // }}}
}

const $function = {
	arity(parameter) { // {{{
		for i from 0 til parameter.modifiers.length {
			if parameter.modifiers[i].kind == ParameterModifier.Rest {
				return parameter.modifiers[i].arity
			}
		}
		
		return null
	}, // }}}
	parameters(node, data, config, fn) { // {{{
		if config.parameters == 'es5' {
			$function.parametersES5(node, data, config, fn)
		}
		else if config.parameters == 'es6' {
			$function.parametersES6(node, data, config, fn)
		}
		else {
			$function.parametersKS(node, data, config, fn)
		}
	} // }}}
	parametersES5(node, data, config, fn) { // {{{
		let signature = $function.signature(data, node)
		
		for parameter, i in data.parameters {
			if signature.parameters[i].rest {
				throw new Error(`Parameter can't be a rest parameter at line \(parameter.start.line)`)
			}
			else if parameter.defaultValue {
				throw new Error(`Parameter can't have a default value at line \(parameter.start.line)`)
			}
			else if parameter.type && parameter.type.nullable {
				throw new Error(`Parameter can't be nullable at line \(parameter.start.line)`)
			}
			else if !parameter.name {
				throw new Error(`Parameter must be named at line \(parameter.start.line)`)
			}
			
			if i {
				node.code(', ')
			}
			
			node.parameter(parameter.name, config, parameter.type)
		}
		
		fn(node)
	} // }}}
	parametersES6(node, data, config, fn) { // {{{
		let signature = $function.signature(data, node)
		let rest = false
		
		for parameter, i in data.parameters {
			if !parameter.name {
				throw new Error(`Parameter must be named at line \(parameter.start.line)`)
			}
			
			if i {
				node.code(', ')
			}
			
			if signature.parameters[i].rest {
				node.code('...')
				
				rest = true
				
				node.parameter(parameter.name, config, {
					kind: Kind::TypeReference
					typeName: {
						kind: Kind::Identifier
						name: 'Array'
					}
				})
			}
			else if rest {
				throw new Error(`Parameter must be before the rest parameter at line \(parameter.start.line)`)
			}
			else {
				node.parameter(parameter.name, config, parameter.type)
			}
			
			if parameter.type {
				if parameter.type.nullable && !parameter.defaultValue {
					node.code(' = null')
				}
			}
			
			if parameter.defaultValue {
				node.code(' = ').compile(parameter.defaultValue, config)
			}
		}
		
		fn(node)
	} // }}}
	parametersKS(node, data, config, fn) { // {{{
		let signature = $function.signature(data, node)
		//console.log(signature)
		
		let parameter, ctrl, ctrl2, name, arity
		let maxb = 0
		let rb = 0
		let db = 0
		let rr = 0
		let maxa = 0
		let ra = 0
		let fr = false
		
		let rest = -1
		for parameter, i in signature.parameters {
			if rest != -1 {
				if parameter.min {
					ra += parameter.min
				}
				
				maxa += parameter.max
				
				if parameter.rest {
					fr = true
				}
			}
			else if parameter.max == Infinity {
				rest = i
				rr = parameter.min
			}
			else {
				if parameter.min == 0 {
					++db
				}
				else {
					rb += parameter.min
				}
				
				maxb += parameter.max
				
				if parameter.rest {
					fr = true
				}
			}
		}
		
		let inc = false
		let l = rest != -1 ? rest : data.parameters.length
		
		if (rest != -1 && !fr && (db == 0 || db + 1 == rest)) || (rest == -1 && ((!signature.async && signature.max == l && (db == 0 || db == l) || (signature.async && signature.max == l + 1 && (db == 0 || db == l + 1))))) { // {{{
			let names = []
			
			for i from 0 til l {
				parameter = data.parameters[i]
				
				if i {
					node.code(', ')
				}
				
				if parameter.name {
					names[i] = parameter.name
				}
				else {
					names[i] = node.newTempName()
				}
				
				node.parameter(names[i], config, parameter.type)
				
				if parameter.type {
					if parameter.type.nullable && !parameter.defaultValue {
						node.code(' = null')
					}
				}
			}
			
			if !ra && rest != -1 && (signature.parameters[rest].type == 'Any' || !maxa) {
				if rest {
					node.code(', ')
				}
				
				if data.parameters[rest].name {
					names[rest] = data.parameters[rest].name
				}
				else {
					names[rest] = node.newTempName()
				}
				
				node.code('...').parameter(names[rest], config, {
					kind: Kind::TypeReference
					typeName: {
						kind: Kind::Identifier
						name: 'Array'
					}
				})
			}
			else if signature.async && !ra {
				if l {
					node.code(', ')
				}
				
				node.parameter('__ks_cb', config)
			}
			
			fn(node)
			
			if ra {
				node
					.newControl()
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.newExpression()
					.code('throw new Error("Wrong number of arguments")')
			}
			
			for i from 0 til l {
				parameter = data.parameters[i]
				
				if parameter.name && (!parameter.type || !parameter.type.nullable || parameter.defaultValue) {
					ctrl = node
						.newControl()
						.code('if(')
						.compile(parameter.name, config)
						.code(' === undefined')
					
					if !parameter.type || !parameter.type.nullable {
						ctrl
							.code(' || ')
							.compile(parameter.name, config)
							.code(' === null')
					}
						
					ctrl
						.code(')')
						.step()
					
					if parameter.defaultValue {
						ctrl
							.newExpression()
							.compile(parameter.name, config)
							.code(' = ')
							.compile(parameter.defaultValue, config)
					}
					else {
						ctrl.newExpression().code('throw new Error("Missing parameter \'').compile(parameter.name, config).code('\'")')
					}
				}
				
				if !$type.isAny(parameter.type) {
					ctrl = node.newControl()
					
					ctrl.code('if(')
					
					if parameter.type.nullable {
						ctrl
							.compile(names[i], config)
							.code(' !== null && ')
					}
					
					ctrl.code('!')
					
					$type.check(ctrl, names[i], parameter.type, config)
					
					ctrl
						.code(')')
						.step()
						.newExpression()
						.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
				}
			}
			
			if ra {
				parameter = data.parameters[rest]
				
				if signature.parameters[rest].type == 'Any' {
					if parameter.name {
						node.newExpression().code($variable.scope(config), '__ks_i')
						
						node
							.newExpression()
							.code($variable.scope(config))
							.parameter(parameter.name, config)
							.code(' = arguments.length > ' + (maxb + ra) + ' ? Array.prototype.slice.call(arguments, ' + maxb + ', __ks_i = arguments.length - ' + ra + ') : (__ks_i = ' + maxb + ', [])')
					}
					else {
						node.newExpression().code($variable.scope(config), '__ks_i = arguments.length > ' + (maxb + ra) + ' ? arguments.length - ' + ra + ' : ' + maxb)
					}
				}
				else {
					node.newExpression().code($variable.scope(config), '__ks_i')
					
					if parameter.name {
						node
							.newExpression()
							.code($variable.scope(config))
							.parameter(parameter.name, config)
							.code(' = []')
					}
				}
			}
			else if rest != -1 && signature.parameters[rest].type != 'Any' && maxa {
				parameter = data.parameters[rest]
				
				if maxb {
				}
				else {
					node.newExpression().code($variable.scope(config), '__ks_i = -1')
				}
			
				if parameter.name {
					node
						.newExpression()
						.code($variable.scope(config))
						.parameter(parameter.name, config, {
							kind: Kind::TypeReference
							typeName: {
								kind: Kind::Identifier
								name: 'Array'
							}
						})
						.code(' = []')
				}
				
				ctrl = node
					.newControl()
					.code('while(')
				
				$type.check(ctrl, 'arguments[++__ks_i]', parameter.type, config)
				
				ctrl
					.code(')')
					.step()
				
				if parameter.name {
					ctrl
						.newExpression()
						.parameter(parameter.name, config)
						.code('.push(arguments[__ks_i])')
				}
			}
			
			if rest != -1 {
				parameter = data.parameters[rest]
				
				if (arity = $function.arity(parameter)) && arity.min {
					node
						.newControl()
						.code('if(')
						.parameter(parameter.name, config)
						.code('.length < ', arity.min, ')')
						.step()
						.newExpression()
						.code('throw new Error("Wrong number of arguments")')
				}
			}
			else if signature.async && !ra {
				node
					.newControl()
					.code('if(!Type.isFunction(__ks_cb))')
					.step()
					.newExpression()
					.code('throw new Error("Invalid callback")')
			}
		} // }}}
		else { // {{{
			fn(node)
			
			if signature.min {
				node
					.newControl()
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.newExpression()
					.code('throw new Error("Wrong number of arguments")')
			}
				
			node.newExpression().code($variable.scope(config), '__ks_i = -1')
			
			let required = rb
			let optional = 0
			
			for i from 0 til l {
				parameter = data.parameters[i]
				
				if parameter.name {
					$variable.define(node, parameter.name, $variable.kind(parameter.type), parameter.type)
				}
				
				if arity = $function.arity(parameter) { // {{{
					required -= arity.min
					
					if parameter.name {
						if $type.isAny(parameter.type) {
							if required {
								node
									.newExpression()
									.code($variable.scope(config))
									.compile(parameter.name, config)
									.code(' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - ', required, ', __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									node.newExpression().code('__ks_i += ').parameter(parameter.name, config).code('.length')
								}
							}
							else {
								node
									.newExpression()
									.code($variable.scope(config))
									.compile(parameter.name, config)
									.code(' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									node.newExpression().code('__ks_i += ').parameter(parameter.name, config).code('.length')
								}
							}
						}
						else {
							node
								.newExpression()
								.code($variable.scope(config))
								.compile(parameter.name, config)
								.code(' = []')
							
							ctrl = node.newControl()
							
							if required {
								ctrl.code('while(__ks_i < arguments.length - ', required, ' && ')
							}
							else {
								ctrl.code('while(__ks_i + 1 < arguments.length && ')
							}
							
							ctrl
								.compile(parameter.name, config)
								.code('.length < ', arity.max, ' )')
								.step()
						}
					}
					else {
					}
					
					optional += arity.max - arity.min
				} // }}}
				else { // {{{
					if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
						ctrl = node
							.newControl()
							.code('if(arguments.length > ', signature.min + optional, ')')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[++__ks_i]')
							}
							else {
								ctrl
									.newExpression()
									.code('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl()
								.code('if(')
							
							$type.check(ctrl2, 'arguments[__ks_i + 1]', parameter.type, config)
							
							ctrl2
								.code(')')
								.step()
								.newExpression()
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[++__ks_i]')
							
							ctrl2
								.step()
								.code('else ')
								.step()
							
							if rest == -1 {
								ctrl2
									.newExpression()
									.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
							}
							else if parameter.defaultValue {
								ctrl2
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl2
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
						
						if parameter.name {
							ctrl.step().code('else ').step()
						
							if parameter.defaultValue {
								ctrl
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
						
						++optional
					}
					else {
						if $type.isAny(parameter.type) {
							if parameter.name {
								node
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[++__ks_i]')
							}
							else {
								node
									.newExpression()
									.code('++__ks_i')
							}
						}
						else {
							if parameter.name {
								ctrl = node
									.newControl()
									.code('if(')
								
								$type.check(ctrl, 'arguments[++__ks_i]', parameter.type, config)
								
								ctrl
									.code(')')
									.step()
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[__ks_i]')
								
								ctrl
									.step()
									.code('else ')
									.newExpression()
									.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
							}
							else {
								ctrl = node
									.newControl()
									.code('if(!')
								
								$type.check(ctrl, 'arguments[++__ks_i]', parameter.type, config)
								
								ctrl
									.code(')')
									.step()
									.newExpression()
									.code('throw new Error("Wrong type of arguments")')
							}
						}
						
						--required
					}
				}
				// }}}
			}
			
			if rest != -1 { // {{{
				parameter = data.parameters[rest]
				
				if ra {
					if parameter.name {
						node
							.newExpression()
							.code($variable.scope(config))
							.parameter(parameter.name, config, {
								kind: Kind::TypeReference
								typeName: {
									kind: Kind::Identifier
									name: 'Array'
								}
							})
							.code(' = arguments.length > __ks_i + ', ra + 1, ' ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - ' + ra + ') : []')
						
						if l + 1 < data.parameters.length {
							node.newExpression().code('__ks_i += ').parameter(parameter.name, config).code('.length')
						}
					}
					else if l + 1 < data.parameters.length {
						node
							.newControl()
							.code('if(arguments.length > __ks_i + ' , ra + 1, ')')
							.step()
							.newExpression().code('__ks_i = arguments.length - ', ra + 1)
					}
				}
				else {
					if parameter.name {
						node
							.newExpression()
							.code($variable.scope(config))
							.parameter(parameter.name, config, {
								kind: Kind::TypeReference
								typeName: {
									kind: Kind::Identifier
									name: 'Array'
								}
							})
							.code(' = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : []')
						
						if l + 1 < data.parameters.length {
							node.newExpression().code('__ks_i += ').parameter(parameter.name, config).code('.length')
						}
					}
				}
			} // }}}
		} // }}}
		
		if ra || maxa { // {{{
			if ra != maxa && signature.parameters[rest].type != 'Any' {
				if ra {
					node
						.newExpression()
						.code($variable.scope(config), '__ks_m = __ks_i + ', ra)
				}
				else {
					node
						.newExpression()
						.code($variable.scope(config), '__ks_m = __ks_i')
				}
			}
			
			for i from rest + 1 til data.parameters.length {
				parameter = data.parameters[i]
				
				if parameter.name {
					$variable.define(node, parameter.name, $variable.kind(parameter.type), parameter.type)
				}
				
				if arity = $function.arity(parameter) { // {{{
					if arity.min {
						if parameter.name {
							if $type.isAny(parameter.type) {
								node
									.newExpression()
									.code($variable.scope(config))
									.compile(parameter.name, config)
									.code(' = Array.prototype.slice.call(arguments, __ks_i + 1, __ks_i + ', arity.min + 1, ')')
								
								if i + 1 < data.parameters.length {
									node.newExpression().code('__ks_i += ').parameter(parameter.name, config).code('.length')
								}
							}
							else {
							}
						}
						else {
						}
					}
					else {
					}
				} // }}}
				else if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
					if signature.parameters[rest].type == 'Any' {
						if parameter.name {
							if parameter.defaultValue {
								node
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								node
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
					}
					else {
						ctrl = node
							.newControl()
							.code('if(arguments.length > __ks_m)')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[', inc ? '++' : '', '__ks_i]')
							}
							else {
								ctrl
									.newExpression()
									.code('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl()
								.code('if(')
							
							$type.check(ctrl2, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type, config)
							
							ctrl2
								.code(')')
								.step()
								.newExpression()
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[__ks_i]')
							
							ctrl2
								.step()
								.code('else ')
							
							if parameter.defaultValue {
								ctrl2
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl2
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
						
						if parameter.name {
							ctrl.step().code('else ').step()
						
							if parameter.defaultValue {
								ctrl
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl
									.newExpression()
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
						
						if !inc {
							inc = true
						}
					}
				}
				else {
					if $type.isAny(parameter.type) {
						if parameter.name {
							node
								.newExpression()
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[', inc ? '++' : '', '__ks_i]')
						}
						else {
							node
								.newExpression()
								.code(inc ? '++' : '', '__ks_i')
						}
					}
					else {
						if parameter.name {
							ctrl = node
								.newControl()
								.code('if(')
							
							$type.check(ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type, config)
							
							ctrl
								.code(')')
								.step()
								.newExpression()
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[__ks_i]')
							
							ctrl
								.step()
								.code('else ')
								.newExpression()
								.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
						}
						else {
							ctrl = node
								.newControl()
								.code('if(!')
							
							$type.check(ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type, config)
							
							ctrl
								.code(')')
								.step()
								.newExpression()
								.code('throw new Error("Wrong type of arguments")')
						}
					}
					
					if !inc {
						inc = true
					}
				}
			}
		} // }}}
	}, // }}}
	signature(data, node) { // {{{
		let signature = {
			min: 0,
			max: 0,
			parameters: []
		}
		
		if data.modifiers {
			for modifier in data.modifiers {
				if modifier.kind == FunctionModifier::Async {
					signature.async = true
				}
			}
		}
		
		for parameter in data.parameters {
			signature.parameters.push(parameter = $function.signatureParameter(parameter, node))
			
			if(parameter.max == Infinity) {
				if(signature.max == Infinity) {
					throw new Error('Function can have only one rest parameter')
				}
				else {
					signature.max = Infinity
				}
			}
			else {
				signature.max += parameter.max
			}
			
			signature.min += parameter.min
		}
		
		if signature.async {
			signature.parameters.push({
				type: 'Function',
				min: 1,
				max: 1
			})
			
			++signature.min
			++signature.max
		}
		
		return signature
	}, // }}}
	signatureParameter(parameter, node) { // {{{
		let signature = {
			type: $signature.type(parameter.type, node),
			min: parameter.defaultValue || (parameter.type && parameter.type.nullable) ? 0 : 1,
			max: 1
		}
		
		if parameter.modifiers {
			for modifier in parameter.modifiers {
				if(modifier.kind == ParameterModifier.Rest) {
					signature.rest = true
					
					if(modifier.arity) {
						signature.min = modifier.arity.min
						signature.max = modifier.arity.max
					}
					else {
						signature.min = 0
						signature.max = Infinity
					}
				}
			}
		}
		
		return signature
	} // }}}
}

const $helper = {
	classMethod(clazz, reflect, name, variable) { // {{{
		let extend = false
		if variable.extends {
			extend = func(node, ctrl?) {
				if variable.extends.instanceMethods[name] {
					node.code('return ' + variable.extends.name.name + '.' + name + '.apply(null, arguments)')
				}
				else {
					ctrl
						.step()
						.code('else if(' + variable.extends.name.name + '.' + name + ')')
						.step()
						.code('return ' + variable.extends.name.name + '.' + name + '.apply(null, arguments)')
					
					node.code('throw new Error("Wrong number of arguments")')
				}
			}
		}
		
		$helper.methods(extend, clazz.newControl(), 'static ' + name + '()', reflect.classMethods[name], $continuous.methodCall^^(variable, '__ks_sttc_' + name + '_', 'arguments', 'return '), 'arguments', 'classMethods.' + name, true)
	} // }}}
	constructor(clazz, reflect, variable) { // {{{
		let extend = false
		if variable.extends {
			extend = func(node, ctrl?) {
				if ctrl {
					ctrl
						.step()
						.code('else')
						.step()
						.code(variable.extends.name.name + '.prototype.__ks_cons.call(this, args)')
				}
				else {
					node.code(variable.extends.name.name + '.prototype.__ks_cons.call(this, args)')
				}
			}
		}
		
		$helper.methods(extend, clazz.newControl(), '__ks_cons(args)', reflect.constructors, $continuous.methodCall^^(variable, 'prototype.__ks_cons_', 'args', ''), 'args', 'constructors', false)
	} // }}}
	decide(node, type, index, path, argName) { // {{{
		if $typeofs[type] {
			node.code($typeofs[type] + '(' + argName + '[' + index + '])')
		}
		else {
			node.code('Type.is(' + argName + '[' + index + '], ' + path + ')')
		}
	} // }}}
	instanceMethod(clazz, reflect, name, variable) { // {{{
		let extend = false
		if variable.extends {
			extend = func(node, ctrl?) {
				if variable.extends.instanceMethods[name] {
					node.code('return ' + variable.extends.name.name + '.prototype.' + name + '.apply(this, arguments)')
				}
				else {
					ctrl
						.step()
						.code('else if(' + variable.extends.name.name + '.prototype.' + name + ')')
						.step()
						.code('return ' + variable.extends.name.name + '.prototype.' + name + '.apply(this, arguments)')
					
					node.code('throw new Error("Wrong number of arguments")')
				}
			}
		}
		
		$helper.methods(extend, clazz.newControl(), name + '()', reflect.instanceMethods[name], $continuous.methodCall^^(variable, 'prototype.__ks_func_' + name + '_', 'arguments', 'return '), 'arguments', 'instanceMethods.' + name, true)
	} // }}}
	methods(extend, node, header, methods, call, argName, refName, returns) { // {{{
		node.code(header).step()
		
		let method
		if methods.length == 0 {
			if extend {
				extend(node)
			}
			else {
				node
					.newControl()
					.code('if(' + argName + '.length !== 0)')
					.step()
					.code('throw new Error("Wrong number of arguments")')
			}
		}
		else if methods.length == 1 {
			method = methods[0]
			
			if method.min == 0 && method.max >= Infinity {
				call(node, method, 0)
			}
			else {
				if method.min == method.max {
					let ctrl = node.newControl()
					
					ctrl.code('if(' + argName + '.length === ' + method.min + ')').step()
					
					call(ctrl, method, 0)
					
					if returns {
						if extend {
							extend(node, ctrl)
						}
						else {
							node.code('throw new Error("Wrong number of arguments")')
						}
					}
					else {
						if extend {
							extend(node, ctrl)
						}
						else {
							ctrl.step().code('else').step().code('throw new Error("Wrong number of arguments")')
						}
					}
				}
				else if method.max < Infinity {
					let ctrl = node.newControl()
					
					ctrl.code('if(' + argName + '.length >= ' + method.min + ' && ' + argName + '.length <= ' + method.max + ')').step()
					
					call(ctrl, method, 0)
					
					if returns {
						node.code('throw new Error("Wrong number of arguments")')
					}
					else {
						ctrl.step().code('else').step().code('throw new Error("Wrong number of arguments")')
					}
				}
				else {
					call(node, method, 0)
				}
			}
		}
		else {
			let groups = []
			
			let nf, group
			for method, index in methods {
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
			
			let ctrl = node.newControl()
			nf = true
			
			for group in groups {
				if group.min == group.max {
					if ctrl.length() > 1 {
						ctrl.code('else ')
					}
					
					ctrl.code('if(' + argName + '.length === ' + group.min + ')').step()
					
					if group.methods.length == 1 {
						call(ctrl, group.methods[0], group.methods[0].index)
					}
					else {
						$helper.methodCheck(ctrl, group, call, argName, refName, returns)
					}
					
					ctrl.step()
				}
				else if group.max < Infinity {
					if ctrl.length() > 1 {
						ctrl.code('else ')
					}
					
					ctrl.code('if(' + argName + '.length >= ' + group.min + ' && arguments.length <= ' + group.max + ')').step()
					
					if group.methods.length == 1 {
						call(ctrl, group.methods[0], group.methods[0].index)
					}
					else {
						$helper.methodCheck(ctrl, group, call, argName, refName, returns)
					}
					
					ctrl.step()
				}
				else {
					nf = false
					
					if ctrl.length() > 1 {
						ctrl.code('else')
					}
					
					ctrl.step()
					
					if group.methods.length == 1 {
						call(ctrl, group.methods[0], group.methods[0].index)
					}
					else {
						$helper.methodCheck(ctrl, group, call, argName, refName, returns)
					}
					
					ctrl.step()
				}
			}
			
			if nf {
				if returns {
					node.code('throw new Error("Wrong number of arguments")')
				}
				else {
					ctrl.code('else').step().code('throw new Error("Wrong number of arguments")')
				}
			}
		}
	} // }}}
	methodCheck(node, group, call, argName, refName, returns) { // {{{
		if $helper.methodCheckTree(group.methods, 0, node, call, argName, refName, returns) {
			if returns {
				node.newExpression().code('throw new Error("Wrong type of arguments")')
			}
			else {
				node.code('else').step().code('throw new Error("Wrong type of arguments")')
			}
		}
	} // }}}
	methodCheckTree(methods, index, node, call, argName, refName, returns) { // {{{
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
				call(node, item.methods[0], item.methods[0].index)
				
				return false
			}
			else {
				return $helper.methodCheckTree(item.methods, index + 1, node, call, argName, refName, returns)
			}
		}
		else {
			let ctrl = node.newControl()
			let ne = true
			
			usages.sort(func(a, b) {
				return a.usage - b.usage
			})
			//console.log(JSON.stringify(usages, null, 2))
			
			for usage, u in usages {
				if usage.tree.length == usage.usage {
					item = usage.tree[0]
					
					if u + 1 == usages.length {
						if ctrl.length() > 1 {
							ctrl.code('else')
							
							ne = false
						}
					}
					else {
						if ctrl.length() > 1 {
							ctrl.code('else ')
						}
						
						ctrl.code('if(')
						
						$helper.decide(ctrl, item.type, index, item.path, argName)
						
						ctrl.code(')')
					}
					
					ctrl.step()
					
					if item.methods.length == 1 {
						call(ctrl, item.methods[0], item.methods[0].index)
					}
					else {
						$helper.methodCheckTree(item.methods, index + 1, ctrl, call, argName, refName, returns)
					}
					
					ctrl.step()
				}
				else {
					throw new Error('Not Implemented')
				}
			}
			
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
	reflect(node, name, reflect) { // {{{
		let classname = name.name
		
		let exp = node.newExpression()
		exp.code(classname + '.__ks_reflect = {').indent()
		
		if reflect.final {
			exp.newline().code('final: true,')
		}
		
		exp.newline().code('inits: ' + reflect.inits + ',')
		
		exp.newline().code('constructors: [').indent()
		for i from 0 til reflect.constructors.length {
			if i {
				exp.code(',')
			}
			
			$helper.reflectMethod(exp, reflect.constructors[i], 0, classname + '.__ks_reflect.constructors[' + i + '].type')
		}
		exp.unindent().newline().code('],')
		
		exp.newline().code('instanceVariables: {').indent()
		nf = false
		for name, variable of reflect.instanceVariables {
			if nf {
				exp.code(',')
			}
			else {
				nf = true
			}
			
			$helper.reflectVariable(exp, name, variable, 0, classname + '.__ks_reflect.instanceVariables.' + name)
		}
		exp.unindent().newline().code('},')
		
		exp.newline().code('classVariables: {').indent()
		nf = false
		for name, variable of reflect.classVariables {
			if nf {
				exp.code(',')
			}
			else {
				nf = true
			}
			
			$helper.reflectVariable(exp, name, variable, 0, classname + '.__ks_reflect.classVariables.' + name)
		}
		exp.unindent().newline().code('},')
		
		exp.newline().code('instanceMethods: {').indent()
		nf = false
		for name, methods of reflect.instanceMethods {
			if nf {
				exp.code(',')
			}
			else {
				nf = true
			}
			
			exp.newline().code(name + ': [').indent()
			
			for i from 0 til methods.length {
				if i {
					exp.code(',')
				}
				
				$helper.reflectMethod(exp, methods[i], 0, classname + '.__ks_reflect.instanceMethods.' + name + '[' + i + ']')
			}
			
			exp.unindent().newline().code(']')
		}
		exp.unindent().newline().code('},')
		
		exp.newline().code('classMethods: {').indent()
		nf = false
		for name, methods of reflect.classMethods {
			if nf {
				exp.code(',')
			}
			else {
				nf = true
			}
			
			exp.newline().code(name + ': [').indent()
			
			for i from 0 til methods.length {
				if i {
					exp.code(',')
				}
				
				$helper.reflectMethod(exp, methods[i], 0, classname + '.__ks_reflect.classMethods.' + name + '[' + i + ']')
			}
			
			exp.unindent().newline().code(']')
		}
		exp.unindent().newline().code('}')
		
		exp.unindent().newline().code('}')
	} // }}}
	reflectMethod(node, method, mode, path?) { // {{{
		if !(mode & Mode.NoLine) {
			node.newline()
		}
		
		node.code('{').indent()
		
		node.newline().code('access: ' + method.access + ',')
		node.newline().code('min: ' + method.min + ',')
		node.newline().code('max: ' + (method.max == Infinity ? 'Infinity' : method.max) + ',')
		
		node.newline().code('parameters: [').indent()
		
		for i from 0 til method.parameters.length {
			if i {
				node.code(',')
			}
			
			$helper.reflectParameter(node, method.parameters[i], path + '.parameters[' + i + ']')
		}
		
		node.unindent().newline().code(']')
		
		node.unindent().newline().code('}')
	} // }}}
	reflectParameter(node, parameter, path?) { // {{{
		node.newline().code('{').indent()
		
		node.newline().code('type: ' + $helper.type(parameter.type, node, path))
		node.code(',').newline().code('min: ', parameter.min)
		node.code(',').newline().code('max: ', parameter.max)
		
		node.unindent().newline().code('}')
	} // }}}
	reflectVariable(node, name, variable, mode, path?) { // {{{
		if !(mode & Mode.NoLine) {
			node.newline()
		}
		
		node.code(name, ': {').indent()
		
		node.newline().code('access: ' + variable.access)
		
		if(variable.type) {
			node.code(',').newline().code('type: ' + $helper.type(variable.type, node, path))
		}
		
		node.unindent().newline().code('}')
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
		else if type == 'Any' || type == '...' {
			return $quote(type)
		}
		else if $typeofs[type] {
			return $quote(type)
		}
		else {
			if variable ?= $variable.fromReflectType(type, node) {
				return type
			}
			else {
				node.module().addReference(type, path + '.type = ' + type)
				
				return $quote('#' + type)
			}
		}
	} // }}}
}

func $implement(node, data, config, variable) { // {{{
	switch data.kind {
		Kind::FieldDeclaration => {
			if variable.final {
				throw new Error('Can\'t add a field to a final class')
			}
			else {
				let type = $signature.type(data.type, node)
				
				node
					.newExpression()
					.code('Class.newField(' + $quote(data.name.name) + ', ' + $helper.type(type, node) + ')')
			}
		}
		Kind::MethodAliasDeclaration => {
			if data.name.name == variable.name.name {
				console.error(data)
				throw new Error('Not Implemented')
			}
			else {
				let instance = true
				for i from 0 til data.modifiers.length while instance {
					if data.modifiers[i].kind == MemberModifier.Static {
						instance = false
					}
				}
				
				if variable.final {
					if instance {
						if !variable.final.instanceMethods[data.name.name] {
							variable.final.instanceMethods[data.name.name] = true
						}
					}
					else {
						if !variable.final.classMethods[data.name.name] {
							variable.final.classMethods[data.name.name] = true
						}
					}
				}
				
				let exp = node
					.newExpression()
					.code('Class.', instance ? 'newInstanceMethod' : 'newClassMethod', '({')
					.indent()
				
				exp.newline().code('class: ').compile(variable.name, config).code(',')
				
				if data.name.kind == Kind::Identifier {
					exp.newline().code('name: ', $quote(data.name.name), ',')
				}
				else if data.name.kind == Kind.TemplateExpression {
					exp.newline().code('name: ').compile(data.name, config).code(',')
				}
				else {
					console.error(data.name)
					throw new Error('Not Implemented')
				}
				
				if variable.final {
					exp.newline().code('final: ', variable.final.name, ',')
				}
				
				exp.newline().code('method: ', $quote(data.alias.name))
				
				if data.arguments {
					exp.code(',').newline().code('arguments: [')
					
					for i from 0 til data.arguments.length {
						if i {
							exp.code(', ')
						}
						
						exp.compile(data.arguments[i], config)
					}
					exp.code(']')
				}
				
				exp.code(',').newline().code('signature: ')
				
				$helper.reflectMethod(exp, $method.signature(data, node), Mode.NoLine)
				
				exp.unindent().newline().code('})')
				
				if data.name.kind == Kind::Identifier {
					let methods
					if instance {
						variable.instanceMethods[data.name.name] = variable.instanceMethods[data.alias.name]
					}
					else {
						variable.classMethods[data.name.name] = variable.classMethods[data.alias.name]
					}
				}
			}
		}
		Kind::MethodDeclaration => {
			if data.name.name == variable.name.name {
				console.error(data)
				throw new Error('Not Implemented')
			}
			else {
				let instance = true
				for i from 0 til data.modifiers.length while instance {
					if data.modifiers[i].kind == MemberModifier.Static {
						instance = false
					}
				}
				
				if variable.final {
					if instance {
						if !variable.final.instanceMethods[data.name.name] {
							variable.final.instanceMethods[data.name.name] = true
						}
					}
					else {
						if !variable.final.classMethods[data.name.name] {
							variable.final.classMethods[data.name.name] = true
						}
					}
				}
				
				node.newExpression(Mode.NoIndent).newFunction().operation(func(ctrl) {
					ctrl
						.code('Class.', instance ? 'newInstanceMethod' : 'newClassMethod', '({')
						.indent()
					
					ctrl.newline().code('class: ').compile(variable.name, config).code(',')
					
					if data.name.kind == Kind::Identifier {
						ctrl.newline().code('name: ', $quote(data.name.name), ',')
					}
					else if data.name.kind == Kind.TemplateExpression {
						ctrl.newline().code('name: ').compile(data.name, config).code(',')
					}
					else {
						console.error(data.name)
						throw new Error('Not Implemented')
					}
					
					if variable.final {
						ctrl.newline().code('final: ', variable.final.name, ',')
					}
					
					ctrl.newline().code('function: function(')
					
					$function.parameters(ctrl, data, config, func(node) {
						node.code(')').step()
					})
					
					$variable.define(ctrl, {
						kind: Kind::Identifier
						name: 'this'
					}, VariableKind::Variable, $type.reference(variable.name))
					
					if data.body.kind == Kind.Block {
						ctrl.compile(data.body, config)
					}
					else {
						ctrl.newExpression().code('return ').compile(data.body, config)
					}
					
					ctrl.step(Mode.NoLine).code(',')
					
					ctrl.newline().code('signature: ')
					
					$helper.reflectMethod(ctrl, $method.signature(data, node), Mode.NoLine)
					
					ctrl.unindent().newline().code('})')
				})
				
				if data.name.kind == Kind::Identifier {
					let methods
					if instance {
						variable.instanceMethods[data.name.name] = [] if !variable.instanceMethods[data.name.name]
						
						methods = variable.instanceMethods[data.name.name]
					}
					else {
						variable.classMethods[data.name.name] = [] if !variable.classMethods[data.name.name]
						
						methods = variable.classMethods[data.name.name]
					}
					
					let method = {
						kind: Kind::MethodDeclaration
						name: data.name.name
						signature: $method.signature(data, node)
					}
					
					method.type = $type.type(data.type, node) if data.type
					
					methods.push(method)
				}
			}
		}
		Kind::MethodLinkDeclaration => {
			if(data.name.name == variable.name.name) {
				console.error(data)
				throw new Error('Not Implemented')
			}
			else {
				let instance = true
				for i from 0 til data.modifiers.length while instance {
					if data.modifiers[i].kind == MemberModifier.Static {
						instance = false
					}
				}
				
				let exp = node
					.newExpression()
					.code('Class.', instance ? 'newInstanceMethod' : 'newClassMethod', '({')
					.indent()
				
				exp.newline().code('class: ').compile(variable.name, config).code(',')
				
				if data.name.kind == Kind::Identifier {
					exp.newline().code('name: ', $quote(data.name.name), ',')
				}
				else if data.name.kind == Kind.TemplateExpression {
					exp.newline().code('name: ').compile(data.name, config).code(',')
				}
				else {
					console.error(data.name)
					throw new Error('Not Implemented')
				}
				
				if variable.final {
					exp.newline().code('final: ', variable.final.name, ',')
				}
				
				exp.newline().code('function: ', data.alias.name)
				
				if data.arguments {
					exp.code(',').newline().code('arguments: [')
					
					for i from 0 til data.arguments.length {
						if i {
							exp.code(', ')
						}
						
						exp.compile(data.arguments[i], config)
					}
					exp.code(']')
				}
				
				exp.code(',').newline().code('signature: ')
				
				$helper.reflectMethod(exp, $method.signature(data, node), Mode.NoLine)
				
				exp.unindent().newline().code('})')
				
				if data.name.kind == Kind::Identifier {
					let methods
					if instance {
						variable.instanceMethods[data.name.name] = [] if !variable.instanceMethods[data.name.name]
						
						methods = variable.instanceMethods[data.name.name]
					}
					else {
						variable.classMethods[data.name.name] = [] if !variable.classMethods[data.name.name]
						
						methods = variable.classMethods[data.name.name]
					}
					
					let method = {
						kind: Kind::MethodDeclaration
						name: data.name.name
						signature: $method.signature(data, node)
					}
					
					method.type = $type.type(data.type, node) if data.type
					
					methods.push(method)
				}
			}
		}
		=> {
			console.error(data)
			throw new Error('Unknow kind ' + data.kind)
		}
	}
} // }}}

const $import = {
	addVariable(module, file?, node, name, variable) { // {{{
		node.addVariable(name, variable)
		
		module.import(name, file)
	} // }}}
	define(module, file?, node, name, kind, type?) { // {{{
		$variable.define(node, name, kind, type)
		
		module.import(name.name || name, file)
	} // }}}
	loadCoreModule(x, module, data, node) { // {{{
		if $nodeModules[x] {
			return $import.loadNodeFile(null, x, module, data, node)
		}
		
		return false
	}, // }}}
	loadDirectory(x, moduleName?, module, data, node) { // {{{
		let pkgfile = path.join(x, 'package.json')
		if fs.isFile(pkgfile) {
			let pkg
			try {
				pkg = JSON.parse(fs.readFile(pkgfile))
			}
			
			if pkg.kaoscript && $import.loadKSFile(path.join(x, pkg.kaoscript.main), moduleName, module, data, node) {
				return true
			}
			else if pkg.main && ($import.loadFile(path.join(x, pkg.main), moduleName, module, data, node) || $import.loadDirectory(path.join(x, pkg.main), moduleName, module, data, node)) {
				return true
			}
		}
		
		return $import.loadFile(path.join(x, 'index'), moduleName, module, data, node)
	}, // }}}
	loadFile(x, moduleName?, module, data, node) { // {{{
		if fs.isFile(x) {
			if x.endsWith($extensions.source) {
				return $import.loadKSFile(x, moduleName, module, data, node)
			}
			else {
				return $import.loadNodeFile(x, moduleName, module, data, node)
			}
		}
		
		if fs.isFile(x + $extensions.source) {
			return $import.loadKSFile(x + $extensions.source, moduleName, module, data, node)
		}
		else {
			for ext of require.extensions {
				if fs.isFile(x + ext) {
					return $import.loadNodeFile(x, moduleName, module, data, node)
				}
			}
		}
		
		return false
	}, // }}}
	loadKSFile(x, moduleName?, module, data, node) { // {{{
		let file = null
		if !moduleName {
			file = moduleName = module.path(x, data.module)
		}
		
		let metadata, name, alias, variable, exp
		
		let source = fs.readFile(x)
		
		if fs.isFile(x + $extensions.metadata) && fs.isFile(x + $extensions.hash) && fs.readFile(x + $extensions.hash) == fs.sha256(source) && (metadata ?= $import.readMetadata(x)) {
		}
		else {
			let compiler = new Compiler(x, {
				register: false
			})
			
			compiler.compile(source)
			
			compiler.writeFiles()
			
			metadata = compiler.toMetadata()
		}
		
		let {exports, requirements} = metadata
		
		let importVariables = {}
		let importVarCount = 0
		let importAll = false
		let importAlias = ''
		
		for specifier in data.specifiers {
			if specifier.kind == Kind.ImportWildcardSpecifier {
				if specifier.local {
					importAlias = specifier.local.name
				}
				else {
					importAll = true
				}
			}
			else {
				importVariables[specifier.alias.name] = specifier.local ? specifier.local.name : specifier.alias.name
				++importVarCount
			}
		}
		
		let importCode
		if (importVarCount && importAll) || (importVarCount && importAlias.length) || (importAll && importAlias.length) {
			importCode = node.newTempName()
			
			let exp = node
				.newExpression()
				.code('var ', importCode, ' = require(', $quote(moduleName), ')(')
			
			nf = false
			for name of requirements {
				if nf {
					exp.code(', ')
				}
				else {
					nf = true
				}
				
				exp.code(name)
				
				if requirements[name].class {
					exp.code(', __ks_', name)
				}
			}
			
			exp.code(')')
		}
		else if importVarCount || importAll || importAlias.length {
			importCode = 'require(' + $quote(moduleName) + ')('
			
			nf = false
			for name of requirements {
				if nf {
					importCode += ', '
				}
				else {
					nf = true
				}
				
				importCode += name
				
				if requirements[name].class {
					importCode += ', __ks_' + name
				}
			}
			
			importCode += ')'
		}
		
		if importVarCount == 1 {
			for name, alias of importVariables {
			}
			
			throw new Error(`Undefined variable \(name) in the imported module at line \(data.start.line)`) unless variable ?= exports[name]
			
			$import.addVariable(module, file, node, alias, variable)
			
			if variable.kind != VariableKind::TypeAlias {
				if variable.kind == VariableKind.Class && variable.final {
					variable.final.name = '__ks_' + alias
					
					node.newExpression().code(`var {\(alias), \(variable.final.name)} = \(importCode)`)
				}
				else {
					node.newExpression().code(`var \(alias) = \(importCode).\(name)`)
				}
			}
		}
		else if importVarCount {
			exp = node.newExpression().code('var {')
			
			nf = false
			for name, alias of importVariables {
				throw new Error(`Undefined variable \(name) in the imported module at line \(data.start.line)`) unless variable ?= exports[name]
				
				$import.addVariable(module, file, node, alias, variable)
				
				if variable.kind != VariableKind::TypeAlias {
					if nf {
						exp.code(', ')
					}
					else {
						nf = true
					}
					
					if alias == name {
						exp.code(name)
						
						if variable.kind == VariableKind.Class && variable.final {
							exp.code(', ', variable.final.name)
						}
					}
					else {
						exp.code(name, ': ', alias)
						
						if variable.kind == VariableKind.Class && variable.final {
							variable.final.name = '__ks_' + alias
							
							exp.code(', ', variable.final.name)
						}
					}
				}
			}
			
			exp.code('} = ', importCode)
		}
		
		if importAll {
			let variables = []
			
			for name, variable of exports {
				$import.addVariable(module, file, node, name, variable)
				
				if variable.kind != VariableKind::TypeAlias {
					variables.push(name)
					
					if variable.kind == VariableKind.Class && variable.final {
						variable.final.name = '__ks_' + name
						
						variables.push(variable.final.name)
					}
				}
			}
			
			if variables.length == 1 {
				node.newExpression().code('var ', variables[0], ' = ', importCode, '.' + variables[0])
			}
			else if variables.length {
				exp = node.newExpression().code('var {')
				
				nf = false
				for name in variables {
					if nf {
						exp.code(', ')
					}
					else {
						nf = true
					}
					
					exp.code(name)
				}
				
				exp.code('} = ', importCode)
			}
		}
		
		if importAlias.length {
			node.newExpression().code('var ', importAlias, ' = ', importCode)
			
			type = {
				typeName: {
					kind: Kind::Identifier
					name: 'Object'
				}
				properties: []
			}
			
			for name, variable of exports {
				variable.name = {
					kind: Kind::Identifier
					name: variable.name
				}
				
				type.properties.push(variable)
			}
			
			variable = $variable.define(node, {
				kind: Kind::Identifier
				name: importAlias
			}, VariableKind::Variable, type)
		}
		
		return true
	}, // }}}
	loadNodeFile(x?, moduleName?, module, data, node) { // {{{
		let file = null
		if !moduleName {
			file = moduleName = module.path(x, data.module)
		}
		
		let variables = {}
		let count = 0
		
		for specifier in data.specifiers {
			if specifier.kind == Kind.ImportWildcardSpecifier {
				if specifier.local {
					node.newExpression().code('var ', specifier.local.name, ' = require(', $quote(moduleName), ')')
					
					$import.define(module, file, node, specifier.local, VariableKind::Variable)
				}
				else {
					throw new Error('Wilcard import is only suppoted for ks files')
				}
			}
			else {
				variables[specifier.alias.name] = specifier.local ? specifier.local.name : specifier.alias.name
				++count
			}
		}
		
		if count == 1 {
			let alias
			for alias of variables {
			}
			
			node.newExpression().code('var ', variables[alias], ' = require(', $quote(moduleName), ').', alias)
			
			$import.define(module, file, node, variables[alias], VariableKind::Variable)
		}
		else if count {
			let exp = node.newExpression().code('var {')
			
			let nf = false
			for alias of variables {
				if nf {
					exp.code(', ')
				}
				else {
					nf = true
				}
				
				if variables[alias] == alias {
					exp.code(alias)
				}
				else {
					exp.code(alias, ': ', variables[alias])
				}
				
				$import.define(module, file, node, variables[alias], VariableKind::Variable)
			}
			
			exp.code('} = require(', $quote(moduleName), ')')
		}
		
		return true
	}, // }}}
	loadNodeModule(x, start, module, data, node) { // {{{
		let dirs = $import.nodeModulesPaths(start)
		
		let file
		for dir in dirs {
			file = path.join(dir, x)
			
			if $import.loadFile(file, x, module, data, node) || $import.loadDirectory(file, x, module, data, node) {
				return true
			}
		}
		
		return false
	}, // }}}
	nodeModulesPaths(start) { // {{{
		start = fs.resolve(start)
		
		let prefix = '/'
		if /^([A-Za-z]:)/.test(start) {
			prefix = ''
		}
		else if /^\\\\/.test(start) {
			prefix = '\\\\'
		}
		
		let splitRe = process.platform == 'win32' ? /[\/\\]/ : /\/+/
		
		let parts = start.split(splitRe)
		
		let dirs = []
		for i from parts.length - 1 to 0 by -1 {
			if parts[i] == 'node_modules' {
				continue
			}
			
			dirs.push(prefix + path.join(path.join.apply(path, parts.slice(0, i + 1)), 'node_modules'))
		}
		
		if process.platform == 'win32' {
			dirs[dirs.length - 1] = dirs[dirs.length - 1].replace(':', ':\\')
		}
		
		return dirs
	}, // }}}
	readMetadata(x) { // {{{
		try {
			return JSON.parse(fs.readFile(x + $extensions.metadata))
		}
		catch {
			return null
		}
	}, // }}}
	resolve(data, y, module, node) { // {{{
		let x = data.module
		
		if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(x) {
			x = fs.resolve(y, x)
			
			if !($import.loadFile(x, null, module, data, node) || $import.loadDirectory(x, null, module, data, node)) {
				throw new Error("Cannot find module '" + x + "' from '" + y + "'")
			}
		}
		else {
			if !($import.loadNodeModule(x, y, module, data, node) || $import.loadCoreModule(x, module, data, node)) {
				throw new Error("Cannot find module '" + x + "' from '" + y + "'")
			}
		}
	}, // }}}
}

const $method = {
	fields(node, parameters, config, clazz) { // {{{
		let nf, j, exp
		for parameter in parameters {
			
			nf = true
			for j from 0 til parameter.modifiers.length while nf {
				if parameter.modifiers[j].kind == ParameterModifier.Member {
					$method.setMember(node, parameter.name.name, parameter.name, config, clazz)
					
					nf = false
				}
			}
		}
	} // }}}
	parameters(node, config, parameters, signature) { // {{{
		if signature.max < Infinity || signature.parameters.last().rest {
			for parameter, i in parameters {
				if i {
					node.code(', ')
				}
				
				if signature.parameters[i].rest {
					node.code('...')
				}
				
				node.parameter(parameter.name, config)
				
				if parameter.defaultValue && (!parameter.type || !parameter.type.nullable) {
					node.code(' = ').compile(parameter.defaultValue, config)
				}
			}
		}
		else {
			for parameter, i in parameters {
				if i {
					node.code(', ')
				}
				
				node.parameter(parameter.name, config)
				
				if parameter.defaultValue && (!parameter.type || !parameter.type.nullable) {
					node.code(' = ').compile(parameter.defaultValue, config)
				}
			}
		}
	} // }}}
	prepare(data, methods, node) { // {{{
		methods.push({
			data: data,
			signature: $method.signature(data, node)
		})
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
	setMember(node, name, data, config, clazz) { // {{{
		if clazz.instanceVariables[name] {
			node.newExpression().code('this.' + name + ' = ').compile(data, config)
		}
		else if clazz.instanceVariables['_' + name] {
			node.newExpression().code('this._' + name + ' = ').compile(data, config)
		}
		else if clazz.instanceMethods[name] && clazz.instanceMethods[name]['1'] {
			node.newExpression().code('this.' + name + '(').compile(data, config).code(')')
		}
		else {
			throw new Error('Can\'t set member ' + name + ' (line ' + data.start.line + ')')
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
			type = $signature.type(parameter.type, node)
			
			if !last || !$method.sameType(type, last.type) {
				if last {
					signature.min += last.min
					signature.max += last.max
				}
				
				last = {
					type: $signature.type(parameter.type, node),
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
				
				if(parameter.modifiers) {
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

const $operator = {
	binaries: {
		`\(BinaryOperator::And)`: true
		`\(BinaryOperator::Equality)`: true
		`\(BinaryOperator::Existential)`: true
		`\(BinaryOperator::GreaterThan)`: true
		`\(BinaryOperator::GreaterThanOrEqual)`: true
		`\(BinaryOperator::Inequality)`: true
		`\(BinaryOperator::LessThan)`: true
		`\(BinaryOperator::LessThanOrEqual)`: true
		`\(BinaryOperator::Or)`: true
		`\(BinaryOperator::TypeCheck)`: true
	}
	lefts: {
		`\(BinaryOperator::Addition)`: true
		`\(BinaryOperator::Assignment)`: true
	}
	numerics: {
		`\(BinaryOperator::BitwiseAnd)`: true
		`\(BinaryOperator::BitwiseLeftShift)`: true
		`\(BinaryOperator::BitwiseOr)`: true
		`\(BinaryOperator::BitwiseRightShift)`: true
		`\(BinaryOperator::BitwiseXor)`: true
		`\(BinaryOperator::Division)`: true
		`\(BinaryOperator::Modulo)`: true
		`\(BinaryOperator::Multiplication)`: true
		`\(BinaryOperator::Subtraction)`: true
	}
	assignment(node, data, config, mode) {
		switch data.operator.assignment {
			AssignmentOperator::Addition => { // {{{
				node
					.assignment(data)
					.compile(data.left, config, Mode.Key)
					.code(' += ')
					.compile(data.right, config, Mode.Assignment)
			} // }}}
			AssignmentOperator::BitwiseOr => { // {{{
				node
					.assignment(data)
					.compile(data.left, config, Mode.Key)
					.code(' |= ')
					.compile(data.right, config, Mode.Assignment)
			} // }}}
			AssignmentOperator::BitwiseXor => { // {{{
				node
					.assignment(data)
					.compile(data.left, config, Mode.Key)
					.code(' ^= ')
					.compile(data.right, config, Mode.Assignment)
			} // }}}
			AssignmentOperator::Equality => { // {{{
				node.assignment(data)
				
				if mode & Mode.BooleanExpression {
					node
						.code('(')
						.compile(data.left, config, Mode.Key)
						.code(' = ')
						.compile(data.right, config, Mode.Assignment)
						.code(')')
				}
				else {
					node
						.compile(data.left, config, Mode.Key)
						.code(' = ')
						.compile(data.right, config, Mode.Assignment)
				}
			} // }}}
			AssignmentOperator::Existential => { // {{{
				node.assignment(data, true)
				
				if data.right.kind == Kind::Identifier {
					if mode & Mode.BooleanExpression {
						node
							.code('Type.isValue(')
							.compile(data.right, config, Mode.Key)
							.code(') ? (')
							.compile(data.left, config, Mode.Key)
							.code(' = ')
							.compile(data.right, config, Mode.Assignment)
							.code(', true) : false')
					}
					else {
						node
							.code('Type.isValue(')
							.compile(data.right, config, Mode.Key)
							.code(') ? ')
							.compile(data.left, config, Mode.Key)
							.code(' = ')
							.compile(data.right, config, Mode.Assignment)
							.code(' : undefined')
					}
				}
				else {
					let name = node.newTempName()
					
					if mode & Mode.BooleanExpression {
						node
							.code('Type.isValue(', name, ' = ')
							.compile(data.right, config, Mode.Key)
							.code(') ? (')
							.compile(data.left, config, Mode.Key)
							.code(' = ', name, ', true) : false')
					}
					else {
						node
							.code('Type.isValue(', name, ' = ')
							.compile(data.right, config, Mode.Key)
							.code(') ? ')
							.compile(data.left, config, Mode.Key)
							.code(' = ', name, ' : undefined')
					}
				}
			} // }}}
			AssignmentOperator::Subtraction => { // {{{
				node
					.assignment(data)
					.compile(data.left, config, Mode.Key)
					.code(' -= ')
					.compile(data.right, config, Mode.Assignment)
			} // }}}
			=> { // {{{
				console.error(data)
				throw new Error('Unknow assignment operator ' + data.operator.assignment)
			} // }}}
		}
	},
	binary(node, data, config, mode) {
		switch data.operator.kind {
			BinaryOperator::And => { // {{{
				node
					.compile(data.left, config, mode | Mode.Operand | Mode.BooleanExpression)
					.code(' && ')
					.compile(data.right, config, mode | Mode.Operand | Mode.BooleanExpression)
			} // }}}
			BinaryOperator::Addition => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' + ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::BitwiseAnd => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' & ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::BitwiseLeftShift => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' << ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::BitwiseOr => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' | ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::BitwiseRightShift => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' >> ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::BitwiseXor => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' ^ ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::Division => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' / ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::Equality => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' === ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::Existential => { // {{{
				if data.left.kind == data.right.kind == Kind::Identifier {
					node
						.code('Type.isValue(')
						.compile(data.left, config, Mode.Operand)
						.code(') ? ')
						.compile(data.left, config, Mode.Operand)
						.code(' : ')
						.compile(data.right, config, Mode.Operand)
				}
				else {
					node
						.code('Type.vexists(')
						.compile(data.left, config, Mode.Operand)
						.code(', ')
						.compile(data.right, config, Mode.Operand)
						.code(')')
				}
			} // }}}
			BinaryOperator::GreaterThan => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' > ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::GreaterThanOrEqual => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' >= ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::Inequality => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' !== ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::LessThan => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' < ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::LessThanOrEqual => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' <= ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::Modulo => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' % ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::Multiplication => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' * ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::Or => { // {{{
				node
					.compile(data.left, config, mode | Mode.Operand | Mode.BooleanExpression)
					.code(' || ')
					.compile(data.right, config, mode | Mode.Operand | Mode.BooleanExpression)
			} // }}}
			BinaryOperator::Subtraction => { // {{{
				node
					.compile(data.left, config, Mode.Operand)
					.code(' - ')
					.compile(data.right, config, Mode.Operand)
			} // }}}
			BinaryOperator::TypeCast => { // {{{
				node.compile(data.left, config, Mode.Operand)
			} // }}}
			BinaryOperator::TypeCheck => { // {{{
				$type.check(node, data.left, data.right, config)
			} // }}}
			=> { // {{{
				console.error(data)
				throw new Error('Unknow binary operator ' + data.operator.kind)
			} // }}}
		}
	},
	polyadic(node, data, config, mode) {
		switch data.operator.kind {
			BinaryOperator::And => { // {{{
				for i from 0 til data.operands.length {
					if i {
						node.code(' && ')
					}
					
					node.compile(data.operands[i], config, mode | Mode.Operand | Mode.BooleanExpression)
				}
			} // }}}
			BinaryOperator::Addition => { // {{{
				for i from 0 til data.operands.length {
					if i {
						node.code(' + ')
					}
					
					node.compile(data.operands[i], config, Mode.Operand)
				}
			} // }}}
			BinaryOperator::Equality => { // {{{
				for i from 0 til data.operands.length - 1 {
					if i {
						node.code(' && ')
					}
					
					node.compile(data.operands[i], config, Mode.Operand)
					
					node.code(' === ')
					
					node.compile(data.operands[i + 1], config, Mode.Operand)
				}
			} // }}}
			BinaryOperator::Existential => { // {{{
				node.code('Type.vexists(')
				
				for i from 0 til data.operands.length {
					if i {
						node.code(', ')
					}
					
					node.compile(data.operands[i], config, Mode.Operand)
				}
				
				node.code(')')
			} // }}}
			BinaryOperator::LessThanOrEqual => { // {{{
				for i from 0 til data.operands.length - 1 {
					if i {
						node.code(' && ')
					}
					
					node.compile(data.operands[i], config, Mode.Operand)
					
					node.code(' <= ')
					
					node.compile(data.operands[i + 1], config, Mode.Operand)
				}
			} // }}}
			BinaryOperator::Multiplication => { // {{{
				for i from 0 til data.operands.length {
					if i {
						node.code(' * ')
					}
					
					node.compile(data.operands[i], config, Mode.Operand)
				}
			} // }}}
			BinaryOperator::Or => { // {{{
				for i from 0 til data.operands.length {
					if i {
						node.code(' || ')
					}
					
					node.compile(data.operands[i], config, mode | Mode.Operand | Mode.BooleanExpression)
				}
			} // }}}
			=> { // {{{
				console.error(data)
				throw new Error('Unknow polyadic operator ' + data.operator.kind)
			} // }}}
		}
	},
	unary(node, data, config, mode) {
		switch data.operator.kind {
			UnaryOperator::DecrementPostfix => { // {{{
				node.compile(data.argument, config, Mode.Operand).code('--')
			} // }}}
			UnaryOperator::DecrementPrefix => { // {{{
				node.code('--').compile(data.argument, config, Mode.Operand)
			} // }}}
			UnaryOperator::Existential => { // {{{
				node.code('Type.isValue(').compile(data.argument, config, Mode.Operand).code(')')
			} // }}}
			UnaryOperator::IncrementPostfix => { // {{{
				node.compile(data.argument, config, Mode.Operand).code('++')
			} // }}}
			UnaryOperator::IncrementPrefix => { // {{{
				node.code('++').compile(data.argument, config, Mode.Operand)
			} // }}}
			UnaryOperator::Negation => { // {{{
				node.code('!').compile(data.argument, config, Mode.Operand)
			} // }}}
			UnaryOperator::Negative => { // {{{
				node.code('-').compile(data.argument, config, Mode.Operand)
			} // }}}
			UnaryOperator::New => { // {{{
				node.code('new ').compile(data.argument, config, Mode.Operand)
			} // }}}
			=> { // {{{
				console.error(data)
				throw new Error('Unknow unary operator ' + data.operator.kind)
			} // }}}
		}
	}
}

func $quote(value) { // {{{
	return '"' + value.replace(/"/g, '\\"') + '"'
} // }}}

const $signature = {
	type(type?, node) { // {{{
		if type {
			if type.typeName {
				return $types[type.typeName.name] if $types[type.typeName.name]
				
				if (variable ?= node.getVariable(type.typeName.name)) && variable.kind == VariableKind::TypeAlias {
					return $signature.type(variable.type, node)
				}
				
				return type.typeName.name
			}
			else if type.types {
				let types = []
				
				for i from 0 til type.types.length {
					types.push($signature.type(type.types[i], node))
				}
				
				return types
			}
			else {
				console.error(type)
				throw new Error('Not Implemented')
			}
		}
		else {
			return 'Any'
		}
	} // }}}
}

const $switch = {
	binding(clause, ctrl, name, config) { // {{{
		for binding in clause.bindings {
			if binding.kind == Kind::ArrayBinding {
				ctrl.newExpression().code('var ').compile(binding, config).code(' = ', name)
			}
			else if binding.kind == Kind::ObjectBinding {
				console.error(binding)
				throw new Error('Not Implemented')
			}
			else if binding.kind == Kind::SwitchTypeCast {
				ctrl.newExpression().code($variable.scope(config), binding.name.name, ' = ', name)
				
				$variable.define(ctrl, binding.name, VariableKind::Variable)
			}
			else {
				ctrl.newExpression().code($variable.scope(config), binding.name, ' = ', name)
				
				$variable.define(ctrl, binding, VariableKind::Variable)
			}
		}
	}, // }}}
	length(elements) { // {{{
		let min = 0
		let max = 0
		
		for element in elements {
			if element.spread {
				max = Infinity
			}
			else {
				++min
				++max
			}
		}
		
		return {
			min: min,
			max: max
		}
	}, // }}}
	test(clause, ctrl, name, filter?, nf, config) { // {{{
		let mm
		for binding in clause.bindings {
			if binding.kind == Kind::ArrayBinding {
				if nf {
					ctrl.code(' && ')
				}
				else {
					nf = true
				}
				
				ctrl.code($typeofs.Array, '(', name, ')')
				
				mm = $switch.length(binding.elements)
				if mm.min == mm.max {
					if mm.min != Infinity {
						ctrl.code(' && ', name, '.length === ', mm.min)
					}
				}
				else {
					ctrl.code(' && ', name, '.length >= ', mm.min)
					
					if mm.max != Infinity {
						ctrl.code(' && ', name, '.length <= ', mm.max)
					}
				}
			}
			else if binding.kind == Kind::ObjectBinding {
				console.error(binding)
				throw new Error('Not Implemented')
			}
		}
		
		if clause.filter {
			if nf {
				ctrl.code(' && ')
			}
			
			if filter {
				ctrl.code(filter, '(', name, ')')
			}
			else {
				ctrl.compile(clause.filter, config)
			}
		}
	} // }}}
}

func $toInt(data, defaultValue) { // {{{
	switch data.kind {
		Kind::NumericExpression	=> return data.value
								=> return defaultValue
	}
} // }}}

const $type = {
	check(node, name, type, config) { // {{{
		if type.kind == Kind::TypeReference {
			type = $type.unalias(type, node)
			
			if type.typeParameters {
				if $generics[type.typeName.name] || !$types[type.typeName.name] || $generics[$types[type.typeName.name]] {
					let tof = $typeofs[type.typeName.name] || $typeofs[$types[type.typeName.name]]
					
					if tof {
						node
							.code(tof + '(')
							.compile(name, config, Mode.Operand)
						
						for typeParameter in type.typeParameters {
							node
								.code(', ')
								.compile(typeParameter, config)
						}
						
						node.code(')')
					}
					else {
						node
							.code('Type.is(')
							.compile(name, config, Mode.Operand)
							.code(', ')
							.compile(type.typeName, config, Mode.Operand)
						
						for typeParameter in type.typeParameters {
							node
								.code(', ')
								.compile(typeParameter, config)
						}
						
						node.code(')')
					}
				}
				else {
					throw new Error('Generic on primitive at line ' + type.start.line)
				}
			}
			else {
				let tof = $typeofs[type.typeName.name] || $typeofs[$types[type.typeName.name]]
				
				if tof {
					node
						.code(tof + '(')
						.compile(name, config, Mode.Operand)
						.code(')')
				}
				else {
					node
						.code('Type.is(')
						.compile(name, config, Mode.Operand)
						.code(', ')
						.compile(type, config, Mode.Operand)
						.code(')')
				}
			}
		}
		else if type.types {
			node.code('(')
			
			for i from 0 til type.types.length {
				if i {
					node.code(' || ')
				}
				
				$type.check(node, name, type.types[i], config)
			}
			
			node.code(')')
		}
		else {
			console.error(type)
			throw new Error('Not Implemented')
		}
	} // }}}
	isAny(type?) { // {{{
		if !type {
			return true
		}
		
		if type.kind == Kind::TypeReference && type.typeName.kind == Kind::Identifier && (type.typeName.name == 'any' || type.typeName.name == 'Any') {
			return true
		}
		
		return false
	} // }}}
	reference(name) { // {{{
		if name is string {
			return {
				kind: Kind::TypeReference
				typeName: {
					kind: Kind::Identifier
					name: name
				}
			}
		}
		else {
			return {
				kind: Kind::TypeReference
				typeName: name
			}
		}
	} // }}}
	same(a, b) { // {{{
		return false if a.kind != b.kind
		
		if a.kind == Kind::TypeReference {
			return false if a.typeName.kind != b.typeName.kind
			
			if a.typeName.kind == Kind::Identifier {
				return false if a.typeName.name != b.typeName.name
			}
		}
		
		return true
	} // }}}
	type(data, node) { // {{{
		//console.log('type.data', data)
		return data if !data.kind
		
		let type = null
		
		switch data.kind {
			Kind::BinaryOperator => {
				if data.operator.kind == BinaryOperator::TypeCast {
					return $type.type(data.right)
				}
				else if $operator.binaries[data.operator.kind] {
					return {
						typeName: {
							kind: Kind::Identifier
							name: 'Boolean'
						}
					}
				}
				else if $operator.lefts[data.operator.kind] {
					return $type.type(data.left, node)
				}
				else if $operator.numerics[data.operator.kind] {
					return {
						typeName: {
							kind: Kind::Identifier
							name: 'Number'
						}
					}
				}
			}
			Kind::Identifier => {
				let variable = node.getVariable(data.name)
				
				if variable && variable.type {
					return variable.type
				}
			}
			Kind::Literal => {
				return {
					typeName: {
						kind: Kind::Identifier
						name: $literalTypes[data.value] || 'String'
					}
				}
			}
			Kind::NumericExpression => {
				return {
					typeName: {
						kind: Kind::Identifier
						name: 'Number'
					}
				}
			}
			Kind::ObjectExpression => {
				type = {
					typeName: {
						kind: Kind::Identifier
						name: 'Object'
					}
					properties: []
				}
				
				let prop
				for property in data.properties {
					prop = {
						name: {
							kind: Kind::Identifier
							name: property.name.name
						}
					}
					
					if property.value.kind == Kind::FunctionExpression {
						prop.signature = $function.signature(property.value, node)
						
						if property.value.type {
							prop.type = $type.type(property.value.type, node)
						}
					}
					
					type.properties.push(prop)
				}
			}
			Kind::Template => {
				return {
					typeName: {
						kind: Kind::Identifier
						name: 'String'
					}
				}
			}
			Kind::TypeReference => {
				if data.typeName {
					if data.properties {
						type = {
							typeName: {
								kind: Kind::Identifier
								name: 'Object'
							}
							properties: []
						}
						
						let prop
						for property in data.properties {
							prop = {
								name: {
									kind: Kind::Identifier
									name: property.name.name
								}
							}
							
							if property.type {
								prop.signature = $function.signature(property.type, node)
								
								if property.type.type {
									prop.type = $type.type(property.type.type, node)
								}
							}
							
							type.properties.push(prop)
						}
					}
					else {
						type = {
							typeName: $type.typeName(data.typeName)
						}
						
						if data.nullable {
							type.nullable = true
						}
						
						if data.typeParameters {
							type.typeParameters = [$type.type(parameter, node) for parameter in data.typeParameters]
						}
					}
				}
			}
			Kind::UnionType => {
				return {
					types: [$type.type(type, node) for type in data.types]
				}
			}
		}
		//console.log('type.type', type)
		
		return type
	} // }}}
	typeName(data) { // {{{
		if data.kind == Kind.Identifier {
			return {
				kind: Kind::Identifier
				name: data.name
			}
		}
		else {
			return {
				kind: Kind::MemberExpression
				object: $type.typeName(data.object)
				property: $type.typeName(data.property)
				computed: false
			}
		}
	} // }}}
	unalias(type, node) { // {{{
		let variable = node.getVariable(type.typeName.name)
		
		if variable && variable.kind == VariableKind::TypeAlias {
			return $type.unalias(variable.type, node)
		}
		
		return type
	} // }}}
}

const $variable = {
	define(node, name, kind, type?) { // {{{
		let variable = node.getVariable(name.name || name)
		if variable && variable.kind == kind {
			variable.new = false
		}
		else {
			node.addVariable(name.name || name, variable = {
				name: name,
				kind: kind,
				new: true
			})
			
			if kind == VariableKind::Class {
				variable.constructors = []
				variable.instanceVariables = {}
				variable.classVariables = {}
				variable.instanceMethods = {}
				variable.classMethods = {}
			}
			else if kind == VariableKind::Enum {
				if type {
					if type.typeName.name == 'string' {
						variable.type = 'string'
					}
				}
				
				if !variable.type {
					variable.type = 'number'
					variable.counter = -1
				}
			}
			else if kind == VariableKind::TypeAlias {
				variable.type = $type.type(type, node)
			}
			else if (kind == VariableKind::Function || kind == VariableKind::Variable) && type {
				variable.type = type if type ?= $type.type(type, node)
			}
		}
		
		return variable
	} // }}}
	filter(method, min, max) { // {{{
		if method.signature {
			if min >= method.signature.min && max <= method.signature.max {
				return true
			}
		}
		else if method.typeName {
			if method.typeName.name == 'func' || method.typeName.name == 'Function' {
				return true
			}
			else {
				console.error(method)
				throw new Error('Not implemented')
			}
		}
		else {
			console.error(method)
			throw new Error('Not implemented')
		}
		
		return false
	} // }}}
	filterType(variable, name, node) { // {{{
		if variable.type {
			if variable.type.properties {
				for property in variable.type.properties {
					if property.name.name == name {
						return variable
					}
				}
			}
			else if variable.type.typeName {
				if variable ?= $variable.fromType(variable.type, node) {
					return $variable.filterMember(variable, name, node)
				}
			}
			else if variable.type.types {
				let variables = []
				
				for type in variable.type.types {
					return null unless (variable ?= $variable.fromType(type, node)) && (variable ?= $variable.filterMember(variable, name, node))
					
					variables.push(variable)
				}
				
				return variables
			}
			else {
				console.error(variable)
				throw new Error('Not implemented')
			}
		}
		
		return null
	} // }}}
	filterMember(variable, name, node) { // {{{
		//console.log('variable.fromMember.var', variable)
		//console.log('variable.fromMember.name', name)
		
		if variable.kind == VariableKind::Class {
			if variable.instanceMethods[name] {
				return variable
			}
			else if variable.instanceVariables[name] && variable.instanceVariables[name].type {
				return $variable.fromReflectType(variable.instanceVariables[name].type, node)
			}
		}
		else if variable.kind == VariableKind::Enum {
			console.error(variable)
			throw new Error('Not implemented')
		}
		else if variable.kind == VariableKind::TypeAlias {
			if variable.type.types {
				let variables = []
				
				for type in variable.type.types {
					return null unless (variable ?= $variable.fromType(type, node)) && (variable ?= $variable.filterMember(variable, name, node))
					
					variables.push(variable)
				}
				
				return variables
			}
			else {
				return $variable.filterMember(variable, name, node) if variable ?= $variable.fromType(variable.type, node)
			}
		}
		else if variable.kind == VariableKind::Variable {
			console.error(variable)
			throw new Error('Not implemented')
		}
		else {
			console.error(variable)
			throw new Error('Not implemented')
		}
		
		return null
	} // }}}
	fromAST(data, node) { // {{{
		switch data.kind {
			Kind::BinaryOperator => {
				if data.operator.kind == BinaryOperator::TypeCast {
					return {
						kind: VariableKind::Variable
						type: data.right
					}
				}
				else if $operator.binaries[data.operator.kind] {
					return {
						kind: VariableKind::Variable
						type: {
							kind: Kind::TypeReference
							typeName: {
								kind: Kind::Identifier
								name: 'Boolean'
							}
						}
					}
				}
				else if $operator.lefts[data.operator.kind] {
					let type = $type.type(data.left, node)
					
					if type {
						return {
							kind: VariableKind::Variable
							type: type
						}
					}
				}
				else if $operator.numerics[data.operator.kind] {
					return {
						kind: VariableKind::Variable
						type: {
							kind: Kind::TypeReference
							typeName: {
								kind: Kind::Identifier
								name: 'Number'
							}
						}
					}
				}
			}
			Kind::CallExpression => {
				let variable = $variable.fromAST(data.callee, node)
				//console.log('getVariable.call.data', data)
				//console.log('getVariable.call.variable', variable)
				
				if variable {
					if data.callee.kind == Kind::Identifier {
						return variable if variable.kind == VariableKind::Function
					}
					else if data.callee.kind == Kind::MemberExpression {
						let min = 0
						let max = 0
						for arg in data.arguments {
							if max == Infinity {
								++min
							}
							else if arg.spread {
								max = Infinity
							}
							else {
								++min
								++max
							}
						}
						
						let variables: array = []
						let name = data.callee.property.name
						
						let varType
						if variable is Array {
							for vari in variable {
								for member in vari.instanceMethods[name] {
									if member.type && $variable.filter(member, min, max) {
										varType = $variable.fromType(member.type, node)
										
										variables.pushUniq(varType) if varType
									}
									else {
										return null
									}
								}
							}
							
							return variables[0]	if variables.length == 1
							return variables	if variables
						}
						else if variable.kind == VariableKind::Class {
							if data.callee.object.kind == Kind::Identifier {
								if variable.classMethods[name] {
									for member in variable.classMethods[name] {
										if member.type && $variable.filter(member, min, max) {
											varType = $variable.fromType(member.type, node)
											
											variables.push(varType) if varType
										}
									}
								}
							}
							else {
								if variable.instanceMethods[name] {
									for member in variable.instanceMethods[name] {
										if member.type && $variable.filter(member, min, max) {
											varType = $variable.fromType(member.type, node)
											
											variables.push(varType) if varType
										}
									}
								}
							}
						}
						else if variable.kind == VariableKind::Variable {
							if variable.type && variable.type.properties {
								for property in variable.type.properties {
									if property.type && property.name.name == name && $variable.filter(property, min, max) {
										varType = $variable.fromType(property.type, node)
										
										variables.push(varType) if varType
									}
								}
							}
						}
						else {
							console.error(variable)
							throw new Error('Not implemented')
						}
						
						if variables.length == 1 {
							return variables[0]
						}
					}
					else {
						console.error(data.callee)
						throw new Error('Not implemented')
					}
				}
			}
			Kind::Identifier => {
				return node.getVariable(data.name)
			}
			Kind::Literal => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: Kind::TypeReference
						typeName: {
							kind: Kind::Identifier
							name: $literalTypes[data.value] || 'String'
						}
					}
				}
			}
			Kind::MemberExpression => {
				let variable = $variable.fromAST(data.object, node)
				//console.log('getVariable.member.data', data)
				//console.log('getVariable.member.variable', variable)
				
				if variable {
					if data.computed {
						return variable if variable.type && (variable = $variable.fromType(variable.type, node)) && variable.type && (variable = $variable.fromType(variable.type, node))
					}
					else {
						let name = data.property.name
						
						if variable.kind == VariableKind::Class {
							if data.object.kind == Kind::Identifier {
								if variable.classMethods[name] {
									return variable
								}
							}
							else {
								if variable.instanceMethods[name] {
									return variable
								}
								else if variable.instanceVariables[name] && variable.instanceVariables[name].type {
									return $variable.fromReflectType(variable.instanceVariables[name].type, node)
								}
								else if variable.instanceVariables[name] {
									console.error(variable)
									throw new Error('Not implemented')
								}
							}
						}
						else if variable.kind == VariableKind::Function {
							if data.object.kind == Kind::CallExpression {
								return $variable.filterType(variable, name, node)
							}
							else {
								return node.getVariable('Function')
							}
						}
						else if variable.kind == VariableKind::Variable {
							return $variable.filterType(variable, name, node)
						}
						else {
							console.error(variable)
							throw new Error('Not implemented')
						}
					}
				}
			}
			Kind::NumericExpression => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: Kind::TypeReference
						typeName: {
							kind: Kind::Identifier
							name: 'Number'
						}
					}
				}
			}
			Kind::TernaryConditionalExpression => {
				let a = $type.type(data.then, node)
				let b = $type.type(data.else, node)
				
				if a && b && $type.same(a, b) {
					return {
						kind: VariableKind::Variable
						type: a
					}
				}
			}
			Kind::Template => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: Kind::TypeReference
						typeName: {
							kind: Kind::Identifier
							name: 'String'
						}
					}
				}
			}
			Kind::TypeReference => {
				//console.log('getVariable.ref.data', data)
				if data.typeName {
					//console.log('getVariable.ref.variable', node.getVariable($types[data.typeName.name] || data.typeName.name))
					return node.getVariable($types[data.typeName.name] || data.typeName.name)
				}
			}
		}
		
		return null
	} // }}}
	fromReflectType(type, node) { // {{{
		if type == 'Any' {
			return null
		}
		else if type is string {
			return node.getVariable(type)
		}
		else {
			console.error(type)
			throw new Error('Not implemented')
		}
	} // }}}
	fromType(data, node) { // {{{
		//console.log('fromType', data)
		
		if data.typeName {
			if data.typeName.kind == Kind::Identifier {
				let name = $types[data.typeName.name] || data.typeName.name
				let variable = node.getVariable(name)
				
				return variable if variable
				
				if name = $defaultTypes[name] {
					variable = {
						name: name
						kind: VariableKind::Class
						constructors: []
						instanceVariables: {}
						classVariables: {}
						instanceMethods: {}
						classMethods: {}
					}
					
					if data.typeParameters && data.typeParameters.length == 1 {
						variable.type = data.typeParameters[0]
					}
					
					return variable
				}
			}
			else {
				let variable = $variable.fromAST(data.typeName.object, node)
				
				if variable && variable.kind == VariableKind::Variable && variable.type && variable.type.properties {
					let name = data.typeName.property.name
					
					for property in variable.type.properties {
						if property.name.name == name {
							property.accessPath = (variable.accessPath || variable.name.name) + '.'
							
							return property
						}
					}
				}
				else {
					console.error(data.typeName)
					throw new Error('Not implemented')
				}
			}
		}
		
		return null
	} // }}}
	kind(type?) { // {{{
		if type {
			switch type.kind {
				Kind::TypeReference => {
					if type.typeName {
						if type.typeName.kind == Kind::Identifier {
							let name = $types[type.typeName.name] || type.typeName.name
							
							return $typekinds[name] || VariableKind::Variable
						}
					}
				}
			}
		}
		
		return VariableKind::Variable
	} // }}}
	scope(config) { // {{{
		return config.variables == 'es5' ? 'var ' : 'let '
	} // }}}
	value(variable, data) { // {{{
		if variable.kind == VariableKind::Enum {
			if variable.type == 'number' {
				if data.value {
					variable.counter = $toInt(data.value, variable.counter)
				}
				else {
					++variable.counter
				}
				
				return variable.counter
			}
			else if variable.type == 'string' {
				return $quote(data.name.name.toLowerCase())
			}
		}
		
		return ''
	} // }}}
}

class Block {
	private {
		_code: Array	= []
		_config			= null
		_parent
		_prepared		= false
		_renamedIndexes = {}
		_renamedVars	= {}
		_variables		= {}
	}
	Block() { // {{{
		this._indentation = 1
		this._indent = '\t'
		this._temp = -1
	} // }}}
	Block(@parent) { // {{{
		this._indentation = parent._indentation + 1
		this._indent = '\t'.repeat(this._indentation)
		this._temp = parent.getTempCount(true)
	} // }}}
	addVariable(name, definition) { // {{{
		this._variables[name] = definition
		
		return this
	} // }}}
	block(reference) {
		return {
			block: this,
			reference: reference
		}
	}
	code(...args) { // {{{
		for arg in args {
			this._code.append(arg)
		}
		
		return this
	} // }}}
	codeVariable(data) { // {{{
		let name = this._renamedVars[data.name] ?? data.name
		
		this._code.push(name)
		
		return name
	} // }}}
	compile(data, config, mode = 0, info = null) { // {{{
		this._config = config if !this._config
		
		if data is string {
			this._code.push(data)
		}
		else {
			let r = $compile(this, data, config, mode, info)
			if r && r.node && r.close {
				return r
			}
		}
		
		return this
	} // }}}
	getTempCount(fromChild = true) { // {{{
		return this._temp
	} // }}}
	getVariable(name, fromChild = true) { // {{{
		if this._variables[name] {
			return this._variables[name]
		}
		else if this._parent {
			return this._parent.getVariable(name, true)
		}
		else {
			return null
		}
	} // }}}
	hasVariable(name, fromChild = true) { // {{{
		if this._variables && this._variables[name] {
			return true
		}
		else if this._parent {
			return this._parent.hasVariable(name, true)
		}
		else {
			return false
		}
	} // }}}
	indent() { // {{{
		++this._indentation
		this._indent = this._indent + '\t'
		
		return this
	} // }}}
	listNewVariables(mode = 0) { // {{{
		let variables: array = []
		
		for code in this._code {
			if !Type.isPrimitive(code) {
				variables.appendUniq(code.listNewVariables(mode))
			}
		}
		
		this._prepared = true
		
		return variables
	} // }}}
	newline() { // {{{
		this._code.push('\n' + this._indent)
		
		return this
	} // }}}
	newBlock() { // {{{
		return this
	} // }}}
	newControl(mode = 0) { // {{{
		let control = new Control(this, false, mode)
		
		this._code.push(control)
		
		return control
	} // }}}
	newExpression(mode = 0) { // {{{
		let stmt = new Expression(this, mode | Mode.Statement)
		
		this._code.push(stmt)
		
		return stmt
	} // }}}
	newFunction() { // {{{
		let stmt = new FunctionBlock(this)
		
		this._code.push(stmt)
		
		return stmt
	} // }}}
	newTempName() { // {{{
		let name = '__ks_' + ++this._temp
		
		while(this._variables[name]) {
			name = '__ks_' + ++this._temp
		}
		
		return name
	} // }}}
	rename(name) { // {{{
		let newName = this.newRenamedVar(name)
		if newName != name {
			this._renamedVars[name] = newName
		}
	
		return this
	} // }}}
	toSource(mode = 0) { // {{{
		let src = ''
		
		let str = false
		let variables
		for code in this._code {
			if Type.isPrimitive(code) {
				if !str {
					if src.length {
						src += '\n'
					}
					
					src += this._indent
					str = true
				}
				
				src += code
			}
			else {
				if !this._prepared {
					variables = code.listNewVariables()
					
					if variables.length {
						if str {
							src += ';\n'
							str = false
						}
						else if src.length {
							src += '\n'
						}
						
						src += this._indent + $variable.scope(this._config) + variables.join(', ') + ';'
					}
				}
				
				code = code.toSource(mode)
				
				if code.length {
					if str {
						src += ';\n'
						str = false
					}
					else if src.length {
						src += '\n'
					}
					
					src += code
				}
			}
		}
		
		if str {
			src += ';'
		}
		
		if src.length {
			src += '\n'
		}
		
		return src
	} // }}}
	unindent() { // {{{
		this._indent = '\t'.repeat(--this._indentation)
		
		return this
	} // }}}
}

class Node extends Block {
	Node(parent) { // {{{
		super(parent)
	} // }}}
	getRenamedVar(name) { // {{{
		if this._renamedVars[name] {
			return this._renamedVars[name]
		}
		else if this._variables[name] {
			return name
		}
		else {
			return this._parent.getRenamedVar(name)
		}
	} // }}}
	module() { // {{{
		return this._parent.module()
	} // }}}
	newRenamedVar(name) { // {{{
		if this._variables[name] {
			let index = this._renamedIndexes[name] ? this._renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)
			
			while this._variables[newName] {
				newName = '__ks_' + name + '_' + (++index)
			}
			
			this._renamedIndexes[name] = index
			
			return newName
		}
		else {
			return this._parent.newRenamedVar(name)
		}
	} // }}}
}

class Scope extends Block {
	private {
		_module
	}
	Scope(parent) { // {{{
		if parent is Module {
			super()
			
			this._module = parent
		}
		else {
			super(parent)
		}
	} // }}}
	getRenamedVar(name) { // {{{
		if this._renamedVars[name] {
			return this._renamedVars[name]
		}
		else {
			return name
		}
	} // }}}
	module() { // {{{
		if this._module {
			return this._module
		}
		else {
			return this._parent.module()
		}
	} // }}}
	newRenamedVar(name) { // {{{
		if this._variables[name] {
			let index = this._renamedIndexes[name] ? this._renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)
			
			while this._variables[newName] {
				newName = '__ks_' + name + '_' + (++index)
			}
			
			this._renamedIndexes[name] = index
			
			return newName
		}
		else {
			return name
		}
	} // }}}
}

class Control {
	private {
		_index		= 0
		_mode
		_parent
		_scope		= false
		_steps		= []
	}
	Control(@parent, @scope, @mode = 0) { // {{{
		this._indentation = parent._codeIndentation || parent._indentation
		this._indent = parent._codeIndent || parent._indent
		
		this._steps.push(new Expression(this))
	} // }}}
	addMode(mode) { // {{{
		this._steps[this._index].addMode(mode)
		
		return this
	} // }}}
	addVariable(name, definition) { // {{{
		if this._index % 2 == 0 {
			return this._parent.addVariable(name, definition)
		}
		else {
			this._steps[this._index].addVariable(name, definition)
		}
		
		return this
	} // }}}
	code(...args) { // {{{
		this._steps[this._index].code.apply(this._steps[this._index], args)
		
		return this
	} // }}}
	codeVariable(data) { // {{{
		this._steps[this._index].codeVariable(data)
		
		return this
	} // }}}
	compile(data, config, mode = 0, info = null) { // {{{
		if data is string {
			this.code(data)
		}
		else {
			let r = $compile(this, data, config, mode, info)
			if r && r.node && r.close {
				return r
			}
		}
		
		return this
	} // }}}
	getRenamedVar(name) { // {{{
		return this._parent.getRenamedVar(name)
	} // }}}
	getTempCount(fromChild = false) { // {{{
		if fromChild || this._index % 2 == 0 {
			return this._parent.getTempCount()
		}
		else {
			return this._steps[this._index].getTempCount()
		}
	} // }}}
	getVariable(name, fromChild = false) { // {{{
		if fromChild || this._index % 2 == 0 {
			return this._parent.getVariable(name)
		}
		else {
			return this._steps[this._index].getVariable(name)
		}
	} // }}}
	hasVariable(name, fromChild = false) { // {{{
		if(fromChild || this._index % 2 == 0) {
			return this._parent.hasVariable(name)
		}
		else {
			return this._steps[this._index].hasVariable(name)
		}
	} // }}}
	indent() { // {{{
		++this._indentation
		this._indent = this._indent + '\t'
		
		this._steps[this._index].indent()
		
		return this
	} // }}}
	length() { // {{{
		return this._steps.length
	} // }}}
	module() { // {{{
		return this._parent.module()
	} // }}}
	newline() { // {{{
		this._steps[this._index].newline()
		
		return this
	} // }}}
	newBlock() { // {{{
		return this._steps[this._index].newBlock()
	} // }}}
	newControl(mode = 0) { // {{{
		return this._steps[this._index].newControl(mode)
	} // }}}
	newExpression(mode = 0) { // {{{
		return this._steps[this._index].newExpression(mode)
	} // }}}
	newFunction() { // {{{
		return this._steps[this._index].newFunction()
	} // }}}
	newRenamedVar(name) { // {{{
		return this._parent.newRenamedVar(name)
	} // }}}
	newTempName() { // {{{
		if this._index % 2 == 0 {
			if this._index + 1 >= this._steps.length {
				this._steps.push(this._scope ? new Scope(this) : new Node(this))
			}
			
			return this._steps[this._index + 1].newTempName()
		}
		else {
			return this._steps[this._index].newTempName()
		}
	} // }}}
	rename(name) { // {{{
		if this._index % 2 == 0 {
			if this._index + 1 >= this._steps.length {
				this._steps.push(this._scope ? new Scope(this) : new Node(this))
			}
			
			this._steps[this._index + 1].rename(name)
		}
		else {
			this._steps[this._index].rename(name)
		}
		
		return this
	} // }}}
	step(mode = 0) { // {{{
		if this._index + 1 >= this._steps.length {
			if this._steps.length % 2 == 0 {
				this._steps.push(new Expression(this, mode))
			}
			else if this._scope {
				this._steps.push(new Scope(this))
			}
			else {
				this._steps.push(new Node(this))
			}
		}
		
		++this._index
		
		return this
	} // }}}
	listNewVariables() { // {{{
		let variables: array = []
		
		if this._mode & Mode.PrepareAll {
			for step in this._steps {
				variables.appendUniq(step.listNewVariables(Mode.PrepareAll))
			}
		}
		else if !(this._mode & Mode.PrepareNone) {
			for s from 0 til this._steps.length by 2 {
				variables.appendUniq(this._steps[s].listNewVariables(Mode.PrepareAll))
			}
		}
		
		return variables
	} // }}}
	parameter(data, config, type?) { // {{{
		this.compile(data, config, Mode.Key)
		
		if this._index % 2 == 0 {
			if this._index + 1 >= this._steps.length {
				this._steps.push(this._scope ? new Scope(this) : new Node(this))
			}
			
			if type {
				$variable.define(this._steps[this._index + 1], data.name || data, $variable.kind(type), type)
			}
			else {
				$variable.define(this._steps[this._index + 1], data.name || data, $variable.kind(data.type), data.type)
			}
		}
		else {
			if type {
				$variable.define(this._steps[this._index], data.name || data, $variable.kind(type), type)
			}
			else {
				$variable.define(this._steps[this._index], data.name || data, $variable.kind(data.type), data.type)
			}
		}
		
		return this
	} // }}}
	toSource(mode = 0) { // {{{
		let src = ''
		
		mode = this._mode & Mode.PrepareAll ? Mode.PrepareAll : 0
		for s from 0 til this._steps.length by 2 {
			if s + 1 == this._steps.length {
				if this._steps[s].length() == 0 {
				}
				else if s && !(this._steps[s]._mode & Mode.NoLine) {
					src += '\n'
					
					src += this._steps[s].toSource(Mode.PrepareAll)
				}
				else {
					src += this._steps[s].toSource(Mode.PrepareAll | Mode.NoIndent)
				}
			}
			else {
				if s {
					src += '\n'
				}
				
				src += this._steps[s].toSource(Mode.PrepareAll)
				
				src += ' {\n'
				
				src += this._steps[s + 1].toSource(mode)
				
				src += '\t'.repeat(this._steps[s + 1]._indentation - 1) + '}'
			}
		}
		
		return src
	} // }}}
	unindent() { // {{{
		this._indent = '\t'.repeat(--this._indentation)
		
		this._steps[this._index].unindent()
		
		return this
	} // }}}
	use(...args) { // {{{
		return this._steps[this._index].use.apply(this._steps[this._index], args)
	} // }}}
}

class Expression {
	private {
		_assignment			= false
		_config				= null
		_code		: Array = []
		_mode
		_parent
		_prepared			= false
		_usages				= []
		_reference			= ''
		_variables	: Array	= []
	}
	Expression(@parent, @mode = 0) { // {{{
		this._indentation = parent._indentation
		this._indent = parent._indent
		
		this._codeIndentation = parent._indentation
		this._codeIndent = parent._indent
	} // }}}
	addMode(mode) { // {{{
		this._mode |= mode
		
		return this
	} // }}}
	addVariable(name, definition) { // {{{
		this._parent.addVariable(name, definition)
		
		return this
	} // }}}
	assignment(data, variable = false) { // {{{
		if data.left.kind == Kind::Identifier && !this.hasVariable(data.left.name) {
			if variable || this._assignment {
				this._variables.push(data.left.name)
			}
			else {
				this._assignment = data.left.name
			}
			
			$variable.define(this, data.left, $variable.kind(data.right.type), data.right.type)
		}
		
		return this
	} // }}}
	block(reference?) { // {{{
		return this._parent.block(reference ? this._reference + reference : this._reference)
	} // }}}
	code(...args) { // {{{
		for arg in args {
			this._code.append(arg)
		}
		
		return this
	} // }}}
	codeVariable(data) { // {{{
		let name = this.getRenamedVar(data.name)
		
		this._code.push(name)
		
		return this
	} // }}}
	compile(data, config, mode = 0, info = null) { // {{{
		this._config = config if !this._config
		
		if data is string {
			this._code.push(data)
		}
		else {
			$compile(this, data, config, mode, info)
		}
		
		return this
	} // }}}
	getRenamedVar(name) { // {{{
		return this._parent.getRenamedVar(name)
	} // }}}
	getTempCount(fromChild = true) { // {{{
		return this._parent.getTempCount(fromChild)
	} // }}}
	getVariable(name, fromChild = true) { // {{{
		return this._parent.getVariable(name, fromChild)
	} // }}}
	hasVariable(name, fromChild = true) { // {{{
		return this._parent.hasVariable(name, fromChild)
	} // }}}
	indent() { // {{{
		if this._code.length {
			++this._codeIndentation
			this._codeIndent = this._codeIndent + '\t'
		}
		else {
			++this._indentation
			this._indent = this._indent + '\t'
		}
		
		return this
	} // }}}
	length() { // {{{
		return this._code.length
	} // }}}
	module() { // {{{
		return this._parent.module()
	} // }}}
	newline() { // {{{
		this._code.push('\n' + this._codeIndent)
		
		return this
	} // }}}
	newControl(mode = 0) { // {{{
		let control = new Control(this, false, mode)
		
		this._code.push(control)
		
		return control
	} // }}}
	newExpression(mode = 0) { // {{{
		return this
	} // }}}
	newFunction() { // {{{
		let code = new FunctionBlock(this)
		
		this._code.push(code)
		
		return code
	} // }}}
	newObject() { // {{{
		let code = new ObjectBlock(this)
		
		this._code.push(code)
		
		return code
	} // }}}
	newRenamedVar(name) { // {{{
		return this._parent.newRenamedVar(name)
	} // }}}
	newTempName() { // {{{
		let name = this._parent.newTempName()
		
		this._variables.pushUniq(name)
		
		return name
	} // }}}
	listNewVariables(mode = 0) { // {{{
		this._prepared = true
		
		if(mode & Mode.PrepareAll && this._assignment) {
			return [this._assignment].concat(this._variables)
		}
		else {
			return this._variables
		}
	} // }}}
	parameter(data, config, type?) { // {{{
		$compile(this, data, config, Mode.Key)
		
		if data.name {
			$variable.define(this._parent, data.name, $variable.kind(data.type), data.type)
		}
		else {
			$variable.define(this._parent, data, $variable.kind(type), type)
		}
		
		return this
	} // }}}
	reference(@reference) => this
	rename(name) { // {{{
		this._parent.rename(name)
		return this
	} // }}}
	toSource(mode = 0) { // {{{
		for variable in this._usages {
			if !this._parent.hasVariable(variable.name) {
				throw new Error(`Undefined variable '\(variable.name)' at line \(variable.start.line)`)
			}
		}
		
		let src = ''
		
		if !(this._mode & Mode.NoIndent || mode & Mode.NoIndent) {
			src += this._indent
		}
		
		if this._prepared {
			if !(mode & Mode.PrepareAll) && this._assignment {
				src += $variable.scope(this._config)
			}
		}
		else {
			if this._assignment {
				src += $variable.scope(this._config)
			}
			
			if this._variables.length {
				src = this._indent + $variable.scope(this._config) + this._variables.join(', ') + ';\n' + src
			}
		}
		
		for code in this._code {
			if Type.isPrimitive(code) {
				src += code
			}
			else {
				src += code.toSource()
			}
		}
		
		if this._mode & Mode.Statement {
			return src + ';'
		}
		else {
			return src
		}
	} // }}}
	unindent() { // {{{
		if this._code.length {
			this._codeIndent = '\t'.repeat(--this._codeIndentation)
		}
		else {
			this._indent = '\t'.repeat(--this._indentation)
		}
		
		return this
	} // }}}
	use(data) { // {{{
		if data.kind == Kind::Identifier {
			this._usages.push({
				name: data.name,
				start: data.start
			})
		}
		
		return this
	} // }}}
	write(data) { // {{{
		if data is object {
			this.code('{').indent()
			
			let nf = false
			for name of data {
				if nf {
					this.code(',')
				}
				else {
					nf = true
				}
				
				this.newline().code($quote(name) + ': ').write(data[name])
			}
			
			this.unindent().newline().code('}')
		}
		else {
			this.code(Type.toSource(data))
		}
		
		return this
	} // }}}
}

class FunctionBlock {
	private {
		_operation
		_parent
		_unprepared			= true
	}
	FunctionBlock(@parent) { // {{{
		this._ctrl = new Control(parent, true, Mode.PrepareNone)
	} // }}}
	listNewVariables() { // {{{
		return []
	} // }}}
	operation(@operation) => this
	toSource(mode = 0) { // {{{
		if this._unprepared {
			this._operation(this._ctrl)
			
			this._unprepared = false
		}
		
		return this._ctrl.toSource(mode)
	} // }}}
}

class ObjectBlock {
	private {
		_code		: Array = []
		_config				= null
		_parent
	}
	ObjectBlock(@parent) { // {{{
		this._closingIndent = parent._codeIndent
		
		this._indentation = parent._codeIndentation + 1
		this._indent = '\t'.repeat(this._indentation)
	} // }}}
	block(reference?) { // {{{
		return this._parent.block(reference)
	} // }}}
	compile(data, config, mode = 0, info = null) { // {{{
		this._config = config if !this._config
		
		if data is string {
			this._code.push(data)
		}
		else {
			$compile(this, data, config, mode, info)
		}
		
		return this
	} // }}}
	getRenamedVar(name) { // {{{
		return this._parent.getRenamedVar(name)
	} // }}}
	getTempCount(fromChild = true) { // {{{
		return this._parent.getTempCount(fromChild)
	} // }}}
	getVariable(name, fromChild = true) { // {{{
		return this._parent.getVariable(name, fromChild)
	} // }}}
	hasVariable(name, fromChild = true) { // {{{
		return this._parent.hasVariable(name, fromChild)
	} // }}}
	listNewVariables() { // {{{
		return []
	} // }}}
	newExpression(mode = 0) { // {{{
		let code = new Expression(this, mode)
		
		this._code.push(code)
		
		return code
	} // }}}
	toSource(mode = 0) { // {{{
		if this._code.length {
			let src = '{'
			
			for code, index in this._code {
				if index {
					src += ','
				}
				
				src += '\n' + code.toSource()
			}
			
			return src + '\n' + this._closingIndent + '}'
		}
		else {
			return '{}'
		}
	} // }}}
}

class Module {
	private {
		_binary		: Boolean	= false
		_body		: Block 	= new Scope(this)
		_compiler	: Compiler
		_exportSource			= []
		_exportMeta				= {}
		_imports				= {}
		_references				= {}
		_register				= false
		_requirements			= {}
	}
	Module(@compiler) { // {{{
		if this._compiler._options.output {
			this._output = this._compiler._options.output
		
			if this._compiler._options.rewire is Array {
				this._rewire = this._compiler._options.rewire
			}
			else {
				this._rewire = []
			}
		}
		else {
			this._output = null
		}
	} // }}}
	addReference(key, code) { // {{{
		if this._references[key] {
			this._references[key].push(code)
		}
		else {
			this._references[key] = [code]
		}
		
		return this
	} // }}}
	do(data, config) { // {{{
		for attr in data.attributes {
			if(attr.declaration.kind == Kind::Identifier &&	attr.declaration.name == 'bin') {
				this._binary = true
				this._body.unindent()
			}
			else if attr.declaration.kind == Kind::AttributeExpression && attr.declaration.name.name == 'cfg' {
				for arg in attr.declaration.arguments {
					if(arg.kind == Kind::AttributeOperator) {
						config[arg.name.name] = arg.value.value
					}
				}
			}
		}
		
		for value in data.body {
			this._body.compile(value, config)
		}
		
		return this
	} // }}}
	export(name, alias = false) { // {{{
		throw new Error('Binary file can\'t export') if this._binary
		
		let variable = this._body.getVariable(name.name)
		
		throw new Error(`Undefined variable \(name.name)`) unless variable
		
		if variable.kind != VariableKind::TypeAlias {
			if alias {
				this._exportSource.push(`\(alias.name): \(name.name)`)
			}
			else {
				this._exportSource.push(`\(name.name): \(name.name)`)
			}
			
			if variable.kind == VariableKind::Class && variable.final {
				if alias {
					this._exportSource.push(`__ks_\(alias.name): \(variable.final.name)`)
				}
				else {
					this._exportSource.push(`__ks_\(name.name): \(variable.final.name)`)
				}
			}
		}
		
		if alias {
			this._exportMeta[alias.name] = variable
		}
		else {
			this._exportMeta[name.name] = variable
		}
		
		return this
	} // }}}
	import(name, file?) { // {{{
		this._imports[name] = true
		
		if file && file.slice(-$extensions.source.length).toLowerCase() == $extensions.source {
			this._register = true
		}
	} // }}}
	listReferences(key) { // {{{
		if this._references[key] {
			let references = this._references[key]
			
			this._references[key] = null
			
			return references
		}
		else {
			return null
		}
	} // }}}
	parent() { // {{{
		return this._compiler.parent()
	} // }}}
	path(x?, name) { // {{{
		if !x || !this._output {
			return name
		}
		
		let output = null
		for rewire in this._rewire {
			if rewire.input == x {
				output = path.relative(this._output, rewire.output)
				break
			}
		}
		
		if !output {
			output = path.relative(this._output, x)
		}
		
		if output[0] != '.' {
			output = './' + output
		}
		
		return output
	} // }}}
	require(name, kind) { // {{{
		if this._binary {
			throw new Error('Binary file can\'t require')
		}
		
		if kind == VariableKind::Class {
			this._requirements[name] = {
				class: true
			}
		}
		else {
			this._requirements[name] = {}
		}
	} // }}}
	toMetadata() { // {{{
		let data = {
			requirements: this._requirements,
			exports: {}
		}
		
		let d
		for name, variable of this._exportMeta {
			d = {}
			
			for n of variable {
				if n == 'name' {
					d[n] = variable[n].name || variable[n]
				}
				else if !(n == 'accessPath') {
					d[n] = variable[n]
				}
			}
			
			data.exports[name] = d
		}
		
		return data
	} // }}}
	toSource() { // {{{
		let source = ''
		if this._body._config.header {
			source += `// Generated by kaoscript \(metadata.version)\n`
		}
		
		if this._register && this._body._config.register {
			source += 'require("kaoscript/register");\n'
		}
		
		if this._binary {
			source += this._body.toSource().slice(0, -1)
		}
		else {
			if !(this._requirements.Class || this._requirements.Type) && !(this._imports.Class && this._imports.Type) {
				this._requirements.Array = {
					class: true
				}
				this._requirements.Class = {}
				this._requirements.Function = {
					class: true
				}
				this._requirements.Object = {
					class: true
				}
				this._requirements.Type = {}
			}
			
			source += 'module.exports = function('
			
			let nf = false
			for name of this._requirements {
				if nf {
					source += ', '
				}
				else {
					nf = true
				}
				
				source += name
				
				if this._requirements[name].class {
					source += ', __ks_' + name
				}
			}
			
			source += ') {\n'
			
			source += this._body.toSource()
			
			if this._exportSource.length {
				source += '\treturn {'
				
				nf = false
				for src in this._exportSource {
					if nf {
						source += ','
					}
					else {
						nf = true
					}
					
					source += '\n\t\t' + src
				}
				
				source += '\n\t};\n'
			}
			
			source += '}'
		}
		
		return source
	} // }}}
}

export class Compiler {
	private {
		_file	: String
		_module	: Module
	}
	Compiler(@file, options?) { // {{{
		this._options = Object.merge({
			context: 'node6',
			register: true,
			config: {
				header: true,
				parameters: 'kaoscript',
				variables: 'es6'
			}
		}, options)
		
		this._module = new Module(this)
	} // }}}
	compile(data?) { // {{{
		data = data || fs.readFile(this._file)
		
		this._sha256 = fs.sha256(data)
		
		this._module.do(parse(data), this._options.config)
		/* console.time('parse')
		data = parse(data)
		console.timeEnd('parse')
		
		console.time('compile')
		this._module.do(data, this._options.config)
		console.timeEnd('compile') */
		
		return this
	} // }}}
	parent() { // {{{
		return path.dirname(this._file)
	} // }}}
	toMetadata() { // {{{
		return this._module.toMetadata()
	} // }}}
	toSource() { // {{{
		return this._module.toSource()
	} // }}}
	writeFiles() { // {{{
		fs.writeFile(this._file + $extensions.binary, this._module.toSource())
		
		if !this._module._binary {
			let metadata = this._module.toMetadata()
			
			fs.writeFile(this._file + $extensions.metadata, JSON.stringify(metadata))
		}
		
		fs.writeFile(this._file + $extensions.hash, this._sha256)
	} // }}}
	writeOutput() { // {{{
		if !this._options.output {
			throw new Error('Undefined option: output')
		}
		
		let filename = path.join(this._options.output, path.basename(this._file)).slice(0, -3) + '.js'
		
		fs.writeFile(filename, this._module.toSource())
		
		return this
	} // }}}
}

export func compileFile(file, options?) { // {{{
	let compiler = new Compiler(file, options)
	
	return compiler.compile().toSource()
} // }}}

export $extensions as extensions