class ObjectBinding extends Expression {
	private late {
		@assignment: AssignmentType			= .Neither
		@elements: ObjectBindingElement[]	= []
		@flatten: Boolean					= false
		@immutable: Boolean					= false
		@rest: Boolean						= false
		@reuseName: String?
		@tested: Boolean					= false
		@testType: Type
		@type: Type
		@value
	}
	analyse() { # {{{
		for var data in @data.elements {
			var element = @newElement(data)

			element.setAssignment(@assignment)

			element.analyse()

			if element.hasDefaultValue() || (element.isThisAliasing() && @assignment != AssignmentType.Parameter) {
				@flatten = true
			}

			@elements.push(element)

			@rest ||= element.isRest()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		var subtarget = target.isObject() ? target.parameter() : AnyType.NullableUnexplicit

		@testType = ObjectType.new(@scope)
		@testType.flagDestructuring()

		if !?@type {
			for var element in @elements {
				element.prepare(subtarget)
			}

			@type = @testType
		}
		else if @type.isAny() || (@type.isReference() && @type.name() == 'Object') {
			var parameter = @type.parameter()

			if parameter.isAny() {
				for var element in @elements {
					element.prepare(subtarget)
				}
			}
			else {
				for var element in @elements {
					element.type(parameter).prepare(subtarget)
				}
			}
		}
		else {
			var type = @type.discard()

			if type.isObject() {
				for var element in @elements {
					if var property ?= type.getProperty(element.name()) {
						element.type(property)
					}
					else if element.isRequired() {
						ReferenceException.throwUndefinedBindingVariable(element.name(), this)
					}

					element.prepare(subtarget)
				}
			}
			else if type.isStruct() {
				for var element in @elements {
					if var property ?= type.getProperty(element.name()) {
						element.type(property.type())
					}
					else if element.isRequired() {
						ReferenceException.throwUndefinedBindingVariable(element.name(), this)
					}

					element.prepare(subtarget)
				}
			}
			else {
				var parameter = @type.parameter()

				if parameter.isAny() {
					for var element in @elements {
						element.prepare(subtarget)
					}
				}
				else {
					for var element in @elements {
						element.type(parameter).prepare(subtarget)
					}
				}
			}
		}

		if @assignment == .Parameter {
			for var element in @elements {
				if element.isRest() {
					@testType.setRestType(element.getExternalType())
				}
				else {
					@testType.addProperty(element.name(), element.hasComputedKey(), element.getExternalType())
				}
			}
		}
		else {
			for var element in @elements {
				var type = element.getExternalType()

				if element.isRest() {
					@testType.setRestType(type)
				}
				else if @rest || (element.isRequired() && !(type.isAny() && type.isNullable())) {
					@testType.addProperty(element.name(), element.hasComputedKey(), type)
				}
			}
		}

		if @statement() is ExpressionStatement | VariableStatement {
			@tested = true

			if ?@value && !@value.type().isSubsetOf(@testType, MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast) {
				@statement().addBeforehand(this)

				if @value.isComposite() {
					@reuseName = @scope.acquireTempName(false)
				}
			}
		}
		else if @type != @testType && @type.isSubsetOf(@testType, MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast) {
			@tested = true
		}
	} # }}}
	translate() { # {{{
		for var element in @elements {
			element.translate()
		}
	} # }}}
	export(recipient) { # {{{
		for var element in @elements {
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
		for var element in @elements {
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
	listAssignments(array: Array, immutable: Boolean? = null) { # {{{
		for var element in @elements {
			element.listAssignments(array, immutable)
		}

		return array
	} # }}}
	name() => null
	newElement(data) => ObjectBindingElement.new(data, this, @scope)
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}
	} # }}}
	setAssignment(@assignment)
	toFragments(fragments, mode) { # {{{
		fragments.code('{')

		var mut nc = true

		for var element in @elements {
			if !element.isAnonymous() {
				if nc {
					nc = false
				}
				else {
					fragments.code($comma)
				}

				element.toFragments(fragments)
			}
		}

		fragments.code('}')
	} # }}}
	toAssertFragments(fragments, value, inline) { # {{{
		if !@tested && !value.type().isBroadObject() {
			if inline {
				@testType.toAssertFragments(value, true, fragments, this)

				fragments.code($comma)
			}
			else {
				var line = fragments.newLine()

				@testType.toAssertFragments(value, true, line, this)

				line.done()
			}
		}
	} # }}}
	toAssignmentFragments(fragments, mut value? = null) { # {{{
		if @flatten {
			@toFlatFragments(fragments, @reuseName ?? @value ?? value)
		}
		else {
			fragments.code('(') unless @assignment == .Declaration

			fragments
				.compile(this)
				.code($equals)
				.compile(@reuseName ?? @value ?? value)

			fragments.code(')') unless @assignment == .Declaration
		}
	} # }}}
	toBeforehandFragments(fragments, mode) { # {{{
		if @value.isComposite() {
			fragments.newLine().code(`\($runtime.scope(this)) \(@reuseName) = `).compile(@value).done()
		}

		var line = fragments.newLine()

		@testType.toAssertFragments(@reuseName ?? @value, !@value.type().isBroadObject(), line, this)

		line.done()
	} # }}}
	toFlatFragments(fragments, value) { # {{{
		if @elements.length == 1 {
			@elements[0].toFlatFragments(fragments, value)
		}
		else {
			var reusableValue = TempReusableExpression.new(value, this)

			@elements[0].toFlatFragments(fragments, reusableValue)

			for var element in @elements from 1 {
				fragments.code(', ')

				element.toFlatFragments(fragments, reusableValue)
			}
		}
	} # }}}
	toParameterFragments(fragments) { # {{{
		fragments.code('{')

		var mut nc = true

		for var element in @elements {
			if !element.isAnonymous() {
				if nc {
					nc = false
				}
				else {
					fragments.code($comma)
				}

				element.toParameterFragments(fragments)
			}
		}

		fragments.code('}')
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
	value(@value) => this
	override walkVariable(fn) { # {{{
		for var element in @elements {
			element.walkVariable(fn)
		}
	} # }}}
}

class ObjectBindingElement extends Expression {
	private late {
		@assignment: AssignmentType			= .Neither
		@computed: Boolean					= false
		@defaultValue						= null
		@explicitlyNonNullable: Boolean		= false
		@explicitlyRequired: Boolean		= false
		@external: Expression
		@hasDefaultValue: Boolean			= false
		@immutable: Boolean?				= null
		@internal: Expression
		@named: Boolean						= true
		@nullable: Boolean					= false
		@operator: AssignmentOperatorKind	= .Equals
		@rest: Boolean						= false
		@sameName: Boolean					= false
		@thisAlias: Boolean					= false
		@type: Type							= AnyType.Unexplicit
	}
	analyse() { # {{{
		for var modifier in @data.modifiers {
			match modifier.kind {
				ModifierKind.Computed {
					@computed = true
				}
				ModifierKind.Mutable {
					@immutable = false
				}
				ModifierKind.NonNullable {
					@explicitlyNonNullable = true
				}
				ModifierKind.Nullable {
					@nullable = true
					@type = AnyType.NullableUnexplicit
				}
				ModifierKind.Required {
					@explicitlyRequired = true
				}
				ModifierKind.Rest {
					@rest = true
				}
			}
		}

		if ?@data.external {
			@external = $compile.expression(@data.external, this)

			if ?@data.internal {
				@internal = @compileVariable(@data.internal)

				if @data.internal.kind == NodeKind.ThisExpression {
					@thisAlias = true
					@sameName = @external is IdentifierLiteral && @external.name() == @data.internal.name.name
				}
			}
			else {
				@internal = @compileVariable(@data.external)
				@sameName = true
			}
		}
		else if ?@data.internal {
			@internal = @compileVariable(@data.internal)
			@thisAlias = @data.internal.kind == NodeKind.ThisExpression

			@external = @internal
			@sameName = true
		}
		else {
			@named = false
		}

		if @named {
			@internal.setAssignment(@assignment)
			@internal.analyse()
		}

		if ?@data.defaultValue {
			@hasDefaultValue = true

			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()

			@operator = @data.operator.assignment
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if ?@data.type {
			@type = Type.fromAST(@data.type, this)
		}

		if @named {
			@internal.prepare()

			if @internal is ThisExpression {
				@type = @internal.type()
			}
			else {
				@type = @internal.getDeclaredType().merge(@type, this)
			}
		}

		if @explicitlyNonNullable {
			@nullable = false
			@type = @type.setNullable(false)
		}
		else {
			@nullable ||= @type.isNullable()
		}

		if @hasDefaultValue {
			if @explicitlyRequired && @type.isNullable() {
				if @data.defaultValue.kind == NodeKind.Identifier && @data.defaultValue.name == 'null' {
					pass
				}
				else {
					SyntaxException.throwDeadCodeParameter(this)
				}
			}

			@defaultValue.prepare(@type, TargetMode.Permissive)

			unless @defaultValue.type().isAssignableToVariable(@internal.getDeclaredType(), true, false, false) {
				TypeException.throwInvalidAssignement(@internal, @internal.getDeclaredType(), @defaultValue.type(), this)
			}
		}

		if !@named {
			pass
		}
		else if @internal is ThisExpression {
			pass
		}
		else if @internal is IdentifierLiteral {
			var variable = @internal.variable()

			variable.setDeclaredType(@type)

			if @assignment == AssignmentType.Declaration {
				variable.setRealType(@type)
			}
			else if @hasDefaultValue {
				variable.setRealType(@defaultValue.type())
			}
		}
		else {
			@internal.type(@type)
		}

		@statement().assignTempVariables(@scope)
	} # }}}
	translate() { # {{{
		@internal?.translate()

		if @hasDefaultValue {
			@defaultValue.translate()
		}
	} # }}}
	compileVariable(data) => $compile.expression(data, this)
	export(recipient) => @internal?.export(recipient)
	getExternalType() { # {{{
		if @hasDefaultValue {
			return @type.setNullable(true)
		}
		else {
			return @type
		}
	} # }}}
	hasComputedKey() => @computed
	hasDefaultValue() => @hasDefaultValue
	initializeVariables(type: Type, node: Expression) { # {{{
		@internal.initializeVariables(type.getProperty(@external.name()) ?? AnyType.NullableUnexplicit, node)
	} # }}}
	isAnonymous() => !@named
	isDeclararingVariable(name: String) => @internal?.isDeclararingVariable(name)
	isRedeclared() => @internal?.isRedeclared()
	isRequired() => @explicitlyRequired || !(@rest || @hasDefaultValue)
	isRest() => @rest
	isThisAliasing() => @thisAlias
	listAssignments(array: Array, immutable: Boolean? = null) => @internal?.listAssignments(array, @immutable) ?? array
	name(): String? => @external?.value()
	setAssignment(@assignment)
	toFragments(fragments) { # {{{
		return unless @named

		if @rest {
			fragments.code('...')
		}

		if $keywords[this.name()] {
			if @computed {
				fragments.code(`[\(this.name())]: `).compile(@internal)
			}
			else {
				fragments.code(`\(this.name()): `).compile(@internal)
			}
		}
		else {
			if @computed {
				fragments.code('[').compile(@external).code(']: ').compile(@internal)
			}
			else if @sameName && !@thisAlias {
				fragments.compile(@internal)
			}
			else {
				fragments.compile(@external).code(': ').compile(@internal)
			}
		}

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} # }}}
	toExistFragments(fragments, name) { # {{{
		return unless @named

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
				fragments.code('[').compile(@external).code(']: ', name)
			}
			else {
				fragments.compile(@external).code(': ', name)
			}
		}

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} # }}}
	toFlatFragments(fragments, value) { # {{{
		return unless @named

		if @hasDefaultValue {
			fragments
				.compile(@internal)
				.code($equals, $runtime.helper(this), '.default(')
				.wrap(value)
				.code('.')
				.compile($keywords[@name()] ? @name() : @external)
				.code($comma)
				.code(match @operator {
					.EmptyCoalescing, .NonEmpty {
						set '2'
					}
					.NullCoalescing, .Existential {
						set '1'
					}
					else {
						set @type.isNullable() ? '0' : '1'
					}
				})
				.code($comma)
				.code('() => ')
				.compile(@defaultValue)

			if @assignment != .Parameter && !@isRequired() && !@type.isAny() {
				fragments.code($comma)

				@type.setNullable(false).toTestFunctionFragments(fragments, this)
			}

			fragments.code(')')
		}
		else {
			fragments
				.compile(@internal)
				.code($equals)
				.wrap(value)
				.code('.')
				.compile($keywords[@name()] ? @name() : @external)
		}
	} # }}}
	toParameterFragments(fragments) { # {{{
		return unless @named

		if @rest {
			fragments.code('...')
		}

		if $keywords[this.name()] {
			if @computed {
				fragments.code(`[\(this.name())]: `)

				@internal.toParameterFragments(fragments)
			}
			else {
				fragments.code(`\(this.name()): `)

				@internal.toParameterFragments(fragments)
			}
		}
		else {
			if @computed {
				fragments.code('[').compile(@external).code(']: ')

				@internal.toParameterFragments(fragments)
			}
			else if @sameName {
				@internal.toParameterFragments(fragments)
			}
			else {
				fragments.compile(@external).code(': ')

				@internal.toParameterFragments(fragments)
			}
		}

		if @hasDefaultValue {
			fragments.code(' = ').compile(@defaultValue)
		}
	} # }}}
	type() => @type
	type(@type) => this
	override walkVariable(fn) { # {{{
		@internal?.walkVariable(fn)
	} # }}}
}
