class SyntimeStatement extends Statement {
	private {
		@marks: Array								= []
		@macros: SyntimeFunctionDeclaration[]{}		= {}
		@macroScope: MacroScope
		@newData: Ast(StatementList)?				= null
		@newReferences: Type{}						= {}
		@offsetEnd: Number							= 0
		@offsetStart: Number						= 0
		@passedReferences							= {}
		@statements									= []
	}
	override constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		@macroScope = @module().compiler().getMacroScope(this)

		var builder = KSGeneration.KSWriter.new({
			filters: {
				expression: @filterExpression
				statement: @filterStatement
			}
		})

		var refMark = builder.mark()

		builder.line('var mut __ks_src = ""')

		var statements =
			// TODO!
			// match @data.body.kind
			// 	AstKind.Block {
			// 		set @data.body.statements
			// 	}
			// 	AstKind.ExpressionStatement {
			// 		set @data.body
			// 	}
			// 	else {
			// 		set [{
			// 			kind: AstKind.ExpressionStatement
			// 			attributes: []
			// 			expression: @data.body
			// 			start: @data.start
			// 			end: @data.end
			// 		}]
			// 	}
			// }
			if @data.body.kind == AstKind.Block {
				set @data.body.statements
			}
			else if @data.body.kind == AstKind.ExpressionStatement {
				set [@data.body]
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
			builder.statement(statement)
		}

		builder.line('return __ks_src')

		for var type, name of @newReferences {
			var line = refMark.newLine().code('export ')

			type.toSyntimeFragments(name, line)

			line.done()
		}

		var references = []

		if ?#@passedReferences {
			var line = refMark.newLine().code('require')
			var block = line.newBlock()

			for var reference, name of @passedReferences {
				block.line(name)

				references.push(reference)
			}

