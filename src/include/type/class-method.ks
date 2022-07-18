class ClassMethodType extends FunctionType {
	private {
		@abstract: Boolean						= false
		@access: Accessibility					= Accessibility::Public
		@forked: Boolean						= false
		@forkedIndex: Number?						= null
		@initVariables: Dictionary<Boolean>		= {}
		@instance: Boolean						= false
		@overwrite: Array?						= null
	}
	static {
		fromAST(data, node: AbstractNode): ClassMethodType { # {{{
			const scope = node.scope()

			return new ClassMethodType([ParameterType.fromAST(parameter, true, scope, false, node) for parameter in data.parameters], data, node)
		} # }}}
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ClassMethodType { # {{{
			const data = index
			const type = new ClassMethodType(scope)

			type._index = data.index
			type._access = data.access
			type._sealed = data.sealed
			type._async = data.async
			type._min = data.min
			type._max = data.max
			type._errors = [Type.import(throw, metadata, references, alterations, queue, scope, node) for throw in data.errors]

			type._returnType = Type.import(data.returns, metadata, references, alterations, queue, scope, node)

			type._parameters = [ParameterType.import(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

			if data.overwrite? {
				type._overwrite = [...data.overwrite]
			}

			if data.forkedIndex? {
				type._forked = true
				type._forkedIndex = data.forkedIndex
			}

			if data.inits? {
				for const name in data.inits {
					type._initVariables[name] = true
				}
			}

			type.updateParameters()

			return type
		} # }}}
	}
	access(@access) => this
	addInitializingInstanceVariable(name: String) { # {{{
		@initVariables[name] = true
	} # }}}
	clone() { # {{{
		const clone = new ClassMethodType(@scope)

		FunctionType.clone(this, clone)

		clone._access = @access
		clone._index = @index
		clone._initVariables = {...@initVariables}
		clone._instance = @instance

		if @overwrite? {
			clone._overwrite = [...@overwrite]
		}

		if @forked {
			clone._forked = true
			clone._forkedIndex = @forkedIndex
		}

		return clone
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module, originalMethods?) { # {{{
		const export = {
			index: @index
			access: @access
			sealed: @sealed
			async: @async
			min: @min
			max: @max
			parameters: [parameter.export(references, indexDelta, mode, module) for parameter in @parameters]
			returns: @returnType.toReference(references, indexDelta, mode, module)
			errors: [error.toReference(references, indexDelta, mode, module) for error in @errors]
			inits: Dictionary.keys(@initVariables)
		}

		if originalMethods? && @overwrite? {
			const overwrite = @overwrite.filter((index, _, _) => originalMethods:Array.contains(index))

			if overwrite.length > 0 {
				export.overwrite = overwrite
			}
		}

		if @forked {
			export.forkedIndex = @forkedIndex
		}

		return export
	} # }}}
	flagAbstract() { # {{{
		@abstract = true
	} # }}}
	flagForked(hidden: Boolean) { # {{{
		@forked = true
		@forkedIndex = @index
	} # }}}
	flagInstance() { # {{{
		@instance = true

		return this
	} # }}}
	getForkedIndex() => @forkedIndex
	isAbstract() => @abstract
	isExportable() { # {{{
		if !super() {
			return false
		}

		return @access != Accessibility::Internal
	} # }}}
	isForked() => @forked
	isInitializingInstanceVariable(name) => @initVariables[name]
	isInstance() => @instance
	isMethod() => true
	isOverflowing(methods: Array<ClassMethodType>) { # {{{
		const mode = MatchingMode::SimilarParameter + MatchingMode::MissingParameter + MatchingMode::ShiftableParameters + MatchingMode::RequireAllParameters

		for const method in methods {
			if this.isSubsetOf(method, mode) {
				return false
			}
		}

		return true
	} # }}}
	isSealable() => true
	isSubsetOf(methods: Array<ClassMethodType>, mode: MatchingMode): Boolean { # {{{
		for const method in methods {
			if this.isSubsetOf(method, mode) {
				return true
			}
		}

		return false
	} # }}}
	isSupersetOf(methods: Array<ClassMethodType>, mode: MatchingMode): Boolean { # {{{
		for const method in methods {
			if method.isSubsetOf(this, mode) {
				return true
			}
		}

		return false
	} # }}}
	overwrite() => @overwrite
	overwrite(@overwrite)
	private processModifiers(modifiers) { # {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@abstract = true
			}
			else if modifier.kind == ModifierKind::Async {
				this.async()
			}
			else if modifier.kind == ModifierKind::Internal {
				@access = Accessibility::Internal
			}
			else if modifier.kind == ModifierKind::Private {
				@access = Accessibility::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				@access = Accessibility::Protected
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true
			}
		}
	} # }}}
	setForkedIndex(@forkedIndex): this { # {{{
		@forked = true
	} # }}}
	override setReturnType(@returnType): this
}
