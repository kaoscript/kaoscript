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
			let variable
			for clause in @data.catchClauses {
				if variable !?= $variable.fromAST(clause.type, this) {
					ReferenceException.throwNotDefined(clause.type.name, this)
				}
				else if variable.kind != VariableKind::Class {
					TypeException.throwNotClass(clause.type.name, this)
				}
				
				if clause.binding? {
					$variable.define(this, @scope = new Scope(scope), clause.binding, VariableKind::Variable)
				}
				
				@catchClauses.push({
					body: $compile.expression(clause.body, this)
					type: $compile.expression(clause.type, this)
				})
			}
		}
		
		if @data.catchClause? {
			if @data.catchClause.binding? {
				$variable.define(this, @scope = new Scope(scope), @data.catchClause.binding, VariableKind::Variable)
			}
			
			@catchClause = $compile.expression(@data.catchClause.body, this)
		}
		
		@scope = scope
		
		@body = $compile.expression(@data.body, this)
		
		@finalizer = $compile.expression(@data.finalizer, this) if @data.finalizer?
	} // }}}
	fuse() { // {{{
		this._body.fuse()
		
		for clause in this._catchClauses {
			clause.body.fuse()
		}
		
		this._catchClause.fuse() if this._catchClause?
		this._finalizer.fuse() if this._finalizer?
	} // }}}
	isConsumedError(name, variable): Boolean { // {{{
		if @data.catchClauses.length > 0 {
			for clause in @data.catchClauses {
				return true if $error.isConsumed(clause.type.name, name, variable, @scope)
			}
			
			return false
		}
		
		return true
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let finalizer = null
		
		if this._finalizer? {
			finalizer = this._scope.acquireTempName()
			
			let line = fragments
				.newLine()
				.code($variable.scope(this), finalizer, ' = () =>')
			
			line
				.newBlock()
				.compile(this._finalizer)
				.done()
			
			line.done()
		}
		
		let ctrl = fragments
			.newControl()
			.code('try')
			.step()
			.compile(this._body)
		
		if finalizer? {
			ctrl.line(finalizer, '()')
		}
		
		ctrl.step()
		
		if this._catchClauses.length {
			this.module().flag('Type')
			
			let error = this._scope.acquireTempName()
			
			ctrl.code('catch(', error, ')').step()
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			let ifs = ctrl.newControl()
			
			for clause, i in this._data.catchClauses {
				ifs.step().code('else ') if i
				
				ifs
					.code('if(', $runtime.type(this), '.is(', error, ', ')
					.compile(this._catchClauses[i].type)
					.code(')')
					.step()
					
				if clause.binding? {
					ifs.line($variable.scope(this), clause.binding.name, ' = ', error)
				}
				
				ifs.compile(this._catchClauses[i].body)
			}
			
			if this._catchClause? {
				ifs.step().code('else').step()
				
				if this._data.catchClause.binding? {
					ifs.line($variable.scope(this), this._data.catchClause.binding.name, ' = ', error)
				}
				
				ifs.compile(this._catchClause)
			}
			
			ifs.done()
			
			this._scope.releaseTempName(error)
		}
		else if this._catchClause? {
			let error = this._scope.acquireTempName()
			
			if this._data.catchClause.binding? {
				ctrl.code('catch(', this._data.catchClause.binding.name, ')').step()
			}
			else {
				ctrl.code('catch(', error, ')').step()
			}
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			ctrl.compile(this._catchClause)
			
			this._scope.releaseTempName(error)
		}
		else {
			let error = this._scope.acquireTempName()
			
			ctrl.code('catch(', error, ')').step()
			
			if finalizer? {
				ctrl.line(finalizer, '()')
			}
			
			this._scope.releaseTempName(error)
		}
		
		ctrl.done()
	} // }}}
}