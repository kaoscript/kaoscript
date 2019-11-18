class NamedType extends Type {
	private {
		_cloned: Boolean 				= false
		_container: NamedContainerType?	= null
		_name: String
		_type: Type
	}
	constructor(@name, @type) { // {{{
		super(type.scope())
	} // }}}
	canBeBoolean() => @type.canBeBoolean()
	canBeNumber(any = true) => @type.canBeNumber(any)
	canBeString(any = true) => @type.canBeString(any)
	clone() { // {{{
		@cloned = true

		return new NamedType(@name, @type.clone())
	} // }}}
	condense() { // {{{
		@type.condense()

		return this
	} // }}}
	container() => @container
	container(@container) => this
	discard() => @type.discard()
	discardAlias() => @type.discardAlias()
	discardName() => @type
	duplicate() => new NamedType(@name, @type)
	export(references, mode) { // {{{
		if @type is ClassType && (@type.isPredefined() || !(@type.isExported() || @type.isAlien())) {
			return @name
		}
		else {
			return @type.export(references, mode)
		}
	} // }}}
	flagAlien() { // {{{
		@type.flagAlien()

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
	flagRequired() { // {{{
		@type.flagRequired()

		return this
	} // }}}
	flagSealed() { // {{{
		@type.flagSealed()

		return this
	} // }}}
	getHierarchy() { // {{{
		if @type is ClassType {
			return @type.getHierarchy(@name)
		}
		else {
			return [@name]
		}
	} // }}}
	getProperty(name: String) => @type.getProperty(name)
	getSealedName() => `__ks_\(@name)`
	getSealedPath() { // {{{
		if @container? {
			return `\(@container.path()).\(this.getSealedName())`
		}
		else {
			return this.getSealedName()
		}
	} // }}}
	hasContainer() => ?@container
	hasProperty(name: String) => @type.hasProperty(name)
	isAlias() => @type.isAlias()
	isAlien() => @type.isAlien()
	isAlteration() => @type.isAlteration()
	isArray() => @type.isArray()
	isBoolean() => @type.isBoolean()
	isCloned() => @cloned
	isClass() => @type.isClass()
	isEnum() => @type.isEnum()
	isExclusion() => @type.isExclusion()
	isExhaustive() => @type.isExhaustive()
	isExhaustive(node) => this.isExhaustive() && !node._options.rules.ignoreMisfit
	isExplicitlyExported() => @type.isExplicitlyExported()
	isExportable() => @type.isExportable()
	isExported() => @type.isExported()
	isExtendable() => @type.isExtendable()
	isFlexible() => @type.isFlexible()
	isHybrid() => @type.isHybrid()
	isInheriting(superclass: NamedType) { // {{{
		let that = this

		while that.type().isExtending() {
			that = that.type().extends()

			if that.name() == superclass {
				return true
			}
		}

		return false
	} // }}}
	isMatching(value: Type, mode: MatchingMode) { // {{{
		if this == value {
			return true
		}
		else if mode & MatchingMode::Exact != 0 {
			return false
		}
		else {
			if value.isAny() {
				return true
			}
			else if value is NamedType {
				if @type is ClassType && value.type() is ClassType {
					if @type.isPredefined() && value.isPredefined() {
						return @name == value.name()
					}
					else {
						return this.isInheriting(value) || @type.isMatching(value.type(), mode)
					}
				}
				else if value.type() is EnumType {
					if @type is EnumType {
						return @name == value.name()
					}
					else {
						return this.isMatching(value.type().type(), mode)
					}
				}
				else if value.type() is ClassType && value.name() == 'Enum' {
					return this.isEnum()
				}
				else if value.isAlias() {
					if this.isAlias() {
						return @name == value.name() || this.discardAlias().isMatching(value.discardAlias(), mode)
					}
					else {
						return this.isMatching(value.discardAlias(), mode)
					}
				}
				else {
					return @type.isMatching(value.type(), mode)
				}
			}
			else if this.isAlias() {
				return this.discardAlias().isMatching(value, mode)
			}
			else if value is UnionType {
				for const type in value.types() {
					if this.isMatching(type, mode) {
						return true
					}
				}

				return false
			}
			else if value is ReferenceType {
				return @name == value.name() || this.isMatching(value.discardReference(), mode)
			}
			else {
				return @type.isMatching(value, mode)
			}
		}
	} // }}}
	isMorePreciseThan(that: Type) { // {{{
		if that is NamedType {
			if this.isClass() && that.isClass() {
				return @name != that.name() && this.matchInheritanceOf(that)
			}
			else if that.isAlias() {
				return this.isMorePreciseThan(that.discardAlias())
			}
		}
		else if that is UnionType {
			for const type in that.types() {
				if this.matchContentOf(type) {
					return true
				}
			}

			return false
		}

		return false
	} // }}}
	isNamed() => true
	isNamespace() => @type.isNamespace()
	isNative() => $natives[@name] == true
	isNullable() => @type.isNullable()
	isNumber() => @type.isNumber()
	isPredefined() => @type.isPredefined()
	isReducible() => true
	isReferenced() => @type.isReferenced()
	isRequired() => @type.isRequired()
	isSealable() => @type.isSealable()
	isSealed() => @type.isSealed()
	isSealedAlien() => @type.isSealedAlien()
	isString() => @type.isString()
	isStruct() => @type.isStruct()
	isTypeOf() => $typeofs[@name]
	isUnion() => @type.isUnion()
	/* isVirtual() => @type.isClass() && $virtuals[@name] */
	isVirtual() => $virtuals[@name]
	matchClassName(that: Type?) { // {{{
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
	} // }}}
	matchContentOf(that: Type?) { // {{{
		if that == null {
			return false
		}
		else if that.isAny() {
			return true
		}
		else if @name == 'Object' && @type is ClassType {
			return @scope.module().getPredefined('Object')!?.matchContentOf(that)
		}
		else if that is NamedType {
			if that.name() == 'Object' && that.type() is ClassType {
				return this.matchContentOf(@scope.module().getPredefined('Object'))
			}
			else if @type is ClassType && that.type() is ClassType {
				return this.matchInheritanceOf(that)
			}
			else if that.type() is EnumType {
				if @type is EnumType {
					return @name == that.name()
				}
				else {
					return this.matchContentOf(that.type().type())
				}
			}
			else if that.isAlias() {
				if this.isAlias() {
					return @name == that.name() || this.discardAlias().matchContentOf(that.discardAlias())
				}
				else {
					return this.matchContentOf(that.discardAlias())
				}
			}
			else {
				return @type.matchContentOf(that)
			}
		}
		else if this.isAlias() {
			return this.discardAlias().matchContentOf(that)
		}
		else if that is UnionType {
			for const type in that.types() {
				if this.matchContentOf(type) {
					return true
				}
			}

			return false
		}
		else if that is ExclusionType {
			const types = that.types()

			if !this.matchContentOf(types[0]) {
				return false
			}

			for const type in types from 1 {
				if this.matchContentOf(type) {
					return false
				}
			}

			return true
		}
		else if that is ReferenceType {
			return @name == that.name() || this.matchContentOf(that.discardReference())
		}
		else if that is DictionaryType {
			return @name == 'Dictionary'
		}
		else {
			return @type.matchContentOf(that)
		}
	} // }}}
	matchInheritanceOf(base: Type, strict = false) { // {{{
		if base is not NamedType || !this.isClass() || !base.isClass() {
			return false
		}

		const basename = base.name()

		if !strict && @name == basename {
			return true
		}

		let that = this
		while that.type().isExtending() {
			that = that.type().extends()

			if that.name() == basename {
				return true
			}
		}

		return false
	} // }}}
	metaReference(references, mode) { // {{{
		if @type is ClassType {
			return @type.metaReference(references, @name, mode)
		}
		else {
			throw new NotSupportedException()
		}
	} // }}}
	name() => @name
	name(@name) => this
	parameter() => @type.parameter()
	path() { // {{{
		if @container? {
			return `\(@container.path()).\(@name)`
		}
		else {
			return @name
		}
	} // }}}
	reduce(type: Type) { // {{{
		if @type.isReducible() {
			return @type.reduce(type)
		}
		else {
			return this
		}
	} // }}}
	referenceIndex() => @type.referenceIndex()
	toAlterationReference(references, mode) { // {{{
		if @type is ClassType {
			return @type.toAlterationReference(references, mode)
		}
		else {
			throw new NotSupportedException()
		}
	} // }}}
	toExportOrIndex(references, mode) => @type.toExportOrIndex(references, mode)
	toFragments(fragments, node)
	toMetadata(references, mode) => @type.toMetadata(references, mode)
	toQuote() => @name
	toReference(references, mode) { // {{{
		if @type is ClassType && @type.isPredefined() {
			return @name
		}
		else {
			return @type.toReference(references, mode)
		}
	} // }}}
	toTestFragments(fragments, node) { // {{{
		if const tof = $runtime.typeof(@name, node) {
			fragments.code(`\(tof)(`).compile(node).code(')')
		}
		else {
			@type.toTestFragments(fragments, node)
		}
	} // }}}
	type() => @type
	walk(fn) { // {{{
		if @type is DictionaryType || @type is NamespaceType {
			@type.walk(fn)
		}
		else {
			throw new NotSupportedException()
		}
	} // }}}
}

class NamedContainerType extends NamedType {
	private {
		_properties			= {}
	}
	constructor(@name, @type) { // {{{
		super(name, type)
	} // }}}
	addProperty(name: String, property: Type) { // {{{
		if property is NamedType {
			property = property.duplicate().container(this)
		}

		@type:DictionaryType.addProperty(name, property)

		@properties[name] = property
	} // }}}
	getProperty(name: String): Type? { // {{{
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
	} // }}}
	hasProperty(name: String): Boolean => @type.hasProperty(name)
	matchContentOf(that: Type?) { // {{{
		if that == null {
			return false
		}
		else if that.isAny() {
			return true
		}
		else if that is NamedContainerType {
			return @name == that.name()
		}
		else if that is UnionType {
			for const type in that.types() {
				if this.matchContentOf(type) {
					return true
				}
			}

			return false
		}
		else if that is ExclusionType {
			const types = that.types()

			if !this.matchContentOf(types[0]) {
				return false
			}

			for const type in types from 1 {
				if this.matchContentOf(type) {
					return false
				}
			}

			return true
		}
		else if that is ReferenceType {
			return @name == that.name() || this.matchContentOf(that.discardReference())
		}
		else {
			return @type.matchContentOf(that)
		}
	} // }}}
}