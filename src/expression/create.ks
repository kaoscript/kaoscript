class CreateExpression extends Expression {
	private {
		_arguments: Array		= []
		_class: Expression
		_flatten: Boolean		= false
		_type: Type				= Type.Any
	}
	analyse() { // {{{
		@class = $compile.expression(@data.class, this)
		@class.analyse()

		const es5 = @options.format.spreads == 'es5'

		for argument in @data.arguments {
			@arguments.push(argument = $compile.expression(argument, this))

			argument.analyse()

			if es5 && argument is UnaryOperatorSpread {
				@flatten = true
			}
		}
	} // }}}
	prepare() { // {{{
		@class.prepare()

		for argument in @arguments {
			argument.prepare()
		}

		if type !?= @class.type() {
			ReferenceException.throwNotDefined(@class.type().name(), this)
		}
		else if type.isNamed() && type.type() is ClassType {
			if type.type().isAbstract() {
				TypeException.throwCannotBeInstantiated(type.name(), this)
			}
			else if !type.type().matchArguments([argument.type() for argument in @arguments]) {
				ReferenceException.throwNoMatchingConstructor(type.name(), this)
			}

			@type = @scope.reference(type)
		}
		else if !type.isAny() && !type.isClass() {
			TypeException.throwNotClass(type.name(), this)
		}
	} // }}}
	translate() { // {{{
		@class.translate()

		for argument in @arguments {
			argument.translate()
		}
	} // }}}
	isComputed() => true
	isUsingVariable(name) { // {{{
		if @class.isUsingVariable(name) {
			return true
		}

		for const argument in @arguments {
			if argument.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @flatten {
			this.module().flag('Helper')

			fragments.code(`\($runtime.helper(this)).create(`).compile(@class)

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), @arguments)

			fragments.code(')')
		}
		else {
			fragments.code('new ').compile(@class).code('(')

			for i from 0 til @arguments.length {
				fragments.code($comma) if i != 0

				fragments.compile(@arguments[i])
			}

			fragments.code(')')
		}
	} // }}}
	type() => @type
}