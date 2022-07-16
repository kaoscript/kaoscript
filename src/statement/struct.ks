class StructDeclaration extends Statement {
	private lateinit {
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
	override initiate() { // {{{
		@name = @data.name.name

		@struct = new StructType(@scope)

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
	} // }}}
	override analyse() { // {{{
		@function = new StructFunction(@data, this, new BlockScope(@scope!?))

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
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	fields() => @fields
	isEnhancementExport() => true
	isExtending() => @extending
	toObjectFragments(fragments, mode) { // {{{
		if !@extending && @fields.length == 0 {
			fragments.line(`return new \($runtime.dictionary(this))`)
		}
		else {
			let varname = '_'

			if @extending {
				const line = fragments.newLine().code($const(this), varname, $equals, @extendsName, '.__ks_new(')

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
		const line = fragments.newLine().code(`\($runtime.immutableScope(this))\(@name) = \($runtime.helper(this)).struct(`)

		let ctrl = line.newControl(null, false, false).code(`function(`)

		Parameter.toFragments(@function, ctrl, ParameterMode::Default, func(fragments) {
			return fragments.code(')').step()
		})

		this.toObjectFragments(ctrl, mode)

		ctrl.done()

		const assessment = @type.type().assessment(@type.reference(@scope), this)

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
				const field = new StructFieldDeclaration(type as StructFieldType, @parent!?)
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
	getParameterOffset() => 0
	isAssertingParameter() => @options.rules.assertNewStruct
	isAssertingParameterType() => this.isAssertingParameter()
	isOverridableFunction() => false
	parameters() => @parameters
	type() => @type
}

class StructFieldDeclaration extends AbstractNode {
	private lateinit {
		_index: Number
		_type: StructFieldType
	}
	private {
		_name: String
		_parameter: StructFieldParameter
	}
	constructor(data, parent) { // {{{
		super(data, parent)

		@name = data.name.name

		@parameter = new StructFieldParameter(this, parent._function)
	} // }}}
	constructor(@type, parent) { // {{{
		super({}, parent)

		@name = @type.name()
		@index = @type.index()

		@parameter = new StructFieldParameter(this, parent._function)
		@parameter.unflagValidation()
	} // }}}
	analyse()
	prepare() { // {{{
		@parameter.analyse()
		@parameter.prepare()

		if !?@type {
			let type: Type? = null

			if @data.type? {
				type = Type.fromAST(@data.type, this)
			}

			if type == null {
				type = AnyType.Unexplicit
			}
			else if type.isNull() {
				type = NullType.Explicit
			}

			@type = new StructFieldType(@scope!?, @name, @index, type!?, @parameter.isRequired() as Boolean)

			if @data.defaultValue? && @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				@type.flagNullable()
			}
		}
	} // }}}
	translate() { // {{{
		@parameter.translate()
	} // }}}
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
		@name = new IdentifierParameter({
			name: @field.name()
		}, this, @scope)

		@name.setAssignment(AssignmentType::Parameter)
		@name.analyse()

		for const name in @name.listAssignments([]) {
			@scope.define(name, false, null, this)
		}
	} // }}}
	name() => @name
	toValidationFragments(fragments) { // {{{
		if @validation {
			super(fragments)
		}
	} // }}}
	unflagValidation() { // {{{
		@validation = false
	} // }}}
}
