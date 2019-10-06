class DictionaryExpression extends Expression {
	private {
		_empty: Boolean				= true
		_properties					= []
		_reusable: Boolean			= false
		_reuseName: String?			= null
		_spread: Boolean			= false
		_type: Type
		_varname: String			= 'd'
	}
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope, ScopeType::Hollow)
	} // }}}
	analyse() { // {{{
		if @options.format.functions == 'es5' && @scope.hasVariable('this') {
			@scope.rename('this', 'that')
		}

		const names = {}

		let ref
		for let property in @data.properties {
			if property.kind == NodeKind::UnaryExpression {
				property = new DictionarySpreadMember(property, this)
				property.analyse()

				@spread = true

				this.module().flag('Helper')
			}
			else if property.name.kind == NodeKind::Identifier || property.name.kind == NodeKind::Literal {
				property = new DictionaryLiteralMember(property, this)
				property.analyse()

				if names[property.reference()] {
					SyntaxException.throwDuplicateKey(property)
				}

				names[property.reference()] = true
			}
			else if property.name.kind == NodeKind::ThisExpression {
				property = new DictionaryThisMember(property, this)
				property.analyse()

				if names[property.reference()] {
					SyntaxException.throwDuplicateKey(property)
				}

				names[property.reference()] = true
			}
			else {
				property = new DictionaryComputedMember(property, this)
				property.analyse()
			}

			@properties.push(property)
		}

		@empty = @properties.length == 0
	} // }}}
	prepare() { // {{{
		for const property in @properties {
			property.prepare()
		}

		@type = @scope.reference('Dictionary')
	} // }}}
	translate() { // {{{
		for property in @properties {
			property.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}

		for const property in @properties {
			property.acquireReusable(acquire)
		}
	} // }}}
	isComputed() => true
	isMatchingType(type: Type) { // {{{
		if @properties.length == 0 {
			return type.isAny() || type.isDictionary()
		}
		else {
			return @type.matchContentOf(type)
		}
	} // }}}
	isSpread() => @spread
	isUsingVariable(name) { // {{{
		for const property in @properties {
			if property.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
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
		else if @empty {
			fragments.code('new ', $runtime.dictionary(this), '()')
		}
		else if @spread {
			fragments.code($runtime.helper(this), '.concatDictionary(')

			let opened = false

			for const property, index in @properties {
				if property is DictionarySpreadMember {
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
		else {
			if this.isUsingVariable('d') {
				if !this.isUsingVariable('o') {
					@varname = 'o'
				}
				else if !this.isUsingVariable('_') {
					@varname = '_'
				}
				else {
					@varname = '__ks__'
				}
			}

			let usingThis = false

			if @options.format.functions == 'es5' {
				if this.isUsingVariable('this') {
					usingThis = true

					fragments.code('(function(that)')
				}
				else {
					fragments.code('(function()')
				}
			}
			else {
				fragments.code('(() =>')
			}

			const block = fragments.newBlock()

			block.line($const(this), @varname, ' = new ', $runtime.dictionary(this), '()')

			for const property in @properties {
				block.newLine().compile(property).done()
			}

			block.line(`return \(@varname)`).done()

			if usingThis {
				fragments.code(`)(\(@scope.parent().getVariable('this').getSecureName()))`)
			}
			else {
				fragments.code(')()')
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} // }}}
	type() => @type
	varname() => @varname
}

class DictionaryLiteralMember extends Expression {
	private {
		_computed: Boolean		= true
		_function: Boolean		= false
		_shorthand: Boolean		= true
		_name
		_value
	}
	analyse() { // {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property)

		if @data.name.kind == NodeKind::Identifier	{
			@name = new Literal(@data.name, this, @scope:Scope, @data.name.name)

			this.reference('.' + @data.name.name)

			@computed = false
		}
		else {
			@name = new StringLiteral(@data.name, this)

			this.reference('[' + $quote(@data.name.value) + ']')
		}

		if @data.kind == NodeKind::ObjectMember {
			@value = $compile.expression(@data.value, this)

			@function = @data.value.kind == NodeKind::FunctionExpression

			@shorthand =
				@data.name.kind == NodeKind::Identifier &&
				@data.value.kind == NodeKind::Identifier &&
				@data.name.name == @data.value.name
		}
		else {
			@value = $compile.expression(@data.name, this)
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
	toFragments(fragments, mode) { // {{{
		if @parent.isSpread() {
			fragments.compile(@name)

			if !@shorthand || @value.isRenamed() {
				if !@function {
					fragments.code(': ')
				}

				fragments.compile(@value)
			}
		}
		else if @computed {
			fragments.code(@parent.varname(), '[').compile(@name).code(']', $equals).compile(@value)
		}
		else {
			fragments.code(@parent.varname(), '.').compile(@name).code($equals).compile(@value)
		}
	} // }}}
	value() => @value
}

class DictionaryComputedMember extends Expression {
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
		fragments.code(@parent.varname(), '[').compile(@name).code(']', $equals).compile(@value)
	} // }}}
	value() => @value
}

class DictionaryThisMember extends Expression {
	private {
		_name
		_value
	}
	analyse() { // {{{
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
	isUsingVariable(name) => @value.isUsingVariable(name)
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
	value() => @value
}

class DictionarySpreadMember extends Expression {
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
	isUsingVariable(name) => @value.isUsingVariable(name)
	toFragments(fragments, mode) { // {{{
		fragments.compile(@value)
	} // }}}
	value() => @value
}