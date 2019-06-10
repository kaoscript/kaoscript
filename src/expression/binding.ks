class ArrayBinding extends Expression {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_elements						= []
		_flatten: Boolean				= false
		_immutable: Boolean				= false
	}
	analyse() { // {{{
		@flatten = @options.format.destructuring == 'es5'

		for element, index in @data.elements {
			@elements.push(element = $compile.expression(element, this, this.bindingScope()))

			element.setAssignment(@assignment)

			element.analyse()

			if element is BindingElement {
				element.index(index)
			}
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

class BindingElement extends Expression {
	private {
		_alias
		_assignment: AssignmentType		= AssignmentType::Neither
		_defaultValue					= null
		_hasDefaultValue: Boolean		= false
		_index							= -1
		_name
	}
	analyse() { // {{{
		@name = $compile.expression(@data.name, this)
		@name.setAssignment(@assignment)
		@name.analyse()

		if @data.alias? {
			@alias = $compile.expression(@data.alias, this)
		}

		if @data.defaultValue? {
			@hasDefaultValue = true

			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
		}
	} // }}}
	prepare() { // {{{
		@name.prepare()

		if @hasDefaultValue {
			@defaultValue.prepare()
		}

		this.statement().assignTempVariables(@scope)
	} // }}}
	translate() { // {{{
		@name.translate()
		@defaultValue.translate() if @hasDefaultValue
	} // }}}
	export(recipient) => @name.export(recipient)
	hasDefaultValue() => @hasDefaultValue
	index(@index) => this
	isImmutable() => @parent.isImmutable()
	isDeclararingVariable(name: String) => @name.isDeclararingVariable(name)
	isRedeclared() => @name.isRedeclared()
	listAssignments(array) => @name.listAssignments(array)
	setAssignment(@assignment)
	toFragments(fragments) { // {{{
		if @data.spread {
			fragments.code('...')
		}

		if @alias? {
			if @data.alias.computed {
				fragments.code('[').compile(@alias).code(']: ')
			}
			else {
				fragments.compile(@alias).code(': ')
			}
		}

		fragments.compile(@name)

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} // }}}
	toExistFragments(fragments, name) { // {{{
		if @data.spread {
			fragments.code('...')
		}

		if @alias? {
			if @data.alias.computed {
				fragments.code('[').compile(@alias).code(']: ')
			}
			else {
				fragments.compile(@alias).code(': ')
			}
		}

		if @index == -1 {
			fragments.compile(@name).code(': ', name)
		}
		else {
			fragments.code(name)
		}

		if @defaultValue != null {
			fragments.code(' = ').compile(@defaultValue)
		}
	} // }}}
	toFlatFragments(fragments, value) { // {{{
		if @name is ArrayBinding {
			@name.toFlatFragments(fragments, new FlatArrayBindingElement(value, @index, this))
		}
		else if @name is ObjectBinding {
			@name.toFlatFragments(fragments, new FlatObjectBindingElement(value, @alias ?? @name, this))
		}
		else if @hasDefaultValue {
			fragments
				.compile(@name)
				.code($equals, $runtime.helper(this), '.default(')
				.wrap(new FlatObjectBindingElement(value, @alias ?? @name, this))
				.code($comma)
				.compile(@defaultValue)
				.code(')')
		}
		else if @index == -1 {
			fragments
				.compile(@name)
				.code($equals)
				.wrap(value)
				.code('.')
				.compile(@alias ?? @name)
		}
		else {
			fragments
				.compile(@name)
				.code($equals)
				.wrap(value)
				.code(`[\(@index)]`)
		}
	} // }}}
	walk(fn) { // {{{
		@name.walk(fn)
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

		for let element in @data.elements {
			@elements.push(element = $compile.expression(element, this, this.bindingScope()))

			element.setAssignment(@assignment)

			element.analyse()

			if element.hasDefaultValue() {
				@flatten = true
			}
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