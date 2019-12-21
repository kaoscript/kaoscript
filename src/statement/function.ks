const $function = {
	surround(node) { // {{{
		let parent = node._parent
		while parent? && !(parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration) {
			parent = parent.parent()
		}

		if parent?._instance {
			if $function.useThisVariable(node._data.body, node) {
				if node._options.format.functions == 'es5' {
					return {
						arrow: false
						beforeParameters: `\($runtime.helper(node)).vcurry(function(`
						afterParameters: ')'
						footer: ', this)'
					}
				}
				else {
					return {
						arrow: true
						beforeParameters: '('
						afterParameters: ') =>'
						footer: ''
					}
				}
			}
			else {
				return {
					arrow: false
					beforeParameters: 'function('
					afterParameters: ')'
					footer: ''
				}
			}
		}
		else {
			return {
				arrow: false
				beforeParameters: 'function('
				afterParameters: ')'
				footer: ''
			}
		}
	} // }}}
	useThisVariable(data, node) { // {{{
		switch data.kind {
			NodeKind::ArrayExpression => {
				for value in data.values {
					if $function.useThisVariable(value, node) {
						return true
					}
				}
			}
			NodeKind::BinaryExpression => {
				if $function.useThisVariable(data.left, node) || $function.useThisVariable(data.right, node) {
					return true
				}
			}
			NodeKind::Block => {
				for statement in data.statements {
					if $function.useThisVariable(statement, node) {
						return true
					}
				}
			}
			NodeKind::CallExpression => {
				if $function.useThisVariable(data.callee, node) {
					return true
				}

				for arg in data.arguments {
					if $function.useThisVariable(arg, node) {
						return true
					}
				}
			}
			NodeKind::ComparisonExpression => {
				for const operand in data.values by 2 {
					if $function.useThisVariable(operand, node) {
						return true
					}
				}
			}
			NodeKind::CreateExpression => {
				if $function.useThisVariable(data.class, node) {
					return true
				}

				for arg in data.arguments {
					if $function.useThisVariable(arg, node) {
						return true
					}
				}
			}
			NodeKind::EnumExpression => return false
			NodeKind::Identifier => return data.name == 'this'
			NodeKind::IfStatement => {
				if $function.useThisVariable(data.condition, node) || $function.useThisVariable(data.whenTrue, node) {
					return true
				}

				if data.whenFalse? && $function.useThisVariable(data.whenFalse, node) {
					return true
				}
			}
			NodeKind::Literal => return false
			NodeKind::MemberExpression => return $function.useThisVariable(data.object, node)
			NodeKind::NumericExpression => return false
			NodeKind::ObjectExpression => {
				for property in data.properties {
					if $function.useThisVariable(property.value, node) {
						return true
					}
				}
			}
			NodeKind::PolyadicExpression => {
				for operand in data.operands {
					if $function.useThisVariable(operand, node) {
						return true
					}
				}
			}
			NodeKind::ReturnStatement => return $function.useThisVariable(data.value, node)
			NodeKind::TemplateExpression => {
				for element in data.elements {
					if $function.useThisVariable(element, node) {
						return true
					}
				}
			}
			NodeKind::ThisExpression => return true
			NodeKind::ThrowStatement => return $function.useThisVariable(data.value, node)
			NodeKind::UnaryExpression => return $function.useThisVariable(data.argument, node)
			NodeKind::VariableDeclaration => {
				return data.init? && $function.useThisVariable(data.init, node)
			}
			=> {
				throw new NotImplementedException(`Unknow kind \(data.kind)`, node)
			}
		}

		return false
	} // }}}
}

