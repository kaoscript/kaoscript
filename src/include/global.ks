extern console, JSON

var $extensions = { # {{{
	binary: '.ksb',
	exports: '.kse',
	hash: '.ksh',
	requirements: '.ksr',
	source: '.ks'
} # }}}

var $ast = {
	block(data) { # {{{
		if data.kind == NodeKind::Block {
			return data
		}
		else {
			return {
				kind: NodeKind::Block
				statements: [
					data
				]
				start: data.start
				end: data.end
			}
		}
	} # }}}
	body(data?) { # {{{
		if !?data.body {
			return {
				kind: NodeKind::Block
				statements: []
				start: data.start
				end: data.end
			}
		}
		else if data.body.kind == NodeKind::Block || data.body.kind == NodeKind::ReturnStatement {
			return data.body
		}
		else if data.body.kind == NodeKind::IfStatement || data.body.kind == NodeKind::UnlessStatement {
			return {
				kind: NodeKind::Block
				statements: [data.body]
				start: data.body.start
				end: data.body.end
			}
		}
		else {
			return {
				kind: NodeKind::ReturnStatement
				value: data.body
				start: data.body.start
				end: data.body.end
			}
		}
	} # }}}
	hasModifier(data, target: ModifierKind): Boolean { # {{{
		for var modifier in data.modifiers {
			if modifier.kind == target {
				return true
			}
		}

		return false
	} # }}}
	identifier(name) { # {{{
		if name is String {
			return {
				kind: NodeKind::Identifier
				name: name
			}
		}
		else {
			return name
		}
	} # }}}
	parameter() { # {{{
		return {
			kind: NodeKind::Parameter
			attributes: []
			modifiers: []
		}
	} # }}}
}

var $compile = {
	block(data, parent, scope = parent.scope()) => new Block($ast.block(data), parent, scope)
	expression(data, parent, scope = parent.scope()) { # {{{
		var dyn expression

		if var clazz ?= $expressions[data.kind] {
			expression = clazz is Class ? new clazz(data, parent, scope) : clazz(data, parent, scope)
		}
		else if data.kind == NodeKind::BinaryExpression {
			if data.operator.kind == BinaryOperatorKind::Assignment {
				if var clazz ?= $assignmentOperators[data.operator.assignment] {
					expression = new clazz(data, parent, scope)
				}
				else {
					throw new NotSupportedException(`Unexpected assignment operator \(data.operator.assignment)`, parent)
				}
			}
			else if var clazz ?= $binaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected binary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::PolyadicExpression {
			if var clazz ?= $polyadicOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected polyadic operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::UnaryExpression {
			if var clazz ?= $unaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected unary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::JunctionExpression {
			throw new NotSupportedException(`Unexpected junction expression`, parent)
		}
		else {
			throw new NotSupportedException(`Unexpected expression/statement \(data.kind)`, parent)
		}

		return expression
	} # }}}
	function(data, parent, scope = parent.scope()) => new FunctionBlock($ast.block(data), parent, scope)
	statement(data, parent, scope = parent.scope()) { # {{{
		if Attribute.conditional(data, parent) {
			var clazz = $statements[data.kind] ?? $statements.default

			return new clazz(data, parent, scope)
		}
		else {
			return null
		}
	} # }}}
}

var $runtime = {
	getVariable(name, node) { # {{{
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
	helper(node) { # {{{
		node.module?().flag('Helper')

		return node._options.runtime.helper.alias
	} # }}}
	immutableScope(node) { # {{{
		return node._options.format.variables == 'es5' ? 'var ' : 'const '
	} # }}}
	initFlag(node) { # {{{
		node.module?().flag('initFlag')

		return node._options.runtime.initFlag.alias
	} # }}}
	object(node) { # {{{
		node.module?().flag('Object')

		return node._options.runtime.object.alias
	} # }}}
	operator(node) { # {{{
		node.module?().flag('Operator')

		return node._options.runtime.operator.alias
	} # }}}
	scope(node) { # {{{
		return node._options.format.variables == 'es5' ? 'var ' : 'let '
	} # }}}
	type(node) { # {{{
		node.module?().flag('Type')

		return node._options.runtime.type.alias
	} # }}}
	typeof(type, node? = null) { # {{{
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
	v8(version, targets) { # {{{
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
		throw new Error(`Undefined target '\(options.target.name)'`)
	}

	if engine is Function {
		if var opts ?= engine(options.target.version.split('.').map((value, _, _) => parseInt(value)), $targets) {
			return Object.defaults(options, opts)
		}
		else {
			throw new Error(`Undefined target's version '\(options.target.version)'`)
		}
	}
	else {
		if !?engine[options.target.version] {
			throw new Error(`Undefined target's version '\(options.target.version)'`)
		}

		return Object.defaults(options, engine[options.target.version])
	}
} # }}}
