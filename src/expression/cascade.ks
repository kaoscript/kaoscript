enum CascadeMode {
	Default
	Cascade
	Inline
}

class CascadeExpression extends Expression {
	private late {
		@beforehands: Array				= []
		@cascade
		@declarator?
		@expressions: Array				= []
		@mode: CascadeMode				= .Default
		@object
		@type: Type
		@valueName: String?				= null
	}
	override analyse() { # {{{
		var mut statement = @parent

		while statement is not Statement {
			if @mode == .Default {
				if statement is CascadeExpression {
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
		else if @parent is not Statement {
			statement.addBeforehand(this)
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
			return $ast.identifier(@valueName)
		}

		return null
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @mode == .Inline {
			fragments.compile(@object)
		}
		else {
			fragments.code(@valueName)
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
			fragments
				.newLine()
				.code(`\(@valueName) = `)
				.compile(@object)
				.done()

			@toStatementFragments(fragments, mode)
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for var expression in @expressions {
			fragments.newLine().compile(expression).done()
		}
	} # }}}
	type() => @type
}
