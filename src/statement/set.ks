class SetStatement extends Statement {
	private late {
		@gateway
		@inline: Boolean
		@value
		@type: Type				= AnyType.NullableUnexplicit
	}
	override analyse() { # {{{
		var mut parent = @parent
		while parent is not IfExpression | MatchExpression {
			parent = parent.parent()
		}

		@inline = parent.isInline()
		@gateway = parent

		@value = $compile.expression(@data.value, this)

		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target, TargetMode.Permissive)

		@value.acquireReusable(false)
		@value.releaseReusable()

		@assignTempVariables(@scope!?)

		@type = @value.type().asReference()
	} # }}}
	override translate() { # {{{
		@value.translate()
	} # }}}
	override assignTempVariables(scope) => @parent.parent().assignTempVariables(scope)
	isExit() => true
	isExpectingType() => true
	isInline() => @inline
	toFragments(fragments, mode) { # {{{
		if @inline {
			fragments.compile(@value)
		}
		else {
			fragments
				.newLine()
				.code(`\(@gateway.getValueName()) = `)
				.compile(@value)
				.done()
		}
	} # }}}
	type() => @type
}
