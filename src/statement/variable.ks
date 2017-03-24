class VariableDeclaration extends Statement {
	private {
		_await: Boolean		= false
		_declarators		= []
		_init: Boolean		= false
	}
	analyse() { // {{{
		for declarator in @data.declarations {
			if declarator.kind == NodeKind::AwaitExpression {
				declarator = new AwaitDeclarator(declarator, this)
				
				@await = true
			}
			else {
				declarator = new VariableDeclarator(declarator, this)
			}
			
			declarator.analyse()
			
			@declarators.push(declarator)
		}
	} // }}}
	prepare() { // {{{
		for declarator in @declarators {
			declarator.prepare()
		}
	} // }}}
	translate() { // {{{
		for declarator in @declarators {
			declarator.translate()
		}
	} // }}}
	isImmutable() => !@data.rebindable
	isAwait() => @await
	modifier(data) { // {{{
		if data.name.kind == NodeKind::ArrayBinding || data.name.kind == NodeKind::ObjectBinding || @options.format.variables == 'es5' {
			return $code('var')
		}
		else {
			if @data.rebindable {
				return $code('let')
			}
			else {
				return $code('const')
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @declarators.length == 1 {
			if @await {
				return @declarators[0].toFragments(fragments)
			}
			else {
				@declarators[0].toFragments(fragments)
			}
		}
		else {
			let line = fragments.newLine().code(this.modifier(@declarators[0]._data), $space)
			
			for declarator, index in @declarators {
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
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent._scope))
	} // }}}
	analyse() { // {{{
		@operation = $compile.expression(@data.operation, this)
		
		@operation.analyse()
		
		const immutable = @parent.isImmutable()
		
		for variable in @data.variables {
			if variable.kind == NodeKind::VariableDeclarator {
				$variable.define(this, @scope._parent, variable.name, immutable, $variable.kind(variable.type), variable.type)
				
				@variables.push($compile.expression(variable.name, this))
			}
			else {
				$variable.define(this, @scope._parent, variable, immutable, VariableKind::Variable)
				
				@variables.push($compile.expression(variable, this))
			}
		}
	} // }}}
	prepare() { // {{{
		@operation.prepare()
		
		for variable in @variables {
			variable.prepare()
		}
	} // }}}
	translate() { // {{{
		@operation.translate()
		
		for variable in @variables {
			variable.translate()
		}
	} // }}}
	statement() => @parent.statement()
	toFragments(fragments) { // {{{
		let line = fragments.newLine()
		
		@operation.toFragments(line, Mode::Async)
		
		line.code('(__ks_e')
		
		for variable in @variables {
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
		_name
	}
	analyse() { // {{{
		if @data.name.kind == NodeKind::Identifier {
			if @scope.hasVariable(@data.name.name, false) {
				SyntaxException.throwAlreadyDeclared(@data.name.name, this)
			}
			
			if @options.format.variables == 'es5' {
				@scope.rename(@data.name.name)
			}
			
			if @scope.isDeclaredVariable(@data.name.name, false) {
				@declare = false
			}
		}
		
		const immutable = @parent.isImmutable()
		
		if @data.autotype || immutable {
			let type = @data.type
			
			if !type && @data.init {
				type = @data.init
			}
			
			variable = $variable.define(this, @scope, @data.name, immutable, $variable.kind(@data.type), type)
		}
		else {
			variable = $variable.define(this, @scope, @data.name, immutable, $variable.kind(@data.type), @data.type)
		}
		
		@name = $compile.expression(@data.name, this)
		
		@name.analyse()
		
		if @data.init? {
			if @data.name.kind == NodeKind::Identifier {
				this.reference(@data.name.name)
			}
			
			@init = $compile.expression(@data.init, this)
			
			@init.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @init != null {
			@init.prepare()
			
			@init.acquireReusable(false)
			@init.releaseReusable()
		}
	} // }}}
	translate() { // {{{
		if @init != null {
			@init.translate()
		}
	} // }}}
	statement() => @parent.statement()
	toFragments(fragments) { // {{{
		if @options.format.destructuring == 'es5' && (@name is ArrayBinding || @name is ObjectBinding) {
			if @init != null {
				let line = fragments.newLine()
			
				line.code(@parent.modifier(@data), $space) if @declare
				
				@name.toFlatFragments(line, @init)
				
				line.done()
			}
			else if @declare {
				fragments.line(@parent.modifier(@data), $space, @name.listVariables().join(', '))
			}
		}
		else {
			let line = fragments.newLine()
			
			line.code(@parent.modifier(@data), $space) if @declare
			
			line.compile(@name)
			
			if @init != null {
				line.code($equals).compile(@init)
			}
			
			line.done()
		}
	} // }}}
}