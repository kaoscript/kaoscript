extern Buffer, eval, parseInt

enum MacroVariableKind {
	AST
	AutoEvaluated
}

var $target = parseInt(/^v(\d+)\./.exec(process.version)[1]) >= 6 ? 'ecma-v6' : 'ecma-v5'

func $autoEvaluate(macro, node, data) { # {{{
	return $evaluate($compileMacro(Generator.generate(data, {
		transformers: {
			expression: $transformExpression^^(macro, node, ^, ^)
		}
	})))
} # }}}

func $compileMacro(source: String, standardLibrary: Boolean = false): String { # {{{
	// echo('--> ', source)

	var compiler = Compiler.new('__ks__', {
		register: false
		target: $target
	})

	if standardLibrary {
		compiler.flagStandardLibrary()
	}

	compiler.compile('extern console, JSON\nrequire class __ks_marker\nreturn ' + source)
	// echo('=- ', compiler.toSource())

	return compiler.toSource()
} # }}}

func $evaluate(source: String): Function { # {{{
	return eval(source)(MacroMarker)
} # }}}

func $generate(macro, node, data) { # {{{
	return Generator.generate(data)
} # }}}

class MacroMarker {
	public {
		index: Number
	}
	constructor(@index)
}

func $reificate(macro, node, data, ast, reification? = null, separator? = null) { # {{{
	if ast {
		if data is Array {
			var result = [$generate(macro, node, item) for var item in data]

			return result.join(', ')
		}
		else {
			return $generate(macro, node, data)
		}
	}
	else {
		match reification {
			ReificationKind.Argument {
				if data is Array {
					return data.join(', ')
				}
				else {
					return data
				}
			}
			ReificationKind.Expression {
				var context = {
					data: ''
				}

				$serialize(macro, data, context)

				return context.data
			}
			ReificationKind.Join {
				if data is Array {
					return data.join(separator)
				}
				else {
					return data
				}
			}
			ReificationKind.Statement {
				if data is Array {
					return data.join('\n') + '\n'
				}
				else {
					return data
				}
			}
			ReificationKind.Write {
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

			for i from 1 to~ data.length {
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
		var dyn computed, name

		context.data += '{'

		for var value, key of data {
			if empty {
				empty = false

				context.data += '\n'
			}

			computed = /^\_ks\_property\_name\_mark\_(\d+)$/.exec(key)

			if value is MacroMarker {
				if ?computed {
					name = `\(Generator.generate(macro.getMark(computed[1]), {
						mode: Generator.KSWriterMode.Property
					}))`
				}
				else {
					name = key
				}

				if macro.getMark(value.index + 1) == NodeKind.ObjectMember {
					context.data += `\(name): \(Generator.generate(macro.getMark(value.index), {
						mode: Generator.KSWriterMode.Property
					}))`
				}
				else {
					context.data += `\(name)\(Generator.generate(macro.getMark(value.index), {
						mode: Generator.KSWriterMode.Property
					}))`
				}
			}
			else if ?computed {
				context.data += `\(Generator.generate(macro.getMark(computed[1]), {
					mode: Generator.KSWriterMode.Property
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
	match data.kind {
		NodeKind.FunctionExpression {
			return macro.addMark(data)
		}
		NodeKind.LambdaExpression {
			return macro.addMark(data)
		}
		NodeKind.MemberExpression when data.object.kind != NodeKind.Identifier || data.object.name != '__ks_marker' {
			return macro.addMark(data)
		}
		NodeKind.ObjectMember {
			var name = data.name.kind == NodeKind.ComputedPropertyName || data.name.kind == NodeKind.TemplateExpression
			var value = 	(data.value.kind == NodeKind.Identifier && !node.scope().isPredefinedVariable(data.value.name)) ||
							data.value.kind == NodeKind.LambdaExpression ||
							data.value.kind == NodeKind.MemberExpression

			if name || value {
				return {
					kind: NodeKind.ObjectMember
					name: name ? macro.addPropertyNameMark(data.name) : data.name
					value: value ? macro.addMark(data.value, NodeKind.ObjectMember) : data.value
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
		@executeCount							= 0
		@fn: Function?
		@line: Number
		@marks: Array							= []
		@name: String
		@parameters: Object						= {}
		@referenceIndex: Number					= -1
		@source: String?
		@standardLibrary: Boolean
		@type: MacroType
	}
	constructor(@data, @parent, _: Scope?, @name = data.name.name, @standardLibrary = false) { # {{{
		super(data, parent, MacroScope.new())

		@standardLibrary ||= @parent.module().isStandardLibrary()

		if @parent.scope().hasDefinedVariable(@name) {
			SyntaxException.throwIdenticalIdentifier(@name, this)
		}

		@type = MacroType.fromAST(data!?, this)
		@line = data.start?.line ?? -1

		@parent.registerMacro(@name, this)
	} # }}}
	postInitiate()
	analyse()
	private buildFunction() { # {{{
		if ?@data.source {
			@source = @data.source
		}
		else {
			var builder = Generator.KSWriter.new({
				filters: {
					expression: this.filter^^(false, ^, ^)
					statement: this.filter^^(true, ^, ^)
				}
			})

			var line = builder.newLine().code('func(__ks_auto, __ks_reificate')

			for var data in @data.parameters {
				var mut auto = false
				var mut rest = false

				for var modifier in data.modifiers until auto {
					match modifier.kind {
						ModifierKind.AutoEvaluate {
							auto = true
						}
						ModifierKind.Rest {
							rest = true
						}
					}
				}

				@parameters[data.internal.name] = auto ? MacroVariableKind.AutoEvaluated : MacroVariableKind.AST

				line.code(`,\(auto ? ' mut' : '') \(rest ? '...' : '')\(data.internal.name)`)

				if ?data.defaultValue {
					line.code(' = ').expression(data.defaultValue)
				}
			}

			var block = line.code(')').newBlock()

			for var kind, name of @parameters {
				if kind == MacroVariableKind.AutoEvaluated {
					block.line(`\(name) = __ks_auto(\(name))`)
				}
			}

			block.line('var mut __ks_src = ""')

			for var statement in $ast.block(@data.body).statements {
				block.statement(statement)
			}

			block.line('return __ks_src').done()

			line.done()

			var mut source = ''

			for var fragment in builder.toArray() {
				source += fragment.code
			}

			@source = $compileMacro(source, @standardLibrary)
		}

		@fn = $evaluate(@source)
	} # }}}
	override prepare(target, targetMode)
	prepare(target: Type, index: Number, length: Number)
	translate()
	addMark(data, kind? = null) { # {{{
		var index = @marks.length

		@marks.push(data, kind)

		return {
			kind: NodeKind.CallExpression
			modifiers: []
			scope: {
				kind: ScopeKind.This
			}
			callee: {
				kind: NodeKind.MemberExpression
				modifiers: []
				object: {
					kind: NodeKind.Identifier
					name: '__ks_marker'
				}
				property: {
					kind: NodeKind.Identifier
					name: 'new'
				}
			}
			arguments: [
				{
					kind: NodeKind.NumericExpression
					value: index
				}
			]
		}
	} # }}}
	addPropertyNameMark(data, kind? = null) { # {{{
		var index = @marks.length

		@marks.push(data, kind)

		return {
			kind: NodeKind.Identifier
			name: `_ks_property_name_mark_\(index)`
		}
	} # }}}
	execute(arguments: Array, parent) { # {{{
		if !?@fn {
			@buildFunction()
		}

		var module = @module()
		@executeCount += 1

		var args = [$autoEvaluate^^(this, parent, ^), $reificate^^(this, parent, ...)].concat(arguments)

		// echo(args)
		var mut data = @fn(...args)
		// echo(data)

		try {
			data = Parser.parseStatements(data + '\n', Parser.FunctionMode.Method)
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
		var elements = if statement {
			unless data.kind == NodeKind.ExpressionStatement && data.expression.kind == NodeKind.MacroExpression {
				return false
			}

			pick data.expression.elements
		}
		else {
			unless data.kind == NodeKind.MacroExpression {
				return false
			}

			pick data.elements
		}

		if statement {
			fragments = fragments.newLine().code('__ks_src += ')
		}

		for var element, index in elements {
			if index != 0 {
				fragments.code(' + ')
			}

			match element.kind {
				MacroElementKind.Expression {
					if element.expression.kind == NodeKind.Identifier && @parameters[element.expression.name] == MacroVariableKind.AST {
						unless !?element.reification {
							SyntaxException.throwInvalidASTReification(this)
						}

						fragments.code('__ks_reificate(').expression(element.expression).code(`, true)`)
					}
					else if !?element.reification {
						fragments.code('__ks_reificate(').expression(element.expression).code(`, false, \(ReificationKind.Expression))`)
					}
					else if element.reification.kind == ReificationKind.Join {
						fragments.code('__ks_reificate(').expression(element.expression).code(`, false, \(element.reification.kind), `).expression(element.separator).code(')')
					}
					else {
						fragments.code('__ks_reificate(').expression(element.expression).code(`, false, \(element.reification.kind))`)
					}
				}
				MacroElementKind.Literal {
					if element.value[0] == '\\' {
						fragments.code($quote(element.value.substr(1).replace(/\\/g, '\\\\')))
					}
					else {
						fragments.code($quote(element.value.replace(/\\/g, '\\\\')))
					}
				}
				MacroElementKind.NewLine {
					fragments.code('"\\n"')
				}
			}
		}

		if statement {
			fragments.done()
		}

		return true
	} # }}}
	getMark(index) => @marks[index]
	isEnhancementExport() => false
	isExportable() => false
	isInstanceMethod() => false
	isStandardLibrary(): @standardLibrary
	line() => @line
	matchArguments(arguments: Array) => @type.matchArguments(arguments, this)
	name() => @name
	statement() => this
	toFragments(fragments, mode)
	toMetadata() { # {{{
		if !?@source {
			@buildFunction()
		}

		return Buffer.from(JSON.stringify({
			parameters: @data.parameters
			@source
		})).toString('base64')
	} # }}}
	type() => @type
}

class MacroType extends FunctionType {
	static fromAST(data, node: AbstractNode): MacroType { # {{{
		var scope = node.scope()

		return MacroType.new([ParameterType.fromAST(parameter, false, scope, false, node) for parameter in data.parameters], data, node)
	} # }}}
	static import(data, references, scope: Scope, node: AbstractNode): MacroType { # {{{
		var type = MacroType.new(scope)

		for var parameter in data.parameters {
			type.addParameter(ParameterType.import(parameter, false, references, scope, node), node)
		}

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
		parameters: [parameter.export() for parameter in @parameters]
	} # }}}
	matchContentOf(value: MacroType): Boolean { # {{{
		if value.min() < @min() || value.max() > @max() {
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
			throw NotImplementedException.new()
		}
		else {
			throw NotImplementedException.new()
		}

		return true
	} # }}}
}

// TODO remove extended type
class MacroArgument extends Type {
	private {
		@data
	}
	static build(arguments: Array) => [MacroArgument.new(argument) for var argument in arguments]
	constructor(@data) { # {{{
		super(null)
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		throw NotSupportedException.new()
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotSupportedException.new()
	} # }}}
	toPositiveTestFragments(fragments, node, junction: Junction = Junction.NONE) { # {{{
		throw NotSupportedException.new()
	} # }}}
	toVariations(variations: Array<String>) { # {{{
		throw NotSupportedException.new()
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

		match value.name() {
			'Array' {
				return @data.kind == NodeKind.ArrayExpression
			}
			'Expression' {
				return	@data.kind == NodeKind.UnaryExpression ||
						@data.kind == NodeKind.BinaryExpression ||
						@data.kind == NodeKind.PolyadicExpression ||
						?$expressions[@data.kind]
			}
			'Identifier' {
				return @data.kind == NodeKind.Identifier
			}
			'Number' {
				return @data.kind == NodeKind.NumericExpression
			}
			'Object' {
				return @data.kind == NodeKind.ObjectExpression
			}
			'String' {
				return @data.kind == NodeKind.Literal
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
	toQuote() { # {{{
		match @data.kind {
			NodeKind.ArrayExpression => return 'Array'
			NodeKind.Identifier => return 'Identifier'
			NodeKind.NumericExpression => return 'Number'
			NodeKind.ObjectExpression => return 'Object'
			NodeKind.Literal => return 'String'
			else => return 'Expression'
		}
	} # }}}
}

func $callExpression(data, parent, scope) { # {{{
	if var path ?= $ast.path(data.callee) {
		if var macros ?= scope.getMacro(path) {
			var arguments = MacroArgument.build(data.arguments)

			for var macro in macros {
				if macro.matchArguments(arguments) {
					var result = macro.execute(data.arguments, parent)

					if result.body.length == 1 && result.body[0].kind == NodeKind.ExpressionStatement {
						var expression = $compile.expression(result.body[0].expression, parent)

						expression.setAttributes(result.body[0].attributes)

						return expression
					}
					else {
						throw NotImplementedException.new(parent)
					}
				}
			}

			ReferenceException.throwNoMatchingMacro(path, arguments, parent)
		}
	}

	return CallExpression.new(data, parent, scope)
} # }}}

func $callStatement(data, parent, scope) { # {{{
	if var path ?= $ast.path(data.expression.callee) {
		if var macros ?= scope.getMacro(path) {
			var arguments = MacroArgument.build(data.expression.arguments)

			for var macro in macros {
				if macro.matchArguments(arguments) {
					return CallMacroStatement.new(data, parent, scope, macro)
				}
			}

			ReferenceException.throwNoMatchingMacro(path, arguments, parent)
		}
	}

	return ExpressionStatement.new(data, parent, scope)
} # }}}

class CallMacroStatement extends Statement {
	private {
		@macro: MacroDeclaration
		@offsetEnd: Number		= 0
		@offsetStart: Number	= 0
		@statements: Array		= []
	}
	constructor(@data, @parent, @scope = parent.scope(), @macro) { # {{{
		super(data, parent, scope)
	} # }}}
	initiate() { # {{{
		var data = @macro.execute(@data.expression.arguments, this)

		var offset = @scope.getLineOffset()

		@offsetStart = @scope.line()

		@scope.setLineOffset(@offsetStart)

		var file = `\(@file())!#\(@macro.name())`

		@options = Attribute.configure(data, @options, AttributeTarget.Global, file)

		for var data in data.body {
			@scope.line(data.start.line)

			if var statement ?= $compile.statement(data, this) {
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

		for var statement in @statements {
			@scope.line(statement.line())

			statement.analyse()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	enhance() { # {{{
		@scope.setLineOffset(@offsetStart)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.enhance()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@scope.setLineOffset(@offsetStart)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.prepare(target)
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
