class TryStatement extends Statement {
	private {
		_body
		_catchClause
		_catchClauses = []
		_finalizer
	}
	analyse() { // {{{
		let scope = @scope
		
		if @data.catchClauses? {
			let variable, body, type
			for clause in @data.catchClauses {
				if variable !?= scope.getVariable(clause.type.name) {
					ReferenceException.throwNotDefined(clause.type.name, this)
				}
				else if variable.type() is not ClassType {
					TypeException.throwNotClass(clause.type.name, this)
				}
				
				if clause.binding? {
					@scope = new Scope(scope)
					
					@scope.define(clause.binding.name, false, this)
				}
				
				body = $compile.expression(clause.body, this)
				body.analyse()
				
				type = $compile.expression(clause.type, this)
				type.analyse()
				
				@catchClauses.push({
					body: body
					type: type
				})
			}
		}
		
		if @data.catchClause? {
			if @data.catchClause.binding? {
				@scope = new Scope(scope)
				@scope.define(@data.catchClause.binding.name, false, this)
			}
			
			@catchClause = $compile.expression(@data.catchClause.body, this)
			@catchClause.analyse()
		}
		
		@scope = scope
		
		@body = $compile.expression(@data.body, this)
		@body.analyse()
		
		if @data.finalizer? {
			@finalizer = $compile.expression(@data.finalizer, this)
			@finalizer.analyse()
		}
	} // }}}
	prepare() { // {{{
		@body.prepare()
		
		for clause in @catchClauses {
			clause.body.prepare()
			clause.type.prepare()
		}
		
		@catchClause.prepare() if @catchClause?
		@finalizer.prepare() if @finalizer?
	} // }}}
	translate() { // {{{
		@body.translate()
		
		for clause in @catchClauses {
			clause.body.translate()
			clause.type.translate()
		}
		
		@catchClause.translate() if @catchClause?
		@finalizer.translate() if @finalizer?
	} // }}}
	isConsumedError(error): Boolean { // {{{
		if @catchClauses.length > 0 {
			for clause in @catchClauses {
				if clause.type.type().match(error) {
					return true
				}
			}
			
			return false
		}
		else {
			return true
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let finalizer = null
		
		if @finalizer? {
			finalizer = @scope.acquireTempName()
			
			let line = fragments
				.newLine()
				.code($runtime.scope(this), finalizer, ' = () =>')
			
			line
				.newBlock()
				.compile(@finalizer)
				.done()
			
			line.done()
		}
		
		let ctrl = fragments
			.newControl()
			.code('try')
			.step()
			.compile(@body)
		
		if finalizer? {
			ctrl.line(finalizer, '()')
		}
		
		ctrl.step()
		
		if @catchClauses.length {
			this.module().flag('Type')
			
			let error = @scope.acquireTempName()
			
			ctrl.code('catch(', error, ')').step()
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			let ifs = ctrl.newControl()
			
			for clause, i in @data.catchClauses {
				ifs.step().code('else ') if i
				
				ifs
					.code('if(', $runtime.type(this), '.is(', error, ', ')
					.compile(@catchClauses[i].type)
					.code(')')
					.step()
					
				if clause.binding? {
					ifs.line($runtime.scope(this), clause.binding.name, ' = ', error)
				}
				
				ifs.compile(@catchClauses[i].body)
			}
			
			if @catchClause? {
				ifs.step().code('else').step()
				
				if @data.catchClause.binding? {
					ifs.line($runtime.scope(this), @data.catchClause.binding.name, ' = ', error)
				}
				
				ifs.compile(@catchClause)
			}
			
			ifs.done()
			
			@scope.releaseTempName(error)
		}
		else if @catchClause? {
			let error = @scope.acquireTempName()
			
			if @data.catchClause.binding? {
				ctrl.code('catch(', @data.catchClause.binding.name, ')').step()
			}
			else {
				ctrl.code('catch(', error, ')').step()
			}
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			ctrl.compile(@catchClause)
			
			@scope.releaseTempName(error)
		}
		else {
			let error = @scope.acquireTempName()
			
			ctrl.code('catch(', error, ')').step()
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			@scope.releaseTempName(error)
		}
		
		ctrl.done()
	} // }}}
}