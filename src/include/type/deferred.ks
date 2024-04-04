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
	override applyGenerics(generics) { # {{{
		for var { name, type } in generics {
			if name == @name {
				return type.setNullable(@nullable)
			}
		}

		return @nullable ? AnyType.NullableUnexplicit : AnyType.Unexplicit
	} # }}}
	override buildGenericMap(position, expressions, decompose, genericMap) { # {{{
		genericMap[@name] ??= []

		if position is Array {
			var types = []

			for var { index?, element? } in position {
				if !?index {
					pass
				}
				else if ?element {
					types.pushUniq(decompose(expressions[index].argument().type()))
				}
				else {
					types.pushUniq(decompose(expressions[index].type()))
				}
			}

			genericMap[@name].push(Type.union(@scope, ...types))
		}
		else {
			var { index?, element? } = position

			if !?index || !?expressions[index] {
				pass
			}
			else if ?element {
				genericMap[@name].push(decompose(expressions[index].argument().type()))
			}
			else {
				genericMap[@name].push(decompose(expressions[index].type()))
			}
		}
	} # }}}
	override canBeDeferred() => true
	override clone() { # {{{
		var clone = DeferredType.new(@name, @constraint, @scope)
			.._nullable = @nullable
			.._generic = @generic if ?@generic

		return clone
	} # }}}
	compareToRef(value: NullType, equivalences: String[][]? = null) => 1
	compareToRef(value: ReferenceType, equivalences: String[][]? = null) => 1
	constraint() => @constraint
	override discardDeferred() => @nullable ? AnyType.NullableUnexplicit : AnyType.Unexplicit
	override export(references, indexDelta, mode, module) { # {{{
		return {
			kind: TypeKind.Deferred
			@name
			nullable: true if @nullable
			constraint: @constraint.toReference(references, indexDelta, mode, module) if @constrainted && !?@generic
		}
	} # }}}
	override flagReferenced() => this
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
			return `<\(@name) is \(@constraint.hashCode())>\(@nullable ? '?' : '')`
		}
		else {
			return `<\(@name)>\(@nullable ? '?' : '')`
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

		if anycast {
			if @nullable && !nullcast && !value.isNullable() {
				return false
			}

			return true
		}

		return false
	} # }}}
	override isComplete() => true
	isConstrainted() => @constrainted
	override isDeferrable() => true
	override isDeferred() => true
	override isExportable() => true
	override isNullable() => @nullable
	override isNullable(generics: AltType[]?) { # {{{
		return true if @nullable || !?#generics

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
	override makeMemberCallee(property, path, generics, node) { # {{{
		return @discardDeferred().makeMemberCallee(property, path, generics, node)
	} # }}}
	matchDeferred(type: Type, generics: Type{}) { # {{{
		if type.isNull() {
			if @nullable {
				return {
					type
					match: true
				}
			}
			else {
				return {
					type: this
					match: false
				}
			}
		}
		else if ?generics[@name] {
			return {
				type: generics[@name]
				match: false
			}
		}
		else {
			if @constrainted {
				unless type.isSubsetOf(@constraint, null, null, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
					return {
						type: this
						match: false
					}
				}
			}

			generics[@name] = type

			return {
				type
				match: true
			}
		}
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
	override toAwareTestFunctionFragments(varname, nullable, hasDeferred, _, _, generics, subtypes, fragments, node) { # {{{
		if hasDeferred {
			fragments.code(`gens.\(@name) || `)
		}

		if @constrainted {
			@constraint.toAwareTestFunctionFragments(varname, nullable, hasDeferred, false, false, generics, subtypes, fragments, node)
		}
		else if nullable || @nullable {
			fragments.code(`\($runtime.type(node)).any`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue`)
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, _, _, _, generics, fragments, node) { # {{{
		if ?#generics {
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
	override toReference(references, indexDelta, mode, module) { # {{{
		return @export(references, indexDelta, mode, module)
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
