class TupleDeclaration extends Statement {
	private late {
		_extending: Boolean						= false
		_extendsName: String
		_extendsType: NamedType<TupleType>
		_fields: Array<TupleFieldDeclaration>	= []
		_function: TupleFunction
		_name: String
		_tuple: TupleType
		_type: NamedType<TupleType>
		_variable: Variable
	}
	override initiate() { # {{{
		@name = @data.name.name

		var mut named = false

		for var modifier in @data.modifiers {
			switch modifier.kind {
				ModifierKind::Named => {
					named = true
				}
			}
		}

		if named {
			@tuple = new NamedTupleType(@scope)
		}
		else {
			@tuple = new UnnamedTupleType(@scope)
		}

		if @data.extends? {
			@extending = true

			var mut name = ''
			var mut member = @data.extends
			while member.kind == NodeKind::MemberExpression {
				name = `.\(member.property.name)\(name)`

				member = member.object
			}

			@extendsName = `\(member.name)\(name)`
		}

		@type = new NamedType(@name, @tuple)

		@variable = @scope.define(@name, true, @type, this)
	} # }}}
	override analyse() { # {{{
		@function = new TupleFunction(@data, this, new BlockScope(@scope!?))

		for var data in @data.fields {
			var field = new TupleFieldDeclaration(data, this)

			field.analyse()

			@fields.push(field)
		}

		@function.analyse()
	} # }}}
	override prepare(target) { # {{{
		if @extending {
			if @extendsType !?= Type.fromAST(@data.extends, this) {
				ReferenceException.throwNotDefined(@extendsName, this)
			}
			else if @extendsType.discardName() is not TupleType {
				TypeException.throwNotTuple(@extendsName, this)
			}

			@tuple.extends(@extendsType)
		}

		@function.prepare()

		for var field in @fields {
			@tuple.addField(field.type())
		}
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
	toArrayFragments(fragments, mode) { # {{{
		if @extending {
			var mut varname = '_'

			var line = fragments.newLine().code($const(this), varname, $equals, @extendsName, '.__ks_builder(')

			for var field, index in @extendsType.type().listAllFields() {
				line.code($comma) if index != 0

				line.code(field.name())
			}

			line.code(')').done()

			for var field in @fields {
				fragments.line(varname, '.push(', field.type().name(), ')')
			}

			fragments.line(`return \(varname)`)
		}
		else {
			var line = fragments.newLine().code('return [')

			for var field, index in @fields {
				line.code($comma) if index != 0

				line.compile(field.parameter().name())
			}

			line.code(']').done()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code(`\($runtime.immutableScope(this))\(@name) = \($runtime.helper(this)).tuple(`)

		var mut ctrl = line.newControl(null, false, false).code(`function(`)

		Parameter.toFragments(@function, ctrl, ParameterMode::Default, func(fragments) {
			return fragments.code(')').step()
		})

		this.toArrayFragments(ctrl, mode)

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

		if @extending {
			line.code($comma, @extendsName)
		}

		line.code(')').done()
	} # }}}
}

class TupleFunction extends AbstractNode {
	private {
		_parameters: Array<Parameter>	= []
		_type: FunctionType
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		@type = new FunctionType(@scope)
	} # }}}
	analyse()
	override prepare(target) { # {{{
		// TODO move to `var mut`
		var dyn index = -1

		if @parent.isExtending() {
			var parent = @parent._extendsType.type()

			for var type in parent.listAllFields() {
				var field = new TupleFieldDeclaration(type, @parent!?)
				field.analyse()
				field.prepare()

				var parameter = field.parameter()

				@parameters.push(parameter)

				@type.addParameter(parameter.type())
			}

			index += parent.length()
		}

		for var field in @parent.fields() {
			field.index(++index)

			field.prepare()

			var parameter = field.parameter()

			@parameters.push(parameter)

			@type.addParameter(parameter.type())
		}
	} # }}}
	translate()
	getParameterOffset() => 0
	isAssertingParameter() => @options.rules.assertNewTuple
	isAssertingParameterType() => this.isAssertingParameter()
	isOverridableFunction() => false
	parameters() => @parameters
	type() => @type
}

class TupleFieldDeclaration extends AbstractNode {
	private late {
		_index: Number
		_name: String
		_type: TupleFieldType
	}
	private {
		_hasName: Boolean					= false
		_parameter: TupleFieldParameter
	}
	constructor(data, parent) { # {{{
		super(data, parent)

		if data.name? {
			@name = data.name.name
			@hasName = true
		}

		@parameter = new TupleFieldParameter(this, parent._function)
	} # }}}
	constructor(@type, parent) { # {{{
		super({}, parent)

		if @name ?= @type.name() {
			@hasName = true
		}

		@index = @type.index()

		@parameter = new TupleFieldParameter(this, parent._function)
		@parameter.unflagValidation()
	} # }}}
	analyse()
	override prepare(target) { # {{{
		@parameter.analyse()
		@parameter.prepare()

		if !?@type {
			@type = new TupleFieldType(@scope, @data.name?.name, @index, Type.fromAST(@data.type, this), @parameter.isRequired())

			if @data.defaultValue? && @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				@type.flagNullable()
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
		_field: TupleFieldDeclaration
		_validation: Boolean			 = true
	}
	constructor(@field, parent) { # {{{
		super(field._data, parent)

		@data.modifiers = []
	} # }}}
	analyse() { # {{{
		if @field.hasName() {
			@internal = new IdentifierParameter({name: @field.name()}, this, @scope)
		}
		else {
			@internal = new IdentifierParameter({name: `__ks_\(@field.index())`}, this, @scope)
		}

		@internal.setAssignment(AssignmentType::Parameter)
		@internal.analyse()

		for var name in @internal.listAssignments([]) {
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
