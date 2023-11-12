class ClassMethodType extends FunctionType {
	private {
		@abstract: Boolean						= false
		@access: Accessibility					= Accessibility.Public
		@forked: Boolean						= false
		@forkedIndex: Number?					= null
		@initVariables: Object<Boolean>			= {}
		@instance: Boolean						= false
		@overload: Array?						= null
		@overwrite: Array?						= null
		@proxy: Boolean							= false
		@proxyName: String						= ''
		@proxyPath: String						= ''
		@unknownReturnType: Boolean				= false
	}
	static {
		fromAST(data, node: AbstractNode): ClassMethodType { # {{{
			var scope = node.scope()

			return ClassMethodType.new([ParameterType.fromAST(parameter, true, scope, false, null, node) for var parameter in data.parameters], data, node)
		} # }}}
		fromFunction(source: FunctionType): ClassMethodType { # {{{
			var clone = ClassMethodType.new(source._scope)

			FunctionType.clone(source, clone)

			return clone
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ClassMethodType { # {{{
			var data = index
			var type = ClassMethodType.new(scope)

			type._index = data.index
			type._access = Accessibility(data.access) ?? .Public
			type._sealed = data.sealed
			type._async = data.async
			type._errors = [Type.import(throw, metadata, references, alterations, queue, scope, node) for var throw in data.errors]

			type._returnType = Type.import(data.returns, metadata, references, alterations, queue, scope, node)

			for var parameter in data.parameters {
				type.addParameter(ParameterType.import(parameter, metadata, references, alterations, queue, scope, node), node)
			}

			if ?data.overwrite {
				type._overwrite = [...data.overwrite]
			}

			if ?data.forkedIndex {
				type._forked = true
				type._forkedIndex = data.forkedIndex
			}

			if ?data.inits {
				for var name in data.inits {
					type._initVariables[name] = true
				}
			}

			if ?type.proxyPath {
				type._proxy = true
				type._proxyPath = data.proxyPath
			}

			return type
		} # }}}
	}
	access() => @access
	access(@access) => this
	clone() { # {{{
		var clone = ClassMethodType.new(@scope)

		FunctionType.clone(this, clone)

		clone._access = @access
		clone._index = @index
		clone._initVariables = {...@initVariables}
		clone._instance = @instance

		if ?@overwrite {
			clone._overwrite = [...@overwrite]
		}

		if @forked {
			clone._forked = true
			clone._forkedIndex = @forkedIndex
		}

		return clone
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module, originalMethods?) { # {{{
		var export = {
			index: @index
			access: @access
			sealed: @sealed
			async: @async
			parameters: [parameter.export(references, indexDelta, mode, module) for var parameter in @parameters]
			returns: @returnType.toReference(references, indexDelta, mode, module)
			errors: [error.toReference(references, indexDelta, mode, module) for var error in @errors]
			inits: Object.keys(@initVariables)
		}

		if ?originalMethods && ?@overwrite {
			var overwrite = @overwrite.filter((index, _, _) => originalMethods:Array.contains(index))

			if overwrite.length > 0 {
				export.overwrite = overwrite
			}
		}

		if @forked {
			export.forkedIndex = @forkedIndex
		}

		if @proxy {
			export.proxyPath = @proxyPath
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
	flagInitializingInstanceVariable(name: String) { # {{{
		@initVariables[name] = true
	} # }}}
	flagInstance() { # {{{
		@instance = true

		return this
	} # }}}
	getForkedIndex() => @forkedIndex
	getProxyName() => @proxyName
	getProxyPath() => @proxyPath
	isAbstract() => @abstract
	isExportable() { # {{{
		if !super() {
			return false
		}

		return true
	} # }}}
	isForked() => @forked
	isInitializingInstanceVariable(name) => @initVariables[name]
	isInstance() => @instance
	isLessAccessibleThan(target: ClassMethodType) => Accessibility.isLessAccessibleThan(@access, target.access())
	isLessAccessibleThan(target: FunctionType) => Accessibility.isLessAccessibleThan(@access, Accessibility.Public)
	isMethod() => true
	isOverflowing(methods: Array<ClassMethodType>) { # {{{
		var mode = MatchingMode.SimilarParameter + MatchingMode.MissingParameter + MatchingMode.ShiftableParameters + MatchingMode.RequireAllParameters

		for var method in methods {
			if this.isSubsetOf(method, mode) {
				return false
			}
		}

		return true
	} # }}}
	isProxy() => @proxy
	isSealable() => true
	isSubsetOf(methods: ClassMethodType[], generics: AltType[]? = null, subtypes: AltType[]? = null, mode: MatchingMode): Boolean { # {{{
		for var method in methods {
			if @isSubsetOf(method, generics, subtypes, mode) {
				return true
			}
		}

		return false
	} # }}}
	isSupersetOf(methods: ClassMethodType[], mode: MatchingMode): Boolean { # {{{
		for var method in methods {
			if method.isSubsetOf(this, mode) {
				return true
			}
		}

		return false
	} # }}}
	isUnknownReturnType() => @autoTyping || @unknownReturnType
	overload() => @overload
	overload(@overload)
	overwrite() => @overwrite
	overwrite(@overwrite)
	private processModifiers(modifiers) { # {{{
		for var modifier in modifiers {
			match modifier.kind {
				ModifierKind.Abstract {
					@abstract = true
				}
				ModifierKind.Async {
					@async()
				}
				ModifierKind.AutoType {
					@autoTyping = true
				}
				ModifierKind.Internal {
					@access = Accessibility.Internal
				}
				ModifierKind.Private {
					@access = Accessibility.Private
				}
				ModifierKind.Protected {
					@access = Accessibility.Protected
				}
				ModifierKind.Sealed {
					@sealed = true
				}
			}
		}
	} # }}}
	setProxy(@proxyPath, @proxyName) { # {{{
		@proxy = true
	} # }}}
	setForkedIndex(@forkedIndex): valueof this { # {{{
		@forked = true
	} # }}}
	override setReturnType(@returnType): valueof this
}
