enum ContainerKind {
	Class
	Struct
	Tuple
	Unknown
}

class ConstructorCallee extends Callee {
	private {
		@alien: Boolean					= false
		@assessment: Router.Assessment?
		@container: ContainerKind		= .Unknown
		@computed: Boolean				= true
		@factory: Expression
		@hash: String
		@hybrid: Boolean				= false
		@node: CallExpression
		@result: CallMatchResult?
		@sealed: Boolean				= false
		@type: Type
	}
	constructor(@data, @factory, @type, @assessment, @result, @node) { # {{{
		super(data)

		if @type is ReferenceType {
			var raw = type.type().type()

			match raw {
				is ClassType {
					if @type.isVirtual() {
						TypeException.throwNotClass(@type.name(), @node)
					}
					if raw.isAbstract() {
						TypeException.throwAbstractInstantiation(@type.name(), @node)
					}
					if raw.features() !~ ClassFeature.Constructor {
						TypeException.throwInvalidInstantiation(@type.name(), @node)
					}

					if raw.hasSealedConstructors() {
						@sealed = true
					}

					@container = .Class
					@alien = raw.isAlien()
					@hybrid = raw.isHybrid()

					@type = @type.flagStrict()
				}
				is StructType {
					@container = .Struct
					@type = @type.flagStrict()
				}
				is TupleType {
					@container = .Tuple
					@type = @type.flagStrict()
				}
			}
		}

		@hash = `constructor:\(@type.hashCode())`

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
	assessment() => @assessment
	override hashCode() => @hash
	isComputed() => @computed
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		if @result is PreciseCallMatchResult {
			for var { function } in @result.matches {
				if function.isInitializingInstanceVariable(name) {
					return true
				}
			}
		}

		return false
	} # }}}
	isUsingVariable(name) { # {{{
		if @factory.isUsingVariable(name) {
			return true
		}

		for var argument in @node.arguments() {
			if argument.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		match @container {
			.Class => @toClassFragments(fragments, mode)
			.Struct => @toStructFragments(fragments, mode)
			.Tuple => @toTupleFragments(fragments, mode)
			else => @toUnknownFragments(fragments, mode)
		}
	} # }}}
	toClassFragments(fragments, mode) { # {{{
		var arguments = @node.arguments()

		match @result {
			is LenientCallMatchResult {
				if @sealed {
					fragments.code(`\(@type.type().getSealedName()).new(`)
				}
				else {
					fragments.code('new ').compile(@factory).code('(')
				}

				if ?#@result.possibilities {
					Router.Argument.toFragments(@result.positions, null, arguments, @result.possibilities[0], @assessment.labelable, false, false, fragments, mode)
				}
				else {
					for var argument, i in arguments {
						fragments.code($comma) if i != 0

						fragments.compile(argument)
					}
				}
			}
			is PreciseCallMatchResult {
				if @hybrid {
					fragments.code('new ').compile(@factory).code('(')

					if ?#arguments {
						var { function, positions } = @result.matches[0]

						Router.Argument.toFragments(positions, null, arguments, function, @assessment.labelable, false, true, fragments, mode)
					}
				}
				else if @result.matches.length == 0 {
					if @alien {
						fragments.code('new ').compile(@factory).code('(')
					}
					else {
						fragments.code(`\(@type.type().path()).__ks_new_0`).code('(')
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

					Router.Argument.toFragments(positions, null, arguments, function, @assessment.labelable, false, true, fragments, mode)
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

				for var argument, i in arguments {
					fragments.code($comma) if i != 0

					fragments.compile(argument)
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
	} # }}}
	toStructFragments(fragments, mode) { # {{{
		var arguments = @node.arguments()

		fragments.wrap(@factory, mode)

		match @result {
			is LenientCallMatchResult {
				fragments.code('(')

				Router.Argument.toFragments(@result.positions, null, arguments, @result.possibilities[0], false, false, false, fragments, mode)
			}
			is PreciseCallMatchResult {
				match @result.matches.length {
					0 {
						fragments.code(`.__ks_new()`)
					}
					1 {
						fragments.code(`.__ks_new(`)

						var { function, positions } = @result.matches[0]

						Router.Argument.toFragments(positions, null, arguments, function, false, false, true, fragments, mode)
					}
					else {
						throw NotImplementedException.new()
					}
				}
			}
			else {
				fragments.code('(')

				for var argument, i in arguments {
					fragments.code($comma) if i != 0

					fragments.compile(argument)
				}
			}
		}
	} # }}}
	toTupleFragments(fragments, mode) { # {{{
		var arguments = @node.arguments()

		fragments.wrap(@factory, mode)

		match @result {
			is LenientCallMatchResult {
				fragments.code('(')

				Router.Argument.toFragments(@result.positions, null, arguments, @result.possibilities[0], false, false, false, fragments, mode)
			}
			is PreciseCallMatchResult {
				match @result.matches.length {
					0 {
						fragments.code(`.__ks_new()`)
					}
					1 {
						fragments.code(`.__ks_new(`)

						var { function, positions } = @result.matches[0]

						Router.Argument.toFragments(positions, null, arguments, function, false, false, true, fragments, mode)
					}
					else {
						throw NotImplementedException.new()
					}
				}
			}
			else {
				fragments.code('(')

				for var argument, i in arguments {
					fragments.code($comma) if i != 0

					fragments.compile(argument)
				}
			}
		}
	} # }}}
	toUnknownFragments(fragments, mode) { # {{{
		var arguments = @node.arguments()

		fragments.code($runtime.helper(@node), '.create(').compile(@factory, mode).code($comma)

		CallExpression.toFlattenArgumentsFragments(fragments, arguments)
	} # }}}
	toQuote() => `\(@factory.toQuote()).new()`
	translate()
	type() => @type
}
