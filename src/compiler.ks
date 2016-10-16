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

enum VariableKind { // {{{
	Class = 1
	Enum
	Function
	TypeAlias
	Variable
} // }}}

const $extensions = { // {{{
	binary: '.ksb',
	hash: '.ksh',
	metadata: '.ksm',
	source: '.ks'
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
func $fragmentsToText(fragments) {
	return [fragment.code for fragment in fragments].join('')
}

func $locationDataToString(location?) {
	if location? {
		return `\(location.first_line + 1):\(location.first_column + 1)-\(location.last_line + 1):\(location.last_column + 1)`
	}
	else {
		return 'No location data'
	}
}

class CodeFragment {
	private {
		end		= null
		code
		start	= null
	}
	CodeFragment(@code)
	CodeFragment(@code, @start, @end)
	toString() {
		if this._start? {
			return `\(this._code): \($locationDataToString(this._location))`
		}
		else {
			return this.code
		}
	}
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

const $function = {
	parameters(node, indent, fragments, fn) { // {{{
		if node._options.parameters == 'es5' {
			$function.parametersES5(node, indent, fragments, fn)
		}
		else if node._options.parameters == 'es6' {
			$function.parametersES6(node, indent, fragments, fn)
		}
		else {
			$function.parametersKS(node, indent, fragments, fn)
		}
	} // }}}
	parametersKS(node, indent, fragments: Array, fn) { // {{{
		let signature = $function.signature(node._data, node)
		//console.log(signature)
		
		let parameter
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
				parameter = node._data.parameters[i]
				
				fragments.push($comma) if i
				
				if parameter.name {
					names[i] = parameter.name.name
					
					fragments.push($codeLoc(parameter.name.name, parameter.name.start, parameter.name.end))
				}
				else {
					fragments.push($code(names[i] = node.acquireTempName()))
				}
				
				if parameter.type {
					if parameter.type.nullable && !parameter.defaultValue {
						fragments.push($code(' = null'))
					}
				}
			}
			
			/* if !ra && rest != -1 && (signature.parameters[rest].type == 'Any' || !maxa) {
				if rest {
					node.code(', ')
				}
				
				if data.parameters[rest].name {
					names[rest] = data.parameters[rest].name
				}
				else {
					names[rest] = node.acquireTempName()
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
			} */
			
			fn()
			
			/* if ra {
				node
					.newControl(config)
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.newExpression(config)
					.code('throw new Error("Wrong number of arguments")')
			} */
			
			for i from 0 til l {
				parameter = node._data.parameters[i]
				
				if parameter.name? && (!?parameter.type || !parameter.type.nullable || parameter.defaultValue?) {
					fragments.push($indent(indent), $code('if('), $code(parameter.name.name), $code(' === undefined'))
					
					if !?parameter.type || !parameter.type.nullable {
						fragments.push($code(' || '), $code(parameter.name.name), $code(' === null'))
					}
					
					fragments.push($code(') {\n'))
					
					if parameter.defaultValue? {
						fragments.push($indent(indent + 1), $code(parameter.name.name), $equals)
						
						fragments.append(node._parameters[i]._defaultValue.toFragments(indent))
						
						fragments.push($terminator)
					}
					else {
						fragments.push($indent(indent + 1), $code('throw new Error("Missing parameter \''), $code(parameter.name.name), $code('\'")'), $terminator)
					}
					
					fragments.push($indent(indent), $code('}\n'))
				}
				
				/* if !$type.isAny(parameter.type) {
					ctrl = node.newControl(config)
					
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
						.newExpression(config)
						.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
				} */
			}
			
			if ra {
				/* parameter = data.parameters[rest] */
				
				if signature.parameters[rest].type == 'Any' {
					/* if parameter.name {
						node.newExpression(config).code($variable.scope(config), '__ks_i')
						
						node
							.newExpression(config)
							.code($variable.scope(config))
							.parameter(parameter.name, config)
							.code(' = arguments.length > ' + (maxb + ra) + ' ? Array.prototype.slice.call(arguments, ' + maxb + ', __ks_i = arguments.length - ' + ra + ') : (__ks_i = ' + maxb + ', [])')
					}
					else {
						node.newExpression(config).code($variable.scope(config), '__ks_i = arguments.length > ' + (maxb + ra) + ' ? arguments.length - ' + ra + ' : ' + maxb)
					} */
				}
				else {
					/* node.newExpression(config).code($variable.scope(config), '__ks_i')
					
					if parameter.name {
						node
							.newExpression(config)
							.code($variable.scope(config))
							.parameter(parameter.name, config)
							.code(' = []')
					} */
				}
			}
			else if rest != -1 && signature.parameters[rest].type != 'Any' && maxa {
				/* parameter = data.parameters[rest] */
				
				/* if maxb {
				}
				else {
					node.newExpression(config).code($variable.scope(config), '__ks_i = -1')
				} */
			
				/* if parameter.name {
					node
						.newExpression(config)
						.code($variable.scope(config))
						.parameter(parameter.name, config, {
							kind: Kind::TypeReference
							typeName: {
								kind: Kind::Identifier
								name: 'Array'
							}
						})
						.code(' = []')
				} */
				
				/* ctrl = node
					.newControl(config)
					.code('while(')
				
				$type.check(ctrl, 'arguments[++__ks_i]', parameter.type, config)
				
				ctrl
					.code(')')
					.step()
				
				if parameter.name {
					ctrl
						.newExpression(config)
						.parameter(parameter.name, config)
						.code('.push(arguments[__ks_i])')
				} */
			}
			
			if rest != -1 {
				/* parameter = data.parameters[rest] */
				
				/* if (arity = $function.arity(parameter)) && arity.min {
					node
						.newControl(config)
						.code('if(')
						.parameter(parameter.name, config)
						.code('.length < ', arity.min, ')')
						.step()
						.newExpression(config)
						.code('throw new Error("Wrong number of arguments")')
				} */
			}
			else if signature.async && !ra {
				/* node.module().flag('Type')
				
				node
					.newControl(config)
					.code('if(!', $runtime.type(config), '.isFunction(__ks_cb))')
					.step()
					.newExpression(config)
					.code('throw new Error("Invalid callback")') */
			}
		} // }}}
		else { // {{{
			fn()
			
			/* if signature.min {
				node
					.newControl(config)
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.newExpression(config)
					.code('throw new Error("Wrong number of arguments")')
			}
				
			node.newExpression(config).code($variable.scope(config), '__ks_i = -1') */
			
			let required = rb
			let optional = 0
			
			for i from 0 til l {
				/* parameter = data.parameters[i] */
				
				/* if parameter.name {
					$variable.define(node, parameter.name, $variable.kind(parameter.type), parameter.type)
				} */
				
				if arity = $function.arity(parameter) { // {{{
					required -= arity.min
					
					if parameter.name {
						if $type.isAny(parameter.type) {
							/* if required {
								node
									.newExpression(config)
									.code($variable.scope(config))
									.compile(parameter.name, config)
									.code(' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - ', required, ', __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									node.newExpression(config).code('__ks_i += ').parameter(parameter.name, config).code('.length')
								}
							}
							else {
								node
									.newExpression(config)
									.code($variable.scope(config))
									.compile(parameter.name, config)
									.code(' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									node.newExpression(config).code('__ks_i += ').parameter(parameter.name, config).code('.length')
								}
							} */
						}
						else {
							/* node
								.newExpression(config)
								.code($variable.scope(config))
								.compile(parameter.name, config)
								.code(' = []')
							
							ctrl = node.newControl(config)
							
							if required {
								ctrl.code('while(__ks_i < arguments.length - ', required, ' && ')
							}
							else {
								ctrl.code('while(__ks_i + 1 < arguments.length && ')
							}
							
							ctrl
								.compile(parameter.name, config)
								.code('.length < ', arity.max, ' )')
								.step() */
						}
					}
					else {
					}
					
					optional += arity.max - arity.min
				} // }}}
				else { // {{{
					if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
						/* ctrl = node
							.newControl(config)
							.code('if(arguments.length > ', signature.min + optional, ')')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[++__ks_i]')
							}
							else {
								ctrl
									.newExpression(config)
									.code('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl(config)
								.code('if(')
							
							$type.check(ctrl2, 'arguments[__ks_i + 1]', parameter.type, config)
							
							ctrl2
								.code(')')
								.step()
								.newExpression(config)
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[++__ks_i]')
							
							ctrl2
								.step()
								.code('else ')
								.step()
							
							if rest == -1 {
								ctrl2
									.newExpression(config)
									.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
							}
							else if parameter.defaultValue {
								ctrl2
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl2
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
						
						if parameter.name {
							ctrl.step().code('else ').step()
						
							if parameter.defaultValue {
								ctrl
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
						
						++optional */
					}
					else {
						/* if $type.isAny(parameter.type) {
							if parameter.name {
								node
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[++__ks_i]')
							}
							else {
								node
									.newExpression(config)
									.code('++__ks_i')
							}
						}
						else {
							if parameter.name {
								ctrl = node
									.newControl(config)
									.code('if(')
								
								$type.check(ctrl, 'arguments[++__ks_i]', parameter.type, config)
								
								ctrl
									.code(')')
									.step()
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[__ks_i]')
								
								ctrl
									.step()
									.code('else ')
									.newExpression(config)
									.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
							}
							else {
								ctrl = node
									.newControl(config)
									.code('if(!')
								
								$type.check(ctrl, 'arguments[++__ks_i]', parameter.type, config)
								
								ctrl
									.code(')')
									.step()
									.newExpression(config)
									.code('throw new Error("Wrong type of arguments")')
							}
						}
						
						--required */
					}
				}
				// }}}
			}
			
			if rest != -1 { // {{{
				/* parameter = data.parameters[rest] */
				
				if ra {
					/* if parameter.name {
						node
							.newExpression(config)
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
							node.newExpression(config).code('__ks_i += ').parameter(parameter.name, config).code('.length')
						}
					}
					else if l + 1 < data.parameters.length {
						node
							.newControl(config)
							.code('if(arguments.length > __ks_i + ' , ra + 1, ')')
							.step()
							.newExpression(config).code('__ks_i = arguments.length - ', ra + 1)
					} */
				}
				else {
					/* if parameter.name {
						node
							.newExpression(config)
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
							node.newExpression(config).code('__ks_i += ').parameter(parameter.name, config).code('.length')
						}
					} */
				}
			} // }}}
		} // }}}
		
		if ra || maxa { // {{{
			/* if ra != maxa && signature.parameters[rest].type != 'Any' {
				if ra {
					node
						.newExpression(config)
						.code($variable.scope(config), '__ks_m = __ks_i + ', ra)
				}
				else {
					node
						.newExpression(config)
						.code($variable.scope(config), '__ks_m = __ks_i')
				}
			} */
			
			/* for i from rest + 1 til data.parameters.length {
				/* parameter = data.parameters[i] */
				
				/* if parameter.name {
					$variable.define(node, parameter.name, $variable.kind(parameter.type), parameter.type)
				} */
				
				if arity = $function.arity(parameter) {
					/* if arity.min {
						if parameter.name {
							if $type.isAny(parameter.type) {
								node
									.newExpression(config)
									.code($variable.scope(config))
									.compile(parameter.name, config)
									.code(' = Array.prototype.slice.call(arguments, __ks_i + 1, __ks_i + ', arity.min + 1, ')')
								
								if i + 1 < data.parameters.length {
									node.newExpression(config).code('__ks_i += ').parameter(parameter.name, config).code('.length')
								}
							}
							else {
							}
						}
						else {
						}
					}
					else {
					} */
				}
				else if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
					if signature.parameters[rest].type == 'Any' {
						/* if parameter.name {
							if parameter.defaultValue {
								node
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								node
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						} */
					}
					else {
						/* ctrl = node
							.newControl(config)
							.code('if(arguments.length > __ks_m)')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = arguments[', inc ? '++' : '', '__ks_i]')
							}
							else {
								ctrl
									.newExpression(config)
									.code('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl(config)
								.code('if(')
							
							$type.check(ctrl2, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type, config)
							
							ctrl2
								.code(')')
								.step()
								.newExpression(config)
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[__ks_i]')
							
							ctrl2
								.step()
								.code('else ')
							
							if parameter.defaultValue {
								ctrl2
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl2
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						} */
						
						/* if parameter.name {
							ctrl.step().code('else ').step()
						
							if parameter.defaultValue {
								ctrl
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = ')
									.compile(parameter.defaultValue, config)
							}
							else {
								ctrl
									.newExpression(config)
									.code('var ')
									.compile(parameter.name, config)
									.code(' = null')
							}
						}
						
						if !inc {
							inc = true
						} */
					}
				}
				else {
					if $type.isAny(parameter.type) {
						/* if parameter.name {
							node
								.newExpression(config)
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[', inc ? '++' : '', '__ks_i]')
						}
						else {
							node
								.newExpression(config)
								.code(inc ? '++' : '', '__ks_i')
						} */
					}
					else {
						/* if parameter.name {
							ctrl = node
								.newControl(config)
								.code('if(')
							
							$type.check(ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type, config)
							
							ctrl
								.code(')')
								.step()
								.newExpression(config)
								.code('var ')
								.compile(parameter.name, config)
								.code(' = arguments[__ks_i]')
							
							ctrl
								.step()
								.code('else ')
								.newExpression(config)
								.code('throw new Error("Invalid type for parameter \'').compile(parameter.name, config).code('\'")')
						}
						else {
							ctrl = node
								.newControl(config)
								.code('if(!')
							
							$type.check(ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type, config)
							
							ctrl
								.code(')')
								.step()
								.newExpression(config)
								.code('throw new Error("Wrong type of arguments")')
						} */
					}
					
					if !inc {
						inc = true
					}
				}
			} */
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

