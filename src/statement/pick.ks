class PickStatement extends Statement {
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

		@type = @value.type().asReference()
	} # }}}
	override translate() { # {{{
		@value.translate()
	} # }}}
	isExit() => true
	isExpectingType() => true
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
