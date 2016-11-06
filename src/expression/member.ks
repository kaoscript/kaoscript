class MemberExpression extends Expression {
	private {
		_object
		_property
		_tested			= false
	}
	MemberExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._object = $compile.expression(this._data.object, this)
		this._property = $compile.expression(this._data.property, this)
		
		if (this._data.nullable && (this._object.isNullable() || this._object.isCallable())) || this._property.isNullable() {
			this._object.analyseReusable()
		}
	} // }}}
	analyseReusable() { // {{{
		this._object.analyseReusable()
	} // }}}
	fuse() { // {{{
		this._object.fuse()
	} // }}}
	isCallable() => this._object.isCallable()
	isEntangled() => this.isCallable() || this.isNullable()
	isNullable() => this._data.nullable || this._object.isNullable() || (this._data.computed && this._property.isNullable())
	toFragments(fragments, mode) { // {{{
		if this.isNullable() && !this._tested {
			fragments.wrapNullable(this).code(' ? ').compile(this._object)
			
			if this._data.computed {
				fragments.code('[').compile(this._property).code('] : undefined')
			}
			else {
				fragments.code($dot).compile(this._property).code(' : undefined')
			}
		}
		else {
			if this._object.isComputed() || this._object._data.kind == Kind::NumericExpression {
				fragments.code('(').compile(this._object).code(')')
			}
			else {
				fragments.compile(this._object)
			}
			
			if this._data.computed {
				fragments.code('[').compile(this._property).code(']')
			}
			else {
				fragments.code($dot).compile(this._property)
			}
		}
	} // }}}
	toBooleanFragments(fragments) { // {{{
		if this.isNullable() && !this._tested {
			if this._data.computed {
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(this._object)
					.code('[')
					.compile(this._property)
					.code(']')
					.code(' : false')
			}
			else {
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(this._object)
					.code($dot)
					.compile(this._property)
					.code(' : false')
			}
		}
		else {
			if this._data.computed {
				fragments
					.compile(this._object)
					.code('[')
					.compile(this._property)
					.code(']')
			}
			else {
				fragments
					.compile(this._object)
					.code($dot)
					.compile(this._property)
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			this._tested = true
			
			let conditional = false
			
			if this._object.isNullable() {
				fragments.compileNullable(this._object)
				
				conditional = true
			}
			
			if this._data.nullable {
				fragments.code(' && ') if conditional
				
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(this._object)
					.code(')')
				
				conditional = true
			}
			
			if this._data.computed && this._property.isNullable() {
				fragments.code(' && ') if conditional
				
				fragments.compileNullable(this._property)
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		if this._object.isCallable() {
			if this._data.computed {
				fragments
					.code('(')
					.compileReusable(this._object)
					.code(', ')
					.compile(this._object)
					.code('[')
					.compileReusable(this._property)
					.code(']')
					.code(')')
			}
			else {
				fragments
					.code('(')
					.compileReusable(this._object)
					.code(', ')
					.compile(this._object)
					.code($dot)
					.compile(this._property)
					.code(')')
			}
		}
		else if this._data.computed {
			fragments
				.compile(this._object)
				.code('[')
				.compileReusable(this._property)
				.code(']')
		}
		else {
			fragments
				.compile(this._object)
				.code($dot)
				.compile(this._property)
		}
	} // }}}
}