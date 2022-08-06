class ArrayBinding extends Expression {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_elements						= []
		_flatten: Boolean				= false
		_immutable: Boolean				= false
		_type: Type?					= null
	}
	analyse() { # {{{
		@flatten = @options.format.destructuring == 'es5'

		for var data, index in @data.elements {
			var element = this.newElement(data)

			element.setAssignment(@assignment)

			element.index(index)

			element.analyse()

			if element.isThisAliasing() && @assignment != AssignmentType::Parameter {
				@flatten = true
			}

			@elements.push(element)
		}
	} # }}}
	prepare() { # {{{
		if @type == null {
			for var element in @elements {
				element.prepare()
			}

			@type = @scope.reference('Array')
		}
		else if @type is ArrayType {
			if @type.length() < @elements.length {
				ReferenceException.throwBindingExceedArray(@elements.length, @type.length(), this)
			}

			for var element, index in @elements {
				element.type(@type.getElement(index))

				element.prepare()
			}
		}
		else if @type.isTuple() {
			var type = @type.discard()

			if type.length() < @elements.length {
				ReferenceException.throwBindingExceedArray(@elements.length, type.length(), this)
			}

			for var element, index in @elements {
				element.type(type.getProperty(index).type())

				element.prepare()
			}
		}
		else {
			var type = @type.parameter()

			for var element in @elements {
				element.type(type)

				element.prepare()
			}
		}
	} # }}}
	translate() { # {{{
		for var element in @elements {
			element.translate()
		}
	} # }}}
	export(recipient) { # {{{
		for element in @elements {
			element.export(recipient)
		}
	} # }}}
	flagImmutable() { # {{{
		@immutable = true
	} # }}}
	initializeVariables(type: Type, node: Expression) { # {{{
		for var element in @elements {
			element.initializeVariables(type, node)
		}
	} # }}}
	isAssignable() => true
	isDeclarable() => true
	isImmutable() => @immutable
	isDeclararingVariable(name: String) { # {{{
		for element in @elements {
			if element.isDeclararingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isRedeclared() { # {{{
		for var element in @elements {
			if element.isRedeclared() {
				return true
			}
		}

		return false
	} # }}}
	isSplitAssignment() => @flatten && @elements.length > 1
	listAssignments(array: Array<String>) { # {{{
		for var element in @elements {
			element.listAssignments(array)
		}

		return array
	} # }}}
	name() => null
	newElement(data) => new ArrayBindingElement(data, this, @scope)
	setAssignment(@assignment)
	toFragments(fragments, mode) { # {{{
		fragments.code('[')

		for i from 0 til @elements.length {
			fragments.code(', ') if i != 0

			@elements[i].toFragments(fragments)
		}

		fragments.code(']')
	} # }}}
	toAssignmentFragments(fragments, value) { # {{{
		if @flatten {
			this.toFlatFragments(fragments, value)
		}
		else {
			fragments
				.compile(this)
				.code($equals)
				.compile(value)
		}
	} # }}}
	toFlatFragments(fragments, value) { # {{{
		if @elements.length == 1 {
			@elements[0].toFlatFragments(fragments, value)
		}
		else {
			var reusableValue = new TempReusableExpression(value, this)

			var mut comma = false
			for var element in @elements when !element.isAnonymous() {
				if comma {
					fragments.code(', ')
				}
				else {
					comma = true
				}

				element.toFlatFragments(fragments, reusableValue)
			}
		}
	} # }}}
	type() => @type
	type(@type) => this
	type(type: Type, scope: Scope, node)
	walk(fn) { # {{{
		for element in @elements {
			element.walk(fn)
		}
	} # }}}
}

class ArrayBindingElement extends Expression {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_defaultValue					= null
		_hasDefaultValue: Boolean		= false
		_index							= -1
		_name							= null
		_named: Boolean					= false
		_rest: Boolean					= false
		_thisAlias: Boolean				= false
		_type: Type						= AnyType.NullableUnexplicit
	}
	analyse() { # {{{
		if @data.name? {
			@name = this.compileVariable(@data.name)
			@name.setAssignment(@assignment)
			@name.analyse()

			@named = true

			if @data.defaultValue? {
				@hasDefaultValue = true

				@defaultValue = $compile.expression(@data.defaultValue, this)
				@defaultValue.analyse()
			}

			@thisAlias = @data.name.kind == NodeKind::ThisExpression
		}

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Rest {
				@rest = true
			}
		}
	} # }}}
	prepare() { # {{{
		if @data.type? {
			@type = Type.fromAST(@data.type, this)
		}

		if @named {
			@name.prepare()

			if @hasDefaultValue {
				@defaultValue.prepare()
			}

			if @name is IdentifierLiteral {
				var variable = @name.variable()

				variable.setDeclaredType(@type)

				if @assignment == AssignmentType::Declaration {
					variable.setRealType(@type)
				}
				else if @hasDefaultValue {
					variable.setRealType(@defaultValue.type())
				}
			}
			else {
				@name.type(@type)
			}
		}

		this.statement().assignTempVariables(@scope)
	} # }}}
	translate() { # {{{
		if @named {
			@name.translate()

			if @hasDefaultValue {
				@defaultValue.translate()
			}
		}
	} # }}}
	compileVariable(data) => $compile.expression(data, this)
	export(recipient) => @named ? @name.export(recipient) : null
	index(@index) => this
	initializeVariables(type: Type, node: Expression) { # {{{
		if var name = @name.name() {
			@name.initializeVariables(type.getProperty(name) ?? AnyType.NullableUnexplicit, node)
		}
	} # }}}
	isImmutable() => @parent.isImmutable()
	isDeclararingVariable(name: String) => @named ? @name.isDeclararingVariable(name) : false
	isAnonymous() => !@named
	isRedeclared() => @named ? @name.isRedeclared() : false
	isRest() => @rest
	isThisAliasing() => @thisAlias
	listAssignments(array: Array<String>) => @named ? @name.listAssignments(array) : array
	max() => @rest ? Infinity : 1
	min() => @rest ? 0 : 1
	setAssignment(@assignment)
	toFragments(fragments) { # {{{
		if @rest {
			fragments.code('...')
		}

		if @named {
			fragments.compile(@name)

			if @defaultValue != null {
				fragments.code(' = ').compile(@defaultValue)
			}
		}
	} # }}}
	toExistFragments(fragments, name) { # {{{
		if @rest {
			fragments.code('...')
		}

		if @named {
			if @defaultValue != null {
				fragments.code(' = ').compile(@defaultValue)
			}
		}
	} # }}}
	toFlatFragments(fragments, value) { # {{{
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
	} # }}}
	type() => @type
	type(@type) => this
	walk(fn) { # {{{
		if @named {
			@name.walk(fn)
		}
	} # }}}
}

