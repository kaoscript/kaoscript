class ClassVariableType extends Type {
	private {
		@access: Accessibility	= Accessibility.Public
		@default: Boolean		= false
		@immutable: Boolean		= false
		@lateInit: Boolean		= false
		@type: Type
	}
	static {
		fromAST(data, node: AbstractNode): ClassVariableType { # {{{
			var scope = node.scope()

			var mut type: ClassVariableType

			if ?data.type {
				type = new ClassVariableType(scope, Type.fromAST(data.type, node))
			}
			else {
				type = new ClassVariableType(scope, AnyType.NullableUnexplicit)
			}

			if ?data.modifiers {
				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Immutable {
							type._immutable = true
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

			return type
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ClassVariableType { # {{{
			var data = index
			var type = new ClassVariableType(scope, Type.import(data.type, metadata, references, alterations, queue, scope, node))

			type._access = data.access
			type._default = data.default
			type._immutable = data.immutable
			type._lateInit = data.lateInit

			return type
		} # }}}
	}
	constructor(@scope, @type) { # {{{
		super(scope)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	discardVariable() => @type
	access(@access) => this
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var data = {
			access: @access
			type: @type.toReference(references, indexDelta, mode, module)
			default: @default
			immutable: @immutable
			lateInit: @lateInit
			sealed: @sealed
		}

		return data
	} # }}}
	flagNullable(): this { # {{{
		@type = @type.setNullable(true)
	} # }}}
	hasDefaultValue() => @default
	isImmutable() => @immutable
	isLateInit() => @lateInit
	isRequiringInitialization() => !(@lateInit || @default || @type.isNullable()) || (@lateInit && @immutable)
	isSubsetOf(value: ClassVariableType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode.Exact {
			return @type.isSubsetOf(value.type(), MatchingMode.Exact)
		}
		else {
			return true
		}
	} # }}}
	isUsingGetter() => @sealed && @default
	isUsingSetter() => @sealed && @default
	override toVariations(variations)
	type(): @type
	type(@type): this

	proxy @type {
		hashCode
		isAssignableToVariable
		isNullable
		toFragments
		toPositiveTestFragments
		toQuote
	}
}
