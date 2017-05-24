class MemberExpression extends Expression {
	private {
		_callee
		_object
		_prepareObject: Boolean	= true
		_property
		_tested: Boolean		= false
		_type: Type
	}
	constructor(@data, @parent, @scope, @object) {
		super(data, parent, scope)
		
		@prepareObject = false
	}
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
				else {
					@type = Type.Any
				}
			}
			else {
				@property = @data.property.name
				
				const type = @object.type()
				
				if @type !?= type.getProperty(@property) {
					if type is EnumType {
						SyntaxException.throwInvalidEnumAccess(this)
					}
					else {
						ReferenceException.throwNotDefinedProperty(@property, this)
					}
				}
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
		@object.acquireReusable(@data.nullable || acquire)
	} // }}}
	caller() => @object
	isCallable() => @object.isCallable()
	isComputed() => this.isNullable() && !@tested
	isEntangled() =>this.isCallable() || this.isNullable()
	isNullable() => @data.nullable || @object.isNullable() || (@data.computed && @property.isNullable())
	isNullableComputed() => (@object.isNullable() ? 1 : 0) + (@data.nullable ? 1 : 0) + (@data.computed && @property.isNullable() ? 1 : 0) > 1
	releaseReusable() { // {{{
		@object.releaseReusable()
	} // }}}
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
			if @object.isComputed() || @object._data.kind == NodeKind::NumericExpression {
				fragments.code('(').compile(@object).code(')')
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
		if @object.isCallable() {
			if @data.computed {
				fragments
					.code('(')
					.compileReusable(@object)
					.code(', ')
					.compile(@object)
					.code('[')
					.compileReusable(@property)
					.code(']')
					.code(')')
			}
			else {
				fragments
					.code('(')
					.compileReusable(@object)
					.code(', ')
					.compile(@object)
					.code($dot)
					.compile(@property)
					.code(')')
			}
		}
		else if @data.computed {
			fragments
				.wrap(@object)
				.code('[')
				.compileReusable(@property)
				.code(']')
		}
		else {
			fragments
				.wrap(@object)
				.code($dot)
				.compile(@property)
		}
	} // }}}
	type() => @type
}