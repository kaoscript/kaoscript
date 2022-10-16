class CreateExpression extends Expression {
	private late {
		@alien: Boolean					= false
		@arguments: Array				= []
		@assessment: Router.Assessment?
		@computed: Boolean				= true
		@factory: Expression
		@flatten: Boolean				= false
		@hybrid: Boolean				= false
		@result: CallMatchResult?
		@sealed: Boolean				= false
		@type: Type						= Type.Any
	}
	analyse() { # {{{
		@factory = $compile.expression(@data.class, this)
		@factory.analyse()

		var es5 = @options.format.spreads == 'es5'

		for var data in @data.arguments {
			var argument = $compile.expression(data, this)

			argument.analyse()

			@arguments.push(argument)

			if es5 && argument is UnaryOperatorSpread {
				@flatten = true
			}
		}
	} # }}}
	override prepare(target) { # {{{
		@factory.prepare(@scope.reference('Class'))

		for var argument in @arguments {
			argument.prepare(AnyType.NullableUnexplicit)
		}

		if type !?= @factory.type() {
			ReferenceException.throwNotDefined(@factory.toQuote(), this)
		}
		else if type.isNamed() && type.type() is ClassType {
			if type.type().isAbstract() {
				TypeException.throwCannotBeInstantiated(type.name(), this)
			}

			if type.type().hasSealedConstructors() {
				@sealed = true
			}

			@assessment = type.type().getConstructorAssessment(type.name(), this)

			if var result ?= Router.matchArguments(@assessment, @arguments, this) {
				@result = result
			}
			else if type.type().isExhaustiveConstructor(this) {
				ReferenceException.throwNoMatchingConstructor(type.name(), @arguments, this)
			}

			@alien = type.isAlien()
			@hybrid = type.isHybrid()
			@type = @scope.reference(type).flagStrict()
		}
		else if !(type.isAny() || type.isClass()) {
			TypeException.throwNotClass(type.toQuote(), this)
		}

		if @flatten {
			@computed = false
		}
		else if !?@result || @result is LenientCallMatchResult {
			if @sealed {
				@computed = false
			}
			else {
				@computed = true
			}
		}
		else {
			if @hybrid {
				@computed = true
			}
			else if @result.matches.length == 0 {
				@computed = @alien
			}
			else if @result.matches.length == 1 {
				var { function } = @result.matches[0]

				if @sealed && !function.isSealed() {
					@computed = true
				}
				else {
					@computed = false
				}
			}
		}
	} # }}}
	translate() { # {{{
		@factory.translate()

		for argument in @arguments {
			argument.translate()
		}
	} # }}}
	isComputed() => @computed
	isUsingVariable(name) { # {{{
		if @factory.isUsingVariable(name) {
			return true
		}

		for var argument in @arguments {
			if argument.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		@factory.listNonLocalVariables(scope, variables)

		for var argument in @arguments {
			argument.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @flatten {
			if @sealed {
				fragments.code(`\(@type.type().getSealedName()).new.apply(null`)

				CallExpression.toFlattenArgumentsFragments(fragments.code($comma), @arguments)

				fragments.code(')')
			}
			else {
				@module().flag('Helper')

				fragments.code(`\($runtime.helper(this)).create(`).compile(@factory)

				CallExpression.toFlattenArgumentsFragments(fragments.code($comma), @arguments)

				fragments.code(')')
			}
		}
		else {
			if !?@result || @result is LenientCallMatchResult {
				if @sealed {
					fragments.code(`\(@type.type().getSealedName()).new(`)
				}
				else {
					fragments.code('new ').compile(@factory).code('(')
				}

				for var argument, i in @arguments {
					fragments.code($comma) if i != 0

					fragments.compile(argument)
				}

				fragments.code(')')
			}
			else {
				if @hybrid {
					fragments.code('new ').compile(@factory).code('(')

					for var argument, i in @arguments {
						fragments.code($comma) if i != 0

						fragments.compile(argument)
					}

					fragments.code(')')
				}
				else if @result.matches.length == 0 {
					if @alien {
						fragments.code('new ').compile(@factory).code('()')
					}
					else {
						fragments.code(`\(@type.type().path()).__ks_new_0`).code('()')
					}
				}
				else if @result.matches.length == 1 {
					var { function, positions } = @result.matches[0]

					if @sealed {
						if function.isSealed() {
							fragments.code(`\(@type.type().getSealedName()).__ks_new_\(function.index())`).code('(')
						}
						else {
							fragments.code('new ').compile(@factory).code('(')
						}
					}
					else {
						fragments.code(`\(@type.type().path()).__ks_new_\(function.index())`).code('(')
					}

					Router.Argument.toFragments(positions, null, @arguments, function, @assessment.labelable, false, fragments, mode)

					fragments.code(')')
				}
				else {
					throw new NotImplementedException()
				}
			}
		}
	} # }}}
	toQuote() => `new \(@factory.toQuote())()`
	type() => @type
}
