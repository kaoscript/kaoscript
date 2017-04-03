class ReturnStatement extends Statement {
	private {
		_value = null
	}
	analyse() { // {{{
		if @data.value? {
			@value = $compile.expression(@data.value, this)
			
			@value.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @value != null {
			@value.prepare()
		}
	} // }}}
	translate() { // {{{
		if @value != null {
			@value.translate()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if mode == Mode::Async {
			if @value != null {
				fragments
					.newLine()
					.code('return __ks_cb(null, ')
					.compile(@value)
					.code(')')
					.done()
			}
			else {
				fragments.line('return __ks_cb()')
			}
		}
		else {
			if @value != null {
				fragments
					.newLine()
					.code('return ')
					.compile(@value)
					.done()
			}
			else {
				fragments.line('return', @data)
			}
		}
	} // }}}
	type() => @value.type()
}