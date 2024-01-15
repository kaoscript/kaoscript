class SetStatement extends Statement {
	private late {
		@exitLabel: String?
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
	isContinuousInlineReturn() => true
	override isExit(mode) => mode ~~ .Expression
	isExpectingType() => true
	isInline() => @inline
	override setExitLabel(label % @exitLabel)
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

			if ?@exitLabel {
				fragments.line(`break \(@exitLabel)`)
			}
		}
	} # }}}
	type() => @type
}
