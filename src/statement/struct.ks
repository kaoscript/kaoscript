class StructDeclaration extends Statement {
	private late {
		@array: Boolean							= false
		@extending: Boolean						= false
		@extendsName: String
		@extendsType: NamedType<StructType>
		@fields: Array<StructFieldDeclaration>	= []
		@function: StructFunction
		@implementing: Boolean					= false
		@name: String
		@struct: StructType
		@type: NamedType<StructType>
		@variable: Variable
	}
	override initiate() { # {{{
		@name = @data.name.name

		@struct = StructType.new(@scope)

		if ?@data.extends {
			@extending = true

			var mut name = ''
			var mut member = @data.extends.typeName
			while member.kind == AstKind.MemberExpression {
				name = `.\(member.property.name)\(name)`

				member = member.object
			}

			@extendsName = `\(member.name)\(name)`
		}

		@type = NamedType.new(@name, @struct)

		@variable = @scope.define(@name, true, @type, this)
	} # }}}
	override analyse() { # {{{
		@function = StructFunction.new(@data, this, BlockScope.new(@scope!?))

		for var data in @data.fields {
			var field = StructFieldDeclaration.new(data, this)

			field.analyse()

			@fields.push(field)
		}

		@function.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @extending {
			@extendsType = Type.fromAST(@data.extends.typeName, this)!!

			if @extendsType.discardName() is not StructType {
				TypeException.throwNotStruct(@extendsName, this)
			}

			@struct.extends(@extendsType)
		}

		if ?@data.implements {
			@implementing = true

			for var implement in @data.implements {
				var name = $ast.toIMString(implement)

				if name == @name {
					SyntaxException.throwInheritanceLoop(@name, this)
				}

				var type = Type.fromAST(implement, this)

				if type.isAlias() {
					unless type.isObject() {
						SyntaxException.throwNotObjectInterface(name, this)
					}
				}
				else {
					throw NotImplementedException.new(this)
				}

				@struct.addInterface(type)
			}
		}

		@function.prepare()

		for var field in @fields {
			@struct.addField(field.type())
		}

		if @implementing {
			for var interface in @struct.listInterfaces() {
				var notImplemented = interface.listMissingProperties(@struct)

				if ?#notImplemented.fields {
					SyntaxException.throwMissingProperties('Struct', @name, interface, notImplemented, this)
				}
			}
		}

		@struct.flagComplete()
	} # }}}
	override translate() { # {{{
		for var field in @fields {
			field.translate()
		}
	} # }}}
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	fields() => @fields
	isEnhancementExport() => true
	isExtending() => @extending
	isImplementing() => @implementing
	listInterfaces() => @struct.listInterfaces()
	toCastFragments(fragments, mode) { # {{{
		with var ctrl = fragments.newControl() {
			ctrl.code(`if(`)

			var literal = Literal.new(false, this, @scope(), 'item')

			@type.reference(@scope).toPositiveTestFragments(null, null, Junction.NONE, ctrl, literal)

			ctrl
				.code(')').step()
				.line('return item')
				.done()
		}

		fragments.newControl()
			.code(`if(!\($runtime.type(this)).isObject(item))`).step()
			.line('return null')
			.done()

		fragments.line(`const args = []`)
		fragments.line(`let arg`)

		for var field, index in @struct.listAllFields() {
			var ctrl = fragments.newControl().code(`if(!`)
			var literal = Literal.new(false, this, @scope(), `arg = item.\(field.name())`)

			field.type().toPositiveTestFragments(null, null, Junction.NONE, ctrl, literal)

			ctrl
				.code(')').step()
				.line('return null')
				.done()

			fragments.line(`args[\(index)] = arg`)
		}

		fragments.line(`return __ks_new.call(null, args)`)
	} # }}}
	toObjectFragments(fragments, mode) { # {{{
		if @extending && @extendsType.type().hasDefaultValues() {
			var line = fragments.newLine().code(`\($const(this))_ = \(@extendsName).__ks_create(`)

			for var name, index in @extendsType.type().listAllFieldNames() {
				line
					..code($comma) if index > 0
					..code(name)
			}

			line.code(')').done()

			for var field in @fields {
				fragments.newLine().code('_.').compile(field.name()).code($equals).compile(field.parameter().name()).done()
			}

			fragments.line(`return _`)
		}
		else {
			var fields = @function.fields()

			if ?#fields {
				fragments.line($const(this), '_ = new ', $runtime.object(this), '()')

				for var field in fields {
					fragments.newLine().code('_.').compile(field.name()).code($equals).compile(field.parameter().name()).done()
				}

				fragments.line(`return _`)
			}
			else {
				fragments.line(`return new \($runtime.object(this))()`)
			}
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code(`\($runtime.immutableScope(this))\(@name) = \($runtime.helper(this)).struct(`)

		var mut ctrl = line.newControl(null, false, false).code(`function(`)

		Parameter.toFragments(@function, ctrl, ParameterMode.Default, (writer) => writer.code(')').step())

		@toObjectFragments(ctrl, mode)

		ctrl.done()

		var assessment = @type.type().assessment(@type.reference(@scope), this)

		ctrl = line.newControl(null, false, false).code(`, function(__ks_new, args)`).step()

		Router.toFragments(
			(function, writer) => {
				writer.code(`__ks_new(`)

				return false
			}
			null
			assessment
			ctrl.block()
			this
		)

		ctrl.done()

		ctrl = line.newControl(null, false, false).code(`, function(__ks_new, item)`).step()

		@toCastFragments(ctrl, mode)

		ctrl.done()

		line.code(')').done()
	} # }}}
	type() => @type
}

