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
				
				if data.whenFalse? && data.$function.useThisVariable(data.whenFalse, node) {
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
		_main: Boolean				= false
		_name: String
		_variable: FunctionVariable
	}
	constructor(@data, @parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@scope.define('this', true, this)
		
		@name = @data.name.name
		
		if @variable ?= this.greatScope().getLocalVariable(@name) {
			if @variable is not FunctionVariable {
				SyntaxException.throwNotOverloadableFunction(@name, this)
			}
		}
		else {
			@main = true
			@variable = new FunctionVariable(@name)
			
			this.greatScope().addVariable(@name, @variable, this)
		}
		
		const declarator = new FunctionDeclarator(@variable, @data, this)
		
		declarator.analyse()
	} // }}}
	prepare() { // {{{
		return unless @main
		
		@variable.prepare()
	} // }}}
	translate() { // {{{
		return unless @main
		
		@variable.translate()
	} // }}}
	name() => @name
	toStatementFragments(fragments, mode) { // {{{
		return unless @main
		
		if @variable.length() == 1 {
			@variable.getDeclarator(0).toStatementFragments(fragments, mode)
		}
		else {
			ClassDeclaration.toSwitchFragments(
				this
				fragments.newLine()
				@variable.type()
				[declarator.type() for declarator in @variable._declarators]
				@name
				null
				(node, fragments) => {
					const block = fragments.code(`function \(@name)()`).newBlock()
					
					return block
				}
				(fragments) => {
					fragments.done()
				}
				(fragments, method, index) => {
					const declarator = @variable.getDeclarator(index)
					
					declarator.toSwitchFragments(fragments)
				}
				'arguments'
				false
			).done()
		}
	} // }}}
	type() => @variable.type()
	walk(fn) { // {{{
		if @main {
			fn(@name, @variable.type())
		}
	} // }}}
}

class FunctionDeclarator extends AbstractNode {
	private {
		_await: Boolean				= false
		_exit: Boolean				= false
		_parameters: Array			= []
		_statements: Array			= []
		_variable: FunctionVariable
		_type: FunctionType
	}
	constructor(@variable, @data, @parent) { // {{{
		super(data, parent)
		
		variable.addDeclarator(this)
	} // }}}
	analyse() { // {{{
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))
			
			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}
		
		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, this)
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		for statement in $ast.body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
			
			if statement.isAwait() {
				@await = true
			}
		}
		
		const rtype = @type.returnType()
		const na = !rtype.isAny()
		
		for statement in @statements {
			statement.prepare()
			
			if @exit {
				SyntaxException.throwDeadCode(statement)
			}
			else if na && !statement.isReturning(rtype) {
				TypeException.throwUnexpectedReturnedType(rtype, statement)
			}
			else {
				@exit = statement.isExit()
			}
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isAwait() => @await
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
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
	toStatementFragments(fragments, mode) { // {{{
		const ctrl = fragments.newControl().code(`function \(@parent.name())(`)
		
		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(fragments) {
			return fragments.code(')').step()
		})
		
		if @await {
			let index = -1
			let item
			
			for statement, i in @statements while index == -1 {
				if item ?= statement.toFragments(ctrl, Mode::None) {
					index = i
				}
			}
			
			if index != -1 {
				item(@statements.slice(index + 1))
			}
		}
		else {
			for statement in @statements {
				ctrl.compile(statement, Mode::None)
			}
			
			if !@exit && @type.isAsync() {
				ctrl.line('__ks_cb()')
			}
		}
		
		ctrl.done()
	} // }}}
	toSwitchFragments(fragments) { // {{{
		Parameter.toFragments(this, fragments, ParameterMode::OverloadedFunction, (fragments) => fragments)
		
		if @await {
			let index = -1
			let item
			
			for statement, i in @statements while index == -1 {
				if item ?= statement.toFragments(fragments, Mode::None) {
					index = i
				}
			}
			
			if index != -1 {
				item(@statements.slice(index + 1))
			}
		}
		else {
			for statement in @statements {
				fragments.compile(statement, Mode::None)
			}
			
			if !@exit && @type.isAsync() {
				fragments.line('__ks_cb()')
			}
		}
	} // }}}
	type() => @type
}

class FunctionVariable extends Variable {
	private {
		_declarators: Array<FunctionDeclarator>		= []
	}
	constructor(@name) { // {{{
		super(name, true)
	} // }}}
	addDeclarator(declarator: FunctionDeclarator) { // {{{
		@declarators.push(declarator)
	} // }}}
	getDeclarator(index: Number) => @declarators[index]
	length() => @declarators.length
	prepare() { // {{{
		if @declarators.length == 1 {
			@declarators[0].prepare()
			
			@type = @declarators[0].type()
		}
		else {
			@type = new OverloadedFunctionType()
			
			let declarator = @declarators[0]
			declarator.prepare()
			
			let type = declarator.type()
			@type.addFunction(type)
			
			const async = type.isAsync()
			
			for declarator in @declarators from 1 {
				declarator.prepare()
				
				type = declarator.type()
				
				if type.isAsync() != async {
					SyntaxException.throwMixedOverloadedFunction(declarator)
				}
				else if @type.hasFunction(type) {
					SyntaxException.throwNotDifferentiableFunction(declarator)
				}
				
				@type.addFunction(type)
			}
		}
	} // }}}
	translate() { // {{{
		for declarator in @declarators {
			declarator.translate()
		}
	} // }}}
}