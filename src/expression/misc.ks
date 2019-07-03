class TempReusableExpression extends Expression {
	private {
		_count: Number			= 0
		_value
	}
	constructor(@value, parent) { // {{{
		super({}, parent)
	} // }}}
	analyse()
	prepare()
	translate()
	isComputed() => @count == 0 && @value.isComposite()
	toFragments(fragments, mode) { // {{{
		if @count == 0 && @value.isComposite() {
			fragments.compileReusable(@value)
		}
		else {
			fragments.compile(@value)
		}

		++@count
	} // }}}
}

class TempMemberExpression extends Expression {
	private {
		_computed: Boolean		= false
		_object
		_property
		_reusable: Boolean		= false
		_reuseName: String?		= null
	}
	constructor(@object, @property, @computed, @parent, @scope) { // {{{
		super({}, parent, scope)
	} // }}}
	analyse()
	prepare()
	translate()
	acquireReusable(acquire) { // {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} // }}}
	isComposite() => true
	releaseReusable() { // {{{
		if @reuseName? {
			@scope.releaseTempName(@reuseName)
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @computed {
			fragments
				.compile(@object)
				.code('[')
				.compile(@property)
				.code(']')
		}
		else {
			fragments
				.compile(@object)
				.code('.')
				.compile(@property)
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} // }}}
}