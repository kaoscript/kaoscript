class TemplateExpression extends Expression {
	private {
		_computing: Boolean		= false
		_elements: Array		= []
		_isString: Boolean		= true
	}
	analyse() { # {{{
		for const data in @data.elements {
			const element = $compile.expression(data, this)

			element.analyse()

			@elements.push(element)
		}
	} # }}}
	prepare() { # {{{
		for const element, index in @elements {
			element.prepare()

			if @isString {
				const type = element.type()

				if !type.isString() || type.isNullable() {
					@isString = false
				}
			}
		}
	} # }}}
	translate() { # {{{
		for const element in @elements {
			element.translate()
		}
	} # }}}
	computing(@computing)
	isUsingVariable(name) { # {{{
		for const element in @elements {
			if element.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isComputed() => @elements.length > 1 || !@isString
	override listNonLocalVariables(scope, variables) { # {{{
		for const element in @elements {
			element.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @elements.length == 0 {
			fragments.code('""')
		}
		else if @elements.length == 1 {
			if @computing {
				fragments.wrap(@elements[0])
			}
			else if @isString {
				@elements[0].toStringFragments(fragments)
			}
			else {
				fragments.code($runtime.helper(this), '.toString(').compile(@elements[0]).code(')')
			}
		}
		else if @isString {
			@elements[0].toStringFragments(fragments)

			for const element in @elements from 1 {
				fragments.code(' + ').wrap(element)
			}
		}
		else {
			fragments.code($runtime.helper(this), '.concatString(').wrap(@elements[0])

			for const element, index in @elements from 1 {
				fragments.code(', ').wrap(element)
			}

			fragments.code(')')
		}
	} # }}}
	type() => @scope.reference('String')
}
