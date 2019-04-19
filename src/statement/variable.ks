class VariableDeclaration extends Statement {
	private {
		_autotype: Boolean
		_await: Boolean
		_declarators: Array			= []
		_destructuring: Boolean		= false
		_function					= null
		_hasInit: Boolean			= false
		_immutable: Boolean
		_init
		_initScope: Scope
		_rebindable: Boolean
		_redeclared: Boolean		= false
		_toDeclareAll: Boolean		= true
		_try
	}
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		super(data, parent, scope)

		while parent? && !(parent is FunctionExpression || parent is LambdaExpression || parent is FunctionDeclarator || parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration || parent is ImplementNamespaceFunctionDeclaration) {
			if parent is TryStatement {
				@try = parent
			}

			parent = parent.parent()
		}

		if parent? {
			@function = parent
		}
	} // }}}
	constructor(@data, @parent, @scope, @initScope) { // {{{
		this(data, parent, scope)
	} // }}}
	analyse() { // {{{
		@immutable = !@data.rebindable
		@rebindable = !@immutable
		@autotype = @immutable || @data.autotype
		@await = @data.await

		if @await && !?@function && !this.module().isBinary() {
			SyntaxException.throwInvalidAwait(this)
		}

		@initScope ??= @scope

		if @data.init? {
			@hasInit = true

			@init = $compile.expression(@data.init, this, @initScope)
			@init.analyse()

			if @immutable {
				@rebindable = @scope != @initScope
			}
		}

		let declarator
		for data in @data.variables {
			switch data.name.kind {
				NodeKind::ArrayBinding => {
					declarator = new VariableBindingDeclarator(data, this)
				}
				NodeKind::Identifier => {
					declarator = new VariableIdentifierDeclarator(data, this)
				}
				NodeKind::ObjectBinding => {
					declarator = new VariableBindingDeclarator(data, this)
				}
				=> {
					throw new NotImplementedException(this)
				}
			}

			declarator.analyse()

			if @toDeclareAll && declarator.isAlreadyDeclared() {
				@toDeclareAll = false
			}

			@declarators.push(declarator)
		}

		if @hasInit && @declarators.length == 1 {
			if @declarators[0] is VariableIdentifierDeclarator {
				this.reference(@declarators[0].name())
			}
			else {
				@destructuring = true
			}
		}
	} // }}}
	prepare() { // {{{
		const declarator = @declarators[0]

		if @hasInit {
			@init.prepare()

			@init.acquireReusable(@destructuring && @options.format.destructuring == 'es5')
			@init.releaseReusable()

			if @autotype {
				declarator.setDeclaredType(@init.type())
				declarator.flagDefinitive()
			}
			else {
				declarator.setRealType(@init.type())
			}

			this.assignTempVariables(@initScope)
		}

		for const declarator in @declarators {
			declarator.prepare()

			if declarator.isRedeclared() {
				@redeclared = true
			}
		}

		if @hasInit && !@autotype {
			declarator.setRealType(@init.type())
		}
	} // }}}
	translate() { // {{{
		if @hasInit {
			@init.translate()
		}

		for declarator in @declarators {
			declarator.translate()
		}
	} // }}}
	checkNames() { // {{{
		if @hasInit {
			for const declarator in @declarators {
				declarator.checkNames(@init)
			}
		}
	} // }}}
	export(recipient) { // {{{
		for declarator in @declarators {
			declarator.export(recipient)
		}
	} // }}}
	isDuplicate(scope) { // {{{
		for const declarator in @declarators {
			if declarator.isDuplicate(scope) {
				return true
			}
		}

		return false
	} // }}}
	hasInit() => @hasInit
	init() => @init
	isAwait() => @await
	isDeclararingVariable(name: String) { // {{{
		for declarator in @declarators {
			if declarator.isDeclararingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	isImmutable() => @immutable
	toAwaitExpressionFragments(fragments, parameters, statements) { // {{{
		fragments.code('(__ks_e')

		for parameter in parameters {
			fragments.code($comma).compile(parameter)
		}

		fragments.code(') =>')

		const block = fragments.newBlock()

		for statement in statements {
			block.compile(statement, Mode::None)
		}

		block.done()

		fragments.code(')').done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @await {
			let line = fragments.newLine()

			@init.toFragments(line, Mode::Async)

			if @try? {
				return @try.toAwaitExpressionFragments^@(line, @declarators)
			}
			else if @function?.type().isAsync() {
				return @function.toAwaitExpressionFragments^@(line, @declarators)
			}
			else {
				return this.toAwaitExpressionFragments^@(line, @declarators)
			}
		}
		else {
			if @hasInit {
				const declarator = @declarators[0]

				let line = fragments.newLine()

				if @toDeclareAll {
					if @options.format.variables == 'es5' {
						line.code('var ')
					}
					else if @rebindable || @redeclared {
						line.code('let ')
					}
					else {
						line.code('const ')
					}
				}

				if @destructuring && @options.format.destructuring == 'es5' {
					declarator.toFlatFragments(line, @init)
				}
				else {
					line
						.compile(declarator)
						.code($equals)
						.compile(@init)
				}

				line.done()
			}
			else if @toDeclareAll {
				let line = fragments.newLine()

				if @options.format.variables == 'es5' {
					line.code('var ')
				}
				else if @rebindable || @redeclared {
					line.code('let ')
				}
				else {
					line.code('const ')
				}

				for declarator, index in @declarators {
					line.code($comma) if index != 0

					line.compile(declarator)
				}

				line.done()
			}
			else {
				let line = fragments.newLine()

				for declarator, index in @declarators {
					line.code($comma) if index != 0

					line.compile(declarator)
				}

				line.code(' = undefined')

				line.done()
			}
		}
	} // }}}
	walk(fn) { // {{{
		for declarator in @declarators {
			declarator.walk(fn)
		}
	} // }}}
}

class VariableBindingDeclarator extends AbstractNode {
	private {
		_binding
	}
	analyse() { // {{{
		@binding = $compile.expression(@data.name, this)

		@binding.flagAssignement()

		if @parent.isImmutable() {
			@binding.flagImmutable()
		}

		@binding.analyse()
	} // }}}
	prepare() { // {{{
		@binding.prepare()
	} // }}}
	translate() { // {{{
		@binding.translate()
	} // }}}
	checkNames(init) { // {{{
		@binding.walk(name => {
			if init.isUsingVariable(name) {
				@scope.rename(name)
			}
		})
	} // }}}
	export(recipient) { // {{{
		@binding.export(recipient)
	} // }}}
	flagDefinitive() { // {{{

	} // }}}
	isAlreadyDeclared() => false
	isDeclararingVariable(name: String) => @binding.isDeclararingVariable(name)
	isRedeclared() => @binding.isRedeclared()
	isDuplicate(scope) { // {{{
		return false
	} // }}}
	setDeclaredType(type: Type) => this.setRealType(type)
	setRealType(type: Type) { // {{{
		if !type.isAny() {
			if @binding is ArrayBinding {
				if !type.isArray() {
					TypeException.throwInvalidBinding('Array', this)
				}
			}
			else if @binding is ObjectBinding {
				if !type.isObject() {
					TypeException.throwInvalidBinding('Object', this)
				}
			}
		}
	} // }}}
	toFlatFragments(fragments, init) { // {{{
		@binding.toFlatFragments(fragments, init)
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@binding)
	} // }}}
	walk(fn) { // {{{
		@binding.walk(fn)
	} // }}}
}

