class ArrayBinding extends Expression {
	private late {
		@assignment: AssignmentType			= .Neither
		@elements: ArrayBindingElement[]	= []
		@firstAnonymous: Number?			= null
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
		for var data, index in @data.elements {
			var element = @newElement(data)

			element.setAssignment(@assignment)

			element.index(index)

			element.analyse()

			if element.hasDefaultValue() || (element.isThisAliasing() && @assignment != AssignmentType.Parameter) {
				@flatten = true
			}

			@elements.push(element)

			@rest ||= element.isRest()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		var subtarget = target.isArray() ? target.parameter() : AnyType.NullableUnexplicit

		@testType = ArrayType.new(@scope)
		@testType.flagDestructuring()

		if !?@type {
			for var element in @elements {
				element.prepare(subtarget)
			}

			@type = @testType
		}
		else if @type.isAny() || (@type.isReference() && @type.name() == 'Array') {
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

			if type.isTuple() {
				unless type.length() >= @elements.length {
					ReferenceException.throwBindingExceedArray(@elements.length, type.length(), this)
				}

				for var element in @elements {
					element.type(type.getProperty(element.index()).type())

					element.prepare(subtarget)
				}
			}
			else if type.isArray() {
				unless type.hasRest() || type.length() >= @elements.length {
					ReferenceException.throwBindingExceedArray(@elements.length, type.length(), this)
				}

				for var element in @elements {
					element.type(type.getProperty(element.index()))

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

		var mut untested = false
		var mut min = 0

		if @assignment == .Parameter {
			for var element in @elements {
				if element.isRest() {
					@testType.setRestType(element.getExternalType())
				}
				else {
					@testType.addProperty(element.getExternalType())

					if element.hasDefaultValue() && !element.isRequired() {
						untested = true
					}
					else {
						min += 1
					}
				}
			}
		}
		else {
			untested = ?#@elements

			var mut optional = false

			for var element in @elements {
				var type = element.getExternalType()

				if element.hasDefaultValue() && !element.isRequired() {
					optional = true

					if !type.isAny() || !type.isNullable() {
						@flatten = true
					}

					if @rest {
						@testType.addProperty(type)
					}
				}
				else if element.isRest() {
					@testType.setRestType(type)

					optional = true
				}
				else {
					if optional {
						SyntaxException.throwUnsupportedDestructuringArray(this)
					}

					@testType.addProperty(type)

					min += 1
				}
			}
		}

		if untested {
			@testType.unflagFullTest(min)
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
	} # }}}
	translate() { # {{{
		for var element, i in @elements {
			element.translate()

			if element.isAnonymous() {
				@firstAnonymous ??= i
			}
			else {
				@firstAnonymous = null
			}
		}
	} # }}}
	elements(): valueof @elements
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
	newElement(data) => ArrayBindingElement.new(data, this, @scope)
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}
	} # }}}
	setAssignment(@assignment)
	toFragments(fragments, mode) { # {{{
		fragments.code('[')

		if ?@firstAnonymous {
			for var element, i in @elements to~ @firstAnonymous {
				fragments.code(', ') if i != 0

				element.toFragments(fragments)
			}
		}
		else {
			for var element, i in @elements {
				fragments.code(', ') if i != 0

				element.toFragments(fragments)
			}
		}

		fragments.code(']')
	} # }}}
	toAssertFragments(fragments, value, inline) { # {{{
		if !@tested && !value.type().isBroadArray() {
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
		if ?@reuseName {
			fragments.newLine().code(`\($runtime.scope(this)) \(@reuseName) = `).compile(@value).done()
		}

		var line = fragments.newLine()

		@testType.toAssertFragments(@reuseName ?? @value, !@value.type().isBroadArray(), line, this)

		line.done()
	} # }}}
	toFlatFragments(fragments, value) { # {{{
		if @elements.length == 1 {
			@elements[0].toFlatFragments(fragments, value)
		}
		else {
			var reusableValue = TempReusableExpression.new(value, this)

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
	value(@value)
	override walkVariable(fn) { # {{{
		for var element in @elements {
			element.walkVariable(fn)
		}
	} # }}}
}

class ArrayBindingElement extends Expression {
	private {
		@assignment: AssignmentType			= AssignmentType.Neither
		@defaultValue						= null
		@explicitlyNonNullable: Boolean		= false
		@explicitlyRequired: Boolean		= false
		@hasDefaultValue: Boolean			= false
		@immutable: Boolean?				= null
		@index								= -1
		@name: Expression?					= null
		@named: Boolean						= false
		@nullable: Boolean					= false
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind.Equals
		@rest: Boolean						= false
		@thisAlias: Boolean					= false
		@type: Type							= AnyType.Unexplicit
	}
	analyse() { # {{{
		for var modifier in @data.modifiers {
			match modifier.kind {
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

		if ?@data.internal {
			@name = @compileVariable(@data.internal)
			@name.setAssignment(@assignment)
			@name.analyse()

			@named = true
			@thisAlias = @data.internal.kind == NodeKind.ThisExpression
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
			@name.prepare()

			if @name is ThisExpression {
				@type = @name.type()
			}
			else {
				@type = @name.getDeclaredType().merge(@type, null, null, false, this)
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

			unless !@named || @defaultValue.type().isAssignableToVariable(@name.getDeclaredType(), true, false, false) {
				TypeException.throwInvalidAssignment(@name, @name.getDeclaredType(), @defaultValue.type(), this)
			}
		}

		if !@named {
			pass
		}
		else if @name is ThisExpression {
			pass
		}
		else if @name is IdentifierLiteral {
			var variable = @name.variable()

			variable.setDeclaredType(@type)

			if @assignment == AssignmentType.Declaration {
				variable.setRealType(@type)
			}
			else if @hasDefaultValue {
				variable.setRealType(@defaultValue.type())
			}
		}
		else {
			@name.type(@type)
		}

		@statement().assignTempVariables(@scope)
	} # }}}
	translate() { # {{{
		@name?.translate()

		if @hasDefaultValue {
			@defaultValue.translate()
		}
	} # }}}
	compileVariable(data) => $compile.expression(data, this)
	export(recipient) => @named ? @name.export(recipient) : null
	getExternalType() { # {{{
		if @hasDefaultValue {
			return @type.setNullable(true)
		}
		else {
			return @type
		}
	} # }}}
	hasDefaultValue() => @hasDefaultValue
	index() => @index
	index(@index) => this
	initializeVariables(type: Type, node: Expression) { # {{{
		if var name ?= @name.name() {
			@name.initializeVariables(type.getProperty(name) ?? AnyType.NullableUnexplicit, node)
		}
	} # }}}
	isImmutable() => @parent.isImmutable()
	isDeclararingVariable(name: String) => @named ? @name.isDeclararingVariable(name) : false
	isAnonymous() => !@named
	isRedeclared() => @named ? @name.isRedeclared() : false
	isRequired() => @explicitlyRequired || !(@rest || @hasDefaultValue)
	isRest() => @rest
	isThisAliasing() => @thisAlias
	listAssignments(array: Array, immutable: Boolean? = null) => @named ? @name.listAssignments(array, @immutable) : array
	max(): Number => @rest ? Infinity : 1
	min(): Number => @rest ? 0 : 1
	setAssignment(@assignment)
	toAssignmentFragments(fragments, value) { # {{{
		if @named {
			fragments
				.compile(@name)
				.code($equals)
				.compile(value)
		}
	} # }}}
	toFragments(fragments) { # {{{
		if @rest {
			fragments.code('...')
		}

		if @named {
			fragments.compile(@name)

			if @hasDefaultValue {
				fragments.code(' = ').compile(@defaultValue)
			}
		}
	} # }}}
	toExistFragments(fragments, name) { # {{{
		if @rest {
			fragments.code('...')
		}

		if @named {
			if @hasDefaultValue {
				fragments.code(' = ').compile(@defaultValue)
			}
		}
	} # }}}
	toFlatFragments(fragments, value) { # {{{
		return unless @named

		if @name is ArrayBinding {
			@name.toFlatFragments(fragments, FlatArrayBindingElement.new(value, @index, this))
		}
		else if @rest {
			fragments
				.compile(@name)
				.code($equals)
				.wrap(value)
				.code(`.slice(\(@index))`)
		}
		else if @hasDefaultValue {
			fragments
				.compile(@name)
				.code($equals, $runtime.helper(this), '.default(')
				.wrap(value)
				.code(`[\(@index)]`)
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

			if @assignment != .Parameter && !@isRequired() && !(@type.isAny() && @type.isNullable()) {
				fragments.code($comma)

				@type.setNullable(false).toAwareTestFunctionFragments('value', false, false, null, null, fragments, this)
			}

			fragments.code(')')
		}
		else {
			fragments
				.compile(@name)
				.code($equals)
				.wrap(value)
				.code(`[\(@index)]`)
		}
	} # }}}
	type() => @type
	type(@type) => this
	override walkVariable(fn) { # {{{
		if @named {
			@name.walkVariable(fn)
		}
	} # }}}
}

class FlatArrayBindingElement extends Expression {
	private {
		@array
		@index
	}
	constructor(@array, @index, parent) { # {{{
		super({}, parent)
	} # }}}
	analyse()
	override prepare(target, targetMode)
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
