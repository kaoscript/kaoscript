class TemplateExpression extends Expression {
	private {
		_computing: Boolean		= false
		_elements: Array
		_types: Array
	}
	analyse() { // {{{
		@elements = []
		for element in @data.elements {
			@elements.push(element = $compile.expression(element, this))

			element.analyse()
		}
	} // }}}
	prepare() { // {{{
		@types = []
		for element in @elements {
			element.prepare()

			@types.push(element.type().isString())
		}
	} // }}}
	translate() { // {{{
		for element in @elements {
			element.translate()
		}
	} // }}}
	computing(@computing)
	isComputed() => @elements.length > 1
	toFragments(fragments, mode) { // {{{
		if @computing {
			for element, index in @elements {
				if index == 0 {
					fragments.wrap(element)
				}
				else {
					fragments.code(' + ').wrap(element)
				}
			}
		}
		else {
			for element, index in @elements {
				if index == 0 {
					if @types[index] {
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
		}
	} // }}}
	type() => @scope.reference('String')
}