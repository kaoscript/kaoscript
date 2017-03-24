/**
 * compiler.ks
 * Version 0.8.0
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![error(off)]
#![runtime(type(alias='KSType'))]

import {
	*				from @kaoscript/ast
	* as fs			from ./fs.js
	* as metadata	from ../package.json
	parse			from @kaoscript/parser
	* as path		from path
}

extern console, JSON

include ./include/error

enum Mode {
	None
	Async
}

enum CalleeKind {
	ClassMethod
	InstanceMethod
	VariableProperty
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
	RegExp: 'RegExp'
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
		`\(BinaryOperatorKind::And)`: true
		`\(BinaryOperatorKind::Equality)`: true
		`\(BinaryOperatorKind::GreaterThan)`: true
		`\(BinaryOperatorKind::GreaterThanOrEqual)`: true
		`\(BinaryOperatorKind::Inequality)`: true
		`\(BinaryOperatorKind::LessThan)`: true
		`\(BinaryOperatorKind::LessThanOrEqual)`: true
		`\(BinaryOperatorKind::NullCoalescing)`: true
		`\(BinaryOperatorKind::Or)`: true
		`\(BinaryOperatorKind::TypeEquality)`: true
		`\(BinaryOperatorKind::TypeInequality)`: true
	}
	lefts: {
		`\(BinaryOperatorKind::Addition)`: true
		`\(BinaryOperatorKind::Assignment)`: true
	}
	numerics: {
		`\(BinaryOperatorKind::BitwiseAnd)`: true
		`\(BinaryOperatorKind::BitwiseLeftShift)`: true
		`\(BinaryOperatorKind::BitwiseOr)`: true
		`\(BinaryOperatorKind::BitwiseRightShift)`: true
		`\(BinaryOperatorKind::BitwiseXor)`: true
		`\(BinaryOperatorKind::Division)`: true
		`\(BinaryOperatorKind::Modulo)`: true
		`\(BinaryOperatorKind::Multiplication)`: true
		`\(BinaryOperatorKind::Subtraction)`: true
	}
} // }}}

const $targetRegex = /^(\w+)-v(\d+)(?:\.\d+)?(?:\.\d+)?$/

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
	Any: true
	Array: true
	Boolean: true
	Class: true
	Function: true
	NaN: true
	Number: true
	Object: true
	RegExp: true
	String: true
} // }}}

func $block(data) { // {{{
	return data if data.kind == NodeKind::Block
	
	return {
		kind: NodeKind::Block
		statements: [
			data
		]
	}
} // }}}

func $body(data?) { // {{{
	if !?data {
		return []
	}
	else if data.kind == NodeKind::Block {
		return data.statements
	}
	else {
		return [
			{
				kind: NodeKind::ReturnStatement
				value: data
			}
		]
	}
} // }}}

const $error = {
	isConsumed(error, name, variable, scope) { // {{{
		return true if error == name
		
		if variable.extends? {
			return error == name || $error.isConsumed(error, variable.extends, scope.getVariable(variable.extends), scope)
		}
		
		return false
	} // }}}
}

func $identifier(name) { // {{{
	if name is String {
		return {
			kind: NodeKind::Identifier
			name: name
		}
	}
	else {
		return name
	}
} // }}}

const $runtime = {
	helper(node) { // {{{
		node.module?().flag('Helper')
		
		return node._options.runtime.helper.alias
	} // }}}
	isDefined(name, node) { // {{{
		if node._options.runtime.helper.alias == name {
			node.module?().flag('Helper')
			
			return true
		}
		else if node._options.runtime.type.alias == name {
			node.module?().flag('Type')
			
			return true
		}
		else {
			return false
		}
	} // }}}
	type(node) { // {{{
		node.module?().flag('Type')
		
		return node._options.runtime.type.alias
	} // }}}
	typeof(type, node = null) { // {{{
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
	match(signature, methods) { // {{{
		for method in methods {
			return true if method.min == signature.min && method.max == signature.max && $signature.isMatchingParameters(method.parameters, signature.parameters)
		}
		
		return false
	} // }}}
	matchArguments(signature, arguments) { // {{{
		return false unless arguments.length >= signature.min && arguments.length <= signature.max
		
		
		
		return true
	} // }}}
	isMatchingParameters(p1, p2) { // {{{
		return false if p1.length != p2.length
		
		for i from 0 til p1.length {
			return false if p1[i].min != p2[i].min || p1[i].max != p2[i].max || p1[i].type != p2[i].type
		}
		
		return true
	} // }}}
	type(type = null, scope) { // {{{
		if type? {
			if type is String {
				return type
			}
			else if type.typeName? {
				if type.typeParameters? {
					let signature = {
						parameters: [$signature.type(item, scope) for item in type.typeParameters]
					}
					
					if $types[type.typeName.name] {
						signature.name = $types[type.typeName.name]
					}
					else if (variable ?= scope.getVariable(type.typeName.name)) && variable.kind == VariableKind::TypeAlias {
						signature.name = $signature.type(variable.type, scope)
					}
					else {
						signature.name = type.typeName.name
					}
					
					return signature
				}
				else {
					return $types[type.typeName.name] if $types[type.typeName.name]
					
					if (variable ?= scope.getVariable(type.typeName.name)) && variable.kind == VariableKind::TypeAlias {
						return $signature.type(variable.type, scope)
					}
					
					return type.typeName.name
				}
			}
			else if type.types? {
				let types = []
				
				for i from 0 til type.types.length {
					types.push($signature.type(type.types[i], scope))
				}
				
				return types
			}
			else {
				throw new Error('Not Implemented')
			}
		}
		else {
			return 'Any'
		}
	} // }}}
}

func $throw(message, node = null) ~ Error { // {{{
	let error = new Error(message)
	
	if node? {
		error.filename = node.file()
	}
	
	throw error
} // }}}

func $toInt(data, defaultValue) { // {{{
	switch data.kind {
		NodeKind::NumericExpression	=> return data.value
									=> return defaultValue
	}
} // }}}

const $type = {
	check(node, fragments, name, type) { // {{{
		if type.kind == NodeKind::TypeReference {
			type = $type.unalias(type, node.scope())
			
			if type.typeParameters {
				if $generics[type.typeName.name] || !$types[type.typeName.name] || $generics[$types[type.typeName.name]] {
					let tof = $runtime.typeof(type.typeName.name, node)
					
					if !tof && $types[type.typeName.name]? {
						tof = $runtime.typeof($types[type.typeName.name], node)
					}
					
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
					throw new NotSupportedException(node)
				}
			}
			else {
				let tof = $runtime.typeof(type.typeName.name, node)
				
				if !tof && $types[type.typeName.name]? {
					tof = $runtime.typeof($types[type.typeName.name], node)
				}
				
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
		else if type.types? {
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
			throw new NotImplementedException(node)
		}
	} // }}}
	compile(data, fragments) { // {{{
		switch(data.kind) {
			NodeKind::TypeReference => fragments.code($types[data.typeName.name] ?? data.typeName.name)
		}
	} // }}}
	fromAST(type = null) { // {{{
		return VariableKind::Variable	if !?type
		return VariableKind::Class		if type.kind == NodeKind::ClassDeclaration
		return VariableKind::Enum		if type.kind == NodeKind::EnumDeclaration
		return VariableKind::Function	if type.kind == NodeKind::FunctionExpression
		return VariableKind::Variable
	} // }}}
	isAny(type = null) { // {{{
		if !type {
			return true
		}
		
		if type.kind == NodeKind::TypeReference && type.typeName.kind == NodeKind::Identifier && (type.typeName.name == 'any' || type.typeName.name == 'Any') {
			return true
		}
		
		return false
	} // }}}
	reference(name) { // {{{
		if name is String {
			return {
				kind: NodeKind::TypeReference
				typeName: {
					kind: NodeKind::Identifier
					name: name
				}
			}
		}
		else if name.kind? {
			return {
				kind: NodeKind::TypeReference
				typeName: name
			}
		}
		else {
			return {
				kind: NodeKind::TypeReference
				typeName: {
					kind: NodeKind::Identifier
					name: name.name
				}
			}
		}
	} // }}}
	same(a, b) { // {{{
		return false if a.kind != b.kind
		
		if a.kind == NodeKind::TypeReference {
			return false if a.typeName.kind != b.typeName.kind
			
			if a.typeName.kind == NodeKind::Identifier {
				return false if a.typeName.name != b.typeName.name
			}
		}
		
		return true
	} // }}}
	toQuote(type) { // {{{
		if type is Array {
			if type.length == 1 {
				return `'\(type[0])'`
			}
			else {
				return `'\(type.slice(0, type.length - 1).join("', '"))' or '\(type[type.length - 1])'`
			}
		}
		else if type is String {
			return `'\(type)'`
		}
		else {
			return `'\(type.name)'`
		}
	} // }}}
	type(data?, scope, node) { // {{{
		//console.log('type.data', data)
		if !?data {
			return {
				typeName: {
					kind: NodeKind::Identifier
					name: 'Any'
				}
			}
		}
		else if !?data.kind {
			return data
		}
		
		let type = null
		
		switch data.kind {
			NodeKind::ArrayComprehension => {
				return {
					typeName: {
						kind: NodeKind::Identifier
						name: 'Array'
					}
				}
			}
			NodeKind::ArrayExpression => {
				return {
					typeName: {
						kind: NodeKind::Identifier
						name: 'Array'
					}
				}
			}
			NodeKind::ArrayRange => {
				return {
					typeName: {
						kind: NodeKind::Identifier
						name: 'Array'
					}
				}
			}
			NodeKind::BinaryExpression => {
				if data.operator.kind == BinaryOperatorKind::TypeCasting {
					return $type.type(data.right, scope, node)
				}
				else if $operator.binaries[data.operator.kind] {
					return {
						typeName: {
							kind: NodeKind::Identifier
							name: 'Boolean'
						}
					}
				}
				else if $operator.lefts[data.operator.kind] {
					return $type.type(data.left, scope, node)
				}
				else if $operator.numerics[data.operator.kind] {
					return {
						typeName: {
							kind: NodeKind::Identifier
							name: 'Number'
						}
					}
				}
			}
			NodeKind::CallExpression => {
				if (variable ?= $variable.fromAST(data, node)) && variable.type? {
					return variable.type
				}
			}
			NodeKind::CreateExpression => {
				return {
					typeName: data.class
				}
			}
			NodeKind::Identifier => {
				let variable = scope.getVariable(data.name)
				
				if variable && variable.type {
					return variable.type
				}
			}
			NodeKind::Literal => {
				return {
					typeName: {
						kind: NodeKind::Identifier
						name: $literalTypes[data.value] || 'String'
					}
				}
			}
			NodeKind::MemberExpression => {
				if (variable ?= $variable.fromAST(data, node)) && variable.type? {
					return variable.type
				}
			}
			NodeKind::NumericExpression => {
				return {
					typeName: {
						kind: NodeKind::Identifier
						name: 'Number'
					}
				}
			}
			NodeKind::ObjectExpression => {
				type = {
					typeName: {
						kind: NodeKind::Identifier
						name: 'Object'
					}
					properties: {}
				}
				
				let prop
				for property in data.properties {
					prop = {
						kind: $type.fromAST(property.value)
						name: property.name.name
					}
					
					if property.value.kind == NodeKind::FunctionExpression {
						prop.signature = $function.signature(property.value, node)
						
						if property.value.type {
							prop.type = $type.type(property.value.type, scope, node)
						}
					}
					
					type.properties[property.name.name] = prop
				}
			}
			NodeKind::RegularExpression => {
				return {
					typeName: {
						kind: NodeKind::Identifier
						name: 'RegExp'
					}
				}
			}
			NodeKind::Template => {
				return {
					typeName: {
						kind: NodeKind::Identifier
						name: 'String'
					}
				}
			}
			NodeKind::ThisExpression => {
				if (variable ?= $variable.fromAST(data, node)) && variable.type? {
					return variable.type
				}
			}
			NodeKind::TypeReference => {
				if data.typeName {
					if data.properties {
						type = {
							typeName: {
								kind: NodeKind::Identifier
								name: 'Object'
							}
							properties: {}
						}
						
						let prop
						for property in data.properties {
							prop = {
								kind: $type.fromAST(property.type)
								name: property.name.name
							}
							
							if property.type? {
								if property.type.kind == NodeKind::FunctionExpression {
									prop.signature = $function.signature(property.type, node)
									
									if property.type.type {
										prop.type = $type.type(property.type.type, scope, node)
									}
								}
								else {
									prop.type = $type.type(property.type, scope, node)
								}
							}
							
							type.properties[property.name.name] = prop
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
							type.typeParameters = [$type.type(parameter, scope, node) for parameter in data.typeParameters]
						}
					}
				}
			}
			NodeKind::UnionType => {
				return {
					types: [$type.type(type, scope, node) for type in data.types]
				}
			}
		}
		//console.log('type.type', type)
		
		return type
	} // }}}
	typeName(data) { // {{{
		if data.kind == NodeKind::Identifier {
			return {
				kind: NodeKind::Identifier
				name: data.name
			}
		}
		else {
			return {
				kind: NodeKind::MemberExpression
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
	define(node, scope, name, immutable, kind, type = null) { // {{{
		let variable
		
		if kind == VariableKind::Enum && (variable ?= scope.getVariable(name.name || name)) {
			if variable.kind == VariableKind::Enum {
				variable.new = false
			}
			else {
				SyntaxException.throwAlreadyDeclared(name.name || name, node)
			}
		}
		else if scope.hasVariable(name.name || name, false) {
			SyntaxException.throwAlreadyDeclared(name.name || name, node)
		}
		else {
			scope.addVariable(name.name || name, variable = {
				name: name,
				kind: kind,
				new: true
				immutable: immutable
			})
			
			if kind == VariableKind::Class {
				variable.constructors = []
				variable.destructors = 0
				variable.instanceVariables = {}
				variable.classVariables = {}
				variable.instanceMethods = {}
				variable.classMethods = {}
			}
			else if kind == VariableKind::Enum {
				if type {
					if type.typeName.name == 'string' || type.typeName.name == 'String' {
						variable.type = 'String'
					}
				}
				
				if !variable.type {
					variable.type = 'Number'
					variable.counter = -1
				}
			}
			else if kind == VariableKind::TypeAlias {
				variable.type = $type.type(type, scope, node)
			}
			else if kind == VariableKind::Function {
				variable.type ?= $type.type(type, scope, node) if type?
				
				variable.throws = []
			}
			else if kind == VariableKind::Variable && type? {
				variable.type ?= $type.type(type, scope, node)
			}
		}
		
		return variable
	} // }}}
	filterMember(variable, name, node) { // {{{
		//console.log('variable.filterMember.var', variable)
		//console.log('variable.filterMember.name', name)
		
		if variable.kind == VariableKind::Class {
			if variable.instanceMethods[name] is Array {
				let variables: Array = []
				
				for method in variable.instanceMethods[name] {
					if method.type? {
						$variable.push(variables, {
							kind: VariableKind::Variable
							type: method.type
						})
					}
					else {
						return null
					}
				}
				
				return variables[0]	if variables.length == 1
				return variables	if variables.length > 0
			}
			else if variable.instanceVariables[name] is Object {
				if variable.instanceVariables[name].type? {
					return {
						kind: VariableKind::Variable
						type: {
							kind: NodeKind::TypeReference
							typeName: {
								kind: NodeKind::Identifier
								name: variable.instanceVariables[name].type
							}
						}
					}
				}
			}
		}
		else if variable.kind == VariableKind::Enum {
			throw new NotImplementedException(node)
		}
		else if variable.kind == VariableKind::TypeAlias {
			if variable.type.types {
				let variables: Array = []
				
				for type in variable.type.types {
					return null unless (v ?= $variable.fromType(type, node)) && (v ?= $variable.filterMember(v, name, node))
					
					$variable.push(variables, v)
				}
				
				return variables[0]	if variables.length == 1
				return variables	if variables.length > 0
			}
			else {
				if variable.type.properties? {
					return variable.type.properties[name] if variable.type.properties[name] is Object
				}
				else {
					return $variable.filterMember(variable, name, node) if variable ?= $variable.fromType(variable.type, node)
				}
			}
		}
		else if variable.kind == VariableKind::Variable {
			throw new NotImplementedException(node)
		}
		else {
			throw new NotImplementedException(node)
		}
		
		return null
	} // }}}
	filterType(variable, name, node) { // {{{
		//console.log('variable.filterType.variable', variable)
		//console.log('variable.filterType.name', name)
		if variable.type? {
			if variable.type is String {
				if variable ?= $variable.fromType({typeName: $identifier(variable.type)}, node) {
					return $variable.filterMember(variable, name, node)
				}
			}
			else if variable.type.properties? {
				return variable.type.properties[name] if variable.type.properties[name] is Object
			}
			else if variable.type.typeName? {
				if variable ?= $variable.fromType(variable.type, node) {
					return $variable.filterMember(variable, name, node)
				}
			}
			else if variable.type.types? {
				let variables: Array = []
				
				for type in variable.type.types {
					return null unless (v ?= $variable.fromType(type, node)) && (v ?= $variable.filterMember(v, name, node))
					
					$variable.push(variables, v)
				}
				
				return variables[0]	if variables.length == 1
				return variables	if variables.length > 0
			}
			else if variable.type.parameters? {
				if variable ?= $variable.fromType({typeName: $identifier(variable.type.name)}, node) {
					return $variable.filterMember(variable, name, node)
				}
			}
			else {
				throw new NotImplementedException(node)
			}
		}
		
		return null
	} // }}}
	fromAST(data, node) { // {{{
		//console.log(data)
		switch data.kind {
			NodeKind::ArrayComprehension, NodeKind::ArrayExpression, NodeKind::ArrayRange => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: NodeKind::TypeReference
						typeName: {
							kind: NodeKind::Identifier
							name: 'Array'
						}
					}
				}
			}
			NodeKind::BinaryExpression => {
				if data.operator.kind == BinaryOperatorKind::TypeCasting {
					return {
						kind: VariableKind::Variable
						type: data.right
					}
				}
				else if $operator.binaries[data.operator.kind] {
					return {
						kind: VariableKind::Variable
						type: {
							kind: NodeKind::TypeReference
							typeName: {
								kind: NodeKind::Identifier
								name: 'Boolean'
							}
						}
					}
				}
				else if $operator.lefts[data.operator.kind] {
					let type = $type.type(data.left, node.scope(), node)
					
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
							kind: NodeKind::TypeReference
							typeName: {
								kind: NodeKind::Identifier
								name: 'Number'
							}
						}
					}
				}
			}
			NodeKind::CallExpression => {
				let variable = $variable.fromAST(data.callee, node)
				//console.log('getVariable.call.data', data)
				//console.log('getVariable.call.variable', variable)
				
				if variable? {
					if variable.kind == VariableKind::Class {
						return {
							kind: VariableKind::Variable
							type: {
								kind: NodeKind::TypeReference
								typeName: $identifier(variable.name)
							}
						}
					}
					else if variable.kind == VariableKind::Function || variable.kind == VariableKind::Variable {
						if variable.type? {
							return {
								kind: VariableKind::Variable
								type: variable.type
							}
						}
					}
					else {
						throw new NotImplementedException(node)
					}
				}
			}
			NodeKind::ConditionalExpression => {
				let a = $type.type(data.whenTrue, node.scope(), node)
				let b = $type.type(data.whenFalse, node.scope(), node)
				
				if a && b && $type.same(a, b) {
					return {
						kind: VariableKind::Variable
						type: a
					}
				}
			}
			NodeKind::CreateExpression => {
				if variable ?= $variable.fromAST(data.class, node) {
					return {
						kind: VariableKind::Variable
						type: {
							kind: NodeKind::TypeReference
							typeName: $identifier(variable.name)
						}
					}
				}
			}
			NodeKind::FunctionExpression => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: NodeKind::TypeReference
						typeName: {
							kind: NodeKind::Identifier
							name: 'Function'
						}
					}
				}
			}
			NodeKind::Identifier => {
				if $literalTypes[data.name] is String {
					return {
						kind: VariableKind::Variable
						type: {
							kind: NodeKind::TypeReference
							typeName: {
								kind: NodeKind::Identifier
								name: $literalTypes[data.name]
							}
						}
					}
				}
				else {
					return node.scope().getVariable(data.name)
				}
			}
			NodeKind::LambdaExpression => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: NodeKind::TypeReference
						typeName: {
							kind: NodeKind::Identifier
							name: 'Function'
						}
					}
				}
			}
			NodeKind::Literal => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: NodeKind::TypeReference
						typeName: {
							kind: NodeKind::Identifier
							name: 'String'
						}
					}
				}
			}
			NodeKind::MemberExpression => {
				let variable = $variable.fromAST(data.object, node)
				//console.log('getVariable.member.data', data)
				//console.log('getVariable.member.variable', variable)
				
				if variable? {
					if variable.kind == VariableKind::TypeAlias {
						variable = $variable.fromType($type.unalias(variable.type, node.scope()), node)
					}
					
					if data.computed {
						// if array
						if variable.type? && (variable ?= $variable.fromType(variable.type, node)) {
							// if generic
							if variable.type? && (variable ?= $variable.fromType(variable.type, node)) {
								return {
									kind: VariableKind::Variable
									type: {
										kind: NodeKind::TypeReference
										typeName: $identifier(variable.name)
									}
								}
							}
						}
					}
					else {
						let name = data.property.name
						
						if variable.kind == VariableKind::Class {
							if data.object.kind == NodeKind::Identifier {
								if variable.classMethods[name]? {
									let variables: Array = []
									
									for method in variable.classMethods[name] {
										if method.type? {
											if method.type is String {
												$variable.push(variables, {
													kind: VariableKind::Variable
													type: {
														kind: NodeKind::TypeReference
														typeName: $identifier(method.type)
													}
												})
											}
											else if method.type.typeName? {
												$variable.push(variables, {
													kind: VariableKind::Variable
													type: {
														kind: NodeKind::TypeReference
														typeName: method.type.typeName
													}
												})
											}
											else if method.type.name? {
												$variable.push(variables, {
													kind: VariableKind::Variable
													type: {
														kind: NodeKind::TypeReference
														typeName: $identifier(method.type.name)
													}
												})
											}
											else {
												return null
											}
										}
										else {
											return null
										}
									}
									
									return variables[0]	if variables.length == 1
									return variables	if variables.length > 0
								}
								else if variable.classVariables[name]? {
									return $variable.fromReflectType(variable.classVariables[name].type, node) if variable.classVariables[name].type?
								}
							}
							else {
								return $variable.filterMember(variable, name, node)
							}
						}
						else {
							return $variable.filterType(variable, name, node)
						}
					}
				}
			}
			NodeKind::NumericExpression => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: NodeKind::TypeReference
						typeName: {
							kind: NodeKind::Identifier
							name: 'Number'
						}
					}
				}
			}
			NodeKind::ObjectExpression => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: NodeKind::TypeReference
						typeName: {
							kind: NodeKind::Identifier
							name: 'Object'
						}
					}
				}
			}
			NodeKind::TemplateExpression => {
				return {
					kind: VariableKind::Variable
					type: {
						kind: NodeKind::TypeReference
						typeName: {
							kind: NodeKind::Identifier
							name: 'String'
						}
					}
				}
			}
			NodeKind::TypeReference => {
				if data.typeName {
					return node.scope().getVariable($types[data.typeName.name] || data.typeName.name)
				}
			}
		}
		
		return null
	} // }}}
	fromType(data, node) { // {{{
		//console.log('fromType', data)
		
		if data.typeName? {
			if data.typeName.kind == NodeKind::Identifier {
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
				
				if variable?.kind == VariableKind::Variable && variable.type?.properties? {
					let name = data.typeName.property.name
					
					let property = variable.type.properties[name]
					if property is Object {
						property.accessPath = (variable.accessPath || variable.name.name) + '.'
						
						return property
					}
				}
				else {
					throw new NotImplementedException(node)
				}
			}
		}
		
		return null
	} // }}}
	kind(type = null) { // {{{
		if type {
			switch type.kind {
				NodeKind::TypeReference => {
					if type.typeName {
						if type.typeName.kind == NodeKind::Identifier {
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
			Object.merge(variable.sealed.instanceMethods, importedVariable.sealed.instanceMethods)
			Object.merge(variable.sealed.classMethods, importedVariable.sealed.classMethods)
		}
		
		return variable
	} // }}}
	push(variables, variable) { // {{{
		let nf = true
		
		if variable.kind == VariableKind::Variable {
			if variable.type? {
				for v in variables while nf {
					nf = false if v.kind == VariableKind::Variable && v.type? && $type.same(variable.type, v.type)
				}
			}
		}
		else {
			$throw('Not implemented')
		}
		
		variables.push(variable) if nf
	} // }}}
	retype(node, scope, name, kind, type = null) { // {{{
		const variable = scope.getVariable(name.name || name)
		
		if kind == VariableKind::Variable {
			variable.type ?= $type.type(type, scope, node) if type?
		}
		else if kind == VariableKind::Function {
			variable.kind = kind
			variable.type ?= $type.type(type, scope, node) if type?
			
			variable.throws = []
		}
		else if kind == VariableKind::Class {
			variable.kind = kind
			variable.constructors = []
			variable.destructors = 0
			variable.instanceVariables = {}
			variable.classVariables = {}
			variable.instanceMethods = {}
			variable.classMethods = {}
			
			delete variable.type
		}
		else {
			throw new NotImplementedException(node)
		}
	} // }}}
	scope(node) { // {{{
		return node._options.format.variables == 'es5' ? 'var ' : 'let '
	} // }}}
}

abstract class AbstractNode {
	private {
		_data
		_options
		_parent = null
		_reference
		_scope = null
	}
	constructor()
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		@options = parent._options
	} // }}}
	abstract analyse()
	abstract prepare()
	abstract translate()
	directory() => this._parent.directory()
	file() => this._parent.file()
	greatParent() => this._parent?._parent
	greatScope() => this._parent?._scope
	isConsumedError(name, variable): Boolean => @parent.isConsumedError(name, variable)
	module() => this._parent.module()
	newScope() { // {{{
		if this._options.format.variables == 'es6' {
			return new Scope(this._scope)
		}
		else {
			return new XScope(this._scope)
		}
	} // }}}
	newScope(scope) { // {{{
		if this._options.format.variables == 'es6' {
			return new Scope(scope)
		}
		else {
			return new XScope(scope)
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
	./include/attribute
	./include/fragment
	./include/scope
	./include/module
	./include/sealed
	./include/statement
	./include/expression
	./operator/assignment
	./operator/binary
	./operator/polyadic
	./operator/unary
}

const $compile = {
	expression(data, parent, scope = parent.scope()) { // {{{
		let expression
		
		let clazz = $expressions[data.kind]
		if clazz? {
			expression = clazz is Class ? new clazz(data, parent, scope) : clazz(data, parent, scope)
		}
		else if data.kind == NodeKind::BinaryExpression {
			if clazz ?= $binaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else if data.operator.kind == BinaryOperatorKind::Assignment {
				if clazz = $assignmentOperators[data.operator.assignment] {
					expression = new clazz(data, parent, scope)
				}
				else {
					throw new NotSupportedException(`Unexpected assignment operator \(data.operator.assignment)`, parent)
				}
			}
			else {
				throw new NotSupportedException(`Unexpected binary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::PolyadicExpression {
			if clazz ?= $polyadicOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected polyadic operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::UnaryExpression {
			if clazz ?= $unaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected assignment operator \(data.operator.kind)`, parent)
			}
		}
		else {
			throw new NotSupportedException(`Unexpected assignment operator \(data.kind)`, parent)
		}
		
		return expression
	} // }}}
	statement(data, parent) { // {{{
		if Attribute.conditional(data, parent.module()._compiler._target) {
			let clazz = $statements[data.kind] ?? $statements.default
			
			return new clazz(data, parent)
		}
		else {
			return null
		}
	} // }}}
}

const $assignmentOperators = {
	`\(AssignmentOperatorKind::Addition)`			: AssignmentOperatorAddition
	`\(AssignmentOperatorKind::BitwiseAnd)`			: AssignmentOperatorBitwiseAnd
	`\(AssignmentOperatorKind::BitwiseLeftShift)`	: AssignmentOperatorBitwiseLeftShift
	`\(AssignmentOperatorKind::BitwiseOr)`			: AssignmentOperatorBitwiseOr
	`\(AssignmentOperatorKind::BitwiseRightShift)`	: AssignmentOperatorBitwiseRightShift
	`\(AssignmentOperatorKind::BitwiseXor)`			: AssignmentOperatorBitwiseXor
	`\(AssignmentOperatorKind::Equality)`			: AssignmentOperatorEquality
	`\(AssignmentOperatorKind::Existential)`		: AssignmentOperatorExistential
	`\(AssignmentOperatorKind::Modulo)`				: AssignmentOperatorModulo
	`\(AssignmentOperatorKind::Multiplication)`		: AssignmentOperatorMultiplication
	`\(AssignmentOperatorKind::NonExistential)`		: AssignmentOperatorNonExistential
	`\(AssignmentOperatorKind::NullCoalescing)`		: AssignmentOperatorNullCoalescing
	`\(AssignmentOperatorKind::Subtraction)`		: AssignmentOperatorSubtraction
}

const $binaryOperators = {
	`\(BinaryOperatorKind::Addition)`			: BinaryOperatorAddition
	`\(BinaryOperatorKind::And)`				: BinaryOperatorAnd
	`\(BinaryOperatorKind::BitwiseAnd)`			: BinaryOperatorBitwiseAnd
	`\(BinaryOperatorKind::BitwiseLeftShift)`	: BinaryOperatorBitwiseLeftShift
	`\(BinaryOperatorKind::BitwiseOr)`			: BinaryOperatorBitwiseOr
	`\(BinaryOperatorKind::BitwiseRightShift)`	: BinaryOperatorBitwiseRightShift
	`\(BinaryOperatorKind::BitwiseXor)`			: BinaryOperatorBitwiseXor
	`\(BinaryOperatorKind::Division)`			: BinaryOperatorDivision
	`\(BinaryOperatorKind::Equality)`			: BinaryOperatorEquality
	`\(BinaryOperatorKind::GreaterThan)`		: BinaryOperatorGreaterThan
	`\(BinaryOperatorKind::GreaterThanOrEqual)`	: BinaryOperatorGreaterThanOrEqual
	`\(BinaryOperatorKind::Inequality)`			: BinaryOperatorInequality
	`\(BinaryOperatorKind::LessThan)`			: BinaryOperatorLessThan
	`\(BinaryOperatorKind::LessThanOrEqual)`	: BinaryOperatorLessThanOrEqual
	`\(BinaryOperatorKind::Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperatorKind::Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: BinaryOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: BinaryOperatorOr
	`\(BinaryOperatorKind::Subtraction)`		: BinaryOperatorSubtraction
	`\(BinaryOperatorKind::TypeCasting)`		: BinaryOperatorTypeCasting
	`\(BinaryOperatorKind::TypeEquality)`		: BinaryOperatorTypeEquality
	`\(BinaryOperatorKind::TypeInequality)`		: BinaryOperatorTypeInequality
}

const $expressions = {
	`\(NodeKind::ArrayBinding)`					: ArrayBinding
	`\(NodeKind::ArrayComprehension)`			: func(data, parent, scope) {
		if data.loop.kind == NodeKind::ForFromStatement {
			return new ArrayComprehensionForFrom(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForInStatement {
			return new ArrayComprehensionForIn(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForOfStatement {
			return new ArrayComprehensionForOf(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForRangeStatement {
			return new ArrayComprehensionForRange(data, parent, scope)
		}
		else {
			throw new NotSupportedException(parent, `Unexpected kind \(data.loop.kind)`)
		}
	}
	`\(NodeKind::ArrayExpression)`				: ArrayExpression
	`\(NodeKind::ArrayRange)`					: ArrayRange
	`\(NodeKind::BindingElement)`				: BindingElement
	`\(NodeKind::Block)`						: BlockExpression
	`\(NodeKind::CallExpression)`				: CallExpression
	`\(NodeKind::ConditionalExpression)`		: ConditionalExpression
	`\(NodeKind::CreateExpression)`				: CreateExpression
	`\(NodeKind::CurryExpression)`				: CurryExpression
	`\(NodeKind::EnumExpression)`				: EnumExpression
	`\(NodeKind::FunctionExpression)`			: FunctionExpression
	`\(NodeKind::Identifier)`					: IdentifierLiteral
	`\(NodeKind::IfExpression)`					: IfExpression
	`\(NodeKind::LambdaExpression)`				: LambdaExpression
	`\(NodeKind::Literal)`						: StringLiteral
	`\(NodeKind::MemberExpression)`				: MemberExpression
	`\(NodeKind::NumericExpression)`			: NumberLiteral
	`\(NodeKind::ObjectBinding)`				: ObjectBinding
	`\(NodeKind::ObjectExpression)`				: ObjectExpression
	`\(NodeKind::ObjectMember)`					: ObjectMember
	`\(NodeKind::OmittedExpression)`			: OmittedExpression
	`\(NodeKind::RegularExpression)`			: RegularExpression
	`\(NodeKind::SequenceExpression)`			: SequenceExpression
	`\(NodeKind::TemplateExpression)`			: TemplateExpression
	`\(NodeKind::ThisExpression)`				: ThisExpression
	`\(NodeKind::UnlessExpression)`				: UnlessExpression
}

const $statements = {
	`\(NodeKind::BreakStatement)`				: BreakStatement
	`\(NodeKind::ClassDeclaration)`				: ClassDeclaration
	`\(NodeKind::ContinueStatement)`			: ContinueStatement
	`\(NodeKind::DestroyStatement)`				: DestroyStatement
	`\(NodeKind::DoUntilStatement)`				: DoUntilStatement
	`\(NodeKind::DoWhileStatement)`				: DoWhileStatement
	`\(NodeKind::EnumDeclaration)`				: EnumDeclaration
	`\(NodeKind::ExportDeclaration)`			: ExportDeclaration
	`\(NodeKind::ExternDeclaration)`			: ExternDeclaration
	`\(NodeKind::ExternOrRequireDeclaration)`	: ExternOrRequireDeclaration
	`\(NodeKind::ForFromStatement)`				: ForFromStatement
	`\(NodeKind::ForInStatement)`				: ForInStatement
	`\(NodeKind::ForOfStatement)`				: ForOfStatement
	`\(NodeKind::ForRangeStatement)`			: ForRangeStatement
	`\(NodeKind::FunctionDeclaration)`			: FunctionDeclaration
	`\(NodeKind::IfStatement)`					: IfStatement
	`\(NodeKind::ImplementDeclaration)`			: ImplementDeclaration
	`\(NodeKind::ImportDeclaration)`			: ImportDeclaration
	`\(NodeKind::IncludeDeclaration)`			: IncludeDeclaration
	`\(NodeKind::IncludeOnceDeclaration)`		: IncludeOnceDeclaration
	`\(NodeKind::RequireDeclaration)`			: RequireDeclaration
	`\(NodeKind::RequireOrExternDeclaration)`	: RequireOrExternDeclaration
	`\(NodeKind::RequireOrImportDeclaration)`	: RequireOrImportDeclaration
	`\(NodeKind::ReturnStatement)`				: ReturnStatement
	`\(NodeKind::SwitchStatement)`				: SwitchStatement
	`\(NodeKind::ThrowStatement)`				: ThrowStatement
	`\(NodeKind::TryStatement)`					: TryStatement
	`\(NodeKind::TypeAliasDeclaration)`			: TypeAliasDeclaration
	`\(NodeKind::UnlessStatement)`				: UnlessStatement
	`\(NodeKind::UntilStatement)`				: UntilStatement
	`\(NodeKind::VariableDeclaration)`			: VariableDeclaration
	`\(NodeKind::WhileStatement)`				: WhileStatement
	`default`									: ExpressionStatement
}

const $polyadicOperators = {
	`\(BinaryOperatorKind::Addition)`			: PolyadicOperatorAddition
	`\(BinaryOperatorKind::And)`				: PolyadicOperatorAnd
	`\(BinaryOperatorKind::BitwiseAnd)`			: PolyadicOperatorBitwiseAnd
	`\(BinaryOperatorKind::BitwiseLeftShift)`	: PolyadicOperatorBitwiseLeftShift
	`\(BinaryOperatorKind::BitwiseOr)`			: PolyadicOperatorBitwiseOr
	`\(BinaryOperatorKind::BitwiseRightShift)`	: PolyadicOperatorBitwiseRightShift
	`\(BinaryOperatorKind::BitwiseXor)`			: PolyadicOperatorBitwiseXor
	`\(BinaryOperatorKind::Division)`			: PolyadicOperatorDivision
	`\(BinaryOperatorKind::Equality)`			: PolyadicOperatorEquality
	`\(BinaryOperatorKind::GreaterThan)`		: PolyadicOperatorGreaterThan
	`\(BinaryOperatorKind::GreaterThanOrEqual)`	: PolyadicOperatorGreaterThanOrEqual
	`\(BinaryOperatorKind::LessThan)`			: PolyadicOperatorLessThan
	`\(BinaryOperatorKind::LessThanOrEqual)`	: PolyadicOperatorLessThanOrEqual
	`\(BinaryOperatorKind::Modulo)`				: PolyadicOperatorModulo
	`\(BinaryOperatorKind::Multiplication)`		: PolyadicOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: PolyadicOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: PolyadicOperatorOr
	`\(BinaryOperatorKind::Subtraction)`		: PolyadicOperatorSubtraction
}

const $unaryOperators = {
	`\(UnaryOperatorKind::BitwiseNot)`			: UnaryOperatorBitwiseNot
	`\(UnaryOperatorKind::DecrementPostfix)`	: UnaryOperatorDecrementPostfix
	`\(UnaryOperatorKind::DecrementPrefix)`		: UnaryOperatorDecrementPrefix
	`\(UnaryOperatorKind::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperatorKind::IncrementPostfix)`	: UnaryOperatorIncrementPostfix
	`\(UnaryOperatorKind::IncrementPrefix)`		: UnaryOperatorIncrementPrefix
	`\(UnaryOperatorKind::Negation)`			: UnaryOperatorNegation
	`\(UnaryOperatorKind::Negative)`			: UnaryOperatorNegative
}

const $targets = {
	ecma: { // {{{
		'5': {
			format: {
				classes: 'es5'
				destructuring: 'es5'
				functions: 'es5'
				parameters: 'es5'
				spreads: 'es5'
				variables: 'es5'
			}
		}
		'6': {
			format: {
				classes: 'es6'
				destructuring: 'es6'
				functions: 'es6'
				parameters: 'es6'
				spreads: 'es6'
				variables: 'es6'
			}
		}
	} // }}}
}

export class Compiler {
	private {
		_file: String
		_fragments
		_hashes
		_module
		_options
		_target
	}
	static {
		registerTarget(target, options) { // {{{
			if target !?= $targetRegex.exec(target) {
				throw new Error(`Invalid target syntax: \(target)`)
			}
			
			$targets[target[1]] ??= {}
			$targets[target[1]][target[2]] = options
		} // }}}
		registerTargets(targets) { // {{{
			for name, data of targets {
				if data is String {
					Compiler.registerTargetAlias(name, data)
				}
				else {
					Compiler.registerTarget(name, data)
				}
			}
		} // }}}
		registerTargetAlias(target, alias) { // {{{
			if target !?= $targetRegex.exec(target) {
				throw new Error(`Invalid target syntax: \(target)`)
			}
			if alias !?= $targetRegex.exec(alias) {
				throw new Error(`Invalid target syntax: \(alias)`)
			}
			
			if !?$targets[alias[1]] {
				throw new Error(`Undefined target '\(alias[1])'`)
			}
			else if !?$targets[alias[1]][alias[2]] {
				throw new Error(`Undefined target's version '\(alias[2])'`)
			}
			
			$targets[target[1]] ??= {}
			$targets[target[1]][target[2]] = $targets[alias[1]][alias[2]]
		} // }}}
	}
	constructor(@file, options = null, @hashes = {}) { // {{{
		@options = Object.merge({
			target: 'ecma-v6'
			register: true
			config: {
				header: true
				error: {
					level: 'fatal'
					ignore: []
					raise: []
				}
				parse: {
					parameters: 'kaoscript'
				}
				format: {}
				runtime: {
					helper: {
						alias: 'Helper'
						member: 'Helper'
						package: '@kaoscript/runtime'
					}
					type: {
						alias: 'Type'
						member: 'Type'
						package: '@kaoscript/runtime'
					}
				}
			}
		}, options)
		
		if target !?= $targetRegex.exec(@options.target) {
			throw new Error(`Invalid target syntax: \(@options.target)`)
		}
		
		@target = {
			name: target[1],
			version: target[2]
		}
		
		if !?$targets[@target.name] {
			throw new Error(`Undefined target '\(@target.name)'`)
		}
		else if !?$targets[@target.name][@target.version] {
			throw new Error(`Undefined target's version '\(@target.version)'`)
		}
		
		@options.target = `\(@target.name)-v\(@target.version)`
		
		@options.config = Object.defaults($targets[@target.name][@target.version], @options.config)
	} // }}}
	compile(data = null) { // {{{
		//console.time('parse')
		@module = new Module(data ?? fs.readFile(@file), this, @file)
		//console.timeEnd('parse')
		
		//console.time('compile')
		@module.compile()
		//console.timeEnd('compile')
		
		//console.time('toFragments')
		@fragments = @module.toFragments()
		//console.timeEnd('toFragments')
		
		return this
	} // }}}
	createServant(file) { // {{{
		return new Compiler(file, {
			config: @options.config
			register: false
			target: @options.target
		}, @hashes)
	} // }}}
	readFile() => fs.readFile(@file)
	sha256(file, data = null) { // {{{
		return this._hashes[file] ?? (this._hashes[file] = fs.sha256(data ?? fs.readFile(file)))
	} // }}}
	toHashes() { // {{{
		return this._module.toHashes()
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
		fs.mkdir(path.dirname(this._file))
		
		fs.writeFile(getBinaryPath(this._file, this._options.target), this.toSource())
		
		if !this._module._binary {
			let metadata = this.toMetadata()
			
			fs.writeFile(getMetadataPath(this._file, this._options.target), JSON.stringify(metadata))
		}
		
		fs.writeFile(getHashPath(this._file, this._options.target), JSON.stringify(this._module.toHashes()))
	} // }}}
	writeOutput() { // {{{
		if !this._options.output {
			throw new Error('Undefined option: output')
		}
		
		fs.mkdir(this._options.output)
		
		let filename = path.join(this._options.output, path.basename(this._file)).slice(0, -3) + '.js'
		
		fs.writeFile(filename, this.toSource())
		
		return this
	} // }}}
}

export func compileFile(file, options = null) { // {{{
	let compiler = new Compiler(file, options)
	
	return compiler.compile().toSource()
} // }}}

export func getBinaryPath(file, target) => fs.hidden(file, target, $extensions.binary)

export func getHashPath(file, target) => fs.hidden(file, target, $extensions.hash)

export func getMetadataPath(file, target) => fs.hidden(file, target, $extensions.metadata)

export func isUpToDate(file, target, source) { // {{{
	let hashes
	try {
		hashes = JSON.parse(fs.readFile(getHashPath(file, target)))
	}
	catch {
		return false
	}
	
	let root = path.dirname(file)
	
	for name, hash of hashes {
		if name == '.' {
			return null if fs.sha256(source) != hash
		}
		else {
			return null if fs.sha256(fs.readFile(path.join(root, name))) != hash
		}
	}
	
	return true
} // }}}

export $extensions as extensions