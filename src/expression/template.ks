class TemplateExpression extends Expression {
	private {
		_elements
	}
	analyse() { // {{{
		@elements = [$compile.expression(element, this) for element in @data.elements]
	} // }}}
	fuse() { // {{{
	} // }}}
	isComputed() => @elements.length > 1
	toFragments(fragments, mode) { // {{{
		for element, index in @elements {
			if index == 0 {
				/* const type = $type.type(@data.elements[index], @scope, this)
				
				if type?.typeName?.kind == Kind::Identifier && (type.typeName.name == 'String' || type.typeName.name == 'string') {
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