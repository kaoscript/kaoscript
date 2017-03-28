class ArrayBinding extends Expression {
	private {
		_elements			= []
		_existing			= {}
		_existingCount		= 0
		_nonexisting		= {}
		_nonexistingCount	= 0
		_variables			= {}
	}
	analyse() { // {{{
		for element, index in @data.elements {
			if element.kind == NodeKind::BindingElement && !element.name.computed {
				if @scope.hasVariable(element.name.name) {
					@existing[element.name.name] = true
					++@existingCount
				}
				else {
					@nonexisting[element.name.name] = true
					++@nonexistingCount
				}
			}
			
			@elements.push(element = $compile.expression(element, this))
			
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
	toFragments(fragments, mode) { // {{{
		if @existingCount && @nonexistingCount {
			fragments.code('[')
			
			let name
			for element, i in @data.elements {
				fragments.code(', ') if i
				
				if element.kind == NodeKind::BindingElement && !element.name.computed && @existing[element.name.name] {
					name = @scope.acquireTempName()
					
					@elements[i].toExistFragments(fragments, name)
					
					@variables[name] = element.name.name
				}
				else {
					@elements[i].toFragments(fragments)
				}
			}
			
			fragments.code(']')
			
			this.statement().afterward(this)
		}
		else {
			fragments.code('[')
			
			for i from 0 til @elements.length {
				fragments.code(', ') if i
				
				@elements[i].toFragments(fragments)
			}
			
			fragments.code(']')
		}
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		for name, variable of @variables {
			fragments.line(variable, ' = ', name)
			
			@scope.releaseTempName(name)
		}
	} // }}}
	toAssignmentFragments(fragments, value) { // {{{
		if @nonexistingCount {
			fragments.code('var ')
		}
		
		if @options.format.destructuring == 'es5' {
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
		if value.isComposite() {
			if @elements.length == 1 {
				@elements[0].toFlatFragments(fragments, value)
			}
			else {
				/* let variable = new IdentifierLiteral({
					kind: NodeKind::Identifier
					name: @name
				}, this, @scope, false)
				
				@elements[0].toFlatFragments(fragments, new TempBinding(variable, value, this))
				
				for i from 1 til @elements.length {
					fragments.code(', ')
					
					@elements[i].toFlatFragments(fragments, variable)
				} */
				throw new NotImplementedException(this)
			}
		}
		else {
			for i from 0 til @elements.length {
				fragments.code(', ') if i
				
				@elements[i].toFlatFragments(fragments, value)
			}
		}
	} // }}}
	type() => Type.Any
}

class BindingElement extends Expression {
	private {
		_alias
		_defaultValue	 = null
		_index			= -1
		_name
		_variable
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
		const scope = this.statement().scope()
		
		if @data.name.kind == NodeKind::Identifier && !scope.hasVariable(@data.name.name) {
			$variable.define(this.statement(), scope, @data.name, false, VariableKind::Variable)
		}
		
		if @data.alias? {
			$variable.define(this, @scope, @data.alias, false, VariableKind::Variable)
			
			@alias = $compile.expression(@data.alias, this)
			@alias.analyse()
		}
		
		@name = $compile.expression(@data.name, this)
		@name.analyse()
		
		if @data.defaultValue? {
			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
			
			if @options.format.destructuring == 'es5' {
				@variable = @scope.acquireTempName(this.statement())
				
				@scope.releaseTempName(@variable)
			}
		}
	} // }}}
	prepare() { // {{{
		@alias.prepare() if @alias?
		@name.prepare()
		@defaultValue.prepare() if @defaultValue?
	} // }}}
	translate() { // {{{
		@alias.translate() if @alias?
		@name.translate()
		@defaultValue.translate() if @defaultValue?
	} // }}}
	index(@index) => this
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
		
		if @defaultValue? {
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
		if @name is ObjectBinding {
			@name.toFlatFragments(fragments, new FlatBindingElement(value, @alias ?? @name, this))
		}
		else if @defaultValue? {
			let variable = new IdentifierLiteral({
				kind: NodeKind::Identifier
				name: @variable
			}, this, @scope, false)
			
			fragments
				.compile(@name)
				.code($equals, 'Type.isValue(')
				.compile(variable)
				.code($equals)
				.compile(new FlatBindingElement(value, @alias ?? @name, this))
				.code(') ? ')
				.compile(variable)
				.code(' : ')
				.compile(@defaultValue)
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
	type() => Type.Any
}

class FlatBindingElement extends Expression {
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
	type() => Type.Any
}

class ObjectBinding extends Expression {
	private {
		_elements			= []
		_exists				= false
		_existing			= {}
		_name				= null
		_variables			= {}
	}
	analyse() { // {{{
		if @options.format.destructuring == 'es5' && @data.elements.length > 1 {
			@name = @scope.acquireTempName(this.statement())
		}
		
		for element in @data.elements {
			if !element.name.computed && element.name.name? && @scope.hasVariable(element.name.name) {
				@exists = true
				@existing[element.name.name] = true
			}
			
			@elements.push(element = $compile.expression(element, this))
			
			element.analyse()
		}
		
		if @name != null {
			@scope.releaseTempName(@name)
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
	toFragments(fragments, mode) { // {{{
		if @exists {
			fragments.code('{')
			
			let name
			for element, i in @data.elements {
				fragments.code(', ') if i
				
				if @existing[element.name.name] {
					name = @scope.acquireTempName()
					
					@elements[i].toExistFragments(fragments, name)
					
					@variables[name] = element.name.name
				}
				else {
					@elements[i].toFragments(fragments)
				}
			}
			
			fragments.code('}')
			
			this.statement().afterward(this)
		}
		else {
			fragments.code('{')
			
			for i from 0 til @elements.length {
				fragments.code(', ') if i
				
				@elements[i].toFragments(fragments)
			}
			
			fragments.code('}')
		}
	} // }}}
	toAfterwardFragments(fragments) { // {{{
		for name, variable of @variables {
			fragments.line(variable, ' = ', name)
			
			@scope.releaseTempName(name)
		}
	} // }}}
	toAssignmentFragments(fragments, value) { // {{{
		fragments.code('var ')
		
		if @options.format.destructuring == 'es5' {
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
		if value.isComposite() {
			if @elements.length == 1 {
				@elements[0].toFlatFragments(fragments, value)
			}
			else {
				let variable = new IdentifierLiteral({
					kind: NodeKind::Identifier
					name: @name
				}, this, @scope, false)
				
				@elements[0].toFlatFragments(fragments, new TempBinding(variable, value, this))
				
				for i from 1 til @elements.length {
					fragments.code(', ')
					
					@elements[i].toFlatFragments(fragments, variable)
				}
			}
		}
		else {
			for i from 0 til @elements.length {
				fragments.code(', ') if i
				
				@elements[i].toFlatFragments(fragments, value)
			}
		}
	} // }}}
	type() => Type.Any
}

class TempBinding extends Expression {
	private {
		_name
		_value
	}
	constructor(@name, @value, parent) { // {{{
		super({}, parent)
	} // }}}
	analyse()
	prepare()
	translate()
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		fragments
			.compile(@name)
			.code($equals)
			.compile(@value)
	} // }}}
	type() => Type.Any
}