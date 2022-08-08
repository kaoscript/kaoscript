class ArrayType extends Type {
	private {
		@properties: Array<Type>		= []
		@rest: Boolean					= false
		@restType: Type?				= null
	}
	addProperty(type: Type) { # {{{
		@properties.push(type)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var export = {
			kind: TypeKind::Array
		}

		if @sealed {
			export.sealed = @sealed
		}

		export.properties = [property.export(references, indexDelta, mode, module) for var property in @properties]

		return export
	} # }}}
	getProperty(index: Number): Type? {
		if index >= @properties.length {
			if @rest {
				return @restType
			}

			return null
		}
		else {
			return @properties[index]
		}
	}
	isArray() => true
	isMorePreciseThan(value) => true
	isNullable() => false
	isSealable() => true
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		if this.length() != value.length() {
			return false
		}

		if this.isSealed() != value.isSealed() {
			return false
		}

		for var property, index in value._properties {
			unless @properties[index].isSubsetOf(property, mode) {
				return false
			}
		}

		return true
	} # }}}
	length() => @properties.length
	setRestType(@restType): this { # {{{
		@rest = true
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @properties.length == 0 {
			fragments.code($runtime.type(node), '.isArray')
		}
		else {
			fragments.code(`value => `, $runtime.type(node), '.isArray(value)')

			for var value, index in @properties {
				fragments.code(' && ')

				value.toPositiveTestFragments(fragments, new Literal(false, node, node.scope(), `value[\(index)]`))
			}
		}
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('array')

		for var property in @properties {
			property.toVariations(variations)
		}
	} # }}}
	walk(fn)
}
