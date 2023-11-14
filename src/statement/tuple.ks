class TupleDeclaration extends Statement {
	private late {
		@extending: Boolean						= false
		@extendsName: String
		@extendsType: NamedType<TupleType>
		@fields: Array<TupleFieldDeclaration>	= []
		@function: TupleFunction
		@implementing: Boolean					= false
		@name: String
		@tuple: TupleType
		@type: NamedType<TupleType>
		@variable: Variable
	}
	override initiate() { # {{{
		@name = @data.name.name
		@tuple = TupleType.new(@scope)

		if ?@data.extends {
			@extending = true

			var mut name = ''
			var mut member = @data.extends
			while member.kind == NodeKind.MemberExpression {
				name = `.\(member.property.name)\(name)`

				member = member.object
			}

			@extendsName = `\(member.name)\(name)`
		}

		@type = NamedType.new(@name, @tuple)

		@variable = @scope.define(@name, true, @type, this)
	} # }}}
	override analyse() { # {{{
		@function = TupleFunction.new(@data, this, BlockScope.new(@scope!?))

		for var data in @data.fields {
			var field = TupleFieldDeclaration.new(data, this)

			field.analyse()

			@fields.push(field)
		}

		@function.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @extending {
			if @extendsType !?= Type.fromAST(@data.extends, this) {
				ReferenceException.throwNotDefined(@extendsName, this)
			}
			else if @extendsType.discardName() is not TupleType {
				TypeException.throwNotTuple(@extendsName, this)
			}

			@tuple.extends(@extendsType)
		}

		if ?@data.implements {
			@implementing = true

			for var implement in @data.implements {
				var name = $ast.toIMString(implement)

				if name == @name {
					SyntaxException.throwInheritanceLoop(@name, this)
				}

				if var type ?= Type.fromAST(implement, this) {
					if type.isAlias() {
						unless type.isArray() {
							SyntaxException.throwNotArrayInterface(name, this)
						}
					}
					else {
						throw NotImplementedException.new(this)
					}

					@tuple.addInterface(type)
				}
				else {
					ReferenceException.throwNotDefined(name, this)
				}
			}
		}

		@function.prepare()

		for var field in @fields {
			@tuple.addField(field.type())
		}

		if @implementing {
			for var interface in @tuple.listInterfaces() {
				var notImplemented = interface.listMissingProperties(@tuple)

				if ?#notImplemented.fields {
					SyntaxException.throwMissingProperties('Tuple', @name, interface, notImplemented, this)
				}
			}
		}

		@tuple.flagComplete()
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
	listInterfaces() => @tuple.listInterfaces()
	toArrayFragments(fragments, mode) { # {{{
		if @extending && @extendsType.type().hasDefaultValues() {
			var line = fragments.newLine().code(`\($const(this))_ = \(@extendsName).__ks_create(`)

			for var field, index in @extendsType.type().listAllFields() {
				line.code($comma) if index != 0

				line.code(field.name())
			}

			line.code(')').done()

			for var field in @fields {
				fragments.line('_.push(', field.type().name(), ')')
			}

			fragments.line(`return _`)
		}
		else {
			var fields = @function.fields()
			var line = fragments.newLine().code('return [')

			for var field, index in fields {
				line
					..code($comma) if index != 0
					..compile(field.parameter().name())
			}

			line.code(']').done()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code(`\($runtime.immutableScope(this))\(@name) = \($runtime.helper(this)).tuple(`)

		var mut ctrl = line.newControl(null, false, false).code(`function(`)

		Parameter.toFragments(@function, ctrl, ParameterMode.Default, (fragments) => fragments.code(')').step())

		@toArrayFragments(ctrl, mode)

		ctrl.done()

		var assessment = @type.type().assessment(@type.reference(@scope), this)

		ctrl = line.newControl(null, false, false).code(`, function(__ks_new, args)`).step()

		Router.toFragments(
			(function, line) => {
				line.code(`__ks_new(`)

				return false
			}
			null
			assessment
			ctrl.block()
			this
		)

		ctrl.done()

		line.code(')').done()
	} # }}}
	type() => @type
}

class TupleFunction extends AbstractNode {
	private {
		@fields: StructFieldDeclaration[]	= []
		@parameters: Array<Parameter>	= []
		@type: FunctionType
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		@type = FunctionType.new(@scope)
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		// TODO move to `var mut`
		var dyn index = -1

		if @parent.isExtending() {
			var parent = @parent._extendsType.type()

			for var type in parent.listAllFields() {
				var field = TupleFieldDeclaration.new(type, @parent!?)
				field.analyse()
				field.prepare()

				var parameter = field.parameter()

				@parameters.push(parameter)

				@type.addParameter(parameter.type(), this)

				@fields.push(field)
			}

			index += parent.length()
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
	isAssertingParameter() => @options.rules.assertNewTuple
	isAssertingParameterType() => @isAssertingParameter()
	isOverridableFunction() => false
	parameters() => @parameters
	type() => @type
}

class TupleFieldDeclaration extends AbstractNode {
	private late {
		@index: Number
		@name: String
		@type: TupleFieldType
	}
	private {
		@hasName: Boolean					= false
		@parameter: TupleFieldParameter
	}
	constructor(data, parent) { # {{{
		super(data, parent)

		if ?data.name {
			@name = data.name.name
			@hasName = true
		}

		@parameter = TupleFieldParameter.new(this, parent._function)
	} # }}}
	constructor(@type, parent) { # {{{
		super($ast.parameter(), parent)

		if @name ?= @type.name() {
			@hasName = true
		}

		@index = @type.index()

		@parameter = TupleFieldParameter.new(this, parent._function)
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

			@type = TupleFieldType.new(@scope, @data.name?.name, @index, type, @parameter.isRequired())

			if ?@data.defaultValue {
				@type.flagDefaultValue()

				if @data.defaultValue.kind == NodeKind.Identifier && @data.defaultValue.name == 'null' {
					@type.flagNullable()
				}
			}
		}

		if @parent.isImplementing() {
			for var interface in @parent.listInterfaces() {
				if var property ?= interface.getProperty(@index) {
					if @type.type().isExplicit() {
						unless @type.isSubsetOf(property, MatchingMode.Default) {
							SyntaxException.throwUnmatchVariable(@parent.type(), interface, @index, this)
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
	hasName() => @hasName
	index() => @index
	index(@index) => this
	name() => @name
	parameter() => @parameter
	type() => @type
}

class TupleFieldParameter extends Parameter {
	private {
		@field: TupleFieldDeclaration
		@validation: Boolean			 = true
	}
	constructor(@field, parent) { # {{{
		super(field._data, parent)
	} # }}}
	analyse() { # {{{
		if @field.hasName() {
			@internal = IdentifierParameter.new({name: @field.name()}, this, @scope)
		}
		else {
			@internal = IdentifierParameter.new({name: `__ks_\(@field.index())`}, this, @scope)
		}

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
