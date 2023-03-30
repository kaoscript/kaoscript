abstract class TupleType extends Type {
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): TupleType { # {{{
			if data.named {
				return NamedTupleType.import(data, metadata, references, alterations, queue, scope, node)
			}
			else {
				return UnnamedTupleType.import(data, metadata, references, alterations, queue, scope, node)
			}
		} # }}}
	}
	private {
		@assessment?							= null
		@length: Number							= 0
		@extending: Boolean						= false
		@extends: NamedType<TupleType>?			= null
		@extendedLength: Number					= 0
		@fieldsByIndex: Object<TupleFieldType>	= {}
		@function: FunctionType?				= null
	}
	abstract addField(field: TupleFieldType): Void
	assessment(reference: ReferenceType, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess([@function(reference, node)], reference.name(), node)
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
	function(): @function
	function(reference, node) { # {{{
		if @function == null {
			var scope = node.scope()
			@function = new FunctionType(scope)

			for var field in @listAllFields([]) {
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
		if var field ?= @fieldsByIndex[index] {
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
		if var field ?= @fieldsByIndex[name] {
			return field
		}

		if @extending {
			return @extends.getProperty(name)
		}
		else {
			return null
		}
	} # }}}
	hasProperty(index: Number) { # {{{
		if ?@fieldsByIndex[index] {
			return true
		}

		if @extending {
			return @extends.type().hasProperty(index)
		}
		else {
			return false
		}
	} # }}}
	hasProperty(name: String) { # {{{
		if ?@fieldsByIndex[name] {
			return true
		}

		if @extending {
			return @extends.type().hasProperty(name)
		}
		else {
			return false
		}
	} # }}}
	isExtending() => @extending
	isSubsetOf(value: NamedType | ReferenceType, mode: MatchingMode) { # {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} # }}}
	override isTuple() => true
	isSubsetOf(value: NullType, mode: MatchingMode) => false
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		for var type, index in value.properties() {
			if var prop ?= @getProperty(index) {
				return false unless prop.type().isSubsetOf(type, mode)
			}
			else {
				return false unless type.isNullable()
			}
		}

		if value.hasRest() {
			var rest = value.getRestType()

			for var prop, index in @listAllFields() from value.length() {
				return false unless prop.type().isSubsetOf(rest, mode)
			}
		}
		// for exact match
		// else {
		// 	for var prop, index in @listAllFields() from value.length() {
		// 		return false
		// 	}
		// }

		return true
	} # }}}
	isSubsetOf(value: TupleType, mode: MatchingMode) => mode ~~ MatchingMode.Similar
	isSubsetOf(value: UnionType, mode: MatchingMode) { # {{{
		for var type in value.types() {
			if this.isSubsetOf(type) {
				return true
			}
		}

		return false
	} # }}}
	length(): Number => @extendedLength + @length
	listAllFields(list = []) { # {{{
		if @extending {
			@extends.type().listAllFields(list)
		}

		for var index from @extendedLength to~ @extendedLength + @length {
			list.push(@fieldsByIndex[index])
		}

		return list
	} # }}}
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) => [@toMetadata(references, indexDelta, mode, module), name]
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
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): NamedTupleType { # {{{
			var data = index
			var value = new NamedTupleType(scope)

			queue.push(() => {
				if ?data.extends {
					value.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				for var type, name of data.fields {
					value.addField(TupleFieldType.import(name, type, metadata, references, alterations, queue, scope, node))
				}
			})

			return value.flagComplete()
		} # }}}
	}
	private {
		@fieldsByName: Object<TupleFieldType>	= {}
	}
	override addField(field) { # {{{
		@fieldsByName[field.name()] = field
		@fieldsByIndex[field.index()] = field

		@length += 1
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		var export = {
			kind: TypeKind.Tuple
			named: true
			fields: {}
		}

		for var field, name of @fieldsByName {
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

		for var field, name of @fieldsByName {
			list[name] = field
		}

		return list
	} # }}}
	getProperty(name: String): Type? { # {{{
		if var field ?= @fieldsByName[name] {
			return field
		}
		else if var field ?= @fieldsByIndex[name] {
			return field
		}

		if @extending {
			return @extends.getProperty(name)
		}
		else {
			return null
		}
	} # }}}
	isSubsetOf(value: TupleType, mode: MatchingMode) => mode ~~ MatchingMode.Similar
	isSubsetOf(value: NamedType | ReferenceType, mode: MatchingMode) { # {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} # }}}
	isSubsetOf(value: NullType, mode: MatchingMode) => false
	isSubsetOf(value: UnionType, mode: MatchingMode) { # {{{
		for var type in value.types() {
			if this.isSubsetOf(type) {
				return true
			}
		}

		return false
	} # }}}
	matchArguments(tupleName: String, arguments: Array, node): Boolean ~ Exception { # {{{
		var fields = @getAllFieldsMap()
		var count = @length()

		var nameds = {}
		var mut namedCount = 0

		var shorthands = {}
		var leftovers = []

		for var argument in arguments {
			if argument is NamedArgument {
				var name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedTupleField(name, node)
				}

				nameds[name] = true

				namedCount += 1
			}
			else if argument is IdentifierLiteral {
				var name = argument.name()

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
					for var field, name of fields when field.isRequired() {
						ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
					}
				}
				else {
					for var field, name of fields when !nameds[name] && field.isRequired() {
						SyntaxException.throwMissingTupleField(name, node)
					}
				}
			}
		}
		else {
			var groups = []

			var mut index = 0
			var mut required = 0
			var mut optional = 0

			for var field, name of fields {
				if nameds[name] || shorthands[name] {
					index += 1
				}
				else {
					index += 1

					groups.push([index, field])

					if field.isRequired() {
						required += 1
					}
					else {
						optional += 1
					}
				}
			}

			if leftovers.length < required {
				ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
			}
			else if leftovers.length > required + optional {
				SyntaxException.throwTooMuchTupleFields(node)
			}

			var mut countdown = leftovers.length - required
			var mut leftover = 0

			for var [index, field] in groups {
				if field.isRequired() {
					if !leftovers[leftover].type().matchContentOf(field.type()) {
						ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
					}

					leftover += 1
				}
				else if countdown > 0 {
					leftover += 1
					countdown -= 1
				}
			}
		}

		return true
	} # }}}
	sortArguments(arguments: Array, node) { # {{{
		var order = []

		var fields = @getAllFieldsMap()
		var count = @length()

		var nameds = {}
		var mut namedCount = 0

		var shorthands = {}
		var leftovers = []

		for var argument in arguments {
			if argument is NamedArgument {
				var name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedTupleField(name, node)
				}

				nameds[name] = argument

				namedCount += 1
			}
			else if argument is IdentifierLiteral {
				var name = argument.name()

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
				for var field, name of fields {
					order.push(nameds[name])
				}
			}
			else {
				for var field, name of fields {
					if ?nameds[name] {
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
			var groups = []
			var mut required = 0
			var mut optional = 0

			for var field, name of fields {
				if ?nameds[name] {
					order.push(nameds[name])
				}
				else if ?shorthands[name] {
					order.push(shorthands[name])
				}
				else {
					var index = order.length

					order.push(null)
					groups.push([index, field])

					if field.isRequired() {
						required += 1
					}
					else {
						optional += 1
					}
				}
			}

			if leftovers.length < required {
				SyntaxException.throwNotEnoughTupleFields(node)
			}
			else if leftovers.length > required + optional {
				SyntaxException.throwTooMuchTupleFields(node)
			}

			var mut countdown = leftovers.length - required
			var mut leftover = 0

			for var [index, field] in groups {
				if field.isRequired() {
					order[index] = leftovers[leftover]

					leftover += 1
				}
				else if countdown > 0 {
					order[index] = leftovers[leftover]

					leftover += 1
					countdown -= 1
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
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): UnnamedTupleType { # {{{
			var data = index
			var value = new UnnamedTupleType(scope)

			queue.push(() => {
				if ?data.extends {
					value.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				for var type in data.fields {
					value.addField(TupleFieldType.import(null, type, metadata, references, alterations, queue, scope, node))
				}
			})

			return value.flagComplete()
		} # }}}
	}
	private {
		@fields: Array<TupleFieldType>	= []
	}
	addField(field) { # {{{
		@fieldsByIndex[field.index()] = field

		@fields.push(field)

		@length += 1
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		var export = {
			kind: TypeKind.Tuple
			named: false
			fields: []
		}

		for var field in @fields {
			export.fields.push(field.export(references, indexDelta, mode, module))
		}

		if @extending {
			export.extends = @extends.metaReference(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	override isArray() => true
	isSubsetOf(value: TupleType, mode: MatchingMode) => mode ~~ MatchingMode.Similar
	isSubsetOf(value: NamedType | ReferenceType, mode: MatchingMode) { # {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} # }}}
	isSubsetOf(value: NullType, mode: MatchingMode) => false
	isSubsetOf(value: UnionType, mode: MatchingMode) { # {{{
		for var type in value.types() {
			if this.isSubsetOf(type) {
				return true
			}
		}

		return false
	} # }}}
	matchArguments(tupleName: String, arguments: Array, node): Boolean ~ Exception { # {{{
		var fields = @listAllFields()

		var mut required = 0
		var mut optional = 0

		for var field of fields {
			if field.isRequired() {
				required += 1
			}
			else {
				optional += 1
			}
		}

		if arguments.length < required {
			ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
		}
		else if arguments.length > required + optional {
			SyntaxException.throwTooMuchTupleFields(node)
		}

		var mut countdown = arguments.length - required
		var mut leftover = 0

		for var field of fields {
			if field.isRequired() {
				if !arguments[leftover].type().matchContentOf(field.type()) {
					ReferenceException.throwNoMatchingTuple(tupleName, arguments, node)
				}

				leftover += 1
			}
			else if countdown > 0 {
				leftover += 1
				countdown -= 1
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
		import(name?, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): TupleFieldType { # {{{
			var fieldType = Type.import(data.type, metadata, references, alterations, queue, scope, node)

			return new TupleFieldType(scope, name, data.index, fieldType, data.required)
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
