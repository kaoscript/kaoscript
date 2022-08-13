class NamedType extends Type {
	private {
		_cloned: Boolean 				= false
		_container: NamedContainerType?	= null
		_name: String
		_type: Type
	}
	constructor(@name, @type) { # {{{
		super(type.scope())
	} # }}}
	asReference() { # {{{
		if @type.isClass() {
			return @scope.reference('Class')
		}
		else {
			return this
		}
	} # }}}
	canBeBoolean() => @type.canBeBoolean()
	canBeFunction(any = true) => @type.canBeFunction(any)
	canBeNumber(any = true) => @type.canBeNumber(any)
	canBeString(any = true) => @type.canBeString(any)
	clone() { # {{{
		@cloned = true

		return new NamedType(@name, @type.clone())
	} # }}}
	container() => @container
	container(@container) => this
	discard() => @type.discard()
	discardAlias() => this.isAlias() ? @type.discardAlias() : this
	discardName() => @type
	duplicate() => new NamedType(@name, @type)
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @type is ClassType && (@type.isPredefined() || !(@type.isExported() || @type.isAlien())) {
			return @name
		}
		else {
			return @type.export(references, indexDelta, mode, module)
		}
	} # }}}
	flagAlien() { # {{{
		@type.flagAlien()

		return this
	} # }}}
	flagAltering(): this { # {{{
		@type.flagAltering()
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		@type.flagExported(explicitly)

		return this
	} # }}}
	flagReferenced() { # {{{
		@type.flagReferenced()

		return this
	} # }}}
	flagRequired() { # {{{
		@type.flagRequired()

		return this
	} # }}}
	flagRequirement(): this { # {{{
		@type.flagRequirement()
	} # }}}
	flagSealed() { # {{{
		@type.flagSealed()

		return this
	} # }}}
	getAlterationReference() => @type.getAlterationReference()
	getHierarchy() { # {{{
		if @type is ClassType {
			return @type.getHierarchy(@name)
		}
		else {
			return [@name]
		}
	} # }}}
	getMajorReferenceIndex() => @type.getMajorReferenceIndex()
	getProperty(name: String) => @type.getProperty(name)
	getSealedName() => `__ks_\(@name)`
	getSealedPath() { # {{{
		if @container? {
			return `\(@container.path()).\(this.getSealedName())`
		}
		else {
			return this.getSealedName()
		}
	} # }}}
	hasContainer() => ?@container
	hashCode() => `&\(@name)`
	hasProperty(name: String) => @type.hasProperty(name)
	isAlias() => @type.isAlias()
	isAlien() => @type.isAlien()
	isAltering() => @type.isAltering()
	isArray() => @type.isArray()
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if super(value, anycast, nullcast, downcast) {
			return true
		}
		else if value is NamedType {
			if value.isAlias() {
				if this.isAlias() {
					return @name == value.name() || this.discardAlias().isAssignableToVariable(value.discardAlias(), anycast, nullcast, downcast)
				}
				else {
					return this.isAssignableToVariable(value.discardAlias(), anycast, nullcast, downcast)
				}
			}
			else if @type.isClass() && value.isClass() {
				return @name == 'Class' || this.isInheriting(value) || (downcast && value.isInheriting(this))
			}
			else if @type.isEnum() {
				return @type.type().isAssignableToVariable(value, anycast, nullcast, downcast)
			}
			else if @type.isStruct() && value.isStruct() {
				return @name == 'Struct' || this.isInheriting(value) || (downcast && value.isInheriting(this))
			}
			else if @type.isTuple() && value.isTuple() {
				return @name == 'Tuple' || this.isInheriting(value) || (downcast && value.isInheriting(this))
			}
			else {
				return false
			}
		}
		else if value is ReferenceType {
			if value.name() == 'Class' {
				return @type.isClass()
			}
			else if value.name() == 'Enum' {
				return @type.isEnum()
			}
			else if value.name() == 'Namespace' {
				return @type.isNamespace()
			}
			else if value.name() == 'Struct' {
				return @type.isStruct()
			}
			else if value.name() == 'Tuple' {
				return @type.isTuple()
			}
			else if @type.isClass() {
				return value.name() == 'Class'
			}
			else if @type.isEnum() {
				return value.name() == 'Enum'
			}
			else if @type.isNamespace() {
				return value.name() == 'Namespace'
			}
			else if @type.isStruct() {
				return value.name() == 'Struct'
			}
			else if @type.isTuple() {
				return value.name() == 'Tuple'
			}
			else {
				return this.isAssignableToVariable(value.type(), anycast, nullcast, downcast, limited)
			}
		}
		else if value is UnionType {
			for var type in value.types() {
				if this.isAssignableToVariable(type.discardReference(), anycast, nullcast, downcast, limited) {
					return true
				}
			}

			return false
		}
		else if value is ExclusionType {
			var types = value.types()

			if !this.isAssignableToVariable(types[0].discardReference(), anycast, nullcast, downcast) {
				return false
			}

			for var type in types from 1 {
				if this.isAssignableToVariable(type.discardReference(), anycast, nullcast, downcast) {
					return false
				}
			}

			return true
		}
		else {
			return false
		}
	} # }}}
	isBoolean() => @type.isBoolean()
	isCloned() => @cloned
	isClass() => @type.isClass()
	override isComparableWith(type) => @type.isComparableWith(type)
	isDictionary() => @type.isDictionary()
	isEnum() => @type.isEnum()
	isExclusion() => @type.isExclusion()
	isExhaustive() => @type.isExhaustive()
	isExhaustive(node) => this.isExhaustive() && !node._options.rules.ignoreMisfit
	isExplicit() => true
	isExplicitlyExported() => @type.isExplicitlyExported()
	isExportable() => @type.isExportable()
	isExported() => @type.isExported()
	isExportingFragment() => @type.isExportingFragment()
	isExtendable() => @type.isExtendable()
	isFlexible() => @type.isFlexible()
	isHybrid() => @type.isHybrid()
	isInheriting(superclass: NamedType) { # {{{
		var mut name = superclass.name()
		var mut that = this

		while that.type().isExtending() {
			that = that.type().extends()

			if that.name() == name {
				return true
			}
		}

		return false
	} # }}}
	isInheriting(superclass: ReferenceType) { # {{{
		return false unless superclass.isInstance()

		return @isInheriting(superclass.type())
	} # }}}
	isInheriting(superclass: Type) => false
	isInstanceOf(value: Type) => @type.isInstanceOf(value)
	isMorePreciseThan(value: Type) { # {{{
		if value is NamedType {
			if this.isClass() && value.isClass() {
				return @name != value.name() && this.matchInheritanceOf(value)
			}
			else if value.isAlias() {
				return this.isMorePreciseThan(value.discardAlias())
			}
		}
		else if value is UnionType {
			for var type in value.types() {
				if this.matchContentOf(value) {
					return true
				}
			}

			return false
		}

		return false
	} # }}}
	isNamed() => true
	isNamespace() => @type.isNamespace()
	isNative() => $natives[@name] == true
	isNullable() => @type.isNullable()
	isNumber() => @type.isNumber()
	isPredefined() => @type.isPredefined()
	isReducible() => true
	isReferenced() => @type.isReferenced()
	isRequired() => @type.isRequired()
	isRequirement() => @type.isRequirement()
	isSealable() => @type.isSealable()
	isSealed() => @type.isSealed()
	isSealedAlien() => @type.isSealedAlien()
	isString() => @type.isString()
	isStruct() => @type.isStruct()
	isSubsetOf(value: Type, mode: MatchingMode) { # {{{
		if this == value {
			return true
		}
		else if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			return false
		}
		else {
			if value.isAny() {
				return true
			}
			else if value.isVoid() {
				return false
			}
			else if value is NamedType {
				if @type is ClassType && value.type() is ClassType {
					if value.isSystemic() && !@type.isSystemic() {
						return false
					}
					else if value.isSealed() && !@type.isSealed() {
						return false
					}
					else if @type.isPredefined() && value.isPredefined() {
						return @scope.isRenamed(@name, value.name(), value.scope(), mode)
					}
					else {
						return @type.isSubsetOf(value.type(), mode + MatchingMode::Subclass)
					}
				}
				else if value.type() is EnumType {
					if @type is EnumType {
						return @scope.isRenamed(@name, value.name(), value.scope(), mode)
					}
					else {
						return this.isSubsetOf(value.type().type(), mode)
					}
				}
				else if value.type() is ClassType && value.name() == 'Enum' {
					return this.isEnum()
				}
				else if value.isAlias() {
					if this.isAlias() {
						return @scope.isRenamed(@name, value.name(), value.scope(), mode) || this.discardAlias().isSubsetOf(value.discardAlias(), mode)
					}
					else {
						return this.isSubsetOf(value.discardAlias(), mode)
					}
				}
				else {
					return @type.isSubsetOf(value.type(), mode)
				}
			}
			else if this.isAlias() {
				return this.discardAlias().isSubsetOf(value, mode)
			}
			else if value is UnionType {
				for var type in value.types() {
					if this.isSubsetOf(type, mode) {
						return true
					}
				}

				return false
			}
			else if value is ReferenceType {
				return @scope.isRenamed(@name, value.name(), value.scope(), mode) || this.isSubsetOf(value.discardReference(), mode)
			}
			else {
				return @type.isSubsetOf(value, mode)
			}
		}
	} # }}}
	isSystemic() => @type.isSystemic()
	isTuple() => @type.isTuple()
	isTypeOf() => $typeofs[@name]
	isUnion() => @type.isUnion()
	isVirtual() => $virtuals[@name]
	majorOriginal() => @type.majorOriginal()
	matchClassName(that: Type?) { # {{{
		if that == null {
			return false
		}
		else if that is NamedType {
			if @type is ClassType && that.type() is ClassType {
				return @name == that.name()
			}
		}
		else if that is ReferenceType {
			return @name == that.name() || this.matchClassName(that.discardReference())
		}

		return false
	} # }}}
	matchContentOf(value: Type?) { # {{{
		if value == null {
			return false
		}
		else if value.isAny() {
			return true
		}
		else if @name == 'Object' && @type is ClassType {
			return @scope.module().getPredefined('Object')!?.matchContentOf(value)
		}
		else if value is NamedType {
			if value.name() == 'Object' && value.type() is ClassType {
				return this.matchContentOf(@scope.module().getPredefined('Object'))
			}
			else if @type is ClassType && value.type() is ClassType {
				return this.matchInheritanceOf(value)
			}
			else if value.type() is EnumType {
				if @type is EnumType {
					return @name == value.name()
				}
				else {
					return this.matchContentOf(value.type())
				}
			}
			else if value.type() is StructType {
				if @type is StructType {
					return this.matchInheritanceOf(value)
				}
				else {
					return @type.matchContentOf(value.type())
				}
			}
			else if value.type() is TupleType {
				if @type is TupleType {
					return this.matchInheritanceOf(value)
				}
				else {
					return @type.matchContentOf(value.type())
				}
			}
			else if value.isAlias() {
				if this.isAlias() {
					return @name == value.name() || @type.discardAlias().matchContentOf(value.discardAlias())
				}
				else {
					return this.matchContentOf(value.discardAlias())
				}
			}
			else {
				return @type.matchContentOf(value)
			}
		}
		else if this.isAlias() {
			return @type.discardAlias().matchContentOf(value)
		}
		else if value is UnionType {
			for var type in value.types() {
				if this.matchContentOf(type) {
					return true
				}
			}

			return false
		}
		else if value is ExclusionType {
			var types = value.types()

			if !this.matchContentOf(types[0]) {
				return false
			}

			for var type in types from 1 {
				if this.matchContentOf(type) {
					return false
				}
			}

			return true
		}
		else if value is ReferenceType {
			return @name == value.name() || this.matchContentOf(value.discardReference())
		}
		else if value is DictionaryType {
			return @name == 'Dictionary'
		}
		else {
			return @type.matchContentOf(value)
		}
	} # }}}
	matchInheritanceOf(base: Type) { # {{{
		var basename = base.name()

		if @name == basename {
			return true
		}

		var mut that = this
		while that.type().isExtending() {
			that = that.type().extends()

			if that.name() == basename {
				return true
			}
		}

		return false
	} # }}}
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @type is ClassType || @type is StructType || @type is TupleType {
			return @type.metaReference(references, indexDelta, mode, module, @name)
		}
		else {
			throw new NotSupportedException()
		}
	} # }}}
	minorOriginal() => @type.minorOriginal()
	name() => @name
	name(@name) => this
	origin() => @type.origin()
	origin(origin) => @type.origin(origin)
	originals(...originals): this { # {{{
		@type.originals(...originals)
	} # }}}
	parameter() => @type.parameter()
	path() { # {{{
		if @container? {
			return `\(@container.path()).\(@name)`
		}
		else {
			return @name
		}
	} # }}}
	reduce(type: Type) { # {{{
		if @type.isReducible() {
			return @type.reduce(type)
		}
		else {
			return this
		}
	} # }}}
	referenceIndex() => @type.referenceIndex()
	resetReferences() => @type.resetReferences()
	setAlterationReference(type: Type) => @type.setAlterationReference(type)
	split(types: Array) { # {{{
		if @type.isAlias() || @type.isUnion() {
			@type.split(types)
		}
		else if @isNullable() {
			types.pushUniq(@setNullable(false), Type.Null)
		}
		else {
			types.pushUniq(this)
		}

		return types
	} # }}}
	toAlterationReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @type is ClassType {
			return @type.toAlterationReference(references, indexDelta, mode, module)
		}
		else {
			throw new NotSupportedException()
		}
	} # }}}
	toCastFragments(fragments) { # {{{
		@type.toCastFragments(fragments)
	} # }}}
	toExportFragment(fragments, name, variable) { # {{{
		if @type.isExportingFragment() {
			super(fragments, name, variable)
		}
	} # }}}
	toExportOrIndex(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => @type.toExportOrIndex(references, indexDelta, mode, module)
	toFragments(fragments, node)
	toMetadata(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => @type.toMetadata(references, indexDelta, mode, module)
	toQuote() => @name
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @type is ClassType && @type.isPredefined() {
			return @name
		}
		else {
			return @type.toReference(references, indexDelta, mode, module)
		}
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		if var tof = $runtime.typeof(@name, node) {
			fragments.code(`!\(tof)(`).compile(node).code(')')
		}
		else {
			@type.toNegativeTestFragments(fragments, node, junction)
		}
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		if var tof = $runtime.typeof(@name, node) {
			fragments.code(`\(tof)(`).compile(node).code(')')
		}
		else {
			@type.toPositiveTestFragments(fragments, node, junction)
		}
	} # }}}
	override toRequiredMetadata(requirements) => @type.toRequiredMetadata(requirements)
	override toVariations(variations) { # {{{
		variations.push('named', @name)

		@type.toVariations(variations)
	} # }}}
	type() => @type
	unflagAltering(): this { # {{{
		@type.unflagAltering()
	} # }}}
	walk(fn) { # {{{
		if @type is DictionaryType || @type is NamespaceType {
			@type.walk(fn)
		}
		else {
			throw new NotSupportedException()
		}
	} # }}}
}

