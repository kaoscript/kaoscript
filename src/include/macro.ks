extern Buffer, eval, parseInt

enum MacroVariableKind {
	AST
	AutoEvaluated
}

var $target = parseInt(/^v(\d+)\./.exec(process.version)[1]) >= 6 ? 'ecma-v6' : 'ecma-v5'

func $evaluate(source) { # {{{
	// console.log('--> ', source)

	var compiler = new Compiler('__ks__', {
		register: false
		target: $target
	})

	compiler.compile('#![bin]\nextern console, JSON, __ks_marker\nreturn ' + source)

	// console.log('<-- ', compiler.toSource())

	return eval(`(function(__ks_marker) {\(compiler.toSource())})`)(MacroMarker)
} # }}}

class MacroMarker {
	public {
		index: Number
	}
	constructor(@index)
}

func $reificate(macro, node, data, ast, reification = null, separator = null) { # {{{
	if ast {
		return Generator.generate(data, {
			transformers: {
				expression: $transformExpression^^(macro, node)
			}
		})
	}
	else {
		switch reification {
			ReificationKind::Argument => {
				if data is Array {
					return data.join(', ')
				}
				else {
					return data
				}
			}
			ReificationKind::Expression => {
				var context = {
					data: ''
				}

				$serialize(macro, data, context)

				return context.data
			}
			ReificationKind::Join => {
				if data is Array {
					return data.join(separator)
				}
				else {
					return data
				}
			}
			ReificationKind::Statement => {
				if data is Array {
					return data.join('\n') + '\n'
				}
				else {
					return data
				}
			}
			ReificationKind::Write => {
				return data
			}
		}
	}
} # }}}

func $serialize(macro, data, context) { # {{{
	if data is Boolean {
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
		context.data += (data == NaN ? 'NaN' : data)
	}
	else if data is RegExp {
		context.data += data
	}
	else if data is String {
		context.data += $quote(data)
	}
	else {
		var mut empty = true
		var mut computed, name

		context.data += '{'

		for var value, key of data {
			if empty {
				empty = false

				context.data += '\n'
			}

			computed = /^\_ks\_property\_name\_mark\_(\d+)$/.exec(key)

			if value is MacroMarker {
				if computed? {
					name = `\(Generator.generate(macro.getMark(computed[1]), {
						mode: Generator.KSWriterMode::Property
					}))`
				}
				else {
					name = key
				}

				if macro.getMark(value.index + 1) == NodeKind::ObjectMember {
					context.data += `\(name): \(Generator.generate(macro.getMark(value.index), {
						mode: Generator.KSWriterMode::Property
					}))`
				}
				else {
					context.data += `\(name)\(Generator.generate(macro.getMark(value.index), {
						mode: Generator.KSWriterMode::Property
					}))`
				}
			}
			else if computed? {
				context.data += `\(Generator.generate(macro.getMark(computed[1]), {
					mode: Generator.KSWriterMode::Property
				})): `

				$serialize(macro, value, context)
			}
			else {
				context.data += `\($quote(key)): `

				$serialize(macro, value, context)
			}

			context.data += '\n'
		}

		context.data += '}'
	}
} # }}}

func $transformExpression(macro, node, data, writer) { # {{{
	switch data.kind {
		NodeKind::EnumExpression => {
			return macro.addMark(data)
		}
		NodeKind::FunctionExpression => {
			return macro.addMark(data)
		}
		NodeKind::LambdaExpression => {
			return macro.addMark(data)
		}
		NodeKind::ObjectMember => {
			var name = data.name.kind == NodeKind::ComputedPropertyName || data.name.kind == NodeKind::TemplateExpression
			var value = 	data.value.kind == NodeKind::EnumExpression ||
							(data.value.kind == NodeKind::Identifier && !node.scope().isPredefinedVariable(data.value.name)) ||
							data.value.kind == NodeKind::LambdaExpression ||
							data.value.kind == NodeKind::MemberExpression

			if name || value {
				return {
					kind: NodeKind::ObjectMember
					name: name ? macro.addPropertyNameMark(data.name) : data.name
					value: value ? macro.addMark(data.value, NodeKind::ObjectMember) : data.value
					start: data.start
					end: data.end
				}
			}
		}
	}

	return data
} # }}}

