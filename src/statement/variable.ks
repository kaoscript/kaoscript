class VariableDeclaration extends Statement {
	private {
		_autotype: Boolean			= false
		_await: Boolean				= false
		_declarators: Array			= []
		_function					= null
		_hasInit: Boolean			= false
		_immutable: Boolean			= false
		_init
		_initScope: Scope
		_rebindable: Boolean		= true
		_redeclared: Boolean		= false
		_toDeclareAll: Boolean		= true
		_try
	}
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		super(data, parent, scope)

		while parent? && !(parent is AnonymousFunctionExpression || parent is ArrowFunctionExpression || parent is FunctionDeclarator || parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration || parent is ImplementNamespaceFunctionDeclaration) {
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

			const line = @initScope.getRawLine()

			@initScope.line(line - 1)

			@init = $compile.expression(@data.init, this, @initScope)
			@init.analyse()

			@initScope.line(line)

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

			if @hasInit {
				declarator.checkNames(@init)
			}

			@declarators.push(declarator)
		}

		if @hasInit && @declarators.length == 1 {
			if @declarators[0] is VariableIdentifierDeclarator {
				this.reference(@declarators[0].name())
			}
		}
	} // }}}
	prepare() { // {{{
		const declarator = @declarators[0]

		let type = null

		if @hasInit {
			@init.prepare()

			type = @init.type()

			if @parent is IfStatement {
				type = type.setNullable(false)
			}

			if @autotype {
				declarator.setDeclaredType(type)
				declarator.flagDefinitive()
			}
			else {
				declarator.setRealType(type)
			}

			this.assignTempVariables(@initScope)
		}

		for const declarator in @declarators {
			declarator.prepare()

			if declarator.isRedeclared() {
				@redeclared = true
			}
		}

		if @hasInit {
			if !@autotype {
				declarator.setRealType(type)
			}

			@init.acquireReusable(declarator.isSplitAssignment())
			@init.releaseReusable()

			this.statement().assignTempVariables(@scope)
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
	defineVariables(declarator) { // {{{
		let alreadyDeclared

		for const name in declarator.listAssignments([]) {
			if @scope.hasDefinedVariable(name) {
				SyntaxException.throwAlreadyDeclared(name, this)
			}

			alreadyDeclared = @scope.hasDeclaredVariable(name)

			const variable = @scope.define(name, this.isImmutable(), null, this)

			if alreadyDeclared {
				alreadyDeclared = !variable.isRenamed()
			}

			if alreadyDeclared && @toDeclareAll {
				@toDeclareAll = false
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
	isUsingVariable(name) => @hasInit && @init.isUsingVariable(name)
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

				declarator.toAssignmentFragments(line, @init)

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

		@binding.setAssignment(AssignmentType::Declaration)

		if @parent.isImmutable() {
			@binding.flagImmutable()
		}

		@binding.analyse()

		@parent.defineVariables(@binding)
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
	flagDefinitive()
	isDeclararingVariable(name: String) => @binding.isDeclararingVariable(name)
	isDuplicate(scope) { // {{{
		return false
	} // }}}
	isRedeclared() => @binding.isRedeclared()
	isSplitAssignment() => @binding.isSplitAssignment()
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
	toFragments(fragments, mode) { // {{{
		fragments.compile(@binding)
	} // }}}
	toAssignmentFragments(fragments, value) => @binding.toAssignmentFragments(fragments, value)
	walk(fn) { // {{{
		@binding.walk(fn)
	} // }}}
}

class VariableIdentifierDeclarator extends AbstractNode {
	private {
		_identifier: IdentifierLiteral
		_name: String
		_variable: Variable
	}
	analyse() { // {{{
		@name = @data.name.name

		@identifier = new IdentifierLiteral(@data.name, this)
		@identifier.setAssignment(AssignmentType::Declaration)
		@identifier.analyse()

		@parent.defineVariables(@identifier)

		@variable = @identifier.variable()
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
	isDeclararingVariable(name: String) => @name == name
	isRedeclared() => @scope.isRedeclaredVariable(@name)
	isSplitAssignment() => false
	name() => @name
	setDeclaredType(type: Type) => @variable.setDeclaredType(type)
	setRealType(type: Type) => @variable.setRealType(type)
	toFragments(fragments, mode) { // {{{
		fragments.compile(@identifier)
	} // }}}
	toAssignmentFragments(fragments, value) { // {{{
		fragments
			.compile(@identifier)
			.code($equals)
			.compile(value)
	} // }}}
	walk(fn) { // {{{
		fn(@variable.getSecureName(), @variable.getRealType())
	} // }}}
}