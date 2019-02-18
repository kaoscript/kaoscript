class NamespaceType extends Type {
	private {
		_alterationReference: NamespaceType
		_properties: Object			= {}
		_sealProperties: Object		= {}
	}
	static {
		import(data, references: Array, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new NamespaceType(scope)

			if data.namespace? {
				queue.push(() => {
					const source = references[data.namespace.reference]

					type.copyFrom(source.type())

					for name, property of data.properties {
						type.addPropertyFromMetadata(name, property, references, node)
					}
				})
			}
			else {
				if data.sealed {
					type.flagSealed()
				}

				queue.push(() => {
					for name, property of data.properties {
						type.addPropertyFromMetadata(name, property, references, node)
					}
				})
			}

			return type
		} // }}}
	}
	constructor(scope: AbstractScope) { // {{{
		super(new NamespaceScope(scope))
	} // }}}
	addProperty(name: String, type: Type, alteration: Boolean = false) { // {{{
		const variable = new Variable(name, false, false, type)

		@scope.addVariable(name, variable)

		type = variable.type()

		const internalType = this.toPropertyType(type)

		@properties[name] = internalType

		if @sealed {
			@sealProperties[name] = true

			internalType.flagSealed()
		}

		if alteration {
			internalType.flagAlteration()
		}

		return type
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		const name = data.name.name
		const variable = new Variable(name, false, false, Type.fromAST(data, node))

		@scope.addVariable(name, variable)

		const type = variable.type()
		const internalType = this.toPropertyType(type)

		@properties[name] = internalType

		if type.isSealed() {
			@sealProperties[name] = true
		}

		return type
	} // }}}
	addPropertyFromMetadata(name, data, references, node) { // {{{
		const type = Type.fromMetadata(data, references, @scope, node)

		if type._scope != @scope {
			type._scope = @scope
		}

		const variable = new Variable(name, false, false, type)

		@scope.addVariable(name, variable)

		const internalType = this.toPropertyType(variable.type())

		@properties[name] = internalType

		if type.isSealed() {
			@sealProperties[name] = true
		}

		return variable.type()
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

			for name, value of @properties when value.isAlteration() {
				export.properties[name] = value.toExportOrIndex(references, ignoreAlteration)
			}

			return export
		}
		else {
			const export = {
				kind: TypeKind::Namespace
				sealed: @sealed
				properties: {}
			}

			for name, value of @properties {
				export.properties[name] = value.toExportOrIndex(references, ignoreAlteration)
			}

			return export
		}
	} // }}}
	flagExported() { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for :value of @properties {
			value.flagExported()
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
	setAlterationReference(@alterationReference)
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	private toPropertyType(type) { // {{{
		if type.isAny() || type.discardName() is ReferenceType {
			return new NamespaceVariableType(@scope, type)
		}
		else {
			return new NamespaceDirectType(@scope, type)
		}
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

class NamespaceVariableType extends SealableType {
	private {
		_alteration: Boolean	= false
	}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
}

class NamespaceDirectType extends SealableType {
	private {
		_alteration: Boolean	= false
	}
	export(references, ignoreAlteration) { // {{{
		const export = @type.export(references, ignoreAlteration)

		export.sealed = this.isSealed()

		return export
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
	toExportOrIndex(references, ignoreAlteration) { // {{{
		if @type.isSealable() {
			return @type.toExportOrIndex(references, ignoreAlteration)
		}
		else if @type.referenceIndex() != -1 {
			return {
				kind: TypeKind::Sealable
				sealed: @type.isSealed()
				type: @type.referenceIndex()
			}
		}
		else if @type.isReferenced() {
			return {
				kind: TypeKind::Sealable
				sealed: this.isSealed()
				type: @type.toMetadata(references, ignoreAlteration)
			}
		}
		else {
			return this.export(references, ignoreAlteration)
		}
	} // }}}
}