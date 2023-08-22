class ClassConstructorType extends FunctionType {
	private late {
		@access: Accessibility					= Accessibility.Public
		@class: ClassType
		@dependent: Boolean						= false
		@initVariables: Object<Boolean>			= {}
		@overwrite: Array?						= null
	}
	static {
		fromAST(data, node: AbstractNode): ClassConstructorType { # {{{
			var scope = node.scope()

			return ClassConstructorType.new([ParameterType.fromAST(parameter, true, scope, false, node) for var parameter in data.parameters], data, node)
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ClassConstructorType { # {{{
			var data = index
			var type = ClassConstructorType.new(scope)

			type._index = data.index
			type._access = data.access
			type._sealed = data.sealed

			if data.dependent {
				type._dependent = true
			}

			type._errors = [Type.import(error, metadata, references, alterations, queue, scope, node) for var error in data.errors]

			for var parameter in data.parameters {
				type.addParameter(ParameterType.import(parameter, metadata, references, alterations, queue, scope, node), node)
			}

			if ?data.inits {
				for var name in data.inits {
					type._initVariables[name] = true
				}
			}

			return type
		} # }}}
	}
	access(@access) => this
	checkVariableInitialization(variables: String[], node: AbstractNode): Void { # {{{
		for var variable in variables {
			unless @initVariables[variable] {
				SyntaxException.throwNotInitializedField(variable, node)
			}
		}
	} # }}}
	clone() { # {{{
		var clone = ClassConstructorType.new(@scope)

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
		var export = {
			index: @index
			access: @access
			sealed: @sealed
			min: @min
			max: @max
			parameters: [parameter.export(references, indexDelta, mode, module) for var parameter in @parameters]
			errors: [error.toReference(references, indexDelta, mode, module) for var error in @errors]
		}

		if @class.isAbstract() {
			export.inits = Object.keys(@initVariables)
		}

		if @dependent {
			export.dependent = true
		}

		if ?originalMethods && ?@overwrite {
			var overwrite = @overwrite.filter((index, _, _) => originalMethods:Array.contains(index))

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
	flagInitializingInstanceVariable(...variables: String): Void { # {{{
		for var variable in variables {
			@initVariables[variable] = true
		}
	} # }}}
	isDependent() => @dependent
	isInitializingInstanceVariable(name) => @initVariables[name]
	isOverwritten() => @overwrite != null
	overwrite() => @overwrite
	overwrite(@overwrite)
	private processModifiers(modifiers) { # {{{
		for var modifier in modifiers {
			match modifier.kind {
				ModifierKind.Async {
					throw NotImplementedException.new()
				}
				ModifierKind.Private {
					@access = Accessibility.Private
				}
				ModifierKind.Protected {
					@access = Accessibility.Protected
				}
			}
		}
	} # }}}
	setClass(@class): valueof this
}