class MacroDeclaration extends AbstractNode {
	private {
		_executeCount							= 0
		_fn: Function
		_line: Number
		_marks:	Array							= []
		_name: String
		_parameters: Dictionary						= {}
		_referenceIndex: Number					= -1
		_type: MacroType
	}
	constructor(@data, @parent, _: Scope?, @name = data.name.name) { # {{{
		super(data, parent, new MacroScope())

		@type = MacroType.fromAST(data!?, this)
		@line = data.start?.line ?? -1

		var builder = new Generator.KSWriter({
			filters: {
				expression: this.filter^@(false)
				statement: this.filter^@(true)
			}
		})

		var line = builder.newLine().code('func(__ks_evaluate, __ks_reificate')

		for var data in @data.parameters {
			var mut auto = false

			for var modifier in data.modifiers until auto {
				if modifier.kind == ModifierKind::AutoEvaluate {
					auto = true
				}
			}

			@parameters[data.name.name] = auto ? MacroVariableKind::AutoEvaluated : MacroVariableKind::AST

			if auto {
				line.code(', mut ', data.name.name)
			}
			else {
				line.code(', ', data.name.name)
			}

			if data.defaultValue? {
				line.code(' = ').expression(data.defaultValue)
			}
		}

		var block = line.code(')').newBlock()

		for var kind, name of @parameters {
			if kind == MacroVariableKind::AutoEvaluated {
				block.line(`\(name) = __ks_evaluate(__ks_reificate(\(name), true, \(ReificationKind::Expression.value)))`)
			}
		}

		block.line('var mut __ks_src = ""')

		for var statement in $ast.block(@data.body).statements {
			block.statement(statement)
		}

		block.line('return __ks_src').done()

		line.done()

		var mut source = ''

		for fragment in builder.toArray() {
			source += fragment.code
		}

		@fn = $evaluate(source)

		@parent.registerMacro(@name, this)
	} # }}}
	analyse()
	override prepare(target)
	translate()
	addMark(data, kind = null) { # {{{
		var index = @marks.length

		@marks.push(data, kind)

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
	} # }}}
	addPropertyNameMark(data, kind = null) { # {{{
		var index = @marks.length

		@marks.push(data, kind)

		return {
			kind: NodeKind::Identifier
			name: `_ks_property_name_mark_\(index)`
		}
	} # }}}
	execute(arguments: Array, parent) { # {{{
		// console.log(@fn.toString())
		var module = this.module()
		++@executeCount

		var args = [$evaluate, $reificate^^(this, parent)].concat(arguments)

		var mut data = @fn(...args)
		// console.log('execute =>', data)

		try {
			data = Parser.parse(data)
		}
		catch error {
			error.fileName = `\(@parent.file())$\(@name)$\(@executeCount)`
			error.message += ` (\(error.fileName):\(error.lineNumber):\(error.columnNumber))`

			throw error
		}

		return data
	} # }}}
	export(recipient, name = @name) { # {{{
		recipient.exportMacro(name, this)
	} # }}}
	private filter(statement, data, mut fragments) { # {{{
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
						if element.expression.kind == NodeKind::Identifier && @parameters[element.expression.name] == MacroVariableKind::AST {
							fragments.code('__ks_reificate(').expression(element.expression).code(`, true)`)
						}
						else if element.reification.kind == ReificationKind::Join {
							fragments.code('__ks_reificate(').expression(element.expression).code(`, false, \(element.reification.kind), `).expression(element.separator).code(')')
						}
						else {
							fragments.code('__ks_reificate(').expression(element.expression).code(`, false, \(element.reification.kind))`)
						}
					}
					MacroElementKind::Literal => {
						if element.value[0] == '\\' {
							fragments.code($quote(element.value.substr(1).replace(/\\/g, '\\\\')))
						}
						else {
							fragments.code($quote(element.value.replace(/\\/g, '\\\\')))
						}
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
	} # }}}
	getMark(index) => @marks[index]
	isEnhancementExport() => false
	isExportable() => false
	isInstanceMethod() => false
	line() => @line
	matchArguments(arguments: Array) => @type.matchArguments(arguments, this)
	name() => @name
	statement() => this
	toFragments(fragments, mode)
	toMetadata() => Buffer.from(JSON.stringify({
		parameters: @data.parameters
		body: @data.body
	})).toString('base64')
	type() => @type
}

class MacroType extends FunctionType {
	static fromAST(data, node: AbstractNode): MacroType { # {{{
		var scope = node.scope()

		return new MacroType([ParameterType.fromAST(parameter, false, scope, false, node) for parameter in data.parameters], data, node)
	} # }}}
	static import(data, references, scope: Scope, node: AbstractNode): MacroType { # {{{
		var type = new MacroType(scope)

		type._min = data.min
		type._max = data.max

		type._parameters = [ParameterType.import(parameter, false, references, scope, node) for parameter in data.parameters]

		type.updateParameters()

		return type
	} # }}}
	assessment(name: String, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess([this], name, node)

			@assessment.macro = true
		}