func $return(body) { // {{{
	return {
		kind: Kind::Block
		statements: [
			{
				kind: Kind::ReturnStatement
				value: body
			}
		]
	}
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

const $type = {
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
	scope(node) { // {{{
		return node._options.variables == 'es5' ? 'var ' : 'let '
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
}

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
		return this._variables[name]? || (this._parent? && this._parent.hasVariable(name, true))
	} // }}}
	rename(name) { // {{{
		let newName = this.newRenamedVariable(name)
		if newName != name {
			this._renamedVariables[name] = newName
		}
	
		return this
	} // }}}
	statement() => this
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		for statement in this._body {
			fragments.append(statement.toFragments(indent))
		}
		
		return fragments
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
			
			/* node.useTempVariable(name, assignment) if node */
			
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

class Module {
	private {
		_body
		_data
		_flags					= {}
		_imports				= {}
		_options
		_register				= false
		_requirements			= {}
	}
	Module(@data, options) { // {{{
		this._options = $applyAttributes(data, options)
		
		this._body = new ModuleScope(data, this)
	} // }}}
	flag(name) { // {{{
		this._flags[name] = true
	} // }}}
	toFragments() { // {{{
		let body = this._body.toFragments(1)
		
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
		
		fragments.push($code('module.exports = function() {\n'))
		
		fragments.append(body)
		
		fragments.push($code('}'))
		
		return fragments
	} // }}}
}

// {{{ Statements
class Statement extends Base {
	private {
		_usages				= []
		_variable			= ''
		_variables	: Array	= []
	}
	acquireTempName(node?, assignment = false, fromChild = true) { // {{{
		return this._parent.acquireTempName(node, assignment, fromChild)
	} // }}}
	addVariable(name, definition) { // {{{
		this._parent.addVariable(name, definition)
		
		return this
	} // }}}
	rename(name) { // {{{
		this._parent.rename(name)
		
		return this
	} // }}}
	assignment(data, variable = false) { // {{{
		if data.left.kind == Kind::Identifier && !this.hasVariable(data.left.name) {
			if this.denyVariable() || variable || this._variable.length {
				this._variables.push(data.left.name)
			}
			else {
				this._variable = data.left.name
			}
			
			$variable.define(this, data.left, $variable.kind(data.right.type), data.right.type)
		}
	} // }}}
	denyVariable() => true
	getRenamedVariable(name) { // {{{
		return this._parent.getRenamedVariable(name)
	} // }}}
	getVariable(name, fromChild = true) { // {{{
		return this._parent.getVariable(name, fromChild)
	} // }}}
	hasVariable(name, fromChild = true) { // {{{
		return this._parent.hasVariable(name, fromChild)
	} // }}}
	newBlock(data) => this._parent.newBlock(data, this._parent)
	newRenamedVariable(name) { // {{{
		return this._parent.newRenamedVariable(name)
	} // }}}
	releaseTempName(name, fromChild = true) { // {{{
		this._parent.releaseTempName(name, fromChild)
		
		return this
	} // }}}
	statement() => this
	toFragments(indent) { // {{{
		for variable in this._usages {
			if !this._parent.hasVariable(variable.name) {
				throw new Error(`Undefined variable '\(variable.name)' at line \(variable.start.line)`)
			}
		}
		
		let fragments: Array = []
		
		if this._variables.length {
			fragments.push($indent(indent), $code('let ' + this._variables.join(', ') + ';\n'))
		}
		
		this.toStatementFragments(indent, fragments)
		
		return fragments
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
	/* useTempVariable(name, assignment) { // {{{
		if assignment && this._variable.length == 0 {
			this._variable = name
		}
		else {
			this._variables.pushUniq(name)
		}
	} // }}} */
}

class ExpressionStatement extends Statement {
	private {
		_denyVariable
		_expression
	}
	ExpressionStatement(data, parent) { // {{{
		super(data, parent)
		
		this._denyVariable = !(data.kind == Kind::BinaryOperator && data.operator.kind == BinaryOperator::Assignment)
		
		this._expression = $compile.expression(data, this)
	} // }}}
	denyVariable() => this._denyVariable
	toStatementFragments(indent, fragments: Array) { // {{{
		fragments.push($indent(indent))
		
		if this._variable.length {
			fragments.push($code($variable.scope(this)))
		}
		
		fragments.append(this._expression.toFragments(indent))
		
		fragments.push($terminator)
	} // }}}
}

class ExternDeclaration extends Statement {
	ExternDeclaration(data, parent) { // {{{
		super(data, parent)
		
		for declaration in data.declarations {
			switch declaration.kind {
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
	toStatementFragments(indent, fragments: Array) { // {{{
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
	toStatementFragments(indent, fragments: Array) { // {{{
		let data = this._data
		
		fragments.push($indent(indent), $code('for('))
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			fragments.push($code($variable.scope(this)))
		}
		fragments.append(this._variable.toFragments(indent))
		fragments.push($equals)
		fragments.append(this._from.toFragments(indent))
		
		let bound
		if data.til {
			if this._til.isComplex() {
				bound = this.acquireTempName()
				
				fragments.push($code(bound), $equals)
				fragments.append(this._til.toFragments(indent))
			}
		}
		else {
			if this._to.isComplex() {
				bound = this.acquireTempName()
				
				fragments.push($code(bound), $equals)
				fragments.append(this._to.toFragments(indent))
			}
		}
		
		let by
		if data.by && this._by.isComplex() {
			by = this.acquireTempName()
			
			fragments.push($comma, $code(by), $equals)
			fragments.append(this._by.toFragments(indent))
		}
		
		fragments.push($code('; '))
		
		if data.until {
			fragments.push($code('!('))
			
			fragments.append(this._until.toBooleanFragments(indent))
			
			fragments.push($code(') && '))
		}
		else if data.while {
			fragments.append(this._while.toBooleanFragments(indent))
			
			fragments.push($code(' && '))
		}
		
		fragments.append(this._variable.toFragments(indent))
		
		let desc = (data.by && data.by.kind == Kind::NumericExpression && data.by.value < 0) || (data.from.kind == Kind::NumericExpression && ((data.to && data.to.kind == Kind::NumericExpression && data.from.value > data.to.value) || (data.til && data.til.kind == Kind::NumericExpression && data.from.value > data.til.value)))
		
		if data.til {
			if desc {
				fragments.push($code(' > '))
			}
			else {
				fragments.push($code(' < '))
			}
			
			if this._til.isComplex() {
				fragments.push($code(bound))
			}
			else {
				fragments.append(this._til.toFragments(indent))
			}
		}
		else {
			if desc {
				fragments.push($code(' >= '))
			}
			else {
				fragments.push($code(' <= '))
			}
			
			if this._to.isComplex() {
				fragments.push($code(bound))
			}
			else {
				fragments.append(this._to.toFragments(indent))
			}
		}
		
		fragments.push($code('; '))
		
		if data.by {
			if data.by.kind == Kind::NumericExpression {
				if data.by.value == 1 {
					fragments.push($code('++'))
					fragments.append(this._variable.toFragments(indent))
				}
				else if data.by.value == -1 {
					fragments.push($code('--'))
					fragments.append(this._variable.toFragments(indent))
				}
				else if data.by.value >= 0 {
					fragments.append(this._variable.toFragments(indent))
					fragments.push($code(' += '))
					fragments.append(this._by.toFragments(indent))
				}
				else {
					fragments.append(this._variable.toFragments(indent))
					fragments.push($code(' -= '))
					fragments.push($code(-data.by.value))
				}
			}
			else {
				fragments.append(this._variable.toFragments(indent))
				fragments.push($code(' += '))
				fragments.append(this._by.toFragments(indent))
			}
		}
		else if desc {
			fragments.push($code('--'))
			fragments.append(this._variable.toFragments(indent))
		}
		else {
			fragments.push($code('++'))
			fragments.append(this._variable.toFragments(indent))
		}
		
		fragments.push($code(') {\n'))
		
		if data.when {
			fragments.push($indent(indent + 1), $code('if('))
			fragments.append(this._when.toBooleanFragments(indent))
			fragments.push($code(') {\n'))
			
			fragments.append(this._body.toFragments(indent + 2))
			
			fragments.push($indent(indent + 1), $code('}\n'))
		}
		else {
			fragments.append(this._body.toFragments(indent + 1))
		}
		
		fragments.push($indent(indent), $code('}\n'))
		
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
	toStatementFragments(indent, fragments: Array) { // {{{
		let data = this._data
		
		let value, index, bound
		if this._value.isComplex() {
			value = this.greatParent().acquireTempName()
			
			this.parent().updateTempNames()
			
			fragments.push($indent(indent))
			if !this.hasVariable(value) {
				fragments.push($code($variable.scope(this)))
				
				$variable.define(this.greatParent(), value, VariableKind::Variable)
			}
			fragments.push($code(value))
			fragments.push($equals)
			fragments.append(this._value.toFragments(indent))
			fragments.push($terminator)
			
			/* fragments.newLine().define(value, this.greatParent(), VariableKind::Variable).push(this._value.toFragments(indent)) */
		}
		
		if data.desc {
			if data.index && !data.declaration && this.greatParent().hasVariable(data.index.name) {
				fragments.push($indent(indent))
				fragments.append(this._index.toFragments(indent))
				fragments.push($equals)
				if value? {
					fragments.push($code(value))
				}
				else {
					fragments.append(this._value.toFragments(indent))
				}
				fragments.push($code('.length - 1;\n'))
				
				fragments.push($indent(indent), $code('for('))
			}
			else {
				index = this.acquireTempName() unless this._index?
				
				fragments.push($indent(indent), $code('for('), $code($variable.scope(this)))
				if index? {
					fragments.push($code(index))
				}
				else {
					fragments.append(this._index.toFragments(indent))
				}
				fragments.push($equals)
				if value? {
					fragments.push($code(value))
				}
				else {
					fragments.append(this._value.toFragments(indent))
				}
				fragments.push($code('.length - 1'))
			}
		}
		else {
			if data.index && !data.declaration && this.greatParent().hasVariable(data.index.name) {
				fragments.push($indent(indent))
				fragments.append(this._index.toFragments(indent))
				fragments.push($code(' = 0;\n'))
				
				fragments.push($indent(indent), $code('for('), $code($variable.scope(this)))
			}
			else {
				index = this.acquireTempName() unless this._index?
				
				fragments.push($indent(indent), $code('for('), $code($variable.scope(this)))
				if index? {
					fragments.push($code(index))
				}
				else {
					fragments.append(this._index.toFragments(indent))
				}
				fragments.push($code(' = 0, '))
			}
			
			bound = this.acquireTempName()
			
			fragments.push($code(bound), $equals)
			if value? {
				fragments.push($code(value))
			}
			else {
				fragments.append(this._value.toFragments(indent))
			}
			fragments.push($code('.length'))
		}
		
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			fragments.push($comma, $code(data.variable.name))
		}
		
		fragments.push($code('; '))
		
		if data.until {
			fragments.push($code('!('))
			
			fragments.append(this._until.toBooleanFragments(indent))
			
			fragments.push($code(') && '))
		}
		else if data.while {
			fragments.append(this._while.toBooleanFragments(indent))
			
			fragments.push($code(' && '))
		}
		
		if data.desc {
			if index? {
				fragments.push($code(index))
			}
			else {
				fragments.append(this._index.toFragments(indent))
			}
			fragments.push($code(' >= 0; --'))
			if index? {
				fragments.push($code(index))
			}
			else {
				fragments.append(this._index.toFragments(indent))
			}
			fragments.push($code(')'))
		}
		else {
			if index? {
				fragments.push($code(index))
			}
			else {
				fragments.append(this._index.toFragments(indent))
			}
			fragments.push($code(' < ' + bound + '; ++'))
			if index? {
				fragments.push($code(index))
			}
			else {
				fragments.append(this._index.toFragments(indent))
			}
			fragments.push($code(')'))
		}
		
		fragments.push($code(' {\n'))
		
		fragments.push($indent(indent + 1))
		fragments.append(this._variable.toFragments(indent + 1))
		fragments.push($equals)
		if value? {
			fragments.push($code(value))
		}
		else {
			fragments.append(this._value.toFragments(indent))
		}
		fragments.push($code('['))
		if index? {
			fragments.push($code(index))
		}
		else {
			fragments.append(this._index.toFragments(indent))
		}
		fragments.push($code('];\n'))
		
		if data.when {
			fragments.push($indent(indent + 1), $code('if('))
			fragments.append(this._when.toBooleanFragments(indent))
			fragments.push($code(') {\n'))
			
			fragments.append(this._body.toFragments(indent + 2))
			
			fragments.push($indent(indent + 1), $code('}\n'))
		}
		else {
			fragments.append(this._body.toFragments(indent + 1))
		}
		
		fragments.push($indent(indent), $code('}\n'))
		
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
	toStatementFragments(indent, fragments: Array) { // {{{
		let data = this._data
		
		let value
		if this._value.isComplex() {
			value = this.greatParent().acquireTempName()
			
			this.parent().updateTempNames()
			
			fragments.push($indent(indent))
			if !this.hasVariable(value) {
				fragments.push($code($variable.scope(this)))
				
				$variable.define(this.greatParent(), value, VariableKind::Variable)
			}
			fragments.push($code(value))
			fragments.push($equals)
			fragments.append(this._value.toFragments(indent))
			fragments.push($terminator)
		}
		
		fragments.push($indent(indent), $code('for('))
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			fragments.push($code($variable.scope(this)))
		}
		fragments.append(this._variable.toFragments(indent))
		fragments.push($code(' in '))
		if value? {
			fragments.push($code(value))
		}
		else {
			fragments.append(this._value.toFragments(indent))
		}
		fragments.push($code(') {\n'))
		
		if data.index {
			fragments.push($indent(indent + 1))
			
			if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
				fragments.push($code($variable.scope(this)))
			}
			
			fragments.append(this._index.toFragments(indent))
			fragments.push($equals)
			if value? {
				fragments.push($code(value))
			}
			else {
				fragments.append(this._value.toFragments(indent))
			}
			fragments.push($code('['))
			fragments.append(this._variable.toFragments(indent))
			fragments.push($code(']'), $terminator)
		}
		
		if data.until {
			fragments.push($indent(indent + 1), $code('if('))
			fragments.append(this._until.toBooleanFragments(indent))
			fragments.push($code(') {\n'))
			
			fragments.push($indent(indent + 2), $code('break;\n'))
			
			fragments.push($indent(indent + 1), $code('}\n'))
		}
		else if data.while {
			fragments.push($indent(indent + 1), $code('if(!('))
			fragments.append(this._while.toBooleanFragments(indent))
			fragments.push($code(')) {\n'))
			
			fragments.push($indent(indent + 2), $code('break;\n'))
			
			fragments.push($indent(indent + 1), $code('}\n'))
		}
		
		if data.when {
			fragments.push($indent(indent + 1), $code('if('))
			fragments.append(this._when.toBooleanFragments(indent))
			fragments.push($code(') {\n'))
			
			fragments.append(this._body.toFragments(indent + 2))
			
			fragments.push($indent(indent + 1), $code('}\n'))
		}
		else {
			fragments.append(this._body.toFragments(indent + 1))
		}
		
		fragments.push($indent(indent), $code('}\n'))
		
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
	toStatementFragments(indent, fragments: Array) { // {{{
		let data = this._data
		
		fragments.push($indent(indent), $code('for('))
		if data.declaration || !this.greatParent().hasVariable(data.variable.name) {
			fragments.push($code($variable.scope(this)))
		}
		fragments.append(this._variable.toFragments(indent))
		fragments.push($equals)
		fragments.append(this._from.toFragments(indent))
		
		let bound
		if this._to.isComplex() {
			bound = this.acquireTempName()
			
			fragments.push($code(bound), $equals)
			fragments.append(this._to.toFragments(indent))
		}
		
		let by
		if data.by && this._by.isComplex() {
			by = this.acquireTempName()
			
			fragments.push($comma, $code(by), $equals)
			fragments.append(this._by.toFragments(indent))
		}
		
		fragments.push($code('; '))
		
		if data.until {
			fragments.push($code('!('))
			
			fragments.append(this._until.toBooleanFragments(indent))
			
			fragments.push($code(') && '))
		}
		else if data.while {
			fragments.append(this._while.toBooleanFragments(indent))
			
			fragments.push($code(' && '))
		}
		
		fragments.append(this._variable.toFragments(indent))
		fragments.push($code(' <= '))
		
		if this._to.isComplex() {
			fragments.push($code(bound))
		}
		else {
			fragments.append(this._to.toFragments(indent))
		}
		
		fragments.push($code('; '))
		
		if data.by {
			if data.by.kind == Kind::NumericExpression {
				if data.by.value == 1 {
					fragments.push($code('++'))
					fragments.append(this._variable.toFragments(indent))
				}
				else {
					fragments.append(this._variable.toFragments(indent))
					fragments.push($code(' += '))
					fragments.append(this._by.toFragments(indent))
				}
			}
			else {
				fragments.append(this._variable.toFragments(indent))
				fragments.push($code(' += '))
				fragments.append(this._by.toFragments(indent))
			}
		}
		else {
			fragments.push($code('++'))
			fragments.append(this._variable.toFragments(indent))
		}
		
		fragments.push($code(') {\n'))
		
		if data.when {
			fragments.push($indent(indent + 1), $code('if('))
			fragments.append(this._when.toBooleanFragments(indent))
			fragments.push($code(') {\n'))
			
			fragments.append(this._body.toFragments(indent + 2))
			
			fragments.push($indent(indent + 1), $code('}\n'))
		}
		else {
			fragments.append(this._body.toFragments(indent + 1))
		}
		
		fragments.push($indent(indent), $code('}\n'))
		
		this.releaseTempName(bound) if bound?
		this.releaseTempName(by) if by?
	} // }}}
}


class FunctionDeclaration extends Statement {
	private {
		_body
		_parameters
	}
	FunctionDeclaration(data, parent) { // {{{
		super(data, parent)
		
		variable = $variable.define(this, data.name, VariableKind::Function, data.type)
		
		for modifier in data.modifiers {
			if modifier.kind == FunctionModifier::Async {
				variable.async = true
			}
		}
		
		if data.body.kind == Kind::Block {
			this._body = new FunctionScope(data.body, this)
		}
		else {
			this._body = new FunctionScope($return(data.body), this)
		}
		
		this._parameters = [new Parameter(parameter, this._body) for parameter in data.parameters]
		
		this._body.compile()
	} // }}}
	toStatementFragments(indent, fragments: Array) { // {{{
		fragments.push($indent(indent), $code('function ' + this._data.name.name + '('))
		
		$function.parameters(this, indent + 1, fragments, func() {
			fragments.push($code(') {\n'))
		})
		
		fragments.append(this._body.toFragments(indent + 1))
		
		fragments.push($indent(indent), $code('}\n'))
	} // }}}
}

class Parameter {
	private {
		_defaultValue = null
	}
	Parameter(data, parent) { // {{{
		if data.name? {
			$variable.define(parent, data.name, $variable.kind(data.type), data.type)
		}
		
		if data.defaultValue? {
			this._defaultValue = $compile.expression(data.defaultValue, parent)
		}
	} // }}}
}

class IfStatement extends Statement {
	private {
		_condition
		_then
	}
	IfStatement(data, parent) { // {{{
		super(data, parent)
		
		this._condition = $compile.expression(data.condition, this)
		this._then = $compile.expression(data.then, this)
	} // }}}
	toStatementFragments(indent, fragments: Array) { // {{{
		fragments.push($indent(indent), $code('if('))
		
		fragments.append(this._condition.toBooleanFragments(indent))
		
		fragments.push($code(') {\n'))
		
		fragments.append(this._then.toFragments(indent + 1))
		
		fragments.push($indent(indent), $code('}\n'))
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
	toStatementFragments(indent, fragments: Array) { // {{{
		if this._value? {
			fragments.push($indent(indent), $code('return '))
			
			fragments.append(this._value.toFragments(indent))
			
			fragments.push($terminator)
		}
		else {
			fragments.push($indent(indent), $code('return'), $terminator)
		}
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
	toStatementFragments(indent, fragments: Array) { // {{{
		if this._declarators.length == 1 {
			this._declarators[0].toFragments(indent, this._data.modifiers, fragments)
		}
		else {
			fragments.push($indent(indent), this.modifier(this._declarators[0]._data), $space)
			
			for declarator, index in this._declarators {
				fragments.push($comma) if index
				
				fragments.append(declarator._name.toFragments(indent))
			}
			
			fragments.push($terminator)
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
	toFragments(indent, modifier, fragments: Array) { // {{{
		fragments.push($indent(indent), this._parent.modifier(this._data), $space)
		
		fragments.append(this._name.toFragments(indent))
		
		if this._init {
			fragments.push($equals)
			
			fragments.append(this._init.toFragments(indent))
		}
		
		fragments.push($terminator)
	} // }}}
}
// }}}

// {{{ Expressions
class Expression extends Base {
	assignment(data, variable = false) {
		this._parent.statement().assignment(data, variable)
	}
	getRenamedVariable(name) { // {{{
		return this._parent.statement().getRenamedVariable(name)
	} // }}}
	isCallable() => false
	isComplex() => true
	isComputed() => false
	isConditional() => this.isNullable()
	isNullable() => false
	statement() => this._parent.statement()
	toBooleanFragments(indent) => this.toFragments(indent)
	toConditionalFragments(indent) => this.toFragments(indent)
	toReusableFragments(indent) => this.toFragments(indent)
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
	isComputed() => true
	isNullable() => this._right.isNullable()
	AssignmentOperatorExpression(data, parent) { // {{{
		super(data, parent)
		
		parent.assignment(data)
		
		this._left = $compile.expression(data.left, this)
		this._right = $compile.expression(data.right, this)
	} // }}}
	toConditionalFragments(indent) { // {{{
		return this._right.toConditionalFragments(indent)
	} // }}}
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.append(this._left.toFragments(indent))
		
		fragments.push($equals)
		
		fragments.append(this._right.toFragments(indent))
		
		return fragments
	} // }}}
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		if this._right.isNullable() {
			fragments.append(this._right.toConditionalFragments(indent))
			
			fragments.push($code(' && '))
			
			fragments.push($codeLoc($runtime.type(this) + '.isValue(', this._data.operator.start, this._data.operator.end))
			
			fragments.append(this._right.toFragments(indent))
			
			fragments.push($codeLoc(')', this._data.operator.start, this._data.operator.end))
		}
		else {
			fragments.push($codeLoc($runtime.type(this) + '.isValue(', this._data.operator.start, this._data.operator.end))
			
			fragments.append(this._right.toFragments(indent))
			
			fragments.push($codeLoc(')', this._data.operator.start, this._data.operator.end))
		}
		
		fragments.push($code(' ? '))
		
		fragments.append(this._left.toFragments(indent))
		
		fragments.push($equals)
		
		fragments.append(this._right.toFragments(indent))
		
		fragments.push($code(' : undefined'))
		
		return fragments
	} // }}}
	toBooleanFragments(indent) { // {{{
		let fragments: Array = []
		
		if this._right.isNullable() {
			fragments.append(this._right.toConditionalFragments(indent))
			
			fragments.push($code(' && '))
			
			fragments.push($codeLoc($runtime.type(this) + '.isValue(', this._data.operator.start, this._data.operator.end))
			
			fragments.append(this._right.toFragments(indent))
			
			fragments.push($codeLoc(')', this._data.operator.start, this._data.operator.end))
		}
		else {
			fragments.push($codeLoc($runtime.type(this) + '.isValue(', this._data.operator.start, this._data.operator.end))
			
			fragments.append(this._right.toFragments(indent))
			
			fragments.push($codeLoc(')', this._data.operator.start, this._data.operator.end))
		}
		
		fragments.push($code(' ? ('))
		
		fragments.append(this._left.toFragments(indent))
		
		fragments.push($equals)
		
		fragments.append(this._right.toFragments(indent))
		
		fragments.push($code(', true) : false'))
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.append(this._left.toFragments(indent))
		
		fragments.push($space)
		
		fragments.push($codeLoc('&&', this._data.operator.start, this._data.operator.end))
		
		fragments.push($space)
		
		fragments.append(this._right.toFragments(indent))
		
		return fragments
	} // }}}
}

class BinaryOperatorEquality extends BinaryOperatorExpression {
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.push($code('(')) if this._left.isComputed()
		fragments.append(this._left.toFragments(indent))
		fragments.push($code(')')) if this._left.isComputed()
		
		fragments.push($space)
		
		fragments.push($codeLoc('===', this._data.operator.start, this._data.operator.end))
		
		fragments.push($space)
		
		fragments.push($code('(')) if this._right.isComputed()
		fragments.append(this._right.toFragments(indent))
		fragments.push($code(')')) if this._right.isComputed()
		
		return fragments
	} // }}}
}

class BinaryOperatorGreaterThan extends BinaryOperatorExpression {
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.push($code('(')) if this._left.isComputed()
		fragments.append(this._left.toFragments(indent))
		fragments.push($code(')')) if this._left.isComputed()
		
		fragments.push($space)
		
		fragments.push($codeLoc('>', this._data.operator.start, this._data.operator.end))
		
		fragments.push($space)
		
		fragments.push($code('(')) if this._right.isComputed()
		fragments.append(this._right.toFragments(indent))
		fragments.push($code(')')) if this._right.isComputed()
		
		return fragments
	} // }}}
}

class BinaryOperatorInequality extends BinaryOperatorExpression {
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.push($code('(')) if this._left.isComputed()
		fragments.append(this._left.toFragments(indent))
		fragments.push($code(')')) if this._left.isComputed()
		
		fragments.push($space)
		
		fragments.push($codeLoc('!==', this._data.operator.start, this._data.operator.end))
		
		fragments.push($space)
		
		fragments.push($code('(')) if this._right.isComputed()
		fragments.append(this._right.toFragments(indent))
		fragments.push($code(')')) if this._right.isComputed()
		
		return fragments
	} // }}}
}

class BinaryOperatorModulo extends BinaryOperatorExpression {
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.append(this._left.toFragments(indent))
		
		fragments.push($space)
		
		fragments.push($codeLoc('%', this._data.operator.start, this._data.operator.end))
		
		fragments.push($space)
		
		fragments.append(this._right.toFragments(indent))
		
		return fragments
	} // }}}
}

class BinaryOperatorMultiplication extends BinaryOperatorExpression {
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.append(this._left.toFragments(indent))
		
		fragments.push($space)
		
		fragments.push($codeLoc('*', this._data.operator.start, this._data.operator.end))
		
		fragments.push($space)
		
		fragments.append(this._right.toFragments(indent))
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.push($code('['))
		
		for value, index in this._values {
			fragments.push($comma) if index
			
			fragments.append(value.toFragments(indent))
		}
		
		fragments.push($code(']'))
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		if this._tempName? {
			fragments.push(this._tempName)
		}
		else if this.isNullable() && !this._tested {
			fragments.append(this.toConditionalFragments(indent))
			
			fragments.push($code(' ? '))
			
			fragments.append(this._callee.toFragments(indent))
			
			fragments.push($code('('))
			
			for argument, index in this._arguments {
				fragments.push($comma) if index
				
				fragments.append(argument.toFragments(indent))
			}
			
			fragments.push($code(')'))
			
			fragments.push($code(' : undefined'))
		}
		else {
			fragments.append(this._callee.toFragments(indent))
			
			fragments.push($code('('))
			
			for argument, index in this._arguments {
				fragments.push($comma) if index
				
				fragments.append(argument.toFragments(indent))
			}
			
			fragments.push($code(')'))
		}
		
		return fragments
	} // }}}
	toConditionalFragments(indent) { // {{{
		let fragments: Array = []
		
		if !this._tested {
			this._tested = true
			
			if this._data.nullable {
				if this._callee.isNullable() {
					fragments.append(this._callee.toConditionalFragments(indent))
					
					fragments.push($code(' && '))
				}
				
				fragments.push($code($runtime.type(this) + '.isFunction('))
				
				fragments.append(this._callee.toReusableFragments(indent))
				
				fragments.push($code(')'))
			}
			else {
				if this._callee.isNullable() {
					fragments.append(this._callee.toConditionalFragments(indent))
				}
			}
		}
		
		return fragments
	} // }}}
	toReusableFragments(indent) { // {{{
		let fragments: Array = []
		
		this._tempName = $code('__ks_0')
		
		fragments.push(this._tempName)
		
		fragments.push($code(' = '))
		
		fragments.append(this._callee.toFragments(indent))
		
		fragments.push($code('('))
		
		for argument, index in this._arguments {
			fragments.push($comma) if index
			
			fragments.append(argument.toFragments(indent))
		}
		
		fragments.push($code(')'))
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		if this.isNullable() && !this._tested {
			fragments.append(this.toConditionalFragments(indent))
			
			fragments.push($code(' ? '))
			
			fragments.append(this._object.toFragments(indent))
			
			if this._data.computed {
				fragments.push($code('['))
				
				fragments.append(this._property.toFragments(indent))
				
				fragments.push($code('] : undefined'))
			}
			else {
				fragments.push($code($dot))
				
				fragments.append(this._property.toFragments(indent))
				
				fragments.push($code(' : undefined'))
			}
		}
		else {
			fragments.push($code('(')) if this._object.isComputed()
			
			fragments.append(this._object.toFragments(indent))
			
			fragments.push($code(')')) if this._object.isComputed()
			
			if this._data.computed {
				fragments.push($code('['))
				
				fragments.append(this._property.toFragments(indent))
				
				fragments.push($code(']'))
			}
			else {
				fragments.push($code($dot))
				
				fragments.append(this._property.toFragments(indent))
			}
		}
		
		return fragments
	} // }}}
	toBooleanFragments(indent) { // {{{
		let fragments: Array = []
		
		if this.isNullable() && !this._tested {
			if this._data.computed {
				throw new Error('Not Implemented')
			}
			else {
				fragments.append(this.toConditionalFragments(indent))
				
				fragments.push($code(' ? '))
				
				fragments.append(this._object.toFragments(indent))
				
				fragments.push($code($dot))
				
				fragments.append(this._property.toFragments(indent))
				
				fragments.push($code(' : false'))
			}
		}
		else {
			if this._data.computed {
				throw new Error('Not Implemented')
			}
			else {
				fragments.append(this._object.toFragments(indent))
				
				fragments.push($code($dot))
				
				fragments.append(this._property.toFragments(indent))
			}
		}
		
		return fragments
	} // }}}
	toConditionalFragments(indent) { // {{{
		let fragments: Array = []
		
		if !this._tested {
			this._tested = true
			
			let conditional = false
			
			if this._object.isNullable() {
				fragments.append(this._object.toConditionalFragments(indent))
				
				conditional = true
			}
			
			if this._data.nullable {
				fragments.push($code(' && ')) if conditional
				
				fragments.push($code($runtime.type(this) + '.isValue('))
				
				fragments.append(this._object.toReusableFragments(indent))
				
				fragments.push($code(')'))
				
				conditional = true
			}
			
			if this._data.computed && this._property.isNullable() {
				fragments.push($code(' && ')) if conditional
				
				fragments.append(this._property.toConditionalFragments(indent))
			}
		}
		
		return fragments
	} // }}}
	toReusableFragments(indent) { // {{{
		let fragments: Array = []
		
		if this._object.isCallable() {
			fragments.push($code('('))
			
			fragments.append(this._object.toReusableFragments(indent))
			
			fragments.push($code(', '))
			
			fragments.append(this._object.toFragments(indent))
			
			fragments.push($code($dot))
			
			fragments.append(this._property.toFragments(indent))
			
			fragments.push($code(')'))
		}
		else {
			fragments.append(this._object.toFragments(indent))
			
			fragments.push($code($dot))
			
			fragments.append(this._property.toFragments(indent))
		}
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		if this._properties.length {
			fragments.push($code('{\n'))
			
			for property, index in this._properties {
				fragments.push($code(',\n')) if index
				
				fragments.append(property.toFragments(indent + 1))
			}
			
			fragments.push($code('\n'), $indent(indent), $code('}'))
		}
		else {
			fragments.push($code('{}'))
		}
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		let data = this._data
		
		if data.name.kind == Kind::Identifier || data.name.kind == Kind::Literal {
			fragments.push($indent(indent))
			fragments.append(this._name.toFragments(indent))
			
			if data.value.kind == Kind::FunctionExpression {
				fragments.append(this._value.toFragments(indent))
			}
			else {
				fragments.push($code(': '))
				fragments.append(this._value.toFragments(indent + 1))
			}
		}
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.push($code('(')) if this._condition.isComputed()
		
		fragments.append(this._condition.toBooleanFragments(indent))
		
		fragments.push($code(')')) if this._condition.isComputed()
		
		fragments.push($code(' ? '))
		
		fragments.append(this._then.toFragments(indent))
		
		fragments.push($code(' : '))
		
		fragments.append(this._else.toFragments(indent))
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		for element, index in this._elements {
			fragments.push($code(' + ')) if index
			
			fragments.append(element.toFragments(indent))
		}
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		if this._argument.isNullable() {
			fragments.append(this._argument.toConditionalFragments(indent))
			
			fragments.push($code(' && '))
			
			fragments.push($codeLoc($runtime.type(this) + '.isValue(', this._data.operator.start, this._data.operator.end))
			
			fragments.append(this._argument.toFragments(indent))
			
			fragments.push($codeLoc(')', this._data.operator.start, this._data.operator.end))
		}
		else {
			fragments.push($codeLoc($runtime.type(this) + '.isValue(', this._data.operator.start, this._data.operator.end))
			
			fragments.append(this._argument.toFragments(indent))
			
			fragments.push($codeLoc(')', this._data.operator.start, this._data.operator.end))
		}
		
		return fragments
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
	toFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.push($codeLoc('!', this._data.operator.start, this._data.operator.end))
		
		fragments.append(this._argument.toFragments(indent))
		
		return fragments
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
	toFragments(indent) { // {{{
		if this._data {
			return [$codeLoc(this._value, this._data.start, this._data.end)]
		}
		else {
			return [$code(this._value)]
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
	toFragments(indent) { // {{{
		if this._isVariable {
			return [$codeLoc(this.getRenamedVariable(this._value), this._data.start, this._data.end)]
		}
		else {
			return [$codeLoc(this._value, this._data.start, this._data.end)]
		}
	} // }}}
	toConditionalFragments(indent) { // {{{
		let fragments: Array = []
		
		fragments.push($code($runtime.type(this) + '.isValue('))
		
		fragments.append(this.toFragments(indent))
		
		fragments.push($code(')'))
		
		return fragments
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
}

const $expressions = {
	`\(Kind::ArrayExpression)`				: ArrayExpression
	`\(Kind::Block)`						: func(data, parent) {
		if parent._options.variables == 'es6' {
			return new Scope(data, parent)
		}
		else {
			return new XScope(data, parent)
		}
	}
	`\(Kind::CallExpression)`				: CallExpression
	`\(Kind::Identifier)`					: IdentifierLiteral
	`\(Kind::Literal)`						: StringLiteral
	`\(Kind::MemberExpression)`				: MemberExpression
	`\(Kind::NumericExpression)`			: NumberLiteral
	`\(Kind::ObjectExpression)`				: ObjectExpression
	`\(Kind::ObjectMember)`					: ObjectMember
	`\(Kind::TemplateExpression)`			: TemplateExpression
	`\(Kind::TernaryConditionalExpression)`	: TernaryConditionalExpression
}

const $statements = {
	`\(Kind::ExternDeclaration)`			: ExternDeclaration
	`\(Kind::ForFromStatement)`				: ForFromStatement
	`\(Kind::ForInStatement)`				: ForInStatement
	`\(Kind::ForOfStatement)`				: ForOfStatement
	`\(Kind::ForRangeStatement)`			: ForRangeStatement
	`\(Kind::FunctionDeclaration)`			: FunctionDeclaration
	`\(Kind::IfStatement)`					: IfStatement
	`\(Kind::Module)`						: Module
	`\(Kind::ReturnStatement)`				: ReturnStatement
	`\(Kind::VariableDeclaration)`			: VariableDeclaration
	'default'								: ExpressionStatement
}

const $unaryOperators = {
	`\(UnaryOperator::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperator::Negation)`			: UnaryOperatorNegation
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
		
		this._module = new Class(parse(data), this._options.config)
		
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
		throw new Error('Not Implemented')
	} // }}}
	toSource() { // {{{
		let source = ''
		
		for fragment in this._fragments {
			source += fragment.code
		}
		
		return source
	} // }}}
	toSourceMap() { // {{{
		throw new Error('Not Implemented')
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