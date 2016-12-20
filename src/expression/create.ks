class CreateExpression extends Expression {
	private {
		_arguments	= []
		_class
		_list		= true
	}
	analyse() { // {{{
		this._class = $compile.expression(this._data.class, this)
		
		for argument in this._data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				this._arguments.push($compile.expression(argument.argument, this))
				
				this._list = false
			}
			else {
				this._arguments.push($compile.expression(argument, this))
			}
		}
	} // }}}
	fuse() { // {{{
		this._class.fuse()
		
		for argument in this._arguments {
			argument.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._list {
			fragments.code('new ').compile(this._class).code('(')
			
			for i from 0 til this._arguments.length {
				fragments.code($comma) if i != 0
				
				fragments.compile(this._arguments[i])
			}
			
			fragments.code(')')
		}
		else {
			$throw('Not Implemted')
		}
	} // }}}
}