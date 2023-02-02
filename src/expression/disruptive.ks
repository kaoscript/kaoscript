class DisruptiveExpression extends Expression {
	private late {
		@condition
		@declarator
		@disruptedExpression
		@insitu: Boolean						= false
		@mainExpression
		@type: Type
		@valueName: String?						= null
	}
	override analyse() { # {{{
		var mut statement = @parent
		var mut declaration = null

		while statement is not Statement {
			if statement is VariableDeclaration {
				declaration = statement
			}

			statement = statement.parent()
		}

		if ?declaration {
			var declarators = declaration.declarators()
			var declarator = declarators[0]

			if declarators.length == 1 && declarator is VariableIdentifierDeclarator {
				@declarator = declarator
				// @insitu = true
			}
		}

		if @insitu {
			statement.addAfterward(this)
		}
		else {
			statement.addBeforehand(this)
		}

		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@scope.line(@data.mainExpression.start.line)
		@mainExpression = $compile.expression(@data.mainExpression, this)
		@mainExpression.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition.prepare(@scope.reference('Boolean'), TargetMode::Permissive)

		@condition.acquireReusable(false)
		@condition.releaseReusable()

		@scope.line(@data.mainExpression.start.line)
		@mainExpression.prepare(AnyType.NullableUnexplicit)

		var mType = @mainExpression.type()

		if @insitu {
			var variable = @declarator.variable()

			@valueName = variable.getSecureName()

			variable.setRealType(mType)
		}
		else {
			var scope = @statement().scope()

			@valueName = scope.acquireTempName()

			scope.define(@valueName, false, mType, this)
		}

		@scope.line(@data.disruptedExpression.start.line)
		@disruptedExpression = $compile.expression(@data.disruptedExpression, this)
		@disruptedExpression.analyse()
		@disruptedExpression.prepare(target, targetMode)

		var dType = @disruptedExpression.type()

		@type = Type.union(@scope, mType, dType)
	} # }}}
	override translate() { # {{{
		@condition.translate()
		@mainExpression.translate()
		@disruptedExpression.translate()
	} # }}}
	override getASTReference(name) { # {{{
		if name == 'main' {
			return $ast.identifier(@valueName)
		}

		return null
	} # }}}
	getValueName() => @valueName
	isInSituStatement() => @insitu
	toFragments(fragments, mode) { # {{{
		fragments.code(@valueName)
	} # }}}
	toAfterwardFragments(fragments, mode) { # {{{
		@toStatementFragments(fragments, mode)
	} # }}}
	toBeforehandFragments(fragments, mode) { # {{{
		@toStatementFragments(fragments, mode)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		fragments.newLine().code(`\(@valueName) = `).compile(@mainExpression).done()

		var ctrl = fragments.newControl()

		if @data.operator.kind == RestrictiveOperatorKind::If {
			ctrl.code(`if(`).compileCondition(@condition)
		}
		else {
			ctrl.code(`if(!`).wrapCondition(@condition)
		}

		ctrl.code(')').step()

		ctrl.newLine().code(`\(@valueName) = `).compile(@disruptedExpression).done()

		ctrl.done()
	} # }}}
	type() => @type
}
