class VirtualMethodType extends FunctionType {
	private {
		@access: Accessibility			= .Public
		@alteration: Boolean			= false
		@instance: Boolean				= false
	}
	static {
		fromAST(data, node: AbstractNode): VirtualMethodType { # {{{
			var scope = node.scope()

			return VirtualMethodType.new([ParameterType.fromAST(parameter, true, scope, false, null, node) for var parameter in data.parameters], data, node)
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): VirtualMethodType { # {{{
			var data = index
			var type = VirtualMethodType.new(scope)

			type._identifier = data.id
			type._access = Accessibility(data.access) ?? .Public
			type._async = data.async

			queue.push(() => {
				type._errors = [Type.import(error, metadata, references, alterations, queue, scope, node) for var error in data.errors]

				type._returnType = Type.import(data.returns, metadata, references, alterations, queue, scope, node)

				for var parameter in data.parameters {
					type.addParameter(ParameterType.import(parameter, metadata, references, alterations, queue, scope, node), node)
				}
			})

			return type
		} # }}}
	}
	clone() { # {{{
		var clone = VirtualMethodType.new(@scope)

		FunctionType.clone(this, clone)

		clone._access = @access
		clone._alteration = @alteration
		clone._index = @index

		return clone
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var export = {
			index: @index
			access: @access
			async: @async
			parameters: [parameter.export(references, indexDelta, mode, module) for var parameter in @parameters]
			returns: @returnType.toReference(references, indexDelta, mode, module)
			errors: [error.toReference(references, indexDelta, mode, module) for var error in @errors]
		}

		return export
	} # }}}
	flagAlteration() { # {{{
		@alteration = true

		return this
	} # }}}
	flagInstance() { # {{{
		@instance = true

		return this
	} # }}}
	isInstance() => @instance
	isMethod() => true
}

class VirtualVariableType extends Type {
	private {
		@type: Type
	}
	static {
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): VirtualVariableType { # {{{
			var data = index
			var type = VirtualVariableType.new(scope, Type.import(data.type, metadata, references, alterations, queue, scope, node))

			return type
		} # }}}
	}
	constructor(@scope, @type) { # {{{
		super(scope)
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	discardVariable() => @type
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var data = {
			type: @type.toReference(references, indexDelta, mode, module)
		}

		return data
	} # }}}
	flagNullable(): valueof this { # {{{
		@type = @type.setNullable(true)
	} # }}}
	isLateInit() => false
	assist isSubsetOf(value: VirtualVariableType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact {
			return @type.isSubsetOf(value.type(), MatchingMode.Exact)
		}
		else {
			return true
		}
	} # }}}
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) => @type.isSubsetOf(value, mode)
	override toVariations(variations)
	type(): valueof @type
	type(@type): valueof this

	proxy @type {
		hashCode
		isAssignableToVariable
		isExportable
		isImmutable
		isNullable
		toFragments
		toPositiveTestFragments
		toQuote
	}
}
