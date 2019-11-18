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

		@function = new StructFunction(this)

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
		/* _struct: StructDeclaration */
		_type: FunctionType
	}
	constructor(@parent) { // {{{
		super(parent._data, parent)

		/* @parameters = [field.parameter() for const field in parent._fields] */

		@type = new FunctionType(@scope)

		/* for const parameter in @parameters {
			@type.addParameter(parameter.type())
		} */
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
		/* _defaultValue						= null */
		_hasDefaultValue: Boolean			= false
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
		/* if @data.defaultValue? {
			@hasDefaultValue = true

			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
		} */

		@parameter.analyse()
	} // }}}
	prepare() { // {{{
		@type = StructFieldType.fromAST(@data, @index, this)

		@parameter.prepare()
	} // }}}
	translate() { // {{{
		/* if @hasDefaultValue {
			@defaultValue.prepare()

			if !@defaultValue.isMatchingType(@type.type()) {
				/* TypeException.throwInvalidAssignement(@name, @type, @defaultValue.type(), this) */
			}

			@defaultValue.translate()
		} */

		@parameter.translate()
	} // }}}
	hasDefaultValue() => @hasDefaultValue
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
			/* @name = new IdentifierParameter({name: `_\(@field.index())`}, this, @scope) */
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