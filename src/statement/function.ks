var $function = {
	surround(node) { # {{{
		var mut parent = node._parent
		while ?parent && !(parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration) {
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

				if ?data.whenFalse && $function.useThisVariable(data.whenFalse, node) {
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
				return ?data.init && $function.useThisVariable(data.init, node)
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
		@continued: Boolean			= false
		@extended: Boolean			= false
		@main: Boolean				= false
		@name: String
		@oldVariableName: String
		@variable: FunctionVariable
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
	override prepare(target) { # {{{
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
	toMainFragments(fragments, name: String, assessment) { # {{{
		if assessment.labelable {
			var line = fragments.newLine().code(`function \(name)(kws, ...args)`)
			var block = line.newBlock()

			block.line(`return \(name).__ks_rt(this, args, kws)`)

			block.done()
			line.done()
		}
		else {
			var declarators = @variable.declarators()
			var line = fragments.newLine().code(`function \(name)(`)

			if declarators.length == 1 && declarators[0].hasRetainedParameters() {
				for var parameter, index in declarators[0].parameters() {
					line.code($comma) unless index == 0

					line.compile(parameter)
				}
			}

			var block = line.code(`)`).newBlock()

			block.line(`return \(name).__ks_rt(this, arguments)`)

			block.done()
			line.done()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		return unless @main

		var name = @variable.getSecureName()
		var assessment = @type().assessment(@variable.name(), this)

		if @continued {
			for var declarator in @variable.declarators() {
				declarator.toStatementFragments(fragments)
			}

			@toRouterFragments(fragments, name, assessment)
		}
		else if @extended {
			fragments.line($const(this), @oldVariableName, $equals, name)

			@toMainFragments(fragments, name, assessment)

			fragments.line(`\(name).__ks_0 = \(@oldVariableName)`)

			for var declarator in @variable.declarators() {
				declarator.toStatementFragments(fragments)
			}

			@toRouterFragments(fragments, name, assessment)
		}
		else {
			@toMainFragments(fragments, name, assessment)

			for var declarator in @variable.declarators() {
				declarator.toStatementFragments(fragments)
			}

			@toRouterFragments(fragments, name, assessment)
		}
	} # }}}
	toRouterFragments(fragments, name: String, assessment) { # {{{
		var line = fragments.newLine()

		if assessment.labelable {
			line.code(`\(name).__ks_rt = function(that, args, kws)`)
		}
		else {
			line.code(`\(name).__ks_rt = function(that, args)`)
		}

		var block = line.newBlock()

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
	walkVariable(fn) { # {{{
		if @main {
			fn(@name, @variable.getDeclaredType())
		}
	} # }}}
}

class FunctionDeclarator extends AbstractNode {
	private late {
		@autoTyping: Boolean			= false
		@awaiting: Boolean				= false
		@block: Block
		@exit: Boolean					= false
		@index: Number					= 0
		@offset: Number
		@parameters: Array<Parameter>	= []
		@returnNull: Boolean			= false
		@variable: FunctionVariable
		@topNodes: Array				= []
		@type: FunctionType
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
	override prepare(target) { # {{{
		@scope.module().setLineOffset(@offset)

		@scope.line(@data.start.line)

		for var parameter in @parameters {
			parameter.prepare(AnyType.NullableUnexplicit)
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, @index, this)

		@returnNull = @data.body.kind == NodeKind::IfStatement || @data.body.kind == NodeKind::UnlessStatement

		@block = $compile.function($ast.body(@data), this)
		@block.analyse()

		@autoTyping = @type.isAutoTyping()

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}

		@type.flagComplete()
	} # }}}
	translate() { # {{{
		@scope.module().setLineOffset(@offset)

		@scope.line(@data.start.line)

		for parameter in @parameters {
			parameter.translate()
		}

		if @autoTyping {
			@block.prepare(AnyType.NullableUnexplicit)

			@type.setReturnType(@block.type())
		}
		else {
			@block.prepare(@type.getReturnType())
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
	hasRetainedParameters() { # {{{
		for var parameter in @parameters {
			return true if parameter.isRetained()
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
		var mut item = null

		for var statement, i in statements while index == -1 {
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
		@async: Boolean								= false
		@extended: Boolean							= false
		@declarators: Array<FunctionDeclarator>		= []
		@indexDelta: Number							 = 0
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
			for var declarator in @declarators {
				declarator.prepare()

				var type = declarator.type()

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

			for var declarator in @declarators from 1 {
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
		for var declarator in @declarators {
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
