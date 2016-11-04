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

enum Mode {
	None
	Async
}

enum HelperTypeKind {
	Native
	Referenced
	Unreferenced
}

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
	module: true
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
		_indent
		_lines			= {}
		_objects		= {}
	}
	FragmentBuilder(@indent)
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
		_firstStep = true
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
	compile(node, mode = Mode::None) { // {{{
		this._step.compile(node, mode)
		
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
	isFirstStep() { // {{{
		return this._firstStep
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
		
		this._firstStep = false if this._firstStep
		
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
	compile(node, mode = Mode::None) { // {{{
		if node is Object {
			node.toFragments(this, mode)
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
				if i + 1 < args.length && (data = args[i + 1]) is Object && data.kind? {
					if data.start? {
						this._builder._fragments.push(new CodeFragment(arg, data.start, data.end))
					}
					else {
						this._builder._fragments.push(new CodeFragment(arg))
					}
					
					i++
				}
				else {
					this._builder._fragments.push(new CodeFragment(arg))
				}
			}
		}
		
		return this
	} // }}}
	compile(node, mode = Mode::None) { // {{{
		if node is Object {
			node.toFragments(this, mode)
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
	newArray(indent = this._indent) { // {{{
		return ArrayBuilder.create(this._builder, indent)
	} // }}}
	newBlock(indent = this._indent) { // {{{
		return BlockBuilder.create(this._builder, indent)
	} // }}}
	newControl(indent = this._indent + 1) { // {{{
		return new ControlBuilder(this._builder, indent)
	} // }}}
	newLine(indent = this._indent + 1) { // {{{
		return LineBuilder.create(this._builder, indent)
	} // }}}
	newObject(indent = this._indent) { // {{{
		return ObjectBuilder.create(this._builder, indent)
	} // }}}
	wrap(node, mode = Mode::None) { // {{{
		if node.isComputed() {
			this.code('(')
			
			node.toFragments(this, mode)
			
			this.code(')')
		}
		else {
			node.toFragments(this, mode)
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

func $caller(data, node) { // {{{
	if data.kind == Kind.Identifier {
		return $compile.expression(data, node)
	}
	else if data.kind == Kind.MemberExpression {
		return $compile.expression(data.object, node)
	}
	else {
		console.error(data)
		throw new Error('Not Implemented')
	}
} // }}}

const $continuous = {
	class(node, fragments) { // {{{
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
			$continuous.constructor(node, clazz, method.statement, method.signature, method.parameters, reflect)
		}
		
		$helper.constructor(node, clazz, reflect)
		
		for name, methods of node._instanceMethods {
			for method in methods {
				$continuous.instanceMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
			}
			
			$helper.instanceMethod(node, clazz, reflect, name)
		}
		
		for name, methods of node._classMethods {
			for method in methods {
				$continuous.classMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
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
		
		signature.type = type if data.type && (type ?= $signature.type(data.type, node.scope()))
		
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
	class(node, fragments) { // {{{
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
			final: true
			inits: 0
			constructors: []
			instanceVariables: node._instanceVariables
			classVariables: node._classVariables
			instanceMethods: {}
			classMethods: {}
		}
		
		for method in node._constructors {
			$continuous.constructor(node, clazz, method.statement, method.signature, method.parameters, reflect)
		}
		
		$helper.constructor(node, clazz, reflect)
		
		for name, methods of node._instanceMethods {
			for method in methods {
				$continuous.instanceMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
			}
			
			$helper.instanceMethod(node, clazz, reflect, name)
		}
		
		for name, methods of node._classMethods {
			for method in methods {
				$continuous.classMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
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
	parametersES5(node, fragments, fn) { // {{{
		let data = node._data
		let signature = $function.signature(data, node.scope())
		
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
			
			fragments.code($comma) if i
			
			fragments.code(parameter.name.name, parameter.name)
		}
		
		fn(fragments)
	} // }}}
	parametersES6(node, fragments, fn) { // {{{
		let data = node._data
		let signature = $function.signature(data, node.scope())
		let rest = false
		
		for parameter, i in data.parameters {
			if !parameter.name {
				throw new Error(`Parameter must be named at line \(parameter.start.line)`)
			}
			
			fragments.code($comma) if i
			
			if signature.parameters[i].rest {
				fragments.code('...').code(parameter.name.name, parameter.name)
				
				rest = true
			}
			else if rest {
				throw new Error(`Parameter must be before the rest parameter at line \(parameter.start.line)`)
			}
			else {
				fragments.code(parameter.name.name, parameter.name)
			}
			
			if parameter.type {
				if parameter.type.nullable && !parameter.defaultValue {
					fragments.code(' = null')
				}
			}
			
			if parameter.defaultValue {
				fragments.code(' = ').compile(node._parameters[i]._defaultValue)
			}
		}
		
		fn(fragments)
	} // }}}
	parametersKS(node, fragments, fn) { // {{{
		let data = node._data
		let signature = $function.signature(data, node.scope())
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
					fragments.code(names[i] = node.scope().acquireTempName())
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
					fragments.code(names[rest] = node.scope().acquireTempName())
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
	signature(data, scope) { // {{{
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
			signature.parameters.push(parameter = $function.signatureParameter(parameter, scope))
			
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
	signatureParameter(parameter, scope) { // {{{
		let signature = {
			type: $signature.type(parameter.type, scope),
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
	analyseType(type, node) { // {{{
		if type is Array {
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
					
					fragments.code('return ' + node._extendsName + '.' + name + '.apply(null, arguments)')
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
		
		$helper.methods(extend, node, fragments.newControl(), 'static ' + name + '()', reflect.classMethods[name], $continuous.methodCall^^(node, '__ks_sttc_' + name + '_', 'arguments', 'return '), 'arguments', 'classMethods.' + name, true)
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
		
		$helper.methods(extend, node, fragments.newControl(), '__ks_cons(args)', reflect.constructors, $continuous.methodCall^^(node, 'prototype.__ks_cons_', 'args', ''), 'args', 'constructors', false)
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
		
		$helper.methods(extend, node, fragments.newControl(), name + '()', reflect.instanceMethods[name], $continuous.methodCall^^(node, 'prototype.__ks_func_' + name + '_', 'arguments', 'return '), 'arguments', 'instanceMethods.' + name, true)
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
					throw new Error('Not Implemented')
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
		
		if reflect.final {
			object.line('final: true')
		}
		
		object.newLine().code('inits: ' + reflect.inits)
		
		a = object.newLine().code('constructors: ').newArray()
		for i from 0 til reflect.constructors.length {
			$helper.reflectMethod(node, a.newLine(), reflect.constructors[i].signature, reflect.constructors[i].parameters, classname + '.__ks_reflect.constructors[' + i + '].type')
		}
		a.done()
		
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
				throw new Error(`Invalid type \(type.type)`)
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
					
					variable = $variable.merge(node.scope().getVariable(reference.alias.name), variable)
				}
			}
		}
		
		node.scope().addVariable(name, variable)
		
		module.import(name, file)
	} // }}}
	define(module, file?, node, name, kind, type?) { // {{{
		$variable.define(node.scope(), name, kind, type)
		
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
								$import.use(reference.alias, node.scope())
								
								nf = false
							}
						}
						else {
							if reference.alias.name == name {
								$import.use(reference.alias, node.scope())
								
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
			
			variable = $variable.define(node.scope(), {
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
	use(data, scope) { // {{{
		if data is Array {
			for item in data {
				throw new Error(`Undefined variable '\(item.name)' at line \(item.start.line)`) if item.kind == Kind::Identifier && !scope.hasVariable(item.name)
			}
		}
		else if data.kind == Kind::Identifier {
			throw new Error(`Undefined variable '\(data.name)' at line \(data.start.line)`) if !scope.hasVariable(data.name)
		}
	} // }}}
	toKSFileFragments(node, fragments, data, metadata) { // {{{
		let {moduleName, exports, requirements, importVariables, importVarCount, importAll, importAlias} = metadata
		
		let name, alias, variable, importCode
		
		if (importVarCount && importAll) || (importVarCount && importAlias.length) || (importAll && importAlias.length) {
			importCode = node.scope().acquireTempName()
			
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
		
		node.scope().releaseTempName(importCode)
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

func $return(data?) { // {{{
	return {
		kind: Kind::ReturnStatement
		value: data
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
	type(type?, scope) { // {{{
		if type {
			if type.typeName {
				return $types[type.typeName.name] if $types[type.typeName.name]
				
				if (variable ?= scope.getVariable(type.typeName.name)) && variable.kind == VariableKind::TypeAlias {
					return $signature.type(variable.type, scope)
				}
				
				return type.typeName.name
			}
			else if type.types {
				let types = []
				
				for i from 0 til type.types.length {
					types.push($signature.type(type.types[i], scope))
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
			type = $type.unalias(type, node.scope())
			
			if type.typeParameters {
				if $generics[type.typeName.name] || !$types[type.typeName.name] || $generics[$types[type.typeName.name]] {
					let tof = $runtime.typeof(type.typeName.name, node) || $runtime.typeof($types[type.typeName.name], node)
					
					if tof {
						fragments
							.code(tof + '(')
							.compile(name)
						
						for typeParameter in type.typeParameters {
							fragments.code($comma)
							
							$type.compile(typeParameter, fragments)
						}
						
						fragments.code(')')
					}
					else {
						fragments
							.code($runtime.type(node), '.is(')
							.compile(name)
							.code(', ')
							.expression(type.typeName.name)
						
						for typeParameter in type.typeParameters {
							fragments.code($comma)
							
							$type.compile(typeParameter, fragments)
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
						.code(tof + '(')
						.compile(name)
						.code(')')
				}
				else {
					fragments
						.code($runtime.type(node), '.is(')
						.compile(name)
						.code(', ')
					
					$type.compile(type, fragments)
					
					fragments.code(')')
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
	compile(data, fragments) { // {{{
		switch(data.kind) {
			Kind::TypeReference => fragments.code($types[data.typeName.name] ?? data.typeName.name)
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
	type(data, scope) { // {{{
		//console.log('type.data', data)
		return data if !data.kind
		
		let type = null
		
		switch data.kind {
			Kind::BinaryOperator => {
				if data.operator.kind == BinaryOperator::TypeCast {
					return $type.type(data.right, scope)
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
					return $type.type(data.left, scope)
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
				let variable = scope.getVariable(data.name)
				
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
						prop.signature = $function.signature(property.value, scope)
						
						if property.value.type {
							prop.type = $type.type(property.value.type, scope)
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
								prop.signature = $function.signature(property.type, scope)
								
								if property.type.type {
									prop.type = $type.type(property.type.type, scope)
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
							type.typeParameters = [$type.type(parameter, scope) for parameter in data.typeParameters]
						}
					}
				}
			}
			Kind::UnionType => {
				return {
					types: [$type.type(type, scope) for type in data.types]
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
	unalias(type, scope) { // {{{
		let variable = scope.getVariable(type.typeName.name)
		
		if variable && variable.kind == VariableKind::TypeAlias {
			return $type.unalias(variable.type, scope)
		}
		
		return type
	} // }}}
}

const $variable = {
	define(scope, name, kind, type?) { // {{{
		let variable = scope.getVariable(name.name || name)
		if variable && variable.kind == kind {
			variable.new = false
		}
		else {
			scope.addVariable(name.name || name, variable = {
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
				variable.type = $type.type(type, scope)
			}
			else if (kind == VariableKind::Function || kind == VariableKind::Variable) && type {
				variable.type = type if type ?= $type.type(type, scope)
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
		//console.log('variable.filterMember.var', variable)
		//console.log('variable.filterMember.name', name)
		
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
				return node.scope().getVariable(data.name)
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
								return node.scope().getVariable('Function')
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
				let a = $type.type(data.then, node.scope())
				let b = $type.type(data.else, node.scope())
				
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
				if data.typeName {
					return node.scope().getVariable($types[data.typeName.name] || data.typeName.name)
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
				let variable = node.scope().getVariable(name)
				
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
	fromReflectType(type, node) { // {{{
		if type == 'Any' {
			return null
		}
		else if type is string {
			return node.scope().getVariable(type)
		}
		else {
			console.error(type)
			throw new Error('Not implemented')
		}
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

class AbstractNode {
	private {
		_data
		_options
		_parent = null
		_reference
		_scope = null
	}
	AbstractNode(@data, @parent, @scope = parent.scope()) { // {{{
		this._options = $applyAttributes(data, parent._options)
	} // }}}
	greatParent() => this._parent?._parent
	greatScope() => this._parent?._scope
	module() => this._parent.module()
	newScope() { // {{{
		if this._options.variables == 'es6' {
			return new Scope(this._scope)
		}
		else {
			return new XScope(this._scope)
		}
	} // }}}
	parent() => this._parent
	reference() { // {{{
		if this._parent? && this._parent.reference()? {
			return this._parent.reference() + this._reference
		}
		else {
			return this._reference
		}
	} // }}}
	reference(@reference) { // {{{
	} // }}}
	scope() => this._scope
	statement() => this._parent?.statement()
}

class AbstractScope {
	private {
		_body: Array		= []
		_parent
		_prepared			= false
		_renamedIndexes 	= {}
		_renamedVariables	= {}
		_variables			= {}
	}
	AbstractScope(@parent = null)
	addVariable(name, definition) { // {{{
		this._variables[name] = definition
		
		return this
	} // }}}
	getVariable(name) { // {{{
		if this._variables[name] {
			return this._variables[name]
		}
		else if this._parent {
			return this._parent.getVariable(name)
		}
		else {
			return null
		}
	} // }}}
	hasVariable(name) { // {{{
		return this._variables[name]? || (this._parent? && this._parent.hasVariable(name))
	} // }}}
	parent() => this._parent
	rename(name) { // {{{
		let newName = this.newRenamedVariable(name)
		if newName != name {
			this._renamedVariables[name] = newName
		}
	
		return this
	} // }}}
}

class Scope extends AbstractScope {
	private {
		_tempNextIndex 		= 0
		_tempNames			= {}
		_tempNameCount		= 0
		_tempParentNames	= {}
	}
	Scope(parent) { // {{{
		super(parent)
		
		this._tempNextIndex = parent._tempNextIndex
	} // }}}
	acquireTempName(statement: Statement?, assignment = false) { // {{{
		if this._parent && (name ?= this._parent.acquireTempNameFromKid()) {
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
			
			statement._variables.pushUniq(name) if statement?
			
			return name
		}
	} // }}}
	private acquireTempNameFromKid() { // {{{
		if this._parent && (name ?= this._parent.acquireTempNameFromKid()) {
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
	releaseTempName(name) { // {{{
		if name.length > 5 && name.substr(0, 5) == '__ks_' {
			if this._parent && this._tempParentNames[name] {
				this._parent.releaseTempNameFromKid(name)
				
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
		if this._parent && this._tempParentNames[name] {
			this._parent.releaseTempNameFromKid(name)
			
			this._tempParentNames[name] = false
		}
		else {
			++this._tempNameCount
				
			this._tempNames[name.substr(5)] = name
		}
	} // }}}
	updateTempNames() { // {{{
		if this._parent && this._parent._tempNextIndex > this._tempNextIndex {
			this._tempNextIndex = this._parent._tempNextIndex
		}
	} // }}}
}

class XScope extends AbstractScope {
	acquireTempName(statement: Statement?, assignment = false) { // {{{
		return this._parent.acquireTempName(statement, assignment)
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
	releaseTempName(name) { // {{{
		this._parent.releaseTempName(name)
		
		return this
	} // }}}
	updateTempNames() { // {{{
	} // }}}
}

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
		_references				= {}
		_register				= false
		_requirements			= {}
		_rewire
	}
	Module(@data, @compiler, @directory) { // {{{
		this._options = $applyAttributes(data, this._compiler._options.config)
		
		for attr in data.attributes {
			if attr.declaration.kind == Kind::Identifier &&	attr.declaration.name == 'bin' {
				this._binary = true
			}
			else if attr.declaration.kind == Kind::AttributeExpression && attr.declaration.name.name == 'cfg' {
				for arg in attr.declaration.arguments {
					if arg.kind == Kind::AttributeOperator {
						this._options[arg.name.name] = arg.value.value
					}
				}
			}
		}
		
		this._body = new ModuleBlock(data, this)
		
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
	analyse() { // {{{
		this._body.analyse()
	} // }}}
	directory() => this._directory
	export(name, alias = false) { // {{{
		throw new Error('Binary file can\'t export') if this._binary
		
		let variable = this._body.scope().getVariable(name.name)
		
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
	fuse() { // {{{
		this._body.fuse()
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
			parameter: this._body.scope().acquireTempName()
			requireFirst: requireFirst
		}
		
		this._requirements[requirement.parameter] = requirement
		
		this._dynamicRequirements.push(requirement)
	} // }}}
	toFragments() { // {{{
		if this._binary {
			let builder = new FragmentBuilder(0)
			
			this._body.toFragments(builder)
			
			return builder.toArray()
		}
		else {
			let builder = new FragmentBuilder(1)
			
			this._body.toFragments(builder)
			
			let fragments: Array = []
			
			if this._options.header {
				fragments.push($code(`// Generated by kaoscript \(metadata.version)\n`))
			}
			
			if this._register && this._options.register {
				fragments.push($code('require("kaoscript/register");\n'))
			}
			
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
			
			if this._dynamicRequirements.length {
				fragments.push($code('function __ks_require('))
				
				for requirement, i in this._dynamicRequirements {
					if i {
						fragments.push($comma)
					}
					
					fragments.push($code(requirement.parameter))
					
					if requirement.class {
						fragments.push($code(', __ks_' + requirement.parameter))
					}
				}
				
				fragments.push($code(') {\n'))
				
				if this._dynamicRequirements.length == 1 {
					requirement = this._dynamicRequirements[0]
					
					if requirement.requireFirst {
						fragments.push($code('\tif(Type.isValue(' + requirement.parameter + ')) {\n'))
						
						if requirement.class {
							fragments.push($code('\t\treturn [' + requirement.parameter + ', __ks_' + requirement.parameter + '];\n'))
							fragments.push($code('\t}\n'))
							fragments.push($code('\telse {\n'))
							fragments.push($code('\t\treturn [' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + '];\n'))
							fragments.push($code('\t}\n'))
						}
						else {
							fragments.push($code('\t\treturn [' + requirement.parameter + '];\n'))
							fragments.push($code('\t}\n'))
							fragments.push($code('\telse {\n'))
							fragments.push($code('\t\treturn [' + requirement.name + '];\n'))
							fragments.push($code('\t}\n'))
						}
					}
					else {
						fragments.push($code('\tif(Type.isValue(' + requirement.name + ')) {\n'))
						
						if requirement.class {
							fragments.push($code('\t\treturn [' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + '];\n'))
							fragments.push($code('\t}\n'))
							fragments.push($code('\telse {\n'))
							fragments.push($code('\t\treturn [' + requirement.parameter + ', __ks_' + requirement.parameter + '];\n'))
							fragments.push($code('\t}\n'))
						}
						else {
							fragments.push($code('\t\treturn [' + requirement.name + '];\n'))
							fragments.push($code('\t}\n'))
							fragments.push($code('\telse {\n'))
							fragments.push($code('\t\treturn [' + requirement.parameter + '];\n'))
							fragments.push($code('\t}\n'))
						}
					}
				}
				else {
					fragments.push($code('\tvar req = [];\n'))
					
					for requirement in this._dynamicRequirements {
						if requirement.requireFirst {
							fragments.push($code('\tif(Type.isValue(' + requirement.parameter + ')) {\n'))
							
							if requirement.class {
								fragments.push($code('\t\treq.push(' + requirement.parameter + ', __ks_' + requirement.parameter + ');\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treq.push(' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + ');\n'))
								fragments.push($code('\t}\n'))
							}
							else {
								fragments.push($code('\t\treq.push(' + requirement.parameter + ');\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treq.push(' + requirement.name + ');\n'))
								fragments.push($code('\t}\n'))
							}
						}
						else {
							fragments.push($code('\tif(Type.isValue(' + requirement.name + ')) {\n'))
							
							if requirement.class {
								fragments.push($code('\t\treq.push(' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + ');\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treq.push(' + requirement.parameter + ', __ks_' + requirement.parameter + ');\n'))
								fragments.push($code('\t}\n'))
							}
							else {
								fragments.push($code('\t\treq.push(' + requirement.name + ');\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treq.push(' + requirement.parameter + ');\n'))
								fragments.push($code('\t}\n'))
							}
						}
					}
					
					fragments.push($code('\treturn req;\n'))
				}
				
				fragments.push($code('}\n'))
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
			
			if this._dynamicRequirements.length {
				fragments.push($code('\tvar ['))
				
				for requirement, i in this._dynamicRequirements {
					if i {
						fragments.push($comma)
					}
					
					fragments.push($code(requirement.name))
					
					if requirement.class {
						fragments.push($code(', __ks_' + requirement.name))
					}
				}
				
				fragments.push($code('] = __ks_require('))
				
				for requirement, i in this._dynamicRequirements {
					if i {
						fragments.push($comma)
					}
					
					fragments.push($code(requirement.parameter))
					
					if requirement.class {
						fragments.push($code(', __ks_' + requirement.parameter))
					}
				}
				
				fragments.push($code(');\n'))
			}
			
			fragments.append(builder.toArray())
			
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
			
			fragments.push($code('}\n'))
			
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

class ModuleBlock extends AbstractNode {
	private {
		_body: Array		= []
		_module
	}
	ModuleBlock(data, @module) {
		this._data = data
		this._options = $applyAttributes(data, module._options)
		this._scope = new Scope()
	}
	analyse() { // {{{
		for statement in this._data.body {
			this._body.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
		}
	} // }}}
	fuse() { // {{{
		for statement in this._body {
			statement.fuse()
		}
	} // }}}
	module() => this._module
	toFragments(fragments) { // {{{
		for statement in this._body {
			statement.toFragments(fragments, Mode::None)
		}
	} // }}}
}

// {{{ Statements
class Statement extends AbstractNode {
	private {
		_afterwards	: Array	= []
		_variables	: Array	= []
	}
	afterward(node) { // {{{
		this._afterwards.push(node)
	} // }}}
	assignment(data, allowAssignement = false) { // {{{
		if data.left.kind == Kind::Identifier && !this._scope.hasVariable(data.left.name) {
			this._variables.push(data.left.name)
			
			$variable.define(this._scope, data.left, $variable.kind(data.right.type), data.right.type)
		}
	} // }}}
	compile(statements) { // {{{
		for statement in statements {
			statement.analyse()
		}
		
		for statement in statements {
			statement.fuse()
		}
	} // }}}
	isAsync() => false
	statement() => this
	toFragments(fragments, mode) { // {{{
		if this._variables.length {
			fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
		}
		
		if r ?= this.toStatementFragments(fragments, mode) {
			r.afterwards = this._afterwards
			
			return r
		}
		else {
			for afterward in this._afterwards {
				afterward.toAfterwardFragments(fragments)
			}
		}
	} // }}}
}

class ClassDeclaration extends Statement {
	private {
		_classMethods		= {}
		_classVariables		= {}
		_continuous 		= true
		_constructors		= []
		_constructorScope
		_extends
		_extendsName
		_extendsVariable
		_instanceMethods	= {}
		_instanceVariables	= {}
		_instanceVariableScope
		_name
		_variable
	}
	ClassDeclaration(data, parent) { // {{{
		super(data, parent)
		
		this._constructorScope = new Scope(parent.scope())
		this._instanceVariableScope = new Scope(parent.scope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		let scope = this._scope
		
		this._name = data.name.name
		this._variable = $variable.define(scope, data.name, VariableKind::Class, data.type)
		
		let classname = data.name
		
		let thisVariable = $variable.define(this._constructorScope, {
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
		
		$variable.define(this._instanceVariableScope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(classname.name))
		
		if this._extends = data.extends? {
			if !(this._extendsVariable ?= this._scope.getVariable(data.extends.name)) {
				throw new Error(`Undefined class \(data.extends.name) at line \(data.extends.start.line)`)
			}
			
			this._extendsName = data.extends.name
			
			let extname = data.extends
			
			let superVariable = $variable.define(this._constructorScope, {
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
			
			$variable.define(this._instanceVariableScope, {
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
					if member.name.name == this._variable.name.name {
						this._scope = this._constructorScope
						
						method = $compile.statement(member, this)
						
						method.isConstructor(true)
						
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
	fuse() { // {{{
		for name, variable of this._instanceVariables when variable.defaultValue? {
			variable.defaultValue.analyse()
		}
		
		for name, variable of this._classVariables when variable.defaultValue? {
			variable.defaultValue.analyse()
		}
		
		for method in this._constructors {
			method.statement.analyse()
		}
		
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
		
		$variable.define(scope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(data.name.name))
		
		if this._extends {
			let variable = $variable.define(scope, {
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
		if this._continuous {
			$continuous.class(this, fragments)
		}
		else {
			$final.class(this, fragments)
			
			fragments.line('var ' + this._variable.final.name + ' = {}')
		}
	} // }}}
}

class DoUntilStatement extends Statement {
	private {
		_body
		_condition
	}
	DoUntilStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._body = $compile.expression(this._data.body, this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('do')
			.step()
			.compile(this._body)
			.step()
			.code('while(!(')
			.compileBoolean(this._condition)
			.code('))')
			.done()
	} // }}}
}

class DoWhileStatement extends Statement {
	private {
		_body
		_condition
	}
	DoWhileStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._body = $compile.expression(this._data.body, this)
		this._condition = $compile.expression(this._data.condition, this)
	} // }}}
	fuse() { // {{{
		this._body.fuse()
		this._condition.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('do')
			.step()
			.compile(this._body)
			.step()
			.code('while(')
			.compileBoolean(this._condition)
			.code(')')
			.done()
	} // }}}
}

class EnumDeclaration extends Statement {
	private {
		_members = []
		_new
		_variable
	}
	EnumDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._variable = $variable.define(this._scope, this._data.name, VariableKind::Enum, this._data.type)
		
		this._new = this._variable.new
		
		for member in this._data.members {
			this._members.push(new EnumMember(member, this))
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._new {
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

class EnumMember extends AbstractNode {
	EnumMember(data, parent) { // {{{
		super(data, parent)
	} // }}}
	toFragments(fragments) { // {{{
		let variable = this._parent._variable
		
		if this._parent._new {
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
	}
	ExportDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		let statement
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					this._declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name)
				}
				Kind::ExportAlias => {
					module.export(declaration.name, declaration.alias)
				}
				Kind::EnumDeclaration => {
					this._declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name)
				}
				Kind::Identifier => {
					module.export(declaration)
				}
				Kind::TypeAliasDeclaration => {
					$variable.define(this._scope, declaration.name, VariableKind::TypeAlias, declaration.type)
					
					module.export(declaration.name)
				}
				Kind::VariableDeclaration => {
					this._declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
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
	fuse() { // {{{
		for declaration in this._declarations {
			declaration.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for declaration in this._declarations {
			declaration.toFragments(fragments, Mode::None)
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
	} // }}}
	analyse() { // {{{
		this._expression = $compile.expression(this._data, this)
	} // }}}
	assignment(data, expression) { // {{{
		if data.left.kind == Kind::Identifier && !this._scope.hasVariable(data.left.name) {
			if !expression.isAssignable() || this._variable.length {
				this._variables.push(data.left.name)
			}
			else {
				this._variable = data.left.name
			}
			
			$variable.define(this._scope, data.left, $variable.kind(data.right.type), data.right.type)
		}
	} // }}}
	fuse() { // {{{
		this._expression.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._expression.isAssignable() {
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if this._variable.length {
				line.code($variable.scope(this))
			}
			
			if this._expression.toAssignmentFragments? {
				this._expression.toAssignmentFragments(line)
			}
			else {
				this._expression.toFragments(line, Mode::None)
			}
			
			line.done()
		}
		else if this._expression.toStatementFragments? {
			if this._variable.length {
				this._variables.unshift(this._variable)
			}
			
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			this._expression.toStatementFragments(fragments, Mode::None)
		}
		else {
			if this._variables.length {
				fragments.newLine().code($variable.scope(this) + this._variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if this._variable.length {
				line.code($variable.scope(this))
			}
			
			line.compile(this._expression, Mode::None).done()
		}
		
		for afterward in this._afterwards {
			afterward.toAfterwardFragments(fragments)
		}
	} // }}}
}

class ExternDeclaration extends Statement {
	private {
		_lines = []
	}
	ExternDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
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
					$variable.define(this.greatScope(), declaration.name, $variable.kind(declaration.type), declaration.type)
				}
				=> {
					console.error(declaration)
					throw new Error('Unknow kind ' + declaration.kind)
				}
			}
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for line in this._lines {
			fragments.line(line)
		}
	} // }}}
}

class ExternOrRequireDeclaration extends Statement {
	ExternOrRequireDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
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
					variable = $variable.define(this.greatScope(), declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
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
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
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
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		if !this._scope.hasVariable(data.variable.name) {
			$variable.define(this._scope, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		this._from = $compile.expression(data.from, this)
		
		if data.til {
			this._til = $compile.expression(data.til, this)
			
			this._boundName = this._scope.acquireTempName() if this._til.isComposite()
		}
		else {
			this._to = $compile.expression(data.to, this)
			
			this._boundName = this._scope.acquireTempName() if this._to.isComposite()
		}
		
		if data.by {
			this._by = $compile.expression(data.by, this)
			
			this._byName = this._scope.acquireTempName() if this._by.isComposite()
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
		
		this._body = $compile.expression($block(data.body), this)
		
		this._scope.releaseTempName(this._boundName) if ?this._boundName
		this._scope.releaseTempName(this._byName) if ?this._byName
	} // }}}
	fuse() { // {{{
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		
		let ctrl = fragments.newControl().code('for(')
		
		if data.declaration || !this.greatScope().hasVariable(data.variable.name) {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code($equals).compile(this._from)
		
		if this._boundName? {
			ctrl.code($comma, this._boundName, $equals).compile(this._til ?? this._to)
		}
		
		if this._byName? {
			ctrl.code($comma, this._byName, $equals).compile(this._by)
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
			
			ctrl.compile(this._boundName ?? this._til)
		}
		else {
			if desc {
				ctrl.code(' >= ')
			}
			else {
				ctrl.code(' <= ')
			}
			
			ctrl.compile(this._boundName ?? this._to)
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
				ctrl.compile(this._variable).code(' += ').compile(this._byName ?? this._by)
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
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._value = $compile.expression(data.value, this)
		
		if !this._scope.hasVariable(data.variable.name) {
			$variable.define(this._scope, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		
		if data.index {
			if data.index && (data.declaration || !this._scope.hasVariable(data.index.name)) {
				$variable.define(this._scope, data.index.name, $variable.kind(data.index.type), data.index.type)
			}
			
			this._index = $compile.expression(data.index, this)
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
		
		if this._value.isEntangled() {
			this._valueName = this.greatScope().acquireTempName()
			
			this._scope.updateTempNames()
		}
		
		if !?this._index && !(data.index && !data.declaration && this.greatScope().hasVariable(data.index.name)) {
			this._indexName = this._scope.acquireTempName()
		}
		
		if !data.desc {
			this._boundName = this._scope.acquireTempName()
		}
		
		this._body = $compile.expression($block(data.body), this)
		
		this.greatScope().releaseTempName(this._valueName) if this._valueName?
		this._scope.releaseTempName(this._indexName) if this._indexName?
		this._scope.releaseTempName(this._boundName) if this._boundName?
	} // }}}
	fuse() { // {{{
		this._value.fuse()
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		
		if this._valueName? {
			let line = fragments.newLine()
			
			if !this.greatScope().hasVariable(this._valueName) {
				line.code($variable.scope(this))
				
				$variable.define(this.greatScope(), this._valueName, VariableKind::Variable)
			}
			
			line.code(this._valueName, $equals).compile(this._value).done()
		}
		
		let ctrl
		
		if data.desc {
			if data.index && !data.declaration && this.greatScope().hasVariable(data.index.name) {
				fragments
					.newLine()
					.compile(this._index)
					.code($equals)
					.compile(this._valueName ?? this._value)
					.code('.length - 1')
					.done()
				
				ctrl = fragments
					.newControl()
					.code('for(')
			}
			else {
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
					.compile(this._indexName ?? this._index)
					.code($equals)
					.compile(this._valueName ?? this._value)
					.code('.length - 1')
			}
		}
		else {
			if data.index && !data.declaration && this.greatScope().hasVariable(data.index.name) {
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
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
					.compile(this._indexName ?? this._index)
					.code(' = 0, ')
			}
			
			ctrl
				.code(this._boundName, $equals)
				.compile(this._valueName ?? this._value)
				.code('.length')
		}
		
		if data.declaration || !this.greatScope().hasVariable(data.variable.name) {
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
				.compile(this._indexName ?? this._index)
				.code(' >= 0; --')
				.compile(this._indexName ?? this._index)
		}
		else {
			ctrl
				.compile(this._indexName ?? this._index)
				.code(' < ' + this._boundName + '; ++')
				.compile(this._indexName ?? this._index)
		}
		
		ctrl.code(')').step()
		
		ctrl
			.newLine()
			.compile(this._variable)
			.code($equals)
			.compile(this._valueName ?? this._value)
			.code('[')
			.compile(this._indexName ?? this._index)
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
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._value = $compile.expression(data.value, this)
		
		if !this._scope.hasVariable(data.variable.name) {
			$variable.define(this._scope, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		
		if data.index {
			if data.index && (data.declaration || !this._scope.hasVariable(data.index.name)) {
				$variable.define(this._scope, data.index.name, $variable.kind(data.index.type), data.index.type)
			}
			
			this._index = $compile.expression(data.index, this)
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
		
		if this._value.isEntangled() {
			this._valueName = this.greatScope().acquireTempName()
			
			this._scope.updateTempNames()
		}
		
		this._body = $compile.expression($block(data.body), this)
		
		this.greatScope().releaseTempName(this._valueName) if this._valueName?
	} // }}}
	fuse() { // {{{
		this._value.fuse()
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		
		if this._valueName? {
			let line = fragments.newLine()
			
			if !this.greatScope().hasVariable(this._valueName) {
				line.code($variable.scope(this))
				
				$variable.define(this.greatScope(), this._valueName, VariableKind::Variable)
			}
			
			line.code(this._valueName, $equals).compile(this._value).done()
		}
		
		let ctrl = fragments.newControl().code('for(')
		
		if data.declaration || !this.greatScope().hasVariable(data.variable.name) {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code(' in ').compile(this._valueName ?? this._value).code(')').step()
		
		if data.index {
			let line = ctrl.newLine()
			
			if data.declaration || !this.greatScope().hasVariable(data.variable.name) {
				line.code($variable.scope(this))
			}
			
			line.compile(this._index).code($equals).compile(this._valueName ?? this._value).code('[').compile(this._variable).code(']').done()
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
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		if !this._scope.hasVariable(data.variable.name) {
			$variable.define(this._scope, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
		}
		
		this._variable = $compile.expression(data.variable, this)
		this._from = $compile.expression(data.from, this)
		
		this._to = $compile.expression(data.to, this)
		this._boundName = this._scope.acquireTempName() if this._to.isComposite()
		
		if data.by {
			this._by = $compile.expression(data.by, this)
			
			this._byName = this._scope.acquireTempName() if this._by.isComposite()
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
		
		this._body = $compile.expression($block(data.body), this)
		
		this._scope.releaseTempName(this._boundName) if this._boundName?
		this._scope.releaseTempName(this._byName) if this._byName?
	} // }}}
	fuse() { // {{{
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		
		let ctrl = fragments.newControl().code('for(')
		if data.declaration || !this.greatScope().hasVariable(data.variable.name) {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code($equals).compile(this._from)
		
		if this._boundName? {
			ctrl.code(this._boundName, $equals).compile(this._to)
		}
		
		if this._byName? {
			ctrl.code($comma, this._byName, $equals).compile(this._by)
		}
		
		ctrl.code('; ')
		
		if data.until {
			ctrl.code('!(').compile(this._until).code(') && ')
		}
		else if data.while {
			ctrl.compile(this._while).code(' && ')
		}
		
		ctrl.compile(this._variable).code(' <= ').compile(this._boundName ?? this._to).code('; ')
		
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
				ctrl.compile(this._variable).code(' += ').compile(this._byName ?? this._by)
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
	} // }}}
}


class FunctionDeclaration extends Statement {
	private {
		_async		= false
		_parameters
		_statements
	}
	FunctionDeclaration(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		$variable.define(this._scope, {
			kind: Kind::Identifier,
			name: 'this'
		}, VariableKind::Variable)
		
		let data = this._data
		
		variable = $variable.define(this.greatScope(), data.name, VariableKind::Function, data.type)
		
		for modifier in data.modifiers {
			if modifier.kind == FunctionModifier::Async {
				variable.async = true
			}
		}
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $statements(data.body)]
	} // }}}
	fuse() { // {{{
		for parameter in this._parameters {
			parameter.analyse()
			parameter.fuse()
		}
		
		for statement in this._statements {
			statement.analyse()
			
			this._async = statement.isAsync() if !this._async
		}
		
		for statement in this._statements {
			statement.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('function ' + this._data.name.name + '(')
		
		$function.parameters(this, ctrl, func(node) {
			node.code(')').step()
		})
		
		if this._async {
			let stack = []
			
			let f = ctrl
			let m = Mode::None
			
			let item
			for statement in this._statements {
				if item ?= statement.toFragments(f, m) {
					f = item.fragments
					m = item.mode
					
					stack.push(item)
				}
			}
			
			for item in stack {
				item.done(item.fragments)
			}
		}
		else {
			for statement in this._statements {
				ctrl.compile(statement, Mode::None)
			}
		}
		
		ctrl.done()
	} // }}}
}

class Parameter extends AbstractNode {
	private {
		_defaultValue	= null
		_name			= null
	}
	Parameter(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let parent = this._parent
		
		if data.name? {
			let signature = $function.signatureParameter(data, this._scope)
			
			if signature.rest {
				$variable.define(this._scope, data.name, VariableKind::Variable, {
					kind: Kind::TypeReference
					typeName: {
						kind: Kind::Identifier
						name: 'Array'
					}
				})
			}
			else {
				$variable.define(this._scope, data.name, $variable.kind(data.type), data.type)
			}
			
			this._name = $compile.expression(data.name, parent)
		}
		
		if data.defaultValue? {
			this._defaultValue = $compile.expression(data.defaultValue, parent)
		}
	} // }}}
	fuse() {// {{{
		if this._defaultValue != null {
			this._defaultValue.fuse()
		}
	} // }}}
}

class IfStatement extends Statement {
	private {
		_items	= []
	}
	IfStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._items.push(new IfClause(data, this))
		
		for elseif in data.elseifs {
			this._items.push(new IfElseClause(elseif, this))
		}
		
		this._items.push(new ElseClause(data.else, this)) if data.else?
	} // }}}
	fuse() { // {{{
		for item in this._items {
			item.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		for item, index in this._items {
			ctrl.step() if index
			
			item.toFragments(ctrl, mode)
		}
		
		ctrl.done()
	} // }}}
}

class IfClause extends AbstractNode {
	private {
		_condition
		_body
	}
	IfClause(data, parent) { // {{{
		super(data, parent, parent.newScope())
		
		this.analyse()
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._body = $compile.expression($block(this._data.then), this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._body.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('if(')
		
		if this._condition.isAssignable() {
			fragments.code('(').compileBoolean(this._condition).code(')')
		}
		else {
			fragments.compileBoolean(this._condition)
		}
		
		fragments.code(')').step().compile(this._body, mode)
	} // }}}
}

class IfElseClause extends AbstractNode {
	private {
		_condition
		_body
	}
	IfElseClause(data, parent) { // {{{
		super(data, parent, parent.newScope())
		
		this.analyse()
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._body = $compile.expression($block(this._data.body), this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._body.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('else if(')
		
		if this._condition.isAssignable() {
			fragments.code('(').compileBoolean(this._condition).code(')')
		}
		else {
			fragments.compileBoolean(this._condition)
		}
		
		fragments.code(')').step().compile(this._body)
	} // }}}
}

class ElseClause extends AbstractNode {
	private {
		_condition
		_body
	}
	ElseClause(data, parent) { // {{{
		super(data, parent, parent.newScope())
		
		this.analyse()
	} // }}}
	analyse() { // {{{
		this._body = $compile.expression($block(this._data.body), this)
	} // }}}
	fuse() { // {{{
		this._body.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('else').step().compile(this._body)
	} // }}}
}

class ImplementDeclaration extends Statement {
	private {
		_members = []
	}
	ImplementDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._scope.getVariable(data.class.name)
		
		if variable.kind != VariableKind::Class {
			throw new Error('Invalid class for impl at line ' + data.start.line)
		}
		
		for member in data.members {
			switch member.kind {
				Kind::FieldDeclaration => {
					this._members.push(member = new ImplementFieldDeclaration(member, this, variable))
					
					member.analyse()
				}
				Kind::MethodAliasDeclaration => {
					this._members.push(member = new ImplementMethodAliasDeclaration(member, this, variable))
					
					member.analyse()
				}
				Kind::MethodDeclaration => {
					this._members.push(member = new ImplementMethodDeclaration(member, this, variable))
					
					member.analyse()
				}
				Kind::MethodLinkDeclaration => {
					this._members.push(member = new ImplementMethodLinkDeclaration(member, this, variable))
					
					member.analyse()
				}
				=> {
					console.error(member)
					throw new Error('Unknow kind ' + member.kind)
				}
			}
		}
	} // }}}
	fuse() { // {{{
		for member in this._members {
			member.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		for member in this._members {
			member.toFragments(fragments, Mode::None)
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
	analyse() { // {{{
		this._type = $helper.analyseType($signature.type(this._data.type, this._scope), this)
		
		if this._type.kind == HelperTypeKind::Unreferenced {
			throw new Error(`Invalid type \(this._type.type) at line \(this._data.start.line)`)
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.line($runtime.helper(this), '.newField(' + $quote(this._data.name.name) + ', ' + $helper.type(this._type, this) + ')')
	} // }}}
}

class ImplementMethodDeclaration extends Statement {
	private {
		_instance	= true
		_name
		_parameters
		_statements
		_variable
	}
	ImplementMethodDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
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
				let method = {
					kind: Kind::MethodDeclaration
					name: data.name.name
					signature: $method.signature(data, this)
				}
				
				method.type = $type.type(data.type, this._scope) if data.type
				
				if this._instance {
					if !(variable.instanceMethods[data.name.name] is Array) {
						variable.instanceMethods[data.name.name] = []
					}
					
					variable.instanceMethods[data.name.name].push(method)
				}
				else {
					if !(variable.classMethods[data.name.name] is Array) {
						variable.classMethods[data.name.name] = []
					}
					
					variable.classMethods[data.name.name].push(method)
				}
			}
			else if data.name.kind == Kind.TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
		}
		
		$variable.define(this._scope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(variable.name))
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $statements(data.body)]
	} // }}}
	fuse() { // {{{
		this.compile(this._parameters)
		
		this.compile(this._statements)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
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
				object.newLine().code('name: ').compile(this._name)
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
			
			let signature = $method.signature(data, this)
			$helper.reflectMethod(this, object.newLine().code('signature: '), signature, [$helper.analyseType(parameter.type, this) for parameter in signature.parameters])
			
			object.done()
			line.code(')').done()
		}
	} // }}}
}

class ImplementMethodAliasDeclaration extends Statement {
	private {
		_arguments
		_instance	= true
		_name
		_parameters
		_signature
		_variable
	}
	ImplementMethodAliasDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			if data.name.kind == Kind::TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
			
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == MemberModifier::Static {
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
				if this._instance {
					variable.instanceMethods[data.name.name] = variable.instanceMethods[data.alias.name]
				}
				else {
					variable.classMethods[data.name.name] = variable.classMethods[data.alias.name]
				}
			}
			
			this._signature = $method.signature(data, this)
			
			this._parameters = [$helper.analyseType(parameter.type, this) for parameter in this._signature.parameters]
			
			if data.arguments? {
				this._arguments = [$compile.expression(argument, this) for argument in data.arguments]
			}
		}
	} // }}}
	fuse() { // {{{
		if this._arguments? {
			for argument in this._arguments {
				argument.fuse()
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		let variable = this._variable
		
		let line = fragments
			.newLine()
			.code($runtime.helper(this), '.', this._instance ? 'newInstanceMethod' : 'newClassMethod', '(')
		
		let object = line.newObject()
		
		object.line('class: ', variable.name.name)
		
		if data.name.kind == Kind::TemplateExpression {
			object.newLine().code('name: ').compile(this._name).done()
		}
		else if data.name.kind == Kind::Identifier {
			object.line('name: ', $quote(data.name.name))
		}
		else {
			console.error(data.name)
			throw new Error('Not Implemented')
		}
		
		if variable.final {
			object.line('final: ', variable.final.name)
		}
		
		object.line('method: ', $quote(data.alias.name))
		
		if data.arguments? {
			let argsLine = object.newLine().code('arguments: ')
			let array = argsLine.newArray()
			
			for argument in this._arguments {
				array.newLine().compile(argument).done()
			}
			
			array.done()
			argsLine.done()
		}
		
		let signLine = object.newLine().code('signature: ')
		
		$helper.reflectMethod(this, signLine, this._signature, this._parameters)
		
		signLine.done()
		
		object.done()
		
		line.code(')').done()
	} // }}}
}

class ImplementMethodLinkDeclaration extends Statement {
	private {
		_arguments
		_functionName
		_instance	= true
		_name
		_parameters
		_signature
		_variable
	}
	ImplementMethodLinkDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			if data.name.kind == Kind::TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
			
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == MemberModifier::Static {
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
			
			this._functionName = $compile.expression(data.alias, this)
			
			this._signature = $method.signature(data, this)
			
			this._parameters = [$helper.analyseType(parameter.type, this) for parameter in this._signature.parameters]
			
			if data.arguments? {
				this._arguments = [$compile.expression(argument, this) for argument in data.arguments]
			}
		}
	} // }}}
	fuse() { // {{{
		if this._arguments? {
			for argument in this._arguments {
				argument.fuse()
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		let variable = this._variable
		
		let line = fragments
			.newLine()
			.code($runtime.helper(this), '.', this._instance ? 'newInstanceMethod' : 'newClassMethod', '(')
		
		let object = line.newObject()
		
		object.line('class: ', variable.name.name)
		
		if data.name.kind == Kind::TemplateExpression {
			object.newLine().code('name: ').compile(this._name).done()
		}
		else if data.name.kind == Kind::Identifier {
			object.line('name: ', $quote(data.name.name))
		}
		else {
			console.error(data.name)
			throw new Error('Not Implemented')
		}
		
		if variable.final {
			object.line('final: ', variable.final.name)
		}
		
		object.newLine().code('function: ').compile(this._functionName)
		
		if data.arguments? {
			let argsLine = object.newLine().code('arguments: ')
			let array = argsLine.newArray()
			
			for argument in this._arguments {
				array.newLine().compile(argument).done()
			}
			
			array.done()
			argsLine.done()
		}
		
		let signLine = object.newLine().code('signature: ')
		
		$helper.reflectMethod(this, signLine, this._signature, this._parameters)
		
		signLine.done()
		
		object.done()
		
		line.code(')').done()
	} // }}}
}

class ImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	ImportDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		for declarator in this._data.declarations {
			this._declarators.push(declarator = new ImportDeclarator(declarator, this))
			
			declarator.analyse()
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for declarator in this._declarators {
			declarator.toFragments(fragments, mode)
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
	} // }}}
	analyse() { // {{{
		let module = this.module()
		
		$import.resolve(this._data, module.directory(), module, this)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
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
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		this._parameters = [new Parameter(parameter, this) for parameter in this._data.parameters]
		
		if this._data.body? {
			this._statements = [$compile.statement(statement, this) for statement in $statements(this._data.body)]
		}
		else {
			this._statements = []
		}
	} // }}}
	fuse() { // {{{
		this.compile(this._parameters)
		this.compile(this._statements)
	} // }}}
	isConstructor(@isConstructor) => this
	name(@name) => this
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code(this._name + '(')
		
		$function.parameters(this, ctrl, func(node) {
			node.code(')').step()
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
	RequireDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		let type
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
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
						$extern.classMember(declaration.members[i], variable, this._parent)
					}
					
					module.require(declaration.name.name, VariableKind::Class)
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(this.greatScope(), declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
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
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrExternDeclaration extends Statement {
	RequireOrExternDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
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
					
					module.require(declaration.name.name, VariableKind::Class, true)
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(this.greatScope(), declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
					variable.requirement = declaration.name.name
					
					module.require(declaration.name.name, type, true)
				}
				=> {
					console.error(declaration)
					throw new Error('Unknow kind ' + declaration.kind)
				}
			}
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class ReturnStatement extends Statement {
	private {
		_value = null
	}
	ReturnStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		if this._data.value? {
			this._value = $compile.expression(this._data.value, this)
		}
	} // }}}
	fuse() { // {{{
		if this._value != null && this._value.fuse? {
			this._value.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if mode == Mode::Async {
			if this._value != null {
				fragments
					.newLine()
					.code('return __ks_cb(null, ')
					.compile(this._value)
					.code(')')
					.done()
			}
			else {
				fragments.line('return __ks_cb()')
			}
		}
		else {
			if this._value != null {
				fragments
					.newLine()
					.code('return ')
					.compile(this._value)
					.done()
			}
			else {
				fragments.line('return', this._data)
			}
		}
	} // }}}
}

class SwitchStatement extends Statement {
	private {
		_clauses	= []
		_name
		_value
	}
	SwitchStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let scope = this._scope
		
		if this._data.expression.kind == Kind::Identifier {
			this._name = this._data.expression.name
		}
		else {
			this._name = this._scope.acquireTempName()
			this._value = $compile.expression(this._data.expression, this)
		}
		
		let clause, condition, name, exp, value
		for data in this._data.clauses {
			clause = {
				hasTest: false
				bindings: []
				conditions: []
				scope: new Scope(this._scope)
			}
			
			this._scope = clause.scope
			
			for condition, conditionIdx in data.conditions {
				if condition.kind == Kind::SwitchConditionArray {
					condition = new SwitchConditionArray(condition, this)
				}
				else if condition.kind == Kind::SwitchConditionEnum {
					throw new Error('Not Implemented')
				}
				else if condition.kind == Kind::SwitchConditionObject {
					throw new Error('Not Implemented')
				}
				else if condition.kind == Kind::SwitchConditionRange {
					condition = new SwitchConditionRange(condition, this)
				}
				else if condition.kind == Kind::SwitchConditionType {
					condition = new SwitchConditionType(condition, this)
				}
				else {
					condition = new SwitchConditionValue(condition, this)
				}
				
				condition.analyse()
				
				clause.conditions.push(condition)
			}
			
			for binding in data.bindings {
				if binding.kind == Kind::ArrayBinding {
					binding = new SwitchBindingArray(binding, this)
					
					clause.hasTest = true
				}
				else if binding.kind == Kind::ObjectBinding {
					throw new Error('Not Implemented')
					
					clause.hasTest = true
				}
				else if binding.kind == Kind::SwitchTypeCast {
					binding = new SwitchBindingType(binding, this)
				}
				else {
					binding = new SwitchBindingValue(binding, this)
				}
				
				binding.analyse()
				
				clause.bindings.push(binding)
			}
			
			clause.filter = new SwitchFilter(data, this)
			clause.filter.analyse()
			
			clause.hasTest = true if data.filter?
			
			clause.body = $compile.expression($block(data.body), this)
			
			this._clauses.push(clause)
			
			this._scope = scope
		}
	} // }}}
	fuse() { // {{{
		for clause in this._clauses {
			for condition in clause.conditions {
				condition.fuse()
			}
			
			clause.filter.fuse()
			
			clause.body.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._value? {
			fragments
				.newLine()
				.code($variable.scope(this), this._name, ' = ')
				.compile(this._value)
				.done()
		}
		
		let condition
		for clause in this._clauses {
			for condition in clause.conditions {
				condition.toStatementFragments(fragments)
			}
			
			clause.filter.toStatementFragments(fragments)
		}
		
		let ctrl = fragments.newControl()
		let we = false
		
		let i, binding
		for clause, clauseIdx in this._clauses {
			if clause.conditions.length {
				if we {
					throw new Error('The default clause is before this clause')
				}
				
				if clauseIdx {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}
				
				for condition, i in clause.conditions {
					ctrl.code(' || ') if i
					
					condition.toBooleanFragments(ctrl, this._name)
				}
				
				clause.filter.toBooleanFragments(ctrl, true)
				
				ctrl.code(')').step()
				
				for binding in clause.bindings {
					binding.toFragments(ctrl)
				}
				
				clause.body.toFragments(ctrl, mode)
			}
			else if clause.hasTest {
				if clauseIdx {
					ctrl.step().code('else if(')
				}
				else {
					ctrl.code('if(')
				}
				
				clause.filter.toBooleanFragments(ctrl, false)
				
				ctrl.code(')').step()
				
				for binding in clause.bindings {
					binding.toFragments(ctrl)
				}
				
				clause.body.toFragments(ctrl, mode)
			}
			else {
				if clauseIdx {
					ctrl.step().code('else')
				}
				else {
					ctrl.code('if(true)')
				}
				
				we = true
				
				ctrl.step()
				
				for binding in clause.bindings {
					binding.toFragments(ctrl)
				}
				
				clause.body.toFragments(ctrl, mode)
			}
		}
		
		ctrl.done()
		
		this._scope.releaseTempName(this._name) if this._value?
	} // }}}
}

class SwitchBindingArray extends AbstractNode {
	private {
		_array
	}
	SwitchBindingArray(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._array = $compile.expression(this._data, this)
	} // }}}
	fuse() { // {{{
		this._array.fuse()
	} // }}}
	toFragments(fragments) { // {{{
		let line = fragments.newLine()
		
		this._array.toAssignmentFragments(line)
		
		line.code(' = ', this._parent._name).done()
	} // }}}
}

class SwitchBindingType extends AbstractNode {
	SwitchBindingType(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		$variable.define(this._scope, this._data.name, VariableKind::Variable)
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments) { // {{{
		fragments.line($variable.scope(this), this._data.name.name, ' = ', this._parent._name)
	} // }}}
}

class SwitchBindingValue extends AbstractNode {
	SwitchBindingValue(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		$variable.define(this._scope, this._data, VariableKind::Variable)
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments) { // {{{
		fragments.line($variable.scope(this), this._data.name, ' = ', this._parent._name)
	} // }}}
}

class SwitchConditionArray extends AbstractNode {
	private {
		_name
		_values = []
	}
	SwitchConditionArray(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let nv = true
		for i from 0 til this._data.values.length while nv {
			if this._data.values[i].kind != Kind::OmittedExpression {
				nv = false
			}
		}
		
		if !nv {
			this._name = this._scope.parent().acquireTempName()
			
			for value in this._data.values {
				if value.kind != Kind::OmittedExpression {
					if value.kind == Kind::SwitchConditionRange {
						value = new SwitchConditionRange(value, this)
					}
					else {
						value = new SwitchConditionValue(value, this)
					}
					
					value.analyse()
					
					this._values.push(value)
				}
			}
		}
	} // }}}
	fuse() { // {{{
		for value in this._values {
			value.fuse()
		}
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		this.module().flag('Type')
		
		fragments.code('(', $runtime.typeof('Array', this), '(', name, ')')
		
		let mm = $switch.length(this._data.values)
		if mm.min == mm.max {
			if mm.min != Infinity {
				fragments.code(' && ', name, '.length === ', mm.min)
			}
		}
		else {
			fragments.code(' && ', name, '.length >= ', mm.min)
			
			if mm.max != Infinity {
				fragments.code(' && ', name, '.length <= ', mm.max)
			}
		}
		
		if this._name? {
			fragments.code(' && ', this._name, '(', name, ')')
		}
		
		fragments.code(')')
		
		this._scope.parent().releaseTempName(this._name) if this._name?
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._values.length > 0 {
			let line = fragments.newLine()
			
			line.code($variable.scope(this), this._name, ' = ([')
			
			for value, i in this._data.values {
				line.code(', ') if i
				
				if value.kind == Kind::OmittedExpression {
					if value.spread {
						line.code('...')
					}
				}
				else {
					line.code('__ks_', i)
				}
			}
			
			line.code(']) => ')
			
			let index = 0
			for value, i in this._data.values {
				if value.kind != Kind::OmittedExpression {
					line.code(' && ') if index
					
					this._values[index].toBooleanFragments(line, '__ks_' + i)
					
					index++
				}
			}
			
			line.done()
		}
	} // }}}
}

class SwitchConditionRange extends AbstractNode {
	private {
		_from	= true
		_left
		_right
		_to		= true
	}
	SwitchConditionRange(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		if this._data.from? {
			this._left = $compile.expression(this._data.from, this)
		}
		else {
			this._left = $compile.expression(this._data.then, this)
			this._from = false
		}
		
		if this._data.to? {
			this._right = $compile.expression(this._data.to, this)
		}
		else {
			this._right = $compile.expression(this._data.til, this)
			this._to = false
		}
	} // }}}
	fuse() { // {{{
		this._left.fuse()
		this._right.fuse()
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		fragments
			.code(name, this._from ? ' >= ' : '>')
			.compile(this._left)
			.code(' && ')
			.code(name, this._to ? ' <= ' : '<')
			.compile(this._right)
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchConditionType extends AbstractNode {
	SwitchConditionType(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		$type.check(this, fragments, name, this._data.type)
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchConditionValue extends AbstractNode {
	private {
		_value
	}
	SwitchConditionValue(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._value = $compile.expression(this._data, this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toBooleanFragments(fragments, name) { // {{{
		fragments
			.code(name, ' === ')
			.compile(this._value)
	} // }}}
	toStatementFragments(fragments) { // {{{
	} // }}}
}

class SwitchFilter extends AbstractNode {
	private {
		_bindings = []
		_filter
		_name
	}
	SwitchFilter(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		if this._data.filter? {
			if this._data.bindings.length > 0 {
				this._name = this._scope.parent().acquireTempName()
				
				for binding in this._data.bindings {
					this._bindings.push($compile.expression(binding, this))
				}
			}
			
			this._filter = $compile.expression(this._data.filter, this)
		}
	} // }}}
	fuse() { // {{{
		this._filter.fuse() if this._filter?
	} // }}}
	toBooleanFragments(fragments, nf) { // {{{
		let mm
		for binding in this._data.bindings {
			if binding.kind == Kind::ArrayBinding {
				this.module().flag('Type')
				
				if nf {
					fragments.code(' && ')
				}
				else {
					nf = true
				}
				
				fragments.code($runtime.typeof('Array', this), '(', this._parent._name, ')')
				
				mm = $switch.length(binding.elements)
				if mm.min == mm.max {
					if mm.min != Infinity {
						fragments.code(' && ', this._parent._name, '.length === ', mm.min)
					}
				}
				else {
					fragments.code(' && ', this._parent._name, '.length >= ', mm.min)
					
					if mm.max != Infinity {
						fragments.code(' && ', this._parent._name, '.length <= ', mm.max)
					}
				}
			}
		}
		
		if this._name? {
			fragments.code(' && ') if nf
			
			fragments.code(this._name, '(', this._parent._name, ')')
			
			this._scope.parent().releaseTempName(this._name)
		}
		else if this._filter? {
			fragments.code(' && ') if nf
			
			fragments.compile(this._filter)
		}
	} // }}}
	toStatementFragments(fragments) { // {{{
		if this._name? {
			let line = fragments.newLine()
			
			line.code($variable.scope(this), this._name, ' = (')
		
			for binding, i in this._bindings {
				line.code(', ') if i
				
				line.compile(binding)
			}
			
			line.code(') => ').compile(this._filter)
			
			line.done()
		}
	} // }}}
}

class ThrowStatement extends Statement {
	private {
		_value = null
	}
	ThrowStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._value = $compile.expression(this._data.value, this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newLine()
			.code('throw ')
			.compile(this._value)
			.done()
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
	} // }}}
	analyse() { // {{{
		let data = this._data
		let scope = this._scope
		
		this._body = $compile.expression(data.body, this)
		if data.catchClauses? {
			for clause in data.catchClauses {
				if clause.binding? {
					$variable.define(this._scope = new Scope(scope), clause.binding, VariableKind::Variable)
				}
				
				this._catchClauses.push({
					body: $compile.expression(clause.body, this)
					type: $compile.expression(clause.type, this)
				})
			}
		}
		
		if data.catchClause? {
			if this._data.catchClause.binding? {
				$variable.define(this._scope = new Scope(scope), data.catchClause.binding, VariableKind::Variable)
			}
			
			this._catchClause = $compile.expression(data.catchClause.body, this)
		}
		
		this._scope = scope
		
		this._finalizer = $compile.expression(data.finalizer, this) if data.finalizer?
	} // }}}
	fuse() { // {{{
		this._body.fuse()
		
		for clause in this._catchClauses {
			clause.body.fuse()
		}
		
		this._catchClause.fuse() if this._catchClause?
		this._finalizer.fuse() if this._finalizer?
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let finalizer = null
		
		if this._finalizer? {
			finalizer = this._scope.acquireTempName()
			
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
			
			let error = this._scope.acquireTempName()
			
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
			
			this._scope.releaseTempName(error)
		}
		else if this._catchClause? {
			let error = this._scope.acquireTempName()
			
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
			
			this._scope.releaseTempName(error)
		}
		else {
			let error = this._scope.acquireTempName()
			
			ctrl.code('catch(', error, ')').step()
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			this._scope.releaseTempName(error)
		}
		
		ctrl.done()
	} // }}}
}

class TypeAliasDeclaration extends Statement {
	TypeAliasDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		$variable.define(this._scope, this._data.name, VariableKind::TypeAlias, this._data.type)
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class UnlessStatement extends Statement {
	private {
		_body
		_then
	}
	UnlessStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._then = $compile.expression(this._data.then, this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._then.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
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
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._body = $compile.expression(this._data.body, this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
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
		_async = false
		_declarators = []
		_init = false
	}
	VariableDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		for declarator in this._data.declarations {
			if declarator.kind == Kind::AwaitExpression {
				declarator = new AwaitDeclarator(declarator, this)
				
				this._async = true
			}
			else {
				declarator = new VariableDeclarator(declarator, this)
			}
			
			declarator.analyse()
			
			this._declarators.push(declarator)
		}
	} // }}}
	fuse() { // {{{
		for declarator in this._declarators {
			declarator.fuse()
		}
	} // }}}
	isAsync() => this._async
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
	toStatementFragments(fragments, mode) { // {{{
		if this._declarators.length == 1 {
			if this._async {
				return this._declarators[0].toFragments(fragments)
			}
			else {
				this._declarators[0].toFragments(fragments, this._data.modifiers)
			}
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

class AwaitDeclarator extends AbstractNode {
	private {
		_operation
		_variables = []
	}
	AwaitDeclarator(data, parent) { // {{{
		super(data, parent, new Scope(parent._scope))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._operation = $compile.expression(data.operation, this)
		
		for variable in data.variables {
			if variable.kind == Kind::VariableDeclarator {
				$variable.define(this._scope._parent, variable.name, $variable.kind(variable.type), variable.type)
				
				this._variables.push($compile.expression(variable.name, this))
			}
			else {
				$variable.define(this._scope._parent, variable, VariableKind::Variable)
				
				this._variables.push($compile.expression(variable, this))
			}
		}
	} // }}}
	fuse() { // {{{
		this._operation.fuse()
		
		for variable in this._variables {
			variable.fuse()
		}
	} // }}}
	statement() => this._parent.statement()
	toFragments(fragments) { // {{{
		let line = fragments.newLine()
		
		this._operation.toFragments(line, Mode::Async)
		
		line.code('(__ks_e')
		
		for variable in this._variables {
			line.code(', ').compile(variable)
		}
		
		line.code(') =>')
		
		let block = line.newBlock()
		
		block
			.newControl()
			.code('if(__ks_e)')
			.step()
			.line('return __ks_cb(__ks_e)')
			.done()
		
		return {
			fragments: block
			mode: Mode::Async
			done: func(block) {
				block.done()
				
				line.code(')').done()
			}
		}
	} // }}}
}

class VariableDeclarator extends AbstractNode {
	private {
		_init	= null
	}
	VariableDeclarator(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		if data.name.kind == Kind::Identifier && this._options.variables == 'es5' {
			this._scope.rename(data.name.name)
		}
		
		if data.autotype? {
			let type = data.type
			
			if !type && data.init {
				type = data.init
			}
			
			$variable.define(this._scope, data.name, $variable.kind(data.type), type)
		}
		else {
			$variable.define(this._scope, data.name, $variable.kind(data.type), data.type)
		}
		
		this._name = $compile.expression(data.name, this)
		
		if data.init? {
			if data.name.kind == Kind::Identifier {
				this.reference(data.name.name)
			}
			
			this._init = $compile.expression(data.init, this)
		}
	} // }}}
	fuse() { // {{{
		if this._init != null {
			this._init.fuse()
		}
	} // }}}
	statement() => this._parent.statement()
	toFragments(fragments, modifier) { // {{{
		let line = fragments.newLine().code(this._parent.modifier(this._data), $space)
		
		line.compile(this._name)
		
		if this._init != null {
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
	} // }}}
	analyse() { // {{{
		this._body = $compile.expression(this._data.body, this)
		this._condition = $compile.expression(this._data.condition, this)
	} // }}}
	fuse() { // {{{
		this._body.fuse()
		this._condition.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
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
class Expression extends AbstractNode {
	isAssignable() => false
	isCallable() => false
	isComposite() => true
	isComputed() => false
	isConditional() => this.isNullable()
	isEntangled() => true
	isNullable() => false
	toBooleanFragments(fragments) => this.toFragments(fragments, Mode::None)
	toNullableFragments(fragments) => this.toFragments(fragments, Mode::None)
	toReusableFragments(fragments) => this.toFragments(fragments, Mode::None)
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
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this.assignment(data)
		
		this._left = $compile.expression(data.left, this)
		this._right = $compile.expression(data.right, this)
	} // }}}
	assignment(data) { // {{{
		let expression = this
		while !(expression._parent is Statement) {
			expression = expression._parent
		}
		
		expression._parent.assignment(data, expression)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
		this._right.fuse()
	} // }}}
	toNullableFragments(fragments) { // {{{
		fragments.compileNullable(this._right)
	} // }}}
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' += ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseAnd extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' &= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseLeftShift extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' <<= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseOr extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' |= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseRightShift extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' >>= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseXor extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' ^= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code($equals).compile(this._right)
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		if this._left.toAssignmentFragments? {
			this._left.toAssignmentFragments(fragments)
			
			fragments.code($equals).compile(this._right)
		}
		else {
			fragments.compile(this._left).code($equals).compile(this._right)
		}
	} // }}}
	toBooleanFragments(fragments) { // {{{
		fragments.compile(this._left).code($equals).wrap(this._right)
	} // }}}
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	analyse() { // {{{
		super.analyse()
		
		this._right.analyseReusable()
	} // }}}
	isAssignable() => false
	toFragments(fragments, mode) { // {{{
		if this._right.isNullable() {
			fragments
				.wrapNullable(this._right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
				.code(')', this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
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
				.wrapNullable(this._right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
				.code(')', this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
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

class AssignmentOperatorModulo extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' %= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorMultiplication extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' *= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorNullCoalescing extends AssignmentOperatorExpression {
	isAssignable() => false
	toFragments(fragments, mode) { // {{{
		if this._left.isNullable() {
			fragments.code('(')
			
			this._left.toNullableFragments(fragments)
			
			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code(')')
		}
		
		fragments
			.code(' ? undefined : ')
			.compile(this._left)
			.code($equals)
			.compile(this._right)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('if(!')
		
		if this._left.isNullable() {
			ctrl.code('(')
			
			this._left.toNullableFragments(ctrl)
			
			ctrl
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code('))')
		}
		else {
			ctrl
				.code($runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code(')')
		}
		
		ctrl
			.code(')')
			.step()
			.newLine()
			.compile(this._left)
			.code($equals)
			.compile(this._right)
			.done()
		
		ctrl.done()
	} // }}}
}

class AssignmentOperatorSubtraction extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' -= ').compile(this._right)
	} // }}}
}
// }}}}

// {{{ Binary Operators
class BinaryOperatorExpression extends Expression {
	private {
		_left
		_right
		_tested = false
	}
	isComputed() => true
	isNullable() => this._left.isNullable() || this._right.isNullable()
	analyse() { // {{{
		this._left = $compile.expression(this._data.left, this)
		this._right = $compile.expression(this._data.right, this)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
		this._right.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		let test = this.isNullable() && !this._tested
		if test {
			fragments
				.compileNullable(this)
				.code(' ? ')
		}
		
		this.toOperatorFragments(fragments)
		
		if test {
			fragments.code(' : false')
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			if this._left.isNullable() {
				fragments.compileNullable(this._left)
				
				if this._right.isNullable() {
					fragments.code(' && ').compileNullable(this._right)
				}
			}
			else {
				fragments.compileNullable(this._right)
			}
			
			this._tested = true
		}
	} // }}}
}

class BinaryOperatorAddition extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('+', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorAnd extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrapBoolean(this._left)
			.code($space)
			.code('&&', this._data.operator)
			.code($space)
			.wrapBoolean(this._right)
	} // }}}
}

class BinaryOperatorBitwiseAnd extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('&', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseLeftShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('<<', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseOr extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('|', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseRightShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('>>', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseXor extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('^', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorDivision extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('/', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorEquality extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('===', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorGreaterThan extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('>', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorGreaterThanOrEqual extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('>=', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorInequality extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('!==', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorLessThan extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('<', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorLessThanOrEqual extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('<=', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorModulo extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('%', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorMultiplication extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('*', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorNullCoalescing extends BinaryOperatorExpression {
	analyse() { // {{{
		super.analyse()
		
		if this._data.left != Kind::Identifier {
			this._left.analyseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._left.isNullable() {
			fragments.code('(')
			
			this._left.toNullableFragments(fragments)
			
			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compileReusable(this._left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compileReusable(this._left)
				.code(')')
		}
		
		fragments
			.code(' ? ')
			.compile(this._left)
			.code(' : ')
			.compile(this._right)
	} // }}}}
}

class BinaryOperatorOr extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrapBoolean(this._left)
			.code($space)
			.code('||', this._data.operator)
			.code($space)
			.wrapBoolean(this._right)
	} // }}}
}

class BinaryOperatorSubtraction extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space, '-', this._data.operator, $space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorTypeCast extends Expression {
	private {
		_left
	}
	isComputed() => false
	isNullable() => this._left.isNullable()
	analyse() { // {{{
		this._left = $compile.expression(this._data.left, this)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left)
	} // }}}
}

class BinaryOperatorTypeCheck extends Expression {
	isComputed() => false
	isNullable() => false
	analyse() { // {{{
		this._left = $compile.expression(this._data.left, this)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		$type.check(this, fragments, this._left, this._data.right)
	} // }}}
}
// }}}

class ArrayBinding extends Expression {
	private {
		_elements			= []
		_existing			= {}
		_existingCount		= 0
		_nonexisting		= {}
		_nonexistingCount	= 0
		_variables			= {}
	}
	ArrayBinding(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		for element in this._data.elements {
			if element.kind == Kind::BindingElement && !element.name.computed {
				if this._scope.hasVariable(element.name.name) {
					this._existing[element.name.name] = true
					++this._existingCount
				}
				else {
					this._nonexisting[element.name.name] = true
					++this._nonexistingCount
				}
			}
			
			this._elements.push($compile.expression(element, this))
		}
	} // }}}
	fuse() { // {{{
		for element in this._elements {
			element.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._existingCount && this._nonexistingCount {
			fragments.code('[')
			
			let name
			for element, i in this._data.elements {
				fragments.code(', ') if i
				
				if element.kind == Kind::BindingElement && !element.name.computed && this._existing[element.name.name] {
					name = this._scope.acquireTempName()
					
					this._elements[i].toFragments(fragments, Kind::ArrayBinding, name)
					
					this._variables[name] = element.name.name
				}
				else {
					this._elements[i].toFragments(fragments)
				}
			}
			
			fragments.code(']')
			
			this.statement().afterward(this)
		}
		else {
			fragments.code('[')
			
			for i from 0 til this._elements.length {
				fragments.code(', ') if i
				
				this._elements[i].toFragments(fragments)
			}
			
			fragments.code(']')
		}
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		for name, variable of this._variables {
			fragments.line(variable, ' = ', name)
			
			this._scope.releaseTempName(name)
		}
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		if this._nonexistingCount {
			fragments.code('var ')
		}
		
		this.toFragments(fragments, Mode::None)
	} // }}}
}

class ArrayComprehensionForIn extends Expression {
	ArrayComprehensionForIn(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		$variable.define(this._scope, data.loop.variable.name, VariableKind::Variable)
		$variable.define(this._scope, data.loop.index.name, VariableKind::Variable) if data.loop.index?
		
		this._variable = $compile.expression(data.loop.variable, this)
		this._value = $compile.expression(data.loop.value, this)
		this._index = $compile.expression(data.loop.index, this) if data.loop.index?
		
		this._body = $compile.statement($return(data.body), this)
		this._body.analyse()
		
		if data.loop.when? {
			this._when = $compile.statement($return(data.loop.when), this)
			this._when.analyse()
		}
	} // }}}
	fuse() { // {{{
		this._variable.fuse()
		this._value.fuse()
		this._index.fuse() if this._index?
		this._body.fuse()
		this._when.fuse() if this._when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.mapArray(')
			.compile(this._value)
			.code(', ')
		
		fragments
			.code('(')
			.compile(this._variable)
		
		fragments.code($comma).compile(this._index) if this._index?
		
		fragments
			.code(') =>')
			.newBlock()
			.compile(this._body)
			.done()
		
		if this._when? {
			fragments
				.code($comma)
				.code('(')
				.compile(this._variable)
			
			fragments.code($comma).compile(this._index) if this._index?
			
			fragments
				.code(') =>')
				.newBlock()
				.compile(this._when)
				.done()
		}
		
		fragments.code(')')
	} // }}}
}

class ArrayComprehensionForOf extends Expression {
	ArrayComprehensionForOf(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		$variable.define(this._scope, data.loop.variable.name, VariableKind::Variable)
		$variable.define(this._scope, data.loop.index.name, VariableKind::Variable) if data.loop.index?
		
		this._variable = $compile.expression(data.loop.variable, this)
		this._value = $compile.expression(data.loop.value, this)
		this._index = $compile.expression(data.loop.index, this) if data.loop.index?
		
		this._body = $compile.statement($return(data.body), this)
		this._body.analyse()
		
		if data.loop.when? {
			this._when = $compile.statement($return(data.loop.when), this)
			this._when.analyse()
		}
	} // }}}
	fuse() { // {{{
		this._variable.fuse()
		this._value.fuse()
		this._index.fuse() if this._index?
		this._body.fuse()
		this._when.fuse() if this._when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.mapObject(')
			.compile(this._value)
			.code(', ')
		
		fragments
			.code('(')
			.compile(this._variable)
		
		fragments.code($comma).compile(this._index) if this._index?
		
		fragments
			.code(') =>')
			.newBlock()
			.compile(this._body)
			.done()
		
		if this._when? {
			fragments
				.code($comma)
				.code('(')
				.compile(this._variable)
			
			fragments.code($comma).compile(this._index) if this._index?
			
			fragments
				.code(') =>')
				.newBlock()
				.compile(this._when)
				.done()
		}
		
		fragments.code(')')
	} // }}}
}

class ArrayComprehensionForRange extends Expression {
	private {
		_body
		_by
		_from
		_to
		_variable
		_when
	}
	ArrayComprehensionForRange(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		$variable.define(this._scope, data.loop.variable.name, VariableKind::Variable)
		
		this._variable = $compile.expression(data.loop.variable, this)
		this._from = $compile.expression(data.loop.from, this)
		this._to = $compile.expression(data.loop.to, this)
		this._by = $compile.expression(data.loop.by, this) if data.loop.by?
		
		this._body = $compile.statement($return(data.body), this)
		this._body.analyse()
		
		if data.loop.when? {
			this._when = $compile.statement($return(data.loop.when), this)
			this._when.analyse()
		}
	} // }}}
	fuse() { // {{{
		this._variable.fuse()
		this._from.fuse()
		this._to.fuse()
		this._by.fuse() if this._by?
		this._body.fuse()
		this._when.fuse() if this._when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.mapRange(')
			.compile(this._from)
			.code($comma)
			.compile(this._to)
		
		if this._by? {
			fragments.code(', ').compile(this._by)
		}
		else {
			fragments.code(', 1')
		}
		
		fragments
			.code($comma)
			.code('(')
			.compile(this._variable)
			.code(') =>')
			.newBlock()
			.compile(this._body)
			.done()
		
		if this._when? {
			fragments
				.code($comma)
				.code('(')
				.compile(this._variable)
				.code(') =>')
				.newBlock()
				.compile(this._when)
				.done()
		}
		
		fragments.code(')')
	} // }}}
}

class ArrayExpression extends Expression {
	private {
		_values
	}
	ArrayExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._values = [$compile.expression(value, this) for value in this._data.values]
	} // }}}
	fuse() { // {{{
		for value in this._values {
			value.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._from = $compile.expression(data.from ?? data.then, this)
		this._to = $compile.expression(data.to ?? data.til, this)
		this._by = $compile.expression(data.by, this) if data.by?
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
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

class BindingElement extends Expression {
	private {
		_alias
		_defaultValue
		_name
	}
	BindingElement(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		$variable.define(this.statement().scope(), this._data.name, VariableKind::Variable)
		
		if this._data.alias? {
			$variable.define(this._scope, this._data.alias, VariableKind::Variable)
			
			this._alias = $compile.expression(this._data.alias, this)
		}
		
		this._name = $compile.expression(this._data.name, this)
		this._defaultValue = $compile.expression(this._data.defaultValue, this) if this._data.defaultValue?
	} // }}}
	fuse() { // {{{
		this._alias.fuse() if this._alias?
		this._name.fuse()
		this._defaultValue.fuse() if this._defaultValue?
	} // }}}
	toFragments(fragments) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
		
		if this._alias? {
			if this._data.alias.computed {
				fragments.code('[').compile(this._alias).code(']: ')
			}
			else {
				fragments.compile(this._alias).code(': ')
			}
		}
		
		fragments.compile(this._name)
		
		if this._defaultValue? {
			fragments.code(' = ').compile(this._defaultValue)
		}
	} // }}}
	toFragments(fragments, kind, name) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
		
		if this._alias? {
			if this._data.alias.computed {
				fragments.code('[').compile(this._alias).code(']: ')
			}
			else {
				fragments.compile(this._alias).code(': ')
			}
		}
		
		if kind == Kind::ArrayBinding {
			fragments.code(name)
		}
		else {
			fragments.compile(this._name).code(': ', name)
		}
		
		if this._defaultValue? {
			fragments.code(' = ').compile(this._defaultValue)
		}
	} // }}}
}

class BlockExpression extends Expression {
	private {
		_body = []
	}
	analyse() { // {{{
		if this._data.statements {
			for statement in this._data.statements {
				this._body.push(statement = $compile.statement(statement, this))
				
				statement.analyse()
			}
		}
	} // }}}
	fuse() { // {{{
		for statement in this._body {
			statement.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in this._body {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}

class CallExpression extends Expression {
	private {
		_arguments	= []
		_callee
		_caller
		_callScope
		_list		= true
		_reusable	= false
		_reuseName	= null
		_tested		= false
	}
	CallExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		if this._data.callee.kind == Kind::Identifier {
			if variable ?= this._scope.getVariable(this._data.callee.name) {
				if variable.callable? {
					variable.callable(this._data)
				}
			}
			else {
				throw new Error(`Undefined variable \(this._data.callee.name) at line \(this._data.callee.start.line)`)
			}
		}
		
		this._callee = $compile.expression(this._data.callee, this)
		
		for argument in this._data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				this._arguments.push($compile.expression(argument.argument, this))
				
				this._list = false
			}
			else {
				this._arguments.push($compile.expression(argument, this))
			}
		}
		
		if this._data.scope.kind == ScopeModifier::Argument {
			this._callScope = $compile.expression(this._data.scope.value, this)
		}
		
		if !this._list {
			if this._arguments.length != 1 {
				throw new Error(`Invalid to call function at line \(this._data.start.line)`)
			}
			
			this._caller = $caller(this._data.callee, this)
		}
		
		if this._data.nullable && (this._callee.isNullable() || this._callee.isCallable()) {
			this._callee.analyseReusable()
		}
	} // }}}
	analyseReusable() { // {{{
		this._reuseName ??= this._scope.acquireTempName(this.statement())
	} // }}}
	fuse() { // {{{
		this._callee.fuse()
		this._caller.fuse() if this._caller?
		this._callScope.fuse() if this._callScope?
		
		for argument in this._arguments {
			argument.fuse()
		}
	} // }}}
	isCallable() => !this._reusable
	isNullable() { // {{{
		return this._data.nullable || this._callee.isNullable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if mode == Mode::Async {
			this.toCallFragments(fragments, mode)
			
			fragments.code(', ') if this._arguments.length
		}
		else {
			if this._reusable {
				fragments.code(this._reuseName)
			}
			else if this.isNullable() && !this._tested {
				fragments.wrapNullable(this).code(' ? ')
				
				this._tested = true
				
				this.toFragments(fragments, mode)
				
				fragments.code(' : undefined')
			}
			else {
				this.toCallFragments(fragments, mode)
				
				fragments.code(')')
			}
		}
	} // }}}
	toCallFragments(fragments, mode) { // {{{
		let data = this._data
		
		if this._list {
			if data.scope.kind == ScopeModifier::This {
				fragments.compile(this._callee, mode).code('(')
				
				for argument, index in this._arguments {
					fragments.code($comma) if index
					
					fragments.compile(argument, mode)
				}
			}
			else if data.scope.kind == ScopeModifier::Null {
				fragments.compile(this._callee, mode).code('.call(null')
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument, mode)
				}
			}
			else {
				fragments.compile(this._callee, mode).code('.call(').compile(this._callScope, mode)
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument, mode)
				}
			}
		}
		else {
			fragments.compile(this._callee, mode).code('.apply(')
			
			if data.scope.kind == ScopeModifier::Null {
				fragments.code('null')
			}
			else if data.scope.kind == ScopeModifier::This {
				fragments.compile(this._caller, mode)
			}
			else {
				fragments.compile(this._callScope, mode)
			}
			
			fragments.code($comma).compile(this._arguments[0], mode)
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
			else if this._callee.isNullable() {
				fragments.compileNullable(this._callee)
			}
			else {
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(this)
					.code(')')
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		fragments
			.code(this._reuseName, $equals)
			.compile(this)
		
		this._reusable = true
	} // }}}
}

class CallFinalExpression extends Expression {
	private {
		_arguments	= []
		_callee
		_list		= true
		_object
		_tested		= false
	}
	CallFinalExpression(data, parent, @callee) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._object = $compile.expression(this._data.callee.object, this)
		
		for argument in this._data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				this._arguments.push($compile.expression(argument.argument, this))
				
				this._list = false
			}
			else {
				this._arguments.push($compile.expression(argument, this))
			}
		}
	} // }}}
	fuse() { // {{{
		this._object.fuse()
		
		for argument in this._arguments {
			argument.fuse()
		}
	} // }}}
	isComputed() => this._callee.variables? && this._callee.variables.length > 1
	isNullable() { // {{{
		return this._data.nullable || this._object.isNullable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._callee.variable? {
			let path = this._callee.variable.accessPath? ? this._callee.variable.accessPath + this._callee.variable.final.name : this._callee.variable.final.name
			
			if this._callee.instance {
				if this._list {
					fragments
						.code(path + '._im_' + this._data.callee.property.name + '(')
						.compile(this._object)
					
					for i from 0 til this._arguments.length {
						fragments.code(', ').compile(this._arguments[i])
					}
					
					fragments.code(')')
				}
				else {
					fragments
						.code(`\(path)._im_\(this._data.callee.property.name).apply(\(path), [`)
						.compile(this._object)
						.code('].concat(')
						.compile(this._arguments[0])
						.code('))')
				}
			}
			else {
				fragments.code((this._callee.variable.accessPath ?? ''), this._callee.variable.final.name + '._cm_' + this._data.callee.property.name + '(')
				
				for i from 0 til this._arguments.length {
					fragments.code($comma) if i
					
					fragments.compile(this._arguments[i])
				}
				
				fragments.code(')')
			}
		}
		else if this._callee.variables.length == 2 {
			let data = this._data
			let callee = this._callee
			
			this.module().flag('Type')
			
			let name = null
			if data.callee.object.kind == Kind::Identifier {
				if tof = $runtime.typeof(callee.variables[0].name, this) {
					fragments.code(tof, '(').compile(this._object).code(')')
				}
				else {
					fragments.code($runtime.type(this), '.is(').compile(this._object).code(', ', callee.variables[0].name, ')')
				}
			}
			else {
				name = this._scope.acquireTempName()
				
				if tof = $runtime.typeof(callee.variables[0].name, this) {
					fragments.code(tof, '(', name, ' = ').compile(this._object).code(')')
				}
				else {
					fragments.code($runtime.type(this), '.is(', name, ' = ').compile(this._object).code(', ', callee.variables[0].name, ')')
				}
			}
			
			fragments.code(' ? ')
			
			fragments.code((callee.variables[0].accessPath || ''), callee.variables[0].final.name + '._im_' + data.callee.property.name + '(')
			
			if name? {
				fragments.code(name)
			}
			else {
				fragments.compile(this._object)
			}
			
			for argument in this._arguments {
				fragments.code(', ').compile(argument)
			}
			
			fragments.code(') : ')
			
			fragments
				.code((callee.variables[1].accessPath || ''), callee.variables[1].final.name + '._im_' + data.callee.property.name + '(')
			
			if name? {
				fragments.code(name)
			}
			else {
				fragments.compile(this._object)
			}
			
			for argument in this._arguments {
				fragments.code(', ').compile(argument)
			}
			
			fragments.code(')')
			
			this._scope.releaseTempName(name) if name?
		}
		else {
			console.error(this._callee)
			throw new Error('Not Implemented')
		}
	} // }}}
}

class CurryExpression extends Expression {
	private {
		_arguments	= []
		_callee
		_caller
		_callScope
		_list		= true
		_tested		= false
	}
	CurryExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._callee = $compile.expression(this._data.callee, this)
		
		for argument in this._data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				this._arguments.push($compile.expression(argument.argument, this))
				
				this._list = false
			}
			else {
				this._arguments.push($compile.expression(argument, this))
			}
		}
		
		if !this._list && this._arguments.length != 1 {
			throw new Error(`Invalid curry syntax at line \(this._data.start.line)`)
		}
		
		if this._data.scope.kind == ScopeModifier::This {
			this._caller = $caller(this._data.callee, this)
		}
		else if this._data.scope.kind == ScopeModifier::Argument {
			this._callScope = $compile.expression(this._data.scope.value, this)
		}
	} // }}}
	fuse() { // {{{
		this._callee.fuse()
		this._caller.fuse() if this._caller?
		this._callScope.fuse() if this._callScope?
		
		for argument in this._arguments {
			argument.fuse()
		}
	} // }}}
	isNullable() { // {{{
		return this._data.nullable || this._callee.isNullable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this.isNullable() && !this._tested {
			fragments.wrapNullable(this).code(' ? ')
			
			this._tested = true
			
			this.toFragments(fragments)
			
			fragments.code(' : undefined')
		}
		else if this._list {
			this.module().flag('Helper')
			
			let kind = this._data.scope.kind
			
			if kind == ScopeModifier::This {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(this._callee)
					.code(', ')
				
				if this._caller? {
					fragments.compile(this._caller)
				}
				else {
					fragments.code('null')
				}
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else if kind == ScopeModifier::Null {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(this._callee)
					.code(', null')
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(this._callee)
					.code($comma)
					.compile(this._callScope)
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
		}
		else {
			this.module().flag('Helper')
			
			let kind = this._data.scope.kind
			
			if kind == ScopeModifier::This {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(this._callee)
					.code($comma)
				
				if this._caller? {
					fragments.compile(this._caller)
				}
				else {
					fragments.code('null')
				}
				
				fragments
					.code($comma)
					.compile(this._arguments[0])
					.code(')')
			}
			else if kind == ScopeModifier::Null {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(this._callee)
					.code(', null, ')
					.compile(this._arguments[0])
					.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(this._callee)
					.code($comma)
					.compile(this._callScope)
					.code($comma)
					.compile(this._arguments[0])
					.code(')')
			}
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
}

class EnumExpression extends Expression {
	private {
		_enum
	}
	EnumExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._enum = $compile.expression(this._data.enum, this)
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._enum).code('.', this._data.member.name)
	} // }}}
}

class FunctionExpression extends Expression {
	private {
		_async		= false
		_parameters
		_statements
	}
	FunctionExpression(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		this._parameters = [new Parameter(parameter, this) for parameter in this._data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $statements(this._data.body)]
	} // }}}
	fuse() { // {{{
		for parameter in this._parameters {
			parameter.analyse()
			parameter.fuse()
		}
		
		for statement in this._statements {
			statement.analyse()
			
			this._async = statement.isAsync() if !this._async
		}
		
		for statement in this._statements {
			statement.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('function(')
		
		let block
		$function.parameters(this, fragments, func(node) {
			block = node.code(')').newBlock()
		})
		
		if this._async {
			let stack = []
			
			let f = block
			let m = Mode::None
			
			let item
			for statement in this._statements {
				if item ?= statement.toFragments(f, m) {
					f = item.fragments
					m = item.mode
					
					stack.push(item)
				}
			}
			
			for item in stack {
				item.done(item.fragments)
			}
		}
		else {
			for statement in this._statements {
				block.compile(statement)
			}
		}
		
		block.done()
	} // }}}
	toShorthandFragments(fragments) { // {{{
		fragments.code('(')
		
		let block
		$function.parameters(this, fragments, func(node) {
			block = node.code(')').newBlock()
		})
		
		if this._async {
			let stack = []
			
			let f = block
			let m = Mode::None
			
			let item
			for statement in this._statements {
				if item ?= statement.toFragments(f, m) {
					f = item.fragments
					m = item.mode
					
					stack.push(item)
				}
			}
			
			for item in stack {
				item.done(item.fragments)
			}
		}
		else {
			for statement in this._statements {
				block.compile(statement)
			}
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
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._then = $compile.expression(this._data.then, this)
		this._else = $compile.expression(this._data.else, this) if this._data.else?
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._then.fuse()
		this._else.fuse() if this._else?
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
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
	toStatementFragments(fragments, mode) { // {{{
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
	} // }}}
	analyse() { // {{{
		this._object = $compile.expression(this._data.object, this)
		this._property = $compile.expression(this._data.property, this)
		
		if (this._data.nullable && (this._object.isNullable() || this._object.isCallable())) || this._property.isNullable() {
			this._object.analyseReusable()
		}
	} // }}}
	analyseReusable() { // {{{
		this._object.analyseReusable()
	} // }}}
	fuse() { // {{{
		this._object.fuse()
	} // }}}
	isCallable() => this._object.isCallable()
	isEntangled() => this.isCallable() || this.isNullable()
	isNullable() => this._data.nullable || this._object.isNullable() || (this._data.computed && this._property.isNullable())
	toFragments(fragments, mode) { // {{{
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
			if this._object.isComputed() || this._object._data.kind == Kind::NumericExpression {
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
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(this._object)
					.code('[')
					.compile(this._property)
					.code(']')
					.code(' : false')
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
				fragments
					.compile(this._object)
					.code('[')
					.compile(this._property)
					.code(']')
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
			if this._data.computed {
				fragments
					.code('(')
					.compileReusable(this._object)
					.code(', ')
					.compile(this._object)
					.code('[')
					.compileReusable(this._property)
					.code(']')
					.code(')')
			}
			else {
				fragments
					.code('(')
					.compileReusable(this._object)
					.code(', ')
					.compile(this._object)
					.code($dot)
					.compile(this._property)
					.code(')')
			}
		}
		else if this._data.computed {
			fragments
				.compile(this._object)
				.code('[')
				.compileReusable(this._property)
				.code(']')
		}
		else {
			fragments
				.compile(this._object)
				.code($dot)
				.compile(this._property)
		}
	} // }}}
}

class ObjectBinding extends Expression {
	private {
		_elements			= []
		_exists				= false
		_existing			= {}
		_variables			= {}
	}
	ObjectBinding(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		for element in this._data.elements {
			if !element.name.computed && element.name.name? && this._scope.hasVariable(element.name.name) {
				this._exists = true
				this._existing[element.name.name] = true
			}
			
			this._elements.push($compile.expression(element, this))
		}
	} // }}}
	fuse() { // {{{
		for element in this._elements {
			element.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._exists {
			fragments.code('{')
			
			let name
			for element, i in this._data.elements {
				fragments.code(', ') if i
				
				if this._existing[element.name.name] {
					name = this._scope.acquireTempName()
					
					this._elements[i].toFragments(fragments, Kind::ObjectBinding, name)
					
					this._variables[name] = element.name.name
				}
				else {
					this._elements[i].toFragments(fragments)
				}
			}
			
			fragments.code('}')
			
			this.statement().afterward(this)
		}
		else {
			fragments.code('{')
			
			for i from 0 til this._elements.length {
				fragments.code(', ') if i
				
				this._elements[i].toFragments(fragments)
			}
			
			fragments.code('}')
		}
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		for name, variable of this._variables {
			fragments.line(variable, ' = ', name)
			
			this._scope.releaseTempName(name)
		}
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		fragments.code('var ')
		
		this.toFragments(fragments, Mode::None)
	} // }}}
}

class ObjectExpression extends Expression {
	private {
		_properties = []
		_templates = []
	}
	ObjectExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		for property in this._data.properties {
			if property.name.kind == Kind::Identifier || property.name.kind == Kind::Literal {
				this._properties.push(property = new ObjectMember(property, this))
			}
			else {
				this._templates.push(property = new ObjectTemplateMember(property, this))
			}
			
			property.analyse()
		}
	} // }}}
	fuse() { // {{{
		for property in this._properties {
			property.fuse()
		}
		
		for property in this._templates {
			property.fuse()
		}
	} // }}}
	reference() => this._parent.reference()
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	analyse() { // {{{
		if this._data.name.kind == Kind::Identifier	{
			this._name = new IdentifierLiteral(this._data.name, this, false)
			
			this.reference('.' + this._data.name.name)
		}
		else {
			this._name = new StringLiteral(this._data.name, this)
			
			this.reference('[' + $quote(this._data.name.value) + ']')
		}
		
		this._name.analyse()
		
		this._value = $compile.expression(this._data.value, this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._name)
		
		if this._data.value.kind == Kind::FunctionExpression {
			this._value.toShorthandFragments(fragments)
		}
		else {
			fragments.code(': ').compile(this._value)
		}
	} // }}}
}

class ObjectTemplateMember extends Expression {
	private {
		_name
		_value
	}
	ObjectTemplateMember(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._name = new TemplateExpression(this._data.name, this)
		
		this._name.analyse()
		
		this._value = $compile.expression(this._data.value, this)
		
		this.statement().afterward(this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		fragments
			.newLine()
			.code(this.parent().reference(), '[')
			.compile(this._name)
			.code('] = ')
			.compile(this._value)
			.done()
	} // }}}
}

class OmittedExpression extends Expression {
	OmittedExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
	} // }}}
}

class PolyadicOperatorExpression extends Expression {
	private {
		_operands
		_tested = false
	}
	isComputed() => true
	isNullable() { // {{{
		for operand in this._operands {
			return true if operand.isNullable()
		}
		
		return false
	} // }}}
	analyse() { // {{{
		this._operands = [$compile.expression(operand, this) for operand in this._data.operands]
	} // }}}
	fuse() { // {{{
		for operand in this._operands {
			operand.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		let test = this.isNullable() && !this._tested
		if test {
			fragments
				.compileNullable(this)
				.code(' ? ')
		}
		
		this.toOperatorFragments(fragments)
		
		if test {
			fragments.code(' : false')
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			let nf = false
			for operand in this._operands {
				if operand.isNullable() {
					if nf {
						fragments.code(' && ')
					}
					else {
						nf = true
					}
					
					fragments.compileNullable(operand)
				}
			}
			
			this._tested = true
		}
	} // }}}
}

class PolyadicOperatorAddition extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('+', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
}

class PolyadicOperatorAnd extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('&&', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrapBoolean(operand)
		}
	} // }}}
}

class PolyadicOperatorLessThanOrEqual extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		for i from 0 til this._operands.length - 1 {
			fragments.code(' && ') if i
			
			fragments
				.wrap(this._operands[i])
				.code($space)
				.code('<=', this._data.operator)
				.code($space)
				.wrap(this._operands[i + 1])
		}
	} // }}}
}

class PolyadicOperatorMultiplication extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('*', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
}

class PolyadicOperatorNullCoalescing extends PolyadicOperatorExpression {
	PolyadicOperatorNullCoalescing(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		this._operands = []
		
		let l = this._data.operands.length - 1
		let scope = this._scope
		
		let operand
		for i from 0 to l {
			if i == l {
				this._scope = scope
			}
			else {
				this._scope = new Scope(scope)
			}
			
			this._operands.push(operand = $compile.expression(this._data.operands[i], this))
			
			if i != l && this._data.operands[i].kind != Kind::Identifier {
				operand.analyseReusable()
			}
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Type')
		
		let l = this._operands.length - 1
		
		let operand
		for i from 0 til l {
			operand = this._operands[i]
			
			if operand.isNullable() {
				fragments.code('(')
				
				operand.toNullableFragments(fragments)
				
				fragments
					.code(' && ' + $runtime.type(this) + '.isValue(')
					.compileReusable(operand)
					.code('))')
			}
			else {
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(operand)
					.code(')')
			}
			
			fragments
				.code(' ? ')
				.compile(operand)
				.code(' : ')
		}
		
		fragments.compile(this._operands[l])
	} // }}}
}

class PolyadicOperatorOr extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('||', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrapBoolean(operand)
		}
	} // }}}
}

class RegularExpression extends Expression {
	private {
		_value
	}
	RegularExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code(this._data.value)
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
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._then = $compile.expression(this._data.then, this)
		this._else = $compile.expression(this._data.else, this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._then.fuse()
		this._else.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	analyse() { // {{{
		this._elements = [$compile.expression(element, this) for element in this._data.elements]
	} // }}}
	fuse() { // {{{
	} // }}}
	isComputed() => this._elements.length > 1
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._then = $compile.expression(this._data.then, this)
		this._else = $compile.expression(this._data.else, this) if this._data.else?
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._then.fuse()
		this._else.fuse() if this._else?
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
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
	toStatementFragments(fragments, mode) { // {{{
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
class UnaryOperatorExpression extends Expression {
	private {
		_argument
		_right
	}
	analyse() { // {{{
		this._argument = $compile.expression(this._data.argument, this)
	} // }}}
	fuse() { // {{{
		this._argument.fuse()
	} // }}}
}

class UnaryOperatorDecrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(this._argument)
			.code('--', this._data.operator)
	} // }}}
}

class UnaryOperatorDecrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('--', this._data.operator)
			.wrap(this._argument)
	} // }}}
}

class UnaryOperatorExistential extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
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

class UnaryOperatorIncrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(this._argument)
			.code('++', this._data.operator)
	} // }}}
}

class UnaryOperatorIncrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('++', this._data.operator)
			.wrap(this._argument)
	} // }}}
}

class UnaryOperatorNegation extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('!', this._data.operator)
			.wrapBoolean(this._argument)
	} // }}}
}

class UnaryOperatorNegative extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('-', this._data.operator)
			.wrap(this._argument)
	} // }}}
}

class UnaryOperatorNew extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
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
	analyse() { // {{{
	} // }}}
	analyseReusable() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	isComposite() => false
	isEntangled() => false
	toFragments(fragments, mode) { // {{{
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
			
			if !this._scope.hasVariable(data.name) {
				throw new Error(`Undefined variable '\(data.name)' at line \(data.start.line)`)
			}
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._isVariable {
			fragments.code(this._scope.getRenamedVariable(this._value), this._data)
		}
		else {
			fragments.code(this._value, this._data)
		}
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
		let expression
		
		let clazz = $expressions[data.kind]
		if clazz? {
			expression = Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
		}
		else if data.kind == Kind::BinaryOperator {
			if clazz ?= $binaryOperators[data.operator.kind] {
				expression = Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
			}
			else if data.operator.kind == BinaryOperator::Assignment {
				if clazz = $assignmentOperators[data.operator.assignment] {
					expression = Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
				}
				else {
					console.error(data)
					throw new Error('Unknow assignment operator ' + data.operator.assignment)
				}
			}
			else {
				console.error(data)
				throw new Error('Unknow binary operator ' + data.operator.kind)
			}
		}
		else if data.kind == Kind::PolyadicOperator {
			if clazz ?= $polyadicOperators[data.operator.kind] {
				expression = Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
			}
			else {
				console.error(data)
				throw new Error('Unknow polyadic operator ' + data.operator.kind)
			}
		}
		else if data.kind == Kind::UnaryExpression {
			if clazz ?= $unaryOperators[data.operator.kind] {
				expression = Type.isConstructor(clazz) ? new clazz(data, parent) : clazz(data, parent)
			}
			else {
				console.error(data)
				throw new Error('Unknow unary operator ' + data.operator.kind)
			}
		}
		else {
			console.error(data)
			throw new Error('Unknow kind ' + data.kind)
		}
		
		//console.log(expression)
		expression.analyse()
		
		return expression
	} // }}}
	statement(data, parent) { // {{{
		let clazz = $statements[data.kind] ?? $statements.default
		
		return new clazz(data, parent)
	} // }}}
}

const $assignmentOperators = {
	`\(AssignmentOperator::Addition)`			: AssignmentOperatorAddition
	`\(AssignmentOperator::BitwiseAnd)`			: AssignmentOperatorBitwiseAnd
	`\(AssignmentOperator::BitwiseLeftShift)`	: AssignmentOperatorBitwiseLeftShift
	`\(AssignmentOperator::BitwiseOr)`			: AssignmentOperatorBitwiseOr
	`\(AssignmentOperator::BitwiseRightShift)`	: AssignmentOperatorBitwiseRightShift
	`\(AssignmentOperator::BitwiseXor)`			: AssignmentOperatorBitwiseXor
	`\(AssignmentOperator::Equality)`			: AssignmentOperatorEquality
	`\(AssignmentOperator::Existential)`		: AssignmentOperatorExistential
	`\(AssignmentOperator::Modulo)`				: AssignmentOperatorModulo
	`\(AssignmentOperator::Multiplication)`		: AssignmentOperatorMultiplication
	`\(AssignmentOperator::NullCoalescing)`		: AssignmentOperatorNullCoalescing
	`\(AssignmentOperator::Subtraction)`		: AssignmentOperatorSubtraction
}

const $binaryOperators = {
	`\(BinaryOperator::Addition)`			: BinaryOperatorAddition
	`\(BinaryOperator::And)`				: BinaryOperatorAnd
	`\(BinaryOperator::BitwiseAnd)`			: BinaryOperatorBitwiseAnd
	`\(BinaryOperator::BitwiseLeftShift)`	: BinaryOperatorBitwiseLeftShift
	`\(BinaryOperator::BitwiseOr)`			: BinaryOperatorBitwiseOr
	`\(BinaryOperator::BitwiseRightShift)`	: BinaryOperatorBitwiseRightShift
	`\(BinaryOperator::BitwiseXor)`			: BinaryOperatorBitwiseXor
	`\(BinaryOperator::Division)`			: BinaryOperatorDivision
	`\(BinaryOperator::Equality)`			: BinaryOperatorEquality
	`\(BinaryOperator::GreaterThan)`		: BinaryOperatorGreaterThan
	`\(BinaryOperator::GreaterThanOrEqual)`	: BinaryOperatorGreaterThanOrEqual
	`\(BinaryOperator::Inequality)`			: BinaryOperatorInequality
	`\(BinaryOperator::LessThan)`			: BinaryOperatorLessThan
	`\(BinaryOperator::LessThanOrEqual)`	: BinaryOperatorLessThanOrEqual
	`\(BinaryOperator::Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperator::Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperator::NullCoalescing)`		: BinaryOperatorNullCoalescing
	`\(BinaryOperator::Or)`					: BinaryOperatorOr
	`\(BinaryOperator::Subtraction)`		: BinaryOperatorSubtraction
	`\(BinaryOperator::TypeCast)`			: BinaryOperatorTypeCast
	`\(BinaryOperator::TypeCheck)`			: BinaryOperatorTypeCheck
}

const $expressions = {
	`\(Kind::ArrayBinding)`					: ArrayBinding
	`\(Kind::ArrayComprehension)`			: func(data, parent) {
		if data.loop.kind == Kind::ForInStatement {
			return new ArrayComprehensionForIn(data, parent)
		}
		else if data.loop.kind == Kind::ForOfStatement {
			return new ArrayComprehensionForOf(data, parent)
		}
		else if data.loop.kind == Kind::ForRangeStatement {
			return new ArrayComprehensionForRange(data, parent)
		}
		else {
			console.error(data)
			throw new Error('Not Implemented')
		}
	}
	`\(Kind::ArrayExpression)`				: ArrayExpression
	`\(Kind::ArrayRange)`					: ArrayRange
	`\(Kind::BindingElement)`				: BindingElement
	`\(Kind::Block)`						: BlockExpression
	`\(Kind::CallExpression)`				: func(data, parent) {
		if data.callee.kind == Kind::MemberExpression && !data.callee.computed && (callee = $final.callee(data.callee, parent)) {
			return new CallFinalExpression(data, parent, callee)
		}
		else {
			return new CallExpression(data, parent)
		}
	}
	`\(Kind::CurryExpression)`				: CurryExpression
	`\(Kind::EnumExpression)`				: EnumExpression
	`\(Kind::FunctionExpression)`			: FunctionExpression
	`\(Kind::Identifier)`					: IdentifierLiteral
	`\(Kind::IfExpression)`					: IfExpression
	`\(Kind::Literal)`						: StringLiteral
	`\(Kind::MemberExpression)`				: MemberExpression
	`\(Kind::NumericExpression)`			: NumberLiteral
	`\(Kind::ObjectBinding)`				: ObjectBinding
	`\(Kind::ObjectExpression)`				: ObjectExpression
	`\(Kind::ObjectMember)`					: ObjectMember
	`\(Kind::OmittedExpression)`			: OmittedExpression
	`\(Kind::RegularExpression)`			: RegularExpression
	`\(Kind::TemplateExpression)`			: TemplateExpression
	`\(Kind::TernaryConditionalExpression)`	: TernaryConditionalExpression
	`\(Kind::UnlessExpression)`				: UnlessExpression
}

const $statements = {
	`\(Kind::ClassDeclaration)`				: ClassDeclaration
	`\(Kind::DoUntilStatement)`				: DoUntilStatement
	`\(Kind::DoWhileStatement)`				: DoWhileStatement
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
	`\(Kind::RequireOrExternDeclaration)`	: RequireOrExternDeclaration
	`\(Kind::ReturnStatement)`				: ReturnStatement
	`\(Kind::SwitchStatement)`				: SwitchStatement
	`\(Kind::ThrowStatement)`				: ThrowStatement
	`\(Kind::TryStatement)`					: TryStatement
	`\(Kind::TypeAliasDeclaration)`			: TypeAliasDeclaration
	`\(Kind::UnlessStatement)`				: UnlessStatement
	`\(Kind::UntilStatement)`				: UntilStatement
	`\(Kind::VariableDeclaration)`			: VariableDeclaration
	`\(Kind::WhileStatement)`				: WhileStatement
	`default`								: ExpressionStatement
}

const $polyadicOperators = {
	`\(BinaryOperator::Addition)`			: PolyadicOperatorAddition
	`\(BinaryOperator::And)`				: PolyadicOperatorAnd
	/* `\(BinaryOperator::Division)`			: PolyadicOperatorDivision
	`\(BinaryOperator::Equality)`			: PolyadicOperatorEquality
	`\(BinaryOperator::GreaterThan)`		: PolyadicOperatorGreaterThan
	`\(BinaryOperator::GreaterThanOrEqual)`	: PolyadicOperatorGreaterThanOrEqual
	`\(BinaryOperator::LessThan)`			: PolyadicOperatorLessThan */
	`\(BinaryOperator::LessThanOrEqual)`	: PolyadicOperatorLessThanOrEqual
	/* `\(BinaryOperator::Modulo)`				: PolyadicOperatorModulo */
	`\(BinaryOperator::Multiplication)`		: PolyadicOperatorMultiplication
	`\(BinaryOperator::NullCoalescing)`		: PolyadicOperatorNullCoalescing
	`\(BinaryOperator::Or)`					: PolyadicOperatorOr
	/* `\(BinaryOperator::Subtraction)`		: PolyadicOperatorSubtraction */
}

const $unaryOperators = {
	/* `\(UnaryOperator::BitwiseNot)`			: UnaryOperatorBitwiseNot */
	`\(UnaryOperator::DecrementPostfix)`	: UnaryOperatorDecrementPostfix
	`\(UnaryOperator::DecrementPrefix)`		: UnaryOperatorDecrementPrefix
	`\(UnaryOperator::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperator::IncrementPostfix)`	: UnaryOperatorIncrementPostfix
	`\(UnaryOperator::IncrementPrefix)`		: UnaryOperatorIncrementPrefix
	`\(UnaryOperator::Negation)`			: UnaryOperatorNegation
	`\(UnaryOperator::Negative)`			: UnaryOperatorNegative
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
		
		this._module.analyse()
		
		this._module.fuse()
		
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
		
		if source.length {
			return source.substr(0, source.length - 1)
		}
		else {
			return source
		}
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