class SealedPreciseMethodCallee extends Callee {
	private {
		@arguments: Array<CallMatchArgument>
		@expression
		@flatten: Boolean
		@function: FunctionType
		@node: CallExpression
		@object
		@property: String
		@scope: ScopeKind
		@type: Type
		@variable: NamedType<ClassType>
	}
	constructor(@data, @object, @property, match: CallMatch, @variable, @node) { # {{{
		super(data)

		@expression = new MemberExpression(data.callee, node, node.scope(), object)
		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		@function = match.function
		@arguments = match.arguments

		this.validate(@function, node)

		@type = @function.getReturnType()
	} # }}}
	getContextSubstitute(expression) { # {{{
		if expression is IdentifierLiteral {
			const variable = expression.variable()

			if const substitute = variable.replaceContext?() {
				return substitute
			}
		}

		return null
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		return @function.isInitializingInstanceVariable(name)
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @function.isInstance() {
						fragments.code(`\(@variable.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(`)

						if const substitute = this.getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						fragments.code($comma)

						CallExpression.toFlattenArgumentsFragments(fragments, node._arguments)
					}
					else {
						fragments.code(`\(@variable.getSealedPath()).__ks_sttc_\(@property)_\(@function.index()).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node._arguments)
					}
				}
			}
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @function.isAlien() {
						throw new NotImplementedException(node)
					}
					else {
						if @function.isInstance() {
							fragments.code(`\(@variable.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(`)

							if const substitute = this.getContextSubstitute(@object) {
								substitute(fragments)
							}
							else {
								fragments.compile(@object)
							}

							Router.toArgumentsFragments(@arguments, node._arguments, @function, true, fragments, mode)
						}
						else {
							fragments.code(`\(@variable.getSealedPath()).__ks_sttc_\(@property)_\(@function.index())(`)

							Router.toArgumentsFragments(@arguments, node._arguments, @function, false, fragments, mode)
						}
					}
				}
			}
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
		@node.scope().reference(@variable).toPositiveTestFragments(fragments, @object)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
