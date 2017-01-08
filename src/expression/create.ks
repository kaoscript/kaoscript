class CreateExpression extends Expression {
	private {
		_arguments	= []
		_class
		_list		= true
	}
	analyse() { // {{{
		if (variable ?= $variable.fromAST(@data.class, this)) && variable.abstract {
			$throw(`Can't instantiate class at line \(@data.start.line)`, this)
		}
		
		@class = $compile.expression(@data.class, this)
		
		for argument in @data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				@arguments.push($compile.expression(argument.argument, this))
				
				@list = false
			}
			else {
				@arguments.push($compile.expression(argument, this))
			}
		}
	} // }}}
	fuse() { // {{{
		@class.fuse()
		
		for argument in @arguments {
			argument.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @list {
			fragments.code('new ').compile(@class).code('(')
			
			for i from 0 til @arguments.length {
				fragments.code($comma) if i != 0
				
				fragments.compile(@arguments[i])
			}
			
			fragments.code(')')
		}
		else {
			$throw('Not Implemted')
		}
	} // }}}
}