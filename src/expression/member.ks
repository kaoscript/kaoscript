class MemberExpression extends Expression {
	private late {
		@assignable: Boolean			= false
		@assignment: AssignmentType		= AssignmentType::Neither
		@callee
		@computed: Boolean				= false
		@inferable: Boolean				= false
		@liberal: Boolean				= false
		@nullable: Boolean				= false
		@object
		@objectType: DictionaryType?
		@path: String
		@prepareObject: Boolean			= true
		@property
		@sealed: Boolean				= false
		@stringProperty: Boolean		= false
		@tested: Boolean				= false
		@type: Type						= AnyType.NullableUnexplicit
		@usingGetter: Boolean			= false
		@usingSetter: Boolean			= false
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)
	} # }}}
	constructor(@data, @parent, @scope, @object) { # {{{
		super(data, parent, scope)

		@prepareObject = false
	} # }}}
	analyse() { # {{{
		for var modifier in @data.modifiers {
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

			if @computed {
				@property = $compile.expression(@data.property, this)

				@property.analyse()
			}
		}
	} # }}}
	override prepare(target) { # {{{
		if @prepareObject {
			@object.prepare()

			var type = @object.type()

			unless type.isComplete() {
				ReferenceException.throwUncompleteType(type, this, this)
			}

			if type.isNull() && !@nullable && !@options.rules.ignoreMisfit {
				ReferenceException.throwNullExpression(@object, this)
			}

			if @computed {
				@property.prepare(target)

				var mut nf = true

				if type.isTuple() {
					if @property is NumberLiteral | StringLiteral {
						if var property ?= type.getProperty(@property.value()) {
							@type = property.type()

							nf = false
						}
						else if type.isExhaustive(this) {
							if @assignable {
								ReferenceException.throwInvalidAssignment(this)
							}
							else {
								ReferenceException.throwNotDefinedProperty(@property.value(), this)
							}
						}
					}
				}

				if nf && type.isArray() {
					if @property is NumberLiteral {
						if var property ?= type.getProperty(@property.value()) {
							@type = property

							nf = false
						}
						else if type.isExhaustive(this) {
							if @assignable {
								ReferenceException.throwInvalidAssignment(this)
							}
							else {
								ReferenceException.throwNotDefinedProperty(@property.value(), this)
							}
						}
					}
				}

				if nf && type.isDictionary() {
					if @property is NumberLiteral | StringLiteral {
						if var property ?= type.getProperty(@property.value()) {
							@type = property

							nf = false
						}
						else if type.isExhaustive(this) {
							if @assignable {
								ReferenceException.throwInvalidAssignment(this)
							}
							else {
								ReferenceException.throwNotDefinedProperty(@property.value(), this)
							}
						}
					}
				}

				if nf {
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
						if var type ?= @scope.getChunkType(@path) {
							@type = type
						}
					}
				}
			}
			else {
				var isTuple = type.isTuple()

				@property = @data.property.name

				if !isTuple {
					if 48 <= @property.charCodeAt(0) <= 57 {
						SyntaxException.throwInvalidIdentifier(@property, this)
					}
				}

				if type.isDictionary() {
					@type = type.parameter()
				}

				if isTuple {
					@computed = true
					@stringProperty = true

					if var property ?= type.getProperty(@property) {
						@property = `\(property.index())`
						@type = property.type()
					}
					else if type.isExhaustive(this) {
						if @assignable {
							ReferenceException.throwInvalidAssignment(this)
						}
						else {
							ReferenceException.throwNotDefinedProperty(@property, this)
						}
					}

					if @object.isInferable() {
						@inferable = true
						@path = `\(@object.path())[\(@property)]`
					}
				}
				else if type.isStruct() {
					if var property ?= type.getProperty(@property) {
						@type = property.type()
					}
					else if type.isExhaustive(this) {
						if @assignable {
							ReferenceException.throwInvalidAssignment(this)
						}
						else {
							ReferenceException.throwNotDefinedProperty(@property, this)
						}
					}

					if @object.isInferable() {
						@inferable = true
						@path = `\(@object.path()).\(@property)`
					}
				}
				else {
					if var property ?= type.getProperty(@property) {
						var type = type.discardReference()
						if type.isClass() && property is ClassVariableType && property.isSealed() {
							@sealed = true
							@usingGetter = property.hasDefaultValue()
							@usingSetter = property.hasDefaultValue()
						}

						@type = property.discardVariable()
					}
					else if type.isEnum() {
						SyntaxException.throwInvalidEnumAccess(this)
					}
					else if @assignable && type.isLiberal() {
						@liberal = true
						@objectType = type
					}
					else if type.isExhaustive(this) {
						if @assignable {
							ReferenceException.throwInvalidAssignment(this)
						}
						else {
							ReferenceException.throwNotDefinedProperty(@property, this)
						}
					}

					if @object.isInferable() {
						@inferable = true
						@path = `\(@object.path()).\(@property)`
					}
				}

				if @assignable {
					if var variable ?= this.declaration() {
						if variable.isImmutable() {
							if variable.isLateInit() {
								if variable.isInitialized() {
									ReferenceException.throwImmutable(this)
								}
							}
							else {
								ReferenceException.throwImmutable(this)
							}
						}
					}
					else if var property ?= @object.type().getProperty(@property) {
						if property.isImmutable() {
							ReferenceException.throwImmutable(this)
						}
					}
				}
			}
		}
		else {
			var type = @object.type()

			if type.isNull() && !@nullable && !@options.rules.ignoreMisfit {
				ReferenceException.throwNullExpression(@object, this)
			}

			if @computed {
				@property = $compile.expression(@data.property, this)
				@property.analyse()
				@property.prepare(target)
			}
			else {
				@property = @data.property.name

				if 48 <= @property.charCodeAt(0) <= 57 {
					unless type.isTuple() {
						SyntaxException.throwInvalidIdentifier(@property, this)
					}
				}
			}
		}

		if @nullable && !@object.type().isNullable() && !@options.rules.ignoreMisfit {
			unless @object is MemberExpression && @object.isComputedMember() {
				TypeException.throwNotNullableExistential(@object, this)
			}
		}
	} # }}}
	translate() { # {{{
		@object.translate()

		if @computed && !@stringProperty {
			@property.translate()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if @object.isCallable() {
			@object.acquireReusable(@nullable || acquire)
		}

		if @computed && !@stringProperty && @property.isCallable() {
			@property.acquireReusable(@nullable || acquire)
		}
	} # }}}
	caller() => @object
	declaration() { # {{{
		return null if @computed

		if var declaration ?= @object.variable()?.declaration() {
			if declaration is ClassDeclaration {
				return declaration.getClassVariable(@property)
			}
		}
		else if var node ?= @parent.getFunctionNode() {
			if node is ClassConstructorDeclaration {
				return node.parent().getInstanceVariable(@property)
			}
		}

		return null
	} # }}}
	flagAssignable() { # {{{
		@assignable = true
	} # }}}
	inferTypes(inferables) { # {{{
		@object.inferTypes(inferables)

		if @computed && !@stringProperty {
			@property.inferTypes(inferables)
		}

		return inferables
	} # }}}
	initializeVariables(type: Type, node: Expression) { # {{{
		return if @computed

		if @object is IdentifierLiteral {
			if var property ?= @object.type().getProperty(@property) {
				if @object.type().isClass() && !@object.type().isReference() {
					node.initializeVariable(VariableBrief(
						name: @property
						type
						static: true
						class: @object.name()
						immutable: property.isImmutable()
					))
				}
				else if @object.name() == 'this' {
					node.initializeVariable(VariableBrief(
						name: @path.substring(5)
						type
						instance: true
						immutable: property.isImmutable()
					))
				}
			}
		}
	} # }}}
	isCallable() => @object.isCallable() || (@computed && !@stringProperty && @property.isCallable())
	isComputed() => @isNullable() && !@tested
	isComputedMember() => @computed
	isInferable() => @inferable
	isLiberal() => @liberal
	isLooseComposite() => @isCallable() || @isNullable()
	isMacro() => false
	isNullable() => @nullable || @object.isNullable() || (@computed && !@stringProperty && @property.isNullable())
	isNullableComputed() => (@object.isNullable() ? 1 : 0) + (@nullable ? 1 : 0) + (@computed && !@stringProperty && @property.isNullable() ? 1 : 0) > 1
	isUsingSetter() => @usingSetter
	isUsingVariable(name) => @object.isUsingVariable(name)
	isUsingInstanceVariable(name) => @property == name && @object is IdentifierLiteral && @object.name() == 'this' && @object.type().discard().hasInstanceVariable(@property)
	isUsingStaticVariable(class, varname) => @property == varname && @object is IdentifierLiteral && @object.name() == class
	listAssignments(array: Array<String>) => array
	override listNonLocalVariables(scope, variables) { # {{{
		@object.listNonLocalVariables(scope, variables)

		if @computed {
			@property.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	path() => @path
	releaseReusable() { # {{{
		if @object.isCallable() {
			@object.releaseReusable()
		}

		if @computed && !@stringProperty && @property.isCallable() {
			@property.releaseReusable()
		}
	} # }}}
	setAssignment(@assignment)
	setPropertyType(type: Type) { # {{{
		if @objectType.isNamed() {
			var newType = @objectType.clone()

			newType.addProperty(@property, type)

			@scope.replaceVariable(newType.name(), newType, this)
		}
		else {
			@objectType.addProperty(@property, type)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @isNullable() && !@tested {
			fragments.wrapNullable(this).code(' ? ').compile(@object)

			if @computed {
				fragments.code('[').compile(@property).code('] : null')
			}
			else {
				fragments.code($dot).compile(@property).code(' : null')
			}
		}
		else {
			var type = @object.type()

			if @usingGetter {
				if @sealed {
					var name = @property[0] == '_' ? @property.substr(1) : @property

					fragments.code(`\(type.type().getSealedName()).__ks_get_\(name)(`).compile(@object).code(')')
				}
				else {
					NotImplementedException.throw(this)
				}
			}
			else if @prepareObject && @type.isMethod() && @parent is not ClassProxyDeclaration | ClassProxyGroupDeclaration {
				fragments.code(`\($runtime.helper(this)).bindMethod(`)

				if @object.isComputed() || @object._data.kind == NodeKind::NumericExpression {
					fragments.compile(@object)
				}
				else if type.isNamespace() && type.isSealed() && type.type().isSealedProperty(@property) {
					fragments.code(type.getSealedName())
				}
				else {
					fragments.compile(@object)
				}

				fragments.code($comma)

				if @computed {
					fragments.compile(@property)
				}
				else {
					fragments.code('"').compile(@property).code('"')
				}

				fragments.code(')')
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
			}
		}
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		if @isNullable() && !@tested {
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
	} # }}}
	toNullableFragments(fragments) { # {{{
		if !@tested {
			@tested = true

			var mut conditional = false

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
	} # }}}
	toQuote() { # {{{
		var mut fragments = @object.toQuote()

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
			fragments += `.\(@data.property.name)`
		}

		return fragments
	} # }}}
	toReusableFragments(fragments) { # {{{
		var objectCallable = @object.isCallable()

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
	} # }}}
	toSetterFragments(fragments, value) { # {{{
		if @sealed {
			var name = @property[0] == '_' ? @property.substr(1) : @property

			fragments.code(`\(@object.type().type().getSealedName()).__ks_set_\(name)(`).compile(@object).code($comma).compile(value).code(')')
		}
		else {
			NotImplementedException.throw(this)
		}
	} # }}}
	type() => @type
}
