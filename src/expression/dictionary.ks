class DictionaryExpression extends Expression {
	private late {
		@empty: Boolean				= true
		@properties					= []
		@reusable: Boolean			= false
		@reuseName: String?			= null
		@spread: Boolean			= false
		@type: Type
		@varname: String			= 'd'
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope, ScopeType::Hollow)
	} # }}}
	analyse() { # {{{
		var names = {}

		for var data in @data.properties {
			var late property

			if data.kind == NodeKind::UnaryExpression {
				property = new DictionarySpreadMember(data, this)
				property.analyse()

				@spread = true

				@module().flag('Helper')
			}
			else if data.name.kind == NodeKind::Identifier || data.name.kind == NodeKind::Literal {
				property = new DictionaryLiteralMember(data, this)
				property.analyse()

				if names[property.reference()] {
					SyntaxException.throwDuplicateKey(property)
				}

				names[property.reference()] = true
			}
			else if data.name.kind == NodeKind::ThisExpression {
				property = new DictionaryThisMember(data, this)
				property.analyse()

				if names[property.reference()] {
					SyntaxException.throwDuplicateKey(property)
				}

				names[property.reference()] = true
			}
			else {
				property = new DictionaryComputedMember(data, this)
				property.analyse()
			}

			@properties.push(property)
		}

		if @options.format.functions == 'es5' && !@spread && @scope.hasVariable('this') {
			@scope.rename('this', 'that')
		}

		@empty = @properties.length == 0
	} # }}}
	override prepare(target) { # {{{
		var subtarget = target.isDictionary() ? target.parameter() : AnyType.NullableUnexplicit

		@type = new DictionaryType(@scope)

		if #@properties {
			for var property in @properties {
				property.prepare(subtarget)

				if property is DictionaryLiteralMember {
					@type.addProperty(property.name(), property.type())
				}
			}
		}
		else {
			@type.flagEmpty()
		}

		@type.flagComplete()
	} # }}}
	translate() { # {{{
		for property in @properties {
			property.translate()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}

		for var property in @properties {
			property.acquireReusable(acquire)
		}
	} # }}}
	isComputed() => true
	isMatchingType(type: Type) { # {{{
		if @properties.length == 0 {
			return type.isAny() || type.isDictionary()
		}
		else {
			return @type.matchContentOf(type)
		}
	} # }}}
	isNotEmpty() => @properties.length > 0
	isSpread() => @spread
	isUsingVariable(name) { # {{{
		for var property in @properties {
			if property.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		for var property in @properties {
			property.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	reference() => @parent.reference()
	releaseReusable() { # {{{
		if @reuseName != null {
			@scope.releaseTempName(@reuseName)
		}

		for property in @properties {
			property.releaseReusable()
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @empty {
			fragments.code('new ', $runtime.dictionary(this), '()')
		}
		else if @spread {
			fragments.code($runtime.helper(this), '.newDictionary(')

			var mut first = true
			var mut spread = false
			var mut arguments = []

			for var property, index in @properties {
				if property is DictionarySpreadMember {
					if !spread {
						if arguments.length > 0 {
							if first {
								first = false
							}
							else {
								fragments.code($comma)
							}

							fragments.code(`\(arguments.length / 2)`)

							for var i from 0 til arguments.length by 2 {
								if arguments[i] is String {
									fragments.code(`, "\(arguments[i])", `)
								}
								else {
									fragments.code($comma).compile(arguments[i]).code($comma)
								}

								fragments.compile(arguments[i + 1])
							}
						}

						spread = true
						arguments.clear()
					}

					arguments.push(property)
				}
				else {
					if spread {
						if arguments.length > 0 {
							if first {
								first = false
							}
							else {
								fragments.code($comma)
							}

							fragments.code(`-\(arguments.length)`)

							for var argument in arguments {
								fragments.code($comma).compile(argument)
							}
						}

						spread = false
						arguments.clear()
					}

					arguments.push(property.name(), property.value())
				}
			}

			if arguments.length > 0 {
				fragments.code($comma) unless first

				if spread {
					fragments.code(`-\(arguments.length)`)

					for var argument in arguments {
						fragments.code($comma).compile(argument)
					}
				}
				else {
					fragments.code(`\(arguments.length / 2)`)

					for var i from 0 til arguments.length by 2 {
						if arguments[i] is String {
							fragments.code(`, "\(arguments[i])", `)
						}
						else {
							fragments.code($comma).compile(arguments[i]).code($comma)
						}

						fragments.compile(arguments[i + 1])
					}
				}
			}

			fragments.code(')')
		}
		else {
			if @isUsingVariable('d') {
				if !@isUsingVariable('o') {
					@varname = 'o'
				}
				else if !@isUsingVariable('_') {
					@varname = '_'
				}
				else {
					@varname = '__ks__'
				}
			}

			var mut usingThis = false

			if @options.format.functions == 'es5' {
				if @isUsingVariable('this') {
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

			var block = fragments.newBlock()

			block.line($const(this), @varname, ' = new ', $runtime.dictionary(this), '()')

			for var property in @properties {
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
	} # }}}
	toReusableFragments(fragments) { # {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} # }}}
	type() => @type
	validateType(type: DictionaryType) { # {{{
		for var property in @properties {
			if property is DictionaryLiteralMember {
				if var propertyType ?= type.getProperty(property.name()) {
					property.validateType(propertyType)
				}
			}
		}
	} # }}}
	validateType(type: ReferenceType) { # {{{
		if type.hasParameters() {
			var parameter = type.parameter(0)

			for var property in @properties {
				if property is DictionaryLiteralMember {
					property.validateType(parameter)
				}
			}
		}
	} # }}}
	varname() => @varname
}

class DictionaryLiteralMember extends Expression {
	private late {
		@computed: Boolean		= true
		@enumCasting: Boolean	= false
		@function: Boolean		= false
		@shorthand: Boolean		= true
		@name
		@value
		@type: Type
	}
	analyse() { # {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property, @file())

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
	} # }}}
	override prepare(target) { # {{{
		@value.prepare(target)

		@type = @value.type().asReference()

		if @type.isNull() {
			@type = AnyType.NullableUnexplicit
		}
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	acquireReusable(acquire) => @value.acquireReusable(acquire)
	isUsingVariable(name) => @value.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
	name() => @name.value()
	releaseReusable() => @value.releaseReusable()
	toFragments(fragments, mode) { # {{{
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
	} # }}}
	type() => @type
	validateType(type: Type) { # {{{
		if @type.isEnum() && !type.isEnum() {
			@enumCasting = true
		}
	} # }}}
	value() => @value
}

class DictionaryComputedMember extends Expression {
	private {
		@name
		@value
	}
	analyse() { # {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property, @file())

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
	} # }}}
	override prepare(target) { # {{{
		@name.prepare()
		@value.prepare(target)
	} # }}}
	translate() { # {{{
		@name.translate()
		@value.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		@name.acquireReusable(acquire)
		@value.acquireReusable(acquire)
	} # }}}
	isUsingVariable(name) => @name.isUsingVariable(name) || @value.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@name.listNonLocalVariables(scope, variables)
		@value.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	name() => @name
	releaseReusable() { # {{{
		@name.releaseReusable()
		@value.releaseReusable()
	} # }}}
	toComputedFragments(fragments, name) { # {{{
		fragments
			.code(name)
			.code('[')
			.compile(@name)
			.code(']')
			.code($equals)
			.compile(@value)
			.code($comma)
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.code(@parent.varname(), '[').compile(@name).code(']', $equals).compile(@value)
	} # }}}
	value() => @value
}

class DictionaryThisMember extends Expression {
	private {
		@name
		@value
	}
	analyse() { # {{{
		@name = new Literal(@data.name.name, this, @scope:Scope, @data.name.name.name)

		@value = $compile.expression(@data.name, this)
		@value.analyse()

		this.reference(`.\(@name.value())`)
	} # }}}
	override prepare(target) { # {{{
		@value.prepare(target)
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	isUsingVariable(name) => @value.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
	name() => @name.value()
	toComputedFragments(fragments, name) { # {{{
		fragments
			.code(name)
			.code(@reference)
			.code($equals)
			.compile(@value)
			.code($comma)
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.compile(@name)
			.code(': ')
			.compile(@value)
	} # }}}
	value() => @value
}

class DictionarySpreadMember extends Expression {
	private {
		@value
	}
	analyse() { # {{{
		@options = Attribute.configure(@data, @options, AttributeTarget::Property, @file())

		@value = $compile.expression(@data.argument, this)
		@value.analyse()
	} # }}}
	override prepare(target) { # {{{
		@value.prepare(target)
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	isUsingVariable(name) => @value.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
	toFragments(fragments, mode) { # {{{
		fragments.compile(@value)
	} # }}}
	value() => @value
}