		return @assessment
	} # }}}
	export() => { # {{{
		min: @min
		max: @max
		parameters: [parameter.export() for parameter in @parameters]
	} # }}}
	matchContentOf(value: MacroType): Boolean { # {{{
		if value.min() < @min || value.max() > @max {
			return false
		}

		var params = value.parameters()

		if @parameters.length == params.length {
			for parameter, i in @parameters {
				if !params[i].matchContentOf(parameter) {
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
	} # }}}
}

// TODO remove extended type
class MacroArgument extends Type {
	private {
		_data
	}
	static build(arguments: Array) => [new MacroArgument(argument) for var argument in arguments]
	constructor(@data) { # {{{
		super(null)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		throw new NotSupportedException()
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotSupportedException()
	} # }}}
	toPositiveTestFragments(fragments, node, junction: Junction = Junction::NONE) { # {{{
		throw new NotSupportedException()
	} # }}}
	toVariations(variations: Array<String>) { # {{{
		throw new NotSupportedException()
	} # }}}
	isAssignableToVariable(value: AnyType, anycast: Boolean, nullcast: Boolean, downcast: Boolean, limited: Boolean = false): Boolean { # {{{
		return true
	} # }}}
	isAssignableToVariable(value: NullType, anycast: Boolean, nullcast: Boolean, downcast: Boolean, limited: Boolean = false): Boolean { # {{{
		return false
	} # }}}
	isAssignableToVariable(value: ReferenceType, anycast: Boolean, nullcast: Boolean, downcast: Boolean, limited: Boolean = false): Boolean { # {{{
		if value.isAny() {
			return true
		}

		switch value.name() {
			'Array' => {
				return @data.kind == NodeKind::ArrayExpression
			}
			'Dictionary' => {
				return @data.kind == NodeKind::ObjectExpression
			}
			'Expression' => {
				return	@data.kind == NodeKind::UnaryExpression ||
						@data.kind == NodeKind::BinaryExpression ||
						@data.kind == NodeKind::PolyadicExpression ||
						$expressions[@data.kind]?
			}
			'Identifier' => {
				return @data.kind == NodeKind::Identifier
			}
			'Number' => {
				return @data.kind == NodeKind::NumericExpression
			}
			'String' => {
				return @data.kind == NodeKind::Literal
			}
		}

		return false
	} # }}}
	isAssignableToVariable(value: UnionType, anycast: Boolean, nullcast: Boolean, downcast: Boolean, limited: Boolean = false): Boolean { # {{{
		for var type in value.types() {
			if @isAssignableToVariable(type, anycast, nullcast, downcast, limited) {
				return true
			}
		}

		return false
	} # }}}
	isSpread() => false
	isUnion() => false
}

func $callMacroExpression(data, parent, scope) { # {{{
	var macro = scope.getMacro(data, parent)

	var result = macro.execute(data.arguments, parent)

	if result.body.length == 1 {
		return $compile.expression(result.body[0], parent)
	}
	else {
		throw new NotImplementedException(parent)
	}
} # }}}

class CallMacroStatement extends Statement {
	private {
		_offsetEnd: Number		= 0
		_offsetStart: Number	= 0
		_statements: Array		= []
	}
	initiate() { # {{{
		var macro = @scope.getMacro(@data, this)

		var data = macro.execute(@data.arguments, this)

		var offset = @scope.getLineOffset()

		@offsetStart = @scope.line()

		@scope.setLineOffset(@offsetStart)

		var file = `\(this.file())!#\(macro.name())`

		@options = Attribute.configure(data, @options, AttributeTarget::Global, file)

		for var data in data.body {
			@scope.line(data.start.line)

			if var statement = $compile.statement(data, this) {
				@statements.push(statement)

				statement.initiate()
			}
		}

		@scope.line(data.end.line)

		@offsetEnd = offset + @scope.line() - @offsetStart
		@scope.setLineOffset(@offsetEnd)
	} # }}}
	analyse() { # {{{
		@scope.setLineOffset(@offsetStart)

		for statement in @statements {
			@scope.line(statement.line())

			statement.analyse()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	enhance() { # {{{
		@scope.setLineOffset(@offsetStart)

		for statement in @statements {
			@scope.line(statement.line())

			statement.enhance()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	override prepare(target) { # {{{
		@scope.setLineOffset(@offsetStart)

		for statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	translate() { # {{{
		@scope.setLineOffset(@offsetStart)

		for statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	isAwait() { # {{{
		for statement in @statements {
			if statement.isAwait() {
				return true
			}
		}

		return false
	} # }}}
	isExit() { # {{{
		for statement in @statements {
			if statement.isExit() {
				return true
			}
		}

		return false
	} # }}}
	toFragments(fragments, mode) { # {{{
		for statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} # }}}
}
