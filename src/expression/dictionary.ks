class DictionaryExpression extends Expression {
	private lateinit {
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

		if @options.format.functions == 'es5' && !@spread && @scope.hasVariable('this') {
			@scope.rename('this', 'that')
		}

		@empty = @properties.length == 0
	} // }}}
	prepare() { // {{{
		@type = new DictionaryType(@scope)

		for const property in @properties {
			property.prepare()

			if property is DictionaryLiteralMember {
				@type.addProperty(property.name(), property.type())
			}
		}
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
	override listNonLocalVariables(scope, variables) { // {{{
		for const property in @properties {
			property.listNonLocalVariables(scope, variables)
		}

		return variables
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
	validateType(type: DictionaryType) { // {{{
		for const property in @properties {
			if property is DictionaryLiteralMember {
				if const propertyType = type.getProperty(property.name()) {
					property.validateType(propertyType)
				}
			}
		}
	} // }}}
	validateType(type: ReferenceType) { // {{{
		if type.hasParameters() {
			const parameter = type.parameter(0)

			for const property in @properties {
				if property is DictionaryLiteralMember {
					property.validateType(parameter)
				}
			}
		}
	} // }}}
	varname() => @varname
}

class DictionaryLiteralMember extends Expression {
	private lateinit {
		_computed: Boolean		= true
		_enumCasting: Boolean	= false
		_function: Boolean		= false
		_shorthand: Boolean		= true
		_name
		_value
		_type: Type
	}
	analyse() { // {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property, this.file())

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

		@type = @value.type()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	acquireReusable(acquire) => @value.acquireReusable(acquire)
	isUsingVariable(name) => @value.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
	name() => @name.value()
	releaseReusable() => @value.releaseReusable()
	toFragments(fragments, mode) { // {{{
		if @parent.isSpread() {
			fragments.compile(@name)

			if !@shorthand || @value.isRenamed() {
				if !@function {
					fragments.code(': ')
				}
			}
		}
		else if @computed {
			fragments.code(@parent.varname(), '[').compile(@name).code(']', $equals)
		}
		else {
			fragments.code(@parent.varname(), '.').compile(@name).code($equals)
		}

		if @enumCasting {
			@value.toCastingFragments(fragments, mode)
		}
		else {
			fragments.compile(@value)
		}
	} // }}}
	type() => @type
	validateType(type: Type) { // {{{
		if @type.isEnum() && !type.isEnum() {
			@enumCasting = true
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
		@options = Attribute.configure(@data, @options, AttributeTarget::Property, this.file())

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
	override listNonLocalVariables(scope, variables) { // {{{
		@name.listNonLocalVariables(scope, variables)
		@value.listNonLocalVariables(scope, variables)

		return variables
	} // }}}
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
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
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
		@options = Attribute.configure(@data, @options, AttributeTarget::Property, this.file())

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
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
	toFragments(fragments, mode) { // {{{
		fragments.compile(@value)
	} // }}}
	value() => @value
}
