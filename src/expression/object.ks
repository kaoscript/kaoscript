class ObjectExpression extends Expression {
	private {
		_computed: Boolean		= false
		_properties				= {}
		_reuseName: String		= null
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
			}
			else {
				@templates.push(property = new ObjectTemplateMember(property, this))

				property.analyse()
			}
		}

		@computed = @templates.length != 0 && this._options.format.properties == 'es5'
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
	acquireReusable(acquire) { // {{{
		if @computed {
			@reuseName = this.statement().scope().acquireTempName(this.statement())
		}

		for :property of @properties {
			property.acquireReusable(acquire)
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
	hasComputedProperties() => @computed
	reference() => @parent.reference()
	releaseReusable() { // {{{
		if @computed {
			this.statement().scope().releaseTempName(@reuseName)
		}

		for :property of @properties {
			property.releaseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @computed {
			fragments.code('(', @reuseName, ' = {}', $comma)

			for :property of @properties {
				fragments
					.code(@reuseName)
					.code(property.reference())
					.code($equals)
					.compile(property.value())
					.code($comma)
			}

			for template in @templates {
				fragments
					.code(@reuseName)
					.code('[')
					.compile(template.name())
					.code(']')
					.code($equals)
					.compile(template.value())
					.code($comma)
			}

			fragments.code(@reuseName, ')')
		}
		else {
			const object = fragments.newObject()

			for :property of @properties {
				object.newLine().compile(property)
			}

			for template in @templates {
				object.newLine().compile(template)
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
	acquireReusable(acquire) => @value.acquireReusable(acquire)
	name() => @name.value()
	isUsingVariable(name) => @value.isUsingVariable(name)
	releaseReusable() => @value.releaseReusable()
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
	} // }}}
	prepare() { // {{{
		@name.prepare()
		@value.prepare()
	} // }}}
	translate() { // {{{
		@name.translate()
		@value.translate()
	} // }}}
	name() => @name
	isUsingVariable(name) => @name.isUsingVariable(name) || @value.isUsingVariable(name)
	value() => @value
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