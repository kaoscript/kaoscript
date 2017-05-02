/* class VariableDeclaration extends Statement {
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
				@scope._parent.define(variable.name.name, immutable, Type.fromAST(variable.type, this), this)
				
				@variables.push($compile.expression(variable.name, this))
			}
			else {
				@scope._parent.define(variable.name, immutable, this)
				
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
		_autotype: Boolean
		_declare: Boolean		= true
		_hasVariable: Boolean	= false
		_init					= null
		_name
		_variable: Variable
	}
	analyse() { // {{{
		if @data.name.kind == NodeKind::Identifier {
			if @scope.hasLocalVariable(@data.name.name) {
				SyntaxException.throwAlreadyDeclared(@data.name.name, this)
			}
			
			if @options.format.variables == 'es5' {
				@scope.rename(@data.name.name)
			}
			
			if @scope.hasDeclaredLocalVariable(@data.name.name) {
				@declare = false
			}
		}
		
		const immutable = @parent.isImmutable()
		
		if @data.name.kind == NodeKind::Identifier {
			@variable = @scope.define(@data.name.name, immutable, Type.fromAST(@data.type, this), this)
			@hasVariable = true
		}
		
		@name = $compile.expression(@data.name, this)
		@name.analyse()
		
		@autotype = @hasVariable && (@data.autotype || immutable)
		
		if @data.init? {
			if @hasVariable {
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
			
			if @autotype {
				@variable.type(@init.type())
			}
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
} */
class VariableDeclaration extends Statement {
	private {
		_autotype: Boolean
		_await: Boolean
		_declarators: Array		= []
		_hasInit: Boolean		= false
		_immutable: Boolean
		_init
		_toDeclareAll: Boolean	= true
	}
	analyse() { // {{{
		@immutable = !@data.rebindable
		@autotype = @immutable || @data.autotype
		@await = @data.await
		
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
		
		if @data.init? {
			@hasInit = true
			
			if @declarators.length == 1 && @declarators[0] is VariableIdentifierDeclarator {
				this.reference(@declarators[0].name())
			}
			
			@init = $compile.expression(@data.init, this)
			@init.analyse()
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
	hasInit() => @hasInit
	init() => @init
	isAwait() => @await
	isImmutable() => @immutable
	toStatementFragments(fragments, mode) { // {{{
		if @await {
			throw new NotImplementedException()
		}
		else {
			/* if @toDeclareAll || @options.format.variables == 'es5' {
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
				
				if @hasInit {
					line.code($equals).compile(@init)
				}
				
				line.done()
			}
			else if @hasInit {
				fragments
					.newLine()
					.compile(@declarators[0])
					.code($equals)
					.compile(@init)
					.done()
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
			} */
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
	isAlreadyDeclared() => false
	toFlatFragments(fragments, init) {
		@binding.toFlatFragments(fragments, init)
	}
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
		_name
		_variable: Variable
	}
	analyse() { // {{{
		const name = @data.name.name
		
		if @scope.hasLocalVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, this)
		}
		
		if @options.format.variables == 'es5' {
			@scope.rename(name)
		}
		
		if @scope.hasDeclaredLocalVariable(name) {
			@alreadyDeclared = true
		}
		
		@variable = @scope.define(name, @parent.isImmutable(), Type.fromAST(@data.type, this), this)
		
		@name = new IdentifierLiteral(@data.name, this)
		@name.analyse()
	} // }}}
	prepare() { // {{{
		@name.prepare()
	} // }}}
	translate() { // {{{
		@name.translate()
	} // }}}
	isAlreadyDeclared() => @alreadyDeclared
	toFragments(fragments, mode) { // {{{
		fragments.compile(@name)
	} // }}}
	name() => @variable.name()
	type(type: Type) { // {{{
		@variable.type(type)
	} // }}}
	walk(fn) { // {{{
		fn(@variable.name(), @variable.type())
	} // }}}
}