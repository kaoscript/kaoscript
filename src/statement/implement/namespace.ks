class ImplementNamespaceVariableDeclaration extends Statement {
	private lateinit {
		_type: Type
		_value
	}
	private {
		_namespace: NamespaceType
		_variable: NamedType<NamespaceType>
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent)

		@namespace = @variable.type()
	} // }}}
	analyse() { // {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()

		const property = NamespacePropertyType.fromAST(@data.type, this)

		property.flagAlteration()

		if @namespace.isSealed() {
			property.flagSealed()
		}

		@namespace.addProperty(@data.name.name, property)

		@type = property.type()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	getSharedName() => null
	isMethod() => false
	toFragments(fragments, mode) { // {{{
		if @namespace.isSealed() {
			fragments
				.newLine()
				.code(@variable.getSealedName(), '.', @data.name.name, ' = ')
				.compile(@value)
				.done()
		}
		else {
			fragments
				.newLine()
				.code(@variable.name(), '.', @data.name.name, ' = ')
				.compile(@value)
				.done()
		}
	} // }}}
	type() => @type
}

class ImplementNamespaceFunctionDeclaration extends Statement {
	private lateinit {
		_block: Block
		_name: String
		_type: FunctionType
	}
	private {
		_autoTyping: Boolean					= false
		_namespace: NamespaceType
		_namespaceRef: ReferenceType
		_parameters: Array						 = []
		_variable: NamedType<NamespaceType>
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, parent.scope(), ScopeType::Block)

		@namespace = @variable.type()
		@namespaceRef = @scope.reference(@variable)
	} // }}}
	analyse() { // {{{
		@name = @data.name.name

		for const data in @data.parameters {
			const parameter = new Parameter(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}
	} // }}}
	prepare() { // {{{
		for const parameter in @parameters {
			parameter.prepare()
		}

		const property = NamespacePropertyType.fromAST(@data, this)

		property.flagAlteration()

		if @namespace.isSealed() {
			property.flagSealed()
		}

		@namespace.addProperty(@name, property)

		@type = property.type()

		@block = $compile.function($ast.body(@data), this)
		@block.analyse()

		@autoTyping = @data.type?.kind == NodeKind::ReturnTypeReference

		if @autoTyping {
			@type.returnType(@block.getUnpreparedType())
		}
	} // }}}
	translate() { // {{{
		for const parameter in @parameters {
			parameter.translate()
		}

		if @autoTyping {
			@block.prepare()

			@type.returnType(@block.type())
		}
		else {
			@block.type(@type.returnType()).prepare()
		}

		@block.translate()
	} // }}}
	getMatchingMode(): MatchingMode => MatchingMode::ExactParameters
	getParameterOffset() => 0
	getSharedName() => null
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstance() => false
	isInstanceMethod() => false
	isMethod() => true
	name() => @name
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		const line = fragments.newLine()

		if @namespace.isSealed() {
			line.code(@variable.getSealedName())
		}
		else {
			line.code(@variable.name())
		}

		line.code('.', @data.name.name, ' = function(')

		const block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
			return fragments.code(')').newBlock()
		})

		block.compile(@block)

		block.done()

		line.done()
	} // }}}
	type() => @type
}