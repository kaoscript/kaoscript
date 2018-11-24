class ObjectExpression extends Expression {
	private {
		_properties				= {}
		_propertyCount			= 0
		_templates				= []
		_type: Type
	}
	analyse() { // {{{
		let ref
		for property in @data.properties {
			if property.name.kind == NodeKind::Identifier || property.name.kind == NodeKind::Literal {
				property = new ObjectMember(property, this)
				property.analyse()

				ref = property.reference()
				if @properties[ref]? {
					SyntaxException.throwDuplicateKey(property)
				}
				else {
					@properties[ref] = property
				}

				@propertyCount++
			}
			else {
				@templates.push(property = new ObjectTemplateMember(property, this))

				property.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		for :property of @properties {
			property.prepare()
		}

		for property in @templates {
			property.prepare()
		}

		@type = @scope.reference('Object')
	} // }}}
	translate() { // {{{
		for :property of @properties {
			property.translate()
		}

		for property in @templates {
			property.translate()
		}
	} // }}}
	isUsingVariable(name) { // {{{
		for :property of @properties {
			if property.isUsingVariable(name) {
				return true
			}
		}

		for property in @templates {
			if property.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	reference() => @parent.reference()
	toFragments(fragments, mode) { // {{{
		if @propertyCount == 0 {
			fragments.code('{}')
		}
		else {
			let object = fragments.newObject()

			for :property of @properties {
				object.newLine().compile(property)
			}

			object.done()
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
	isUsingVariable(name) => @value.isUsingVariable(name)
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
		@name.prepare()
		@value.prepare()
	} // }}}
	translate() { // {{{
		@name.translate()
		@value.translate()
	} // }}}
	isUsingVariable(name) => @name.isUsingVariable(name) || @value.isUsingVariable(name)
	toAfterwardFragments(fragments) { // {{{
		fragments
			.newLine()
			.code(@parent.reference(), '[')
			.compile(@name)
			.code('] = ')
			.compile(@value)
			.done()
	} // }}}
}