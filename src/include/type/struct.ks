abstract class StructType extends Type {
	override clone() { // {{{
		NotImplementedException.throw()
	} // }}}
	override export(references, mode) { // {{{
		NotImplementedException.throw()
	} // }}}
	override isStruct() => true
	override toFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
	override toTestFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
}

class ArrayStructType extends StructType {
	private {
		_fields: Array<StructFieldType>		= []
	}
	addField(field: StructFieldType) { // }}}
		@fields.push(field)
	} // }}}
	override isArray() => true
	/* getProperty(name: String) => @fields[name]?.type() */
	getProperty(name: Number | String) => @fields[name]
	isMatching(value: ArrayStructType, mode: MatchingMode) => mode & MatchingMode::Similar != 0
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Struct' {
			return true
		}

		return false
	} // }}}
	/* parameter(index: Number | String) => @fields[index]?.type() */
}

class NamedArrayStructType extends StructType {
	private {
		_fields: Dictionary<StructFieldType>		= {}
	}
	addField(field: StructFieldType) { // {{{
		@fields[field.name()] = field
	} // }}}
	override isArray() => true
	getProperty(name: String) => @fields[name]
	isMatching(value: ArrayStructType, mode: MatchingMode) => mode & MatchingMode::Similar != 0
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Struct' {
			return true
		}

		return false
	} // }}}
}

class ObjectStructType extends StructType {
	override isDictionary() => true
}

class StructFieldType extends Type {
	private {
		_index: Number
		_name: String?
		_type: Type
	}
	static {
		fromAST(data, index: Number, node: AbstractNode) { // {{{
			const scope = node.scope()

			const name = data.name?.name
			const type = Type.fromAST(data.type, node)

			return new StructFieldType(scope, name, index, type)
		} // }}}
	}
	constructor(@scope, @name, @index, @type) { // {{{
		super(scope)
	} // }}}
	override clone() { // {{{
		NotImplementedException.throw()
	} // }}}
	override export(references, mode) { // {{{
		NotImplementedException.throw()
	} // }}}
	index() => @index
	name() => @name
	override toFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
	toQuote() => @type.toQuote()
	override toTestFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
	type() => @type
}