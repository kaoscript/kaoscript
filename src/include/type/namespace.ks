class NamespaceType extends Type {
	private {
		_alteration: Boolean		= false
		_alterationReference: NamespaceType
		_properties: Object			= {}
		_sealProperties: Object		= {}
	}
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new NamespaceType(scope)

			if data.namespace? {
				alterations[data.namespace.reference] = index

				queue.push(() => {
					const source = references[data.namespace.reference]

					type.copyFrom(source.type())

					for name, property of data.properties {
						type.addPropertyFromMetadata(name, property, metadata, references, alterations, queue, node)
					}
				})
			}
			else {
				if data.sealed {
					type.flagSealed()
				}

				queue.push(() => {
					for name, property of data.properties {
						type.addPropertyFromMetadata(name, property, metadata, references, alterations, queue, node)
					}
				})
			}

			return type
		} // }}}
	}
	constructor(scope: Scope) { // {{{
		super(new NamespaceScope(scope))
	} // }}}
	addProperty(name: String, property: Type) { // {{{
		if property is not NamespacePropertyType {
			property = new NamespacePropertyType(property.scope(), property)
		}

		const variable = new Variable(name, false, false, property.type())

		@scope.addVariable(name, variable)

		@properties[name] = property

		if @alteration {
			property.flagAlteration()
		}

		if property.type().isSealed() {
			@sealProperties[name] = true
		}

		return variable.getDeclaredType()
	} // }}}
	addPropertyFromAST(data, node) => this.addProperty(data.name.name, Type.fromAST(data, node))
	addPropertyFromMetadata(name, data, metadata, references, alterations, queue, node) { // {{{
		const type = Type.fromMetadata(data, metadata, references, alterations, queue, @scope, node)

		if type._scope != @scope {
			type._scope = @scope
		}

		const variable = new Variable(name, false, false, type)

		@scope.addVariable(name, variable)

		const property = new NamespacePropertyType(@scope, variable.getDeclaredType())

		@properties[name] = property

		if data.sealed {
			property.flagSealed()
		}

		if property.type().isSealed() {
			@sealProperties[name] = true
		}

		return variable.getDeclaredType()
	} // }}}
	clone() { // {{{
		const that = new NamespaceType(@scope)

		return that.copyFrom(this)
	} // }}}
	copyFrom(src: NamespaceType) { // {{{
		@sealed = src._sealed

		for name, property of src._properties {
			@properties[name] = property
		}
		for name, property of src._sealProperties {
			@sealProperties[name] = property
		}

		if src.isRequired() || src.isAlien() {
			this.setAlterationReference(src)
		}

		return this
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, ignoreAlteration) { // {{{
		if @alterationReference? {
			const export = {
				kind: TypeKind::Namespace
				namespace: @alterationReference.toReference(references, ignoreAlteration)
				properties: {}
			}

			for name, property of @properties when property.isAlteration() {
				export.properties[name] = property.toExportOrIndex(references, ignoreAlteration)
			}

			return export
		}
		else {
			const export = {
				kind: TypeKind::Namespace
				sealed: @sealed
				properties: {}
			}

			for name, property of @properties {
				export.properties[name] = property.toExportOrIndex(references, ignoreAlteration)
			}

			return export
		}
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for :value of @properties {
			value.flagExported(explicitly)
		}

		return this
	} // }}}
	getProperty(name: String): Type { // {{{
		if @properties[name] is Type {
			return @properties[name].type()
		}
		else {
			return null
		}
	} // }}}
	hasProperty(name: String): Boolean => @properties[name] is Type
	isExtendable() => true
	isFlexible() => @sealed
	isNamespace() => true
	isSealable() => true
	isSealedProperty(name: String) => @sealed && @sealProperties[name] == true
	matchSignatureOf(that, matchables) { // {{{
		if that is NamespaceType {
			for name, property of that._properties {
				if !@properties[name]?.matchSignatureOf(property, matchables) {
					return false
				}
			}

			return true
		}

		return false
	} // }}}
	setAlterationReference(@alterationReference) { // {{{
		@alteration = true
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

class NamespacePropertyType extends Type {
	private {
		_alteration: Boolean	= false
		_type: Type
	}
	static {
		fromAST(data, node) => new NamespacePropertyType(node.scope(), Type.fromAST(data, node))
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	equals(b) { // {{{
		if b is NamespacePropertyType {
			return @type.equals(b.type())
		}
		else {
			return false
		}
	} // }}}
	export(references, ignoreAlteration) { // {{{
		let export

		if @type is ReferenceType {
			export = @type.toReference(references, ignoreAlteration)

			if export is String {
				export = {
					type: export
				}
			}
		}
		else {
			export = @type.export(references, ignoreAlteration)
		}

		export.sealed = this.isSealed()

		return export
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		@type.flagExported(explicitly)

		return this
	} // }}}
	flagReferenced() { // {{{
		@type.flagReferenced()

		return this
	} // }}}
	flagSealed() { // {{{
		@type = @type.flagSealed()

		return this
	} // }}}
	isAlteration() => @alteration
	isSealed() => @type.isSealed()
	matchSignatureOf(b: Type, matchables): Boolean { // {{{
		if b is NamespacePropertyType {
			return true
		}

		return false
	} // }}}
	toExportOrIndex(references, ignoreAlteration) { // {{{
		if @type.isSealable() {
			return @type.toExportOrIndex(references, ignoreAlteration)
		}
		else if @type.referenceIndex() != -1 {
			return {
				sealed: @type.isSealed()
				type: @type.referenceIndex()
			}
		}
		else if @type.isReferenced() {
			return {
				sealed: this.isSealed()
				type: @type.toMetadata(references, ignoreAlteration)
			}
		}
		else {
			return this.export(references, ignoreAlteration)
		}
	} // }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote() => @type.toQuote()
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
	type() => @type
}