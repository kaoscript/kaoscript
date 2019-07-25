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
	discardAlias() => @type.discardAlias()
	discardName() => @type
	duplicate() => new NamedType(@name, @type)
	equals(b?) => @type.equals(b)
	export(references, ignoreAlteration) { // {{{
		if @type is ClassType && (@type.isPredefined() || !(@type.isExported() || @type.isAlien())) {
			return @name
		}
		else {
			return @type.export(references, ignoreAlteration)
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
	isCloned() => @cloned
	isClass() => @type.isClass()
	isEnum() => @type.isEnum()
	isExhaustive(node) => !(node._options.rules.nonExhaustive || @type.isAlien() || @type.isHybrid() || @type.isSealed())
	isExplicitlyExported() => @type.isExplicitlyExported()
	isExportable() => @type.isExportable()
	isExported() => @type.isExported()
	isExtendable() => @type.isExtendable()
	isFlexible() => @type.isFlexible()
	isHybrid() => @type.isHybrid()
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
	isNative() => $natives[@name] == true
	isNullable() => @type.isNullable()
	isPredefined() => @type.isPredefined()
	isReferenced() => @type.isReferenced()
	isRequired() => @type.isRequired()
	isSealable() => @type.isSealable()
	isSealed() => @type.isSealed()
	isSealedAlien() => @type.isSealedAlien()
	isNamed() => true
	isNamespace() => @type.isNamespace()
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
		else if that is NamedType {
			if @type is ClassType && that.type() is ClassType {
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
				return @type.matchContentOf(that.type())
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
		else if that is ReferenceType {
			return @name == that.name() || this.matchContentOf(that.discardReference())
		}
		else {
			return @type.matchContentOf(that)
		}
	} // }}}
	matchInheritanceOf(base: Type) { // {{{
		if base is not NamedType || !this.isClass() || !base.isClass() {
			return false
		}

		const basename = base.name()

		if @name == basename {
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
	matchSignatureOf(that, matchables) => @type.matchSignatureOf(that.discardName(), matchables)
	metaReference(references, ignoreAlteration) { // {{{
		if @type is ClassType {
			return @type.metaReference(references, @name, ignoreAlteration)
		}
		else {
			throw new NotSupportedException()
		}
	} // }}}
	name() => @name
	name(@name) => this
	path() { // {{{
		if @container? {
			return `\(@container.path()).\(@name)`
		}
		else {
			return @name
		}
	} // }}}
	referenceIndex() => @type.referenceIndex()
	toAlterationReference(references, ignoreAlteration) { // {{{
		if @type is ClassType {
			return @type.toAlterationReference(references, ignoreAlteration)
		}
		else {
			throw new NotSupportedException()
		}
	} // }}}
	toExportOrIndex(references, ignoreAlteration) => @type.toExportOrIndex(references, ignoreAlteration)
	toFragments(fragments, node)
	toMetadata(references, ignoreAlteration) => @type.toMetadata(references, ignoreAlteration)
	toQuote() => @name
	toReference(references, ignoreAlteration) { // {{{
		if @type is ClassType && @type.isPredefined() {
			return @name
		}
		else {
			return @type.toReference(references, ignoreAlteration)
		}
	} // }}}
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
	type() => @type
	walk(fn) { // {{{
		if @type is ObjectType || @type is NamespaceType {
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

		@type:ObjectType.addProperty(name, property)

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
}