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
			const type = new EnumType(scope, data.type)

			type._elements = data.elements
			type._index = data.index

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new EnumType(scope, data.type)

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
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, ignoreAlteration) => { // {{{
		kind: TypeKind::Enum
		elements: @elements
		index: @index
		type: @kind
	} // }}}
	getProperty(name: String) => null
	hasElement(name: String) { // {{{
		for element in @elements {
			if element == name {
				return true
			}
		}

		return false
	} // }}}
	index() => @index
	index(@index)
	isEnum() => true
	isMergeable(type) => type.isEnum()
	kind() => @kind
	matchContentOf(that: Type): Boolean => @type.matchContentOf(that)
	matchSignatureOf(value: Type, matchables): Boolean { // {{{
		if value is EnumType {
			return true
		}
		else if value is ReferenceType && value.name() == 'Enum' {
			return true
		}

		return false
	} // }}}
	step(): EnumType { // {{{
		@index++

		return this
	} // }}}
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	type() => @type
}