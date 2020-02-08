abstract class StructType extends Type {

	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			return ObjectStructType.import(index, data, metadata, references, alterations, queue, scope, node)
		} // }}}
	}
	private {
		_count: Number							= 0
		_extending: Boolean						= false
		_extends: NamedType<StructType>?		= null
		_fields: Dictionary<StructFieldType>	= {}
	}
	addField(field: StructFieldType) { // {{{
		@fields[field.name()] = field
		++@count
	} // }}}
	override clone() { // {{{
		NotImplementedException.throw()
	} // }}}
	count(): Number { // {{{
		if @extending {
			return @count + @extends.type().count():Number
		}
		else {
			return @count
		}
	} // }}}
	extends() => @extends
	extends(@extends) { // {{{
		@extending = true
	} // }}}
	getProperty(name: String) { // {{{
		if const field = @fields[name] {
			return field
		}

		if @extending {
			return @extends.type().getProperty(name)
		}
		else {
			return null
		}
	} // }}}
	isExtending() => @extending
	override isStruct() => true
	listAllFields(list = []) { // {{{
		if @extending {
			@extends.type().listAllFields(list)
		}

		for const field of @fields {
			list.push(field)
		}

		return list
	} // }}}
	metaReference(references, name, mode) => [this.toMetadata(references, mode), name]
	override toFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
	override toTestFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
}

class ObjectStructType extends StructType {
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new ObjectStructType(scope)

			queue.push(() => {
				let index = 0

				for const type, name of data.fields {
					value.addField(StructFieldType.fromMetadata(index, name, type, metadata, references, alterations, queue, scope, node))

					++index
				}

				if data.extends? {
					value.extends(Type.fromMetadata(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}
			})

			return value
		} // }}}
	}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Struct
			fields: {}
		}

		for const field of @fields {
			export.fields[field.name()] = field.export(references, mode)
		}

		if @extending {
			export.extends = @extends.metaReference(references, mode)
		}

		return export
	} // }}}
	getAllFieldsMap(list = {}) { // {{{
		if @extending {
			@extends.type().getAllFieldsMap(list)
		}

		for const field, name of @fields {
			list[name] = field
		}

		return list
	} // }}}
	override isDictionary() => true
	isMatching(value: ObjectStructType, mode: MatchingMode) => mode & MatchingMode::Similar != 0
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Struct' {
			return true
		}

		return false
	} // }}}
	listAllFieldNames(list = []) { // {{{
		if @extending {
			@extends.type().listAllFieldNames(list)
		}

		for const _, name of @fields {
			list.push(name)
		}

		return list
	} // }}}
	sortArguments(arguments: Array, node) { // {{{
		const order = []

		const fields = this.getAllFieldsMap()
		const count = this.count()

		const nameds = {}
		let namedCount = 0

		const shorthands = {}
		const leftovers = []

		for const argument in arguments {
			if argument is NamedArgument {
				const name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedStructField(name, node)
				}

				nameds[name] = argument

				++namedCount
			}
			else if argument is IdentifierLiteral {
				const name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedStructField(name, node)
				}

				shorthands[name] = argument
			}
			else {
				leftovers.push(argument)
			}
		}

		if namedCount == arguments.length {
			if namedCount == count {
				for const field, name of fields {
					order.push(nameds[name])
				}
			}
			else {
				for const field, name of fields {
					if nameds[name]? {
						order.push(nameds[name])
					}
					else if field.isRequired() {
						SyntaxException.throwMissingStructField(name, node)
					}
					else {
						order.push(new Literal('null', node))
					}
				}
			}
		}
		else {
			const groups = []
			let required = 0
			let optional = 0

			for const field, name of fields {
				if nameds[name]? {
					order.push(nameds[name])
				}
				else if shorthands[name]? {
					order.push(shorthands[name])
				}
				else {
					const index = order.length

					order.push(null)
					groups.push([index, field])

					if field.isRequired() {
						++required
					}
					else {
						++optional
					}
				}
			}

			if leftovers.length < required {
				SyntaxException.throwNotEnoughStructFields(node)
			}
			else if leftovers.length > required + optional {
				SyntaxException.throwTooMuchStructFields(node)
			}

			let countdown = leftovers.length - required
			let leftover = 0

			for const [index, field] in groups {
				if field.isRequired() {
					order[index] = leftovers[leftover]

					++leftover
				}
				else if countdown > 0 {
					order[index] = leftovers[leftover]

					++leftover
					--countdown
				}
				else {
					order[index] = new Literal('null', node)
				}
			}
		}

		return order
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
	discardVariable() => @type
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