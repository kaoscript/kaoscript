class ClassMethodType extends FunctionType {
	private {
		@abstract: Boolean						= false
		@access: Accessibility					= Accessibility::Public
		@forked: Boolean						= false
		@forkedIndex: Number?					= null
		@initVariables: Dictionary<Boolean>		= {}
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

			return new ClassMethodType([ParameterType.fromAST(parameter, true, scope, false, node) for parameter in data.parameters], data, node)
		} # }}}
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ClassMethodType { # {{{
			var data = index
			var type = new ClassMethodType(scope)

			type._index = data.index
			type._access = data.access
			type._sealed = data.sealed
			type._async = data.async
			type._errors = [Type.import(throw, metadata, references, alterations, queue, scope, node) for throw in data.errors]

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
	access(@access) => this
	addInitializingInstanceVariable(name: String) { # {{{
		@initVariables[name] = true
	} # }}}
	clone() { # {{{
		var clone = new ClassMethodType(@scope)

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
			parameters: [parameter.export(references, indexDelta, mode, module) for parameter in @parameters]
			returns: @returnType.toReference(references, indexDelta, mode, module)
			errors: [error.toReference(references, indexDelta, mode, module) for error in @errors]
			inits: Dictionary.keys(@initVariables)
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

		return @access != Accessibility::Internal
	} # }}}
	isForked() => @forked
	isInitializingInstanceVariable(name) => @initVariables[name]
	isInstance() => @instance
	isMethod() => true
	isOverflowing(methods: Array<ClassMethodType>) { # {{{
		var mode = MatchingMode::SimilarParameter + MatchingMode::MissingParameter + MatchingMode::ShiftableParameters + MatchingMode::RequireAllParameters

		for var method in methods {
			if this.isSubsetOf(method, mode) {
				return false
			}
		}

		return true
	} # }}}
	isProxy() => @proxy
	isSealable() => true
	isSubsetOf(methods: Array<ClassMethodType>, mode: MatchingMode): Boolean { # {{{
		for var method in methods {
			if this.isSubsetOf(method, mode) {
				return true
			}
		}

		return false
	} # }}}
	isSupersetOf(methods: Array<ClassMethodType>, mode: MatchingMode): Boolean { # {{{
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
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@abstract = true
			}
			else if modifier.kind == ModifierKind::Async {
				@async()
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
	setProxy(@proxyPath, @proxyName) { # {{{
		@proxy = true
	} # }}}
	setForkedIndex(@forkedIndex): this { # {{{
		@forked = true
	} # }}}
	setReturnType(data?, node) { # {{{
		if !?data {
			@returnType = AnyType.NullableUnexplicit

			return
		}

		if data.kind == NodeKind::TypeReference && data.typeName.kind == NodeKind::Identifier {
			if data.typeName.name == 'this' {
				@dynamicReturn = true
				@unknownReturnType = true
				@returnData = data.typeName

				return
			}
		}
		else if data.kind == NodeKind::ThisExpression {
			@dynamicReturn = true
			@unknownReturnType = true
			@returnData = data

			return
		}

		super(data, node)
	} # }}}
	override setReturnType(@returnType): this
}
