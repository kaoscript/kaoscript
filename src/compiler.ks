/**
 * compiler.ks
 * Version 0.4.0
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![cfg(variables='es5')]

import {
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

extern {
	final class Array
	final class Object
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
			this.pushUniq.apply(this, Array.from(args[0]))
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
		if Type.isEnumerable(item) && !Type.isString(item) {
			return (item is array) ? item : Array.prototype.slice.call(item)
		}
		else {
			return [item]
		}
	} // }}}
	last(index = 1) { // {{{
		return this.length ? this[this.length - index] : null
	} // }}}
	static merge(...args) { // {{{
		let source
		
		let i = 0
		let l = args.length
		while i < l && !((source ?= args[i]) && source is Array) {
			++i
		}
		++i
		
		while i < l {
			if args[i] is Array {
				for value of args[i] {
					source.pushUniq(value)
				}
			}
			
			++i
		}
		
		return source
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

enum ImportKind {
	KSFile
	NodeFile
}

enum MemberAccess { // {{{
	Private = 1
	Protected
	Public
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

const $operator = { // {{{
	binaries: {
		`\(BinaryOperator::And)`: true
		`\(BinaryOperator::Equality)`: true
		`\(BinaryOperator::GreaterThan)`: true
		`\(BinaryOperator::GreaterThanOrEqual)`: true
		`\(BinaryOperator::Inequality)`: true
		`\(BinaryOperator::LessThan)`: true
		`\(BinaryOperator::LessThanOrEqual)`: true
		`\(BinaryOperator::NullCoalescing)`: true
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
	Array: true
	Boolean: true
	Function: true
	NaN: true
	Number: true
	Object: true
	String: true
} // }}}

// {{{ fragments
func $fragmentsToText(fragments) { // {{{
	return [fragment.code for fragment in fragments].join('')
} // }}}

func $locationDataToString(location?) { // {{{
	if location? {
		return `\(location.first_line + 1):\(location.first_column + 1)-\(location.last_line + 1):\(location.last_column + 1)`
	}
	else {
		return 'No location data'
	}
} // }}}

class CodeFragment {
	private {
		end		= null
		code
		start	= null
	}
	CodeFragment(@code)
	CodeFragment(@code, @start, @end)
	toString() { // {{{
		if this._start? {
			return `\(this._code): \($locationDataToString(this._location))`
		}
		else {
			return this.code
		}
	} // }}}
}

class FragmentBuilder {
	private {
		_arrays			= {}
		_blocks			= {}
		_expressions	= {}
		_fragments		= []
		_indent			= 1
		_lines			= {}
		_objects		= {}
	}
	line(...args) { // {{{
		let line = LineBuilder.create(this, this._indent)
		
		if args.length == 1 && args[0] is Object {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}
		
		line.done()
		
		return this
	} // }}}
	newControl() { // {{{
		return new ControlBuilder(this, this._indent)
	} // }}}
	newLine() { // {{{
		return LineBuilder.create(this, this._indent)
	} // }}}
	toArray() => this._fragments
}

class ControlBuilder {
	private {
		_addLastNewLine
		_builder
		_indent
		_step
	}
	ControlBuilder(@builder, @indent, @addLastNewLine = true) { // {{{
		this._step = ExpressionBuilder.create(this._builder, this._indent)
	} // }}}
	code(...args) { // {{{
		this._step.code(...args)
		
		return this
	} // }}}
	compile(node) { // {{{
		this._step.compile(node)
		
		return this
	} // }}}
	compileBoolean(node) { // {{{
		this._step.compileBoolean(node)
		
		return this
	} // }}}
	compileNullable(node) { // {{{
		this._step.compileNullable(node)
		
		return this
	} // }}}
	done() { // {{{
		this._step.done()
		
		if this._addLastNewLine {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
	} // }}}
	line(...args) { // {{{
		this._step.line(...args)
		
		return this
	} // }}}
	newControl() { // {{{
		return this._step.newControl()
	} // }}}
	newLine() { // {{{
		return this._step.newLine()
	} // }}}
	step() { // {{{
		this._step.done()
		
		if this._step is ExpressionBuilder {
			this._step = BlockBuilder.create(this._builder, this._indent)
		}
		else {
			if this._addLastNewLine {
				this._builder._fragments.push(new CodeFragment('\n'))
			}
			
			this._step = ExpressionBuilder.create(this._builder, this._indent)
		}
		
		return this
	} // }}}
	wrap(node) { // {{{
		this._step.wrap(node)
		
		return this
	} // }}}
	wrapBoolean(node) { // {{{
		this._step.wrapBoolean(node)
		
		return this
	} // }}}
	wrapNullable(node) { // {{{
		this._step.wrapNullable(node)
		
		return this
	} // }}}
}

class BlockBuilder {
	static create(builder, indent) { // {{{
		builder._blocks[indent] ??= new BlockBuilder(builder, indent)
	
		return builder._blocks[indent].init()
	} // }}}
	private {
		_builder
		_indent
	}
	BlockBuilder(@builder, @indent)
	compile(node) { // {{{
		if node is Object {
			node.toFragments(this)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	done() { // {{{
		this._builder._fragments.push($indent(this._indent), new CodeFragment('}'))
	} // }}}
	private init() { // {{{
		this._builder._fragments.push(new CodeFragment(' {\n'))
		
		return this
	} // }}}
	line(...args) { // {{{
		let line = LineBuilder.create(this._builder, this._indent + 1)
		
		if args.length == 1 && args[0] is Object {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}
		
		line.done()
		
		return this
	} // }}}
	newControl(indent = this._indent + 1) { // {{{
		return new ControlBuilder(this._builder, indent)
	} // }}}
	newLine(indent = this._indent + 1) { // {{{
		return LineBuilder.create(this._builder, indent)
	} // }}}
}

class ExpressionBuilder {
	static create(builder, indent) { // {{{
		builder._expressions[indent] ??= new ExpressionBuilder(builder, indent)
	
		return builder._expressions[indent].init()
	} // }}}
	private {
		_builder
		_indent
	}
	ExpressionBuilder(@builder, @indent)
	code(...args) { // {{{
		let arg, data
		for i from 0 til args.length {
			arg = args[i]
			
			if arg is Array {
				this.push(...arg)
			}
			else if arg is Object {
				this._builder._fragments.push(arg)
			}
			else {
				if i + 1 < args.length && (data = args[i + 1]) is Object && data.start? && data.end? {
					this._builder._fragments.push(new CodeFragment(arg, data.start, data.end))
					
					i++
				}
				else {
					this._builder._fragments.push(new CodeFragment(arg))
				}
			}
		}
		
		return this
	} // }}}
	compile(node) { // {{{
		if node is Object {
			node.toFragments(this)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	compileBoolean(node) { // {{{
		if node is Object {
			node.toBooleanFragments(this)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	compileNullable(node) { // {{{
		if node is Object {
			node.toNullableFragments(this)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	compileReusable(node) { // {{{
		if node is Object {
			node.toReusableFragments(this)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	done(skipLastNewLine = false) { // {{{
	} // }}}
	private init() { // {{{
		this._builder._fragments.push($indent(this._indent))
		
		return this
	} // }}}
	newArray(indent = this._indent) {
		return ArrayBuilder.create(this._builder, indent)
	}
	newBlock(indent = this._indent) {
		return BlockBuilder.create(this._builder, indent)
	}
	newControl(indent = this._indent + 1) { // {{{
		return new ControlBuilder(this._builder, indent)
	} // }}}
	newLine(indent = this._indent + 1) { // {{{
		return LineBuilder.create(this._builder, indent)
	} // }}}
	newObject(indent = this._indent) {
		return ObjectBuilder.create(this._builder, indent)
	}
	wrap(node) { // {{{
		if node.isComputed() {
			this.code('(')
			
			node.toFragments(this)
			
			this.code(')')
		}
		else {
			node.toFragments(this)
		}
		
		return this
	} // }}}
	wrapBoolean(node) { // {{{
		if node.isComputed() {
			this.code('(')
			
			node.toBooleanFragments(this)
			
			this.code(')')
		}
		else {
			node.toBooleanFragments(this)
		}
		
		return this
	} // }}}
	wrapNullable(node) { // {{{
		if node.isComputed() {
			this.code('(')
			
			node.toNullableFragments(this)
			
			this.code(')')
		}
		else {
			node.toNullableFragments(this)
		}
		
		return this
	} // }}}
}

class LineBuilder extends ExpressionBuilder {
	static create(builder, indent) { // {{{
		builder._lines[indent] ??= new LineBuilder(builder, indent)
	
		return builder._lines[indent].init()
	} // }}}
	done() { // {{{
		this._builder._fragments.push($terminator)
	} // }}}
}

class ObjectBuilder {
	static create(builder, indent) { // {{{
		builder._objects[indent] ??= new ObjectBuilder(builder, indent)
	
		return builder._objects[indent].init()
	} // }}}
	private {
		_builder
		_indent
		_line
	}
	ObjectBuilder(@builder, @indent)
	done() { // {{{
		if this._line? {
			this._line.done()
			
			this._line = null
			
			this._builder._fragments.push(new CodeFragment('\n'), $indent(this._indent), new CodeFragment('}'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('}'))
		}
	} // }}}
	private init() { // {{{
		this._line = null
		
		this._builder._fragments.push(new CodeFragment('{'))
		
		return this
	} // }}}
	line(...args) { // {{{
		let line = this.newLine()
		
		line.code(...args)
		
		return this
	} // }}}
	newControl() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = new ControlBuilder(this._builder, this._indent + 1, false)
	} // }}}
	newLine() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = ExpressionBuilder.create(this._builder, this._indent + 1)
	} // }}}
}

class ArrayBuilder {
	static create(builder, indent) { // {{{
		builder._arrays[indent] ??= new ArrayBuilder(builder, indent)
	
		return builder._arrays[indent].init()
	} // }}}
	private {
		_builder
		_indent
		_line
	}
	ArrayBuilder(@builder, @indent)
	done() { // {{{
		if this._line? {
			this._line.done()
			
			this._line = null
			
			this._builder._fragments.push(new CodeFragment('\n'), $indent(this._indent), new CodeFragment(']'))
		}
		else {
			this._builder._fragments.push(new CodeFragment(']'))
		}
	} // }}}
	private init() { // {{{
		this._line = null
		
		this._builder._fragments.push(new CodeFragment('['))
		
		return this
	} // }}}
	line(...args) { // {{{
		this.newLine().code(...args)
		
		return this
	} // }}}
	newControl() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = new ControlBuilder(this._builder, this._indent + 1, false)
	} // }}}
	newLine() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = ExpressionBuilder.create(this._builder, this._indent + 1)
	} // }}}
}
// }}}

// {{{ code
func $code(code) {
	return new CodeFragment(code)
}

func $codeLoc(code, start, end) {
	return new CodeFragment(code, start, end)
}

const $indentations = []

func $indent(indent) {
	return $indentations[indent] ?? ($indentations[indent] = $code('\t'.repeat(indent)))
}

func $quote(value) { // {{{
	return '"' + value.replace(/"/g, '\\"') + '"'
} // }}}

const $comma = $code(', ')
const $dot = $code('.')
const $equals = $code(' = ')
const $space = $code(' ')
const $terminator = $code(';\n')
// }}}

func $applyAttributes(data, options) { // {{{
	let nc = true
	
	if data.attributes && data.attributes.length {
		for attr in data.attributes {
			if attr.declaration.kind == Kind::AttributeExpression && attr.declaration.name.name == 'cfg' {
				if nc {
					options = Object.clone(options)
					
					nc = false
				}
				
				for arg in attr.declaration.arguments {
					if arg.kind == Kind::AttributeOperator {
						options[arg.name.name] = arg.value.value
					}
				}
			}
		}
	}
	
	return options
} // }}}

func $block(data) { // {{{
	return data if data.kind == Kind::Block
	
	return {
		kind: Kind::Block
		statements: [
			data
		]
	}
} // }}}

const $continuous = {
	constructor(node, fragments, data, declaration, signature, reflect, clazz) { // {{{
		let index = reflect.constructors.length
		
		reflect.constructors.push(signature)
	
		declaration
			.name('__ks_cons_' + index)
			.toFragments(fragments)
	} // }}}
	methodCall(variable, fnName, argName, retCode, fragments, method, index) { // {{{
		if method.max == 0 {
			fragments.line(retCode, variable.name.name, '.', fnName, index, '.apply(this)')
		}
		else {
			fragments.line(retCode, variable.name.name, '.', fnName, index, '.apply(this, ', argName, ')')
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
	class(node, fragments, data, variable) { // {{{
		let clazz = fragments
			.newControl()
			.code('class ', variable.name.name)
		
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
			ctrl = fragments
				.newControl()
				.code('__ks_init()')
				.step()
				
			ctrl.line(variable.extends.name.name, '.prototype.__ks_init.call(this)')
			
			if !noinit {
				for name, field of variable.instanceVariables {
					if field.data.defaultValue {
						ctrl
							.newLine()
							.code('this.' + name + ' = ')
							.compile(field.fragments)
							.done()
					}
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
				for name, field of variable.instanceVariables {
					if field.data.defaultValue {
						ctrl
							.newLine()
							.code('this.' + name + ' = ')
							.compile(field.fragments)
							.done()
					}
				}
			}
			
			ctrl.line('this.__ks_cons(arguments)')
			
			ctrl.done()
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
			$continuous.constructor(node, clazz, method.data, method.fragments, method.signature, reflect, variable)
		}
		
		$helper.constructor(node, clazz, reflect, variable)
		
		/*
		for name, methods of variable.instanceMethods {
			for method in methods {
				$continuous.instanceMethod(clazz, method.data, config, method.signature, reflect, name, variable)
			}
			
			$helper.instanceMethod(clazz, reflect, name, variable, config)
		}
		
		for name, methods of variable.classMethods {
			for method in methods {
				$continuous.classMethod(clazz, method.data, config, method.signature, reflect, name, variable)
			}
			
			$helper.classMethod(clazz, reflect, name, variable, config)
		}
		*/
		
		for name, field of variable.instanceVariables {
			reflect.instanceVariables[name] = field.signature
		}
		
		for name, field of variable.classVariables {
			$continuous.classVariable(fragments, field.data, field.signature, reflect, name, variable)
		}
		
		clazz.done()
		
		$helper.reflect(node, fragments, variable.name, reflect)
		
		/* let references = node.module().listReferences(variable.name.name)
		if references {
			for ref in references {
				node.newExpression(config).code(ref)
			}
		} */
		
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
			if parameter.modifiers[i].kind == ParameterModifier::Rest {
				return parameter.modifiers[i].arity
			}
		}
		
		return null
	} // }}}
	parameters(node, fragments, fn) { // {{{
		if node._options.parameters == 'es5' {
			$function.parametersES5(node, fragments, fn)
		}
		else if node._options.parameters == 'es6' {
			$function.parametersES6(node, fragments, fn)
		}
		else {
			$function.parametersKS(node, fragments, fn)
		}
	} // }}}
	parametersKS(node, fragments, fn) { // {{{
		let data = node._data
		let signature = $function.signature(node._data, node)
		//console.log(signature)
		
		let parameter, ctrl
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
		let l = rest != -1 ? rest : node._parameters.length
		
		if (rest != -1 && !fr && (db == 0 || db + 1 == rest)) || (rest == -1 && ((!signature.async && signature.max == l && (db == 0 || db == l)) || (signature.async && signature.max == l + 1 && (db == 0 || db == l + 1)))) { // {{{
			let names = []
			
			for i from 0 til l {
				parameter = data.parameters[i]
				
				fragments.code($comma) if i
				
				if parameter.name {
					names[i] = parameter.name.name
					
					fragments.code(parameter.name.name, parameter.name)
				}
				else {
					fragments.code(names[i] = node.acquireTempName())
				}
				
				if parameter.type {
					if parameter.type.nullable && !parameter.defaultValue {
						fragments.code(' = null')
					}
				}
			}
			
			if !ra && rest != -1 && (signature.parameters[rest].type == 'Any' || !maxa) {
				parameter = data.parameters[rest]
				
				if rest {
					fragments.code(', ')
				}
				
				fragments.code('...')
				
				if parameter.name {
					names[rest] = parameter.name.name
					
					fragments.code(parameter.name.name, parameter.name)
				}
				else {
					fragments.code(names[rest] = node.acquireTempName())
				}
			}
			else if signature.async && !ra {
				if l {
					fragments.code(', ')
				}
				
				fragments.code('__ks_cb')
			}
			
			fn(fragments)
			
			if ra {
				fragments
					.newControl()
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.line('throw new Error("Wrong number of arguments")')
					.done()
			}
			
			for i from 0 til l {
				parameter = data.parameters[i]
				
				if parameter.name? && (!?parameter.type || !parameter.type.nullable || parameter.defaultValue?) {
					ctrl = fragments
						.newControl()
						.code('if(', parameter.name.name, ' === undefined')
					
					if !?parameter.type || !parameter.type.nullable {
						ctrl.code(' || ', parameter.name.name, ' === null')
					}
					
					ctrl.code(')').step()
					
					if parameter.defaultValue? {
						ctrl
							.newLine()
							.code(parameter.name.name, $equals)
							.compile(node._parameters[i]._defaultValue)
							.done()
					}
					else {
						ctrl.line('throw new Error("Missing parameter \'', parameter.name.name, '\'")')
					}
					
					ctrl.done()
				}
				
				if !$type.isAny(parameter.type) {
					ctrl = fragments
						.newControl()
						.code('if(')
					
					if parameter.type.nullable {
						ctrl.code(names[i], ' !== null && ')
					}
					
					ctrl.code('!')
					
					$type.check(node, ctrl, names[i], parameter.type)
					
					ctrl
						.code(')')
						.step()
						.line('throw new Error("Invalid type for parameter \'', parameter.name.name, '\'")')
					
					ctrl.done()
				}
			}
			
			if ra {
				parameter = data.parameters[rest]
				
				if signature.parameters[rest].type == 'Any' {
					if parameter.name {
						fragments.line($variable.scope(node), '__ks_i')
						
						fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = arguments.length > ' + (maxb + ra) + ' ? Array.prototype.slice.call(arguments, ' + maxb + ', __ks_i = arguments.length - ' + ra + ') : (__ks_i = ' + maxb + ', [])')
					}
					else {
						fragments.line($variable.scope(node), '__ks_i = arguments.length > ' + (maxb + ra) + ' ? arguments.length - ' + ra + ' : ' + maxb)
					}
				}
				else {
					fragments.line($variable.scope(node), '__ks_i')
					
					if parameter.name {
						fragments.line($variable.scope(node), parameter.name, parameter.name.name, ' = []')
					}
				}
			}
			else if rest != -1 && signature.parameters[rest].type != 'Any' && maxa {
				parameter = data.parameters[rest]
				
				if maxb {
				}
				else {
					fragments.line($variable.scope(node), '__ks_i = -1')
				}
			
				if parameter.name {
					fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = []')
				}
				
				ctrl = fragments
					.newControl()
					.code('while(')
				
				$type.check(node, ctrl, 'arguments[++__ks_i]', parameter.type)
				
				ctrl
					.code(')')
					.step()
				
				if parameter.name {
					ctrl.line(parameter.name.name, parameter.name, '.push(arguments[__ks_i])')
				}
				
				ctrl.done()
			}
			
			if rest != -1 {
				parameter = data.parameters[rest]
				
				if (arity = $function.arity(parameter)) && arity.min {
					fragments
						.newControl()
						.code('if(', parameter.name.name, parameter.name, '.length < ', arity.min, ')')
						.step()
						.line('throw new Error("Wrong number of arguments")')
						.done()
				}
			}
			else if signature.async && !ra {
				node.module().flag('Type')
				
				fragments
					.newControl()
					.code('if(!', $runtime.type(node), '.isFunction(__ks_cb))')
					.step()
					.line('throw new Error("Invalid callback")')
					.done()
			}
		} // }}}
		else { // {{{
			fn(fragments)
			
			if signature.min {
				fragments
					.newControl()
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.line('throw new Error("Wrong number of arguments")')
					.done()
			}
				
			fragments.line($variable.scope(node), '__ks_i = -1')
			
			let required = rb
			let optional = 0
			
			for i from 0 til l {
				parameter = data.parameters[i]
				
				if arity = $function.arity(parameter) { // {{{
					required -= arity.min
					
					if parameter.name {
						if $type.isAny(parameter.type) {
							if required {
								fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - ', required, ', __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
								}
							}
							else {
								fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
								}
							}
						}
						else {
							fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = []')
							
							ctrl = fragments.newControl()
							
							if required {
								ctrl.code('while(__ks_i < arguments.length - ', required, ' && ')
							}
							else {
								ctrl.code('while(__ks_i + 1 < arguments.length && ')
							}
							
							ctrl
								.code(parameter.name.name, parameter.name, '.length < ', arity.max, ' )')
								.step()
								.done()
						}
					}
					else {
					}
					
					optional += arity.max - arity.min
				} // }}}
				else { // {{{
					if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
						ctrl = fragments
							.newControl()
							.code('if(arguments.length > ', signature.min + optional, ')')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = arguments[++__ks_i]')
							}
							else {
								ctrl.line('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl()
								.code('if(')
							
							$type.check(node, ctrl2, 'arguments[__ks_i + 1]', parameter.type)
							
							ctrl2
								.code(')')
								.step()
								.line('var ', parameter.name.name, parameter.name, ' = arguments[++__ks_i]')
							
							ctrl2
								.step()
								.code('else ')
								.step()
							
							if rest == -1 {
								ctrl2.line('throw new Error("Invalid type for parameter \'', parameter.name.name, parameter.name, '\'")')
							}
							else if parameter.defaultValue {
								ctrl2
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl2.line('var ', parameter.name.name, parameter.name, ' = null')
							}
							
							ctrl2.done()
						}
						
						if parameter.name {
							ctrl.step().code('else ').step()
						
							if parameter.defaultValue {
								ctrl
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = null')
							}
						}
						
						ctrl.done()
						
						++optional
					}
					else {
						if $type.isAny(parameter.type) {
							if parameter.name {
								fragments.line('var ', parameter.name.name, parameter.name, ' = arguments[++__ks_i]')
							}
							else {
								fragments.line('++__ks_i')
							}
						}
						else {
							if parameter.name {
								ctrl = fragments
									.newControl()
									.code('if(')
								
								$type.check(node, ctrl, 'arguments[++__ks_i]', parameter.type)
								
								ctrl
									.code(')')
									.step()
									.line('var ', parameter.name.name, parameter.name, ' = arguments[__ks_i]')
								
								ctrl
									.step()
									.code('else throw new Error("Invalid type for parameter \'', parameter.name.name, parameter.name, '\'")')
									.done()
							}
							else {
								ctrl = fragments
									.newControl()
									.code('if(!')
								
								$type.check(node, ctrl, 'arguments[++__ks_i]', parameter.type)
								
								ctrl
									.code(')')
									.step()
									.line('throw new Error("Wrong type of arguments")')
									.done()
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
						fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = arguments.length > __ks_i + ', ra + 1, ' ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - ' + ra + ') : []')
						
						if l + 1 < data.parameters.length {
							fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
						}
					}
					else if l + 1 < data.parameters.length {
						fragments
							.newControl()
							.code('if(arguments.length > __ks_i + ' , ra + 1, ')')
							.step()
							.line('__ks_i = arguments.length - ', ra + 1)
							.done()
					}
				}
				else {
					if parameter.name {
						fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : []')
						
						if l + 1 < data.parameters.length {
							fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
						}
					}
				}
			} // }}}
		} // }}}
		
		if ra || maxa { // {{{
			if ra != maxa && signature.parameters[rest].type != 'Any' {
				if ra {
					fragments.line($variable.scope(node), '__ks_m = __ks_i + ', ra)
				}
				else {
					fragments.line($variable.scope(node), '__ks_m = __ks_i')
				}
			}
			
			for i from rest + 1 til data.parameters.length {
				parameter = data.parameters[i]
				
				if arity = $function.arity(parameter) {
					if arity.min {
						if parameter.name {
							if $type.isAny(parameter.type) {
								fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = Array.prototype.slice.call(arguments, __ks_i + 1, __ks_i + ', arity.min + 1, ')')
								
								if i + 1 < data.parameters.length {
									fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
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
				}
				else if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
					if signature.parameters[rest].type == 'Any' {
						if parameter.name {
							if parameter.defaultValue {
								fragments
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								fragments.line('var ', parameter.name.name, parameter.name, ' = null')
							}
						}
					}
					else {
						ctrl = fragments
							.newControl()
							.code('if(arguments.length > __ks_m)')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = arguments[', inc ? '++' : '', '__ks_i]')
							}
							else {
								ctrl.line('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl()
								.code('if(')
							
							$type.check(node, ctrl2, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type)
							
							ctrl2
								.code(')')
								.step()
								.line('var ', parameter.name.name, parameter.name, ' = arguments[__ks_i]')
							
							ctrl2
								.step()
								.code('else ')
								.step()
							
							if parameter.defaultValue {
								ctrl2
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl2.line('var ', parameter.name.name, parameter.name, ' = null')
							}
							
							ctrl2.done()
						}
						
						if parameter.name {
							ctrl.step().code('else ').step()
						
							if parameter.defaultValue {
								ctrl
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = null')
							}
						}
						
						ctrl.done()
						
						if !inc {
							inc = true
						}
					}
				}
				else {
					if $type.isAny(parameter.type) {
						if parameter.name {
							fragments.line('var ', parameter.name.name, parameter.name, ' = arguments[', inc ? '++' : '', '__ks_i]')
						}
						else {
							fragments.line(inc ? '++' : '', '__ks_i')
						}
					}
					else {
						if parameter.name {
							ctrl = fragments
								.newControl()
								.code('if(')
							
							$type.check(node, ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type)
							
							ctrl
								.code(')')
								.step()
								.line('var ', parameter.name.name, parameter.name, ' = arguments[__ks_i]')
							
							ctrl
								.step()
								.code('else throw new Error("Invalid type for parameter \'', parameter.name.name, parameter.name, '\'")')
								.done()
						}
						else {
							ctrl = fragments
								.newControl()
								.code('if(!')
							
							$type.check(node, ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type)
							
							ctrl
								.code(')')
								.step()
								.line('throw new Error("Wrong type of arguments")')
								.done()
						}
					}
					
					if !inc {
						inc = true
					}
				}
			}
		} // }}}
	} // }}}
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
			
			if parameter.max == Infinity {
				if signature.max == Infinity {
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
	} // }}}
	signatureParameter(parameter, node) { // {{{
		let signature = {
			type: $signature.type(parameter.type, node),
			min: parameter.defaultValue || (parameter.type && parameter.type.nullable) ? 0 : 1,
			max: 1
		}
		
		if parameter.modifiers {
			for modifier in parameter.modifiers {
				if modifier.kind == ParameterModifier.Rest {
					signature.rest = true
					
					if modifier.arity {
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
	constructor(node, clazz, reflect, variable) { // {{{
		let extend = false
		if variable.extends {
			extend = func(node, ctrl?) {
				if ctrl {
					ctrl
						.step()
						.code('else')
						.step()
						.line(variable.extends.name.name + '.prototype.__ks_cons.call(this, args)')
				}
				else {
					node.line(variable.extends.name.name + '.prototype.__ks_cons.call(this, args)')
				}
			}
		}
		
		$helper.methods(extend, node, clazz.newControl(), '__ks_cons(args)', reflect.constructors, $continuous.methodCall^^(variable, 'prototype.__ks_cons_', 'args', ''), 'args', 'constructors', false)
	} // }}}
	methods(extend, node, fragments, header, methods, call, argName, refName, returns) { // {{{
		fragments.code(header).step()
		
		let method
		if methods.length == 0 {
			if extend {
				extend(fragments)
			}
			else {
				fragments
					.newControl()
					.code('if(' + argName + '.length !== 0)')
					.step()
					.code('throw new Error("Wrong number of arguments")')
					.done()
			}
		}
		else if methods.length == 1 {
			method = methods[0]
			
			if method.min == 0 && method.max >= Infinity {
				call(fragments, method, 0)
			}
			else {
				if method.min == method.max {
					let ctrl = fragments.newControl()
					
					ctrl.code('if(' + argName + '.length === ' + method.min + ')').step()
					
					call(ctrl, method, 0)
					
					if returns {
						if extend {
							extend(fragments, ctrl)
						}
						else {
							fragments.line('throw new Error("Wrong number of arguments")')
						}
					}
					else {
						if extend {
							extend(fragments, ctrl)
						}
						else {
							ctrl.step().code('else').step().line('throw new Error("Wrong number of arguments")')
						}
					}
					
					ctrl.done()
				}
				else if method.max < Infinity {
					let ctrl = fragments.newControl()
					
					ctrl.code('if(' + argName + '.length >= ' + method.min + ' && ' + argName + '.length <= ' + method.max + ')').step()
					
					call(ctrl, method, 0)
					
					if returns {
						fragments.line('throw new Error("Wrong number of arguments")')
					}
					else {
						ctrl.step().code('else').step().line('throw new Error("Wrong number of arguments")')
					}
					
					ctrl.done()
				}
				else {
					call(fragments, method, 0)
				}
			}
		}
		else {
		}
		
		fragments.done()
	} // }}}
	reflect(node, fragments, name, reflect) { // {{{
		let classname = name.name
		
		let line = fragments.newLine()
		
		line.code(classname + '.__ks_reflect = ')
		
		let object = line.newObject()
		
		if reflect.final {
			object.line('final: true')
		}
		
		object.newLine().code('inits: ' + reflect.inits)
		
		a = object.newLine().code('constructors: ').newArray()
		for i from 0 til reflect.constructors.length {
			$helper.reflectMethod(node, a.newLine(), reflect.constructors[i], classname + '.__ks_reflect.constructors[' + i + '].type')
		}
		a.done()
		
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
	reflectMethod(node, fragments, method, path?) { // {{{
		let object = fragments.newObject()
		
		object.newLine().code('access: ' + method.access)
		object.newLine().code('min: ' + method.min)
		object.newLine().code('max: ' + (method.max == Infinity ? 'Infinity' : method.max))
		
		let array = object.newLine().code('parameters: ').newArray()
		
		for parameter, i in method.parameters {
			$helper.reflectParameter(node, array.newLine(), parameter, path + '.parameters[' + i + ']')
		}
		
		array.done()
		
		object.done()
	} // }}}
	reflectParameter(node, fragments, parameter, path?) { // {{{
		let object = fragments.newObject()
		
		object.newLine().code('type: ' + $helper.type(parameter.type, node, path))
		object.newLine().code('min: ' + parameter.min)
		object.newLine().code('max: ' + parameter.max)
		
		object.done()
	} // }}}
	reflectVariable(node, fragments, name, variable, path?) { // {{{
		let object = fragments.code(name, ': ').newObject()
		
		object.line('access: ' + variable.access)
		
		if variable.type? {
			object.line('type: ' + $helper.type(variable.type, node, path))
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
		else if type == 'Any' || type == '...' {
			return $quote(type)
		}
		else if $runtime.typeof(type) {
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

const $import = {
	addVariable(module, file?, node, name, variable, data) { // {{{
		if variable.requirement? && data.references? {
			let nf = true
			for reference in data.references while nf {
				if (reference.foreign? && reference.foreign.name == variable.requirement) || reference.alias.name == variable.requirement {
					nf = false
					
					variable = $variable.merge(node.getVariable(reference.alias.name), variable)
				}
			}
		}
		
		node.addVariable(name, variable)
		
		module.import(name, file)
	} // }}}
	define(module, file?, node, name, kind, type?) { // {{{
		$variable.define(node, name, kind, type)
		
		module.import(name.name || name, file)
	} // }}}
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
	} // }}}
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
	} // }}}
	loadKSFile(x, moduleName?, module, data, node) { // {{{
		let file = null
		if !moduleName {
			file = moduleName = module.path(x, data.module)
		}
		
		let metadata, name, alias, variable
		
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
			if specifier.kind == Kind::ImportWildcardSpecifier {
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
		
		if importVarCount || importAll || importAlias.length {
			let nf
			for name, requirement of requirements {
				throw new Error(`Missing requirement '\(name)' at line \(data.start.line)`) if !requirement.nullable && (!?data.references || data.references.length == 0)
				
				nf = true
				if data.references {
					for reference in data.references while nf {
						if reference.foreign? {
							if reference.foreign.name == name {
								node.use(reference.alias, true)
								
								nf = false
							}
						}
						else {
							if reference.alias.name == name {
								node.use(reference.alias, true)
								
								nf = false
							}
						}
					}
				}
				
				if nf {
					if !requirement.nullable {
						throw new Error(`Missing requirement '\(name)' at line \(data.start.line)`)
					}
				}
			}
		}
		
		if importVarCount == 1 {
			for name, alias of importVariables {
			}
			
			throw new Error(`Undefined variable \(name) in the imported module at line \(data.start.line)`) unless variable ?= exports[name]
			
			$import.addVariable(module, file, node, alias, variable, data)
		}
		else if importVarCount {
			nf = false
			for name, alias of importVariables {
				throw new Error(`Undefined variable \(name) in the imported module at line \(data.start.line)`) unless variable ?= exports[name]
				
				$import.addVariable(module, file, node, alias, variable, data)
			}
		}
		
		if importAll {
			for name, variable of exports {
				$import.addVariable(module, file, node, name, variable, data)
			}
		}
		
		if importAlias.length {
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
		
		node._kind = ImportKind::KSFile
		node._metadata = {
			moduleName: moduleName
			exports: exports
			requirements: requirements
			importVariables: importVariables
			importVarCount: importVarCount
			importAll: importAll
			importAlias: importAlias
		}
		
		return true
	} // }}}
	loadNodeFile(x?, moduleName?, module, data, node) { // {{{
		let file = null
		if !moduleName {
			file = moduleName = module.path(x, data.module)
		}
		
		node._kind = ImportKind::NodeFile
		node._metadata = {
			moduleName: moduleName
		}
		
		let variables = node._metadata.variables = {}
		let count = 0
		
		for specifier in data.specifiers {
			if specifier.kind == Kind.ImportWildcardSpecifier {
				if specifier.local {
					node._metadata.wilcard = specifier.local.name
					
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
		
		node._metadata.count = count
		
		for alias of variables {
			$import.define(module, file, node, variables[alias], VariableKind::Variable)
		}
		
		return true
	} // }}}
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
	} // }}}
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
	} // }}}
	readMetadata(x) { // {{{
		try {
			return JSON.parse(fs.readFile(x + $extensions.metadata))
		}
		catch {
			return null
		}
	} // }}}
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
	} // }}}
	toKSFileFragments(node, fragments, data, metadata) { // {{{
		let {moduleName, exports, requirements, importVariables, importVarCount, importAll, importAlias} = metadata
		
		let name, alias, variable, importCode
		
		if (importVarCount && importAll) || (importVarCount && importAlias.length) || (importAll && importAlias.length) {
			importCode = node.acquireTempName()
			
			let line = fragments
				.newLine()
				.code('var ', importCode, ' = require(', $quote(moduleName), ')(')
			
			let nf
			let first = true
			let nc = 0
			for name, requirement of requirements {
				nf = true
				if data.references {
					for reference in data.references while nf {
						if reference.foreign? {
							if reference.foreign.name == name {
								if first {
									first = false
								}
								else {
									line.code(', ')
								}
								
								for i from 0 til nc {
									if i {
										line.code(', ')
									}
									
									line.code('null')
								}
								
								line.code(reference.alias.name)
								
								if requirement.class {
									line.code(', __ks_' + reference.alias.name)
								}
								
								nf = false
							}
						}
						else {
							if reference.alias.name == name {
								if first {
									first = false
								}
								else {
									line.code(', ')
								}
								
								for i from 0 til nc {
									if i {
										line.code(', ')
									}
									
									line.code('null')
								}
								
								line.code(reference.alias.name)
								
								if requirement.class {
									line.code(', __ks_' + reference.alias.name)
								}
								
								nf = false
							}
						}
					}
				}
				
				if nf {
					if requirement.nullable {
						++nc
						++nc if requirement.class
					}
					else {
						throw new Error(`Missing requirement '\(name)' at line \(data.start.line)`)
					}
				}
			}
			
			line.code(')').done()
		}
		else if importVarCount || importAll || importAlias.length {
			importCode = 'require(' + $quote(moduleName) + ')('
			
			let nf
			let first = true
			let nc = 0
			for name, requirement of requirements {
				throw new Error(`Missing requirement '\(name)' at line \(data.start.line)`) if !requirement.nullable && (!?data.references || data.references.length == 0)
				
				nf = true
				if data.references {
					for reference in data.references while nf {
						if reference.foreign? {
							if reference.foreign.name == name {
								if first {
									first = false
								}
								else {
									importCode += ', '
								}
								
								for i from 0 til nc {
									if i {
										importCode += ', '
									}
									
									importCode += 'null'
								}
								
								importCode += reference.alias.name
								
								if requirement.class {
									importCode += ', __ks_' + reference.alias.name
								}
								
								nf = false
							}
						}
						else {
							if reference.alias.name == name {
								if first {
									first = false
								}
								else {
									importCode += ', '
								}
								
								for i from 0 til nc {
									if i {
										importCode += ', '
									}
									
									importCode += 'null'
								}
								
								importCode += reference.alias.name
								
								if requirement.class {
									importCode += ', __ks_' + reference.alias.name
								}
								
								nf = false
							}
						}
					}
				}
				
				if nf {
					if requirement.nullable {
						++nc
						++nc if requirement.class
					}
					else {
						throw new Error(`Missing requirement '\(name)' at line \(data.start.line)`)
					}
				}
			}
			
			importCode += ')'
		}
		
		if importVarCount == 1 {
			for name, alias of importVariables {
			}
			
			variable = exports[name]
			
			if variable.kind != VariableKind::TypeAlias {
				if variable.kind == VariableKind::Class && variable.final {
					variable.final.name = '__ks_' + alias
					
					fragments.newLine().code(`var {\(alias), \(variable.final.name)} = \(importCode)`).done()
				}
				else {
					fragments.newLine().code(`var \(alias) = \(importCode).\(name)`).done()
				}
			}
		}
		else if importVarCount {
			let line = fragments.newLine().code('var {')
			
			let nf = false
			for name, alias of importVariables {
				variable = exports[name]
				
				if variable.kind != VariableKind::TypeAlias {
					if nf {
						line.code(', ')
					}
					else {
						nf = true
					}
					
					if alias == name {
						line.code(name)
						
						if variable.kind == VariableKind::Class && variable.final {
							line.code(', ', variable.final.name)
						}
					}
					else {
						line.code(name, ': ', alias)
						
						if variable.kind == VariableKind::Class && variable.final {
							variable.final.name = '__ks_' + alias
							
							line.code(', ', variable.final.name)
						}
					}
				}
			}
			
			line.code('} = ', importCode).done()
		}
		
		if importAll {
			let variables = []
			
			for name, variable of exports {
				if variable.kind != VariableKind::TypeAlias {
					variables.push(name)
					
					if variable.kind == VariableKind::Class && variable.final {
						variable.final.name = '__ks_' + name
						
						variables.push(variable.final.name)
					}
				}
			}
			
			if variables.length == 1 {
				fragments
					.newLine()
					.code('var ', variables[0], ' = ', importCode, '.' + variables[0])
					.done()
			}
			else if variables.length {
				let line = fragments.newLine().code('var {')
				
				nf = false
				for name in variables {
					if nf {
						line.code(', ')
					}
					else {
						nf = true
					}
					
					line.code(name)
				}
				
				line.code('} = ', importCode).done()
			}
		}
		
		if importAlias.length {
			fragments.newLine().code('var ', importAlias, ' = ', importCode).done()
		}
		
		node.releaseTempName(importCode)
	} // }}}
	toNodeFileFragments(node, fragments, data, metadata) { // {{{
		let moduleName = metadata.moduleName
		
		if metadata.wilcard? {
			fragments.line('var ', metadata.wilcard, ' = require(', $quote(moduleName), ')')
		}
		
		let variables = metadata.variables
		let count = metadata.count
		
		if count == 1 {
			let alias
			for alias of variables {
			}
			
			fragments.line('var ', variables[alias], ' = require(', $quote(moduleName), ').', alias)
		}
		else if count {
			let line = fragments.newLine().code('var {')
			
			let nf = false
			for alias of variables {
				if nf {
					line.code(', ')
				}
				else {
					nf = true
				}
				
				if variables[alias] == alias {
					line.code(alias)
				}
				else {
					line.code(alias, ': ', variables[alias])
				}
			}
			
			line.code('} = require(', $quote(moduleName), ')')
			
			line.done()
		}
	} // }}}
}

const $method = {
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

func $return(data?) { // {{{
	return {statements: []}	if !?data
	return data				if data.kind == Kind::Block
	
	return {
		kind: Kind::Block
		statements: [
			{
				kind: Kind::ReturnStatement
				value: data
			}
		]
	}
} // }}}

func $statements(data) { // {{{
	return data.statements if data.kind == Kind::Block
	
	return [
		{
			kind: Kind::ReturnStatement
			value: data
		}
	]
} // }}}

const $runtime = {
	helper(node) { // {{{
		return node._options.runtime.Helper
	} // }}}
	package(node) { // {{{
		return node._options.runtime.package
	} // }}}
	type(node) { // {{{
		node.module().flag('Type') if node.module?
		
		return node._options.runtime.Type
	} // }}}
	typeof(type, node?) { // {{{
		if node? {
			return false unless $typeofs[type]
			
			if type == 'NaN' {
				return 'isNaN'
			}
			else {
				return $runtime.type(node) + '.is' + type
			}
		}
		else {
			return $typeofs[type]
		}
	} // }}}
}

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

func $toInt(data, defaultValue) { // {{{
	switch data.kind {
		Kind::NumericExpression	=> return data.value
								=> return defaultValue
	}
} // }}}

const $type = {
	check(node, fragments, name, type) { // {{{
		if type.kind == Kind::TypeReference {
			type = $type.unalias(type, node)
			
			if type.typeParameters {
				if $generics[type.typeName.name] || !$types[type.typeName.name] || $generics[$types[type.typeName.name]] {
					let tof = $runtime.typeof(type.typeName.name, node) || $runtime.typeof($types[type.typeName.name], node)
					
					if tof {
						fragments
							.code(tof + '(', name)
						
						for typeParameter in type.typeParameters {
							fragments
								.code(', ')
								.expression(typeParameter)
						}
						
						fragments.code(')')
					}
					else {
						fragments
							.code($runtime.type(node), '.is(', name, ', ')
							.expression(type.typeName)
						
						for typeParameter in type.typeParameters {
							fragments
								.code(', ')
								.expression(typeParameter)
						}
						
						fragments.code(')')
					}
				}
				else {
					throw new Error('Generic on primitive at line ' + type.start.line)
				}
			}
			else {
				let tof = $runtime.typeof(type.typeName.name, node) || $runtime.typeof($types[type.typeName.name], node)
				
				if tof {
					fragments
						.code(tof + '(', name, ')')
				}
				else {
					fragments
						.code($runtime.type(node), '.is(', name, ', ')
						.expression(type)
						.code(')')
				}
			}
		}
		else if type.types {
			fragments.code('(')
			
			for i from 0 til type.types.length {
				if i {
					fragments.code(' || ')
				}
				
				$type.check(node, fragments, name, type.types[i])
			}
			
			fragments.code(')')
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
			Kind::ArrayComprehension, Kind::ArrayExpression, Kind::ArrayRange => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: Kind::TypeReference
						typeName: {
							kind: Kind::Identifier
							name: 'Array'
						}
					}
				}
			}
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
			Kind::ObjectExpression => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: Kind::TypeReference
						typeName: {
							kind: Kind::Identifier
							name: 'Object'
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
			Kind::TemplateExpression => {
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
	merge(variable, importedVariable) { // {{{
		if variable.kind == VariableKind::Class {
			Array.merge(variable.constructors, importedVariable.constructors)
			Object.merge(variable.instanceVariables, importedVariable.instanceVariables)
			Object.merge(variable.classVariables, importedVariable.classVariables)
			Object.merge(variable.instanceMethods, importedVariable.instanceMethods)
			Object.merge(variable.classMethods, importedVariable.classMethods)
			Object.merge(variable.final.instanceMethods, importedVariable.final.instanceMethods)
			Object.merge(variable.final.classMethods, importedVariable.final.classMethods)
		}
		
		return variable
	} // }}}
	scope(node) { // {{{
		return node._options.variables == 'es5' ? 'var ' : 'let '
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

class Base {
	private {
		_data
		_options
		_parent = null
	}
	Base(@data)
	Base(@data, @parent) { // {{{
		this._options = $applyAttributes(data, parent._options)
	} // }}}
	greatParent() => this._parent?._parent
	module() => this._parent.module()
	parent() => this._parent
	scope() => this._parent.scope()
	statement() => this._parent.statement()
}

// {{{ block/scope
class Block extends Base {
	private {
		_body: Array		= []
		_prepared			= false
		_renamedIndexes 	= {}
		_renamedVariables	= {}
		_variables			= {}
	}
	addVariable(name, definition) { // {{{
		this._variables[name] = definition
		
		return this
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
		return this._variables[name]? || (this._parent? && this._parent.scope().hasVariable(name, true))
	} // }}}
	rename(name) { // {{{
		let newName = this.newRenamedVariable(name)
		if newName != name {
			this._renamedVariables[name] = newName
		}
	
		return this
	} // }}}
	scope() => this
	statement() => this._parent.statement()
	toFragments(fragments) { // {{{
		for statement in this._body {
			statement.toFragments(fragments)
		}
	} // }}}
}

class AbstractScope extends Block {
	private {
		_scopeParent		= null
		_tempNextIndex 		= 0
		_tempNames			= {}
		_tempNameCount		= 0
	}
	acquireTempName(node?, assignment = false, fromChild = true) { // {{{
		if this._scopeParent && (name ?= this._scopeParent.acquireTempNameFromKid()) {
			this._tempParentNames[name] = true
			
			return name
		}
		
		if this._tempNameCount {
			for i from 0 til this._tempNextIndex when this._tempNames[i] {
				--this._tempNameCount
				
				name = this._tempNames[i]
				
				this._tempNames[i] = false
				
				return name
			}
		}
		else {
			let name = '__ks_' + this._tempNextIndex
			
			++this._tempNextIndex
			
			return name
		}
	} // }}}
	private acquireTempNameFromKid() { // {{{
		if this._scopeParent && (name ?= this._scopeParent.acquireTempNameFromKid()) {
			this._tempParentNames[name] = true
			
			return name
		}
		
		if this._tempNameCount {
			for i from 0 til this._tempNextIndex when this._tempNames[i] {
				--this._tempNameCount
				
				name = this._tempNames[i]
				
				this._tempNames[i] = false
				
				return name
			}
		}
		
		return null
	} // }}}
	getRenamedVariable(name) { // {{{
		if this._renamedVariables[name] {
			return this._renamedVariables[name]
		}
		else {
			return name
		}
	} // }}}
	newBlock() => $expressions[Kind::Block]({}, this)
	newBlock(data, parent) => $expressions[Kind::Block](data, parent)
	newRenamedVariable(name) { // {{{
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
	releaseTempName(name, fromChild = true) { // {{{
		if name.length > 5 && name.substr(0, 5) == '__ks_' {
			if this._scopeParent && this._tempParentNames[name] {
				this._scopeParent.releaseTempNameFromKid(name)
				
				this._tempParentNames[name] = false
			}
			else {
				++this._tempNameCount
				
				this._tempNames[name.substr(5)] = name
			}
		}
		
		return this
	} // }}}
	private releaseTempNameFromKid(name) { // {{{
		if this._scopeParent && this._tempParentNames[name] {
			this._scopeParent.releaseTempNameFromKid(name)
			
			this._tempParentNames[name] = false
		}
		else {
			++this._tempNameCount
				
			this._tempNames[name.substr(5)] = name
		}
	} // }}}
	updateTempNames() { // {{{
		if this._scopeParent && this._scopeParent._tempNextIndex > this._tempNextIndex {
			this._tempNextIndex = this._scopeParent._tempNextIndex
		}
	} // }}}
}

class FunctionScope extends AbstractScope {
	FunctionScope(data, parent) { // {{{
		super(data, parent)
	} // }}}
	compile() { // {{{
		for statement in this._data.statements {
			this._body.push($compile.statement(statement, this))
		}
	} // }}}
}

class ModuleScope extends AbstractScope {
	private {
		_module
	}
	ModuleScope(data, @module) { // {{{
		super(data)
		
		this._options = $applyAttributes(data, module._options)
		
		for statement in data.body {
			this._body.push($compile.statement(statement, this))
		}
	} // }}}
	compile() { // {{{
		for statement in this._body {
			statement.compile()
		}
	} // }}}
	module() => this._module
}

class Scope extends AbstractScope {
	Scope(data, parent) { // {{{
		super(data, parent)
		
		while !(parent is AbstractScope) {
			parent = parent._parent
		}
		
		this._scopeParent = parent
		this._tempNextIndex = parent._tempNextIndex
		this._tempParentNames = {}
		
		if data.statements {
			for statement in data.statements {
				this._body.push($compile.statement(statement, this))
			}
		}
	} // }}}
}

class XScope extends Block {
	XScope(data, parent) { // {{{
		super(data, parent)
		
		if data.statements {
			for statement in data.statements {
				this._body.push($compile.statement(statement, this))
			}
		}
	} // }}}
	acquireTempName(node?, assignment = false, fromChild = true) { // {{{
		return this._parent.acquireTempName(node, assignment, fromChild)
	} // }}}
	getRenamedVariable(name) { // {{{
		if this._renamedVariables[name] {
			return this._renamedVariables[name]
		}
		else if this._variables[name] {
			return name
		}
		else {
			return this._parent.getRenamedVariable(name)
		}
	} // }}}
	newBlock() => new XScope({}, this)
	newBlock(data, parent) => new XScope(data, parent)
	newRenamedVariable(name) { // {{{
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
			return this._parent.newRenamedVariable(name)
		}
	} // }}}
	releaseTempName(name, fromChild = true) { // {{{
		this._parent.releaseTempName(name, fromChild)
		
		return this
	} // }}}
	updateTempNames() { // {{{
	} // }}}
}
// }}}

class Module {
	private {
		_binary		: Boolean	= false
		_body
		_compiler	: Compiler
		_data
		_directory
		_dynamicRequirements	= []
		_exportSource			= []
		_exportMeta				= {}
		_flags					= {}
		_imports				= {}
		_options
		_output
		_register				= false
		_requirements			= {}
		_rewire
	}
	Module(@data, @compiler, @directory) { // {{{
		this._options = $applyAttributes(data, this._compiler._options.config)
		
		this._body = new ModuleScope(data, this)
		
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
	compile() { // {{{
		this._body.compile()
	} // }}}
	directory() => this._directory
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
	} // }}}
	flag(name) { // {{{
		this._flags[name] = true
	} // }}}
	import(name, file?) { // {{{
		this._imports[name] = true
		
		if file && file.slice(-$extensions.source.length).toLowerCase() == $extensions.source {
			this._register = true
		}
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
	require(name, kind, requireFirst) { // {{{
		if this._binary {
			throw new Error('Binary file can\'t require')
		}
		
		let requirement = {
			name: name
			class: kind == VariableKind::Class
			parameter: this._body.acquireTempName()
			requireFirst: requireFirst
		}
		
		this._requirements[requirement.parameter] = requirement
		
		this._dynamicRequirements.push(requirement)
	} // }}}
	toFragments() { // {{{
		this._body.toFragments(builder = new FragmentBuilder())
		
		if this._binary {
			return builder.toArray()
		}
		else {
			let body = builder.toArray()
			
			let fragments: Array = []
			
			let helper = $runtime.helper(this)
			let type = $runtime.type(this)
			
			let hasHelper = !this._flags.Helper || this._requirements[helper] || this._imports[helper]
			let hasType = !this._flags.Type || this._requirements[type] || this._imports[type]
			
			if !hasHelper || !hasType {
				if hasHelper {
					fragments.push($code('var ' + type + ' = require("' + $runtime.package(this) + '").Type;\n'))
				}
				else if hasType {
					fragments.push($code('var ' + helper + ' = require("' + $runtime.package(this) + '").Helper;\n'))
				}
				else {
					helper = `Helper: \(helper)` unless helper == 'Helper'
					type = `Type: \(type)` unless type == 'Type'
					
					fragments.push($code('var {' + helper + ', ' + type + '} = require("' + $runtime.package(this) + '");\n'))
				}
			}
			
			if this._register && this._options.register {
				fragments.push($code('require("kaoscript/register");\n'))
			}
			
			if this._options.header {
				fragments.push($code(`// Generated by kaoscript \(metadata.version)\n`))
			}
			
			fragments.push($code('module.exports = function('))
			
			let nf = false
			for name of this._requirements {
				if nf {
					fragments.push($comma)
				}
				else {
					nf = true
				}
				
				fragments.push($code(name))
				
				if this._requirements[name].class {
					fragments.push($code(', __ks_' + name))
				}
			}
			
			fragments.push($code(') {\n'))
			
			fragments.append(body)
			
			if this._exportSource.length {
				fragments.push($code('\treturn {'))
				
				nf = false
				for src in this._exportSource {
					if nf {
						fragments.push($code(','))
					}
					else {
						nf = true
					}
					
					fragments.push($code('\n\t\t' + src))
				}
				
				fragments.push($code('\n\t};\n'))
			}
			
			fragments.push($code('}'))
			
			return fragments
		}
	} // }}}
	toMetadata() { // {{{
		let data = {
			requirements: {},
			exports: {}
		}
		
		for name, variable of this._requirements {
			if variable.parameter {
				if variable.class {
					data.requirements[variable.name] = {
						class: true
						nullable: true
					}
				}
				else {
					data.requirements[variable.name] = {
						nullable: true
					}
				}
			}
			else {
				if variable.class {
					data.requirements[name] = {
						class: true
					}
				}
				else {
					data.requirements[name] = {}
				}
			}
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
}

// {{{ Statements
class Statement extends Base {
	private {
		_usages				= []
		_variables	: Array	= []
	}
	acquireTempName(node?, assignment = false, fromChild = true) { // {{{
		return this._parent.acquireTempName(node, assignment, fromChild)
	} // }}}
	addVariable(name, definition) { // {{{
		this._parent.addVariable(name, definition)
		
		return this
	} // }}}
	assignment(data, allowAssignement = false) { // {{{
		if data.left.kind == Kind::Identifier && !this.hasVariable(data.left.name) {
			this._variables.push(data.left.name)
			
			$variable.define(this, data.left, $variable.kind(data.right.type), data.right.type)
		}
	} // }}}
	compile() { // {{{
	} // }}}
	getRenamedVariable(name) { // {{{
		return this._parent.getRenamedVariable(name)
	} // }}}
	getVariable(name, fromChild = true) { // {{{
		return this._parent.getVariable(name, fromChild)
	} // }}}
	hasVariable(name, fromChild = true) { // {{{
		return this.scope().hasVariable(name, fromChild)
	} // }}}
	newBlock() => this._parent.scope().newBlock()
	newBlock(data) => this._parent.scope().newBlock(data, this._parent)
	newRenamedVariable(name) { // {{{
		return this._parent.newRenamedVariable(name)
	} // }}}
	releaseTempName(name, fromChild = true) { // {{{
		this._parent.releaseTempName(name, fromChild)
		
		return this
	} // }}}
	rename(name) { // {{{
		this._parent.rename(name)
		
		return this
	} // }}}
	scope() => this._parent.scope()
	statement() => this
	toFragments(fragments) { // {{{
		for variable in this._usages {
			if !this.scope().hasVariable(variable.name) {
				throw new Error(`Undefined variable '\(variable.name)' at line \(variable.start.line)`)
			}
		}
		
		if this._variables.length {
			fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
		}
		
		this.toStatementFragments(fragments)
	} // }}}
	use(data, immediate = false) { // {{{
		if immediate {
			if data is Array {
				for item in data {
					throw new Error(`Undefined variable '\(item.name)' at line \(item.start.line)`) if item.kind == Kind::Identifier && !this._parent.hasVariable(item.name)
				}
			}
			else if data.kind == Kind::Identifier {
				throw new Error(`Undefined variable '\(data.name)' at line \(data.start.line)`) if !this._parent.hasVariable(data.name)
			}
		}
		else {
			if data is Array {
				for item in data {
					if item.kind == Kind::Identifier {
						this._usages.push({
							name: item.name,
							start: item.start
						})
					}
				}
			}
			else if data.kind == Kind::Identifier {
				this._usages.push({
					name: data.name,
					start: data.start
				})
			}
		}
	} // }}}
}

class ClassDeclaration extends Statement {
	private {
		_continuous = true
		_variable
	}
	ClassDeclaration(data, parent) { // {{{
		super(data, parent)
		
		this._variable = $variable.define(this, data.name, VariableKind::Class, data.type)
		
		let instanceVariableScope = new AbstractScope({}, this)
		
		$variable.define(instanceVariableScope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(this._variable.name))
		
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
					
					let variable = {
						data: member,
						signature: $field.signature(member, this)
					}
					
					if member.defaultValue? {
						variable.fragments = $compile.expression(member.defaultValue, instance ? instanceVariableScope : this)
					}
					
					if instance {
						this._variable.instanceVariables[member.name.name] = variable
					}
					else {
						this._variable.classVariables[member.name.name] = variable
					}
				}
				Kind::MethodDeclaration => {
					if member.name.name == this._variable.name.name {
						let method = $compile.statement(member, this)
						
						method.isConstructor(true)
						
						this._variable.constructors.push({
							data: member
							fragments: method
							signature: $method.signature(member, this)
						})
					}
					else {
						let instance = true
						for i from 0 til member.modifiers.length while instance {
							if member.modifiers[i].kind == MemberModifier::Static {
								instance = false
							}
						}
						
						if instance {
							if !(this._variable.instanceMethods[member.name.name] is Array) {
								this._variable.instanceMethods[member.name.name] = []
							}
							
							this._variable.instanceMethods[member.name.name].push({
								data: member,
								fragments: $compile.statement(member, this)
								signature: $method.signature(member, this)
							})
						}
						else {
							if !(this._variable.classMethods[member.name.name] is Array) {
								this._variable.classMethods[member.name.name] = []
							}
							
							this._variable.classMethods[member.name.name].push({
								data: member,
								fragments: $compile.statement(member, this)
								signature: $method.signature(member, this)
							})
						}
					}
				}
				=> {
					console.error(member)
					throw new Error('Unknow kind ' + member.kind)
				}
			}
		}
		
		for i from 0 til data.modifiers.length while this._continuous {
			if data.modifiers[i].kind == ClassModifier::Final {
				this._continuous = false
			}
		}
		
		if !this._continuous {
			this._variable.final = {
				name: '__ks_' + this._variable.name.name
				constructors: false
				instanceMethods: {}
				classMethods: {}
			}
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._continuous {
			//$continuous.class(this, fragments, this._data, this._variable)
		}
		else {
			$final.class(this, fragments, this._data, this._variable)
			
			fragments.line('var ' + this._variable.final.name + ' = {}')
		}
	} // }}}
}

class EnumDeclaration extends Statement {
	private {
		_members = []
		_variable
	}
	EnumDeclaration(data, parent) { // {{{
		super(data, parent)
		
		this._variable = $variable.define(this, data.name, VariableKind::Enum, data.type)
		
		for member in data.members {
			this._members.push(new EnumMember(member, this))
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._variable.new {
			let line = fragments.newLine().code($variable.scope(this), this._variable.name.name, $equals)
			let object = line.newObject()
			
			for member in this._members {
				member.toFragments(object.newLine())
			}
			
			object.done()
			line.done()
		}
		else {
			let line
			
			for member in this._members {
				member.toFragments(line = fragments.newLine())
				
				line.done()
			}
		}
	} // }}}
}

class EnumMember extends Base {
	private {
	}
	EnumMember(data, parent) { // {{{
		super(data, parent)
	} // }}}
	toFragments(fragments) { // {{{
		let variable = this._parent._variable
		
		if variable.new {
			fragments.code(this._data.name.name, ': ', $variable.value(variable, this._data))
		}
		else {
			fragments.code(variable.name.name || variable.name, '.', this._data.name.name, ' = ', $variable.value(variable, this._data))
		}
	} // }}}
}

class ExportDeclaration extends Statement {
	private {
		_declarations	= []
		_exports		= []
	}
	ExportDeclaration(data, parent) { // {{{
		super(data, parent)
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					this._declarations.push($compile.statement(declaration, this))
					
					this._exports.push({
						name: declaration.name
					})
				}
				Kind::ExportAlias => {
					this._exports.push(declaration)
				}
				Kind::EnumDeclaration => {
					this._declarations.push($compile.statement(declaration, this))
					
					this._exports.push({
						name: declaration.name
					})
				}
				Kind::Identifier => {
					this._exports.push({
						name: declaration
					})
				}
				Kind::VariableDeclaration => {
					this._declarations.push($compile.statement(declaration, this))
					
					for j from 0 til declaration.declarations.length {
						this._exports.push({
							name: declaration.declarations[j].name
						})
					}
				}
				=> {
					console.error(declaration)
					throw new Error('Not Implemented')
				}
			}
		}
	} // }}}
	compile() { // {{{
		for declaration in this._declarations {
			declaration.compile()
		}
		
		let module = this.module()
		
		for data in this._exports {
			module.export(data.name, data.alias)
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		for declaration in this._declarations {
			declaration.toFragments(fragments)
		}
	} // }}}
}

class ExpressionStatement extends Statement {
	private {
		_expression
		_variable			= ''
	}
	ExpressionStatement(data, parent) { // {{{
		super(data, parent)
		
		this._expression = $compile.expression(data, this)
	} // }}}
	assignment(data, allowAssignement = false) { // {{{
		if data.left.kind == Kind::Identifier && !this.hasVariable(data.left.name) {
			if !allowAssignement || this._variable.length {
				this._variables.push(data.left.name)
			}
			else {
				this._variable = data.left.name
			}
			
			$variable.define(this, data.left, $variable.kind(data.right.type), data.right.type)
		}
	} // }}}
	toFragments(fragments) { // {{{
		for variable in this._usages {
			if !this._parent.hasVariable(variable.name) {
				throw new Error(`Undefined variable '\(variable.name)' at line \(variable.start.line)`)
			}
		}
		
		if this._expression.toStatementFragments? {
			if this._variable.length {
				this._variables.unshift(this._variable)
			}
			
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			this._expression.toStatementFragments(fragments)
		}
		else {
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if this._variable.length {
				line.code($variable.scope(this))
			}
			
			line.compile(this._expression).done()
		}
	} // }}}
}

class ExternDeclaration extends Statement {
	private {
		_lines = []
	}
	ExternDeclaration(data, parent) { // {{{
		super(data, parent)
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(parent, declaration.name, VariableKind::Class, declaration)
					
					let continuous = true
					for i from 0 til declaration.modifiers.length while continuous {
						continuous = false if declaration.modifiers[i].kind == ClassModifier::Final
					}
					
					if !continuous {
						variable.final = {
							name: '__ks_' + variable.name.name
							constructors: false
							instanceMethods: {}
							classMethods: {}
						}
						
						this._lines.push('var ' + variable.final.name + ' = {}')
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, this)
					}
				}
				Kind::VariableDeclarator => {
					$variable.define(parent, declaration.name, $variable.kind(declaration.type), declaration.type)
				}
				=> {
					console.error(declaration)
					throw new Error('Unknow kind ' + declaration.kind)
				}
			}
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		for line in this._lines {
			fragments.line(line)
		}
	} // }}}
}

class ExternOrRequireDeclaration extends Statement {
	ExternOrRequireDeclaration(data, parent) { // {{{
		super(data, parent)
		
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(parent, declaration.name, VariableKind::Class, declaration)
					
					variable.requirement = declaration.name.name
					
					let continuous = true
					for i from 0 til declaration.modifiers.length while continuous {
						continuous = false if declaration.modifiers[i].kind == ClassModifier::Final
					}
					
					if !continuous {
						variable.final = {
							name: '__ks_' + variable.name.name
							constructors: false
							instanceMethods: {}
							classMethods: {}
						}
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, this)
					}
					
					module.require(declaration.name.name, VariableKind::Class, false)
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(parent, declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
					variable.requirement = declaration.name.name
					
					module.require(declaration.name.name, type, false)
				}
				=> {
					console.error(declaration)
					throw new Error('Unknow kind ' + declaration.kind)
				}
			}
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class ForFromStatement extends Statement {
	private {
		_body
		_by
		_til
		_to
		_until
		_variable
		_when
		_while
	}
	ForFromStatement(data, parent) { // {{{
		super(data, parent.newBlock())
		
		if !this.hasVariable(data.variable.name) {
			$variable.define(this, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		this._from = $compile.expression(data.from, this)
		
		if data.til {
			this._til = $compile.expression(data.til, this)
		}
		else {
			this._to = $compile.expression(data.to, this)
		}
		
		if data.by {
			this._by = $compile.expression(data.by, this)
		}
		
		if data.until {
			this._until = $compile.expression(data.until, this)
		}
		else if data.while {
			this._while = $compile.expression(data.while, this)
		}
		
		if data.when {
			this._when = $compile.expression(data.when, this)
		}
		
		this._body = this.newBlock($block(data.body))
	} // }}}
	toStatementFragments(fragments) { // {{{
		let data = this._data
		
		let ctrl = fragments.newControl().code('for(')
		
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code($equals).compile(this._from)
		
		let bound
		if data.til {
			if this._til.isComplex() {
				bound = this.acquireTempName()
				
				ctrl.code(bound, $equals).compile(this._til)
			}
		}
		else {
			if this._to.isComplex() {
				bound = this.acquireTempName()
				
				ctrl.code(bound, $equals).compile(this._to)
			}
		}
		
		let by
		if data.by && this._by.isComplex() {
			by = this.acquireTempName()
			
			ctrl.code($comma, by, $equals).compile(this._by)
		}
		
		ctrl.code('; ')
		
		if data.until {
			ctrl.code('!(').compileBoolean(this._until).code(') && ')
		}
		else if data.while {
			ctrl.compileBoolean(this._while).code(' && ')
		}
		
		ctrl.compile(this._variable)
		
		let desc = (data.by && data.by.kind == Kind::NumericExpression && data.by.value < 0) || (data.from.kind == Kind::NumericExpression && ((data.to && data.to.kind == Kind::NumericExpression && data.from.value > data.to.value) || (data.til && data.til.kind == Kind::NumericExpression && data.from.value > data.til.value)))
		
		if data.til {
			if desc {
				ctrl.code(' > ')
			}
			else {
				ctrl.code(' < ')
			}
			
			if this._til.isComplex() {
				ctrl.code(bound)
			}
			else {
				ctrl.compile(this._til)
			}
		}
		else {
			if desc {
				ctrl.code(' >= ')
			}
			else {
				ctrl.code(' <= ')
			}
			
			if this._to.isComplex() {
				ctrl.code(bound)
			}
			else {
				ctrl.compile(this._to)
			}
		}
		
		ctrl.code('; ')
		
		if data.by {
			if data.by.kind == Kind::NumericExpression {
				if data.by.value == 1 {
					ctrl.code('++').compile(this._variable)
				}
				else if data.by.value == -1 {
					ctrl.code('--').compile(this._variable)
				}
				else if data.by.value >= 0 {
					ctrl.compile(this._variable).code(' += ').compile(this._by)
				}
				else {
					ctrl.compile(this._variable).code(' -= ', -data.by.value)
				}
			}
			else {
				ctrl.compile(this._variable).code(' += ').compile(this._by)
			}
		}
		else if desc {
			ctrl.code('--').compile(this._variable)
		}
		else {
			ctrl.code('++').compile(this._variable)
		}
		
		ctrl.code(')').step()
		
		if data.when {
			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(this._when)
				.code(')')
				.step()
				.compile(this._body)
				.done()
		}
		else {
			ctrl.compile(this._body)
		}
		
		ctrl.done()
		
		this.releaseTempName(bound) if ?bound
		this.releaseTempName(by) if ?by
	} // }}}
}

class ForInStatement extends Statement {
	private {
		_body
		_index
		_until
		_value
		_variable
		_when
		_while
	}
	ForInStatement(data, parent) { // {{{
		super(data, parent.newBlock())
		
		this._value = $compile.expression(data.value, this)
		
		if !this.hasVariable(data.variable.name) {
			$variable.define(this, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		
		if data.index {
			this._index = $compile.expression(data.index, this)
			
			if data.index && (data.declaration || !this.hasVariable(data.index.name)) {
				$variable.define(this, data.index.name, $variable.kind(data.index.type), data.index.type)
			}
		}
		
		if data.until {
			this._until = $compile.expression(data.until, this)
		}
		else if data.while {
			this._while = $compile.expression(data.while, this)
		}
		
		if data.when {
			this._when = $compile.expression(data.when, this)
		}
		
		this._body = this.newBlock($block(data.body))
	} // }}}
	toStatementFragments(fragments) { // {{{
		let data = this._data
		
		let value, index, bound
		if this._value.isComplex() {
			value = this.greatParent().acquireTempName()
			
			this.parent().updateTempNames()
			
			let line = fragments.newLine()
			
			if !this.hasVariable(value) {
				line.code($variable.scope(this))
				
				$variable.define(this.greatParent(), value, VariableKind::Variable)
			}
			
			line.code(value, $equals).compile(this._value).done()
		}
		
		let ctrl
		
		if data.desc {
			if data.index && !data.declaration && this.greatParent().hasVariable(data.index.name) {
				fragments
					.newLine()
					.compile(this._index)
					.code($equals)
					.compile(value ?? this._value)
					.code('.length - 1')
					.done()
				
				ctrl = fragments
					.newControl()
					.code('for(')
			}
			else {
				index = this.acquireTempName() unless this._index?
				
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
					.compile(index ?? this._index)
					.code($equals)
					.compile(value ?? this._value)
					.code('.length - 1')
			}
		}
		else {
			if data.index && !data.declaration && this.greatParent().hasVariable(data.index.name) {
				fragments
					.newLine()
					.compile(this._index)
					.code(' = 0')
					.done()
				
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
			}
			else {
				index = this.acquireTempName() unless this._index?
				
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
					.compile(index ?? this._index)
					.code(' = 0, ')
			}
			
			bound = this.acquireTempName()
			
			ctrl
				.code(bound, $equals)
				.compile(value ?? this._value)
				.code('.length')
		}
		
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			ctrl.code($comma, data.variable.name)
		}
		
		ctrl.code('; ')
		
		if data.until {
			ctrl.code('!(').compile(this._until).code(') && ')
		}
		else if data.while {
			ctrl.compile(this._while).code(' && ')
		}
		
		if data.desc {
			ctrl
				.compile(index ?? this._index)
				.code(' >= 0; --')
				.compile(index ?? this._index)
		}
		else {
			ctrl
				.compile(index ?? this._index)
				.code(' < ' + bound + '; ++')
				.compile(index ?? this._index)
		}
		
		ctrl.code(')').step()
		
		ctrl
			.newLine()
			.compile(this._variable)
			.code($equals)
			.compile(value ?? this._value)
			.code('[')
			.compile(index ?? this._index)
			.code(']')
			.done()
		
		if data.when {
			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(this._when)
				.code(')')
				.step()
				.compile(this._body)
				.done()
		}
		else {
			ctrl.compile(this._body)
		}
		
		ctrl.done()
		
		this.greatParent().releaseTempName(value) if value?
		this.releaseTempName(index) if index?
		this.releaseTempName(bound) if bound?
	} // }}}
}

class ForOfStatement extends Statement {
	private {
		_body
		_index
		_until
		_value
		_variable
		_when
		_while
	}
	ForOfStatement(data, parent) { // {{{
		super(data, parent.newBlock())
		
		this._value = $compile.expression(data.value, this)
		
		if !this.hasVariable(data.variable.name) {
			$variable.define(this, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		
		if data.index {
			this._index = $compile.expression(data.index, this)
			
			if data.index && (data.declaration || !this.hasVariable(data.index.name)) {
				$variable.define(this, data.index.name, $variable.kind(data.index.type), data.index.type)
			}
		}
		
		if data.until {
			this._until = $compile.expression(data.until, this)
		}
		else if data.while {
			this._while = $compile.expression(data.while, this)
		}
		
		if data.when {
			this._when = $compile.expression(data.when, this)
		}
		
		this._body = this.newBlock($block(data.body))
	} // }}}
	toStatementFragments(fragments) { // {{{
		let data = this._data
		
		let value
		if this._value.isComplex() {
			value = this.greatParent().acquireTempName()
			
			this.parent().updateTempNames()
			
			let line = fragments.newLine()
			
			if !this.hasVariable(value) {
				line.code($variable.scope(this))
				
				$variable.define(this.greatParent(), value, VariableKind::Variable)
			}
			line.code(value, $equals).compile(this._value).done()
		}
		
		let ctrl = fragments.newControl().code('for(')
		
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code(' in ').compile(value ?? this._value).code(')').step()
		
		if data.index {
			let line = ctrl.newLine()
			
			if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
				line.code($variable.scope(this))
			}
			
			line.compile(this._index).code($equals).compile(value ?? this._value).code('[').compile(this._variable).code(']').done()
		}
		
		if data.until {
			ctrl
				.newControl()
				.code('if(')
				.compile(this._until)
				.code(')')
				.step()
				.line('break')
				.done()
		}
		else if data.while {
			ctrl
				.newControl()
				.code('if(!(')
				.compile(this._while)
				.code('))')
				.step()
				.line('break')
				.done()
		}
		
		if data.when {
			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(this._when)
				.code(')')
				.step()
				.compile(this._body)
				.done()
		}
		else {
			ctrl.compile(this._body)
		}
		
		ctrl.done()
		
		this.greatParent().releaseTempName(value) if value?
	} // }}}
}

class ForRangeStatement extends Statement {
	private {
		_body
		_by
		_til
		_to
		_until
		_variable
		_when
		_while
	}
	ForRangeStatement(data, parent) { // {{{
		super(data, parent.newBlock())
		
		if !this.hasVariable(data.variable.name) {
			$variable.define(this, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		this._from = $compile.expression(data.from, this)
		
		this._to = $compile.expression(data.to, this)
		
		if data.by {
			this._by = $compile.expression(data.by, this)
		}
		
		if data.until {
			this._until = $compile.expression(data.until, this)
		}
		else if data.while {
			this._while = $compile.expression(data.while, this)
		}
		
		if data.when {
			this._when = $compile.expression(data.when, this)
		}
		
		this._body = this.newBlock($block(data.body))
	} // }}}
	toStatementFragments(fragments) { // {{{
		let data = this._data
		
		let ctrl = fragments.newControl().code('for(')
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code($equals).compile(this._from)
		
		let bound
		if this._to.isComplex() {
			bound = this.acquireTempName()
			
			ctrl.code(bound, $equals).compile(this._to)
		}
		
		let by
		if data.by && this._by.isComplex() {
			by = this.acquireTempName()
			
			ctrl.code($comma, by, $equals).compile(this._by)
		}
		
		ctrl.code('; ')
		
		if data.until {
			ctrl.code('!(').compile(this._until).code(') && ')
		}
		else if data.while {
			ctrl.compile(this._while).code(' && ')
		}
		
		ctrl.compile(this._variable).code(' <= ').compile(bound ?? this._to).code('; ')
		
		if data.by {
			if data.by.kind == Kind::NumericExpression {
				if data.by.value == 1 {
					ctrl.code('++').compile(this._variable)
				}
				else {
					ctrl.compile(this._variable).code(' += ').compile(this._by)
				}
			}
			else {
				ctrl.compile(this._variable).code(' += ').compile(this._by)
			}
		}
		else {
			ctrl.code('++').compile(this._variable)
		}
		
		ctrl.code(')').step()
		
		if data.when {
			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(this._when)
				.code(')')
				.step()
				.compile(this._body)
				.done()
		}
		else {
			ctrl.compile(this._body)
		}
		
		ctrl.done()
		
		this.releaseTempName(bound) if bound?
		this.releaseTempName(by) if by?
	} // }}}
}


class FunctionDeclaration extends Statement {
	private {
		_parameters
		_statements
	}
	FunctionDeclaration(data, parent) { // {{{
		super(data, new FunctionScope({}, parent))
		
		variable = $variable.define(parent, data.name, VariableKind::Function, data.type)
		
		for modifier in data.modifiers {
			if modifier.kind == FunctionModifier::Async {
				variable.async = true
			}
		}
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $statements(data.body)]
	} // }}}
	toStatementFragments(fragments) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('function ' + this._data.name.name + '(')
		
		$function.parameters(this, ctrl, func(node) {
			node.code(')').step()
		})
		
		for statement in this._statements {
			ctrl.compile(statement)
		}
		
		ctrl.done()
	} // }}}
}

class Parameter {
	private {
		_defaultValue	= null
		_name			= null
	}
	Parameter(data, parent) { // {{{
		if data.name? {
			let signature = $function.signatureParameter(data, parent)
			
			if signature.rest {
				$variable.define(parent, data.name, VariableKind::Variable, {
					kind: Kind::TypeReference
					typeName: {
						kind: Kind::Identifier
						name: 'Array'
					}
				})
			}
			else {
				$variable.define(parent, data.name, $variable.kind(data.type), data.type)
			}
			
			this._name = $compile.expression(data.name, parent)
		}
		
		if data.defaultValue? {
			this._defaultValue = $compile.expression(data.defaultValue, parent)
		}
	} // }}}
}

class IfStatement extends Statement {
	private {
		_condition
		_else
		_elseifs
		_then
	}
	IfStatement(data, parent) { // {{{
		super(data, parent)
		
		this._condition = $compile.expression(data.condition, this)
		this._then = $compile.expression($block(data.then), this)
		
		if data.elseifs? {
			this._elseifs = [{
				condition: $compile.expression(elseif.condition, this)
				body: $compile.expression(elseif.body, this)
			} for elseif in data.elseifs]
		}
		
		this._else = $compile.expression($block(data.else.body), this) if data.else?
	} // }}}
	toStatementFragments(fragments) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('if(')
		
		if this._condition.isAssignable() {
			ctrl.code('(').compileBoolean(this._condition).code(')')
		}
		else {
			ctrl.compileBoolean(this._condition)
		}
		
		ctrl.code(')').step().compile(this._then)
		
		if this._elseifs? {
			for elseif in this._elseifs {
				ctrl.step().code('else if(')
				
				if elseif.condition.isAssignable() {
					ctrl.code('(').compileBoolean(elseif.condition).code(')')
				}
				else {
					ctrl.compileBoolean(elseif.condition)
				}
				
				ctrl.code(')').step().compile(elseif.body)
			}
		}
		
		if this._else? {
			ctrl
				.step()
				.code('else')
				.step()
				.compile(this._else)
		}
		
		ctrl.done()
	} // }}}
}

class ImplementDeclaration extends Statement {
	private {
		_members = []
	}
	ImplementDeclaration(data, parent) { // {{{
		super(data, parent)
		
		let variable = this.getVariable(data.class.name)
		
		if variable.kind != VariableKind::Class {
			throw new Error('Invalid class for impl at line ' + data.start.line)
		}
		
		for member in this._data.members {
			switch member.kind {
				Kind::FieldDeclaration => {
					this._members.push(new ImplementFieldDeclaration(member, this, variable))
				}
				Kind::MethodDeclaration => {
					this._members.push(new ImplementMethodDeclaration(member, this, variable))
				}
				=> {
					console.error(member)
					throw new Error('Unknow kind ' + member.kind)
				}
			}
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		this.module().flag('Helper')
		
		for member in this._members {
			member.toFragments(fragments)
		}
	} // }}}
}

class ImplementFieldDeclaration extends Statement {
	private {
		_variable
	}
	ImplementFieldDeclaration(data, parent, @variable) { // {{{
		super(data, parent)
		
		if variable.final {
			throw new Error('Can\'t add a field to a final class')
		}
	} // }}}
	toFragments(fragments) { // {{{
		let type = $signature.type(this._data.type, this)
		
		fragments.line($runtime.helper(this), '.newField(' + $quote(this._data.name.name) + ', ' + $helper.type(type, this) + ')')
	} // }}}
}

class ImplementMethodDeclaration extends Statement {
	private {
		_instance	= true
		_parameters
		_statements
		_variable
	}
	ImplementMethodDeclaration(data, parent, @variable) { // {{{
		super(data, new FunctionScope({}, parent))
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == MemberModifier.Static {
					this._instance = false
				}
			}
			
			if variable.final {
				if this._instance {
					if variable.final.instanceMethods[data.name.name] != true {
						variable.final.instanceMethods[data.name.name] = true
					}
				}
				else {
					if variable.final.classMethods[data.name.name] != true {
						variable.final.classMethods[data.name.name] = true
					}
				}
			}
			
			if data.name.kind == Kind::Identifier {
				let methods
				if this._instance {
					if !(variable.instanceMethods[data.name.name] is Array) {
						variable.instanceMethods[data.name.name] = []
					}
					
					methods = variable.instanceMethods[data.name.name]
				}
				else {
					if !(variable.classMethods[data.name.name] is Array) {
						variable.classMethods[data.name.name] = []
					}
					
					methods = variable.classMethods[data.name.name]
				}
				
				let method = {
					kind: Kind::MethodDeclaration
					name: data.name.name
					signature: $method.signature(data, this)
				}
				
				method.type = $type.type(data.type, this) if data.type
				
				methods.push(method)
			}
		}
		
		$variable.define(this, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(variable.name))
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $statements(data.body)]
	} // }}}
	toStatementFragments(fragments) { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			let line = fragments
				.newLine()
				.code($runtime.helper(this), '.', this._instance ? 'newInstanceMethod' : 'newClassMethod', '(')
			
			let object = line.newObject()
			
			object.newLine().code('class: ' + variable.name.name)
			
			if data.name.kind == Kind::Identifier {
				object.newLine().code('name: ' + $quote(data.name.name))
			}
			else if data.name.kind == Kind.TemplateExpression {
				object.newLine().code('name: ' + data.name.name)
			}
			else {
				console.error(data.name)
				throw new Error('Not Implemented')
			}
			
			if variable.final {
				object.newLine().code('final: ' + variable.final.name)
			}
			
			let ctrl = object.newControl().code('function: function(')
			
			$function.parameters(this, ctrl, func(fragments) {
				fragments.code(')').step()
			})
			
			for statement in this._statements {
				ctrl.compile(statement)
			}
			
			$helper.reflectMethod(this, object.newLine().code('signature: '), $method.signature(data, this))
			
			object.done()
			line.code(')').done()
		}
	} // }}}
}

class ImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	ImportDeclaration(data, parent) { // {{{
		super(data, parent)
		
		for declarator in data.declarations {
			this._declarators.push(new ImportDeclarator(declarator, this))
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		for declarator in this._declarators {
			declarator.toFragments(fragments)
		}
	} // }}}
}

class ImportDeclarator extends Statement {
	private {
		_metadata
		_kind
	}
	ImportDeclarator(data, parent) { // {{{
		super(data, parent)
		
		let module = this.module()
		
		$import.resolve(data, module.directory(), module, this)
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._kind == ImportKind::KSFile {
			$import.toKSFileFragments(this, fragments, this._data, this._metadata)
		}
		else if this._kind == ImportKind::NodeFile {
			$import.toNodeFileFragments(this, fragments, this._data, this._metadata)
		}
		else {
			throw new Error('Not Implemented')
		}
	} // }}}
}

class MethodDeclaration extends Statement {
	private {
		_isConstructor = false
		_name
		_parameters
		_statements
	}
	MethodDeclaration(data, parent) { // {{{
		super(data, new FunctionScope({}, parent))
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		if data._body? {
			this._statements = [$compile.statement(statement, this) for statement in $statements(data.body)]
		}
		else {
			this._statements = []
		}
	} // }}}
	isConstructor(@isConstructor) => this
	name(@name) => this
	toStatementFragments(fragments) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code(this._name + '(')
		
		$function.parameters(this, ctrl, func(node) {
			node.code(')').step()
		})
		
		let variable = this.greatParent()._variable
		
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
						throw new Error('Can\'t set member ' + name + ' (line ' + parameter.start.line + ')')
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

class RequireDeclaration extends Statement {
	private {
	}
	RequireDeclaration(data, parent) { // {{{
		super(data, parent)
		
		let module = parent.module()
		
		let type
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(parent, declaration.name, VariableKind::Class, declaration)
					
					variable.requirement = declaration.name.name
					
					let continuous = true
					for i from 0 til declaration.modifiers.length while continuous {
						continuous = false if declaration.modifiers[i].kind == ClassModifier::Final
					}
					
					if !continuous {
						variable.final = {
							name: '__ks_' + variable.name.name
							constructors: false
							instanceMethods: {}
							classMethods: {}
						}
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, parent)
					}
					
					module.require(declaration.name.name, VariableKind::Class)
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(parent, declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
					variable.requirement = declaration.name.name
					
					module.require(declaration.name.name, type)
				}
				=> {
					console.error(declaration)
					throw new Error('Unknow kind ' + declaration.kind)
				}
			}
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class ReturnStatement extends Statement {
	private {
		_value = null
	}
	ReturnStatement(data, parent) { // {{{
		super(data, parent)
		
		if data.value? {
			this._value = $compile.expression(data.value, this)
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._value? {
			fragments
				.newLine()
				.code('return ')
				.compile(this._value)
				.done()
		}
		else {
			fragments
				.newLine()
				.code('return', this._data)
				.done()
		}
	} // }}}
}

class TryStatement extends Statement {
	private {
		_body
		_catchClause
		_catchClauses = []
		_finalizer
	}
	TryStatement(data, parent) { // {{{
		super(data, parent)
		
		this._body = $compile.expression(data.body, this)
		if data.catchClauses? {
			for clause in data.catchClauses {
				this._catchClauses.push({
					body: $compile.expression(clause.body, this)
					type: $compile.expression(clause.type, this)
				})
				
				if clause.binding? {
					$variable.define(this, clause.binding, VariableKind::Variable)
				}
			}
		}
		
		if data.catchClause? {
			this._catchClause = $compile.expression(data.catchClause.body, this)
			
			if this._data.catchClause.binding? {
				$variable.define(this, data.catchClause.binding, VariableKind::Variable)
			}
		}
		
		this._finalizer = $compile.expression(data.finalizer, this) if data.finalizer?
	} // }}}
	toStatementFragments(fragments) { // {{{
		let finalizer = null
		
		if this._finalizer? {
			finalizer = this.acquireTempName()
			
			let line = fragments
				.newLine()
				.code($variable.scope(this), finalizer, ' = () =>')
			
			line
				.newBlock()
				.compile(this._finalizer)
				.done()
			
			line.done()
		}
		
		let ctrl = fragments
			.newControl()
			.code('try')
			.step()
			.compile(this._body)
		
		if finalizer? {
			ctrl.line(finalizer, '()')
		}
		
		ctrl.step()
		
		if this._catchClauses.length {
			this.module().flag('Type')
			
			let error = this.acquireTempName()
			
			ctrl.code('catch(', error, ')').step()
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			let ifs = ctrl.newControl()
			
			for clause, i in this._data.catchClauses {
				ifs.step().code('else ') if i
				
				ifs
					.code('if(', $runtime.type(this), '.is(', error, ', ')
					.compile(this._catchClauses[i].type)
					.code(')')
					.step()
					
				if clause.binding? {
					ifs.line($variable.scope(this), clause.binding.name, ' = ', error)
				}
				
				ifs.compile(this._catchClauses[i].body)
			}
			
			if this._catchClause? {
				ifs.step().code('else').step()
				
				if this._data.catchClause.binding? {
					ifs.line($variable.scope(this), this._data.catchClause.binding.name, ' = ', error)
				}
				
				ifs.compile(this._catchClause)
			}
			
			ifs.done()
			
			this.releaseTempName(error)
		}
		else if this._catchClause? {
			let error = this.acquireTempName()
			
			if this._data.catchClause.binding? {
				ctrl.code('catch(', this._data.catchClause.binding.name, ')').step()
			}
			else {
				ctrl.code('catch(', error, ')').step()
			}
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			ctrl.compile(this._catchClause)
			
			this.releaseTempName(error)
		}
		else {
			let error = this.acquireTempName()
			
			ctrl.code('catch(', error, ')').step()
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			this.releaseTempName(error)
		}
		
		ctrl.done()
	} // }}}
}

class UnlessStatement extends Statement {
	private {
		_body
		_then
	}
	UnlessStatement(data, parent) { // {{{
		super(data, parent)
		
		this._condition = $compile.expression(data.condition, this)
		this._then = $compile.expression(data.then, this)
	} // }}}
	toStatementFragments(fragments) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(this._condition)
			.code(')')
			.step()
			.compile(this._then)
			.done()
	} // }}}
}

class UntilStatement extends Statement {
	private {
		_body
		_condition
	}
	UntilStatement(data, parent) { // {{{
		super(data, parent)
		
		this._body = $compile.expression(data.body, this)
		this._condition = $compile.expression(data.condition, this)
	} // }}}
	toStatementFragments(fragments) { // {{{
		fragments
			.newControl()
			.code('while(!(')
			.compileBoolean(this._condition)
			.code('))')
			.step()
			.compile(this._body)
			.done()
	} // }}}
}

class VariableDeclaration extends Statement {
	private {
		_declarators = []
		_init = false
	}
	VariableDeclaration(data, parent) { // {{{
		super(data, parent)
		
		for declarator in data.declarations {
			this._declarators.push(new VariableDeclarator(declarator, this))
		}
	} // }}}
	modifier(data) { // {{{
		if data.name.kind == Kind::ArrayBinding || data.name.kind == Kind::ObjectBinding || this._options.variables == 'es5' {
			return $code('var')
		}
		else {
			if this._data.modifiers.kind == VariableModifier::Let {
				return $code('let', this._data.modifiers.start, this._data.modifiers.end)
			}
			else {
				return $code('const', this._data.modifiers.start, this._data.modifiers.end)
			}
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._declarators.length == 1 {
			this._declarators[0].toFragments(fragments, this._data.modifiers)
		}
		else {
			let line = fragments.newLine().code(this.modifier(this._declarators[0]._data), $space)
			
			for declarator, index in this._declarators {
				line.code($comma) if index
				
				line.compile(declarator._name)
			}
			
			line.done()
		}
	} // }}}
}

class VariableDeclarator extends Base {
	private {
		_init	= false
	}
	VariableDeclarator(data, parent) { // {{{
		super(data, parent)
		
		if data.name.kind == Kind::Identifier && this._options.variables == 'es5' {
			parent.rename(data.name.name)
		}
		
		this._name = $compile.expression(data.name, this)
		
		if data.autotype {
			let type = data.type
			
			if !type && data.init {
				type = data.init
			}
			
			$variable.define(this._parent, data.name, $variable.kind(data.type), type)
		}
		else {
			$variable.define(this._parent, data.name, $variable.kind(data.type), data.type)
		}
		
		if data.init {
			this._init = $compile.expression(data.init, this)
		}
	} // }}}
	statement() => this._parent.statement()
	toFragments(fragments, modifier) { // {{{
		let line = fragments.newLine().code(this._parent.modifier(this._data), $space)
		
		line.compile(this._name)
		
		if this._init {
			line.code($equals).compile(this._init)
		}
		
		line.done()
	} // }}}
}

class WhileStatement extends Statement {
	private {
		_body
		_condition
	}
	WhileStatement(data, parent) { // {{{
		super(data, parent)
		
		this._body = $compile.expression(data.body, this)
		this._condition = $compile.expression(data.condition, this)
	} // }}}
	toStatementFragments(fragments) { // {{{
		fragments
			.newControl()
			.code('while(')
			.compileBoolean(this._condition)
			.code(')')
			.step()
			.compile(this._body)
			.done()
	} // }}}
}
// }}}

// {{{ Expressions
class Expression extends Base {
	isAssignable() => false
	assignment(data) { // {{{
		this._parent.assignment(data, this.isAssignable())
	} // }}}
	assignment(data, variable) { // {{{
		this._parent.assignment(data, variable && this.isAssignable())
	} // }}}
	getRenamedVariable(name) { // {{{
		return this._parent.statement().getRenamedVariable(name)
	} // }}}
	isCallable() => false
	isComplex() => true
	isComputed() => false
	isConditional() => this.isNullable()
	isNullable() => false
	toBooleanFragments(fragments) => this.toFragments(fragments)
	toNullableFragments(fragments) => this.toFragments(fragments)
	toReusableFragments(fragments) => this.toFragments(fragments)
	use(data, immediate = false) { // {{{
		this._parent.statement().use(data, immediate)
	} // }}}
}

// {{{ Assignment Operators
class AssignmentOperatorExpression extends Expression {
	private {
		_left
		_right
	}
	isAssignable() => true
	isComputed() => true
	isNullable() => this._right.isNullable()
	AssignmentOperatorExpression(data, parent) { // {{{
		super(data, parent)
		
		this.assignment(data)
		
		this._left = $compile.expression(data.left, this)
		this._right = $compile.expression(data.right, this)
	} // }}}
	toNullableFragments(fragments) { // {{{
		fragments.compileNullable(this._right)
	} // }}}
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	toFragments(fragments) { // {{{
		fragments.compile(this._left).code($equals).compile(this._right)
	} // }}}
	toBooleanFragments(fragments) { // {{{
		fragments.compile(this._left).code($equals).wrap(this._right)
	} // }}}
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	isAssignable() => false
	toFragments(fragments) { // {{{
		if this._right.isNullable() {
			fragments
				.wrapBoolean(this._right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compile(this._right)
				.code(')', this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compile(this._right)
				.code(')', this._data.operator)
		}
		
		fragments
			.code(' ? ')
			.compile(this._left)
			.code($equals)
			.wrap(this._right)
			.code(' : undefined')
	} // }}}
	toBooleanFragments(fragments) { // {{{
		if this._right.isNullable() {
			fragments
				.wrapBoolean(this._right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compile(this._right)
				.code(')', this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compile(this._right)
				.code(')', this._data.operator)
		}
		
		fragments
			.code(' ? (')
			.compile(this._left)
			.code($equals)
			.wrap(this._right)
			.code(', true) : false')
	} // }}}
}
// }}}}

// {{{ Binary Operators
class BinaryOperatorExpression extends Expression {
	private {
		_left
		_right
	}
	isComputed() => true
	isNullable() => this._left.isNullable() || this._right.isNullable()
	BinaryOperatorExpression(data, parent) { // {{{
		super(data, parent)
		
		this._left = $compile.expression(data.left, this)
		this._right = $compile.expression(data.right, this)
	} // }}}
}

class BinaryOperatorAnd extends BinaryOperatorExpression {
	toFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('&&', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorEquality extends BinaryOperatorExpression {
	toFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('===', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorGreaterThan extends BinaryOperatorExpression {
	toFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('>', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorInequality extends BinaryOperatorExpression {
	toFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('!==', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorModulo extends BinaryOperatorExpression {
	toFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('%', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorMultiplication extends BinaryOperatorExpression {
	toFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('*', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorSubtraction extends BinaryOperatorExpression {
	toFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space, '-', this._data.operator, $space)
			.wrap(this._right)
	} // }}}
}
// }}}

class ArrayExpression extends Expression {
	private {
		_values
	}
	ArrayExpression(data, parent) { // {{{
		super(data, parent)
		
		this._values = [$compile.expression(value, this) for value in data.values]
	} // }}}
	toFragments(fragments) { // {{{
		fragments.code('[')
		
		for value, index in this._values {
			fragments.code($comma) if index
			
			fragments.compile(value)
		}
		
		fragments.code(']')
	} // }}}
}

class ArrayRange extends Expression {
	private {
		_by = null
		_from
		_to
	}
	ArrayRange(data, parent) { // {{{
		super(data, parent)
		
		this._from = $compile.expression(data.from ?? data.then, this)
		this._to = $compile.expression(data.to ?? data.til, this)
		this._by = $compile.expression(data.by, this) if data.by?
	} // }}}
	toFragments(fragments) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.newArrayRange(')
			.compile(this._from)
			.code(', ')
			.compile(this._to)
		
		if this._by == null {
			fragments.code(', 1')
		}
		else {
			fragments.code(', ').compile(this._by)
		}
		
		fragments.code(', ', !!this._data.from, ', ', !!this._data.to, ')')
	} // }}}
}

class CallExpression extends Expression {
	private {
		_arguments
		_callee
		_tempName = null
		_tested = false
	}
	CallExpression(data, parent) { // {{{
		super(data, parent)
		
		this._callee = $compile.expression(data.callee, this)
		
		this._arguments = [$compile.expression(argument, this) for argument in data.arguments]
	} // }}}
	isCallable() => !this._tempName?
	isNullable() { // {{{
		return this._data.nullable || this._callee.isNullable()
	} // }}}
	toFragments(fragments) { // {{{
		if this._tempName? {
			fragments.code(this._tempName)
		}
		else if this.isNullable() && !this._tested {
			fragments.wrapNullable(this).code(' ? ').compile(this._callee).code('(')
			
			for argument, index in this._arguments {
				fragments.code($comma) if index
				
				fragments.compile(argument)
			}
			
			fragments.code(') : undefined')
		}
		else {
			fragments.compile(this._callee).code('(')
			
			for argument, index in this._arguments {
				fragments.code($comma) if index
				
				fragments.compile(argument)
			}
			
			fragments.code(')')
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			this._tested = true
			
			if this._data.nullable {
				if this._callee.isNullable() {
					fragments
						.wrapNullable(this._callee)
						.code(' && ')
				}
				
				fragments
					.code($runtime.type(this) + '.isFunction(')
					.compileReusable(this._callee)
					.code(')')
			}
			else {
				if this._callee.isNullable() {
					fragments.compileNullable(this._callee)
				}
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		this._tempName = $code('__ks_0')
		
		fragments
			.code(this._tempName, $equals)
			.compile(this._callee)
			.code('(')
		
		for argument, index in this._arguments {
			fragments.code($comma) if index
			
			fragments.compile(argument)
		}
		
		fragments.code(')')
	} // }}}
}

class CallFinalExpression extends Expression {
	private {
		_arguments
		_callee
		_object
		_tempName = null
		_tested = false
	}
	CallFinalExpression(data, parent, @callee) { // {{{
		super(data, parent)
		
		this._object = $compile.expression(data.callee.object, this)
		
		this._arguments = [$compile.expression(argument, this) for argument in data.arguments]
	} // }}}
	isCallable() => !this._tempName?
	isNullable() { // {{{
		return this._data.nullable || this._callee.isNullable()
	} // }}}
	toFragments(fragments) { // {{{
		if this._callee.variable {
			if this._callee.instance {
				fragments
					.code((this._callee.variable.accessPath || ''), this._callee.variable.final.name, '._im_' + this._data.callee.property.name + '(')
					.compile(this._object)
				
				for i from 0 til this._arguments.length {
					fragments.code(', ').compile(this._arguments[i])
				}
				
				fragments.code(')')
			}
			else {
			}
		}
		else if this._callee.variables.length == 2 {
		}
		else {
			console.error(this._callee)
			throw new Error('Not Implemented')
		}
	} // }}}
}

class EnumExpression extends Expression {
	private {
		_enum
	}
	EnumExpression(data, parent) { // {{{
		super(data, parent)
		
		this._enum = $compile.expression(data.enum, this)
	} // }}}
	toFragments(fragments) { // {{{
		fragments.compile(this._enum).code('.', this._data.member.name)
	} // }}}
}

class FunctionExpression extends Expression {
	private {
		_parameters
		_statements
	}
	FunctionExpression(data, parent) { // {{{
		super(data, new FunctionScope({}, parent))
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $statements(data.body)]
	} // }}}
	toFragments(fragments) { // {{{
		fragments.code('function(')
		
		let block
		$function.parameters(this, fragments, func(node) {
			block = node.code(')').newBlock()
		})
		
		for statement in this._statements {
			block.compile(statement)
		}
		
		block.done()
	} // }}}
}

class IfExpression extends Expression {
	private {
		_condition
		_else
		_then
	}
	IfExpression(data, parent) { // {{{
		super(data, parent)
		
		this._condition = $compile.expression(data.condition, this)
		this._then = $compile.expression(data.then, this)
		this._else = $compile.expression(data.else, this) if data.else?
	} // }}}
	isComputed() => true
	toFragments(fragments) { // {{{
		if this._else? {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? ')
				.compile(this._then)
				.code(' : ')
				.compile(this._else)
		}
		else {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? ')
				.compile(this._then)
				.code(' : undefined')
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('if(')
		
		if this._condition.isAssignable() {
			ctrl.code('(').compileBoolean(this._condition).code(')')
		}
		else {
			ctrl.compileBoolean(this._condition)
		}
		
		ctrl.code(')').step().line(this._then).done()
	} // }}}
}

class MemberExpression extends Expression {
	private {
		_object
		_property
		_tested = false
	}
	MemberExpression(data, parent) { // {{{
		super(data, parent)
		
		this._object = $compile.expression(data.object, this)
		this._property = $compile.expression(data.property, this)
	} // }}}
	isCallable() { // {{{
		return this._object.isCallable()
	} // }}}
	isNullable() { // {{{
		return this._data.nullable || this._object.isNullable() || (this._data.computed && this._property.isNullable())
	} // }}}
	toFragments(fragments) { // {{{
		if this.isNullable() && !this._tested {
			fragments.wrapNullable(this).code(' ? ').compile(this._object)
			
			if this._data.computed {
				fragments.code('[').compile(this._property).code('] : undefined')
			}
			else {
				fragments.code($dot).compile(this._property).code(' : undefined')
			}
		}
		else {
			if this._object.isComputed() {
				fragments.code('(').compile(this._object).code(')')
			}
			else {
				fragments.compile(this._object)
			}
			
			if this._data.computed {
				fragments.code('[').compile(this._property).code(']')
			}
			else {
				fragments.code($dot).compile(this._property)
			}
		}
	} // }}}
	toBooleanFragments(fragments) { // {{{
		if this.isNullable() && !this._tested {
			if this._data.computed {
				throw new Error('Not Implemented')
			}
			else {
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(this._object)
					.code($dot)
					.compile(this._property)
					.code(' : false')
			}
		}
		else {
			if this._data.computed {
				throw new Error('Not Implemented')
			}
			else {
				fragments
					.compile(this._object)
					.code($dot)
					.compile(this._property)
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			this._tested = true
			
			let conditional = false
			
			if this._object.isNullable() {
				fragments.compileNullable(this._object)
				
				conditional = true
			}
			
			if this._data.nullable {
				fragments.code(' && ') if conditional
				
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(this._object)
					.code(')')
				
				conditional = true
			}
			
			if this._data.computed && this._property.isNullable() {
				fragments.code(' && ') if conditional
				
				fragments.compileNullable(this._property)
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		if this._object.isCallable() {
			fragments
				.code('(')
				.compileReusable(this._object)
				.code(', ')
				.compile(this._object)
				.code($dot)
				.compile(this._property)
				.code(')')
		}
		else {
			fragments
				.compile(this._object)
				.code($dot)
				.compile(this._property)
		}
	} // }}}
}

class ObjectExpression extends Expression {
	private {
		_properties
	}
	ObjectExpression(data, parent) { // {{{
		super(data, parent)
		
		this._properties = [$compile.expression(property, this) for property in data.properties]
	} // }}}
	toFragments(fragments) { // {{{
		if this._properties.length {
			let object = fragments.newObject()
			
			for property in this._properties {
				object.newLine().compile(property)
			}
			
			object.done()
		}
		else {
			fragments.code('{}')
		}
	} // }}}
}

class ObjectMember extends Expression {
	private {
		_name
		_value
	}
	ObjectMember(data, parent) { // {{{
		super(data, parent)
		
		this._name = $compile.objectMemberName(data.name, this)
		this._value = $compile.expression(data.value, this)
	} // }}}
	toFragments(fragments) { // {{{
		let data = this._data
		
		if data.name.kind == Kind::Identifier || data.name.kind == Kind::Literal {
			fragments.compile(this._name)
			
			if data.value.kind == Kind::FunctionExpression {
				fragments.compile(this._value)
			}
			else {
				fragments.code(': ').compile(this._value)
			}
		}
	} // }}}
}


class TernaryConditionalExpression extends Expression {
	private {
		_condition
		_else
		_then
	}
	TernaryConditionalExpression(data, parent) { // {{{
		super(data, parent)
		
		this._condition = $compile.expression(data.condition, this)
		this._then = $compile.expression(data.then, this)
		this._else = $compile.expression(data.else, this)
	} // }}}
	toFragments(fragments) { // {{{
		fragments
			.wrapBoolean(this._condition)
			.code(' ? ')
			.compile(this._then)
			.code(' : ')
			.compile(this._else)
	} // }}}
}

class TemplateExpression extends Expression {
	private {
		_elements
	}
	TemplateExpression(data, parent) { // {{{
		super(data, parent)
		
		this._elements = [$compile.expression(element, this) for element in data.elements]
	} // }}}
	isComputed() => this._data.elements > 1
	toFragments(fragments) { // {{{
		for element, index in this._elements {
			fragments.code(' + ') if index
			
			fragments.compile(element)
		}
	} // }}}
}

class UnlessExpression extends Expression {
	private {
		_condition
		_else
		_then
	}
	UnlessExpression(data, parent) { // {{{
		super(data, parent)
		
		this._condition = $compile.expression(data.condition, this)
		this._then = $compile.expression(data.then, this)
		this._else = $compile.expression(data.else, this) if data.else?
	} // }}}
	isComputed() => true
	toFragments(fragments) { // {{{
		if this._else? {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? ')
				.compile(this._else)
				.code(' : ')
				.compile(this._then)
		}
		else {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? undefined : ')
				.compile(this._then)
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(this._condition)
			.code(')')
			.step()
			.line(this._then)
			.done()
	} // }}}
}

// {{{ Unary Operators
class UnaryOperatorExistential extends Expression {
	private {
		_argument
	}
	UnaryOperatorExistential(data, parent) { // {{{
		super(data, parent)
		
		this._argument = $compile.expression(data.argument, this)
	} // }}}
	toFragments(fragments) { // {{{
		if this._argument.isNullable() {
			fragments
				.wrapNullable(this._argument)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(',  this._data.operator)
				.compile(this._argument)
				.code(')',  this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(',  this._data.operator)
				.compile(this._argument)
				.code(')',  this._data.operator)
		}
	} // }}}
}

class UnaryOperatorNegation extends Expression {
	private {
		_argument
	}
	UnaryOperatorNegation(data, parent) { // {{{
		super(data, parent)
		
		this._argument = $compile.expression(data.argument, this)
	} // }}}
	toFragments(fragments) { // {{{
		fragments
			.code('!', this._data.operator)
			.wrapBoolean(this._argument)
	} // }}}
}
class UnaryOperatorNew extends Expression {
	private {
		_argument
	}
	UnaryOperatorNew(data, parent) { // {{{
		super(data, parent)
		
		this._argument = $compile.expression(data.argument, this)
	} // }}}
	toFragments(fragments) { // {{{
		fragments
			.code('new', this._data.operator, $space)
			.wrap(this._argument)
	} // }}}
}
// }}}
// }}}

// {{{ Literals
class Literal extends Expression {
	private {
		_value
	}
	Literal(data, @value, parent) { // {{{
		super(data, parent)
	} // }}}
	isComplex() => false
	toFragments(fragments) { // {{{
		if this._data {
			fragments.code(this._value, this._data)
		}
		else {
			fragments.code(this._value)
		}
	} // }}}
}

class IdentifierLiteral extends Literal {
	private {
		_isVariable = false
	}
	IdentifierLiteral(data, parent, variable = true) { // {{{
		super(data, data.name, parent)
		
		if variable && !((parent is MemberExpression && parent._data.object != data) || $predefined[data.name]) {
			this._isVariable = true
			
			this.use(data)
		}
	} // }}}
	toFragments(fragments) { // {{{
		if this._isVariable {
			fragments.code(this.getRenamedVariable(this._value), this._data)
		}
		else {
			fragments.code(this._value, this._data)
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		fragments
			.code($runtime.type(this) + '.isValue(')
			.compile(this)
			.code(')')
	} // }}}
}

class NumberLiteral extends Literal { // {{{
	NumberLiteral(data, parent) { // {{{
		super(data, data.value, parent)
	} // }}}
} // }}}

class StringLiteral extends Literal { // {{{
	StringLiteral(data, parent) { // {{{
		super(data, $quote(data.value), parent)
	} // }}}
} // }}}

// }}}

const $compile = {
	expression(data, parent) { // {{{
		let clazz = $expressions[data.kind]
		
		if clazz {
			return Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
		}
		else if data.kind == Kind::BinaryOperator {
			if clazz = $binaryOperators[data.operator.kind] {
				return Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
			}
			
			if data.operator.kind == BinaryOperator::Assignment {
				if clazz = $assignmentOperators[data.operator.assignment] {
					return Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
				}
				
				console.error(data)
				throw new Error('Unknow assignment operator ' + data.operator.assignment)
			}
			
			console.error(data)
			throw new Error('Unknow binary operator ' + data.operator.kind)
		}
		else if data.kind == Kind::UnaryExpression {
			if clazz = $unaryOperators[data.operator.kind] {
				return Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
			}
			
			console.error(data)
			throw new Error('Unknow unary operator ' + data.operator.kind)
		}
		else {
			console.error(data)
			throw new Error('Unknow kind ' + data.kind)
		}
	} // }}}
	objectMemberName(data, parent) { // {{{
		switch(data.kind) {
			Kind::Identifier	=> return new IdentifierLiteral(data, parent, false)
			Kind::Literal		=> return new StringLiteral(data, parent)
								=> {
				console.error(data)
				throw new Error('Unknow member kind ' + data.kind)
			}
		}
	} // }}}
	statement(data, parent) { // {{{
		let clazz = $statements[data.kind] ?? $statements.default
		
		return new clazz(data, parent)
	} // }}}
}

const $assignmentOperators = {
	`\(AssignmentOperator::Equality)`		: AssignmentOperatorEquality
	`\(AssignmentOperator::Existential)`	: AssignmentOperatorExistential
}

const $binaryOperators = {
	`\(BinaryOperator::And)`				: BinaryOperatorAnd
	`\(BinaryOperator::Equality)`			: BinaryOperatorEquality
	`\(BinaryOperator::GreaterThan)`		: BinaryOperatorGreaterThan
	`\(BinaryOperator::Inequality)`			: BinaryOperatorInequality
	`\(BinaryOperator::Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperator::Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperator::Subtraction)`		: BinaryOperatorSubtraction
}

const $expressions = {
	`\(Kind::ArrayExpression)`				: ArrayExpression
	`\(Kind::ArrayRange)`					: ArrayRange
	`\(Kind::Block)`						: func(data, parent) {
		if parent._options.variables == 'es6' {
			return new Scope(data, parent)
		}
		else {
			return new XScope(data, parent)
		}
	}
	`\(Kind::CallExpression)`				: func(data, parent) {
		if data.callee.kind == Kind::MemberExpression && !data.callee.computed && (callee = $final.callee(data.callee, parent.scope())) {
			return new CallFinalExpression(data, parent, callee)
		}
		else {
			return new CallExpression(data, parent)
		}
	}
	`\(Kind::EnumExpression)`				: EnumExpression
	`\(Kind::FunctionExpression)`			: FunctionExpression
	`\(Kind::Identifier)`					: IdentifierLiteral
	`\(Kind::IfExpression)`					: IfExpression
	`\(Kind::Literal)`						: StringLiteral
	`\(Kind::MemberExpression)`				: MemberExpression
	`\(Kind::NumericExpression)`			: NumberLiteral
	`\(Kind::ObjectExpression)`				: ObjectExpression
	`\(Kind::ObjectMember)`					: ObjectMember
	`\(Kind::TemplateExpression)`			: TemplateExpression
	`\(Kind::TernaryConditionalExpression)`	: TernaryConditionalExpression
	`\(Kind::UnlessExpression)`				: UnlessExpression
}

const $statements = {
	`\(Kind::ClassDeclaration)`				: ClassDeclaration
	`\(Kind::EnumDeclaration)`				: EnumDeclaration
	`\(Kind::ExportDeclaration)`			: ExportDeclaration
	`\(Kind::ExternDeclaration)`			: ExternDeclaration
	`\(Kind::ExternOrRequireDeclaration)`	: ExternOrRequireDeclaration
	`\(Kind::ForFromStatement)`				: ForFromStatement
	`\(Kind::ForInStatement)`				: ForInStatement
	`\(Kind::ForOfStatement)`				: ForOfStatement
	`\(Kind::ForRangeStatement)`			: ForRangeStatement
	`\(Kind::FunctionDeclaration)`			: FunctionDeclaration
	`\(Kind::IfStatement)`					: IfStatement
	`\(Kind::ImplementDeclaration)`			: ImplementDeclaration
	`\(Kind::ImportDeclaration)`			: ImportDeclaration
	`\(Kind::MethodDeclaration)`			: MethodDeclaration
	`\(Kind::Module)`						: Module
	`\(Kind::RequireDeclaration)`			: RequireDeclaration
	`\(Kind::ReturnStatement)`				: ReturnStatement
	`\(Kind::TryStatement)`					: TryStatement
	`\(Kind::UnlessStatement)`				: UnlessStatement
	`\(Kind::UntilStatement)`				: UntilStatement
	`\(Kind::VariableDeclaration)`			: VariableDeclaration
	`\(Kind::WhileStatement)`				: WhileStatement
	`default`								: ExpressionStatement
}

const $unaryOperators = {
	`\(UnaryOperator::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperator::Negation)`			: UnaryOperatorNegation
	`\(UnaryOperator::New)`					: UnaryOperatorNew
}

export class Compiler {
	private {
		_file	: String
	}
	static {
		register() { // {{{
		} // }}}
	}
	Compiler(@file, options?) { // {{{
		this._options = Object.merge({
			context: 'node6',
			register: true,
			config: {
				header: true,
				parameters: 'kaoscript',
				runtime: {
					Helper: 'Helper',
					Type: 'Type',
					package: '@kaoscript/runtime'
				}
				variables: 'es6'
			}
		}, options)
	} // }}}
	compile(data?) { // {{{
		data ??= fs.readFile(this._file)
		
		this._sha256 = fs.sha256(data)
		
		let Class = $statements[Kind::Module]
		
		this._module = new Class(parse(data), this, path.dirname(this._file))
		
		this._module.compile()
		
		this._fragments = this._module.toFragments()
		
		/* console.time('parse')
		data = parse(data)
		console.timeEnd('parse')
		
		console.time('compile')
		this._module = new Class(data, this._options.config)
		
		this._fragments = this._module.toFragments()
		console.timeEnd('compile') */
		
		return this
	} // }}}
	toMetadata() { // {{{
		return this._module.toMetadata()
	} // }}}
	toSource() { // {{{
		let source = ''
		
		for fragment in this._fragments {
			source += fragment.code
		}
		
		return source
	} // }}}
	toSourceMap() { // {{{
		return this._module.toSourceMap()
	} // }}}
	writeFiles() { // {{{
		fs.writeFile(this._file + $extensions.binary, this.toSource())
		
		if !this._module._binary {
			let metadata = this.toMetadata()
			
			fs.writeFile(this._file + $extensions.metadata, JSON.stringify(metadata))
		}
		
		fs.writeFile(this._file + $extensions.hash, this._sha256)
	} // }}}
	writeOutput() { // {{{
		if !this._options.output {
			throw new Error('Undefined option: output')
		}
		
		let filename = path.join(this._options.output, path.basename(this._file)).slice(0, -3) + '.js'
		
		fs.writeFile(filename, this.toSource())
		
		return this
	} // }}}
}

export func compileFile(file, options?) { // {{{
	let compiler = new Compiler(file, options)
	
	return compiler.compile().toSource()
} // }}}

export $extensions as extensions