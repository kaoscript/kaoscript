class StructDeclaration extends Statement {
	private {
		_array: Boolean							= false
		_extending: Boolean						= false
		_extendsName: String
		_extendsType: NamedType<StructType>
		_fields: Array<StructFieldDeclaration>	= []
		_function: StructFunction
		_name: String
		_struct: StructType
		_type: NamedType<StructType>
		_variable: Variable
	}
	override analyse() { // {{{
		@name = @data.name.name

		let named = false

		for const modifier in @data.modifiers {
			switch modifier.kind {
				ModifierKind::Array => {
					@array = true
				}
				ModifierKind::Named => {
					named = true
				}
			}
		}

		if @array {
			@struct = named ? new NamedArrayStructType(@scope) : new ArrayStructType(@scope)
		}
		else {
			@struct = new ObjectStructType(@scope)
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

		@type = new NamedType(@name, @struct)

		@variable = @scope.define(@name, true, @type, this)

		@function = new StructFunction(@data, this, new BlockScope(@scope))

		for const data in @data.fields {
			const field = new StructFieldDeclaration(data, this)

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
			else if @extendsType.discardName() is not StructType {
				TypeException.throwNotStruct(@extendsName, this)
			}

			@struct.extends(@extendsType)
		}

		@function.prepare()

		for const field in @fields {
			@struct.addField(field.type())
		}
	} // }}}
	override translate() { // {{{
		for const field in @fields {
			field.translate()
		}
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
	toObjectFragments(fragments, mode) { // {{{
		if !@extending && @fields.length == 0 {
			fragments.line(`return new \($runtime.dictionary(this))`)
		}
		else {
			let varname = '_'

			if @extending {
				const line = fragments.newLine().code($const(this), varname, $equals, @extendsName, '.__ks_builder(')

				let nf = false
				for const name in @extendsType.type().listAllFieldNames() {
					if nf {
						line.code($comma)
					}
					else {
						nf = true
					}

					line.code(name)
				}

				line.code(')').done()
			}
			else {
				fragments.line($const(this), varname, ' = new ', $runtime.dictionary(this), '()')
			}

			for const field in @fields {
				fragments.newLine().code(varname, '.').compile(field.name()).code($equals).compile(field.parameter().name()).done()
			}

			fragments.line(`return \(varname)`)
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code(`var \(@name) = \($runtime.helper(this)).struct(`)

		const ctrl = line.newControl(null, false, false).code(`function(`)

		Parameter.toFragments(@function, ctrl, ParameterMode::Default, func(fragments) {
			return fragments.code(')').step()
		})

		if @array {
			this.toArrayFragments(ctrl, mode)
		}
		else {
			this.toObjectFragments(ctrl, mode)
		}

		ctrl.done()

		if @extending {
			line.code($comma, @extendsName)
		}

		line.code(')').done()
	} // }}}
}

class StructFunction extends AbstractNode {
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
			for const type in @parent._extendsType.type().listAllFields() {
				const field = new StructFieldDeclaration(type, @parent)
				field.analyse()
				field.prepare()

				const parameter = field.parameter()

				@parameters.push(parameter)

				@type.addParameter(parameter.type())

				if field.index() > index {
					index = field.index()
				}
			}
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
	isAssertingParameter() => @options.rules.assertNewStruct
	isAssertingParameterType() => this.isAssertingParameter()
	parameters() => @parameters
	type() => @type
}

class StructFieldDeclaration extends AbstractNode {
	private {
		_hasName: Boolean					= false
		_index: Number
		_name: String
		_parameter: StructFieldParameter
		_type: StructFieldType
	}
	constructor(data, parent) { // {{{
		super(data, parent)

		if data.name? {
			@name = data.name.name
			@hasName = true
		}

		@parameter = new StructFieldParameter(this, parent._function)
	} // }}}
	constructor(@type, parent) { // {{{
		super({}, parent)

		if @name ?= @type.name() {
			@hasName = true
		}

		@index = @type.index()

		@parameter = new StructFieldParameter(this, parent._function)
		@parameter.unflagValidation()
	} // }}}
	analyse()
	prepare() { // {{{
		@parameter.analyse()
		@parameter.prepare()

		if !?@type {
			@type = new StructFieldType(@scope, @data.name?.name, @index, Type.fromAST(@data.type, this), @parameter.isRequired())
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

class StructFieldParameter extends Parameter {
	private {
		_field: StructFieldDeclaration
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