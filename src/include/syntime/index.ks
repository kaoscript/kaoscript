namespace Syntime {
	extern eval

	enum ParameterKind {
		AST
		Evaluated
		Mixed

		// TODO!
		// static detect(data: Ast(ArrayType)): ParameterKind { # {{{
		// 	var mut result = null

		// 	for var value in data.values {
		// 		var kind = ParameterKind.detect(value)

		// 		if !?result {
		// 			result = kind
		// 		}
		// 		else if kind == .Mixed || result != kind {
		// 			return .Mixed
		// 		}
		// 	}

		// 	return result
		// } # }}}
		// static detect(data: Ast(Parameter)): ParameterKind { # {{{
		// 	if ?data.type {
		// 		return ParameterKind.detect(data.type)
		// 	}
		// 	else {
		// 		return .AST
		// 	}
		// } # }}}
		// static detect(data: Ast(TypeReference)): ParameterKind { # {{{
		// 	if data.typeName.name == 'Ast' {
		// 		return .AST
		// 	}
		// 	else {
		// 		return .Evaluated
		// 	}
		// } # }}}
		// static detect(data: Ast): ParameterKind { # {{{
		// 	return .Evaluated
		// } # }}}
		static detect(data: Ast): ParameterKind { # {{{
			// TODO!
			// match data {
			// 	is Ast(ArrayType) {
			// 		var mut result = ParameterKind.Evaluated

			// 		for var value in data.values {
			// 			var kind = ParameterKind.detect(value)

			// 			if kind == .Mixed || result != kind {
			// 				return .Mixed
			// 			}
			// 		}

			// 		if ?data.rest {
			// 			var kind = ParameterKind.detect(data.rest.type)

			// 			if kind == .Mixed || result != kind {
			// 				return .Mixed
			// 			}
			// 		}

			// 		return result
			// 	}
			// 	is Ast(Parameter) {
			// 		if ?data.type {
			// 			return ParameterKind.detect(data.type)
			// 		}
			// 		else {
			// 			return .AST
			// 		}
			// 	}
			// 	is Ast(TypeReference) {
			// 		if data.typeName is Ast(Identifier) && data.typeName.name == 'Ast' {
			// 			return .AST
			// 		}
			// 		else {
			// 			return .Evaluated
			// 		}
			// 	}
			// 	else {
			// 		return .Evaluated
			// 	}
			// }
			match data.kind {
				.ArrayType {
					// TODO!
					// var mut result = .Evaluated
					var mut result = ParameterKind.Evaluated

					for var property in data.properties {
						var kind = ParameterKind.detect(property.type)

						if kind == .Mixed || result != kind {
							return .Mixed
						}
					}

					if ?data.rest {
						var kind = ParameterKind.detect(data.rest.type)

						if kind == .Mixed || result != kind {
							return .Mixed
						}
					}

					return result
				}
				.Parameter {
					if ?data.type {
						return ParameterKind.detect(data.type)
					}
					else {
						return .AST
					}
				}
				.PropertyType {
					return ParameterKind.detect(data.type)
				}
				.TypeReference {
					if data.typeName?.name == 'Ast' {
						return .AST
					}
					else {
						return .Evaluated
					}
				}
				.UnionType {
					var mut result = ParameterKind.detect(data.types[0])

					if result == .Mixed {
						return .Mixed
					}

					for var type in data.types from 1 {
						var kind = ParameterKind.detect(type)

						if kind == .Mixed || result != kind {
							return .Mixed
						}
					}

					return result
				}
				else {
					return .Evaluated
				}
			}
		} # }}}
	}

	struct Marker {
		index: Number
	}

	type NEResult = {
		variant ok: Boolean {
			false, N {
			}
			true, Y {
				value
			}
		}
	}

	var $target = if parseInt(/^v(\d+)\./.exec(process.version)[1]) >= 6 set 'ecma-v6' else 'ecma-v5'

	include './function.ks'
	include './statement.ks'

	export {
		func callExpression(data, parent, scope) { # {{{
			if var path ?= $ast.path(data.callee) {
				if var functions ?= scope.getSyntimeFunction(path) {
					var arguments = MacroArgument.build(data.arguments, functions[0].scope(), parent)

					for var function in functions {
						if function.matchArguments(arguments) {
							var result = function.execute(data.arguments, parent, false)

							match #result.body {
								1 when result.body[0].kind == AstKind.ExpressionStatement {
									var expression = $compile.expression(result.body[0].expression, parent)

									expression.setAttributes(result.body[0].attributes)

									return expression
								}
								else {
									throw NotImplementedException.new(parent)
								}
							}
						}
					}

					ReferenceException.throwNoMatchingMacro(path, arguments, parent)
				}
			}

			return CallExpression.new(data, parent, scope)
		} # }}}

		func callStatement(data, parent, scope) { # {{{
			if var path ?= $ast.path(data.expression.callee) {
				if var functions ?= scope.getSyntimeFunction(path) {
					var arguments = MacroArgument.build(data.expression.arguments, functions[0].scope(), parent)

					for var function in functions {
						if function.matchArguments(arguments) {
							return CallStatement.new(data, parent, scope, function)
						}
					}

					ReferenceException.throwNoMatchingMacro(path, arguments, parent)
				}
			}

			return ExpressionStatement.new(data, parent, scope)
		} # }}}

		func callSyntimeExpression(data, parent, scope, isStatement: Boolean = false) { # {{{
			if var path ?= $ast.path(data.callee) {
				if var functions ?= scope.getSyntimeFunction(path) {
					var arguments = MacroArgument.build(data.arguments, functions[0].scope(), parent)
					var context = parent.module().getTimeContext()

					for var function in functions {
						if function.matchArguments(arguments) {
							if !isStatement && context?.mode() == TimeMode.Syntime {
								var type = $resolveSyntimeType(parent)

								if type.isString() {
									var result = function.execute(data.arguments, parent, true)

									return StringLiteral.new({ value: result }, parent)
								}
								else {
									// TODO!
									// var result = function.execute(data.arguments, parent, false)
									var r = function.execute(data.arguments, parent, false)

									return $compile.expression(context.addMark(r), parent)
								}
							}

							var result = function.execute(data.arguments, parent, false)

							var node =
								if #result.body == 1 {
									var body = result.body[0]

									match body.kind {
										AstKind.ExpressionStatement {
											if isStatement {
												set $compile.statement(body, parent)
											}
											else {
												var expression = $compile.expression(body.expression, parent)

												expression.setAttributes(body.attributes)

												set expression
											}
										}
										else {
											throw NotImplementedException.new(parent)
										}
									}
								}
								else {
									throw NotImplementedException.new(parent)
								}

							var nScope = node.scope()
							var offset = nScope.line()

							nScope
								..setLineOffset(offset)
								..line(1)

							return node
						}
					}
				}

				ReferenceException.throwNoMatchingMacro(path, parent)
			}

			NotSupportedException.throw(parent)
		} # }}}

		func evaluate(source: String, ...arguments): Function { # {{{
			return eval(source)(...arguments)
		} # }}}

		SyntimeFunctionDeclaration
		SyntimeStatement
		$target => target
	}
}
