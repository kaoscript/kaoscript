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

extern console, Error, JSON, process, require

enum Mode {
	None
	Async
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
					return null unless (v ?= $variable.fromType(type, node)) && (v ?= $variable.filterMember(v, name, node))
					
					variables.push(v)
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
					return null unless (v ?= $variable.fromType(type, node)) && (v ?= $variable.filterMember(v, name, node))
					
					variables.push(v)
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
	directory() => this._parent.directory()
	file() => this._parent.file()
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

include {
	./include/util
	./include/fragment
	./include/scope
	./include/module
	./include/statement
	./include/expression
	./operator/assignment
	./operator/binary
	./operator/polyadic
	./operator/unary
}

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
	`\(Kind::BreakStatement)`				: BreakStatement
	`\(Kind::ClassDeclaration)`				: ClassDeclaration
	`\(Kind::ContinueStatement)`			: ContinueStatement
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
	`\(Kind::IncludeDeclaration)`			: IncludeDeclaration
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
		
		this._module = new Class(parse(data), this, this._file)
		
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