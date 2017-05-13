class ExpressionStatement extends Statement {
	private {
		_expression
		_variable			= ''
	}
	analyse() { // {{{
		@expression = $compile.expression(@data, this)
		
		@expression.analyse()
	} // }}}
	prepare()
	translate() { // {{{
		@expression.prepare()
		
		@expression.acquireReusable(false)
		@expression.releaseReusable()
		
		@expression.translate()
	} // }}}
	assignment(data, expression) { // {{{
		if data.left.kind == NodeKind::Identifier {
			let variable
			if variable ?= @scope.getVariable(data.left.name) {
				if variable.isImmutable() {
					SyntaxException.throwImmutable(data.left.name, this)
				}
			}
			else {
				if !expression.isAssignable() || @variable.length {
					@variables.push(data.left.name)
				}
				else {
					@variable = data.left.name
				}
				
				@scope.define(data.left.name, false, this)
			}
		}
	} // }}}
	hasExceptions() => @expression.hasExceptions()
	isAwait() => @expression.isAwait()
	toAwaitStatementFragments(fragments, statements) {
		const line = fragments.newLine()
		
		const item = @expression.toFragments(line, Mode::None)
		
		statements.unshift(this)
		
		item(statements)
		
		line.done()
	}
	toFragments(fragments, mode) { // {{{
		if @expression.isAwaiting() {
			return this.toAwaitStatementFragments^@(fragments)
		}
		else if @expression.isAssignable() {
			if @variables.length {
				fragments.newLine().code($runtime.scope(this) + @variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if @variable.length {
				line.code($runtime.scope(this))
			}
			
			if @expression.toAssignmentFragments? {
				@expression.toAssignmentFragments(line)
			}
			else {
				@expression.toFragments(line, Mode::None)
			}
			
			line.done()
		}
		else if @expression.toStatementFragments? {
			if @variable.length {
				@variables.unshift(@variable)
			}
			
			if @variables.length {
				fragments.newLine().code($runtime.scope(this) + @variables.join(', ')).done()
			}
			
			@expression.toStatementFragments(fragments, Mode::None)
		}
		else {
			if @variables.length {
				fragments.newLine().code($runtime.scope(this) + @variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if @variable.length {
				line.code($runtime.scope(this))
			}
			
			line.compile(@expression, Mode::None).done()
		}
		
		for afterward in @afterwards {
			afterward.toAfterwardFragments(fragments)
		}
	} // }}}
}