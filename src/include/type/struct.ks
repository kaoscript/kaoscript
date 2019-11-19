enum StructVarietyKind<String> {
	Array
	NamedArray
	Object
}

abstract class StructType extends Type {
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			switch data.variety {
				StructVarietyKind::Array => {
					return ArrayStructType.import(index, data, metadata, references, alterations, queue, scope, node)
				}
				StructVarietyKind::NamedArray => {
					return NamedArrayStructType.import(index, data, metadata, references, alterations, queue, scope, node)
				}
				=> {
					return ObjectStructType.import(index, data, metadata, references, alterations, queue, scope, node)
				}
			}
		} // }}}
	}
	override clone() { // {{{
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
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new ArrayStructType(scope)

			queue.push(() => {
				let index = 0

				for const type in data.fields {
					value.addField(StructFieldType.fromMetadata(index, null, type, metadata, references, alterations, queue, scope, node))

					++index
				}
			})

			return value
		} // }}}
	}
	addField(field: StructFieldType) { // {{{
		@fields.push(field)
	} // }}}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Struct
			variety: StructVarietyKind::Array
			fields: []
		}

		for const field in @fields {
			export.fields.push(field.export(references, mode))
		}

		return export
	} // }}}
	override isArray() => true
	getProperty(name: Number | String) => @fields[name]
	isMatching(value: ArrayStructType, mode: MatchingMode) => mode & MatchingMode::Similar != 0
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Struct' {
			return true
		}

		return false
	} // }}}
	sortArguments(arguments) => arguments
}

class NamedArrayStructType extends StructType {
	private {
		_fields: Dictionary<StructFieldType>		= {}
	}
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new NamedArrayStructType(scope)

			queue.push(() => {
				let index = 0

				for const type, name of data.fields {
					value.addField(StructFieldType.fromMetadata(index, name, type, metadata, references, alterations, queue, scope, node))

					++index
				}
			})

			return value
		} // }}}
	}
	addField(field: StructFieldType) { // {{{
		@fields[field.name()] = field
	} // }}}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Struct
			variety: StructVarietyKind::NamedArray
			fields: {}
		}

		for const field of @fields {
			export.fields[field.name()] = field.export(references, mode)
		}

		return export
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
	sortArguments(arguments: Array) { // {{{
		NotImplementedException.throw()
	} // }}}
}

class ObjectStructType extends StructType {
	private {
		_count: Number								= 0
		_fields: Dictionary<StructFieldType>		= {}
	}
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new ObjectStructType(scope)

			queue.push(() => {
				let index = 0

				for const type, name of data.fields {
					value.addField(StructFieldType.fromMetadata(index, name, type, metadata, references, alterations, queue, scope, node))

					++index
				}
			})

			return value
		} // }}}
	}
	addField(field: StructFieldType) { // {{{
		@fields[field.name()] = field
		++@count
	} // }}}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Struct
			variety: StructVarietyKind::Object
			fields: {}
		}

		for const field of @fields {
			export.fields[field.name()] = field.export(references, mode)
		}

		return export
	} // }}}
	override isDictionary() => true
	getProperty(name: String) => @fields[name]
	isMatching(value: ObjectStructType, mode: MatchingMode) => mode & MatchingMode::Similar != 0
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Struct' {
			return true
		}

		return false
	} // }}}
	sortArguments(arguments: Array, node) { // {{{
		const result = []

		const nameds = {}
		let count = 0
		for const argument in arguments when argument is NamedArgument {
			nameds[argument.name()] = argument
			++count
		}

		if count == arguments.length {
			if count == @count {
				for const field, name of @fields {
					result.push(nameds[name])
				}
			}
			else {
				for const field, name of @fields {
					if nameds[name]? {
						result.push(nameds[name])
					}
					else if field.isRequired() {
						NotSupportedException.throw(node)
					}
					else {
						result.push(new Literal('null', node))
					}
				}
			}
		}
		else {
			NotImplementedException.throw(node)
		}

		return result
	} // }}}
}

class StructFieldType extends Type {
	private {
		_index: Number
		_name: String?
		_type: Type
	}
	static {
		fromMetadata(index, name?, data, metadata, references, alterations, queue, scope, node) { // {{{
			const fieldType = Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node)

			return new StructFieldType(scope, name, index, fieldType, data.required)
		} // }}}
	}
	constructor(@scope, @name, @index, @type, @required) { // {{{
		super(scope)
	} // }}}
	override clone() { // {{{
		NotImplementedException.throw()
	} // }}}
	override export(references, mode) => { // {{{
		required: @required
		type: @type.export(references, mode)
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