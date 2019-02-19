class ObjectType extends Type {
	private {
		_properties: Object			= {}
	}
	static {
		import(data, references: Array, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new ObjectType(scope)

			if data.sealed == true {
				type.flagSealed()
			}

			queue.push(() => {
				for name, property of data.properties {
					type.addPropertyFromMetadata(name, property, references, scope, node)
				}
			})

			return type
		} // }}}
	}
	addProperty(name: String, type: Type) { // {{{
		@properties[name] = type
	} // }}}
	addPropertyFromMetadata(name, data, references, scope, node) { // {{{
		let type
		if data.parameters? {
			type = FunctionType.fromMetadata(data, references, scope, node)
		}
		else {
			type = Type.fromMetadata(data, references, scope, node)
		}

		@properties[name] = type
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, ignoreAlteration) { // {{{
		const export = {
			kind: TypeKind::Object
		}

		if @sealed {
			export.sealed = @sealed
		}

		export.properties = {}

		for name, value of @properties {
			export.properties[name] = value.export(references, ignoreAlteration)
		}

		return export
	} // }}}
	getProperty(name: String): Type => @properties[name] ?? null
	isSealable() => true
	matchSignatureOf(value, matchables) { // {{{
		if value is not ObjectType {
			return false
		}

		if this.isSealed() != value.isSealed() {
			return false
		}

		let nf
		for :property of value._properties {
			nf = true

			for :prop of @properties while nf {
				if prop.matchSignatureOf(property, matchables) {
					nf = false
				}
			}

			if nf {
				return false
			}
		}

		return true
	} // }}}
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	walk(fn) { // {{{
		for name, type of @properties {
			fn(name, type)
		}
	} // }}}
}