class StructFunction extends AbstractNode {
	private {
		@fields: StructFieldDeclaration[]	= []
		@parameters: Parameter[]			= []
		@type: FunctionType
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		@type = FunctionType.new(@scope)
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		var mut index = -1

		if @parent.isExtending() {
			for var type in @parent._extendsType.type().listAllFields() {
				var field = StructFieldDeclaration.new(type:!!!(StructFieldType), @parent!?)
				field.analyse()
				field.prepare()

				var parameter = field.parameter()

				@parameters.push(parameter)

				@type.addParameter(parameter.type(), this)

				if field.index() > index {
					index = field.index()
				}

				@fields.push(field)
			}
		}

		for var field in @parent.fields() {
			index += 1

			field.index(index)

			field.prepare()

			var parameter = field.parameter()

			@parameters.push(parameter)

			@type.addParameter(parameter.type(), this)

			@fields.push(field)
		}
	} # }}}
	translate()
	fields() => @fields
	getParameterOffset() => 0
	isAssertingParameter() => @options.rules.assertNewStruct
	isAssertingParameterType() => @isAssertingParameter()
	isOverridableFunction() => false
	parameters() => @parameters
	type() => @type
}

class StructFieldDeclaration extends AbstractNode {
	private late {
		@index: Number
		@type: StructFieldType
	}
	private {
		@name: String
		@parameter: StructFieldParameter
	}
	constructor(data, parent) { # {{{
		super(data, parent)

		@name = data.name.name

		@parameter = StructFieldParameter.new(this, parent._function)
	} # }}}
	constructor(@type, parent) { # {{{
		super($ast.parameter(), parent)

		@name = @type.name()
		@index = @type.index()

		@parameter = StructFieldParameter.new(this, parent._function)
		@parameter.unflagValidation()
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		@parameter.analyse()
		@parameter.prepare()

		if !?@type {
			var mut type: Type? = null

			if ?@data.type {
				type = Type.fromAST(@data.type, this)
			}

			if type == null {
				for var modifier in @data.modifiers {
					if modifier.kind == ModifierKind.Nullable {
						type = AnyType.NullableUnexplicit
					}
				}

				type ??= AnyType.Unexplicit
			}
			else if type.isNull() {
				type = NullType.Explicit
			}

			@type = StructFieldType.new(@scope!?, @name, @index, type!?, @parameter.isRequired():!!!(Boolean))

			if ?@data.value {
				@type.flagDefaultValue()

				if @data.value.kind == AstKind.Identifier && @data.value.name == 'null' {
					@type.flagNullable()
				}
			}
		}

		if @parent.isImplementing() {
			for var interface in @parent.listInterfaces() {
				if var property ?= interface.getProperty(@data.name.name) {
					if @type.type().isExplicit() {
						unless @type.isSubsetOf(property, MatchingMode.Default) {
							SyntaxException.throwUnmatchVariable(@parent.type(), interface, @name, this)
						}
					}
					else {
						@type.type(property)
					}
				}
			}
		}
	} # }}}
	translate() { # {{{
		@parameter.translate()
	} # }}}
	index() => @index
	index(@index) => this
	name() => @name
	parameter() => @parameter
	type() => @type
}

class StructFieldParameter extends Parameter {
	private {
		@field: StructFieldDeclaration
		@validation: Boolean			 = true
	}
	constructor(@field, parent) { # {{{
		var data =
			if ?field._data.value {
				set { ...field._data!?, defaultValue: field._data.value }
			}
			else {
				set field._data
			}

		super(data, parent)
	} # }}}
	analyse() { # {{{
		@internal = IdentifierParameter.new({
			name: @field.name()
		}, this, @scope)

		@internal.setAssignment(AssignmentType.Parameter)
		@internal.analyse()

		for var { name } in @internal.listAssignments([]) {
			@scope.define(name, false, null, this)
		}
	} # }}}
	name() => @internal
	toValidationFragments(fragments) { # {{{
		if @validation {
			super(fragments)
		}
	} # }}}
	unflagValidation() { # {{{
		@validation = false
	} # }}}
}
