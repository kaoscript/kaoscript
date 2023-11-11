class DeferredType extends Type {
	private {
		@name: String
		@nullable: Boolean			= false
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): DeferredType { # {{{
			return DeferredType.new(data.name, scope)
		} # }}}
	}
	constructor(@name, @scope) { # {{{
		super(scope)
	} # }}}
	override canBeDeferred() => true
	override clone() { # {{{
		var type = DeferredType.new(@name, @scope)

		type._nullable = @nullable

		return type
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		return {
			kind: TypeKind.Deferred
			@name
		}
	} # }}}
	override hashCode() => `<\(@name)>`
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if this == value {
			return true
		}

		if value is DeferredType {
			if @name == value.name() {
				if @nullable && !nullcast && !value.isNullable() {
					return false
				}

				return true
			}
		}

		return false
	} # }}}
	override isDeferred() => true
	override isNullable() => @nullable
	override isNullable(generics: AltType[]?) { # {{{
		return true if @nullable || !#generics

		for var { name, type } in generics {
			if name == @name {
				return type.isNullable()
			}
		}

		return true
	} # }}}
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Anycast {
			return !@nullable || value.isNullable() || mode ~~ MatchingMode.NonNullToNull
		}

		return false
	} # }}}
	assist isSubsetOf(value: AnyType, generics, subtypes, mode) { # {{{
		return !@nullable || value.isNullable()
	} # }}}
	assist isSubsetOf(value: DeferredType, generics, subtypes, mode) { # {{{
		if this == value {
			return true
		}

		if @name == value.name() {
			return !@nullable || value.isNullable()
		}

		return false
	} # }}}
	name() => @name
	setNullable(nullable: Boolean) { # {{{
		if @nullable == nullable {
			return this
		}
		else {
			var type = @clone()

			type._nullable = nullable

			return type
		}
	} # }}}
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, generics, subtypes, fragments, node) { # {{{
		if nullable || @nullable {
			fragments.code(`\($runtime.type(node)).any`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue`)
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, _, generics, fragments, node) { # {{{
		if var index ?= generics.indexOf(@name) {
			fragments.code(`mapper[\(index)]`)
		}
		else {
			NotImplementedException.throw()
		}
	} # }}}
	override toQuote() => `<\(@name)>`
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
}
