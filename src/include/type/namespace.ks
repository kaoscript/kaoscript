class NamespaceType extends Type {
	private lateinit {
		_altering: Boolean					= false
		_alterations: Dictionary			= {}
		_majorOriginal: NamespaceType?
		_properties: Dictionary				= {}
		_sealProperties: Dictionary			= {}
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): NamespaceType { // {{{
			const type = new NamespaceType(scope)

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			if data.original? {

				queue.push(() => {
					const original = references[data.original]

					type.copyFrom(original.discardName())

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
	addFunction(name: String, type: FunctionType) { // {{{
		if const property = @properties[name] {
			const propertyType = property.type()

			if propertyType is OverloadedFunctionType {
				propertyType.addFunction(type)
			}
			else if propertyType is FunctionType {
				throw new NotImplementedException()
			}
			else {
				throw new NotSupportedException()
			}

			if type.isSealed() {
				@sealProperties[name] = true
			}

			@alterations[name] = true
		}
		else {
			type.index(0)

			this.addProperty(name, type)
		}

		return type.index()
	} // }}}
	addProperty(name: String, property: Type) { // {{{
		if property is not NamespacePropertyType {
			property = new NamespacePropertyType(property.scope(), property)
		}

		const variable = new Variable(name, false, false, property.type())

		@scope.addVariable(name, variable)

		@properties[name] = property

		if property.type().isSealed() {
			@sealProperties[name] = true
		}

		@alterations[name] = true

		return variable.getDeclaredType()
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		let type = Type.fromAST(data, node)

		const options = Attribute.configure(data, null, AttributeTarget::Property, node.file())

		if options.rules.nonExhaustive {
			type.setExhaustive(false)
		}
		else if @exhaustive {
			type.setExhaustive(true)
		}

		if @alien {
			type = type.flagAlien()
		}

		if type is FunctionType && type.index() == -1 {
			type.index(0)
		}

		return this.addProperty(data.name.name, type)
	} // }}}
	addPropertyFromMetadata(name, data, metadata, references, alterations, queue, node) { // {{{
		const type = Type.import(data, metadata, references, alterations, queue, @scope, node)

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

		that.copyFrom(this)

		if @requirement || @alien {
			that.originals(this)
		}

		return that
	} // }}}
	copyFrom(src: NamespaceType) { // {{{
		@alien = src._alien
		@sealed = src._sealed
		@systemic = src._systemic
		@requirement = src._requirement
		@required = src._required

		for const property, name of src._properties {
			@properties[name] = property
		}
		for const property, name of src._sealProperties {
			@sealProperties[name] = property
		}

		return this
	} // }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { // {{{
		if ?@majorOriginal {
			const export = {
				kind: TypeKind::Namespace
				original: @majorOriginal.referenceIndex()
				exhaustive: this.isExhaustive()
				properties: {}
			}

			for const property, name of @properties {
				if @alterations[name] {
					export.properties[name] = property.toExportOrIndex(references, indexDelta, mode, module)
				}
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
				export.properties[name] = property.toExportOrIndex(references, indexDelta, mode, module)
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
	hasMatchingFunction(name, type: FunctionType, mode: MatchingMode) { // {{{
		if @properties[name] is FunctionType | OverloadedFunctionType {
			if @properties[name].isMatching(type, mode) {
				return true
			}
		}

		return false
	} // }}}
	hasProperty(name: String): Boolean => @properties[name] is Type
	isContainer() => true
	isExhaustive() { // {{{
		if @exhaustive {
			return true
		}

		if @altering {
			return @majorOriginal.isExhaustive()
		}

		return super.isExhaustive()
	} // }}}
	isExtendable() => true
	isFlexible() => @sealed
	isNamespace() => true
	isSealable() => true
	isSealedProperty(name: String) => @sealed && @sealProperties[name] == true
	isSubsetOf(value: NamespaceType, mode: MatchingMode) { // {{{
		for const property, name of value._properties {
			if !@properties[name]?.isSubsetOf(property, mode) {
				return false
			}
		}

		return true
	} // }}}
	matchContentOf(value: Type) => value is ReferenceType && value.isNamespace()
	originals(@majorOriginal): this { // {{{
		@altering = true
	} // }}}
	setExhaustive(@exhaustive) { // {{{
		for const property of @properties {
			property.setExhaustive(@exhaustive)
		}

		return this
	} // }}}
	shallBeNamed() => true
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		throw new NotImplementedException()
	} // }}}
	override toVariations(variations) { // {{{
		variations.push('namespace')

		for const property, name of @properties {
			variations.push(name)

			property.toVariations(variations)
		}
	} // }}}
	walk(fn) { // {{{
		for const type, name of @properties {
			fn(name, type)
		}
	} // }}}
}

class NamespacePropertyType extends Type {
	private {
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
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { // {{{
		let export

		if @type is ReferenceType {
			export = @type.toReference(references, indexDelta, mode, module)
		}
		else {
			export = @type.export(references, indexDelta, mode, module)
		}

		if export is String {
			export = {
				type: export
			}
		}

		export.sealed = this.isSealed()

		return export
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
	isSealed() => @type.isSealed()
	isSubsetOf(value: NamespacePropertyType, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Exact {
			return @type.isSubsetOf(value.type(), MatchingMode::Exact)
		}
		else {
			return true
		}
	} // }}}
	setExhaustive(exhaustive) { // {{{
		if !?@type.getExhaustive() {
			@type.setExhaustive(exhaustive)
		}

		return this
	} // }}}
	toExportOrIndex(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { // {{{
		if @type.isSealable() {
			return @type.toExportOrIndex(references, indexDelta, mode, module)
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
				type: @type.toMetadata(references, indexDelta, mode, module)
			}
		}
		else {
			return this.export(references, indexDelta, mode, module)
		}
	} // }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	// TODO add alias
	toQuote() => @type.toQuote()
	toQuote(double) => @type.toQuote(double)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	override toVariations(variations) { // {{{
		@type.toVariations(variations)
	} // }}}
	type() => @type
}
