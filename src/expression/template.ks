class TemplateExpression extends Expression {
	private {
		@computing: Boolean		= false
		@elements: Array		= []
		@isString: Boolean		= true
	}
	analyse() { # {{{
		for var data in @data.elements {
			var element = $compile.expression(data, this)

			element.analyse()

			@elements.push(element)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var element, index in @elements {
			element.prepare(@scope.reference('String'), TargetMode::Permissive)

			if @isString {
				var type = element.type()

				if !type.isString() || type.isNullable() {
					@isString = false
				}
			}
		}
	} # }}}
	translate() { # {{{
		for var element in @elements {
			element.translate()
		}
	} # }}}
	computing(@computing)
	isUsingVariable(name) { # {{{
		for var element in @elements {
			if element.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isComputed() => @elements.length > 1 || !@isString
	override listNonLocalVariables(scope, variables) { # {{{
		for var element in @elements {
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

			for var element in @elements from 1 {
				fragments.code(' + ').wrap(element)
			}
		}
		else {
			fragments.code($runtime.helper(this), '.concatString(').wrap(@elements[0])

			for var element, index in @elements from 1 {
				fragments.code(', ').wrap(element)
			}

			fragments.code(')')
		}
	} # }}}
	type() => @scope.reference('String')
}
