class ConditionalExpression extends Expression {
	private late {
		_condition
		_whenFalse
		_whenTrue
		_type: Type
	}
	analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@whenTrue = $compile.expression(@data.whenTrue, this)
		@whenTrue.analyse()

		@whenFalse = $compile.expression(@data.whenFalse, this)
		@whenFalse.analyse()
	} # }}}
	override prepare(target) { # {{{
		@condition.prepare()

		for var data, name of @condition.inferTypes({}) {
			@scope.updateInferable(name, data, this)
		}

		@whenTrue.prepare()
		@whenFalse.prepare()

		var t = @whenTrue.type()
		var f = @whenFalse.type()

		if t.equals(f) {
			@type = t
		}
		else if f.isNull() {
			@type = t.setNullable(true)
		}
		else if t.isNull() {
			@type = f.setNullable(true)
		}
		else {
			@type = Type.union(@scope, t, f)
		}
	} # }}}
	translate() { # {{{
		@condition.translate()
		@whenTrue.translate()
		@whenFalse.translate()
	} # }}}
	isComputed() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @whenTrue.isUsingVariable(name) || @whenFalse.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@condition.listNonLocalVariables(scope, variables)
		@whenTrue.listNonLocalVariables(scope, variables)
		@whenFalse.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.wrapBoolean(@condition)
			.code(' ? ')
			.compile(@whenTrue)
			.code(' : ')
			.compile(@whenFalse)
	} # }}}
	type() => @type
}
