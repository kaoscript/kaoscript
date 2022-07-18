class ImplementNamespaceVariableDeclaration extends Statement {
	private lateinit {
		_type: Type
		_value
	}
	private {
		_namespace: NamespaceType
		_variable: NamedType<NamespaceType>
	}
	constructor(data, parent, @variable) { # {{{
		super(data, parent)

		@namespace = @variable.type()
	} # }}}
	analyse() { # {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} # }}}
	prepare() { # {{{
		@value.prepare()

		const property = NamespacePropertyType.fromAST(@data.type, this)

		property.flagAltering()

		if @namespace.isSealed() {
			property.flagSealed()
		}

		@namespace.addProperty(@data.name.name, property)

		@type = property.type()
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	getSharedName() => null
	isMethod() => false
	toFragments(fragments, mode) { # {{{
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
	} # }}}
	type() => @type
}

class ImplementNamespaceFunctionDeclaration extends Statement {
	private lateinit {
		_block: Block
		_internalName: String
		_name: String
		_type: FunctionType
	}
	private {
		_autoTyping: Boolean					= false
		_awaiting: Boolean						= false
		_exit: Boolean							= false
		_main: Boolean							= false
		_namespace: NamespaceType
		_namespaceRef: ReferenceType
		_parameters: Array						= []
		_returnNull: Boolean					= false
		_variable: NamedType<NamespaceType>
		_topNodes: Array						= []
	}
	constructor(data, parent, @variable) { # {{{
		super(data, parent, parent.scope(), ScopeType::Block)

		@namespace = @variable.type()
		@namespaceRef = @scope.reference(@variable)
	} # }}}
	analyse() { # {{{
		@name = @data.name.name

		for const data in @data.parameters {
			const parameter = new Parameter(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}
	} # }}}
	prepare() { # {{{
		for const parameter in @parameters {
			parameter.prepare()
		}

		const property = NamespacePropertyType.fromAST(@data, this)

		property.flagAltering()

		if @namespace.isSealed() {
			property.flagSealed()
		}

		@type = property.type()

		@returnNull = ?@data.body && (@data.body.kind == NodeKind::IfStatement || @data.body.kind == NodeKind::UnlessStatement)

		@main = !@namespace.hasProperty(@name)

		if @namespace.hasMatchingFunction(@name, @type, MatchingMode::ExactParameter) {
			SyntaxException.throwDuplicateFunction(@name, this)
		}
		else {
			@internalName = `__ks_\(@namespace.addFunction(@name, @type))`
		}

		@block = $compile.function($ast.body(@data), this)
		@block.analyse()

		@autoTyping = @data.type?.kind == NodeKind::ReturnTypeReference

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}
	} # }}}
	translate() { # {{{
		for const parameter in @parameters {
			parameter.translate()
		}

		if @autoTyping {
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			@block.type(@type.getReturnType()).prepare()
		}

		@block.translate()

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} # }}}
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	getMatchingMode(): MatchingMode => MatchingMode::ExactParameter
	getParameterOffset() => 0
	getSharedName() => null
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstance() => false
	isInstanceMethod() => false
	isMethod() => true
	isOverridableFunction() => false
	name() => @name
	parameters() => @parameters
	toFragments(fragments, mode) { # {{{
		this.toMainFragments(fragments)

		this.toStatementFragments(fragments, mode)

		this.toRouterFragments(fragments)
	} # }}}
	toMainFragments(fragments) { # {{{
		const namespace = @namespace.isSealed() ? @variable.getSealedName() : @variable.name()

		const line = fragments.newLine()

		const block = line.code(`\(namespace).\(@name) = function()`).newBlock()

		block.line(`return \(namespace).\(@name).__ks_rt(this, arguments)`)

		block.done()
		line.done()
	} # }}}
	toRouterFragments(fragments) { # {{{
		const namespace = @namespace.isSealed() ? @variable.getSealedName() : @variable.name()

		const assessment = this.type().assessment(@name, this)

		const line = fragments.newLine()
		const block = line.code(`\(namespace).\(@name).__ks_rt = function(that, args)`).newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`\(namespace).\(@name).__ks_\(function.index()).call(that`)

				return true
			}
			null
			assessment
			block
			this
		)

		block.done()
		line.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		const namespace = @namespace.isSealed() ? @variable.getSealedName() : @variable.name()
		const line = fragments.newLine()

		line.code(`\(namespace).\(@name).\(@internalName) = function(`)

		const block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
			return fragments.code(')').newBlock()
		})

		block.compile(@block, Mode::None)

		if !@exit {
			if !@awaiting && @type.isAsync() {
				block.line('__ks_cb()')
			}
			else if @returnNull {
				block.line('return null')
			}
		}

		block.done()
		line.done()


	} # }}}
	type() => @type
}
