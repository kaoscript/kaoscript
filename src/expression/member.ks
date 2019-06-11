class MemberExpression extends Expression {
	private {
		_callee
		_object
		_prepareObject: Boolean	= true
		_property
		_tested: Boolean		= false
		_type: Type				= Type.Any
	}
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope)
	} // }}}
	constructor(@data, @parent, @scope, @object) { // {{{
		super(data, parent, scope)

		@prepareObject = false
	} // }}}
	analyse() { // {{{
		if @prepareObject {
			@object = $compile.expression(@data.object, this)
			@object.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @prepareObject {
			@object.prepare()

			if @data.computed {
				@property = $compile.expression(@data.property, this)

				@property.analyse()
				@property.prepare()

				if @object.type().isArray() {
					@type = @object.type().parameter()
				}
			}
			else {
				@property = @data.property.name

				const type = @object.type()

				if property !?= type.getProperty(@property) {
					if type.isEnum() {
						SyntaxException.throwInvalidEnumAccess(this)
					}
					else {
						ReferenceException.throwNotDefinedProperty(@property, this)
					}
				}

				@type = property.discardVariable()
			}
		}
		else if @data.computed {
			@property = $compile.expression(@data.property, this)
			@property.analyse()
			@property.prepare()
		}
		else {
			@property = @data.property.name
		}
	} // }}}
	translate() { // {{{
		@object.translate()

		if @data.computed {
			@property.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @object.isCallable() {
			@object.acquireReusable(@data.nullable || acquire)
		}

		if @data.computed && @property is not String && @property.isCallable() {
			@property.acquireReusable(@data.nullable || acquire)
		}
	} // }}}
	caller() => @object
	isCallable() => @object.isCallable() || (@data.computed && @property.isCallable())
	isComputed() => this.isNullable() && !@tested
	isLooseComposite() => this.isCallable() || this.isNullable()
	isMacro() => false
	isNullable() => @data.nullable || @object.isNullable() || (@data.computed && @property.isNullable())
	isNullableComputed() => (@object.isNullable() ? 1 : 0) + (@data.nullable ? 1 : 0) + (@data.computed && @property.isNullable() ? 1 : 0) > 1
	isUsingVariable(name) => @object.isUsingVariable(name)
	listAssignments(array) => array
	releaseReusable() { // {{{
		if @object.isCallable() {
			@object.releaseReusable()
		}

		if @data.computed && @property is not String && @property.isCallable() {
			@property.releaseReusable()
		}
	} // }}}
	setAssignment(assignment)
	toFragments(fragments, mode) { // {{{
		if this.isNullable() && !@tested {
			fragments.wrapNullable(this).code(' ? ').compile(@object)

			if @data.computed {
				fragments.code('[').compile(@property).code('] : undefined')
			}
			else {
				fragments.code($dot).compile(@property).code(' : undefined')
			}
		}
		else {
			const type = @object.type()

			if @object.isComputed() || @object._data.kind == NodeKind::NumericExpression {
				fragments.code('(').compile(@object).code(')')
			}
			else if type.isNamespace() && type.isSealed() && type.type().isSealedProperty(@property) {
				fragments.code(type.getSealedName())
			}
			else {
				fragments.compile(@object)
			}

			if @data.computed {
				fragments.code('[').compile(@property).code(']')
			}
			else {
				fragments.code($dot).compile(@property)
			}

			if @type is ClassMethodSetType {
				if @parent is not UnaryOperatorExpression {
					fragments.code('.bind(').compile(@object).code(')')
				}
			}
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if this.isNullable() && !@tested {
			if @data.computed {
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(@object)
					.code('[')
					.compile(@property)
					.code(']')
					.code(' : false')
			}
			else {
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(@object)
					.code($dot)
					.compile(@property)
					.code(' : false')
			}
		}
		else {
			if @data.computed {
				fragments
					.wrap(@object)
					.code('[')
					.compile(@property)
					.code(']')
			}
			else {
				fragments
					.wrap(@object)
					.code($dot)
					.compile(@property)
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			@tested = true

			let conditional = false

			if @object.isNullable() {
				fragments.compileNullable(@object)

				conditional = true
			}

			if @data.nullable {
				fragments.code(' && ') if conditional

				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(@object)
					.code(')')

				conditional = true
			}

			if @data.computed && @property.isNullable() {
				fragments.code(' && ') if conditional

				fragments.compileNullable(@property)
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		const objectCallable = @object.isCallable()

		if objectCallable {
			fragments
				.code('(')
				.compileReusable(@object)
				.code(', ')
				.compile(@object)
		}
		else {
			fragments.wrap(@object)
		}

		if @data.computed {
			if @property.isCallable() {
				fragments
					.code('[')
					.compileReusable(@property)
					.code(']')
			}
			else {
				fragments
					.code('[')
					.compile(@property)
					.code(']')
			}
		}
		else {
			fragments.code($dot).compile(@property)
		}

		if objectCallable {
			fragments.code(')')
		}
	} // }}}
	type() => @type
}