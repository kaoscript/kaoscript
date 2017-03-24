class MemberExpression extends Expression {
	private {
		_callee
		_object
		_property
		_sealed			= false
		_tested			= false
	}
	analyse() { // {{{
		@object = $compile.expression(@data.object, this)
		@object.analyse()
	} // }}}
	prepare() { // {{{
		if (@callee = $sealed.callee(@data, @parent)) != false {
			@sealed = true
		}
		else {
			@object.prepare()
			
			@property = $compile.expression(@data.property, this)
			
			@property.analyse()
			
			@property.prepare()
		}
	} // }}}
	translate() { // {{{
		if !@sealed {
			@object.translate()
			
			@property.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @sealed {
			if acquire {
				throw new NotImplementedException(this)
			}
		}
		else {
			@object.acquireReusable(@data.nullable || acquire)
		}
	} // }}}
	isCallable() => @sealed ? false : @object.isCallable()
	isComputed() => @sealed ? false : this.isNullable() && !@tested
	isEntangled() => @sealed ? true : this.isCallable() || this.isNullable()
	isNullable() => @sealed ? false : @data.nullable || @object.isNullable() || (@data.computed && @property.isNullable())
	isNullableComputed() => @sealed ? false : (@object.isNullable() ? 1 : 0) + (@data.nullable ? 1 : 0) + (@data.computed && @property.isNullable() ? 1 : 0) > 1
	releaseReusable() { // {{{
		if !@sealed {
			@object.releaseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @sealed {
			if @callee.variable.accessPath? {
				fragments.code(@callee.variable.accessPath)
			}
			
			fragments.code(@callee.variable.sealed.name + '.' + @data.property.name)
		}
		else {
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
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if @sealed {
			throw new NotImplementedException(this)
		}
		else {
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
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if @sealed {
			throw new NotImplementedException(this)
		}
		else {
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
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		if @sealed {
			throw new NotImplementedException(this)
		}
		else {
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
		}
	} // }}}
}