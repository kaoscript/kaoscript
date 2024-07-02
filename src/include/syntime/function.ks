func $autoEvaluate(macro, node, mut data) { # {{{
	if var result ?]= $unquote(data, macro) {
		return result.value
	}
	else {
		if data is Array {
			data = {
				kind: AstKind.ArrayExpression
				modifiers: []
				values: data
				start: data[0].start
				end: data[#data - 1].end
			}
		}

		var source = KSGeneration.generate(data, {
			transformers: {
				expression: $transformExpression^^(macro, node, ^, ^)
			}
		})

		var fn = macro.compile(`return \(source)`)

		return Syntime.evaluate(fn, Marker)
	}
} # }}}

func $unquote(data, macro): NEResult { # {{{
	match data {
		is Array {
			var array = []

			for var value in data {
				var decoded = $unquote(value, macro)

				if decoded.ok {
					array.push(decoded.value)
				}
				else {
					return decoded
				}
			}

			return {ok: true, value: array}
		}
		is Ast(ArrayExpression) {
			var array = []

			for var value in data.values {
				var decoded = $unquote(value, macro)

				if decoded.ok {
					array.push(decoded.value)
				}
				else {
					return decoded
				}
			}

			return {ok: true, value: array}
		}
		is Ast(FunctionExpression) {
			var mark = macro.addMark(data)

			return {ok: true, value: Marker.new(mark.arguments[0].value)}
		}
		is Ast(Identifier) {
			var mark = macro.addMark(data)

			return {ok: true, value: Marker.new(mark.arguments[0].value)}
		}
		is Ast(LambdaExpression) {
			var mark = macro.addMark(data)

			return {ok: true, value: Marker.new(mark.arguments[0].value)}
		}
		is Ast(Literal) {
			return {ok: true, value: data.value}
		}
		is Ast(MemberExpression) {
			var mark = macro.addMark(data)

			return {ok: true, value: Marker.new(mark.arguments[0].value)}
		}
		is Ast(NumericExpression) {
			return {ok: true, value: data.value}
		}
		is Ast(ObjectExpression) {
			var object = {}

			for var property in data.properties {
				match property.kind {
					.ObjectMember {
						match property.name.kind {
							// TODO!
							// .Identifier {
							AstKind.Identifier {
								var decoded = $unquote(property.value, macro)

								if decoded.ok {
									object[property.name.name] = decoded.value
								}
								else {
									return decoded
								}
							}
							else {
								return {ok: false}
							}
						}
					}
					else {
						return {ok: false}
					}
				}
			}

			return {ok: true, value: object}
		}
		is Ast(Operator) {
			return {ok: true, value: data}
		}
		else {
			return {ok: false}
		}
	}
} # }}}

func $generate(macro, node, data) { # {{{
	return KSGeneration.generate(data)
} # }}}

