class ClassVariableType extends Type {
	private {
		_access: Accessibility	= Accessibility::Public
		_default: Boolean		= false
		_immutable: Boolean		= false
		_lateInit: Boolean		= false
		_type: Type
	}
	static {
		fromAST(data, node: AbstractNode): ClassVariableType { // {{{
			const scope = node.scope()

			let type: ClassVariableType

			if data.type? {
				type = new ClassVariableType(scope, Type.fromAST(data.type, node))
			}
			else {
				type = new ClassVariableType(scope, AnyType.NullableUnexplicit)
			}

			if data.modifiers? {
				for const modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Immutable => {
							type._immutable = true
						}
						ModifierKind::Internal => {
							type.access(Accessibility::Internal)
						}
						ModifierKind::LateInit => {
							type._lateInit = true
						}
						ModifierKind::Private => {
							type.access(Accessibility::Private)
						}
						ModifierKind::Protected => {
							type.access(Accessibility::Protected)
						}
					}
				}
			}

			if data.value? {
				type._default = true
				type._lateInit = false
			}

			return type
		} // }}}
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ClassVariableType { // {{{
			const data = index
			const type = new ClassVariableType(scope, Type.import(data.type, metadata, references, alterations, queue, scope, node))

			type._access = data.access
			type._default = data.default
			type._immutable = data.immutable
			type._lateInit = data.lateInit

			return type
		} // }}}
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	discardVariable() => @type
	access(@access) => this
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { // {{{
		const data = {
			access: @access
			type: @type.toReference(references, indexDelta, mode, module)
			default: @default
			immutable: @immutable
			lateInit: @lateInit
			sealed: @sealed
		}

		return data
	} // }}}
	flagNullable() { // {{{
		@type = @type.setNullable(true)
	} // }}}
	hasDefaultValue() => @default
	isImmutable() => @immutable
	isLateInit() => @lateInit
	isNullable() => @type.isNullable()
	isRequiringInitialization() => !(@lateInit || @default || @type.isNullable()) || (@lateInit && @immutable)
	isSubsetOf(value: ClassVariableType, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Exact {
			return @type.isSubsetOf(value.type(), MatchingMode::Exact)
		}
		else {
			return true
		}
	} // }}}
	isUsingGetter() => @sealed && @default
	isUsingSetter() => @sealed && @default
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	// TODO add alias
	toQuote() => @type.toQuote()
	toQuote(double) => @type.toQuote(double)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	override toVariations(variations)
	type(): @type
	type(@type): this
}
