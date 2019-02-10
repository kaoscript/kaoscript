class NamespaceType extends Type {
	private {
		_alterationReference: NamespaceType
		_properties: Object			= {}
		_sealProperties: Object		= {}
	}
	static {
		import(data, references: Array, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new NamespaceType(scope)

			if data.namespace? {
				queue.push(() => {
					const source = references[data.namespace.reference]

					type.copyFrom(source.type())

					for name, property of data.properties {
						type.addPropertyFromMetadata(name, property, references, node)
					}
				})
			}
			else {
				if data.sealed {
					type.flagSealed()
				}

				queue.push(() => {
					for name, property of data.properties {
						type.addPropertyFromMetadata(name, property, references, node)
					}
				})
			}

			return type
		} // }}}
	}
	constructor(scope: AbstractScope) { // {{{
		super(new NamespaceScope(scope))
	} // }}}
	addProperty(name: String, type: Type) { // {{{
		const variable = new Variable(name, false, false, type)

		@scope.addVariable(name, variable)

		@properties[name] = variable.type()

		if @sealed {
			@sealProperties[name] = true

			type.flagSealed()
		}
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		let type
		if data.kind == NodeKind::VariableDeclarator {
			type = NamespaceVariableType.fromAST(data, node)
		}
		else if data.kind == NodeKind::FunctionDeclaration {
			type = NamespaceFunctionType.fromAST(data, node)
		}
		else {
			throw new NotSupportedException(node)
		}

		const name = data.name.name
		const variable = new Variable(name, false, false, type)

		@scope.addVariable(name, variable)

		@properties[name] = variable.type()

		if type.isSealed() {
			@sealProperties[name] = true
		}
	} // }}}
	addPropertyFromMetadata(name, data, references, node) { // {{{
		let type
		if data.parameters? {
			type = NamespaceFunctionType.fromMetadata(data, references, @scope, node)
		}
		else if data.sealed? && data.type? {
			type = NamespaceVariableType.fromMetadata(data, references, @scope, node)
		}
		else {
			type = Type.fromMetadata(data, references, @scope, node)

			if type._scope != @scope {
				type._scope = @scope
			}
		}

		const variable = new Variable(name, false, false, type)

		@scope.addVariable(name, variable)

		@properties[name] = variable.type()

		if type.isSealed() {
			@sealProperties[name] = true
		}
	} // }}}
	clone() { // {{{
		const that = new NamespaceType(@scope)

		return that.copyFrom(this)
	} // }}}
	copyFrom(src: NamespaceType) { // {{{
		@sealed = src._sealed

		for name, property of src._properties {
			@properties[name] = property
		}
		for name, property of src._sealProperties {
			@sealProperties[name] = property
		}

		if src.isRequired() || src.isAlien() {
			this.setAlterationReference(src)
		}

		return this
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, ignoreAlteration) { // {{{
		if @alterationReference? {
			const export = {
				type: TypeKind::Namespace
				namespace: @alterationReference.toReference(references, ignoreAlteration)
				properties: {}
			}

			for name, value of @properties when value.isAlteration() {
				export.properties[name] = value.toExportOrIndex(references, ignoreAlteration)
			}

			return export
		}
		else {
			const export = {
				type: TypeKind::Namespace
				sealed: @sealed
				properties: {}
			}

			for name, value of @properties {
				export.properties[name] = value.toExportOrIndex(references, ignoreAlteration)
			}

			return export
		}
	} // }}}
	flagExported() { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for :value of @properties {
			value.flagExported()
		}

		return this
	} // }}}
	getProperty(name: String): Type { // {{{
		if @properties[name] is Type {
			return @properties[name]
		}
		else {
			return null
		}
	} // }}}
	hasProperty(name: String): Boolean => @properties[name] is Type
	isExtendable() => true
	isFlexible() => @sealed
	isNamespace() => true
	isSealed() => @sealed
	isSealedProperty(name: String) => @sealed && @sealProperties[name] == true
	setAlterationReference(@alterationReference)
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	walk(fn) { // {{{
		for name, type of @properties {
			fn(name, type)
		}
	} // }}}
}

class NamespaceVariableType extends Type {
	private {
		_alteration: Boolean	= false
		_type: Type
	}
	static {
		fromAST(data, node: AbstractNode) { // {{{
			const type = new NamespaceVariableType(node.scope(), Type.fromAST(data.type, node))

			if data.modifiers? {
				for modifier in data.modifiers {
					if modifier.kind == ModifierKind::Sealed {
						type._sealed = true
					}
				}
			}

			return type
		} // }}}
		fromMetadata(data, references, scope: AbstractScope, node: AbstractNode): NamespaceVariableType { // {{{
			const type = new NamespaceVariableType(scope, Type.fromMetadata(data.type, references, scope, node))

			if data.sealed == true {
				type._sealed = true
			}

			return type
		} // }}}
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	discardVariable() => @type
	equals(b?) { // {{{
		if b is NamespaceVariableType {
			return @type.equals(b.type())
		}
		else {
			return false
		}
	} // }}}
	export(references, ignoreAlteration) => { // {{{
		sealed: @sealed
		type: @type.toReference(references, ignoreAlteration)
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote() => @type.toQuote()
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
	type() => @type
}

class NamespaceFunctionType extends FunctionType {
	private {
		_alteration: Boolean	= false
	}
	static {
		fromAST(data, node: AbstractNode) { // {{{
			const scope = node.scope()

			return new NamespaceFunctionType([Type.fromAST(parameter, scope, false, node) for parameter in data.parameters], data, node)
		} // }}}
		fromMetadata(data, references, scope: AbstractScope, node: AbstractNode): NamespaceFunctionType { // {{{
			const type = new NamespaceFunctionType(scope)

			type._async = data.async
			type._min = data.min
			type._max = data.max
			type._sealed = data.sealed
			type._throws = [Type.fromMetadata(throw, references, scope, node) for throw in data.throws]

			type._returnType = Type.fromMetadata(data.returns, references, scope, node)

			type._parameters = [ParameterType.fromMetadata(parameter, references, scope, node) for parameter in data.parameters]

			type.updateArguments()

			return type
		} // }}}
	}
	export(references, ignoreAlteration) => { // {{{
		async: @async
		min: @min
		max: @max
		parameters: [parameter.export(references, ignoreAlteration) for parameter in @parameters]
		returns: @returnType.toReference(references, ignoreAlteration)
		sealed: @sealed
		throws: [throw.toReference(references, ignoreAlteration) for throw in @throws]
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
	private processModifiers(modifiers) { // {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				this.async()
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true
			}
		}
	} // }}}
}