func $reificate(macro, node, data, mut ast? = null, reification? = null, separator? = null) { # {{{
	ast ??= data is Ast

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
		match ReificationKind(reification) {
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

			for var i from 1 to~ data.length {
				context.data += ', '

				$serialize(macro, data[i], context)
			}

			context.data += ']'
		}
	}
	else if data is Marker {
		context.data += KSGeneration.generate(macro.getMark(data.index))
	}
	else if data is Number {
		context.data += if data == NaN set 'NaN' else data
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

			if value is Marker {
				if ?computed {
					name = `\(KSGeneration.generate(macro.getMark(computed[1]), {
						mode: KSGeneration.KSWriterMode.Property
					}))`
				}
				else {
					name = key
				}

				context.data += `\(name): \(KSGeneration.generate(macro.getMark(value.index), {
					mode: KSGeneration.KSWriterMode.Property
				}))`
			}
			else if ?computed {
				context.data += `\(KSGeneration.generate(macro.getMark(computed[1]), {
					mode: KSGeneration.KSWriterMode.Property
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
		AstKind.FunctionExpression {
			return macro.addMark(data)
		}
		AstKind.LambdaExpression {
			return macro.addMark(data)
		}
		AstKind.MemberExpression when data.object.kind != AstKind.Identifier || data.object.name != '__ks_Marker' {
			return macro.addMark(data)
		}
		AstKind.ObjectMember {
			var name = data.name.kind == AstKind.ComputedPropertyName || data.name.kind == AstKind.TemplateExpression
			var value = 	(data.value.kind == AstKind.Identifier && !node.scope().isPredefinedVariable(data.value.name)) ||
							data.value.kind == AstKind.LambdaExpression ||
							data.value.kind == AstKind.MemberExpression

			if name || value {
				return {
					kind: AstKind.ObjectMember
					name: if name set macro.addPropertyNameMark(data.name) else data.name
					value: if value set macro.addMark(data.value, AstKind.ObjectMember) else data.value
					start: data.start
					end: data.end
				}
			}
		}
	}

	return data
} # }}}

class SyntimeFunctionDeclaration extends AbstractNode {
	private {
		@arguments								= []
		@executeCount							= 0
		@fn: Function?
		@line: Number
		@marks: Array							= []
		@name: String
		@parameters: Object						= {}
		@referenceIndex: Number					= -1
		@source: String?
		@standardLibrary: Boolean
		@type: SyntimeFunctionType
	}
	constructor(@data, @parent, _: Scope?, @name = data.name.name, @standardLibrary = false) { # {{{
		super(data, parent, MacroScope.create(parent))

		if @parent.scope().hasDefinedVariable(@name) {
			SyntaxException.throwIdenticalIdentifier(@name, this)
		}

		@type = SyntimeFunctionType.fromAST(data!?, this)
		@line = data.start?.line ?? -1

		@parent.registerSyntimeFunction(@name, this)
	} # }}}
	postInitiate()
	analyse()
	override prepare(target, targetMode)
	prepare(target: Type, index: Number, length: Number)
	translate()
	addMark(data, kind? = null) { # {{{
		var index = @marks.length

		@marks.push(data, kind)

		return {
			kind: AstKind.CallExpression
			modifiers: []
			scope: {
				kind: ScopeKind.This
			}
			callee: {
				kind: AstKind.MemberExpression
				modifiers: []
				object: {
					kind: AstKind.Identifier
					name: '__ks_Marker'
				}
				property: {
					kind: AstKind.Identifier
					name: 'new'
				}
			}
			arguments: [
				{
					kind: AstKind.NumericExpression
					value: index
				}
			]
		}
	} # }}}
	addPropertyNameMark(data, kind? = null) { # {{{
		var index = @marks.length

		@marks.push(data, kind)

		return {
			kind: AstKind.Identifier
			name: `_ks_property_name_mark_\(index)`
		}
	} # }}}
	execute(arguments: Array, parent, toString: Boolean) { # {{{
		if !?@fn {
			@buildFunction()
		}

		var module = @module()
		@executeCount += 1

		var args = [$autoEvaluate^^(this, parent, ^), $reificate^^(this, parent, ...), ...arguments]

		// echo(@source)
		// echo(args)
		var mut data = @fn(...args!?)
		// echo(data)

		if toString {
			return data
		}

		try {
			data = SyntaxAnalysis.parseStatements(data + '\n', SyntaxAnalysis.FunctionMode.Method)
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
	function(parent) { # {{{
		if !?@fn {
			@buildFunction()
		}

		return (...arguments) => {
			var args = [$autoEvaluate^^(this, parent, ^), $reificate^^(this, parent, ...)].concat(arguments)

			var mut data = @fn(...args!?)

			try {
				data = SyntaxAnalysis.parseStatements(data + '\n', SyntaxAnalysis.FunctionMode.Method)
			}
			catch error {
				error.fileName = `\(@parent.file())$\(@name)$\(@executeCount)`
				error.message += ` (\(error.fileName):\(error.lineNumber):\(error.columnNumber))`

				throw error
			}

			return data
		}
	} # }}}
	getMark(index) => @marks[index]
	isEnhancementExport() => false
	isExportable() => false
	isInstanceMethod() => false
	isStandardLibrary(): valueof @standardLibrary
	isUsingVariable(name) => false
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

	private {
		buildAuto(name: String, data: Ast(Type), rest: Boolean, fragments) { # {{{
			var ctrl = fragments.newControl().code(`func __ks_auto_\(name)(eval, data)`).step()

			var { path } =
				if rest {
					var resname = `__ks_auto_0`
					var valname = `__ks_auto_1`

					ctrl.line(`var \(resname) = []`)

					var ctrl2 = ctrl.newControl().code(`for var \(valname) in data`).step()

					var { path % subpath } = @buildAuto(data, valname, 2, ctrl2)

					ctrl2
						..line(`\(resname).push(\(subpath))`)
						..done()

					set { path: resname }
				}
				else {
					set @buildAuto(data, 'data', 0, ctrl)
				}

			ctrl
				..line(`return \(path)`)
				..done()
		} # }}}
		buildAuto(data: Ast, varname: String, mut nextIndex: Number, fragments) { # {{{
			match data.kind {
				.ArrayType {
					var resname = `__ks_auto_\(nextIndex)`
					nextIndex += 1
					var valname = `__ks_auto_\(nextIndex)`
					nextIndex += 1

					fragments.line(`var \(resname) = []`)

					if ?#data.properties {
						for var { type }, index in data.properties {
							match ParameterKind.detect(type) {
								.AST {
									fragments.line(`\(resname).push(\(varname).values[\(index)])`)
								}
								.Evaluated {
									fragments.line(`\(resname).push(eval(\(varname).values[\(index)]))`)
								}
								.Mixed {
									NotImplementedException.throw()
								}
							}
						}
					}
					else if ?data.rest {
						var ctrl = fragments.newControl().code(`for var \(valname) in \(varname).values`).step()

						match ParameterKind.detect(data.rest.type) {
							.AST {
								ctrl.line(`\(resname).push(\(valname))`)
							}
							.Evaluated {
								ctrl.line(`\(resname).push(eval(\(valname)))`)
							}
							.Mixed {
								NotImplementedException.throw()
							}
						}

						ctrl.done()
					}

					return { path: resname }
				}
				.UnionType {
					var resname = `__ks_auto_\(nextIndex)`
					nextIndex += 1

					fragments.line(`var mut \(resname) = null`)

					var asts = []
					var evaluateds = []
					var mixeds = []

					for var type in data.types {
						match ParameterKind.detect(type) {
							.AST {
								asts.push(type)
							}
							.Mixed {
								mixeds.push(type)
							}
							else {
								evaluateds.push(type)
							}
						}
					}

					if !?#evaluateds && !?#mixeds {
						return { path: varname }
					}

					var mut ctrl = null

					var block =
						if ?#asts {
							ctrl = fragments.newControl()

							for var ast, index in asts {
								ctrl
									..code('else ') if index > 0
									..code(`if \(varname).kind == __ks_AstKind.\(ast.typeSubtypes[0].name)`).step()
									// ..code(`if \(varname).kind == AstKind.\(ast.typeSubtypes[0].name)`).step()
									..line(`\(resname) = \(varname)`).step()
							}

							ctrl.code('else').step()

							set ctrl
						}
						else {
							set fragments
						}

					if !?#mixeds {
						block.line(`\(resname) = eval(\(varname))`)
					}
					else if ?#evaluateds {
						var ctrl2 = block.newControl()

						match mixeds {
							with var [mixed] {
								@buildTest(mixed, varname, ctrl2)

								var { path } = @buildAuto(mixed, varname, nextIndex, ctrl2)

								ctrl2.line(`\(resname) = \(path)`).step()
							}
							else {
								NotImplementedException.throw()
							}
						}

						ctrl2
							..code('else').step()
							..line(`\(resname) = eval(\(varname))`)
							..done()
					}
					else {
						match mixeds {
							with var [mixed] {
								var { path } = @buildAuto(mixed, varname, nextIndex, block)

								block.line(`\(resname) = \(path)`)
							}
							else {
								NotImplementedException.throw()
							}
						}
					}

					ctrl.done() if ?ctrl

					return { path: resname }
				}
				else {
					NotImplementedException.throw()
				}
			}
		} # }}}
		buildFunction() { # {{{
			if ?@data.source {
				@source = @data.source
			}
			else {
				var builder = KSGeneration.KSWriter.new({
					filters: {
						expression: this.filter^^(false, ^, ^)
						statement: this.filter^^(true, ^, ^)
					}
				})

				var autoMark = builder.mark()
				var line = builder.newLine().code('return func(eval, __ks_reificate')
				var argsMark = line.mark()
				var block = line.code(')').newBlock()

				for var data in @data.parameters {
					var kind = ParameterKind.detect(data)
					var name = data.internal.name
					var rest = $ast.hasModifier(data, .Rest)

					match kind {
						.AST {
							argsMark.code(`, \(if rest set '...' else '')\(name)`)
						}
						.Evaluated {
							argsMark.code(`, mut \(if rest set '...' else '')\(name)`)

							block.line(`\(name) = eval(\(name))`)
						}
						.Mixed {
							argsMark.code(`, mut \(if rest set '...' else '')\(name)`)

							block.line(`\(name) = __ks_auto_\(name)(eval, \(name))`)

							@buildAuto(name, data.type, rest, autoMark)
						}
					}

					if ?data.defaultValue {
						argsMark.code(' = ').expression(data.defaultValue)
					}

					@parameters[name] = kind
				}

				block.line('var mut __ks_src = ""')

				var statements =
					if @data.body.kind == AstKind.Block {
						set @data.body.statements
					}
					else {
						set [{
							kind: AstKind.ExpressionStatement
							attributes: []
							expression: @data.body
							start: @data.start
							end: @data.end
						}]
					}

				for var statement in statements {
					block.statement(statement)
				}

				block.line('return __ks_src').done()

				line.done()

				var mut source = ''

				for var fragment in builder.toArray() {
					source += fragment.code
				}

				// echo(source)
				@source = @compile(source)
				// echo(@source)
			}

			@fn = Syntime.evaluate(@source, Marker, AstKind)
			// @fn = Syntime.evaluate(@source, Marker, Position, Range, VersionData, ModifierKind, ModifierData, AstKind, Ast, OperatorAttribute, OperatorKind, IterationKind, RestrictiveOperatorKind, UnaryTypeOperatorKind, AssignmentOperatorKind, BinaryOperatorKind, UnaryOperatorKind, BinaryOperatorData, IterationData, RestrictiveOperatorData, UnaryOperatorData, UnaryTypeOperatorData, QuoteElementKind, ReificationKind, QuoteElementData, ReificationData, ScopeKind, ScopeData)
		} # }}}
		buildTest(data: Ast, varname: String, fragments) { # {{{
			match data.kind {
				.ArrayType {
					fragments.code(`if \(varname).kind == __ks_AstKind.ArrayExpression`).step()
					// fragments.code(`if \(varname).kind == AstKind.ArrayExpression`).step()
				}
				else {
					NotImplementedException.throw()
				}
			}
		} # }}}
		compile(body: String): String { # {{{
			// echo('compile.function --> ', body)

			var compiler = Compiler.new(`_ks_macro_\(@name)`, {
				libstd: @options.libstd
				register: false
				target: $target
			})

			var source = ```
				import 'npm:@kaoscript/ast'

				extern console, JSON

				require {
					class __ks_Marker
					enum __ks_AstKind
				}

				\(body)
				```
			// var source = ```
			// 	extern console, JSON

			// 	require {
			// 		class __ks_Marker
			// 	}

			// 	require|import 'npm:@kaoscript/ast'

			// 	\(body)
			// 	```

			compiler.compile(source)
			// echo('=- ', compiler.toSource())

			return compiler.toSource()
		} # }}}
		filter(statement, data, mut fragments) { # {{{
			var elements = if statement {
				unless data.kind == AstKind.ExpressionStatement && data.expression.kind == AstKind.QuoteExpression {
					return false
				}

				set data.expression.elements
			}
			else {
				unless data.kind == AstKind.QuoteExpression {
					return false
				}

				set data.elements
			}

			if statement {
				fragments = fragments.newLine().code('__ks_src += ')
			}

			for var element, index in elements {
				if index != 0 {
					fragments.code(' + ')
				}

				match element.kind {
					QuoteElementKind.Expression {
						if element.expression.kind == AstKind.Identifier && @parameters[element.expression.name] == ParameterKind.AST {
							unless !?element.reification {
								SyntaxException.throwInvalidASTReification(this)
							}

							fragments.code('__ks_reificate(').expression(element.expression).code(`, true)`)
						}
						else if !?element.reification {
							fragments.code('__ks_reificate(').expression(element.expression).code(`, null, \(ReificationKind.Expression))`)
						}
						else if element.reification.kind == ReificationKind.Join {
							fragments.code('__ks_reificate(').expression(element.expression).code(`, false, \(element.reification.kind), `).expression(element.separator).code(')')
						}
						else {
							fragments.code('__ks_reificate(').expression(element.expression).code(`, false, \(element.reification.kind))`)
						}
					}
					QuoteElementKind.Literal {
						if element.value[0] == '\\' {
							fragments.code($quote(element.value.substr(1).replace(/\\/g, '\\\\')))
						}
						else {
							fragments.code($quote(element.value.replace(/\\/g, '\\\\')))
						}
					}
					QuoteElementKind.NewLine {
						fragments.code('"\\n"')
					}
				}
			}

			if statement {
				fragments.done()
			}

			return true
		} # }}}
	}
}

