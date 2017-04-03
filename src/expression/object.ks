class ObjectExpression extends Expression {
	private {
		_properties		= []
		_templates		= []
		_type: Type
	}
	analyse() { // {{{
		for property in @data.properties {
			if property.name.kind == NodeKind::Identifier || property.name.kind == NodeKind::Literal {
				@properties.push(property = new ObjectMember(property, this))
			}
			else {
				@templates.push(property = new ObjectTemplateMember(property, this))
			}
			
			property.analyse()
		}
	} // }}}
	prepare() { // {{{
		for property in @properties {
			property.prepare()
		}
		
		for property in @templates {
			property.prepare()
		}
		
		@type = new ObjectType(@properties, new ScopeDomain(@scope))
		/* @type = @scope.reference('Object') */
	} // }}}
	translate() { // {{{
		for property in @properties {
			property.translate()
		}
		
		for property in @templates {
			property.translate()
		}
	} // }}}
	reference() => @parent.reference()
	toFragments(fragments, mode) { // {{{
		if @properties.length {
			let object = fragments.newObject()
			
			for property in @properties {
				object.newLine().compile(property)
			}
			
			object.done()
		}
		else {
			fragments.code('{}')
		}
	} // }}}
	type() => @type
}

class ObjectMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
		if @data.name.kind == NodeKind::Identifier	{
			@name = new Literal(@data.name, this, @scope, @data.name.name)
			
			this.reference('.' + @data.name.name)
		}
		else {
			@name = new StringLiteral(@data.name, this)
			
			this.reference('[' + $quote(@data.name.value) + ']')
		}
		
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	name() => @name.value()
	value() => @value
	toFragments(fragments, mode) { // {{{
		fragments.compile(@name)
		
		if @data.value.kind != NodeKind::FunctionExpression {
			fragments.code(': ')
		}
		
		fragments.compile(@value)
	} // }}}
}

class ObjectTemplateMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
		@name = new TemplateExpression(@data.name, this)
		@name.computing(true)
		@name.analyse()
		
		@value = $compile.expression(@data.value, this)
		@value.analyse()
		
		this.statement().afterward(this)
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		fragments
			.newLine()
			.code(this.parent().reference(), '[')
			.compile(@name)
			.code('] = ')
			.compile(@value)
			.done()
	} // }}}
}