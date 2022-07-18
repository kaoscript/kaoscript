abstract class TupleType extends Type {
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): TupleType { # {{{
			if data.named {
				return NamedTupleType.import(data, metadata, references, alterations, queue, scope, node)
			}
			else {
				return UnnamedTupleType.import(data, metadata, references, alterations, queue, scope, node)
			}
		} # }}}
	}
	private {
		@assessment							= null
		@length: Number						= 0
		@extending: Boolean					= false
		@extends: NamedType<TupleType>?		= null
		@extendedLength: Number				= 0
		@fieldsByIndex: Dictionary<TupleFieldType>	= {}
		@function: FunctionType				= null
	}
	abstract addField(field: TupleFieldType): Void
	assessment(reference: ReferenceType, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess([this.function(reference, node)], reference.name(), node)
		}

		return @assessment
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	extends() => @extends
	extends(@extends) { # {{{
		@extending = true

		@extendedLength = @extends.type().length()
	} # }}}
	function(reference, node) { # {{{
		if @function == null {
			const scope = node.scope()
			@function = new FunctionType(scope)

			for const field in this.listAllFields([]) {
				if field.isRequired() {
					@function.addParameter(field.type(), field.name(), 1, 1)
				}
				else {
					@function.addParameter(field.type().setNullable(true), field.name(), 0, 1)
				}
			}

			@function.setReturnType(reference)
		}

		return @function
	} # }}}
	getProperty(index: Number): Type? { # {{{
		if const field = @fieldsByIndex[index] {
			return field
		}

		if @extending {
			return @extends.getProperty(index)
		}
		else {
			return null
		}
	} # }}}
	getProperty(name: String): Type? { # {{{
		if const field = @fieldsByIndex[name] {
			return field
		}

		if @extending {
			return @extends.getProperty(name)
		}
		else {
			return null
		}
	} # }}}
	isExtending() => @extending
	override isTuple() => true
	length(): Number => @extendedLength + @length
	listAllFields(list = []) { # {{{
		if @extending {
			@extends.type().listAllFields(list)
		}

		for const index from @extendedLength til @extendedLength + @length {
			list.push(@fieldsByIndex[index])
		}

		return list
	} # }}}
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) => [this.toMetadata(references, indexDelta, mode, module), name]
	shallBeNamed() => true
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		NotImplementedException.throw(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('tuple', @length)
	} # }}}
}

class NamedTupleType extends TupleType {
	static {
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): NamedTupleType { # {{{
			const data = index
			const value = new NamedTupleType(scope)

			queue.push(() => {
				if data.extends? {
					value.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				for const type, name of data.fields {
					value.addField(TupleFieldType.import(name, type, metadata, references, alterations, queue, scope, node))
				}
			})

			return value
		} # }}}
	}
	private {
		@fieldsByName: Dictionary<TupleFieldType>	= {}
	}
	override addField(field) { # {{{
		@fieldsByName[field.name()] = field
		@fieldsByIndex[field.index()] = field

		++@length
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		const export = {
			kind: TypeKind::Tuple
			named: true
			fields: {}
		}

		for const field, name of @fieldsByName {
			export.fields[name] = field.export(references, indexDelta, mode, module)
		}

		if @extending {
			export.extends = @extends.metaReference(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	getAllFieldsMap(list = {}) { # {{{
		if @extending {
			@extends.type().getAllFieldsMap(list)
		}

		for const field, name of @fieldsByName {
			list[name] = field
		}

		return list
	} # }}}
	getProperty(name: String): Type? { # {{{
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
	} # }}}
	isSubsetOf(value: TupleType, mode: MatchingMode) => mode ~~ MatchingMode::Similar
	isSubsetOf(value: NamedType | ReferenceType, mode: MatchingMode) { # {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} # }}}
	isSubsetOf(value: NullType, mode: MatchingMode) => false
	isSubsetOf(value: UnionType, mode: MatchingMode) { # {{{
		for const type in value.types() {
			if this.isSubsetOf(type) {
				return true
			}
		}

		return false
	} # }}}
	matchArguments(tupleName: String, arguments: Array, node): Boolean ~ Exception { # {{{
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
	} # }}}
	sortArguments(arguments: Array, node) { # {{{
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
	} # }}}
}

class UnnamedTupleType extends TupleType {
	static {
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): UnnamedTupleType { # {{{
			const data = index
			const value = new UnnamedTupleType(scope)

			queue.push(() => {
				if data.extends? {
					value.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				for const type in data.fields {
					value.addField(TupleFieldType.import(null, type, metadata, references, alterations, queue, scope, node))
				}
			})

			return value
		} # }}}
	}
	private {
		@fields: Array<TupleFieldType>	= []
	}
	addField(field) { # {{{
		@fieldsByIndex[field.index()] = field

		@fields.push(field)

		++@length
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		const export = {
			kind: TypeKind::Tuple
			named: false
			fields: []
		}

		for const field in @fields {
			export.fields.push(field.export(references, indexDelta, mode, module))
		}

		if @extending {
			export.extends = @extends.metaReference(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	override isArray() => true
	isSubsetOf(value: TupleType, mode: MatchingMode) => mode ~~ MatchingMode::Similar
	isSubsetOf(value: NamedType | ReferenceType, mode: MatchingMode) { # {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} # }}}
	isSubsetOf(value: NullType, mode: MatchingMode) => false
	isSubsetOf(value: UnionType, mode: MatchingMode) { # {{{
		for const type in value.types() {
			if this.isSubsetOf(type) {
				return true
			}
		}

		return false
	} # }}}
	matchArguments(tupleName: String, arguments: Array, node): Boolean ~ Exception { # {{{
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
	} # }}}
	sortArguments(arguments) => arguments
}

class TupleFieldType extends Type {
	private {
		@index: Number
		@name: String?
		@type: Type
	}
	static {
		import(_name?, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): TupleFieldType { # {{{
			const fieldType = Type.import(data.type, metadata, references, alterations, queue, scope, node)
			// FIXME
			const name: String? = _name!!

			return new TupleFieldType(scope, name, data.index as Number, fieldType, data.required)
		} # }}}
	}
	constructor(@scope, @name, @index, @type, @required) { # {{{
		super(scope)

		if !?name {
			@name = `__ks_\(@index)`
		}
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	discardVariable() => @type
	override export(references, indexDelta, mode, module) => { # {{{
		index: @index
		required: @required
		type: @type.export(references, indexDelta, mode, module)
	} # }}}
	flagNullable() { # {{{
		@type = @type.setNullable(true)
	} # }}}
	index() => @index
	name() => @name
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	toQuote() => @type.toQuote()
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		NotImplementedException.throw(node)
	} # }}}
	override toVariations(variations)
	type() => @type
}
