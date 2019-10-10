class TemplateExpression extends Expression {
	private {
		_computing: Boolean		= false
		_elements: Array		= []
		_types: Array			= []
	}
	analyse() { // {{{
		for const data in @data.elements {
			const element = $compile.expression(data, this)

			element.analyse()

			@elements.push(element)
		}
	} // }}}
	prepare() { // {{{
		for const element in @elements {
			element.prepare()

			@types.push(element.type().isString() && !element.type().isNullable())
		}
	} // }}}
	translate() { // {{{
		for const element in @elements {
			element.translate()
		}
	} // }}}
	computing(@computing)
	isUsingVariable(name) { // {{{
		for const element in @elements {
			if element.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	isComputed() => @elements.length > 1 || !@types[0]
	toFragments(fragments, mode) { // {{{
		if @elements.length == 0 {
			fragments.code('""')
		}
		else if @computing {
			for const element, index in @elements {
				if index == 0 {
					fragments.wrap(element)
				}
				else {
					fragments.code(' + ').wrap(element)
				}
			}
		}
		else if @elements.length == 1 {
			if @types[0] {
				@elements[0].toStringFragments(fragments)
			}
			else {
				fragments.code('"" + ').wrap(@elements[0])
			}
		}
		else {
			for const element, index in @elements {
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