class VariableIdentifierDeclarator extends AbstractNode {
	private {
		_alreadyDeclared: Boolean
		_identifier: IdentifierLiteral
		_name: String
		_variable: Variable
	}
	analyse() { // {{{
		@name = @data.name.name

		if @scope.hasDefinedVariable(@name) {
			SyntaxException.throwAlreadyDeclared(@name, this)
		}

		@alreadyDeclared = @scope.hasDeclaredVariable(@name)

		@variable = @scope.define(@name, @parent.isImmutable(), null, this)

		if @alreadyDeclared {
			@alreadyDeclared = @scope.getRenamedVariable(@name) == @name
		}

		@identifier = new IdentifierLiteral(@data.name, this)
		@identifier.analyse()
	} // }}}
	prepare() { // {{{
		if @data.type? {
			@variable.setDeclaredType(Type.fromAST(@data.type, this)).flagDefinitive()
		}

		@identifier.prepare()
	} // }}}
	translate() { // {{{
		@identifier.translate()
	} // }}}
	checkNames(init) { // {{{
		if init.isUsingVariable(@name) {
			@scope.rename(@name)
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	flagDefinitive() { // {{{
		@variable.flagDefinitive()
	} // }}}
	isDuplicate(scope) { // {{{
		if scope.hasDeclaredVariable(@name) {
			return true
		}

		while scope.isInline() {
			scope = scope.parent()

			if scope.hasDeclaredVariable(@name) {
				return true
			}
		}

		return false
	} // }}}
	isAlreadyDeclared() => @alreadyDeclared
	isDeclararingVariable(name: String) => @name == name
	isRedeclared() => @scope.isRedeclaredVariable(@name)
	name() => @name
	setDeclaredType(type: Type) => @variable.setDeclaredType(type)
	setRealType(type: Type) => @variable.setRealType(type)
	toFragments(fragments, mode) { // {{{
		fragments.compile(@identifier)
	} // }}}
	walk(fn) { // {{{
		fn(@scope.getRenamedVariable(@name), @variable.getRealType())
	} // }}}
}