class CreateExpression extends Expression {
	private {
		_arguments	= []
		_class
		_list		= true
	}
	analyse() { // {{{
		if (variable ?= $variable.fromAST(@data.class, this)) && variable.abstract {
			TypeException.throwCannotBeInstantiated(variable.name.name, this)
		}
		
		@class = $compile.expression(@data.class, this)
		@class.analyse()
		
		for argument in @data.arguments {
			if argument.kind == NodeKind::UnaryExpression && argument.operator.kind == UnaryOperatorKind::Spread {
				@arguments.push(argument = $compile.expression(argument.argument, this))
				
				@list = false
			}
			else {
				@arguments.push(argument = $compile.expression(argument, this))
			}
			
			argument.analyse()
		}
	} // }}}
	prepare() { // {{{
		@class.prepare()
		
		for argument in @arguments {
			argument.prepare()
		}
	} // }}}
	translate() { // {{{
		@class.translate()
		
		for argument in @arguments {
			argument.translate()
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
			throw new NotImplementedException(this)
		}
	} // }}}
	type() => Type.Any
}