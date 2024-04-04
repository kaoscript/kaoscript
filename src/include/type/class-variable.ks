class ClassVariableType extends Type {
	private {
		@access: Accessibility	= Accessibility.Public
		@default: Boolean		= false
		@final: Boolean			= false
		@lateInit: Boolean		= false
		@type: Type
	}
	static {
		fromAST(data, node: AbstractNode): ClassVariableType { # {{{
			var scope = node.scope()

			var type =
				if ?data.type {
					set ClassVariableType.new(scope, Type.fromAST(data.type, node))
				}
				else {
					if ?data.modifiers {
						for var modifier in data.modifiers {
							match ModifierKind(modifier.kind) {
								ModifierKind.Nullable {
									set ClassVariableType.new(scope, AnyType.NullableExplicit)
								}
							}
						}
					}

					set ClassVariableType.new(scope, AnyType.NullableUnexplicit)
				}

			if ?data.modifiers {
				for var modifier in data.modifiers {
					match ModifierKind(modifier.kind) {
						ModifierKind.Final {
							type._final = true
						}
						ModifierKind.Internal {
							type.access(Accessibility.Internal)
						}
						ModifierKind.LateInit {
							type._lateInit = true
						}
						ModifierKind.Private {
							type.access(Accessibility.Private)
						}
						ModifierKind.Protected {
							type.access(Accessibility.Protected)
						}
					}
				}
			}

			if ?data.value {
				type._default = true
				type._lateInit = false
			}

			return type!?
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ClassVariableType { # {{{
			var data = index
			var type = ClassVariableType.new(scope, Type.import(data.type, metadata, references, alterations, queue, scope, node))

			type._access = Accessibility(data.access) ?? .Public
			type._default = data.default
			type._final = data.final
			type._lateInit = data.lateInit

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
	access() => @access
	access(@access) => this
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var data = {
			access: @access
			type: @type.toReference(references, indexDelta, mode, module)
			default: @default
			final: @final
			lateInit: @lateInit
			sealed: @sealed
		}

		return data
	} # }}}
	flagNullable(): valueof this { # {{{
		@type = @type.setNullable(true)
	} # }}}
	hasDefaultValue() => @default
	override isExportable() { # {{{
		return @type.isExportable()
	} # }}}
	isImmutable() => @final
	isLateInit() => @lateInit
	isRequiringInitialization() => !(@lateInit || @default || @type.isNullable()) || (@lateInit && @final)
	assist isSubsetOf(value: ClassVariableType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact {
			return @type.isSubsetOf(value.type(), MatchingMode.Exact)
		}
		else {
			return true
		}
	} # }}}
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) => @type.isSubsetOf(value, mode)
	isUsingGetter() => @sealed && @default
	isUsingSetter() => @sealed && @default
	override toVariations(variations)
	type(): valueof @type
	type(@type): valueof this

	proxy @type {
		hashCode
		isAssignableToVariable
		isNullable
		toFragments
		toPositiveTestFragments
		toQuote
	}
}