class NamedContainerType extends NamedType {
	private {
		_properties			= {}
	}
	constructor(@name, @type) { # {{{
		super(name, type)
	} # }}}
	addProperty(name: String, mut property: Type) { # {{{
		if property is NamedType {
			property = property.duplicate().container(this)
		}

		@type.addProperty(name, property)

		@properties[name] = property
	} # }}}
	getProperty(name: String): Type? { # {{{
		if @properties[name] is Type {
			return @properties[name]
		}
		else if property ?= @type.getProperty(name) {
			if property is NamedType {
				property = property.duplicate().container(this)
			}

			@properties[name] = property

			return property
		}
		else {
			return null
		}
	} # }}}
	hasProperty(name: String): Boolean => @type.hasProperty(name)
	matchContentOf(value: Type?) { # {{{
		if value == null {
			return false
		}
		else if value.isAny() {
			return true
		}
		else if value is NamedContainerType {
			return @name == value.name()
		}
		else if value is UnionType {
			for var type in value.types() {
				if this.matchContentOf(type) {
					return true
				}
			}

			return false
		}
		else if value is ExclusionType {
			var types = value.types()

			if !this.matchContentOf(types[0]) {
				return false
			}

			for var type in types from 1 {
				if this.matchContentOf(type) {
					return false
				}
			}

			return true
		}
		else if value is ReferenceType {
			return @name == value.name() || this.matchContentOf(value.discardReference())
		}
		else {
			return @type.matchContentOf(value)
		}
	} # }}}
}
