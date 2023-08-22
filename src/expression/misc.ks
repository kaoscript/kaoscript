class TempReusableExpression extends Expression {
	private {
		@count: Number			= 0
		@value
	}
	constructor(@value, parent) { # {{{
		super({}, parent)
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	isComputed() => @count == 0 && @value is not String && @value.isComposite()
	toFragments(fragments, mode) { # {{{
		if @value is String {
			fragments.code(@value)
		}
		else if @count == 0 && @value.isComposite() {
			fragments.compileReusable(@value)
		}
		else {
			fragments.compile(@value)
		}

		@count += 1
	} # }}}
}

class TempMemberExpression extends Expression {
	private {
		@computed: Boolean		= false
		@object
		@offset: Number			= 0
		@property
		@reusable: Boolean		= false
		@reuseName: String?		= null
	}
	constructor(@object, @property, @computed, @parent, @scope) { # {{{
		super({}, parent, scope)
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} # }}}
	isComposite() => true
	offset(@offset): valueof this
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @computed {
			if @offset > 0 {
				fragments
					.compile(@object)
					.code('[')
					.compile(@property)
					.code(` + \(@offset)]`)
			}
			else {
				fragments
					.compile(@object)
					.code('[')
					.compile(@property)
					.code(']')
			}
		}
		else {
			fragments
				.compile(@object)
				.code('.')
				.compile(@property)
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} # }}}
}
