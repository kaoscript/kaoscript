class VariableDeclaration extends Statement {
	private {
		_autotype: Boolean
		_await: Boolean
		_declarators: Array		= []
		_function				= null
		_hasInit: Boolean		= false
		_immutable: Boolean
		_init
		_toDeclareAll: Boolean	= true
		_try
	}
	constructor(@data, @parent) { // {{{
		super(data, parent)

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
	analyse() { // {{{
		@immutable = !@data.rebindable
		@autotype = @immutable || @data.autotype
		@await = @data.await

		if @await && !?@function && !this.module().isBinary() {
			SyntaxException.throwInvalidAwait(this)
		}

		if @data.init? {
			@hasInit = true

			@init = $compile.expression(@data.init, this)
			@init.analyse()
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

		if @hasInit {
			if @declarators.length == 1 && @declarators[0] is VariableIdentifierDeclarator {
				this.reference(@declarators[0].name())
			}
		}
	} // }}}
	prepare() { // {{{
		if @hasInit {
			@init.prepare()

			@init.acquireReusable(false)
			@init.releaseReusable()

			if @autotype {
				@declarators[0].type(@init.type())
			}
		}

		for declarator in @declarators {
			declarator.prepare()
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
	export(recipient) { // {{{
		for declarator in @declarators {
			declarator.export(recipient)
		}
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
				const binding = declarator is VariableBindingDeclarator

				let line = fragments.newLine()

				if @toDeclareAll {
					if binding || @options.format.variables == 'es5' {
						line.code('var ')
					}
					else if @data.rebindable {
						line.code('let ')
					}
					else {
						line.code('const ')
					}
				}

				if binding && @options.format.destructuring == 'es5' {
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
				else if @data.rebindable {
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
				const toDeclare = [declarator for declarator in @declarators when !declarator.isAlreadyDeclared()]

				if toDeclare.length != 0 {
					let line = fragments.newLine()

					if @options.format.variables == 'es5' {
						line.code('var ')
					}
					else {
						line.code('let ')
					}

					for declarator, index in toDeclare {
						line.code($comma) if index != 0

						line.compile(declarator)
					}

					line.done()
				}
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
		@binding.analyse()
	} // }}}
	prepare() { // {{{
		@binding.prepare()
	} // }}}
	translate() { // {{{
		@binding.translate()
	} // }}}
	export(recipient) { // {{{
		@binding.export(recipient)
	} // }}}
	isAlreadyDeclared() => false
	isDeclararingVariable(name: String) => @binding.isDeclararingVariable(name)
	toFlatFragments(fragments, init) { // {{{
		@binding.toFlatFragments(fragments, init)
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@binding)
	} // }}}
	type(type: Type) { // {{{
		if !type.isAny() {
			throw new NotImplementedException()
		}
	} // }}}
	walk(fn) { // {{{
		@binding.walk(fn)
	} // }}}
}

class VariableIdentifierDeclarator extends AbstractNode {
	private {
		_alreadyDeclared: Boolean		= false
		_identifier: IdentifierLiteral
		_name: String
		_variable: Variable
	}
	analyse() { // {{{
		@name = @data.name.name

		if @scope.hasLocalVariable(@name) {
			SyntaxException.throwAlreadyDeclared(@name, this)
		}

		if @options.format.variables == 'es5' {
			@scope.rename(@name)
		}

		if @scope.hasDeclaredLocalVariable(@name) {
			@alreadyDeclared = true
		}

		@variable = @scope.define(@name, @parent.isImmutable(), null, this)

		@identifier = new IdentifierLiteral(@data.name, this)
		@identifier.analyse()
	} // }}}
	prepare() { // {{{
		if @data.type? {
			@variable.type(Type.fromAST(@data.type, this))
		}

		@identifier.prepare()
	} // }}}
	translate() { // {{{
		@identifier.translate()
	} // }}}
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	isAlreadyDeclared() => @alreadyDeclared
	isDeclararingVariable(name: String) => @name == name
	toFragments(fragments, mode) { // {{{
		fragments.compile(@identifier)
	} // }}}
	name() => @name
	type(type: Type) { // {{{
		@variable.type(type)
	} // }}}
	walk(fn) { // {{{
		fn(@name, @variable.type())
	} // }}}
}