			block.done()
			line.done()
		}

		var mut source = ''

		for var fragment in builder.toArray() {
			source += fragment.code
		}

		var compiled = @compile(source)

		var result = Syntime.evaluate(compiled, Position, Range, VersionData, ModifierKind, ModifierData, AstKind, Ast, OperatorAttribute, OperatorKind, IterationKind, RestrictiveOperatorKind, UnaryTypeOperatorKind, AssignmentOperatorKind, BinaryOperatorKind, UnaryOperatorKind, BinaryOperatorData, IterationData, RestrictiveOperatorData, UnaryOperatorData, UnaryTypeOperatorData, QuoteElementKind, ReificationKind, QuoteElementData, ReificationData, ScopeKind, ScopeData, this, @unquote, ...references)

		if ?#result {
			try {
				@newData = SyntaxAnalysis.parseStatements(result + '\n', SyntaxAnalysis.FunctionMode.Method)
			}
			catch error {
				// error.fileName = `\(@parent.file())$\(@name)$\(@executeCount)`
				error.message += ` (\(error.fileName):\(error.lineNumber):\(error.columnNumber))`

				throw error
			}
		}
	} # }}}
	initiate() { # {{{
		return unless ?@newData

		Attribute.configure(@newData, @parent._options, AttributeTarget.Global, @file())

		var offset = @scope.getLineOffset()

		@offsetStart = @scope.line()

		@scope.setLineOffset(@offsetStart)

		for var data in @newData.body {
			@scope.line(data.start.line)

			if var statement ?= $compile.statement(data, this) {
				@statements.push(statement)

				statement.initiate()
			}
		}

		@scope.line(@newData.end.line)

		@offsetEnd = offset + @scope.line() - @offsetStart

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	initiate(compiler: Compiler): Void { # {{{
		var scope = compiler.module().scope()

		for {
			var declarations, name of @macros
			var declaration in declarations
		}
		then {
			scope.addSyntimeFunction(name, declaration)
		}
	} # }}}
	postInitiate() { # {{{
		for var statement in @statements {
			statement.postInitiate()
		}
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

			statement.prepare()
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
					name: '__ks_context'
				}
				property: {
					kind: AstKind.Identifier
					name: 'getMark'
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
	export(recipient, enhancement: Boolean = false) { # {{{
		for var statement in @statements when statement.isExportable() {
			statement.export(recipient, enhancement)
		}
	} # }}}
	getMark(index) => @marks[index]
	isUsingStaticVariableBefore(class: String, varname: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariableBefore(name: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	mode(): TimeMode => TimeMode.Syntime
	name() => '__ks__'
	recipient() => @module()
	registerSyntimeFunction(name, macro) => @parent.registerSyntimeFunction(name, macro)
	toFragments(fragments, mode) { # {{{
		for var statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} # }}}
	private {
		compile(body: String): String { # {{{
			var compiler = Compiler.new(
				`__ks__`
				{
					libstd: @options.libstd
					register: false
					target: $target
				}
				null
				null
				@macroScope
			)

			var source = ```
				require|import 'npm:@kaoscript/ast'

				extern class Context {
					getMark(index: Number): Ast
				}

				require {
					var __ks_context: Context
					func __ks_unquote(data, reification: ReificationKind? = null): String
				}

				\(body)
				```

			// echo('stmt --> ', source)
			compiler
				..setTimeContext(this)
				..compile(source)
			// echo('=- ', compiler.toSource())

			return compiler.toSource()
		} # }}}
		filterExpression(data, fragments): Boolean { # {{{
			match data.kind {
				AstKind.CallExpression {
					if {
						var path ?= $ast.path(data.callee)
						var functions ?= @scope.getSyntimeFunction(path)
					}
					then {
						@macros[path] = functions

						data.kind = AstKind.SyntimeCallExpression

						return false
					}
				}
				AstKind.QuoteExpression {
					@filterQuote(data, data.elements, fragments)

					return true
				}
				AstKind.SyntimeCallExpression {
					if {
						var path ?= $ast.path(data.callee)
						var functions ?= @scope.getSyntimeFunction(path)
					}
					then {
						@macros[path] = functions

						return false
					}
				}
			}

			return false
		} # }}}
		filterQuote(data, elements, fragments): Void { # {{{
			for var element, index in elements {
				if index != 0 {
					fragments.code(' + ')
				}

				match element.kind {
					QuoteElementKind.Expression {
						fragments.code('__ks_unquote(').expression(element.expression)

						if ?element.reification {
							NotImplementedException.throw()
						}

						fragments.code(`)`)
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
		} # }}}
		filterReference(data) { # {{{
			match data.kind {
				AstKind.Identifier {
					var name = data.name

					return if ?@newReferences[name]

					if var reference ?= @macroScope.getEvalReference(name) {
						@passedReferences[name] = reference
					}
					else if {
						var variable ?= @scope.getVariable(name, -1)
						var type ?= variable.declaration().prepareSyntimeType(@macroScope)
					}
					then {
						@newReferences[name] = type
					}
				}
				AstKind.MemberExpression {
					@filterReference(data.object)
				}
			}
		} # }}}
		filterStatement(data, fragments): Boolean { # {{{
			match data.kind {
				AstKind.ExpressionStatement when data.expression.kind == AstKind.QuoteExpression {
					var line = fragments.newLine().code('__ks_src += ')

					@filterQuote(data, data.expression.elements, line)

					line.done()

					return true
				}
				AstKind.ExpressionStatement {
					@filterExpression(data.expression, fragments)
				}
				AstKind.ForStatement {
					for var iteration in data.iterations {
						@filterReference(iteration.expression)
					}
				}
			}

			return false
		} # }}}
		isASTVariable(name: String): Boolean { # {{{
			return false
		} # }}}
		unquote(data, reification? = null) { # {{{
			if data is Ast {
				return $generate(this, this, data)
			}
			else {
				var context = {
					data: ''
				}

				$serialize(this, data, context)

				return context.data
			}
		} # }}}
	}
}