class SyntimeFunctionType extends FunctionType {
	static fromAST(data, node: AbstractNode): SyntimeFunctionType { # {{{
		var scope = node.scope()

		return SyntimeFunctionType.new([ParameterType.fromAST(parameter, false, scope, false, null, node) for var parameter in data.parameters], data, node)
	} # }}}
	static import(data, references, scope: Scope, node: AbstractNode): SyntimeFunctionType { # {{{
		var type = SyntimeFunctionType.new(scope)

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
		parameters: [parameter.export() for var parameter in @parameters]
	} # }}}
	matchArguments(arguments: Array, node: AbstractNode) { # {{{
		var assessment = this.assessment('', node)
		var match = Router.matchArguments(assessment, null, arguments, [], node)

		return match is not NoMatchResult
	} # }}}
	matchContentOf(value: SyntimeFunctionType): Boolean { # {{{
		if value.min() < @min() || value.max() > @max() {
			return false
		}

		var params = value.parameters()

		if @parameters.length == params.length {
			for var parameter, i in @parameters {
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
		@ast: Boolean
		// TODO!
		// @data: SyntimeArgument
		@data
		@evalType: Type?
		@node: AbstractNode
		@rawType: Type?
	}
	static build(arguments: [], scope: Scope, node: AbstractNode) { # {{{
		var result = []

		for var argument in arguments {
			result.push(MacroArgument.new(argument, scope, node))
		}

		return result
	} # }}}
	constructor(@data, @scope, @node) { # {{{
		super(scope)

		@ast = @data.kind != AstKind.Operator
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
	isAssignableToVariable(value: ArrayType, anycast: Boolean, nullcast: Boolean, downcast: Boolean, limited: Boolean = false): Boolean { # {{{
		// TODO!
		// return false unless @data.kind == .Ast && @data.data.kind == .ArrayExpression
		return false unless @ast && @data.kind == AstKind.ArrayExpression

		if value.hasRest() {
			var restType = value.getRestType()

			for var data in @data.values {
				unless MacroArgument.new(data, @scope, @node).isAssignableToVariable(restType, false, false, false, limited) {
					return false
				}
			}
		}

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
			'Ast' {
				@rawType ??= Type.getASTNode(@data, @scope, @node)

				return @rawType.isAssignableToVariable(value, anycast, nullcast, downcast, limited)
			}
			else {
				@evalType ??= Type.fromAST(@data, @scope, @node)

				return @evalType.isAssignableToVariable(value, anycast, nullcast, downcast, limited)
			}
		}
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
		if @ast {
			match @data.kind {
				AstKind.ArrayExpression => return 'Array'
				AstKind.Identifier => return 'Identifier'
				AstKind.NumericExpression => return 'Number'
				AstKind.ObjectExpression => return 'Object'
				AstKind.Literal => return 'String'
				else => return 'Expression'
			}
		}
		else {
			echo(this)
			NotImplementedException.throw()
		}
	} # }}}
}

func $resolveSyntimeType(node: BinaryOperatorTypeCasting) { # {{{
	return Type.fromAST(node.data().right, node.parent())
} # }}}
func $resolveSyntimeType(node: VariableDeclaration) { # {{{
	var declarators = node.declarators()

	match declarators {
		with var [declarator] {
			var data = declarator.data()

			if ?data.type {
				return Type.fromAST(data.type, node.parent())
			}
		}
		else {
			NotImplementedException.throw()
		}
	}

	return node.scope().reference('Ast')
} # }}}
func $resolveSyntimeType(node) { # {{{
	return node.scope().reference('Ast')
} # }}}

class CallStatement extends Statement {
	private {
		@macro: SyntimeFunctionDeclaration
		@offsetEnd: Number						= 0
		@offsetStart: Number					= 0
		@statements: Array						= []
	}
	constructor(@data, @parent, @scope = parent.scope(), @macro) { # {{{
		super(data, parent, scope)
	} # }}}
	initiate() { # {{{
		// echo(@data)
		var data = @macro.execute(@data.expression.arguments, this, false)
		// echo(data)

		var offset = @scope.getLineOffset()

		@offsetStart = @scope.line()

		@scope.setLineOffset(@offsetStart)

		var file = `\(@file())!#\(@macro.name())`

		@options = Attribute.configure(data, @options, AttributeTarget.Global, file)

		for var stmtData in data.body {
			@scope.line(stmtData.start.line)

			if var statement ?= $compile.statement(stmtData, this) {
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

		for var statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	isAwait() { # {{{
		for var statement in @statements {
			if statement.isAwait() {
				return true
			}
		}

		return false
	} # }}}
	override isExit(mode) { # {{{
		for var statement in @statements {
			if statement.isExit(mode) {
				return true
			}
		}

		return false
	} # }}}
	override isUsingVariable(name, bleeding) { # {{{
		for var statement in @statements {
			if statement.isUsingVariable(name, bleeding) {
				return true
			}
		}

		return false
	} # }}}
	toFragments(fragments, mode) { # {{{
		for var statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} # }}}
}
