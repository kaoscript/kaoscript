class MemberExpression extends Expression {
	private {
		_assignment: AssignmentType	= AssignmentType::Neither
		_callee
		_computed: Boolean			= false
		_inferable: Boolean			= false
		_nullable: Boolean			= false
		_object
		_path: String
		_prepareObject: Boolean		= true
		_property
		_sealed: Boolean			= false
		_stringProperty: Boolean	= false
		_tested: Boolean			= false
		_type: Type					= AnyType.NullableUnexplicit
		_usingGetter: Boolean		= false
		_usingSetter: Boolean		= false
	}
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope)
	} // }}}
	constructor(@data, @parent, @scope, @object) { // {{{
		super(data, parent, scope)

		@prepareObject = false
	} // }}}
	analyse() { // {{{
		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Computed {
				@computed = true
			}
			else if modifier.kind == ModifierKind::Nullable {
				@nullable = true
			}
		}

		if @prepareObject {
			@object = $compile.expression(@data.object, this)
			@object.analyse()
		}
	} // }}}
	prepare() { // {{{
		if @prepareObject {
			@object.prepare()

			const type = @object.type()

			if type.isNull() && !@nullable && !@options.rules.ignoreMisfit {
				ReferenceException.throwNullExpression(@object, this)
			}

			if @computed {
				@property = $compile.expression(@data.property, this)

				@property.analyse()
				@property.prepare()

				if type.isStruct() {
					if type.isArray() {
						if @property is NumberLiteral {
							if const property = type.discard().getProperty(@property.value()) {
								@type = property.type()
							}
							else if type.isExhaustive(this) {
								ReferenceException.throwNotDefinedProperty(@property.value(), this)
							}
						}
					}
				}
				else if type.isArray() || type.isDictionary() {
					@type = type.parameter()
				}

				if @object.isInferable() {
					if @property is NumberLiteral {
						@inferable = true
						@path = `\(@object.path())[\(@property.value())]`
					}
					else if @property is StringLiteral {
						@inferable = true
						@path = `\(@object.path())['\(@property.value())']`
					}

					if @inferable {
						if const type = @scope.getChunkType(@path) {
							@type = type
						}
					}
				}
			}
			else {
				const isStruct = type.isStruct()
				const isArrayStruct = isStruct && type.isArray()

				@property = @data.property.name

				if 48 <= @property.charCodeAt(0) <= 57 {
					unless isArrayStruct {
						SyntaxException.throwInvalidIdentifier(@property, this)
					}
				}

				if type.isDictionary() {
					@type = type.parameter()
				}

				if isArrayStruct {
					@computed = true
					@stringProperty = true

					if const property = type.getProperty(@property) {
						@property = `\(property.index())`
						@type = property.type()
					}
					else if type.isExhaustive(this) {
						ReferenceException.throwNotDefinedProperty(@property, this)
					}

					if @object.isInferable() {
						@inferable = true
						@path = `\(@object.path())[\(@property)]`
					}
				}
				else if isStruct {
					if const property = type.getProperty(@property) {
						@type = property.type()
					}
					else if type.isExhaustive(this) {
						ReferenceException.throwNotDefinedProperty(@property, this)
					}

					if @object.isInferable() {
						@inferable = true
						@path = `\(@object.path()).\(@property)`
					}
				}
				else {
					if const property = type.getProperty(@property) {
						const type = type.discardReference()
						if type.isClass() && property is ClassVariableType && property.isSealed() {
							@sealed = true
							@usingGetter = property.isInitiatable()
							@usingSetter = property.isInitiatable()
						}

						@type = property.discardVariable()
					}
					else {
						if type.isEnum() {
							SyntaxException.throwInvalidEnumAccess(this)
						}
						else if type.isExhaustive(this) {
							ReferenceException.throwNotDefinedProperty(@property, this)
						}
					}

					if @object.isInferable() {
						@inferable = true
						@path = `\(@object.path()).\(@property)`
					}
				}
			}
		}
		else {
			const type = @object.type()

			if type.isNull() && !@nullable && !@options.rules.ignoreMisfit {
				ReferenceException.throwNullExpression(@object, this)
			}

			if @computed {
				@property = $compile.expression(@data.property, this)
				@property.analyse()
				@property.prepare()
			}
			else {
				@property = @data.property.name

				if 48 <= @property.charCodeAt(0) <= 57 {
					unless type.isStruct() && type.isArray() {
						SyntaxException.throwInvalidIdentifier(@property, this)
					}
				}
			}
		}

		if @nullable && !@object.type().isNullable() && !@options.rules.ignoreMisfit {
			TypeException.throwNotNullableExistential(@object, this)
		}
	} // }}}
	translate() { // {{{
		@object.translate()

		if @computed && !@stringProperty {
			@property.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @object.isCallable() {
			@object.acquireReusable(@nullable || acquire)
		}

		if @computed && !@stringProperty && @property.isCallable() {
			@property.acquireReusable(@nullable || acquire)
		}
	} // }}}
	caller() => @object
	inferTypes(inferables) { // {{{
		@object.inferTypes(inferables)

		if @computed && !@stringProperty {
			@property.inferTypes(inferables)
		}

		return inferables
	} // }}}
	isAssignable() => true
	isCallable() => @object.isCallable() || (@computed && !@stringProperty && @property.isCallable())
	isComputed() => this.isNullable() && !@tested
	isInferable() => @inferable
	isLooseComposite() => this.isCallable() || this.isNullable()
	isMacro() => false
	isNullable() => @nullable || @object.isNullable() || (@computed && !@stringProperty && @property.isNullable())
	isNullableComputed() => (@object.isNullable() ? 1 : 0) + (@nullable ? 1 : 0) + (@computed && !@stringProperty && @property.isNullable() ? 1 : 0) > 1
	isUsingSetter() => @usingSetter
	isUsingVariable(name) => @object.isUsingVariable(name)
	listAssignments(array) => array
	path() => @path
	releaseReusable() { // {{{
		if @object.isCallable() {
			@object.releaseReusable()
		}

		if @computed && !@stringProperty && @property.isCallable() {
			@property.releaseReusable()
		}
	} // }}}
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		if this.isNullable() && !@tested {
			fragments.wrapNullable(this).code(' ? ').compile(@object)

			if @computed {
				fragments.code('[').compile(@property).code('] : null')
			}
			else {
				fragments.code($dot).compile(@property).code(' : null')
			}
		}
		else {
			const type = @object.type()

			if @usingGetter {
				if @sealed {
					const name = @property[0] == '_' ? @property.substr(1) : @property

					fragments.code(`\(type.type().getSealedName()).__ks_get_\(name)(`).compile(@object).code(')')
				}
				else {
					NotImplementedException.throw(this)
				}
			}
			else {
				if @object.isComputed() || @object._data.kind == NodeKind::NumericExpression {
					fragments.code('(').compile(@object).code(')')
				}
				else if type.isNamespace() && type.isSealed() && type.type().isSealedProperty(@property) {
					fragments.code(type.getSealedName())
				}
				else {
					fragments.compile(@object)
				}

				if @computed {
					fragments.code('[').compile(@property).code(']')
				}
				else {
					fragments.code($dot).compile(@property)
				}

				if @prepareObject && @type.isMethod() && @parent is not UnaryOperatorExpression{
					fragments.code('.bind(').compile(@object).code(')')
				}
			}
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if this.isNullable() && !@tested {
			if @computed {
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(@object)
					.code('[')
					.compile(@property)
					.code(']')
			}
			else {
				fragments
					.compileNullable(this)
					.code(' ? ')
					.compile(@object)
					.code($dot)
					.compile(@property)
			}

			if !@type.isBoolean() || @type.isNullable() {
				fragments.code(' === true')
			}

			fragments.code(' : false')
		}
		else {
			if @computed {
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

			if !@type.isBoolean() || @type.isNullable() {
				fragments.code(' === true')
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

			if @nullable {
				fragments.code(' && ') if conditional

				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(@object)
					.code(')')

				conditional = true
			}

			if @computed && !@stringProperty && @property.isNullable() {
				fragments.code(' && ') if conditional

				fragments.compileNullable(@property)
			}
		}
	} // }}}
	toQuote() { // {{{
		let fragments = @object.toQuote()

		if @nullable {
			fragments += '?'
		}

		if @computed {
			if @stringProperty {
				fragments += `[\(@property)]`
			}
			else {
				fragments += `[\(@property.toQuote())]`
			}
		}
		else {
			fragments += `.\(@property)`
		}

		return fragments
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

		if @computed {
			if !@stringProperty && @property.isCallable() {
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
	toSetterFragments(fragments, value) { // {{{
		if @sealed {
			const name = @property[0] == '_' ? @property.substr(1) : @property

			fragments.code(`\(@object.type().type().getSealedName()).__ks_set_\(name)(`).compile(@object).code($comma).compile(value).code(')')
		}
		else {
			NotImplementedException.throw(this)
		}
	} // }}}
	type() => @type
}