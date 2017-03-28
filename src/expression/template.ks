class TemplateExpression extends Expression {
	private {
		_elements
	}
	analyse() { // {{{
		@elements = []
		for element in @data.elements {
			@elements.push(element = $compile.expression(element, this))
			
			element.analyse()
		}
	} // }}}
	prepare() { // {{{
		for element in @elements {
			element.prepare()
		}
	} // }}}
	translate() { // {{{
		for element in @elements {
			element.translate()
		}
	} // }}}
	isComputed() => @elements.length > 1
	toFragments(fragments, mode) { // {{{
		for element, index in @elements {
			if index == 0 {
				/* console.log(element)
				console.log(element.type()) */
				if element.type().isString() {
					fragments.wrap(element)
				}
				else {
					fragments.code('"" + ').wrap(element)
				}
			}
			else {
				fragments.code(' + ').wrap(element)
			}
		}
	} // }}}
	type() => Type.String
}