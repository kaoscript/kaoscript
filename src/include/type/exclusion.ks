class ExclusionType extends Type {
	private {
		@types: Array<Type>
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { # {{{
			var type = ExclusionType.new(scope, [Type.fromMetadata(item, metadata, references, alterations, queue, scope, node) for var item in data.types])

			return type
		} # }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { # {{{
			var type = ExclusionType.new(scope)

			queue.push(() => {
				for var item in data.types {
					type.addType(Type.fromMetadata(item, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} # }}}
	}
	constructor(@scope, @types = []) { # {{{
		super(scope)
	} # }}}
	clone() { # {{{
		var that = ExclusionType.new(@scope)

		that._types = [...@types]

		return that
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind.Exclusion
			types: [type.toReference(references, indexDelta, mode, module) for var type in @types]
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for var type in @types {
			type.flagExported(explicitly)
		}

		return this
	} # }}}
	getMainType() => @types[0]
	isComplete() => true
	isExclusion() => true
	isExportable() { # {{{
		for var type in @types {
			if !type.isExportable() {
				return false
			}
		}

		return true
	} # }}}
	override isSubsetOf(value, mapper, subtypes, mode) { # {{{
		return false if value.isNull()

		return true
	} # }}}
	length() => @types.length
	matchContentOf(value: Type?) { # {{{
		if !@types[0].matchContentOf(value) {
			return false
		}

		for var type in @types from 1 {
			if type.matchContentOf(value) {
				return false
			}
		}

		return true
	} # }}}
	override toBlindTestFragments(varname, generics, junction, fragments, node) { # {{{
		fragments.code('(') if junction == .OR

		if @types[0].isAny() {
			@types[1].toBlindTestFragments(varname, generics, Junction.AND, fragments.code('!'), node)

			for var type in @types from 2 {
				fragments.code(' && ')

				type.toBlindTestFragments(varname, generics, Junction.AND, fragments.code('!'), node)
			}
		}
		else {
			@types[0].toBlindTestFragments(varname, generics, Junction.AND, fragments.code('!'), node)

			for var type in @types from 1 {
				fragments.code(' && ')

				type.toBlindTestFragments(varname, generics, Junction.AND, fragments.code('!'), node)
			}
		}

		fragments.code(')') if junction == .OR
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toPositiveTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		fragments.code('(') if junction == .OR

		if @types[0].isAny() {
			@types[1].toNegativeTestFragments(parameters, subtypes, Junction.AND, fragments, node)

			for var type in @types from 2 {
				fragments.code(' && ')

				type.toNegativeTestFragments(parameters, subtypes, Junction.AND, fragments, node)
			}
		}
		else {
			@types[0].toPositiveTestFragments(parameters, subtypes, Junction.AND, fragments, node)

			for var type in @types from 1 {
				fragments.code(' && ')

				type.toNegativeTestFragments(parameters, subtypes, Junction.AND, fragments, node)
			}
		}

		fragments.code(')') if junction == .OR
	} # }}}
	toQuote() => [type.toQuote() for var type in @types].join('^')
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => @export(references, indexDelta, mode, module)
	override toVariations(variations) { # {{{
		variations.push('exclusion')
	} # }}}
	types() => @types
}