class FunctionDeclaration extends Statement {
	private {
		_extended: Boolean			= false
		_main: Boolean				= false
		_name: String
		_oldVariableName: String
		_variable: FunctionVariable
	}
	static toFlatWrongDoingFragments(block, ctrl?, argName, async, returns) { // {{{
		if ctrl == null {
			if async {
				throw new NotImplementedException()
			}
			else {
				block
					.newControl()
					.code(`if(\(argName).length !== 0)`)
					.step()
					.line('throw new SyntaxError("Wrong number of arguments")')
					.done()
			}
		}
		else {
			if async {
				ctrl.step().code('else').step().line(`return __ks_cb(new SyntaxError("Wrong number of arguments"))`).done()
			}
			else if returns {
				ctrl.done()

				block.line('throw new SyntaxError("Wrong number of arguments")')
			}
			else {
				ctrl.step().code('else').step().line('throw new SyntaxError("Wrong number of arguments")').done()
			}
		}
	} // }}}
	analyse() { // {{{
		@name = @data.name.name

		if @variable ?= @scope.getDefinedVariable(@name) {
			if @variable is FunctionVariable {
				const declarator = new FunctionDeclarator(@variable, @data, this)

				declarator.analyse()
			}
			else {
				@scope.addStash(@name, variable => {
					const type = variable.getRealType()

					if type.isFunction() {
						@main = true
						@extended = true

						@variable = new FunctionVariable(@scope!?, @name, true)

						@variable.getRealType().addFunction(type)

						@scope.replaceVariable(@name, @variable)

						@oldVariableName = @scope.getNewName(@name)
					}
					else {
						SyntaxException.throwNotOverloadableFunction(@name, this)
					}

					return true
				}, variable => {
					@variable = variable

					const declarator = new FunctionDeclarator(@variable, @data, this)

					declarator.analyse()
				})
			}
		}
		else {
			@main = true

			@variable = new FunctionVariable(@scope!?, @name, false)

			@scope.defineVariable(@variable, this)

			const declarator = new FunctionDeclarator(@variable, @data, this)

			declarator.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @main || @scope.processStash(@name) {
			@variable.prepare()
		}
	} // }}}
	translate() { // {{{
		if @main {
			@variable.translate()
		}
	} // }}}
	addInitializableVariable(variable, node)
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	initializeVariable(variable, type, expression, node)
	name() => @name
	toFlatFooterFragments(fragments) { // {{{
		fragments.done()
	} // }}}
	toFlatHeaderFragments(fragments) { // {{{
		const block = fragments.code(`function \(@variable.getSecureName())()`).newBlock()

		if @variable.isAsync() {
			block.line('var __ks_cb = arguments[arguments.length - 1]')

			block
				.newControl()
				.code('if(!Type.isFunction(__ks_cb))')
				.step()
				.line(`throw new SyntaxError("Callback can't be found")`)
				.done()

			block.line('var __ks_arguments = Array.prototype.slice.call(arguments, 0, arguments.length - 1)')
		}

		return block
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		return unless @main

		const name = @variable.getSecureName()

		if @extended {
			fragments.line($const(this), @oldVariableName, $equals, name)

			const assessment = Router.assess([declarator.type() for const declarator in @variable._declarators], true, true)

			Router.toFragments(
				assessment
				fragments.newLine()
				'arguments'
				false
				(node, fragments) => fragments.code(`function \(name)()`).newBlock()
				(fragments) => fragments.done()
				(fragments, method, index) => {
					const declarator = @variable.getDeclarator(index)

					declarator.toRouterFragments(fragments, (fragments, wrongdoing, data) => {
						if this._options.format.spreads == 'es5' {
							fragments.line(`return \(@oldVariableName).apply(null, arguments)`)
						}
						else {
							fragments.line(`return \(@oldVariableName)(...arguments)`)
						}
					})

					return false
				}
				(block, ctrl, async, returns) => {
					if this._options.format.spreads == 'es5' {
						ctrl.step().code('else').step().line(`return \(@oldVariableName).apply(null, arguments)`).done()
					}
					else {
						ctrl.step().code('else').step().line(`return \(@oldVariableName)(...arguments)`).done()
					}
				}
				this
			).done()
		}
		else if @variable.length() == 1 {
			@variable.getDeclarator(0).toStatementFragments(fragments, name, mode)
		}
		else {
			const assessment = this.type().assessment()

			if assessment.flattenable {
				const argName = @variable.isAsync() ? '__ks_arguments' : 'arguments'

				Router.toFragments(
					assessment
					fragments.newLine()
					argName
					false
					(node, fragments) => this.toFlatHeaderFragments(fragments)
					(fragments) => this.toFlatFooterFragments(fragments)
					(fragments, method, index) => {
						const declarator = @variable.getDeclarator(index)

						declarator.toRouterFragments(fragments, Parameter.toWrongDoingFragments)

						return declarator.isExit()
					}
					FunctionDeclaration.toFlatWrongDoingFragments
					this
				).done()
			}
			else {
				@variable.toStatementFragments(fragments, mode)

				Router.toFragments(
					assessment
					fragments.newLine()
					'arguments'
					false
					(node, fragments) => fragments.code(`function \(name)()`).newBlock()
					(fragments) => fragments.done()
					(fragments, method, index) => {
						const name = @variable.getDeclaratorName(index)

						if this._options.format.spreads == 'es5' {
							fragments.line(`return \(name).apply(null, arguments)`)
						}
						else {
							fragments.line(`return \(name)(...arguments)`)
						}

						return false
					}
					ClassDeclaration.toWrongDoingFragments
					this
				).done()
			}
		}
	} // }}}
	type() => @variable.getDeclaredType()
	walk(fn) { // {{{
		if @main {
			fn(@name, @variable.getDeclaredType())
		}
	} // }}}
}

class FunctionDeclarator extends AbstractNode {
	private {
		_autoTyping: Boolean			= false
		_awaiting: Boolean				= false
		_block: Block
		_exit: Boolean					= false
		_offset: Number
		_parameters: Array<Parameter>	= []
		_returnNull: Boolean			= false
		_variable: FunctionVariable
		_type: FunctionType
	}
	constructor(@variable, @data, @parent) { // {{{
		super(data, parent, parent.scope(), ScopeType::Function)

		variable.addDeclarator(this)
	} // }}}
	analyse() { // {{{
		@offset = @scope.module().getLineOffset()

		@scope.define('this', true, Type.Any, this)

		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		@scope.module().setLineOffset(@offset)

		@scope.line(@data.start.line)

		for parameter in @parameters {
			parameter.prepare()
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, this)

		@returnNull = @data.body.kind == NodeKind::IfStatement || @data.body.kind == NodeKind::UnlessStatement

		@block = $compile.function($ast.body(@data), this)
		@block.analyse()

		@autoTyping = @data.type?.kind == NodeKind::ReturnTypeReference

		if @autoTyping {
			@type.returnType(@block.getUnpreparedType())
		}
	} // }}}
	translate() { // {{{
		@scope.module().setLineOffset(@offset)

		@scope.line(@data.start.line)

		for parameter in @parameters {
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

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} // }}}
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isAwait() => @awaiting
	isExit() => @exit
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
	isJumpable() => false
	parameters() => @parameters
	toAwaitExpressionFragments(fragments, parameters, statements) { // {{{
		fragments.code('(__ks_e')

		for parameter in parameters {
			fragments.code($comma).compile(parameter)
		}

		fragments.code(') =>')

		const block = fragments.newBlock()

		const ctrl = block
			.newControl()
			.code('if(__ks_e)')
			.step()
			.line('__ks_cb(__ks_e)')
			.step()
			.code('else')
			.step()

		let index = -1
		let item

		for statement, i in statements while index == -1 {
			if item ?= statement.toFragments(ctrl, Mode::None) {
				index = i
			}
		}

		if index != -1 {
			item(statements.slice(index + 1))
		}

		ctrl.done()

		block.done()

		fragments.code(')').done()
	} // }}}
	toRouterFragments(fragments, wrongdoer) { // {{{
		const mode = @type.isAsync() ? ParameterMode::AsyncFunction : ParameterMode::OverloadedFunction

		Parameter.toFragments(this, fragments, mode, (fragments) => fragments, wrongdoer)

		fragments.compile(@block, Mode::None)

		if !@exit {
			if !@awaiting && @type.isAsync() {
				fragments.line('__ks_cb()')
			}
			else if @returnNull {
				fragments.line('return null')
			}
		}
	} // }}}
	toStatementFragments(fragments, name, mode) { // {{{
		const ctrl = fragments.newControl().code(`function \(name)(`)

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(fragments) {
			return fragments.code(')').step()
		})

		ctrl.compile(@block, Mode::None)

		if !@exit {
			if !@awaiting && @type.isAsync() {
				ctrl.line('__ks_cb()')
			}
			else if @returnNull {
				ctrl.line('return null')
			}
		}

		ctrl.done()
	} // }}}
	type() => @type
}

class FunctionVariable extends Variable {
	private {
		_async: Boolean								= false
		_extended: Boolean							= false
		_declarators: Array<FunctionDeclarator>		= []
	}
	constructor(scope: Scope, @name, @extended) { // {{{
		super(name, true, false, new OverloadedFunctionType(scope))

		@initialized = true
	} // }}}
	prepare() { // {{{
		if @extended {
			let type

			for declarator in @declarators {
				declarator.prepare()

				type = declarator.type()

				if type.isAsync() != @async {
					SyntaxException.throwMixedOverloadedFunction(declarator)
				}
				else if @declaredType.hasFunction(type) {
					SyntaxException.throwIdenticalFunction(@name, declarator)
				}

				@declaredType.addFunction(type)
			}
		}
		else if @declarators.length == 1 {
			@declarators[0].prepare()

			const type = @declarators[0].type()

			@declaredType = Type.toNamedType(@name, type)
			@realType = @declaredType
		}
		else {
			let declarator = @declarators[0]
			declarator.prepare()

			let type = declarator.type()
			@declaredType.addFunction(type)

			const async = type.isAsync()

			for declarator in @declarators from 1 {
				declarator.prepare()

				type = declarator.type()

				if type.isAsync() != async {
					SyntaxException.throwMixedOverloadedFunction(declarator)
				}
				else if @declaredType.hasFunction(type) {
					SyntaxException.throwIdenticalFunction(@name, declarator)
				}

				@declaredType.addFunction(type)
			}
		}
	} // }}}
	translate() { // {{{
		for declarator in @declarators {
			declarator.translate()
		}
	} // }}}
	addDeclarator(declarator: FunctionDeclarator) { // {{{
		@declarators.push(declarator)
	} // }}}
	getDeclarator(index: Number) => @declarators[index]
	getDeclaratorName(index) => `__ks_\(@name)_\(index)`
	isAsync() => @declaredType.isAsync()
	length() => @declarators.length
	toStatementFragments(fragments, mode) { // {{{
		for const declarator, index in @declarators {
			declarator.toStatementFragments(fragments, `__ks_\(@name)_\(index)`, mode)
		}
	} // }}}
}