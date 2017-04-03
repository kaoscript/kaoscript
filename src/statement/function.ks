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
				for declaration in data.declarations {
					if declaration.init? && $function.useThisVariable(declaration.init, node) {
						return true
					}
				}
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
		_awaiting: Boolean		= false
		_parameters
		_signature
		_statements
		_variable: Variable
		_type: Type
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@scope.define('this', true, this)
		
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
		
		@statements = []
		for statement in $ast.body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
			
			if statement.isAwait() {
				@awaiting = true
			}
		}
		
		for statement in @statements {
			statement.prepare()
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isMethod() => false
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('function ' + @data.name.name + '(')
		
		Parameter.toFragments(this, ctrl, false, func(node) {
			return node.code(')').step()
		})
		
		if @awaiting {
			let stack = []
			
			let f = ctrl
			let m = Mode::None
			
			let item
			for statement in @statements {
				if item ?= statement.toFragments(f, m) {
					f = item.fragments
					m = item.mode
					
					stack.push(item)
				}
			}
			
			for item in stack {
				item.done(item.fragments)
			}
		}
		else {
			for statement in @statements {
				ctrl.compile(statement, Mode::None)
			}
		}
		
		ctrl.done()
	} // }}}
	type() => @type
}