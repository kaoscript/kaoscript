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
			element
				..unflagAssertable()
				..prepare(@scope.reference('String'), TargetMode.Permissive)

			if @isString {
				var type = element.type()

				if type.isString() || (type.isEnum() && type.canBeString()) {
					@isString = !type.isNullable()
				}
				else {
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
	flagComputing(): valueof this { # {{{
		@computing = true
	} # }}}
	isUsingVariable(name) { # {{{
		for var element in @elements {
			if element.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isComputed() => @elements.length > 1 || !@isString
	isInverted() { # {{{
		for var element in @elements {
			if element.isInverted() {
				return true
			}
		}

		return false
	} # }}}
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
			var element = @elements[0]

			if @computing {
				fragments.wrap(element)
			}
			else if @isString {
				if element.type().isEnum() {
					fragments.compile(element).code('.value')
				}
				else {
					fragments.wrap(element)
				}
			}
			else {
				fragments.code($runtime.helper(this), '.toString(').compile(element).code(')')
			}
		}
		else if @isString {
			with var element = @elements[0] {
				if element.type().isEnum() {
					fragments.compile(element).code('.value')
				}
				else {
					fragments.wrap(element)
				}
			}

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
	toInvertedFragments(fragments, callback) { # {{{
		for var element in @elements {
			if element.isInverted() {
				return element.toInvertedFragments(fragments, callback)
			}
		}
	} # }}}
	type() => @scope.reference('String')
}
