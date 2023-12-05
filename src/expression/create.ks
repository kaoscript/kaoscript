enum ContainerKind {
	Class
	Struct
	Tuple
	Unknown
}

class CreateExpression extends Expression {
	private late {
		@alien: Boolean					= false
		@arguments: Array				= []
		@assessment: Router.Assessment?
		@container: ContainerKind		= .Unknown
		@computed: Boolean				= true
		@factory: Expression
		@hybrid: Boolean				= false
		@result: CallMatchResult?
		@sealed: Boolean				= false
		@type: Type						= Type.Any
	}
	analyse() { # {{{
		@factory = $compile.expression(@data.class, this)
		@factory.analyse()

		for var data in @data.arguments {
			var argument = $compile.expression(data, this)

			argument.analyse()

			@arguments.push(argument)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@factory.prepare(AnyType.Unexplicit)

		var type = @factory.type()

		unless ?type {
			ReferenceException.throwNotDefined(@factory.toQuote(), this)
		}
		if !(type.isAny() || type.isContainer()) || type.isVirtual() {
			TypeException.throwNotCreatable(type.toQuote(), this)
		}

		if type.isNamed() {
			match type.type() {
				is ClassType {
					var class = type.type()

					if type.isVirtual() {
						TypeException.throwNotClass(type.name(), this)
					}
					if class.isAbstract() {
						TypeException.throwAbstractInstantiation(type.name(), this)
					}
					if class.features() !~ ClassFeature.Constructor {
						TypeException.throwInvalidInstantiation(type.name(), this)
					}

					if class.hasSealedConstructors() {
						@sealed = true
					}

					@assessment = class.getConstructorAssessment(type.name(), this)

					@prepareArguments()

					match Router.matchArguments(@assessment, null, @arguments, this) {
						is LenientCallMatchResult | PreciseCallMatchResult with var result {
							@result = result
						}
						else {
							if class.isExhaustiveConstructor(this) {
								ReferenceException.throwNoMatchingConstructor(type.name(), @arguments, this)
							}
						}
					}

					@container = .Class
					@alien = class.isAlien()
					@hybrid = class.isHybrid()
					@type = @scope.reference(type).flagStrict()
				}
				is StructType {
					var struct = type.discardName()

					@assessment = struct.assessment(type.reference(@scope), this)

					@prepareArguments()

					match Router.matchArguments(@assessment, null, @arguments, this) {
						is LenientCallMatchResult | PreciseCallMatchResult with var result {
							@result = result
						}
						else {
							if struct.isExhaustive(this) {
								ReferenceException.throwNoMatchingStruct(type.name(), @arguments, this)
							}
						}
					}

					@container = .Struct
					@type = @scope.reference(type).flagStrict()
				}
				is TupleType {
					var tuple = type.discardName()

					@assessment = tuple.assessment(type.reference(@scope), this)

					@prepareArguments()


					match Router.matchArguments(@assessment, null, @arguments, this) {
						is LenientCallMatchResult | PreciseCallMatchResult with var result {
							@result = result
						}
						else {
							if tuple.isExhaustive(this) {
								ReferenceException.throwNoMatchingTuple(type.name(), @arguments, this)
							}
						}
					}

					@container = .Tuple
					@type = @scope.reference(type).flagStrict()
				}
				else {
					@prepareArguments()
				}
			}
		}
		else {
			@prepareArguments()
		}

		if !?@result || @result is LenientCallMatchResult {
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

		for var argument in @arguments {
			argument.translate()
		}
	} # }}}
	arguments() => @arguments
	assessment() => @assessment
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
	prepareArguments() { # {{{
		for var argument in @arguments {
			argument.prepare(AnyType.NullableUnexplicit)

			if argument.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(argument, this)
			}

			argument.unspecify()
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		match @container {
			.Class => @toClassFragments(fragments, mode)
			.Struct => @toStructFragments(fragments, mode)
			.Tuple => @toTupleFragments(fragments, mode)
			else => @toUnknownFragments(fragments, mode)
		}
	} # }}}
	toClassFragments(fragments, mode) { # {{{
		match @result {
			is LenientCallMatchResult {
				if @sealed {
					fragments.code(`\(@type.type().getSealedName()).new(`)
				}
				else {
					fragments.code('new ').compile(@factory).code('(')
				}

				if ?#@result.possibilities {
					Router.Argument.toFragments(@result.positions, null, @arguments, @result.possibilities[0], @assessment.labelable, false, false, fragments, mode)
				}
				else {
					for var argument, i in @arguments {
						fragments.code($comma) if i != 0

						fragments.compile(argument)
					}
				}

				fragments.code(')')
			}
			is PreciseCallMatchResult {
				if @hybrid {
					fragments.code('new ').compile(@factory).code('(')

					if ?#@arguments {
						var { function, positions } = @result.matches[0]

						Router.Argument.toFragments(positions, null, @arguments, function, @assessment.labelable, false, true, fragments, mode)
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

					Router.Argument.toFragments(positions, null, @arguments, function, @assessment.labelable, false, true, fragments, mode)

					fragments.code(')')
				}
				else {
					throw NotImplementedException.new()
				}
			}
			else {
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
		}
	} # }}}
	toQuote() => `new \(@factory.toQuote())()`
	toStructFragments(fragments, mode) { # {{{
		fragments.wrap(@factory, mode)

		match @result {
			is LenientCallMatchResult {
				fragments.code('(')

				Router.Argument.toFragments(@result.positions, null, @arguments, @result.possibilities[0], false, false, false, fragments, mode)

				fragments.code(')')
			}
			is PreciseCallMatchResult {
				match @result.matches.length {
					0 {
						fragments.code(`.__ks_new()`)
					}
					1 {
						fragments.code(`.__ks_new(`)

						var { function, positions } = @result.matches[0]

						Router.Argument.toFragments(positions, null, @arguments, function, false, false, true, fragments, mode)

						fragments.code(')')
					}
					else {
						throw NotImplementedException.new()
					}
				}
			}
			else {
				fragments.code('(')

				for var argument, i in @arguments {
					fragments.code($comma) if i != 0

					fragments.compile(argument)
				}

				fragments.code(')')
			}
		}
	} # }}}
	toTupleFragments(fragments, mode) { # {{{
		fragments.wrap(@factory, mode)

		match @result {
			is LenientCallMatchResult {
				fragments.code('(')

				Router.Argument.toFragments(@result.positions, null, @arguments, @result.possibilities[0], false, false, false, fragments, mode)

				fragments.code(')')
			}
			is PreciseCallMatchResult {
				match @result.matches.length {
					0 {
						fragments.code(`.__ks_new()`)
					}
					1 {
						fragments.code(`.__ks_new(`)

						var { function, positions } = @result.matches[0]

						Router.Argument.toFragments(positions, null, @arguments, function, false, false, true, fragments, mode)

						fragments.code(')')
					}
					else {
						throw NotImplementedException.new()
					}
				}
			}
			else {
				fragments.code('(')

				for var argument, i in @arguments {
					fragments.code($comma) if i != 0

					fragments.compile(argument)
				}

				fragments.code(')')
			}
		}
	} # }}}
	toUnknownFragments(fragments, mode) { # {{{
		fragments.code($runtime.helper(this), '.create(').compile(@factory, mode).code($comma)

		CallExpression.toFlattenArgumentsFragments(fragments, @arguments)

		fragments.code(')')
	} # }}}
	type() => @type
}
