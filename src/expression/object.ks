class ObjectExpression extends Expression {
	private {
		_computed: Boolean		= false
		_names					= {}
		_properties				= []
		_reuseName: String		= null
		_type: Type
	}
	analyse() { // {{{
		let ref
		for property in @data.properties {
			if property.name.kind == NodeKind::Identifier || property.name.kind == NodeKind::Literal {
				property = new ObjectLiteralMember(property, this)
				property.analyse()

				if @names[property.reference()] == true {
					SyntaxException.throwDuplicateKey(property)
				}

				@names[property.reference()] = true
			}
			else {
				property = new ObjectComputedMember(property, this)
				property.analyse()

				@computed = true
			}

			@properties.push(property)
		}

		if @computed {
			@computed = this._options.format.properties == 'es5'
		}
	} // }}}
	prepare() { // {{{
		for property in @properties {
			property.prepare()
		}

		@type = @scope.reference('Object')
	} // }}}
	translate() { // {{{
		for property in @properties {
			property.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @computed {
			@reuseName = this.statement().scope().acquireTempName(this.statement())
		}

		for property in @properties {
			property.acquireReusable(acquire)
		}
	} // }}}
	isUsingVariable(name) { // {{{
		for property in @properties {
			if property.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	hasComputedProperties() => @computed
	reference() => @parent.reference()
	releaseReusable() { // {{{
		if @computed {
			this.statement().scope().releaseTempName(@reuseName)
		}

		for property in @properties {
			property.releaseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @computed {
			fragments.code('(', @reuseName, ' = {}', $comma)

			for property in @properties {
				property.toComputedFragments(fragments, @reuseName)
			}

			fragments.code(@reuseName, ')')
		}
		else {
			const object = fragments.newObject()

			for property in @properties {
				object.newLine().compile(property)
			}

			object.done()
		}
	} // }}}
	type() => @type
}

class ObjectLiteralMember extends Expression {
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
	acquireReusable(acquire) => @value.acquireReusable(acquire)
	isUsingVariable(name) => @value.isUsingVariable(name)
	releaseReusable() => @value.releaseReusable()
	toComputedFragments(fragments, name) { // {{{
		fragments
			.code(name)
			.code(@reference)
			.code($equals)
			.compile(@value)
			.code($comma)
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@name)

		if @data.value.kind != NodeKind::FunctionExpression {
			fragments.code(': ')
		}

		fragments.compile(@value)
	} // }}}
}

class ObjectComputedMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
		if @data.name.kind == NodeKind::ComputedPropertyName {
			@name = $compile.expression(@data.name.expression, this)
		}
		else {
			@name = new TemplateExpression(@data.name, this)
			@name.computing(true)
		}

		@name.analyse()

		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@name.prepare()
		@value.prepare()
	} // }}}
	translate() { // {{{
		@name.translate()
		@value.translate()
	} // }}}
	acquireReusable(acquire) { // {{{
		@name.acquireReusable(acquire)
		@value.acquireReusable(acquire)
	} // }}}
	isUsingVariable(name) => @name.isUsingVariable(name) || @value.isUsingVariable(name)
	releaseReusable() { // {{{
		@name.releaseReusable()
		@value.releaseReusable()
	} // }}}
	toComputedFragments(fragments, name) { // {{{
		fragments
			.code(name)
			.code('[')
			.compile(@name)
			.code(']')
			.code($equals)
			.compile(@value)
			.code($comma)
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.code('[')
			.compile(@name)
			.code(']')

		if @data.value.kind != NodeKind::FunctionExpression {
			fragments.code(': ')
		}

		fragments.compile(@value)
	} // }}}
}