extern Buffer, console, JSON, parseInt

var $extensions = { # {{{
	binary: '.ksb',
	exports: '.kse',
	hash: '.ksh',
	requirements: '.ksr',
	source: '.ks'
} # }}}

namespace $ast {
	func block(data) { # {{{
		if data.kind == AstKind.Block {
			return data
		}
		else {
			return {
				kind: AstKind.Block
				statements: [data]
				start: data.start
				end: data.end
			}
		}
	} # }}}
	func body(data?) { # {{{
		if !?data.body {
			return {
				kind: AstKind.Block
				statements: []
				start: data.start
				end: data.end
			}
		}
		else if data.body.kind == AstKind.Block || data.body.kind == AstKind.ReturnStatement {
			return data.body
		}
		else if data.body.kind == AstKind.IfStatement || data.body.kind == AstKind.UnlessStatement {
			return {
				kind: AstKind.Block
				statements: [data.body]
				start: data.body.start
				end: data.body.end
			}
		}
		else {
			return {
				kind: AstKind.ReturnStatement
				value: data.body
				start: data.body.start
				end: data.body.end
			}
		}
	} # }}}
	func call(callee, arguments = []) { # {{{
		return {
			kind: AstKind.CallExpression
			modifiers: []
			scope: { kind: ScopeKind.This }
			callee
			arguments
			start: callee.start
			end: callee.end
		}
	} # }}}
	func hasModifier(data, target: ModifierKind): Boolean { # {{{
		for var modifier in data.modifiers {
			if modifier.kind == target {
				return true
			}
		}

		return false
	} # }}}
	func identifier(name) { # {{{
		if name is String {
			return {
				kind: AstKind.Identifier
				name: name
			}
		}
		else {
			return name
		}
	} # }}}
	func isThisField(name: String, data): Boolean { # {{{
		match data.kind {
			AstKind.ThisExpression {
				return data.name.name == name
			}
			AstKind.MemberExpression {
				return data.object.kind == AstKind.Identifier && data.object.name == 'this' && data.property.kind == AstKind.Identifier && (data.property.name == name || data.property.name == `_\(name)`)
			}
		}

		return false
	} # }}}
	func parameter() { # {{{
		return {
			kind: AstKind.Parameter
			attributes: []
			modifiers: []
		}
	} # }}}
	func path(data): String? { # {{{
		match data.kind {
			AstKind.Identifier {
				return data.name
			}
			AstKind.MemberExpression {
				if data.property.kind == AstKind.Identifier {
					if var object ?= $ast.path(data.object) {
						return `\(object).\(data.property.name)`
					}
				}
			}
		}

		return null
	} # }}}
	func return(data? = null) { # {{{
		return {
			kind: AstKind.ReturnStatement
			value: data
			start: data.start if ?data
		}
	} # }}}
	func some(data, filter): Boolean { # {{{
		match data.kind {
			AstKind.BinaryExpression {
				if filter(data.left) || filter(data.right) || $ast.some(data.left, filter) || $ast.some(data.right, filter) {
					return true
				}
			}
			AstKind.CallExpression {
				for var argument in data.arguments {
					if filter(argument) || $ast.some(argument, filter) {
						return true
					}
				}
			}
		}

		return false
	} # }}}
	func toIMString(data) { # {{{
		var mut object = data
		var mut property = ''

		while object.kind == AstKind.MemberExpression {
			property = `.\(object.property.name)\(property)`

			object = object.object
		}

		return `\(object.name)\(property)`
	} # }}}
	func topicReference() { # {{{
		return {
			kind: AstKind.TopicReference
			modifiers: []
		}
	} # }}}

	export *
}

