class TemplateExpression extends Expression {
	private {
		_elements
	}
	analyse() { // {{{
		this._elements = [$compile.expression(element, this) for element in this._data.elements]
	} // }}}
	fuse() { // {{{
	} // }}}
	isComputed() => this._elements.length > 1
	toFragments(fragments, mode) { // {{{
		for element, index in this._elements {
			fragments.code(' + ') if index
			
			fragments.compile(element)
		}
	} // }}}
}