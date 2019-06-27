class ArrayBinding extends Expression {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_elements						= []
		_flatten: Boolean				= false
		_immutable: Boolean				= false
	}
	analyse() { // {{{
		@flatten = @options.format.destructuring == 'es5'

		for const data, index in @data.elements {
			const element = new ArrayBindingElement(data, this, this.bindingScope())

			element.setAssignment(@assignment)

			element.index(index)

			element.analyse()

			@elements.push(element)
		}
	} // }}}
	prepare() { // {{{
		for element in @elements {
			element.prepare()
		}
	} // }}}
	translate() { // {{{
		for element in @elements {
			element.translate()
		}
	} // }}}
	export(recipient) { // {{{
		for element in @elements {
			element.export(recipient)
		}
	} // }}}
	flagImmutable() { // {{{
		@immutable = true
	} // }}}
	isAssignable() => true
	isImmutable() => @immutable
	isDeclararingVariable(name: String) { // {{{
		for element in @elements {
			if element.isDeclararingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	isRedeclared() { // {{{
		for const element in @elements {
			if element.isRedeclared() {
				return true
			}
		}

		return false
	} // }}}
	isSplitAssignment() => @flatten && @elements.length > 1
	listAssignments(array) { // {{{
		for const element in @elements {
			element.listAssignments(array)
		}

		return array
	} // }}}
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		fragments.code('[')

		for i from 0 til @elements.length {
			fragments.code(', ') if i

			@elements[i].toFragments(fragments)
		}

		fragments.code(']')
	} // }}}
	toAssignmentFragments(fragments, value) { // {{{
		if @flatten {
			this.toFlatFragments(fragments, value)
		}
		else {
			fragments
				.compile(this)
				.code($equals)
				.compile(value)
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if @elements.length == 1 {
			@elements[0].toFlatFragments(fragments, value)
		}
		else {
			const reusableValue = new TempReusableExpression(value, this)

			let comma = false
			for const element in @elements when !element.isAnonymous() {
				if comma {
					fragments.code(', ')
				}
				else {
					comma = true
				}

				element.toFlatFragments(fragments, reusableValue)
			}
		}
	} // }}}
	type(type: Type, scope: Scope, node)
	walk(fn) { // {{{
		for element in @elements {
			element.walk(fn)
		}
	} // }}}
}

class ArrayBindingElement extends Expression {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_defaultValue					= null
		_index							= -1
		_name							= null
		_named: Boolean					= false
		_rest: Boolean					= false
		_thisAlias: Boolean				= false
		_type: Type						= Type.Any
	}
	analyse() { // {{{
		if @data.name? {
			@name = $compile.expression(@data.name, this)
			@name.setAssignment(@assignment)
			@name.analyse()

			@named = true

			if @data.defaultValue? {
				@defaultValue = $compile.expression(@data.defaultValue, this)
				@defaultValue.analyse()
			}
		}

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Rest {
				@rest = true
			}
			else if modifier.kind == ModifierKind::ThisAlias {
				@thisAlias = true
			}
		}
	} // }}}
	prepare() { // {{{
		if @named {
			@name.prepare()

			@defaultValue?.prepare()
		}

		if @data.type? {
			@type = Type.fromAST(@data.type, this)
		}

		this.statement().assignTempVariables(@scope)
	} // }}}
	translate() { // {{{
		if @named {
			@name.translate()

			@defaultValue?.translate()
		}
	} // }}}
	export(recipient) => @named ? @name.export(recipient) : null
	index(@index) => this
	isImmutable() => @parent.isImmutable()
	isDeclararingVariable(name: String) => @named ? @name.isDeclararingVariable(name) : false
	isAnonymous() => !@named
	isRedeclared() => @named ? @name.isRedeclared() : false
	isRest() => @rest
	listAssignments(array) => @named ? @name.listAssignments(array) : array
	max() => @rest ? Infinity : 1
	min() => @rest ? 0 : 1
	setAssignment(@assignment)
	toFragments(fragments) { // {{{
		if @rest {
			fragments.code('...')
		}

		if @named {
			fragments.compile(@name)

			if @defaultValue != null {
				fragments.code(' = ').compile(@defaultValue)
			}
		}
	} // }}}
	toExistFragments(fragments, name) { // {{{
		if @rest {
			fragments.code('...')
		}

		if @named {
			if @defaultValue != null {
				fragments.code(' = ').compile(@defaultValue)
			}
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if @named {
			if @name is ArrayBinding {
				@name.toFlatFragments(fragments, new FlatArrayBindingElement(value, @index, this))
			}
			else {
				fragments
					.compile(@name)
					.code($equals)
					.wrap(value)
					.code(`[\(@index)]`)
			}
		}
	} // }}}
	type() => @type
	walk(fn) { // {{{
		if @named {
			@name.walk(fn)
		}
	} // }}}
}

class FlatArrayBindingElement extends Expression {
	private {
		_array
		_index
	}
	constructor(@array, @index, parent) { // {{{
		super({}, parent)
	} // }}}
	analyse()
	prepare()
	translate()
	isComposite() => false
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(@array)
			.code('[')
			.compile(@index)
			.code(']')
	} // }}}
}

class FlatObjectBindingElement extends Expression {
	private {
		_item
		_property
	}
	constructor(@item, @property, parent) { // {{{
		super({}, parent)
	} // }}}
	analyse()
	prepare()
	translate()
	isComposite() => false
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(@item)
			.code('.')
			.compile(@property)
	} // }}}
}

