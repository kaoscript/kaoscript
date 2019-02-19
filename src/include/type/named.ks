class NamedType extends Type {
	private {
		_name: String
		_parent: NamedContainerType	= null
		_type: Type
	}
	constructor(@name, @type) { // {{{
		super(type.scope())
	} // }}}
	clone() => new NamedType(@name, @type.clone())
	condense() { // {{{
		@type.condense()

		return this
	} // }}}
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
	flagExported() { // {{{
		@type.flagExported()

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
	flagSealable() { // {{{
		@type.flagSealable()

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
		if @parent? {
			return `\(@parent.path()).\(this.getSealedName())`
		}
		else {
			return this.getSealedName()
		}
	} // }}}
	hasProperty(name: String) => @type.hasProperty(name)
	isAlias() => @type.isAlias()
	isAlien() => @type.isAlien()
	isClass() => @type.isClass()
	isEnum() => @type.isEnum()
	isExported() => @type.isExported()
	isExtendable() => @type.isExtendable()
	isFlexible() => @type.isFlexible()
	isPredefined() => @type.isPredefined()
	isReferenced() => @type.isReferenced()
	isRequired() => @type.isRequired()
	isSealable() => @type.isSealable()
	isSealed() => @type.isSealed()
	isSealedAlien() => @type.isSealedAlien()
	isNamed() => true
	isNamespace() => @type.isNamespace()
	matchContentOf(that: Type) { // {{{
		if that is NamedType {
			if @type is ClassType && that.type() is ClassType {
				return this.matchInheritanceOf(that)
			}
			else {
				return @type.matchContentOf(that.type())
			}
		}
		else {
			return @type.matchContentOf(that)
		}
	} // }}}
	matchContentTo(that: Type) { // {{{
		if that is NamedType {
			if @type is ClassType && that.type() is ClassType {
				return that.matchInheritanceOf(this)
			}
			else {
				return @type.matchContentTo(that.type())
			}
		}
		else {
			return @type.matchContentTo(that)
		}
	} // }}}
	matchInheritanceOf(base: Type) { // {{{
		unless base is NamedType || !this.isClass() || !base.isClass() {
			return false
		}

		if @name == base.name() {
			return true
		}

		let that = this
		while that.type().isExtending() {
			that = that.type().extends()

			if that.name() == base.name() {
				return true
			}
		}

		return false
	} // }}}
	matchSignatureOf(that, matchables) => @type.matchSignatureOf(that.discardName(), matchables)
	metaReference(references, ignoreAlteration) => @type.metaReference(references, @name, ignoreAlteration)
	name() => @name
	name(@name) => this
	parent() => @parent
	parent(@parent) => this
	path() { // {{{
		if @parent? {
			return `\(@parent.path()).\(@name)`
		}
		else {
			return @name
		}
	} // }}}
	reckonReferenceIndex(references) => @type.reckonReferenceIndex(references)
	reference(scope = @scope) { // {{{
		if @parent? {
			return @parent.scope().reference(@name)
		}
		else {
			return scope.reference(@name)
		}
	} // }}}
	referenceIndex() => @type.referenceIndex()
	toQuote() => @name
	toFragments(fragments, node)
	toExportOrIndex(references, ignoreAlteration) => @type.toExportOrIndex(references, ignoreAlteration)
	toMetadata(references, ignoreAlteration) => @type.toMetadata(references, ignoreAlteration)
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
	walk(fn) => @type.walk(fn)
}

class NamedContainerType extends NamedType {
	constructor(@name, @type) { // {{{
		super(name, type)
	} // }}}
	addProperty(name: String, type: Type) { // {{{
		if type is NamedType {
			type = type.duplicate().parent(this)
		}

		@type.addProperty(name, type)
	} // }}}
	getProperty(name: String): Type => @type.getProperty(name)
	hasProperty(name: String): Boolean => @type.hasProperty(name)
}