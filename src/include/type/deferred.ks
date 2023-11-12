class DeferredType extends Type {
	private {
		@constraint: Type?
		@constrainted: Boolean
		@generic: Generic?		= null
		@name: String
		@nullable: Boolean		= false
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): DeferredType { # {{{
			var type = DeferredType.new(data.name, null, scope)

			if ?data.constraint {
				queue.push(() => {
					type._constraint = Type.import(data.type, metadata, references, alterations, queue, scope, node)
					type._constrainted = true
				})
			}

			return type
		} # }}}
	}
	constructor(@name, @constraint, @scope) { # {{{
		super(scope)

		@constrainted = ?@constraint
	} # }}}
	constructor(@generic, @scope) { # {{{
		this(generic.name, generic.type, scope)
	} # }}}
	addConstraint(value: Type) { # {{{
		if @constrainted {
			NotImplementedException.throw()
		}
		else {
			@constraint = value
			@constrainted = true

			if ?@generic {
				@generic.type = value
			}
		}
	} # }}}
	override canBeDeferred() => true
	override clone() { # {{{
		var type = DeferredType.new(@name, @constraint, @scope)

		type._nullable = @nullable

		return type
	} # }}}
	constraint() => @constraint
	override export(references, indexDelta, mode, module) { # {{{
		return {
			kind: TypeKind.Deferred
			@name
			constraint: @constraint.toReference(references, indexDelta, mode, module) if ?@constraint
		}
	} # }}}
	override getProperty(name) { # {{{
		if @constrainted {
			return @constraint.getProperty(name) ?? AnyType.NullableUnexplicit
		}
		else {
			return AnyType.NullableUnexplicit
		}
	} # }}}
	override hashCode() { # {{{
		if @constrainted {
			return `<\(@name) is \(@constraint.hashCode())>`
		}
		else {
			return `<\(@name)>`
		}
	} # }}}
	override isAny() => !@constrainted
	override isArray() => @constrainted && @constraint.isArray()
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

		if value.isAny() {
			return true
		}

		return false
	} # }}}
	override isComplete() => true
	isConstrainted() => @constrainted
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
	override isObject() => @constrainted && @constraint.isObject()
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
		if @constrainted {
			@constraint.toAwareTestFunctionFragments(varname, nullable, generics, subtypes, fragments, node)
		}
		else if nullable || @nullable {
			fragments.code(`\($runtime.type(node)).any`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue`)
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, _, generics, fragments, node) { # {{{
		if #generics {
			var mut nf = true

			for var generic, index in generics while nf {
				if @name == generic.name {
					fragments.code(`mapper[\(index)]`)

					nf = false
				}
			}

			if nf {
				NotImplementedException.throw()
			}
		}
		else {
			fragments.code(`() => true`)
		}
	} # }}}
	override toQuote() { # {{{
		if @constrainted {
			return `<\(@name) is \(@constraint.toQuote())>`
		}
		else {
			return `<\(@name)>`
		}
	} # }}}
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
}
