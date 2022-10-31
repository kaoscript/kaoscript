class NamespaceType extends Type {
	private late {
		@altering: Boolean					= false
		@alterations: Dictionary			= {}
		@majorOriginal: NamespaceType?
		@properties: Dictionary				= {}
		@sealProperties: Dictionary			= {}
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): NamespaceType { # {{{
			var type = new NamespaceType(scope)

			if ?data.exhaustive {
				type._exhaustive = data.exhaustive
			}

			if ?data.original {

				queue.push(() => {
					var original = references[data.original]

					type.copyFrom(original.discardName())

					for var property, name of data.properties {
						type.addPropertyFromMetadata(name, property, metadata, references, alterations, queue, node)
					}
				})
			}
			else {
				if data.system {
					type.flagSystem()
				}
				else if data.sealed {
					type.flagSealed()
				}

				queue.push(() => {
					for var property, name of data.properties {
						type.addPropertyFromMetadata(name, property, metadata, references, alterations, queue, node)
					}
				})
			}

			return type.flagComplete()
		} # }}}
	}
	constructor(scope: Scope) { # {{{
		super(new NamespaceTypeScope(scope))
	} # }}}
	addFunction(name: String, type: FunctionType) { # {{{
		if var property ?= @properties[name] {
			var propertyType = property.type()

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

			@addProperty(name, type)
		}

		return type.index()
	} # }}}
	addProperty(name: String, mut property: Type) { # {{{
		if property is not NamespacePropertyType {
			property = new NamespacePropertyType(property.scope(), property)
		}

		var variable = new Variable(name, false, false, property.type())

		@scope.addVariable(name, variable)

		@properties[name] = property

		if property.type().isSealed() {
			@sealProperties[name] = true
		}

		@alterations[name] = true

		return variable.getDeclaredType()
	} # }}}
	addPropertyFromAST(data, node) { # {{{
		var mut type = Type.fromAST(data, node)

		var options = Attribute.configure(data, null, AttributeTarget::Property, node.file())

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

		return @addProperty(data.name.name, type)
	} # }}}
	addPropertyFromMetadata(name, data, metadata, references, alterations, queue, node) { # {{{
		var type = Type.import(data, metadata, references, alterations, queue, @scope, node)

		if type._scope != @scope {
			type._scope = @scope
		}

		var variable = new Variable(name, false, false, type)

		@scope.addVariable(name, variable)

		var property = new NamespacePropertyType(@scope, variable.getDeclaredType())

		@properties[name] = property

		if data.sealed {
			property.flagSealed()
		}

		if property.type().isSealed() {
			@sealProperties[name] = true
		}

		return variable.getDeclaredType()
	} # }}}
	clone() { # {{{
		var that = new NamespaceType(@scope:Scope)

		that.copyFrom(this)

		if @requirement || @alien {
			that.originals(this)
		}

		return that
	} # }}}
	copyFrom(src: NamespaceType) { # {{{
		@alien = src._alien
		@complete = src._complete
		@sealed = src._sealed
		@system = src._system
		@requirement = src._requirement
		@required = src._required

		for var property, name of src._properties {
			@properties[name] = property
		}
		for var property, name of src._sealProperties {
			@sealProperties[name] = property
		}

		return this
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if ?@majorOriginal {
			var export = {
				kind: TypeKind::Namespace
				original: @majorOriginal.referenceIndex()
				exhaustive: @isExhaustive()
				properties: {}
			}

			for var property, name of @properties {
				if @alterations[name] {
					export.properties[name] = property.toExportOrIndex(references, indexDelta, mode, module)
				}
			}

			return export
		}
		else {
			var export = {
				kind: TypeKind::Namespace
				sealed: @sealed
				system: @system
				exhaustive: @isExhaustive()
				properties: {}
			}

			for var property, name of @properties {
				export.properties[name] = property.toExportOrIndex(references, indexDelta, mode, module)
			}

			return export
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for var value of @properties {
			value.flagExported(explicitly)
		}

		return this
	} # }}}
	getProperty(name: String): Type? { # {{{
		if @properties[name] is Type {
			return @properties[name].type()
		}
		else {
			return null
		}
	} # }}}
	hasMatchingFunction(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @properties[name] is FunctionType | OverloadedFunctionType {
			if @properties[name].isMatching(type, mode) {
				return true
			}
		}

		return false
	} # }}}
	hasProperty(name: String): Boolean => @properties[name] is Type
	isContainer() => true
	isExhaustive() { # {{{
		if @exhaustive {
			return true
		}

		if @altering {
			return @majorOriginal.isExhaustive()
		}

		return super.isExhaustive()
	} # }}}
	isExtendable() => true
	isFlexible() => @sealed
	isNamespace() => true
	isSealable() => true
	isSealedProperty(name: String) => @sealed && @sealProperties[name] == true
	isSubsetOf(value: NamespaceType, mode: MatchingMode) { # {{{
		for var property, name of value._properties {
			if !@properties[name]?.isSubsetOf(property, mode) {
				return false
			}
		}

		return true
	} # }}}
	matchContentOf(value: Type) => value is ReferenceType && value.isNamespace()
	originals(@majorOriginal): this { # {{{
		@altering = true
	} # }}}
	properties() => @properties
	setExhaustive(@exhaustive) { # {{{
		for var property of @properties {
			property.setExhaustive(@exhaustive)
		}

		return this
	} # }}}
	shallBeNamed() => true
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('namespace')

		for var property, name of @properties {
			variations.push(name)

			property.toVariations(variations)
		}
	} # }}}
	walk(fn) { # {{{
		for var type, name of @properties {
			fn(name, type)
		}
	} # }}}
}

class NamespacePropertyType extends Type {
	private {
		@type: Type
	}
	static {
		fromAST(data, node) => new NamespacePropertyType(node.scope(), Type.fromAST(data, node))
	}
	constructor(@scope, @type) { # {{{
		super(scope)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var dyn export

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

		export.sealed = @isSealed()

		return export
	} # }}}
	flagAlien() { # {{{
		@type.flagAlien()

		return this
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		@type.flagExported(explicitly)

		return this
	} # }}}
	flagReferenced() { # {{{
		@type.flagReferenced()

		return this
	} # }}}
	flagSealed() { # {{{
		@type = @type.flagSealed()

		return this
	} # }}}
	isSealed() => @type.isSealed()
	isSubsetOf(value: NamespacePropertyType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Exact {
			return @type.isSubsetOf(value.type(), MatchingMode::Exact)
		}
		else {
			return true
		}
	} # }}}
	setExhaustive(exhaustive) { # {{{
		if !?@type.getExhaustive() {
			@type.setExhaustive(exhaustive)
		}

		return this
	} # }}}
	toExportOrIndex(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
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
				sealed: @isSealed()
				type: @type.toMetadata(references, indexDelta, mode, module)
			}
		}
		else {
			return @export(references, indexDelta, mode, module)
		}
	} # }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	override toVariations(variations) { # {{{
		@type.toVariations(variations)
	} # }}}
	type() => @type

	proxy {
		toQuote = @type.toQuote
	}
}
