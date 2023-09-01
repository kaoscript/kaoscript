extern console, JSON

var $extensions = { # {{{
	binary: '.ksb',
	exports: '.kse',
	hash: '.ksh',
	requirements: '.ksr',
	source: '.ks'
} # }}}

namespace $ast {
	func block(data) { # {{{
		if data.kind == NodeKind.Block {
			return data
		}
		else {
			return {
				kind: NodeKind.Block
				statements: [data]
				start: data.start
				end: data.end
			}
		}
	} # }}}
	func body(data?) { # {{{
		if !?data.body {
			return {
				kind: NodeKind.Block
				statements: []
				start: data.start
				end: data.end
			}
		}
		else if data.body.kind == NodeKind.Block || data.body.kind == NodeKind.ReturnStatement {
			return data.body
		}
		else if data.body.kind == NodeKind.IfStatement || data.body.kind == NodeKind.UnlessStatement {
			return {
				kind: NodeKind.Block
				statements: [data.body]
				start: data.body.start
				end: data.body.end
			}
		}
		else {
			return {
				kind: NodeKind.ReturnStatement
				value: data.body
				start: data.body.start
				end: data.body.end
			}
		}
	} # }}}
	func call(callee, arguments = []) { # {{{
		return {
			kind: NodeKind.CallExpression
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
				kind: NodeKind.Identifier
				name: name
			}
		}
		else {
			return name
		}
	} # }}}
	func isThisField(name: String, data): Boolean { # {{{
		match data.kind {
			NodeKind.ThisExpression {
				return data.name.name == name
			}
			NodeKind.MemberExpression {
				return data.object.kind == NodeKind.Identifier && data.object.name == 'this' && data.property.kind == NodeKind.Identifier && (data.property.name == name || data.property.name == `_\(name)`)
			}
		}

		return false
	} # }}}
	func parameter() { # {{{
		return {
			kind: NodeKind.Parameter
			attributes: []
			modifiers: []
		}
	} # }}}
	func path(data): String? { # {{{
		match data.kind {
			NodeKind.Identifier {
				return data.name
			}
			NodeKind.MemberExpression {
				if data.property.kind == NodeKind.Identifier {
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
			kind: NodeKind.ReturnStatement
			value: data
			start: data.start if ?data
		}
	} # }}}
	func some(data, filter): Boolean { # {{{
		match data.kind {
			NodeKind.BinaryExpression {
				if filter(data.left) || filter(data.right) || $ast.some(data.left, filter) || $ast.some(data.right, filter) {
					return true
				}
			}
			NodeKind.CallExpression {
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

		while object.kind == NodeKind.MemberExpression {
			property = `.\(object.property.name)\(property)`

			object = object.object
		}

		return `\(object.name)\(property)`
	} # }}}
	func topicReference() { # {{{
		return {
			kind: NodeKind.TopicReference
			modifiers: []
		}
	} # }}}

	export *
}

namespace $compile {
	func block(data, parent, scope = parent.scope()) => Block.new($ast.block(data), parent, scope)
	func expression(data, parent, scope = parent.scope()) { # {{{
		var dyn expression

		if var clazz ?= $expressions[data.kind] {
			expression = clazz is Class ? clazz.new(data, parent, scope) : clazz(data, parent, scope)
		}
		else if data.kind == NodeKind.BinaryExpression {
			if data.operator.kind == BinaryOperatorKind.Assignment {
				if var clazz ?= $assignmentOperators[data.operator.assignment] {
					expression = clazz.new(data, parent, scope)
				}
				else {
					throw NotSupportedException.new(`Unexpected assignment operator \(data.operator.assignment)`, parent)
				}
			}
			else if var clazz ?= $binaryOperators[data.operator.kind] {
				expression = clazz.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected binary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind.PolyadicExpression {
			if var clazz ?= $polyadicOperators[data.operator.kind] {
				expression = clazz.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected polyadic operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind.UnaryExpression {
			if var clazz ?= $unaryOperators[data.operator.kind] {
				expression = clazz.new(data, parent, scope)
			}
			else {
				throw NotSupportedException.new(`Unexpected unary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind.JunctionExpression {
			throw NotSupportedException.new(`Unexpected junction expression`, parent)
		}
		else {
			throw NotSupportedException.new(`Unexpected expression/statement \(data.kind)`, parent)
		}

		return expression
	} # }}}
	func function(data, parent, scope = parent.scope()) => FunctionBlock.new($ast.block(data), parent, scope)
	func statement(data, parent, scope = parent.scope()) { # {{{
		if Attribute.conditional(data, parent) {
			if var clazz ?= $statements[data.kind] {
				return clazz.new(data, parent, scope)
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
		return node._options.format.variables == 'es5' ? 'var ' : 'const '
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
		return node._options.format.variables == 'es5' ? 'var ' : 'let '
	} # }}}
	func type(node) { # {{{
		node.module?().flag('Type')

		return node._options.runtime.type.alias
	} # }}}
	func typeof(type, node? = null) { # {{{
		if ?node {
			if $typeofs[type] {
				return $runtime.type(node) + '.is' + type
			}
			else {
				return null
			}
		}
		else {
			return $typeofs[type]
		}
	} # }}}

	export *
}

var $standardLibraryDirectory = fs.getStandardLibraryDirectory()

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
