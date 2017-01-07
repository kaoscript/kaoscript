class VariableDeclaration extends Statement {
	private {
		_async = false
		_declarators = []
		_init = false
	}
	analyse() { // {{{
		for declarator in this._data.declarations {
			if declarator.kind == Kind::AwaitExpression {
				declarator = new AwaitDeclarator(declarator, this)
				
				this._async = true
			}
			else {
				declarator = new VariableDeclarator(declarator, this)
			}
			
			declarator.analyse()
			
			this._declarators.push(declarator)
		}
	} // }}}
	fuse() { // {{{
		for declarator in this._declarators {
			declarator.fuse()
		}
	} // }}}
	isAsync() => @async
	isConst() => @data.modifiers.kind == VariableModifier::Const
	modifier(data) { // {{{
		if data.name.kind == Kind::ArrayBinding || data.name.kind == Kind::ObjectBinding || this._options.format.variables == 'es5' {
			return $code('var')
		}
		else {
			if this._data.modifiers.kind == VariableModifier::Let {
				return $code('let', this._data.modifiers.start, this._data.modifiers.end)
			}
			else {
				return $code('const', this._data.modifiers.start, this._data.modifiers.end)
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._declarators.length == 1 {
			if this._async {
				return this._declarators[0].toFragments(fragments)
			}
			else {
				this._declarators[0].toFragments(fragments, this._data.modifiers)
			}
		}
		else {
			let line = fragments.newLine().code(this.modifier(this._declarators[0]._data), $space)
			
			for declarator, index in this._declarators {
				line.code($comma) if index
				
				line.compile(declarator._name)
			}
			
			line.done()
		}
	} // }}}
}

class AwaitDeclarator extends AbstractNode {
	private {
		_operation
		_variables = []
	}
	$create(data, parent) { // {{{
		super(data, parent, new Scope(parent._scope))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._operation = $compile.expression(data.operation, this)
		
		for variable in data.variables {
			if variable.kind == Kind::VariableDeclarator {
				$variable.define(this, this._scope._parent, variable.name, $variable.kind(variable.type), variable.type)
				
				this._variables.push($compile.expression(variable.name, this))
			}
			else {
				$variable.define(this, this._scope._parent, variable, VariableKind::Variable)
				
				this._variables.push($compile.expression(variable, this))
			}
		}
	} // }}}
	fuse() { // {{{
		this._operation.fuse()
		
		for variable in this._variables {
			variable.fuse()
		}
	} // }}}
	statement() => this._parent.statement()
	toFragments(fragments) { // {{{
		let line = fragments.newLine()
		
		this._operation.toFragments(line, Mode::Async)
		
		line.code('(__ks_e')
		
		for variable in this._variables {
			line.code(', ').compile(variable)
		}
		
		line.code(') =>')
		
		let block = line.newBlock()
		
		block
			.newControl()
			.code('if(__ks_e)')
			.step()
			.line('return __ks_cb(__ks_e)')
			.done()
		
		return {
			fragments: block
			mode: Mode::Async
			done: func(block) {
				block.done()
				
				line.code(')').done()
			}
		}
	} // }}}
}

class VariableDeclarator extends AbstractNode {
	private {
		_declare	= true
		_init		= null
	}
	analyse() { // {{{
		let data = this._data
		
		if data.name.kind == Kind::Identifier {
			if this._options.format.variables == 'es5' {
				this._scope.rename(data.name.name)
			}
			
			if this._scope.hasVariable(data.name.name, false) {
				$throw(`Already declared variable '\(data.name.name)' at line \(data.name.start.line)`, this)
			}
			
			if this._scope.isDeclaredVariable(data.name.name, false) {
				this._declare = false
			}
		}
		
		if data.autotype || @parent.isConst() {
			let type = data.type
			
			if !type && data.init {
				type = data.init
			}
			
			$variable.define(this, @scope, data.name, $variable.kind(data.type), type)
		}
		else {
			$variable.define(this, @scope, data.name, $variable.kind(data.type), data.type)
		}
		
		this._name = $compile.expression(data.name, this)
		
		if data.init? {
			if data.name.kind == Kind::Identifier {
				this.reference(data.name.name)
			}
			
			this._init = $compile.expression(data.init, this)
		}
	} // }}}
	fuse() { // {{{
		if this._init != null {
			this._init.fuse()
		}
	} // }}}
	statement() => this._parent.statement()
	toFragments(fragments, modifier) { // {{{
		if this._options.format.destructuring == 'es5' && (this._name is ArrayBinding || this._name is ObjectBinding) {
			if this._init != null {
				let line = fragments.newLine()
			
				line.code(this._parent.modifier(this._data), $space) if this._declare
				
				this._name.toFlatFragments(line, this._init)
				
				line.done()
			}
			else if this._declare {
				fragments.line(this._parent.modifier(this._data), $space, this._name.listVariables().join(', '))
			}
		}
		else {
			let line = fragments.newLine()
			
			line.code(this._parent.modifier(this._data), $space) if this._declare
			
			line.compile(this._name)
			
			if this._init != null {
				line.code($equals).compile(this._init)
			}
			
			line.done()
		}
	} // }}}
}