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
				/* const type = $type.type(@data.elements[index], @scope, this)
				
				if type?.typeName?.kind == NodeKind::Identifier && (type.typeName.name == 'String' || type.typeName.name == 'string') {
					fragments.wrap(element)
				}
				else {
					fragments.code('"" + ').wrap(element)
				} */
				fragments.wrap(element)
			}
			else {
				fragments.code(' + ').wrap(element)
			}
		}
	} // }}}
}