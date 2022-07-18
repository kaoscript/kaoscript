class ClassConstructorType extends FunctionType {
	private lateinit {
		_access: Accessibility					= Accessibility::Public
		_class: ClassType
		_dependent: Boolean						= false
		_initVariables: Dictionary<Boolean>		= {}
		_overwrite: Array?						= null
	}
	static {
		fromAST(data, node: AbstractNode): ClassConstructorType { # {{{
			const scope = node.scope()

			return new ClassConstructorType([ParameterType.fromAST(parameter, true, scope, false, node) for parameter in data.parameters], data, node)
		} # }}}
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ClassConstructorType { # {{{
			const data = index
			const type = new ClassConstructorType(scope)

			type._index = data.index
			type._access = data.access
			type._sealed = data.sealed
			type._min = data.min
			type._max = data.max

			if data.dependent {
				type._dependent = true
			}

			type._errors = [Type.import(error, metadata, references, alterations, queue, scope, node) for error in data.errors]
			type._parameters = [ParameterType.import(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

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
	checkVariablesInitializations(node: AbstractNode, class: ClassType = @class) { # {{{
		class.forEachInstanceVariables((name, variable) => {
			if variable.isRequiringInitialization() && !@initVariables[name] {
				SyntaxException.throwNotInitializedField(name, node)
			}
		})
	} # }}}
	clone() { # {{{
		const clone = new ClassConstructorType(@scope)

		FunctionType.clone(this, clone)

		clone._index = -1
		clone._access = @access
		clone._class = @class
		clone._dependent = @dependent
		clone._initVariables = {...@initVariables}

		if @overwrite != null {
			clone._overwrite = [...@overwrite]
		}

		return clone
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module, originalMethods?) { # {{{
		const export = {
			index: @index
			access: @access
			sealed: @sealed
			min: @min
			max: @max
			parameters: [parameter.export(references, indexDelta, mode, module) for parameter in @parameters]
			errors: [error.toReference(references, indexDelta, mode, module) for error in @errors]
		}

		if @class.isAbstract() {
			export.inits = Dictionary.keys(@initVariables)
		}

		if @dependent {
			export.dependent = true
		}

		if originalMethods? && @overwrite? {
			const overwrite = @overwrite.filter((index, _, _) => originalMethods:Array.contains(index))

			if overwrite.length > 0 {
				export.overwrite = overwrite
			}
		}

		return export
	} # }}}
	flagDependent() { # {{{
		@dependent = true

		return this
	} # }}}
	isDependent() => @dependent
	isInitializingInstanceVariable(name) => @initVariables[name]
	isOverwritten() => @overwrite != null
	overwrite() => @overwrite
	overwrite(@overwrite)
	private processModifiers(modifiers) { # {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				throw new NotImplementedException()
			}
			else if modifier.kind == ModifierKind::Private {
				@access = Accessibility::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				@access = Accessibility::Protected
			}
		}
	} # }}}
	setClass(@class): this
}
