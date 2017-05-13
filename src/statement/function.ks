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
						beforeParameters: 'Helper.vcurry(function('
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
		_await: Boolean			= false
		_exit: Boolean			= false
		_name: String
		_parameters
		_signature
		_statements: Array		= []
		_variable: Variable
		_type: Type
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@scope.define('this', true, this)
		
		@name = @data.name.name
		@variable = this.greatScope().define(@data.name.name, true, this)
		
		@parameters = []
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
		
		@variable.type(@type)
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
		
		for statement in @statements {
			statement.prepare()
			
			if @exit {
				SyntaxException.throwDeadCode(statement)
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
	isMethod() => false
	name() => @name
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
		const ctrl = fragments.newControl().code(`function \(@name)(`)
		
		Parameter.toFragments(this, ctrl, false, func(node) {
			return node.code(')').step()
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
	type() => @type
	walk(fn) { // {{{
		fn(@name, @type)
	} // }}}
}