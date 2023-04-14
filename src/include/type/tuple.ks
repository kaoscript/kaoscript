class TupleType extends Type {
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): TupleType { # {{{
			var value = TupleType.new(scope)

			queue.push(() => {
				if ?data.extends {
					value.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				for var type in data.fields {
					value.addField(TupleFieldType.import(type, metadata, references, alterations, queue, scope, node))
				}
			})

			return value.flagComplete()
		} # }}}
	}
	private {
		@assessment?							= null
		@length: Number							= 0
		@extending: Boolean						= false
		@extends: NamedType<TupleType>?			= null
		@extendedLength: Number					= 0
		@fields: Array<TupleFieldType>			= []
		@fieldsByIndex: Object<TupleFieldType>	= {}
		@fieldsByName: Object<TupleFieldType>	= {}
		@function: FunctionType?				= null
	}
	addField(field: TupleFieldType): Void { # {{{
		if field.isNamed() {
			@fieldsByName[field.name()] = field
		}

		@fieldsByIndex[field.index()] = field

		@fields.push(field)

		@length += 1
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
	override export(references, indexDelta, mode, module) { # {{{
		var export = {
			kind: TypeKind.Tuple
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
	extends() => @extends
	extends(@extends) { # {{{
		@extending = true

		@extendedLength = @extends.type().length()
	} # }}}
	function(): @function
	function(reference, node) { # {{{
		if @function == null {
			var scope = node.scope()
			@function = FunctionType.new(scope)

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
		if ?@fieldsByName[name] || ?@fieldsByIndex[name] {
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
	override isTuple() => true
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
	isSubsetOf(value: NamedType | ReferenceType, mode: MatchingMode) { # {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} # }}}
	isSubsetOf(value: NullType, mode: MatchingMode) => false
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

class TupleFieldType extends Type {
	private {
		@index: Number
		@name: String?
		@named: Boolean
		@type: Type
	}
	static {
		import(index % data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): TupleFieldType { # {{{
			var fieldType = Type.import(data.type, metadata, references, alterations, queue, scope, node)

			return TupleFieldType.new(scope, data.name, data.index, fieldType, data.required)
		} # }}}
	}
	constructor(@scope, @name, @index, @type, @required) { # {{{
		super(scope)

		@named = ?name

		if !@named {
			@name = `__ks_\(@index)`
		}
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	discardVariable() => @type
	override export(references, indexDelta, mode, module) => { # {{{
		index: @index
		name: @name if @named
		required: @required
		type: @type.export(references, indexDelta, mode, module)
	} # }}}
	flagNullable() { # {{{
		@type = @type.setNullable(true)
	} # }}}
	index() => @index
	isNamed() => @named
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