class FlatReusableBindingElement extends Expression {
	private {
		_value
	}
	constructor(@value, parent) { // {{{
		super({}, parent)
	} // }}}
	analyse()
	prepare()
	translate()
	isComposite() => false
	toFragments(fragments, mode) { // {{{
		fragments
			.code('(')
			.compileReusable(@value)
			.code(')')
	} // }}}
}

class ObjectBinding extends Expression {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_elements						= []
		_flatten: Boolean				= false
		_immutable: Boolean				= false
	}
	constructor(@data, @parent, scope) { // {{{
		super(data, parent, parent.statement().scope())
	} // }}}
	analyse() { // {{{
		@flatten = @options.format.destructuring == 'es5'

		for const data in @data.elements {
			const element = new ObjectBindingElement(data, this, this.bindingScope())

			element.setAssignment(@assignment)

			element.analyse()

			if element.hasDefaultValue() {
				@flatten = true
			}

			@elements.push(element)
		}
	} // }}}
	prepare() { // {{{
		for const element in @elements {
			element.prepare()
		}
	} // }}}
	translate() { // {{{
		for element in @elements {
			element.translate()
		}
	} // }}}
	export(recipient) { // {{{
		for element in @elements {
			element.export(recipient)
		}
	} // }}}
	flagImmutable() { // {{{
		@immutable = true
	} // }}}
	isAssignable() => true
	isImmutable() => @immutable
	isDeclararingVariable(name: String) { // {{{
		for element in @elements {
			if element.isDeclararingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	isRedeclared() { // {{{
		for const element in @elements {
			if element.isRedeclared() {
				return true
			}
		}

		return false
	} // }}}
	isSplitAssignment() => @flatten && @elements.length > 1
	listAssignments(array) { // {{{
		for const element in @elements {
			element.listAssignments(array)
		}

		return array
	} // }}}
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		fragments.code('{')

		for i from 0 til @elements.length {
			fragments.code(', ') if i

			@elements[i].toFragments(fragments)
		}

		fragments.code('}')
	} // }}}
	toAssignmentFragments(fragments, value) { // {{{
		if @flatten {
			this.toFlatFragments(fragments, value)
		}
		else if @assignment == AssignmentType::Declaration {
			fragments
				.compile(this)
				.code($equals)
				.compile(value)
		}
		else {
			fragments
				.code('(')
				.compile(this)
				.code($equals)
				.compile(value)
				.code(')')
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if @elements.length == 1 {
			@elements[0].toFlatFragments(fragments, value)
		}
		else {
			const reusableValue = new TempReusableExpression(value, this)

			@elements[0].toFlatFragments(fragments, reusableValue)

			for const element in @elements from 1 {
				fragments.code(', ')

				element.toFlatFragments(fragments, reusableValue)
			}
		}
	} // }}}
	type(type: Type, scope: Scope, node)
	walk(fn) { // {{{
		for element in @elements {
			element.walk(fn)
		}
	} // }}}
}

class ObjectBindingElement extends Expression {
	private {
		_alias							= null
		_assignment: AssignmentType		= AssignmentType::Neither
		_computed: Boolean				= false
		_defaultValue					= null
		_hasDefaultValue: Boolean		= false
		_name
		_rest: Boolean					= false
		_thisAlias: Boolean				= false
	}
	analyse() { // {{{
		@name = $compile.expression(@data.name, this)
		@computed = @data.name.computed

		if @data.alias? {
			@alias = $compile.expression(@data.alias, this)
		}
		else  {
			@alias = @name
		}

		@alias.setAssignment(@assignment)
		@alias.analyse()

		if @data.defaultValue? {
			@hasDefaultValue = true

			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
		}

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Rest {
				@rest = true
			}
			else if modifier.kind == ModifierKind::ThisAlias {
				@thisAlias = true
			}
		}
	} // }}}
	prepare() { // {{{
		@alias.prepare()

		if @hasDefaultValue {
			@defaultValue.prepare()
		}

		this.statement().assignTempVariables(@scope)
	} // }}}
	translate() { // {{{
		@alias.translate()

		if @hasDefaultValue {
			@defaultValue.translate()
		}
	} // }}}
	export(recipient) => @alias.export(recipient)
	hasDefaultValue() => @hasDefaultValue
	isImmutable() => @parent.isImmutable()
	isDeclararingVariable(name: String) => @alias.isDeclararingVariable(name)
	isRedeclared() => @alias.isRedeclared()
	listAssignments(array) => @alias.listAssignments(array)
	setAssignment(@assignment)
	toFragments(fragments) { // {{{
		if @rest {
			fragments.code('...')
		}

		if @computed {
			fragments.code('[').compile(@name).code(']: ').compile(@alias)
		}
		else if @name != @alias {
			fragments.compile(@name).code(': ').compile(@alias)
		}
		else {
			fragments.compile(@alias)
		}

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} // }}}
	toExistFragments(fragments, name) { // {{{
		if @rest {
			fragments.code('...')
		}

		if @computed {
			fragments.code('[').compile(@name).code(']: ', name)
		}
		else {
			fragments.compile(@name).code(': ', name)
		}

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if @alias is ObjectBinding {
			@alias.toFlatFragments(fragments, new FlatObjectBindingElement(value, @name, this))
		}
		else if @hasDefaultValue {
			fragments
				.compile(@alias)
				.code($equals, $runtime.helper(this), '.default(')
				.wrap(value)
				.code('.')
				.compile(@name)
				.code($comma)
				.compile(@defaultValue)
				.code(')')
		}
		else {
			fragments
				.compile(@alias)
				.code($equals)
				.wrap(value)
				.code('.')
				.compile(@name)
		}
	} // }}}
	walk(fn) { // {{{
		@alias.walk(fn)
	} // }}}
}