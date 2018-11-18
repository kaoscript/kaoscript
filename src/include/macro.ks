extern Buffer, eval, parseInt

enum MacroVariableKind {
	AST
	AutoEvaluated
}

const $target = parseInt(/^v(\d+)\./.exec(process.version)[1]) >= 6 ? 'ecma-v6' : 'ecma-v5'

func $evaluate(source) { // {{{
	//console.log(source)

	const compiler = new Compiler('__ks__', {
		register: false
		target: $target
	})

	compiler.compile('#![bin]\nextern console, JSON, __ks_marker\nreturn ' + source)

	//console.log(compiler.toSource())

	return eval(`(function(__ks_marker) {\(compiler.toSource())})`)(MacroMarker)
} // }}}

class MacroMarker {
	public {
		index: Number
	}
	constructor(@index)
}

func $reificate(macro, node, data, ast, reification) { // {{{
	if ast {
		return Generator.generate(data, {
			transformers: {
				expression: $transformExpression^^(macro, node)
			}
		})
	}
	else {
		switch reification {
			ReificationKind::Block => {
				let src = ''

				for element in data {
					src += element + '\n'
				}

				return src
			}
			ReificationKind::Expression => {
				const context = {
					data: ''
				}

				$serialize(macro, data, context)

				return context.data
			}
			ReificationKind::Identifier => {
				return data
			}
		}
	}
} // }}}

func $serialize(macro, data, context) { // {{{
	if data == null || data is Boolean {
		context.data += JSON.stringify(data)
	}
	else if data is Array {
		if data.length == 0 {
			context.data += '[]'
		}
		else {
			context.data += '['

			$serialize(macro, data[0], context)

			for i from 1 til data.length {
				context.data += ', '

				$serialize(macro, data[i], context)
			}

			context.data += ']'
		}
	}
	else if data is MacroMarker {
		context.data += Generator.generate(macro.getMark(data.index))
	}
	else if data is Number {
		context.data += (data is NaN ? 'NaN' : data)
	}
	else if data is RegExp {
		context.data += data
	}
	else if data is String {
		context.data += $quote(data)
	}
	else {
		let empty = true

		context.data += '{'

		for key, value of data {
			if empty {
				empty = false

				context.data += '\n'
			}

			if value is MacroMarker {
				context.data += `\(key)\(Generator.generate(macro.getMark(value.index), {
					mode: Generator.KSWriterMode::Property
				}))`
			}
			else {
				context.data += `\($quote(key)): `

				$serialize(macro, value, context)
			}

			context.data += '\n'
		}

		context.data += '}'
	}
} // }}}

func $transformExpression(macro, node, data, writer) { // {{{
	switch data.kind {
		NodeKind::EnumExpression => {
			if variable ?= node.scope().getVariable(data.enum.name) {
				const type = variable.type()
				if type.isEnum() {
					switch type.kind() {
						EnumKind::String => {
							return {
								kind: NodeKind::Literal
								value: data.member.name.toLowerCase()
							}
						}
					}
				}
			}
		}
		NodeKind::FunctionExpression => {
			return macro.addMark(data)
		}
	}

	return data
} // }}}

class MacroDeclaration extends AbstractNode {
	private {
		_fn: Function
		_marks:	Array				= []
		_name: String
		_parameters: Object			= {}
		_referenceIndex: Number		= -1
		_type: MacroType
	}
	constructor(@data, @parent, @name = data.name.name) { // {{{
		super(data, parent, new Scope())

		@scope.addNative('Identifier')
		@scope.addNative('Expression')

		@type = MacroType.fromAST(data, this)

		const builder = new Generator.KSWriter({
			filters: {
				expression: this.filter^@(false)
				statement: this.filter^@(true)
			}
		})

		const line = builder.newLine().code('func(__ks_evaluate, __ks_reificate')

		let auto
		for data in @data.parameters {
			line.code(', ', data.name.name)

			if data.defaultValue? {
				line.code(' = ').expression(data.defaultValue)
			}

			auto = false

			for modifier in data.modifiers until auto {
				if modifier.kind == ModifierKind::AutoEvaluate {
					auto = true
				}
			}

			@parameters[data.name.name] = auto ? MacroVariableKind::AutoEvaluated : MacroVariableKind::AST
		}

		const block = line.code(')').newBlock()

		for name, kind of @parameters {
			if kind == MacroVariableKind::AutoEvaluated {
				block.line(`\(name) = __ks_evaluate(__ks_reificate(\(name), true, 3))`)
			}
		}

		block.line('let __ks_src = ""')

		for statement in $ast.block(@data.body).statements {
			block.statement(statement)
		}

		block.line('return __ks_src').done()

		line.done()

		let source = ''

		for fragment in builder.toArray() {
			source += fragment.code
		}

		//console.log(source)

		@fn = $evaluate(source)
		
		@parent.scope().addMacro(@name, this)
	} // }}}
	analyse()
	prepare()
	translate()
	addMark(data) { // {{{
		const index = @marks.length

		@marks.push(data)

		return {
			kind: NodeKind::CreateExpression
			class: {
				kind: NodeKind::Identifier
				name: '__ks_marker'
			}
			arguments: [
				{
					kind: NodeKind::NumericExpression
					value: index
				}
			]
		}
	} // }}}
	execute(arguments: Array, parent) { // {{{
		//console.log(@fn.toString())
		const module = this.module()

		const args = [$evaluate, $reificate^^(this, parent)].concat(arguments)

		let data = @fn(...args)
		//console.log('execute =>', data)

		try {
			data = module.parse(data, path)
		}
		catch error {
			error.filename = path

			throw error
		}

		const statements = []

		for statement in data.body when statement ?= $compile.statement(statement, parent) {
			statements.push(statement)
		}

		return statements
	} // }}}
	export(recipient, name = @name) { // {{{
		const data = {
			parameters: @data.parameters
			body: @data.body
		}
		
		recipient.exportMacro(name, Buffer.from(JSON.stringify(data)).toString('base64'))
	} // }}}
	private filter(statement, data, fragments) { // {{{
		if data.kind == NodeKind::MacroExpression {
			if statement {
				fragments = fragments.newLine().code('__ks_src += ')
			}

			for element, index in data.elements {
				if index != 0 {
					fragments.code(' + ')
				}

				switch element.kind {
					MacroElementKind::Expression => {
						fragments
							.code('__ks_reificate(')
							.expression(element.expression)
							.code(`, \(element.expression.kind == NodeKind::Identifier && @parameters[element.expression.name] == MacroVariableKind::AST), \(element.reification.kind))`)
					}
					MacroElementKind::Literal => {
						fragments.code($quote(element.value.replace(/\\/g, '\\\\')))
					}
					MacroElementKind::NewLine => {
						fragments.code('"\\n"')
					}
				}
			}

			if statement {
				fragments.done()
			}

			return true
		}
		else {
			return false
		}
	} // }}}
	getMark(index) => @marks[index]
	isExportable() => false
	isInstanceMethod() => false
	matchArguments(arguments: Array) => @type.matchArguments(arguments)
	name() => @name
	statement() => this
	toFragments(fragments, mode)
	type() => @type
}

