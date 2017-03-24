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
				if variable.immutable {
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
				
				$variable.define(this, @scope, data.left, false, $variable.kind(data.right.type), data.right.type)
			}
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @expression.isAssignable() {
			if @variables.length {
				fragments.newLine().code($variable.scope(this) + @variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if @variable.length {
				line.code($variable.scope(this))
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
				fragments.newLine().code($variable.scope(this) + @variables.join(', ')).done()
			}
			
			@expression.toStatementFragments(fragments, Mode::None)
		}
		else {
			if @variables.length {
				fragments.newLine().code($variable.scope(this) + @variables.join(', ')).done()
			}
			
			let line = fragments.newLine()
			
			if @variable.length {
				line.code($variable.scope(this))
			}
			
			line.compile(@expression, Mode::None).done()
		}
		
		for afterward in @afterwards {
			afterward.toAfterwardFragments(fragments)
		}
	} // }}}
}