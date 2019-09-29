enum EnumTypeKind<String> {
	Flags
	Number
	String
}

class EnumType extends Type {
	private {
		_elements: Array	= []
		_index: Number		= -1
		_kind: EnumTypeKind
		_type: Type
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new EnumType(scope, EnumTypeKind.from(data.type))

			type._exhaustive = data.exhaustive
			type._elements = data.elements
			type._index = data.index

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new EnumType(scope, EnumTypeKind.from(data.type))

			type._exhaustive = data.exhaustive
			type._elements = data.elements
			type._index = data.index

			return type
		} // }}}
	}
	constructor(@scope, @kind = EnumTypeKind::Number) { // {{{
		super(scope)

		if @kind == EnumTypeKind::String {
			@type = scope.reference('String')
		}
		else {
			@type = scope.reference('Number')
		}
	} // }}}
	addElement(name: String) { // {{{
		@elements.push(name)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, mode) => { // {{{
		kind: TypeKind::Enum
		exhaustive: this.isExhaustive()
		elements: @elements
		index: @index
		type: @kind
	} // }}}
	hasElement(name: String) { // {{{
		for element in @elements {
			if element == name {
				return true
			}
		}

		return false
	} // }}}
	getProperty(name: String) { // {{{
		if name == 'value' {
			return @type
		}
		else {
			return null
		}
	} // }}}
	hasProperty(name: String) => name == 'value'
	index() => @index
	index(@index)
	isEnum() => true
	isMergeable(type) => type.isEnum()
	isNumber() => @type.isNumber()
	isString() => @type.isString()
	kind() => @kind
	matchContentOf(that: Type): Boolean => @type.matchContentOf(that)
	matchSignatureOf(value: Type, matchables): Boolean { // {{{
		if value is EnumType {
			return true
		}
		else if value is ReferenceType && value.name() == 'Enum' {
			return true
		}
		else {
			return false
		}
	} // }}}
	step() => ++@index
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
}