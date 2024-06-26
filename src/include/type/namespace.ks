class NamespaceType extends Type {
	private late {
		@altering: Boolean					= false
		@alterations: Object				= {}
		@majorOriginal: NamespaceType?
		@properties: Object					= {}
		@sealProperties: Object				= {}
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): NamespaceType { # {{{
			var type = NamespaceType.new(scope)

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
		super(NamespaceTypeScope.new(scope))
	} # }}}
	addFunction(name: String, type: FunctionType) { # {{{
		if var property ?= @properties[name] {
			var propertyType = property.type()

			if propertyType is OverloadedFunctionType {
				propertyType.addFunction(type)
			}
			else if propertyType is FunctionType {
				throw NotImplementedException.new()
			}
			else {
				throw NotSupportedException.new()
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
			property = NamespacePropertyType.new(property.scope(), property)
		}

		var variable = Variable.new(name, false, false, property.type())

		@scope.addVariable(name, variable)

		@properties[name] = property

		if property.type().isSealed() {
			@sealProperties[name] = true
		}

		@alterations[name] = true

		var type = variable.getDeclaredType()

		if @standardLibrary ~~ .Opened && type.isStandardLibrary(LibSTDMode.No) {
			@standardLibrary += .Augmented
		}

		return type
	} # }}}
	addPropertyFromAST(data, name, node) { # {{{
		var mut type = Type.fromAST(data, node)

		var options = Attribute.configure(data, null, AttributeTarget.Property, node.file())

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

		var variable = Variable.new(name, false, false, type)

		@scope.addVariable(name, variable)

		var property = NamespacePropertyType.new(@scope, variable.getDeclaredType())

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
		var that = NamespaceType.new(@scope:!!!(Scope))

		that.copyFrom(this)

		if @requirement || @alien {
			that.originals(this)
		}

		return that
	} # }}}
	copyFrom(src: NamespaceType) { # {{{
		@alien = src._alien
		@auxiliary = src._auxiliary
		@complete = src._complete
		@requirement = src._requirement
		@required = src._required
		@sealed = src._sealed
		@system = src._system

		if src._standardLibrary > @standardLibrary {
			@standardLibrary = src._standardLibrary
		}

		for var property, name of src._properties {
			@properties[name] = property
		}
		for var property, name of src._sealProperties {
			@sealProperties[name] = property
		}

		return this
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var mut exportSuper = false

		if ?@majorOriginal {
			if mode ~~ ExportMode.Export {
				exportSuper = @hasExportableOriginals()
			}
			else if mode ~~ ExportMode.Requirement {
				var mut original? = @majorOriginal

				while ?original {
					if original.isRequirement() || original.referenceIndex() != -1 {
						exportSuper = true
						break
					}
					else {
						original = original._majorOriginal
					}
				}
			}
		}

		var libstd: LibSTDMode = if module.isStandardLibrary() && @standardLibrary == .No set .Yes + .Closed else @standardLibrary

		if exportSuper {
			var export = {
				kind: TypeKind.Namespace
				libstd if libstd != .No
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
				kind: TypeKind.Namespace
				libstd if libstd != .No
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
		if ?@properties[name] {
			return @properties[name].type()
		}
		else {
			return null
		}
	} # }}}
	hasExportableOriginals() { # {{{
		if ?@majorOriginal {
			return @majorOriginal._referenceIndex != -1 || @majorOriginal.hasExportableOriginals()
		}
		else {
			return false
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
	hasProperty(name: String): Boolean => ?@properties[name]
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
	assist isSubsetOf(value: NamespaceType, generics, subtypes, mode) { # {{{
		for var property, name of value._properties {
			if !@properties[name]?.isSubsetOf(property, mode) {
				return false
			}
		}

		return true
	} # }}}
	override makeMemberCallee(property % propName, name, generics, node) { # {{{
		if var property ?= @getProperty(propName) {
			if property is FunctionType || property is OverloadedFunctionType {
				var assessment = property.assessment(propName, node)

				match var result = node.matchArguments(assessment) {
					is LenientCallMatchResult {
						node.addCallee(LenientFunctionCallee.new(node.data(), assessment, result, node))
					}
					is PreciseCallMatchResult with var { matches } {
						if matches.length == 1 {
							var match = matches[0]

							if match.function.isAlien() || match.function.index() == -1 {
								node.addCallee(LenientFunctionCallee.new(node.data(), assessment, [match.function], node))
							}
							else {
								node.addCallee(PreciseFunctionCallee.new(node.data(), assessment, matches, node))
							}
						}
						else {
							var functions = [match.function for var match in matches]

							node.addCallee(LenientFunctionCallee.new(node.data(), assessment, functions, node))
						}
					}
					else {
						return () => {
							if property.isExhaustive(node) {
								ReferenceException.throwNoMatchingFunctionInNamespace(propName, name, node.arguments(), node)
							}
							else {
								node.addCallee(DefaultCallee.new(node.data(), node.object(), null, node))
							}
						}
					}
				}
			}
			else if property is SealableType {
				@makeMemberCallee(propName, property.type(), property.isSealed(), name, generics, node)
			}
			else {
				@makeMemberCallee(propName, property, @isSealedProperty(propName), name, generics, node)
			}
		}
		else if @isExhaustive(node) {
			ReferenceException.throwNotDefinedProperty(propName, node)
		}
		else {
			node.addCallee(DefaultCallee.new(node.data(), node.object(), null, node))
		}

		return null
	} # }}}
	makeMemberCallee(name: String, property: Type, sealed: Boolean, named: NamedType, generics: AltType[], node: CallExpression) { # {{{
		if property is FunctionType {
			if sealed {
				node.addCallee(SealedFunctionCallee.new(node.data(), named, name, property.getReturnType(), node))
			}
			else {
				property.makeCallee(name, generics, node)
			}
		}
		else if property is OverloadedFunctionType {
			property.makeCallee(name, generics, node)
		}
		else {
			node.addCallee(DefaultCallee.new(node.data(), node.object(), null, property, node))
		}
	} # }}}
	matchContentOf(value: Type) => value is ReferenceType && value.isNamespace()
	assist merge(value: NamespaceType) { # {{{
		@auxiliary ||= value.hasAuxiliary()

		for var property, name of value._properties {
			@addProperty(name, property)
		}
	} # }}}
	originals(@majorOriginal): valueof this { # {{{
		@altering = true
	} # }}}
	properties() => @properties
	setExhaustive(@exhaustive) { # {{{
		for var property of @properties {
			property.setExhaustive(@exhaustive)
		}

		return this
	} # }}}
	override setStandardLibrary(standardLibrary) { # {{{
		super(standardLibrary)

		var submode: LibSTDMode = if @standardLibrary ~~ .Yes set .Yes + .Closed else .No

		for var property of @properties {
			property.setStandardLibrary(submode)
		}
	} # }}}
	shallBeNamed() => true
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new()
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
		fromAST(data, node) => NamespacePropertyType.new(node.scope(), Type.fromAST(data, node))
	}
	constructor(@scope, @type) { # {{{
		super(scope)
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
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
	assist isSubsetOf(value: NamespacePropertyType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact {
			return @type.isSubsetOf(value.type(), MatchingMode.Exact)
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
	override toVariations(variations) { # {{{
		@type.toVariations(variations)
	} # }}}
	type() => @type

	proxy @type {
		toPositiveTestFragments
		toQuote
		setExhaustive
	}
}
