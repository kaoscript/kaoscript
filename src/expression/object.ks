class ObjectExpression extends Expression {
	private late {
		@empty: Boolean				= true
		@properties					= []
		@reusable: Boolean			= false
		@reuseName: String?			= null
		@type: Type
		@varname: String			= 'o'
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope, ScopeType.Hollow)
	} # }}}
	analyse() { # {{{
		var names = {}

		for var data in @data.properties {
			var late property

			match data.kind {
				NodeKind.ObjectMember {
					match data.name.kind {
						NodeKind.Identifier, NodeKind.Literal {
							property = ObjectLiteralMember.new(data, this)
							property.analyse()

							if names[property.reference()] {
								SyntaxException.throwDuplicateKey(property)
							}

							names[property.reference()] = true
						}
						NodeKind.ThisExpression {
							property = ObjectThisMember.new(data, this)
							property.analyse()

							if names[property.reference()] {
								SyntaxException.throwDuplicateKey(property)
							}

							names[property.reference()] = true
						}
						else {
							property = ObjectComputedMember.new(data, this)
							property.analyse()
						}
					}
				}
				NodeKind.RestrictiveExpression {
					property = ObjectRestrictiveMember.new(data, this)
					property.analyse()

					if var reference ?= property.reference() {
						if names[reference] {
							SyntaxException.throwDuplicateKey(property)
						}

						names[reference] = true
					}
				}
				NodeKind.ShorthandProperty {
					match data.name.kind {
						NodeKind.Identifier {
							property = ObjectLiteralMember.new(data, this)
							property.analyse()

							if names[property.reference()] {
								SyntaxException.throwDuplicateKey(property)
							}

							names[property.reference()] = true
						}
						NodeKind.ThisExpression {
							property = ObjectThisMember.new(data, this)
							property.analyse()

							if names[property.reference()] {
								SyntaxException.throwDuplicateKey(property)
							}

							names[property.reference()] = true
						}
						else {
							NotSupportedException.throw(this)
						}
					}
				}
				NodeKind.UnaryExpression {
					property = ObjectSpreadMember.new(data, this)
					property.analyse()
				}
				else {
					NotSupportedException.throw(this)
				}
			}

			@properties.push(property)
		}

		@empty = @properties.length == 0
	} # }}}
	override prepare(mut target, targetMode) { # {{{
		while target.isAlias() {
			target = target.discardAlias()
		}

		@type = ObjectType.new(@scope)

		if #@properties {
			if target is ObjectType {
				var type = target.getRestType()
				var rest: Type[] = []

				for var property in @properties {
					if property is ObjectComputedMember {
						if target.length() > 0 {
							property.prepare(AnyType.NullableUnexplicit)
						}
						else {
							property.prepare(type)
						}
					}
					else if property is ObjectLiteralMember {
						property.prepare(target.getProperty(property.name()))

						@type.addProperty(property.name(), property.type())
					}
					else if property is ObjectSpreadMember {
						property.prepare(type)

						var type = property.value().type().discard()

						if type.isObject() && !type.hasRest() {
							for var property, name of type.properties() {
								if !@type.hasProperty(name) {
									@type.addProperty(name, property.type())
								}
							}
						}
						else {
							rest.push(property.type())
						}
					}
					else if property is ObjectThisMember {
						property.prepare(target.getProperty(property.name()))

						@type.addProperty(property.name(), property.type())
					}
				}

				if #rest {
					@type.setRestType(Type.union(@scope, ...rest))
				}
			}
			else {
				var type = target.isReference() ? target.parameter() : AnyType.NullableUnexplicit
				var rest: Type[] = []

				for var property in @properties {
					property.prepare(type)

					if property is ObjectLiteralMember {
						@type.addProperty(property.name(), property.type())
					}
					else if property is ObjectSpreadMember {
						rest.push(property.type())
					}
					else if property is ObjectThisMember {
						@type.addProperty(property.name(), property.type())
					}
				}

				if #rest {
					@type.setRestType(Type.union(@scope, ...rest))
				}
			}
		}
		else {
			@type.flagEmpty()
		}

		@type.flagLiberal()
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
	isInverted() { # {{{
		for var property in @properties {
			if property.isInverted() {
				return true
			}
		}

		return false
	} # }}}
	isMatchingType(type: Type) { # {{{
		if @properties.length == 0 {
			return type.isAny() || type.isObject()
		}
		else {
			return @type.matchContentOf(type)
		}
	} # }}}
	isNotEmpty() => @properties.length > 0
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
			fragments.code('new ', $runtime.object(this), '()')
		}
		else {
			if @isUsingVariable('o') {
				if !@isUsingVariable('d') {
					@varname = 'd'
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

			block.line($const(this), @varname, ' = new ', $runtime.object(this), '()')

			for var property in @properties {
				block.compile(property)
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
	toInvertedFragments(fragments, callback) { # {{{
		for var property in @properties {
			if property.isInverted() {
				return property.toInvertedFragments(fragments, callback)
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
	validateType(type: ObjectType) { # {{{
		for var property in @properties {
			if property is ObjectLiteralMember {
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
				if property is ObjectLiteralMember {
					property.validateType(parameter)
				}
			}
		}
	} # }}}
	varname() => @varname
}

class ObjectComputedMember extends Expression {
	private {
		@name
		@value
	}
	analyse() { # {{{
		@options = Attribute.configure(@data, @options, AttributeTarget.Property, @file())

		if @data.name.kind == NodeKind.ComputedPropertyName {
			@name = $compile.expression(@data.name.expression, this)
		}
		else {
			@name = TemplateExpression.new(@data.name, this)
			@name.computing(true)
		}

		@name.analyse()

		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@name.prepare()
		@value.prepare(target, targetMode)
	} # }}}
	translate() { # {{{
		@name.translate()
		@value.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		@name.acquireReusable(acquire)
		@value.acquireReusable(acquire)
	} # }}}
	isInverted() => @name.isInverted() || @value.isInverted()
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
		fragments
			.newLine()
			.code(@parent.varname(), '[')
			.compile(@name)
			.code(']', $equals)
			.compile(@value)
			.done()
	} # }}}
	toInvertedFragments(fragments, callback) { # {{{
		if @name.isInverted() {
			@name.toInvertedFragments(fragments, callback)
		}
		else {
			@value.toInvertedFragments(fragments, callback)
		}
	} # }}}
	value() => @value
}

class ObjectLiteralMember extends Expression {
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
		@options = Attribute.configure(@data, @options, AttributeTarget.Property, @file())

		if @data.name.kind == NodeKind.Identifier	{
			@name = Literal.new(@data.name, this, @scope:Scope, @data.name.name)

			this.reference('.' + @data.name.name)

			@computed = false
		}
		else {
			@name = StringLiteral.new(@data.name, this)

			this.reference('[' + $quote(@data.name.value) + ']')
		}

		if @data.kind == NodeKind.ObjectMember {
			@value = $compile.expression(@data.value, this)

			@function = @data.value.kind == NodeKind.FunctionExpression

			@shorthand =
				@data.name.kind == NodeKind.Identifier &&
				@data.value.kind == NodeKind.Identifier &&
				@data.name.name == @data.value.name
		}
		else {
			@value = $compile.expression(@data.name, this)
		}

		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target, targetMode)

		@type = @value.type().asReference()

		if @type.isNull() {
			@type = AnyType.NullableUnexplicit
		}
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	acquireReusable(acquire) => @value.acquireReusable(acquire)
	isInverted() => @value.isInverted()
	isUsingVariable(name) => @value.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
	name() => @name.value()
	releaseReusable() => @value.releaseReusable()
	toFragments(fragments, mode) { # {{{
		var line = fragments.newLine()

		if @computed {
			line.code(@parent.varname(), '[').compile(@name).code(']', $equals)
		}
		else {
			line.code(@parent.varname(), '.').compile(@name).code($equals)
		}

		if @enumCasting {
			@value.toCastingFragments(line, mode)
		}
		else {
			line.compile(@value)
		}

		line.done()
	} # }}}
	toInvertedFragments(fragments, callback) => @value.toInvertedFragments(fragments, callback)
	type() => @type
	validateType(type: Type) { # {{{
		if @type.isEnum() && !type.isEnum() {
			@enumCasting = true
		}
	} # }}}
	value() => @value
}

class ObjectRestrictiveMember extends Expression {
	private late {
		@condition
		@property
	}
	analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		match @data.expression.kind {
			NodeKind.ObjectMember {
				match @data.expression.name.kind {
					NodeKind.Identifier, NodeKind.Literal {
						@property = ObjectLiteralMember.new(@data.expression, this)
						@property.analyse()

						this.reference(@property.reference())
					}
					NodeKind.ThisExpression {
						@property = ObjectThisMember.new(@data.expression, this)
						@property.analyse()

						this.reference(@property.reference())
					}
					else {
						@property = ObjectComputedMember.new(@data.expression, this)
						@property.analyse()
					}
				}
			}
			NodeKind.ShorthandProperty {
				match @data.expression.name.kind {
					NodeKind.Identifier {
						@property = ObjectLiteralMember.new(@data.expression, this)
						@property.analyse()

						this.reference(@property.reference())
					}
					NodeKind.ThisExpression {
						@property = ObjectThisMember.new(@data.expression, this)
						@property.analyse()

						this.reference(@property.reference())
					}
					else {
						NotSupportedException.throw(this)
					}
				}
			}
			NodeKind.UnaryExpression {
				@property = ObjectSpreadMember.new(@data.expression, this)
				@property.analyse()
			}
			else {
				NotSupportedException.throw(this)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

		@property.prepare(target, targetMode)
	} # }}}
	translate() { # {{{
		@condition.translate()
		@property.translate()
	} # }}}
	name() => @property.name()
	toFragments(fragments, mode) { # {{{
		var ctrl = fragments.newControl()

		if @data.operator.kind == RestrictiveOperatorKind.If {
			ctrl.code('if(')

			ctrl.compileCondition(@condition)
		}
		else {
			ctrl.code('if(!')

			ctrl.wrapCondition(@condition)
		}

		ctrl.code(')').step().compile(@property).done()
	} # }}}
	value() => @property.value()
	varname() => @parent.varname()
}

class ObjectSpreadMember extends Expression {
	private {
		@type: Type		= AnyType.NullableUnexplicit
		@value
	}
	analyse() { # {{{
		@options = Attribute.configure(@data, @options, AttributeTarget.Property, @file())

		@value = $compile.expression(@data.argument, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		var targetObj = Type.objectOf(target, @scope)

		@value.prepare(targetObj, targetMode)

		var type = @value.type()

		if type.isObject() {
			@type = type.parameter()
		}
		else {
			@type = target
		}
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	isUsingVariable(name) => @value.isUsingVariable(name)
	isInverted() => @value.isInverted()
	override listNonLocalVariables(scope, variables) => @value.listNonLocalVariables(scope, variables)
	toFragments(fragments, mode) { # {{{
		fragments
			.newLine()
			.code($runtime.helper(this), '.concatObject(', @parent.varname(), $comma)
			.compile(@value)
			.code(')')
			.done()
	} # }}}
	toInvertedFragments(fragments, callback) => @value.toInvertedFragments(fragments, callback)
	type(): @type
	value() => @value
}

class ObjectThisMember extends Expression {
	private {
		@name
		@value
	}
	analyse() { # {{{
		@name = Literal.new(@data.name.name, this, @scope:Scope, @data.name.name.name)

		@value = $compile.expression(@data.name, this)
		@value.analyse()

		this.reference(`.\(@name.value())`)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target, targetMode)
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
			.newLine()
			.code(@parent.varname(), '.')
			.compile(@name)
			.code($equals)
			.compile(@value)
			.done()
	} # }}}
	value() => @value
}
