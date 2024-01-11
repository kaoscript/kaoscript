class TupleType extends Type {
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): TupleType { # {{{
			var value = TupleType.new(scope)

			queue.push(() => {
				if ?data.extends {
					value.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
				}

				if ?data.implements {
					for var interface in data.implements {
						value.addInterface(Type.import(interface, metadata, references, alterations, queue, scope, node).discardReference())
					}
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
		@implementing: Boolean					= false
		@interfaces	: NamedType[]				= []
	}
	addField(field: TupleFieldType): Void { # {{{
		if field.isNamed() {
			@fieldsByName[field.name()] = field
		}

		@fieldsByIndex[field.index()] = field

		@fields.push(field)

		@length += 1
	} # }}}
	addInterface(type: NamedType) { # {{{
		@implementing = true

		@interfaces.push(type)
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

		if @implementing {
			export.implements = [interface.metaReference(references, indexDelta, mode, module) for var interface in @interfaces]
		}

		return export
	} # }}}
	extends() => @extends
	extends(@extends) { # {{{
		@extending = true

		@extendedLength = @extends.type().length()
	} # }}}
	function(): valueof @function
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
	hasDefaultValues() { # {{{
		if @extending && @extends.type().hasDefaultValues() {
			return true
		}

		for var field in @fields {
			return true if field.hasDefaultValue()
		}

		return false
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
	isImplementing() => @implementing
	override isTuple() => true
	assist isSubsetOf(value: ArrayType, generics, subtypes, mode) { # {{{
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
	assist isSubsetOf(value: NamedType | ReferenceType, generics, subtypes, mode) { # {{{
		if value.name() == 'Tuple' {
			return true
		}

		return false
	} # }}}
	assist isSubsetOf(value: NullType, generics, subtypes, mode) => false
	assist isSubsetOf(value: TupleType, generics, subtypes, mode) => false
	assist isSubsetOf(value: UnionType, generics, subtypes, mode) { # {{{
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
	listInterfaces() => @interfaces
	override makeCallee(name, generics, node) { # {{{
		TypeException.throwConstructorWithoutNew(name, node)
	} # }}}
	override makeMemberCallee(property, name, generics, node) { # {{{
		var reference = @scope.reference(name)

		if property == 'new' {
			// TODO!
			// var assessment = @assessment(reference, node)
			var assessment = this.assessment(reference, node)

			match var result = node.matchArguments(assessment) {
				is LenientCallMatchResult, PreciseCallMatchResult {
					node.addCallee(ConstructorCallee.new(node.data(), node.object(), reference, assessment, result, node))
				}
				else {
					if @isExhaustive(node) {
						ReferenceException.throwNoMatchingTuple(name.name(), [argument.type() for var argument in node.arguments()], node)
					}
					else {
						@addCallee(ConstructorCallee.new(node.data(), node.object(), reference, assessment, null, node))
					}
				}
			}
		}
		else {
			NotSupportedException.throwTupleMethod(node)
		}
	} # }}}
	override makeMemberCallee(property, reference, generics, node) { # {{{
		NotSupportedException.throwTupleMethod(node)
	} # }}}
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) => [@toMetadata(references, indexDelta, mode, module), name]
	shallBeNamed() => true
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('tuple', @length)
	} # }}}
}

class TupleFieldType extends Type {
	private {
		@defaultValue: Boolean	= false
		@index: Number
		@name: String?
		@named: Boolean
		@type: Type
	}
	static {
		import(index % data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): TupleFieldType { # {{{
			var fieldType = Type.import(data.type, metadata, references, alterations, queue, scope, node)
			var type = TupleFieldType.new(scope, data.name, data.index, fieldType, data.required)

			if data.default {
				type.flagDefaultValue()
			}

			return type
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
		default: @defaultValue if @defaultValue
	} # }}}
	flagDefaultValue() { # {{{
		@defaultValue = true
	} # }}}
	flagNullable() { # {{{
		@type = @type.setNullable(true)
	} # }}}
	hasDefaultValue() => @defaultValue
	index() => @index
	isNamed() => @named
	name() => @name
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	toQuote() => @type.toQuote()
	override toVariations(variations)
	type() => @type
	type(@type): valueof this

	proxy @type {
		isSubsetOf
		isAssignableToVariable
	}
}
