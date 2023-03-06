abstract class Callee {
	protected {
		@data
		@nullable: Boolean			= false
		@nullableProperty: Boolean	= false
	}
	static {
		buildPositionHash(positions: CallMatchPosition[]) { # {{{
			var mut hash = ''

			for var position, index in positions {
				hash += ',' if index != 0

				if position is Array {
					for var { index, element, from }, i in position {
						hash += '|' if i != 0

						if !?index {
							pass
						}
						else if ?element {
							hash += `\(index)[\(element)]`
						}
						else if ?from {
							hash += `\(index)/\(from)`
						}
						else {
							hash += `\(index)`
						}
					}
				}
				else {
					var { index, element, from } = position

					if !?index {
						pass
					}
					else if ?element {
						hash += `\(index)[\(element)]`
					}
					else {
						hash += `\(index)`
					}
				}
			}

			return hash
		}
	} # }}}
	constructor(@data) { # {{{
		for var modifier in data.modifiers {
			if modifier.kind == ModifierKind.Nullable {
				@nullable = true
			}
		}
	} # }}}
	abstract hashCode(): String?
	abstract toFragments(fragments, mode, node)
	abstract toNullableFragments(fragments, node)
	abstract translate()
	abstract type(): Type
	acquireReusable(acquire)
	isNullable() => @nullable || @nullableProperty
	isNullableComputed() => @nullable && @nullableProperty
	isSkippable() => false
	mergeWith(that: Callee) { # {{{
		throw new NotSupportedException()
	} # }}}
	releaseReusable()
	validate(type: FunctionType, node) { # {{{
		for var error in type.listErrors() {
			Exception.validateReportedError(error.discardReference(), node)
		}
	} # }}}
}

abstract class PreciseCallee extends Callee {
	protected {
		@expression
		@flatten: Boolean
		@function: FunctionType
		@functions: FunctionType[]
		@hash: String?
		@index: Number
		@node: CallExpression
		@positions: CallMatchPosition[]
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, @expression, prepared: Boolean, assessment, match: CallMatch, @node) { # {{{
		super(data)

		if !prepared {
			@expression.analyse()
			@expression.prepare(AnyType.NullableUnexplicit)
		}

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		@validate(match.function, node)

		@function = match.function
		@functions = [match.function]
		@index = match.function.getCallIndex()
		@positions = match.positions
		@type = match.function.getReturnType()

		@hash = @buildHashCode()
	} # }}}
	abstract buildHashCode(): String?
	acquireReusable(acquire) { # {{{
		@expression.acquireReusable(@flatten)
	} # }}}
	functions() => @functions
	override hashCode() => @hash
	isInitializingInstanceVariable(name: String): Boolean => false
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
		@functions.push(...that.functions())
	} # }}}
	releaseReusable() { # {{{
		@expression.releaseReusable()
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

abstract class MethodCallee extends PreciseCallee {
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		for var function in @functions {
			if function.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
}
