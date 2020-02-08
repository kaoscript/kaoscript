abstract class TupleType extends Type {
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			if data.named {
				return NamedTupleType.import(index, data, metadata, references, alterations, queue, scope, node)
			}
			else {
				return UnnamedTupleType.import(index, data, metadata, references, alterations, queue, scope, node)
			}
		} // }}}
	}
	private {
		_count: Number							= 0
		_extending: Boolean						= false
		_extends: NamedType<TupleType>?		= null
		_fields: Dictionary<TupleFieldType>	= {}
	}
	addField(field: TupleFieldType) { // {{{
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
	override isTuple() => true
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

class NamedTupleType extends TupleType {
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new NamedTupleType(scope)

			queue.push(() => {
				if data.extends? {
					value.extends(Type.fromMetadata(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				let index = value.count()

				for const type, name of data.fields {
					value.addField(TupleFieldType.fromMetadata(index, name, type, metadata, references, alterations, queue, scope, node))

					++index
				}
			})

			return value
		} // }}}
	}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Tuple
			named: true
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
	override isArray() => true
	isMatching(value: TupleType, mode: MatchingMode) => mode & MatchingMode::Similar != 0
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} // }}}
	sortArguments(arguments: Array) { // {{{
		NotImplementedException.throw()
	} // }}}
}

class UnnamedTupleType extends TupleType {
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new UnnamedTupleType(scope)

			queue.push(() => {
				if data.extends? {
					value.extends(Type.fromMetadata(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				let index = value.count()

				for const type in data.fields {
					value.addField(TupleFieldType.fromMetadata(index, null, type, metadata, references, alterations, queue, scope, node))

					++index
				}
			})

			return value
		} // }}}
	}
	addField(field: TupleFieldType) { // {{{
		@fields[field.index()] = field

		++@count
	} // }}}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Tuple
			named: false
			fields: []
		}

		for const field of @fields {
			export.fields.push(field.export(references, mode))
		}

		if @extending {
			export.extends = @extends.metaReference(references, mode)
		}

		return export
	} // }}}
	override isArray() => true
	getProperty(name: Number) => this.getProperty(`\(name)`)
	isMatching(value: TupleType, mode: MatchingMode) => mode & MatchingMode::Similar != 0
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} // }}}
	sortArguments(arguments) => arguments
}

class TupleFieldType extends Type {
	private {
		_index: Number
		_name: String?
		_type: Type
	}
	static {
		fromMetadata(index, name?, data, metadata, references, alterations, queue, scope, node) { // {{{
			const fieldType = Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node)

			return new TupleFieldType(scope, name, index, fieldType, data.required)
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