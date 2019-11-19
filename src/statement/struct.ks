class StructDeclaration extends Statement {
	private {
		_array: Boolean							= false
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

		@type = new NamedType(@name, @struct)

		@variable = @scope.define(@name, true, @type, this)

		@function = new StructFunction(@data, this, new BlockScope(@scope))

		for const data, index in @data.fields {
			const field = new StructFieldDeclaration(index, data, this)

			field.analyse()

			@fields.push(field)
		}

		@function.analyse()
	} // }}}
	override prepare() { // {{{
		for const field in @fields {
			field.prepare()

			@struct.addField(field.type())
		}

		@function.prepare()
	} // }}}
	override translate() { // {{{
		for const field in @fields {
			field.translate()
		}
	} // }}}
	toArrayFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code('return [')

		for const field, i in @fields {
			if i != 0 {
				line.code($comma)
			}

			line.compile(field.parameter().name())
		}

		line.code(']').done()
	} // }}}
	toObjectFragments(fragments, mode) { // {{{
		if @fields.length == 0 {
			fragments.line(`return new \($runtime.dictionary(this))`)
		}
		else {
			let varname = '_'

			fragments.line($const(this), varname, ' = new ', $runtime.dictionary(this), '()')

			for const field in @fields {
				fragments.newLine().code(varname, '.').compile(field.parameter().name()).code($equals).compile(field.parameter().name()).done()
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

		line.code(')').done()
	} // }}}
}

class StructFunction extends AbstractNode {
	private {
		_parameters: Array<Parameter>
		_type: FunctionType
	}
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope)

		@type = new FunctionType(@scope)
	} // }}}
	analyse() { // {{{
		@parameters = [field.parameter() for const field in @parent._fields]
	} // }}}
	prepare() { // {{{
		for const parameter in @parameters {
			@type.addParameter(parameter.type())
		}
	} // }}}
	translate()
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
	constructor(@index, data, parent) { // {{{
		super(data, parent)

		if data.name? {
			@name = data.name.name
			@hasName = true
		}

		@parameter = new StructFieldParameter(this, parent._function)
	} // }}}
	analyse() { // {{{
		@parameter.analyse()
	} // }}}
	prepare() { // {{{
		@parameter.prepare()

		@type = new StructFieldType(@scope, @data.name?.name, @index, Type.fromAST(@data.type, this), @parameter.isRequired())
	} // }}}
	translate() { // {{{
		@parameter.translate()
	} // }}}
	hasName() => @hasName
	index() => @index
	name() => @name
	parameter() => @parameter
	type() => @type
}

class StructFieldParameter extends Parameter {
	private {
		_field: StructFieldDeclaration
	}
	constructor(@field, parent) { // {{{
		super(field._data, parent)

		@data.modifiers = []
	} // }}}
	analyse() { // {{{
		if @field.hasName() {
			@name = new IdentifierParameter(@data.name, this, @scope)
		}
		else {
			@name = new IdentifierParameter({name: @scope.acquireTempName(false)}, this, @scope)
		}

		@name.setAssignment(AssignmentType::Parameter)
		@name.analyse()

		for const name in @name.listAssignments([]) {
			@scope.define(name, false, null, this)
		}
	} // }}}
	name() => @name
}