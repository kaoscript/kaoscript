abstract class TupleType extends Type {
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			if data.named {
				return NamedTupleType.import(data, metadata, references, alterations, queue, scope, node)
			}
			else {
				return UnnamedTupleType.import(data, metadata, references, alterations, queue, scope, node)
			}
		} // }}}
	}
	private {
		@length: Number						= 0
		@extending: Boolean					= false
		@extends: NamedType<TupleType>?		= null
		@extendedLength: Number				= 0
		@fieldsByIndex: Dictionary<TupleFieldType>	= {}
	}
	abstract addField(field: TupleFieldType): Void
	override clone() { // {{{
		NotImplementedException.throw()
	} // }}}
	extends() => @extends
	extends(@extends) { // {{{
		@extending = true

		@extendedLength = @extends.type().length()
	} // }}}
	getProperty(index: Number): Type? { // {{{
		if const field = @fieldsByIndex[index] {
			return field
		}

		if @extending {
			return @extends.getProperty(index)
		}
		else {
			return null
		}
	} // }}}
	getProperty(name: String): Type? { // {{{
		if const field = @fieldsByIndex[name] {
			return field
		}

		if @extending {
			return @extends.getProperty(name)
		}
		else {
			return null
		}
	} // }}}
	isExtending() => @extending
	override isTuple() => true
	length(): Number => @extendedLength + @length
	metaReference(references, name, mode) => [this.toMetadata(references, mode), name]
	override toFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
	override toPositiveTestFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
}