namespace $compile {
	func block(data, parent, scope = parent.scope()) => Block.new($ast.block(data), parent, scope)
	func expression(data, parent, scope = parent.scope()) { # {{{
		var dyn result

		if var clazz ?= $expressions[data.kind] {
			result = if clazz is Class set clazz.new(data, parent, scope) else clazz(data, parent, scope)
		}
		else if data.kind == AstKind.BinaryExpression {
			if data.operator.kind == BinaryOperatorKind.Assignment {
				if var clazz ?= $assignmentOperators[data.operator.assignment] {
					result = clazz.new(data, parent, scope)
				}
				else {
					throw NotSupportedException.new(`Unexpected assignment operator \(data.operator.assignment)`, parent)
				}
			}
			else if var clazz ?= $binaryOperators[data.operator.kind] {
				result = clazz.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected binary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == AstKind.PolyadicExpression {
			if var clazz ?= $polyadicOperators[data.operator.kind] {
				result = clazz.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected polyadic operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == AstKind.UnaryExpression {
			if var clazz ?= $unaryOperators[data.operator.kind] {
				result = clazz.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected unary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == AstKind.JunctionExpression {
			throw NotSupportedException.new(`Unexpected junction expression`, parent)
		}
		else {
			throw NotSupportedException.new(`Unexpected expression/statement \(data.kind)`, parent)
		}

		return result
	} # }}}
	func function(data, parent, scope = parent.scope()) => FunctionBlock.new($ast.block(data), parent, scope)
	func statement(data, parent, scope = parent.scope()) { # {{{
		if Attribute.conditional(data, parent) {
			if data.kind == AstKind.ExpressionStatement {
				match data.expression.kind {
					AstKind.CallExpression {
						return Syntime.callStatement(data, parent, scope)
					}
					AstKind.SyntimeCallExpression {
						return Syntime.callSyntimeExpression(data.expression, parent, scope, true)
					}
					AstKind.SyntimeExpression {
						return Syntime.SyntimeStatement.new(data.expression, parent, scope)
					}
					else {
						return ExpressionStatement.new(data, parent, scope)
					}
				}
			}
			else if var class ?= $statements[data.kind] {
				return class.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected statement \(data.kind)`, parent)
			}
		}
		else {
			return null
		}
	} # }}}

	export *
}

namespace $runtime {
	func getVariable(name, node) { # {{{
		if node._options.runtime.object.alias == name || (node.isIncluded() && name == 'Object') {
			node.module?().flag('Object')

			return node._options.runtime.object.alias
		}
		else if node._options.runtime.helper.alias == name || (node.isIncluded() && name == 'Helper') {
			node.module?().flag('Helper')

			return node._options.runtime.helper.alias
		}
		else if node._options.runtime.type.alias == name || (node.isIncluded() && name == 'Type') {
			node.module?().flag('Type')

			return node._options.runtime.type.alias
		}
		else {
			return null
		}
	} # }}}
	func helper(node) { # {{{
		node.module?().flag('Helper')

		return node._options.runtime.helper.alias
	} # }}}
	func immutableScope(node) { # {{{
		return if node._options.format.variables == 'es5' set 'var ' else 'const '
	} # }}}
	func initFlag(node) { # {{{
		node.module?().flag('initFlag')

		return node._options.runtime.initFlag.alias
	} # }}}
	func object(node) { # {{{
		node.module?().flag('Object')

		return node._options.runtime.object.alias
	} # }}}
	func operator(node) { # {{{
		node.module?().flag('Operator')

		return node._options.runtime.operator.alias
	} # }}}
	func scope(node) { # {{{
		return if node._options.format.variables == 'es5' set 'var ' else 'let '
	} # }}}
	func scope(immutable: Boolean, node) { # {{{
		if immutable {
			return if node._options.format.variables == 'es5' set 'var ' else 'const '
		}
		else {
			return if node._options.format.variables == 'es5' set 'var ' else 'let '
		}
	} # }}}
	func type(node) { # {{{
		node.module?().flag('Type')

		return node._options.runtime.type.alias
	} # }}}
	func typeof(type % name, node? = null) { # {{{
		if ?node {
			if $typeofs[name] {
				return $runtime.type(node) + '.is' + name
			}
			else {
				return null
			}
		}
		else {
			return $typeofs[name]
		}
	} # }}}

	export *
}

var $targets = {
	ecma: { # {{{
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
	} # }}}
	v8: func(version, targets) { # {{{
		if version[0] < 5 {
			return targets.ecma['5']
		}
		else {
			return targets.ecma['6']
		}
	} # }}}
}

var $targetRegex = /^(\w+)-v((?:\d+)(?:\.\d+)?(?:\.\d+)?)$/

var $typeofs = { # {{{
	Array: true
	Boolean: true
	Class: true
	Enum: true
	Function: true
	Namespace: true
	Number: true
	Object: true
	Primitive: true
	RegExp: true
	String: true
	Struct: true
	Tuple: true
} # }}}

func $expandOptions(options) { # {{{
	var engine = $targets[options.target.name]
	if !?engine {
		throw Error.new(`Undefined target '\(options.target.name)'`)
	}

	if engine is Function {
		if var opts ?= engine(options.target.version.split('.').map((value, _, _) => parseInt(value)), $targets) {
			return Object.defaults(options, opts)
		}
		else {
			throw Error.new(`Undefined target's version '\(options.target.version)'`)
		}
	}
	else {
		if !?engine[options.target.version] {
			throw Error.new(`Undefined target's version '\(options.target.version)'`)
		}

		return Object.defaults(options, engine[options.target.version])
	}
} # }}}

func $isVarname(name: String): Boolean { # {{{
	return /^[a-zA-Z_$][\w$]*$/.test(name)
} # }}}