class MacroType extends FunctionType {
	static fromAST(data, node: AbstractNode) { // {{{
		const domain = node.scope().domain()

		return new MacroType([MacroParameterType.fromAST(parameter, domain, false, node) for parameter in data.parameters], data, node)
	} // }}}
	static import(data, references, domain: Domain, node: AbstractNode): MacroType { // {{{
		const type = new MacroType()

		type._min = data.min
		type._max = data.max

		type._parameters = [MacroParameterType.import(parameter, references, domain, node) for parameter in data.parameters]

		type.updateArguments()

		return type
	} // }}}
	export() => { // {{{
		min: @min
		max: @max
		parameters: [parameter.export() for parameter in @parameters]
	} // }}}
	match(that: MacroType): Boolean { // {{{
		if that.min() < @min || that.max() > @max {
			return false
		}

		const params = that.parameters()

		if @parameters.length == params.length {
			for parameter, i in @parameters {
				if !parameter.match(params[i]) {
					return false
				}
			}
		}
		else if @hasRest {
			throw new NotImplementedException()
		}
		else {
			throw new NotImplementedException()
		}

		return true
	} // }}}
}

class MacroParameterType extends ParameterType {
	static {
		fromAST(data, domain: Domain, defined: Boolean, node: AbstractNode) { // {{{
			const type = Type.fromAST(data.type, domain, false, node)

			let min: Number = data.defaultValue? ? 0 : 1
			let max: Number = 1

			let nf = true
			for modifier in data.modifiers while nf {
				if modifier.kind == ModifierKind::Rest {
					if modifier.arity {
						min = modifier.arity.min
						max = modifier.arity.max
					}
					else {
						min = 0
						max = Infinity
					}

					nf = true
				}
			}

			return new MacroParameterType(type, min, max)
		} // }}}
	}
	clone() => new MacroParameterType(@type, @min, @max)
	matchArgument(argument) { // {{{
		//console.log(@type)
		//console.log(argument)

		if @type.isAny() {
			return true
		}

		switch @type.name() {
			'Expression' => {
				return	argument.kind == NodeKind::UnaryExpression ||
						argument.kind == NodeKind::BinaryExpression ||
						argument.kind == NodeKind::PolyadicExpression ||
						$expressions[argument.kind]?
			}
			'Identifier' => {
				return argument.kind == NodeKind::Identifier
			}
			'Number' => {
				return argument.kind == NodeKind::NumericExpression
			}
			'Object' => {
				return argument.kind == NodeKind::ObjectExpression
			}
			'String' => {
				return argument.kind == NodeKind::Literal
			}
		}

		return false
	} // }}}
}

class CallMacroStatement extends Statement {
	private {
		_statements: Array
	}
	analyse() { // {{{
		const macro = this.scope().getMacro(@data, this)

		@statements = macro.execute(@data.arguments, this)

		for statement in @statements {
			statement.analyse()
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			statement.prepare()
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isAwait() { // {{{
		for statement in @statements {
			if statement.isAwait() {
				return true
			}
		}

		return false
	} // }}}
	isExit() { // {{{
		for statement in @statements {
			if statement.isExit() {
				return true
			}
		}

		return false
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}