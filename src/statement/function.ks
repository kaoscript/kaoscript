var $function = {
	surround(node) { # {{{
		var mut parent = node._parent
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
	} # }}}
	useThisVariable(data, node) { # {{{
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
				for var operand in data.values by 2 {
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
	} # }}}
}

class FunctionDeclaration extends Statement {
	private late {
		_continued: Boolean			= false
		_extended: Boolean			= false
		_main: Boolean				= false
		_name: String
		_oldVariableName: String
		_variable: FunctionVariable
	}
	static toFlatWrongDoingFragments(block, ctrl?, argName, async, returns) { # {{{
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
	} # }}}
	initiate() { # {{{
		@name = @data.name.name

		if @variable ?= @scope.getDefinedVariable(@name) {
			if @variable is FunctionVariable {
				@continued = true
			}
			else if @variable.getDeclaredType().isFunction() {
				@main = true
				@continued = true
			}
			else {
				@scope.addStash(@name, variable => {
					var type = variable.getRealType()

					if type.isFunction() {
						@main = true
						@extended = true

						@variable = new FunctionVariable(@scope!?, @name, true, type.length?() ?? 1)

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

					var declarator = new FunctionDeclarator(@variable, @data, this)

					declarator.analyse()
				})
			}
		}
		else {
			@main = true

			@variable = new FunctionVariable(@scope!?, @name, false)

			@scope.defineVariable(@variable, this)
		}
	} # }}}
	analyse() { # {{{
		if @main {
			if @continued {
				var variable = @scope.getDefinedVariable(@name)

				if variable is FunctionVariable {
					@main = false
					@variable = variable
				}
				else {
					var type = @variable.getDeclaredType()

					@variable = new FunctionVariable(@scope!?, @name, true, type.length?() ?? 1)

					@variable.getRealType().addFunction(type)

					@scope.replaceVariable(@name, @variable)
				}
			}

			var declarator = new FunctionDeclarator(@variable, @data, this)

			declarator.analyse()
		}
		else if @continued {
			var declarator = new FunctionDeclarator(@variable, @data, this)

			declarator.analyse()
		}
	} # }}}
	prepare() { # {{{
		if @main || @scope.processStash(@name) {
			@variable.prepare()
		}
	} # }}}
	translate() { # {{{
		if @main {
			@variable.translate()
		}
	} # }}}
	addInitializableVariable(variable, node)
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	initializeVariable(variable, expression, node)
	name() => @name
	toMainFragments(fragments) { # {{{
		var declarators = @variable.declarators()
		var name = @variable.getSecureName()
		var line = fragments.newLine().code(`function \(name)(`)

		if declarators.length == 1 && declarators[0].hasPreservedParameter() {
			for var parameter, index in declarators[0].parameters() {
				line.code($comma) unless index == 0

				line.compile(parameter)
			}
		}

		var block = line.code(`)`).newBlock()

		block.line(`return \(name).__ks_rt(this, arguments)`)

		block.done()
		line.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		return unless @main

		if @continued {
			for var declarator in @variable.declarators() {
				declarator.toStatementFragments(fragments)
			}

			this.toRouterFragments(fragments)
		}
		else if @extended {
			var name = @variable.getSecureName()

			fragments.line($const(this), @oldVariableName, $equals, name)

			this.toMainFragments(fragments)

			fragments.line(`\(name).__ks_0 = \(@oldVariableName)`)

			for var declarator in @variable.declarators() {
				declarator.toStatementFragments(fragments)
			}

			this.toRouterFragments(fragments)
		}
		else {
			this.toMainFragments(fragments)

			for var declarator in @variable.declarators() {
				declarator.toStatementFragments(fragments)
			}

			this.toRouterFragments(fragments)
		}
	} # }}}
	toRouterFragments(fragments) { # {{{
		var name = @variable.getSecureName()

		var assessment = this.type().assessment(@variable.name(), this)

		var line = fragments.newLine()
		var block = line.code(`\(name).__ks_rt = function(that, args)`).newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`\(name).__ks_\(function.getCallIndex()).call(that`)

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
	type() => @variable.getDeclaredType()
	walk(fn) { # {{{
		if @main {
			fn(@name, @variable.getDeclaredType())
		}
	} # }}}
}

class FunctionDeclarator extends AbstractNode {
	private late {
		_autoTyping: Boolean			= false
		_awaiting: Boolean				= false
		_block: Block
		_exit: Boolean					= false
		_index: Number					= 0
		_offset: Number
		_parameters: Array<Parameter>	= []
		_returnNull: Boolean			= false
		_variable: FunctionVariable
		_topNodes: Array				= []
		_type: FunctionType
	}
	constructor(@variable, @data, @parent) { # {{{
		super(data, parent, parent.scope(), ScopeType::Function)

		variable.addDeclarator(this)
	} # }}}
	analyse() { # {{{
		@offset = @scope.module().getLineOffset()

		@scope.define('this', true, Type.Any, this)

		for var data in @data.parameters {
			var parameter = new Parameter(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}
	} # }}}
	prepare() { # {{{
		@scope.module().setLineOffset(@offset)

		@scope.line(@data.start.line)

		for var parameter in @parameters {
			parameter.prepare()
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, @index, this)

		@returnNull = @data.body.kind == NodeKind::IfStatement || @data.body.kind == NodeKind::UnlessStatement

		@block = $compile.function($ast.body(@data), this)
		@block.analyse()

		@autoTyping = @data.type?.kind == NodeKind::ReturnTypeReference

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}
	} # }}}
	translate() { # {{{
		@scope.module().setLineOffset(@offset)

		@scope.line(@data.start.line)

		for parameter in @parameters {
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
	addInitializableVariable(variable, node)
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	getFunctionNode() => this
	getParameterOffset() => 0
	hasPreservedParameter() { # {{{
		for var parameter in @parameters {
			return true if parameter.isPreserved()
		}

		return false
	} # }}}
	index(@index): this
	initializeVariable(variable, expression, node)
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isAwait() => @awaiting
	isExit() => @exit
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
	isJumpable() => false
	isOverridableFunction() => false
	parameters() => @parameters
	toAwaitExpressionFragments(fragments, parameters, statements) { # {{{
		fragments.code('(__ks_e')

		for parameter in parameters {
			fragments.code($comma).compile(parameter)
		}

		fragments.code(') =>')

		var block = fragments.newBlock()

		var ctrl = block
			.newControl()
			.code('if(__ks_e)')
			.step()
			.line('__ks_cb(__ks_e)')
			.step()
			.code('else')
			.step()

		var mut index = -1
		var mut item

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
	} # }}}
	toStatementFragments(fragments) { # {{{
		var line = fragments.newLine().code(`\(@variable.getSecureName()).__ks_\(@type.index()) = function(`)

		var block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
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

class FunctionVariable extends Variable {
	private {
		_async: Boolean								= false
		_extended: Boolean							= false
		_declarators: Array<FunctionDeclarator>		= []
		_indexDelta: Number							 = 0
	}
	constructor(scope: Scope, @name, @extended, @indexDelta = 0) { # {{{
		super(name, true, false, new OverloadedFunctionType(scope))

		@initialized = true
	} # }}}
	analyse() { # {{{
		for declarator in @declarators {
			declarator.analyse()
		}
	} # }}}
	prepare() { # {{{
		if @extended {
			var mut type

			for declarator in @declarators {
				declarator.prepare()

				type = declarator.type()

				if type.isAsync() != @async {
					SyntaxException.throwMixedOverloadedFunction(declarator)
				}
				else if @declaredType.hasFunction(type) {
					SyntaxException.throwIdenticalFunction(@name, type, declarator)
				}

				@declaredType.addFunction(type)
			}
		}
		else if @declarators.length == 1 {
			@declarators[0].prepare()

			var type = @declarators[0].type()

			@declaredType = Type.toNamedType(@name, type)
			@realType = @declaredType
		}
		else {
			var mut declarator = @declarators[0]
			declarator.prepare()

			var mut type = declarator.type()
			@declaredType.addFunction(type)

			var async = type.isAsync()

			for declarator in @declarators from 1 {
				declarator.prepare()

				type = declarator.type()

				if type.isAsync() != async {
					SyntaxException.throwMixedOverloadedFunction(declarator)
				}
				else if @declaredType.hasFunction(type) {
					SyntaxException.throwIdenticalFunction(@name, type, declarator)
				}

				@declaredType.addFunction(type)
			}
		}
	} # }}}
	translate() { # {{{
		for declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	addDeclarator(declarator: FunctionDeclarator) { # {{{
		declarator.index(@indexDelta + @declarators.length)

		@declarators.push(declarator)
	} # }}}
	declarators() => @declarators
	isAsync() => @declaredType.isAsync()
	length() => @declarators.length
	toStatementFragments(fragments, mode) { # {{{
		for var declarator, index in @declarators {
			declarator.toStatementFragments(fragments, `__ks_\(@name)_\(index)`, mode)
		}
	} # }}}
}
