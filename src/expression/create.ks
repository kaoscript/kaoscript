class CreateExpression extends Expression {
	private {
		_arguments: Array		= []
		_factory: Expression
		_flatten: Boolean		= false
		_sealed: Boolean		= false
		_struct: Boolean		= false
		_type: Type				= Type.Any
	}
	analyse() { // {{{
		@factory = $compile.expression(@data.class, this)
		@factory.analyse()

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
		@factory.prepare()

		for argument in @arguments {
			argument.prepare()
		}

		if type !?= @factory.type() {
			ReferenceException.throwNotDefined(@factory.toQuote(), this)
		}
		else if type.isNamed() && type.type() is ClassType {
			if type.type().isAbstract() {
				TypeException.throwCannotBeInstantiated(type.name(), this)
			}
			else if type.type().isExhaustiveConstructor(this) {
				if !type.type().matchArguments(@arguments) {
					ReferenceException.throwNoMatchingConstructor(type.name(), @arguments, this)
				}
			}

			if type.type().hasSealedConstructors() {
				@sealed = true
			}

			@type = @scope.reference(type)
		}
		else if type.isNamed() && type.type() is StructType {
			@type = @scope.reference(type)

			@struct = true
		}
		else if !(type.isAny() || type.isClass() || type.isStruct()) {
			TypeException.throwNotClass(type.toQuote(), this)
		}
	} // }}}
	translate() { // {{{
		@factory.translate()

		for argument in @arguments {
			argument.translate()
		}
	} // }}}
	isComputed() => true
	isUsingVariable(name) { // {{{
		if @factory.isUsingVariable(name) {
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
		if @struct {
			fragments.compile(@factory).code('(')

			for const argument, i in @arguments {
				fragments.code($comma) if i != 0

				fragments.compile(argument)
			}

			fragments.code(')')
		}
		else if @sealed {
			fragments.code(`\(@type.type().getSealedName()).new(`)

			for const argument, i in @arguments {
				fragments.code($comma) if i != 0

				fragments.compile(argument)
			}

			fragments.code(')')
		}
		else if @flatten {
			this.module().flag('Helper')

			fragments.code(`\($runtime.helper(this)).create(`).compile(@factory)

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), @arguments)

			fragments.code(')')
		}
		else {
			fragments.code('new ').compile(@factory).code('(')

			for const argument, i in @arguments {
				fragments.code($comma) if i != 0

				fragments.compile(argument)
			}

			fragments.code(')')
		}
	} // }}}
	type() => @type
}