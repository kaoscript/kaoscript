class StructType extends Type {
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): StructType { # {{{
			var value = StructType.new(scope)

			queue.push(() => {
				var mut index = 0

				for var type, name of data.fields {
					value.addField(StructFieldType.import(index, name, type, metadata, references, alterations, queue, scope, node))

					index += 1
				}

				if ?data.extends {
					value.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}
			})

			return value.flagComplete()
		} # }}}
	}
	private {
		@assessment?							= null
		@count: Number							= 0
		@extending: Boolean						= false
		@extends: NamedType<StructType>?		= null
		@fields: StructFieldType{}				= {}
		@function: FunctionType?				= null
	}
	addField(field: StructFieldType) { # {{{
		@fields[field.name()] = field
		@count += 1
	} # }}}
	assessment(reference: ReferenceType, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess([@function(reference, node)], reference.name(), node)
		}

		return @assessment
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	count(): Number { # {{{
		if @extending {
			return @count + @extends.type().count():Number
		}
		else {
			return @count
		}
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		var export = {
			kind: TypeKind.Struct
			fields: {}
		}

		for var field of @fields {
			export.fields[field.name()] = field.export(references, indexDelta, mode, module)
		}

		if @extending {
			export.extends = @extends.metaReference(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	extends() => @extends
	extends(@extends) { # {{{
		@extending = true
	} # }}}
	function(): @function
	function(reference, node) { # {{{
		if @function == null {
			var scope = node.scope()

			@function = FunctionType.new(scope)

			for var field, index in @listAllFields([]) {
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
	getAllFieldsMap(list = {}) { # {{{
		if @extending {
			@extends.type().getAllFieldsMap(list)
		}

		for var field, name of @fields {
			list[name] = field
		}

		return list
	} # }}}
	getProperty(name: String) { # {{{
		if var field ?= @fields[name] {
			return field
		}

		if @extending {
			return @extends.type().getProperty(name)
		}
		else {
			return null
		}
	} # }}}
	hasProperty(name: String) { # {{{
		if ?@fields[name] {
			return true
		}

		if @extending {
			return @extends.type().hasProperty(name)
		}
		else {
			return false
		}
	} # }}}
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value is ObjectType {
			var mut matchingMode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast

			if anycast {
				matchingMode += MatchingMode.Anycast + MatchingMode.AnycastParameter
			}

			return @isSubsetOf(value, matchingMode)
		}

		return false
	} # }}}
	isExtending() => @extending
	override isStruct() => true
	isSubsetOf(value: NamedType | ReferenceType, mode: MatchingMode) { # {{{
		if value.name() == 'Struct' {
			return true
		}

		return false
	} # }}}
	isSubsetOf(value: NullType, mode: MatchingMode) => false
	isSubsetOf(value: ObjectType, mode: MatchingMode) { # {{{
		for var type, name of value.properties() {
			if var prop ?= @getProperty(name) {
				return false unless prop.type().isSubsetOf(type, mode)
			}
			else {
				return false unless type.isNullable()
			}
		}

		if value.hasRest() {
			var rest = value.getRestType()

			for var prop, name of @getAllFieldsMap() when !value.hasProperty(name) {
				return false unless prop.type().isSubsetOf(rest, mode)
			}
		}
		// for exact match
		// else {
		// 	for var prop, name of @getAllFieldsMap() when !value.hasProperty(name) {
		// 		return false
		// 	}
		// }

		return true
	} # }}}
	isSubsetOf(value: StructType, mode: MatchingMode) => mode ~~ MatchingMode.Similar
	isSubsetOf(value: UnionType, mode: MatchingMode) { # {{{
		for var type in value.types() {
			if this.isSubsetOf(type) {
				return true
			}
		}

		return false
	} # }}}
	listAllFields(list = []) { # {{{
		if @extending {
			@extends.type().listAllFields(list)
		}

		for var field of @fields {
			list.push(field)
		}

		return list
	} # }}}
	listAllFieldNames(list = []) { # {{{
		if @extending {
			@extends.type().listAllFieldNames(list)
		}

		for var _, name of @fields {
			list.push(name)
		}

		return list
	} # }}}
	matchArguments(structName: String, arguments: Array, node): Boolean ~ Exception { # {{{
		var fields = @getAllFieldsMap()
		var count = @count()

		var nameds = {}
		var mut namedCount = 0

		var shorthands = {}
		var leftovers = []

		for var argument in arguments {
			if argument is NamedArgument {
				var name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedStructField(name, node)
				}

				nameds[name] = true

				namedCount += 1
			}
			else if argument is IdentifierLiteral {
				var name = argument.name()

				if ?fields[name] {
					shorthands[name] = true
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
						ReferenceException.throwNoMatchingStruct(structName, arguments, node)
					}
				}
				else {
					for var field, name of fields when !nameds[name] && field.isRequired() {
						SyntaxException.throwMissingStructField(name, node)
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
				ReferenceException.throwNoMatchingStruct(structName, arguments, node)
			}
			else if leftovers.length > required + optional {
				SyntaxException.throwTooMuchStructFields(node)
			}

			var mut countdown = leftovers.length - required
			var mut leftover = 0

			for var [index, field] in groups {
				if field.isRequired() {
					if !leftovers[leftover].type().matchContentOf(field.type()) {
						ReferenceException.throwNoMatchingStruct(structName, arguments, node)
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
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) => [@toMetadata(references, indexDelta, mode, module), name]
	shallBeNamed() => true
	sortArguments(arguments: Array, node) { # {{{
		var order = []

		var fields = @getAllFieldsMap()
		var count = @count()

		var nameds = {}
		var mut namedCount = 0

		var shorthands = {}
		var leftovers = []

		for var argument in arguments {
			if argument is NamedArgument {
				var name = argument.name()

				if !?fields[name] {
					SyntaxException.throwUnrecognizedStructField(name, node)
				}

				nameds[name] = argument

				namedCount += 1
			}
			else if argument is IdentifierLiteral {
				var name = argument.name()

				if ?fields[name] {
					shorthands[name] = argument
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
						SyntaxException.throwMissingStructField(name, node)
					}
					else {
						order.push(Literal.new('null', node))
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
				SyntaxException.throwNotEnoughStructFields(node)
			}
			else if leftovers.length > required + optional {
				SyntaxException.throwTooMuchStructFields(node)
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
					order[index] = Literal.new('null', node)
				}
			}
		}

		return order
	} # }}}
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		NotImplementedException.throw(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('struct', @count)
	} # }}}
}

class StructFieldType extends Type {
	private {
		@index: Number
		@name: String?
		@type: Type
	}
	static {
		import(index: Number, name: String?, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): StructFieldType { # {{{
			var fieldType = Type.import(data.type, metadata, references, alterations, queue, scope, node)

			return StructFieldType.new(scope, name, index, fieldType, data.required)
		} # }}}
	}
	constructor(@scope, @name, @index, @type, @required) { # {{{
		super(scope)
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	discardVariable() => @type
	override export(references, indexDelta, mode, module) => { # {{{
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

	proxy @type {
		isSubsetOf
		isAssignableToVariable
	}
}
