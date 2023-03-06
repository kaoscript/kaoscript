class DefaultCallee extends Callee {
	private {
		@expression: Expression?
		@flatten: Boolean
		@node: CallExpression
		@object: Expression?
		@objectType: ReferenceType?
		@scope: ScopeKind
		@type: Type
	}
	private static {
		toArgumentFragments(argument?, fragments, mode) { # {{{
			if ?argument {
				argument.toArgumentFragments(fragments, mode)
			}
			else {
				fragments.code('void 0')
			}
		} # }}}
	}
	constructor(@data, @object, @objectType, mut type: Type | Array<Type> | Null = null, @node) { # {{{
		super(data)

		if object == null {
			@expression = $compile.expression(data.callee, node)
		}
		else {
			@expression = new MemberExpression(data.callee, node, node.scope(), object)
		}

		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		type ??= @expression.type()

		if type is Array {
			var types = []

			for var tt in type {
				@validate(tt, node)

				types.pushUniq(tt.getReturnType())
			}

			@type = Type.union(node.scope(), ...types)
		}
		else if type.isClass() {
			TypeException.throwConstructorWithoutNew(type.name(), node)
		}
		else if type is FunctionType {
			@validate(type, node)

			@type = type.getReturnType()
		}
		else if type.isStruct() || type.isTuple() {
			@type = node.scope().reference(type)
		}
		else {
			@type = AnyType.NullableUnexplicit
		}
	} # }}}
	constructor(@data, @expression, @node) { # {{{
		super(data)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		var type = @expression.type()

		if type is Array {
			var types = []

			for var tt in type {
				@validate(tt, node)

				types.pushUniq(tt.getReturnType())
			}

			@type = Type.union(node.scope(), ...types)
		}
		else if type.isClass() {
			TypeException.throwConstructorWithoutNew(type.name(), node)
		}
		else if type is FunctionType {
			@validate(type, node)

			@type = type.getReturnType()
		}
		else if type.isStruct() || type.isTuple() {
			@type = node.scope().reference(type)
		}
		else {
			@type = AnyType.NullableUnexplicit
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		@expression.acquireReusable(acquire || @nullable || (@flatten && @scope == ScopeKind.This))
	} # }}}
	override hashCode() => `default`
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		return false
	} # }}}
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
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

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), node.arguments())
		}
		else {
			match @scope {
				ScopeKind.Argument {
					fragments.wrap(@expression, mode).code('.call(').compile(node.getCallScope(), mode)

					for var argument in node.arguments() {
						fragments.code($comma)

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
				ScopeKind.This {
					fragments.wrap(@expression, mode).code('(')

					for var argument, index in node.arguments() {
						fragments.code($comma) if index != 0

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		match @scope {
			ScopeKind.Argument {
				throw new NotImplementedException()
			}
			ScopeKind.This {
				var arguments = @node.arguments()
				var parameters = []

				fragments.code('(')

				for var argument in arguments {
					if argument is PlaceholderArgument {
						fragments.code($comma) if #parameters

						var name = `__ks_\(parameters.length)`

						fragments.code(name)
						parameters.push(name)
					}
				}

				fragments.code(') => ').compile(@expression).code('(')

				for var argument, index in arguments {
					fragments.code($comma) if index != 0

					if argument is PlaceholderArgument {
						fragments.code(parameters.shift())
					}
					else {
						argument.toArgumentFragments(fragments, mode)
					}
				}
			}
		}
	} # }}}
	toCurryType() { # {{{
		if @type is FunctionType {
			throw new NotImplementedException()
		}
		else {
			var type = new FunctionType(@node.scope())
			type.addParameter(AnyType.NullableExplicit, null, 0, Infinity)

			return type
		}
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
	toPositiveTestFragments(fragments, node) { # {{{
		@objectType.toPositiveTestFragments(fragments, @object)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
	type(@type) => this
}