class FlatArrayBindingElement extends Expression {
	private {
		_array
		_index
	}
	constructor(@array, @index, parent) { # {{{
		super({}, parent)
	} # }}}
	analyse()
	prepare()
	translate()
	isComposite() => false
	toFragments(fragments, mode) { # {{{
		fragments
			.wrap(@array)
			.code('[')
			.compile(@index)
			.code(']')
	} # }}}
}

class FlatObjectBindingElement extends Expression {
	private {
		_item
		_property
	}
	constructor(@item, @property, parent) { # {{{
		super({}, parent)
	} # }}}
	analyse()
	prepare()
	translate()
	isComposite() => false
	toFragments(fragments, mode) { # {{{
		fragments
			.wrap(@item)
			.code('.')
			.compile(@property)
	} # }}}
}

class FlatReusableBindingElement extends Expression {
	private {
		_value
	}
	constructor(@value, parent) { # {{{
		super({}, parent)
	} # }}}
	analyse()
	prepare()
	translate()
	isComposite() => false
	toFragments(fragments, mode) { # {{{
		fragments
			.code('(')
			.compileReusable(@value)
			.code(')')
	} # }}}
}

class ObjectBinding extends Expression {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_elements						= []
		_flatten: Boolean				= false
		_immutable: Boolean				= false
		_type: Type?					= null
	}
	analyse() { # {{{
		@flatten = @options.format.destructuring == 'es5'

		for var data in @data.elements {
			var element = this.newElement(data)

			element.setAssignment(@assignment)

			element.analyse()

			if element.hasDefaultValue() || (element.isThisAliasing() && @assignment != AssignmentType::Parameter) {
				@flatten = true
			}

			@elements.push(element)
		}
	} # }}}
	prepare() { # {{{
		if @type == null {
			@type = new DestructurableObjectType()

			for var element in @elements {
				element.prepare()

				if element is ObjectBindingElement {
					@type.addProperty(element.name(), element.type())
				}
			}
		}
		else if @type is DictionaryType {
			for var element in @elements {
				if element.isRequired() {
					if var property = @type.getProperty(element.name()) {
						element.type(property)
					}
					else {
						ReferenceException.throwUndefinedBindingVariable(element.name(), this)
					}
				}

				element.prepare()
			}
		}
		else if @type.isStruct() {
			var type = @type.discard()

			for var element in @elements {
				if element.isRequired() {
					if var property = type.getProperty(element.name()) {
						element.type(property.type())
					}
					else {
						ReferenceException.throwUndefinedBindingVariable(element.name(), this)
					}
				}

				element.prepare()
			}
		}
		else {
			var type = @type.parameter()

			for var element in @elements {
				element.type(type)

				element.prepare()
			}
		}
	} # }}}
	translate() { # {{{
		for element in @elements {
			element.translate()
		}
	} # }}}
	export(recipient) { # {{{
		for element in @elements {
			element.export(recipient)
		}
	} # }}}
	flagImmutable() { # {{{
		@immutable = true
	} # }}}
	initializeVariables(type: Type, node: Expression) { # {{{
		for var element in @elements {
			element.initializeVariables(type, node)
		}
	} # }}}
	isAssignable() => true
	isDeclarable() => true
	isImmutable() => @immutable
	isDeclararingVariable(name: String) { # {{{
		for element in @elements {
			if element.isDeclararingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isRedeclared() { # {{{
		for var element in @elements {
			if element.isRedeclared() {
				return true
			}
		}

		return false
	} # }}}
	isSplitAssignment() => @flatten && @elements.length > 1
	listAssignments(array: Array<String>) { # {{{
		for var element in @elements {
			element.listAssignments(array)
		}

		return array
	} # }}}
	name() => null
	newElement(data) => new ObjectBindingElement(data, this, @scope)
	setAssignment(@assignment)
	toFragments(fragments, mode) { # {{{
		fragments.code('{')

		for i from 0 til @elements.length {
			fragments.code(', ') if i != 0

			@elements[i].toFragments(fragments)
		}

		fragments.code('}')
	} # }}}
	toAssignmentFragments(fragments, value) { # {{{
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
	} # }}}
	toFlatFragments(fragments, value) { # {{{
		if @elements.length == 1 {
			@elements[0].toFlatFragments(fragments, value)
		}
		else {
			var reusableValue = new TempReusableExpression(value, this)

			@elements[0].toFlatFragments(fragments, reusableValue)

			for var element in @elements from 1 {
				fragments.code(', ')

				element.toFlatFragments(fragments, reusableValue)
			}
		}
	} # }}}
	override toQuote() { # {{{
		var mut fragments = '{'

		for var element, index in @elements {
			if index != 0 {
				fragments += ', '
			}

			fragments += element.name()
		}

		fragments += '}'

		return fragments
	} # }}}
	type() => @type
	type(@type) => this
	type(type: Type, scope: Scope, node)
	walk(fn) { # {{{
		for element in @elements {
			element.walk(fn)
		}
	} # }}}
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
		_sameName: Boolean				= false
		_thisAlias: Boolean				= false
		_type: Type						= AnyType.NullableUnexplicit
	}
	analyse() { # {{{
		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Computed {
				@computed = true

				break
			}
		}

		if @data.alias? {
			@name = $compile.expression(@data.name, this)

			@alias = this.compileVariable(@data.alias)

			@thisAlias = @data.alias.kind == NodeKind::ThisExpression
		}
		else if @data.name.kind == NodeKind::ThisExpression {
			@name = $compile.expression(@data.name.name, this)

			@alias = this.compileVariable(@data.name)

			@thisAlias = true
			@sameName = true
		}
		else {
			@name = this.compileVariable(@data.name)

			@alias = @name
			@sameName = true
		}

		@alias.setAssignment(@assignment)
		@alias.analyse()

		if @data.defaultValue? {
			@hasDefaultValue = true

			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
		}

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Rest {
				@rest = true
			}
		}
	} # }}}
	prepare() { # {{{
		if @data.type? {
			@type = Type.fromAST(@data.type, this)
		}

		@alias.prepare()

		if @hasDefaultValue {
			@defaultValue.prepare()
		}

		if @alias is IdentifierLiteral {
			var variable = @alias.variable()

			variable.setDeclaredType(@type)

			if @assignment == AssignmentType::Declaration {
				variable.setRealType(@type)
			}
			else if @hasDefaultValue {
				variable.setRealType(@defaultValue.type())
			}
		}
		else if @alias is not ThisExpression {
			@alias.type(@type)
		}

		this.statement().assignTempVariables(@scope)
	} # }}}
	translate() { # {{{
		@alias.translate()

		if @hasDefaultValue {
			@defaultValue.translate()
		}
	} # }}}
	compileVariable(data) => $compile.expression(data, this)
	export(recipient) => @alias.export(recipient)
	hasDefaultValue() => @hasDefaultValue
	initializeVariables(type: Type, node: Expression) { # {{{
		@alias.initializeVariables(type.getProperty(@name.name()) ?? AnyType.NullableUnexplicit, node)
	} # }}}
	isImmutable() => @parent.isImmutable()
	isDeclararingVariable(name: String) => @alias.isDeclararingVariable(name)
	isRedeclared() => @alias.isRedeclared()
	isRequired() => !(@computed || @rest || @hasDefaultValue)
	isThisAliasing() => @thisAlias
	listAssignments(array: Array<String>) => @alias.listAssignments(array)
	name(): String => @name.value()
	setAssignment(@assignment)
	toFragments(fragments) { # {{{
		if @rest {
			fragments.code('...')
		}

		if $keywords[this.name()] {
			if @computed {
				fragments.code(`[\(this.name())]: `).compile(@alias)
			}
			else {
				fragments.code(`\(this.name()): `).compile(@alias)
			}
		}
		else {
			if @computed {
				fragments.code('[').compile(@name).code(']: ').compile(@alias)
			}
			else if @sameName {
				fragments.compile(@alias)
			}
			else {
				fragments.compile(@name).code(': ').compile(@alias)
			}
		}

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} # }}}
	toExistFragments(fragments, name) { # {{{
		if @rest {
			fragments.code('...')
		}

		if $keywords[this.name()] {
			if @computed {
				fragments.code(`[\(this.name())]: \(name)`)
			}
			else {
				fragments.code(`\(this.name()): \(name)`)
			}
		}
		else {
			if @computed {
				fragments.code('[').compile(@name).code(']: ', name)
			}
			else {
				fragments.compile(@name).code(': ', name)
			}
		}

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} # }}}
	toFlatFragments(fragments, value) { # {{{
		if @alias is ObjectBinding {
			@alias.toFlatFragments(fragments, new FlatObjectBindingElement(value, @name, this))
		}
		else if $keywords[this.name()] {
			if @hasDefaultValue {
				fragments
					.compile(@alias)
					.code($equals, $runtime.helper(this), '.default(')
					.wrap(value)
					.code('.')
					.code(this.name())
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
					.code(this.name())
			}
		}
		else {
			if @hasDefaultValue {
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
		}
	} # }}}
	type() => @type
	type(@type) => this
	walk(fn) { # {{{
		@alias.walk(fn)
	} # }}}
}
