enum RollingMode {
	Default
	Cascade
	Inline
	Insitu
	Statement
}

class RollingExpression extends Expression {
	private late {
		@beforehands: Array				= []
		@cascade
		@declarator?
		@expressions: Array				= []
		@insitu: Boolean				= false
		@mode: RollingMode				= .Default
		@nullable: Boolean				= false
		@object
		@type: Type
		@valueName: String?				= null
	}
	override analyse() { # {{{
		var mut statement = @parent

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Nullable {
				@nullable = true
			}
		}

		if @parent is ExpressionStatement {
			statement.addBeforehand(this)
		}
		else {
			while statement is not Statement {
				if @mode == .Default {
					if statement is RollingExpression {
						@cascade = statement
						@mode = .Cascade
					}
					else if statement is VariableDeclaration {
						var declarators = statement.declarators()
						var declarator = declarators[0]

						if declarators.length == 1 && declarator is VariableIdentifierDeclarator {
							@declarator = declarator
							@mode = .Inline
						}
					}
				}

				statement = statement.parent()
			}

			if @mode == .Inline {
				statement.addAfterward(this)
			}
			else if @mode == .Cascade {
				@cascade.addBeforehand(this)
			}
			else if @parent is not Statement || @parent is ReturnStatement {
				statement.addBeforehand(this)
			}
			else if @parent.isInline() {
				@mode = .Insitu
			}
		}

		@object = $compile.expression(@data.object, this)
		@object.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@object.prepare(target, targetMode)

		@type = @object.type()

		if @mode == .Inline {
			var variable = @declarator.variable()

			@valueName = variable.getSecureName()

			variable.setRealType(@type)
		}
		else if @object is IdentifierLiteral {
			@valueName = @object.name()
		}
		else {
			var scope = @statement().scope()

			@valueName = scope.acquireTempName()

			scope.define(@valueName, true, @type, true, this)
		}

		for var data in @data.expressions {
			var expression = $compile.expression(data, this)
			expression.analyse()
			expression.prepare()

			@expressions.push(expression)
		}

		if @mode == .Inline && #@beforehands {
			@statement().addBeforehand(this)
		}
	} # }}}
	override translate() { # {{{
		@object.translate()

		for var expression in @expressions {
			expression.translate()
		}
	} # }}}
	addBeforehand(node) { # {{{
		@beforehands.push(node)
	} # }}}
	override getASTReference(name) { # {{{
		if name == 'main' {
			return IdentifierLiteral.new($ast.identifier(@valueName), this, @scope)
		}

		return null
	} # }}}
	toFragments(fragments, mode) { # {{{
		match @mode {
			.Inline {
				fragments.compile(@object)
			}
			.Insitu {
				fragments
					.code(`(\(@valueName) = `)
					.compile(@object)

				for var expression in @expressions {
					fragments.code(', ').compile(expression)
				}

				fragments.code(`, \(@valueName))`)
			}
			else {
				fragments.code(@valueName)
			}
		}
	} # }}}
	toAfterwardFragments(fragments, mode) { # {{{
		@toStatementFragments(fragments, mode)
	} # }}}
	toBeforehandFragments(fragments, mode) { # {{{
		for var beforehand in @beforehands {
			beforehand.toBeforehandFragments(fragments, mode)
		}

		if @mode != .Inline {
			if @object is not IdentifierLiteral {
				fragments
					.newLine()
					.code(`\(@valueName) = `)
					.compile(@object)
					.done()
			}

			if @parent is not ExpressionStatement {
				@toStatementFragments(fragments, mode)
			}
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @nullable {
			var ctrl = fragments
				.newControl()
				.code(`if(\($runtime.type(this)).isValue(\(@valueName)))`)
				.step()

			for var expression in @expressions {
				ctrl.newLine().compile(expression).done()
			}

			ctrl.done()
		}
		else {
			for var expression in @expressions {
				fragments.newLine().compile(expression).done()
			}
		}
	} # }}}
	type() => @type
}
