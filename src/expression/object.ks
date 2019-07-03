class ObjectExpression extends Expression {
	private {
		_computed: Boolean		= false
		_names					= {}
		_properties				= []
		_reusable: Boolean		= false
		_reuseName: String?		= null
		_spread: Boolean		= false
		_type: Type
	}
	analyse() { // {{{
		let ref
		for let property in @data.properties {
			if property.kind == NodeKind::UnaryExpression {
				property = new ObjectSpreadMember(property, this)
				property.analyse()

				@spread = true

				this.module().flag('Helper')
			}
			else if property.name.kind == NodeKind::Identifier || property.name.kind == NodeKind::Literal {
				property = new ObjectLiteralMember(property, this)
				property.analyse()

				if @names[property.reference()] == true {
					SyntaxException.throwDuplicateKey(property)
				}

				@names[property.reference()] = true
			}
			else if property.name.kind == NodeKind::ThisExpression {
				property = new ObjectThisMember(property, this)
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
			@computed = @options.format.properties == 'es5'
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
		if acquire || @computed {
			@reuseName = @scope.acquireTempName()
		}

		for const property in @properties {
			property.acquireReusable(acquire)
		}
	} // }}}
	isComputed() => true
	isUsingVariable(name) { // {{{
		for const property in @properties {
			if property.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	hasComputedProperties() => @computed
	reference() => @parent.reference()
	releaseReusable() { // {{{
		if @reuseName != null {
			@scope.releaseTempName(@reuseName)
		}

		for property in @properties {
			property.releaseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @spread {
			fragments.code($runtime.helper(this), '.concatObject(')
			let opened = false

			for const property, index in @properties {
				if property is ObjectSpreadMember {
					if opened {
						fragments.code('}, ')

						opened = false
					}
					else if index != 0 {
						fragments.code($comma)
					}

					fragments.compile(property)
				}
				else {
					if index != 0 {
						fragments.code($comma)
					}

					if !opened {
						fragments.code('{')

						opened = true
					}

					fragments.compile(property)
				}
			}

			if opened {
				fragments.code('}')
			}

			fragments.code(')')
		}
		else if @computed {
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
	toReusableFragments(fragments) { // {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} // }}}
	type() => @type
}

class ObjectLiteralMember extends Expression {
	private {
		_function: Boolean	= false
		_shorthand: Boolean	= false
		_name
		_value
	}
	analyse() { // {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property)

		if @data.name.kind == NodeKind::Identifier	{
			@name = new Literal(@data.name, this, @scope:Scope, @data.name.name)

			this.reference('.' + @data.name.name)
		}
		else {
			@name = new StringLiteral(@data.name, this)

			this.reference('[' + $quote(@data.name.value) + ']')
		}

		if @data.kind == NodeKind::ObjectMember {
			@value = $compile.expression(@data.value, this)

			@function = @data.value.kind == NodeKind::FunctionExpression

			@shorthand =
				@options.format.properties != 'es5' &&
				@data.name.kind == NodeKind::Identifier &&
				@data.value.kind == NodeKind::Identifier &&
				@data.name.name == @data.value.name
		}
		else {
			@value = $compile.expression(@data.name, this)

			@shorthand = @options.format.properties != 'es5'
		}

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

		if !@shorthand || @value.isRenamed() {
			if !@function {
				fragments.code(': ')
			}

			fragments.compile(@value)
		}
	} // }}}
}

class ObjectComputedMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property)

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

class ObjectThisMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property)

		@name = new Literal(@data.name.name, this, @scope:Scope, @data.name.name.name)

		@value = $compile.expression(@data.name, this)
		@value.analyse()

		this.reference(`.\(@name.value())`)
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	toComputedFragments(fragments, name) { // {{{
		fragments
			.code(name)
			.code(@reference)
			.code($equals)
			.compile(@value)
			.code($comma)
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.compile(@name)
			.code(': ')
			.compile(@value)
	} // }}}
}

class ObjectSpreadMember extends Expression {
	private {
		_value
	}
	analyse() { // {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property)

		@value = $compile.expression(@data.argument, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	isUsingVariable(name) => false
	toFragments(fragments, mode) { // {{{
		fragments.compile(@value)
	} // }}}
}