class NamedTupleType extends TupleType {
	static {
		import(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new NamedTupleType(scope)

			queue.push(() => {
				if data.extends? {
					value.extends(Type.fromMetadata(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				for const type, name of data.fields {
					value.addField(TupleFieldType.fromMetadata(name, type, metadata, references, alterations, queue, scope, node))
				}
			})

			return value
		} // }}}
	}
	private {
		@fieldsByName: Dictionary<TupleFieldType>	= {}
	}
	override addField(field) { // {{{
		@fieldsByName[field.name()] = field
		@fieldsByIndex[field.index()] = field

		++@length
	} // }}}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Tuple
			named: true
			fields: {}
		}

		for const field, name of @fieldsByName {
			export.fields[name] = field.export(references, mode)
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

		for const field, name of @fieldsByName {
			list[name] = field
		}

		return list
	} // }}}
	getProperty(name: String): Type? { // {{{
		if const field = @fieldsByName[name] {
			return field
		}
		else if const field = @fieldsByIndex[name] {
			return field
		}

		if @extending {
			return @extends.getProperty(name)
		}
		else {
			return null
		}
	} // }}}
	override isArray() => true
	isMatching(value: TupleType, mode: MatchingMode) => mode ~~ MatchingMode::Similar
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} // }}}
	listAllFields(list = []) { // {{{
		if @extending {
			@extends.type().listAllFields(list)
		}

		for const field of @fieldsByName {
			list.push(field)
		}

		return list
	} // }}}
	matchArguments(tupleName: String, arguments: Array, node): Boolean ~ Exception { // {{{
		const fields = this.getAllFieldsMap()
		const count = this.length()

		const nameds = {}
		let namedCount = 0

		const shorthands = {}
		const leftovers = []

		for const argument in arguments {
			if argument is NamedArgument {
				const name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedTupleField(name, node)
				}

				nameds[name] = true

				++namedCount
			}
			else if argument is IdentifierLiteral {
				const name = argument.name()

				if ?fields[name] {
					shorthands[name] = true
				}
				else {
					leftovers.push(argument)
				}
			}
			else {
				leftovers.push(argument)
			}
		}

		if namedCount == arguments.length {
			if namedCount != count {
				if arguments.length == 0 {
					for const field, name of fields when field.isRequired() {
						ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
					}
				}
				else {
					for const field, name of fields when !nameds[name] && field.isRequired() {
						SyntaxException.throwMissingTupleField(name, node)
					}
				}
			}
		}
		else {
			const groups = []

			let index = 0
			let required = 0
			let optional = 0

			for const field, name of fields {
				if nameds[name] || shorthands[name] {
					++index
				}
				else {
					groups.push([++index, field])

					if field.isRequired() {
						++required
					}
					else {
						++optional
					}
				}
			}

			if leftovers.length < required {
				ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
			}
			else if leftovers.length > required + optional {
				SyntaxException.throwTooMuchTupleFields(node)
			}

			let countdown = leftovers.length - required
			let leftover = 0

			for const [index, field] in groups {
				if field.isRequired() {
					if !leftovers[leftover].type().matchContentOf(field.type()) {
						ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
					}

					++leftover
				}
				else if countdown > 0 {
					++leftover
					--countdown
				}
			}
		}

		return true
	} // }}}
	sortArguments(arguments: Array, node) { // {{{
		const order = []

		const fields = this.getAllFieldsMap()
		const count = this.length()

		const nameds = {}
		let namedCount = 0

		const shorthands = {}
		const leftovers = []

		for const argument in arguments {
			if argument is NamedArgument {
				const name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedTupleField(name, node)
				}

				nameds[name] = argument

				++namedCount
			}
			else if argument is IdentifierLiteral {
				const name = argument.name()

				if ?fields[name] {
					shorthands[name] = argument
				}
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
						SyntaxException.throwMissingTupleField(name, node)
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
				SyntaxException.throwNotEnoughTupleFields(node)
			}
			else if leftovers.length > required + optional {
				SyntaxException.throwTooMuchTupleFields(node)
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

class UnnamedTupleType extends TupleType {
	static {
		import(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const value = new UnnamedTupleType(scope)

			queue.push(() => {
				if data.extends? {
					value.extends(Type.fromMetadata(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				for const type in data.fields {
					value.addField(TupleFieldType.fromMetadata(null, type, metadata, references, alterations, queue, scope, node))
				}
			})

			return value
		} // }}}
	}
	private {
		@fields: Array<TupleFieldType>	= []
	}
	addField(field) { // {{{
		@fieldsByIndex[field.index()] = field

		@fields.push(field)

		++@length
	} // }}}
	override export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Tuple
			named: false
			fields: []
		}

		for const field in @fields {
			export.fields.push(field.export(references, mode))
		}

		if @extending {
			export.extends = @extends.metaReference(references, mode)
		}

		return export
	} // }}}
	override isArray() => true
	isMatching(value: TupleType, mode: MatchingMode) => mode ~~ MatchingMode::Similar
	isMatching(value: NamedType | ReferenceType, mode: MatchingMode) { // {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} // }}}
	listAllFields(list = []) { // {{{
		if @extending {
			@extends.type().listAllFields(list)
		}

		list.push(...@fields)

		return list
	} // }}}
	matchArguments(tupleName: String, arguments: Array, node): Boolean ~ Exception { // {{{
		const fields = this.listAllFields()

		let required = 0
		let optional = 0

		for const field of fields {
			if field.isRequired() {
				++required
			}
			else {
				++optional
			}
		}

		if arguments.length < required {
			ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
		}
		else if arguments.length > required + optional {
			SyntaxException.throwTooMuchTupleFields(node)
		}

		let countdown = arguments.length - required
		let leftover = 0

		for const field of fields {
			if field.isRequired() {
				if !arguments[leftover].type().matchContentOf(field.type()) {
					ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
				}

				++leftover
			}
			else if countdown > 0 {
				++leftover
				--countdown
			}
		}

		return true
	} // }}}
	sortArguments(arguments) => arguments
}

class TupleFieldType extends Type {
	private {
		@index: Number
		@name: String?
		@type: Type
	}
	static {
		fromMetadata(name?, data, metadata, references, alterations, queue, scope, node) { // {{{
			const fieldType = Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node)

			return new TupleFieldType(scope, name, data.index, fieldType, data.required)
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
		index: @index
		required: @required
		type: @type.export(references, mode)
	} // }}}
	flagNullable() { // {{{
		@type = @type.setNullable(true)
	} // }}}
	index() => @index
	name() => @name
	override toFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
	toQuote() => @type.toQuote()
	override toPositiveTestFragments(fragments, node) { // {{{
		NotImplementedException.throw()
	} // }}}
	type() => @type
}