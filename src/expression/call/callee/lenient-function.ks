class LenientFunctionCallee extends Callee {
	private {
		@curry
		@expression
		@flatten: Boolean
		@function: FunctionType
		@functions: FunctionType[]
		@hash: String
		@labelable: Boolean
		@node: CallExpression
		@result: LenientCallMatchResult?
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, assessment: Router.Assessment, @result!?, @node) { # {{{
		this(data, assessment, result.possibilities, node)

		if ?@result.positions {
			@hash += `:\(Callee.buildPositionHash(@result.positions))`
		}
		if ?@result.labels {
			@hash += `:\(Object.map(@result.labels, ([label, index], ...) => `\(label)=\(index)`).join(','))`
		}
	} # }}}
	constructor(@data, assessment: Router.Assessment, @functions, @node) { # {{{
		super(data)

		{ @labelable } = assessment

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind
		@function = @functions[0]

		if @functions.length == 1 {
			@type = @function.getReturnType()

			if @type.isDeferred() {
				var typeName = @type.name()
				var generics = @function.buildGenericMap(node.arguments())

				for var { name, type } in generics {
					if name == typeName {
						@type = type

						break
					}
				}
			}
			else if @type.isDeferrable() {
				var generics = @function.buildGenericMap(node.arguments())

				@type = @type.applyGenerics(generics)
			}
		}
		else {
			var types = []

			for var function in @functions {
				@validate(function, node)

				types.pushUniq(function.getReturnType())
			}

			@type = Type.union(node.scope(), ...types)
		}

		@hash = 'lenient'
		@hash += `:\(@functions.map((function, ...) => function.index()).join(','))`
	} # }}}
	acquireReusable(acquire) { # {{{
		@expression.acquireReusable(@flatten)
	} # }}}
	functions() => @functions
	override hashCode() => @hash
	isInitializingInstanceVariable(name: String): Boolean => false
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
		@functions.push(...that.functions()!?)
	} # }}}
	releaseReusable() { # {{{
		@expression.releaseReusable()
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			if @scope == ScopeKind.Argument {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(node.getCallScope(), mode)
			}
			else {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(@expression.caller(), mode)
			}

			Router.Argument.toFlatFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, true, null, fragments, mode)
		}
		else {
			match @scope {
				ScopeKind.Argument {
					fragments.wrap(@expression, mode).code('.call(').compile(node.getCallScope(), mode)

					Router.Argument.toFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, true, false, fragments, mode)
				}
				ScopeKind.This {
					fragments.wrap(@expression, mode).code('(')

					Router.Argument.toFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, false, false, fragments, mode)
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		var [type, map] = @curry

		match @scope {
			ScopeKind.Argument {
				throw NotImplementedException.new()
			}
			ScopeKind.This {
				fragments.code('(')

				for var _, index in type.parameters() {
					fragments.code($comma) if index != 0

					fragments.code(`__ks_\(index)`)
				}

				fragments.code(') => ').compile(@expression).code('(')

				var arguments = @node.arguments()

				CurryExpression.toArgumentFragments(map, arguments, false, fragments, mode)
			}
		}
	} # }}}
	toCurryType() { # {{{
		if !?@result {
			throw NotImplementedException.new()
		}

		if #@result.matches {
			if @result.matches.length > 1 {
				var overloaded = OverloadedFunctionType.new(@node.scope())

				for var { function, positions }, index in @result.matches {
					@curry = CurryExpression.toCurryType(function, positions, false, @node)

					overloaded.addFunction(@curry[0])
				}

				return overloaded
			}
			else {
				@curry = CurryExpression.toCurryType(@result.matches[0].function, @result.matches[0].positions, false, @node)

				return @curry[0]
			}
		}

		if #@result.positions && @result.possibilities.length == 1 {
			@curry = CurryExpression.toCurryType(@result.possibilities[0], @result.positions, false, @node)

			return @curry[0]
		}

		throw NotImplementedException.new()
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		if @nullable {
			if @expression.isNullable() {
				fragments
					.compileNullable(@expression)
					.code(' && ')
			}

			fragments
				.code($runtime.type(node) + '.isFunction(')
				.compileReusable(@expression)
				.code(')')
		}
		else if @expression.isNullable() {
			fragments.compileNullable(@expression)
		}
		else {
			fragments
				.code($runtime.type(node) + '.isValue(')
				.compileReusable(@expression)
				.code(')')
		}
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
