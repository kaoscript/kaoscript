class TupleDeclaration extends Statement {
	private lateinit {
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
	override analyse() { // {{{
		@name = @data.name.name

		let named = false

		for const modifier in @data.modifiers {
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

			let name = ''
			let member = @data.extends
			while member.kind == NodeKind::MemberExpression {
				name = `.\(member.property.name)\(name)`

				member = member.object
			}

			@extendsName = `\(member.name)\(name)`
		}

		@type = new NamedType(@name, @tuple)

		@variable = @scope.define(@name, true, @type, this)

		@function = new TupleFunction(@data, this, new BlockScope(@scope))

		for const data in @data.fields {
			const field = new TupleFieldDeclaration(data, this)

			field.analyse()

			@fields.push(field)
		}

		@function.analyse()
	} // }}}
	override prepare() { // {{{
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

		for const field in @fields {
			@tuple.addField(field.type())
		}
	} // }}}
	override translate() { // {{{
		for const field in @fields {
			field.translate()
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	fields() => @fields
	isExtending() => @extending
	toArrayFragments(fragments, mode) { // {{{
		if @extending {
			let varname = '_'

			const line = fragments.newLine().code($const(this), varname, $equals, @extendsName, '.__ks_builder(')

			let nf = false
			for const field in @extendsType.type().listAllFields() {
				if nf {
					line.code($comma)
				}
				else {
					nf = true
				}

				line.code(`__ks_\(field.index())`)
			}

			line.code(')').done()

			for const field in @fields {
				fragments.line(varname, '.push(__ks_', field.index(), ')')
			}

			fragments.line(`return \(varname)`)
		}
		else {
			const line = fragments.newLine().code('return [')

			for const field, i in @fields {
				if i != 0 {
					line.code($comma)
				}

				line.compile(field.parameter().name())
			}

			line.code(']').done()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code(`var \(@name) = \($runtime.helper(this)).tuple(`)

		const ctrl = line.newControl(null, false, false).code(`function(`)

		Parameter.toFragments(@function, ctrl, ParameterMode::Default, func(fragments) {
			return fragments.code(')').step()
		})

		this.toArrayFragments(ctrl, mode)

		ctrl.done()

		if @extending {
			line.code($comma, @extendsName)
		}

		line.code(')').done()
	} // }}}
}

class TupleFunction extends AbstractNode {
	private {
		_parameters: Array<Parameter>	= []
		_type: FunctionType
	}
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope)

		@type = new FunctionType(@scope)
	} // }}}
	analyse()
	prepare() { // {{{
		let index = -1

		if @parent.isExtending() {
			const parent = @parent._extendsType.type()

			for const type in parent.listAllFields() {
				const field = new TupleFieldDeclaration(type, @parent)
				field.analyse()
				field.prepare()

				const parameter = field.parameter()

				@parameters.push(parameter)

				@type.addParameter(parameter.type())
			}

			index += parent.length()
		}

		for const field in @parent.fields() {
			field.index(++index)

			field.prepare()

			const parameter = field.parameter()

			@parameters.push(parameter)

			@type.addParameter(parameter.type())
		}
	} // }}}
	translate()
	getParameterOffset() => 0
	isAssertingParameter() => @options.rules.assertNewTuple
	isAssertingParameterType() => this.isAssertingParameter()
	parameters() => @parameters
	type() => @type
}

class TupleFieldDeclaration extends AbstractNode {
	private lateinit {
		_index: Number
		_name: String
		_type: TupleFieldType
	}
	private {
		_hasName: Boolean					= false
		_parameter: TupleFieldParameter
	}
	constructor(data, parent) { // {{{
		super(data, parent)

		if data.name? {
			@name = data.name.name
			@hasName = true
		}

		@parameter = new TupleFieldParameter(this, parent._function)
	} // }}}
	constructor(@type, parent) { // {{{
		super({}, parent)

		if @name ?= @type.name() {
			@hasName = true
		}

		@index = @type.index()

		@parameter = new TupleFieldParameter(this, parent._function)
		@parameter.unflagValidation()
	} // }}}
	analyse()
	prepare() { // {{{
		@parameter.analyse()
		@parameter.prepare()

		if !?@type {
			@type = new TupleFieldType(@scope, @data.name?.name, @index, Type.fromAST(@data.type, this), @parameter.isRequired())

			if @data.defaultValue? && @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				@type.flagNullable()
			}
		}
	} // }}}
	translate() { // {{{
		@parameter.translate()
	} // }}}
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
	constructor(@field, parent) { // {{{
		super(field._data, parent)

		@data.modifiers = []
	} // }}}
	analyse() { // {{{
		if @field.hasName() {
			@name = new IdentifierParameter({name: @field.name()}, this, @scope)
		}
		else {
			@name = new IdentifierParameter({name: `__ks_\(@field.index())`}, this, @scope)
		}

		@name.setAssignment(AssignmentType::Parameter)
		@name.analyse()

		for const name in @name.listAssignments([]) {
			@scope.define(name, false, null, this)
		}
	} // }}}
	name() => @name
	toValidationFragments(fragments, wrongdoer) { // {{{
		if @validation {
			super(fragments, wrongdoer)
		}
	} // }}}
	unflagValidation() { // {{{
		@validation = false
	} // }}}
}