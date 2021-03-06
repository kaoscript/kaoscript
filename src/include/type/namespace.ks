class NamespaceType extends Type {
	private lateinit {
		_alteration: Boolean					= false
		_alterationReference: NamespaceType
		_properties: Dictionary					= {}
		_sealProperties: Dictionary				= {}
	}
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new NamespaceType(scope)

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			if data.namespace? {
				alterations[data.namespace.reference] = index

				queue.push(() => {
					const source = references[data.namespace.reference]

					type.copyFrom(source.type())

					for const property, name of data.properties {
						type.addPropertyFromMetadata(name, property, metadata, references, alterations, queue, node)
					}
				})
			}
			else {
				if data.systemic {
					type.flagSystemic()
				}
				else if data.sealed {
					type.flagSealed()
				}

				queue.push(() => {
					for const property, name of data.properties {
						type.addPropertyFromMetadata(name, property, metadata, references, alterations, queue, node)
					}
				})
			}

			return type
		} // }}}
	}
	constructor(scope: Scope) { // {{{
		super(new NamespaceTypeScope(scope))
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
	addPropertyFromAST(data, node) { // {{{
		const type = Type.fromAST(data, node)
		const options = Attribute.configure(data, null, AttributeTarget::Property, node.file())

		if options.rules.nonExhaustive {
			type.setExhaustive(false)
		}

		return this.addProperty(data.name.name, type)
	} // }}}
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
		const that = new NamespaceType(@scope:Scope)

		return that.copyFrom(this)
	} // }}}
	copyFrom(src: NamespaceType) { // {{{
		@sealed = src._sealed
		@systemic = src._systemic

		for const property, name of src._properties {
			@properties[name] = property
		}
		for const property, name of src._sealProperties {
			@sealProperties[name] = property
		}

		if src.isRequired() || src.isAlien() {
			this.setAlterationReference(src)
		}

		return this
	} // }}}
	export(references, mode) { // {{{
		if @alterationReference? {
			const export = {
				kind: TypeKind::Namespace
				exhaustive: this.isExhaustive()
				namespace: @alterationReference.toReference(references, mode)
				properties: {}
			}

			for const property, name of @properties when property.isAlteration() {
				export.properties[name] = property.toExportOrIndex(references, mode)
			}

			return export
		}
		else {
			const export = {
				kind: TypeKind::Namespace
				sealed: @sealed
				systemic: @systemic
				exhaustive: this.isExhaustive()
				properties: {}
			}

			for const property, name of @properties {
				export.properties[name] = property.toExportOrIndex(references, mode)
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

		for const value of @properties {
			value.flagExported(explicitly)
		}

		return this
	} // }}}
	getProperty(name: String): Type? { // {{{
		if @properties[name] is Type {
			return @properties[name].type()
		}
		else {
			return null
		}
	} // }}}
	hasProperty(name: String): Boolean => @properties[name] is Type
	isExhaustive() { // {{{
		if @exhaustive {
			return true
		}

		if @alteration {
			return @alterationReference.isExhaustive()
		}

		return super.isExhaustive()
	} // }}}
	isExtendable() => true
	isFlexible() => @sealed
	isMatching(value: NamespaceType, mode: MatchingMode) { // {{{
		for const property, name of value._properties {
			if !@properties[name]?.isMatching(property, mode) {
				return false
			}
		}

		return true
	} // }}}
	isNamespace() => true
	isSealable() => true
	isSealedProperty(name: String) => @sealed && @sealProperties[name] == true
	matchContentOf(that: Type) => that is ReferenceType && that.isNamespace()
	setAlterationReference(@alterationReference) { // {{{
		@alteration = true
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		throw new NotImplementedException()
	} // }}}
	walk(fn) { // {{{
		for const type, name of @properties {
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
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) { // {{{
		let export

		if @type is ReferenceType {
			export = @type.toReference(references, mode)
		}
		else {
			export = @type.export(references, mode)
		}

		if export is String {
			export = {
				type: export
			}
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
	isMatching(value: NamespacePropertyType, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Exact {
			return @type.isMatching(value.type(), MatchingMode::Exact)
		}
		else {
			return true
		}
	} // }}}
	isSealed() => @type.isSealed()
	toExportOrIndex(references, mode) { // {{{
		if @type.isSealable() {
			return @type.toExportOrIndex(references, mode)
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
				type: @type.toMetadata(references, mode)
			}
		}
		else {
			return this.export(references, mode)
		}
	} // }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote(...args) => @type.toQuote(...args)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	type() => @type
}