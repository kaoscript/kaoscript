class CreateExpression extends Expression {
	private {
		_arguments	= []
		_class
		_list		= true
		_type		= Type.Any
	}
	analyse() { // {{{
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
		
		const type = @class.type()
		if type is ClassType {
			if type.isAbstract() {
				TypeException.throwCannotBeInstantiated(type.name(), this)
			}
			
			@type = type.reference()
		}
		
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
	isComputed() => true
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
	type() => @type
}