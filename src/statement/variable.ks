class VariableStatement extends Statement {
	private {
		@await: Boolean								= false
		@declarations: VariableDeclaration[]		= []
		@function									= null
		@try: TryStatement?							= null
	}
	constructor(@data, @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)

		var mut ancestor = parent

		while ?ancestor && !(ancestor is AnonymousFunctionExpression | ArrowFunctionExpression | FunctionDeclarator | ClassMethodDeclaration | ImplementDividedClassMethodDeclaration | ImplementNamespaceFunctionDeclaration) {
			if ancestor is TryStatement {
				@try = ancestor
			}

			ancestor = ancestor.parent()
		}

		if ?ancestor {
			@function = ancestor
		}
	} # }}}
	override initiate() { # {{{
		var modifing = ?#@data.modifiers
		var modifier = if modifing set @data.modifiers[0].kind else null
		var overwrite = @hasAttribute('overwrite')

		for var data in @data.declarations {
			var declaration = VariableDeclaration.new(data, this, @scope)
				..setModifier(modifier) if modifing
				..flagOverwrite() if overwrite
				..initiate()

			@declarations.push(declaration)
		}
	} # }}}
	override analyse() { # {{{
		for var declaration in @declarations {
			declaration.analyse()

			@await ||= declaration.isAwait()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var declaration in @declarations {
			declaration.prepare(target)
		}
	} # }}}
	override translate() { # {{{
		for var declaration in @declarations {
			declaration.translate()
		}
	} # }}}
	export(recipient) { # {{{
		for var declaration in @declarations {
			declaration.export(recipient)
		}
	} # }}}
	function(): valueof @function
	isAwait() => @await
	isDeclararingVariable(name: String) { # {{{
		for var declaration in @declarations {
			if declaration.isDeclararingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isUsingInstanceVariable(name) { # {{{
		for var declaration in @declarations {
			if declaration.isUsingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isUsingStaticVariable(class, varname) { # {{{
		for var declaration in @declarations {
			if declaration.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	override isUsingVariable(name, bleeding) { # {{{
		for var declaration in @declarations {
			if declaration.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override isUsingVariableBefore(name, statement: Statement = this) => super(name, statement)
	length()
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		for var declaration in @declarations {
			declaration.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	toAwaitStatementFragments(fragments, statements) { # {{{
		for var declaration in @declarations {
			if declaration.isAwait() {
				declaration.toAwaitStatementFragments(fragments, statements)
			}
		}
	} # }}}
	override toFragments(fragments, mode) { # {{{
		var variables = @assignments()

		if ?#variables {
			fragments.newLine().code($runtime.scope(this) + variables.join(', ')).done()
		}

		if ?#@beforehands {
			for var beforehand in @beforehands {
				beforehand.toBeforehandFragments(fragments, mode)
			}
		}

		for var declaration in @declarations {
			if var item ?= declaration.toFragments(fragments, mode) {
				return item
			}
		}

		for var afterward in @afterwards {
			afterward.toAfterwardFragments(fragments, mode)
		}
	} # }}}
	try(): valueof @try
	override walkVariable(fn) { # {{{
		for var declaration in @declarations {
			declaration.walkVariable(fn)
		}
	} # }}}
}

class VariableDeclaration extends AbstractNode {
	private late {
		@autotype: Boolean			= true
		@await: Boolean				= false
		@cascade: Boolean			= false
		@declarators: Array			= []
		@expression
		@hasExpression: Boolean		= false
		@hasValue: Boolean			= false
		@immutable: Boolean			= true
		@lateInit: Boolean			= false
		@mixedMutability: Boolean	= false
		@overwrite: Boolean			= false
		@rebindable: Boolean		= false
		@redeclared: Boolean		= false
		@toDeclareAll: Boolean		= true
		@type: Type					= Type.Null
		@useExpression: Boolean		= false
		@value
		@valueScope: Scope?
	}
	constructor(@data, @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)
	} # }}}
	constructor(@data, @parent, @scope, @valueScope, @cascade) { # {{{
		this(data, parent, scope)
	} # }}}
	override initiate() { # {{{
		@overwrite ||= @hasAttribute('overwrite')

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Mutable {
				@immutable = false
				@rebindable = true
			}
		}

		@hasValue = ?@data.value

		for var data in @data.variables {
			var declarator = match data.name.kind {
				AstKind.ArrayBinding {
					set VariableBindingDeclarator.new(data, this)
				}
				AstKind.Identifier {
					set VariableIdentifierDeclarator.new(data, this)
				}
				AstKind.ObjectBinding {
					set VariableBindingDeclarator.new(data, this)
				}
				else {
					throw NotImplementedException.new(this)
				}
			}

			declarator.analyse()

			@declarators.push(declarator)
		}

		if @hasValue && @useExpression {
			@hasExpression = true
			@hasValue = false

			if var class ?= $assignmentOperators[@data.operator.assignment] {
				var left = @data.variables[0].name

				@expression = class.new({
					left
					operator: @data.operator
					right: @data.value
					start: left.start
					end: @data.value.end
				}, @parent, @scope, @valueScope)
					..flagDeclaration()
					..initiate()
			}
			else {
				NotSupportedException.throw(`Unexpected assignment operator \(@data.operator.assignment)`, this)
			}
		}
	} # }}}
	override analyse() { # {{{
		var assignments = @listAssignments([])

		if @hasValue {
			if @immutable {
				@rebindable = ?@valueScope
			}

			@valueScope ??= @newScope(@scope!?, ScopeType.Hollow)

			var line = @valueScope.getRawLine()

			@valueScope.line(line - 1)

			@value = $compile.expression(@data.value, this, @valueScope)
			@value.analyse()

			@valueScope.line(line)

			@await = @value.isAwait()

			if @await && !?@parent.function() && !@module().isBinary() {
				SyntaxException.throwInvalidAwait(this)
			}

			for var { name } in assignments {
				if @value.isUsingVariable(name) || @parent.isUsingVariableBefore(name) {
					@scope.rename(name)
				}
			}
		}
		else if @hasExpression {
			@expression.analyse()

			var value = @expression.right()

			for var { name } in assignments {
				if value.isUsingVariable(name) || @parent.isUsingVariableBefore(name) {
					@scope.rename(name)
				}
			}
		}
		else {
			for var { name } in assignments {
				if @parent.isUsingVariableBefore(name) {
					@scope.rename(name)
				}
			}
		}

		if @hasValue && #@declarators == 1 {
			if @declarators[0] is VariableIdentifierDeclarator {
				this.reference(@declarators[0].name())
			}
		}

	} # }}}
	override prepare(target, targetMode) { # {{{
		for var declarator in @declarators {
			declarator.prepare()

			if declarator.isRedeclared() {
				@redeclared = true
			}
		}

		var declarator = @declarators[0]

		if @hasValue {
			@value.prepare(declarator.type() ?? AnyType.NullableUnexplicit)

			if @value.isDerivative() {
				TypeException.throwNotUniqueValue(@value, this)
			}

			@type = @value.type()

			if @type.isInoperative() {
				TypeException.throwUnexpectedInoperative(@value, this)
			}

			if @parent is IfStatement | IfExpression {
				@type = @type.setNullable(false)
			}

			if @autotype {
				if @type.isNull() {
					declarator.setDeclaredType(AnyType.NullableExplicit)
				}
				else {
					declarator.setDeclaredType(@type.discardValue().asReference())
				}

				declarator.flagDefinitive()
			}
			else {
				declarator.setDeclaredType(AnyType.NullableUnexplicit)
			}

			if @value is UnaryOperatorTypeFitting && @value.isForced() {
				pass
			}
			else {
				declarator.setRealType(@type)
			}

			@parent.assignTempVariables(@valueScope)

			if declarator is VariableIdentifierDeclarator {
				if var type ?= declarator.type() {
					@value.validateType(type)
				}
			}

			if @parent is VariableStatement {
				@value.acquireReusable(declarator.isSplitAssignment())
				@value.releaseReusable()
			}

			@statement().assignTempVariables(@scope)
		}
		else if @hasExpression {
			@expression.prepare(target, targetMode)

			@type = @expression.getRightType()

			if @autotype {
				if @type.isNull() {
					declarator.setDeclaredType(AnyType.NullableExplicit)
				}
				else {
					declarator.setDeclaredType(@type.discardValue().asReference())
				}

				declarator.flagDefinitive()
			}
			else {
				declarator.setDeclaredType(AnyType.NullableUnexplicit)
			}

			declarator.setRealType(@type)

			@statement().assignTempVariables(@scope)
		}
		else {
			@type = declarator.variable().getRealType()
		}
	} # }}}
	override translate() { # {{{
		if @hasValue {
			@value.translate()
		}
		else if @hasExpression {
			@expression.translate()
		}

		for var declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	declarator() => @declarators[0]
	declarators() => @declarators
	defineVariables(declarator) { # {{{
		var assignments = []

		for var { name, immutable = @immutable } in declarator.listAssignments([]) {
			@mixedMutability ||= immutable != @immutable

			if !@overwrite && @scope.hasDefinedVariable(name) {
				SyntaxException.throwAlreadyDeclared(name, this)
			}
			else if @scope.hasMacro(name) {
				SyntaxException.throwIdenticalMacro(name, this)
			}

			var alreadyDeclared = @scope.hasDeclaredVariable(name)

			var variable = @scope.define(name, immutable, null, false, @overwrite, this)

			if alreadyDeclared && !variable.isRenamed() {
				@toDeclareAll = false
			}
			else {
				assignments.push(variable.getSecureName())
			}
		}

		if @cascade {
			@parent.addAssignments(assignments)
		}
		else if !@hasValue {
			@parent.addAssignments(assignments)
		}
	} # }}}
	export(recipient) { # {{{
		for var declarator in @declarators {
			declarator.export(recipient)
		}
	} # }}}
	expression() => @expression
	flagOverwrite() { # {{{
		@overwrite = true
	} # }}}
	flagUseExpression() { # {{{
		@useExpression = true
	} # }}}
	hasExpression() => @hasExpression
	hasValue() => @hasValue
	getIdentifierVariable() { # {{{
		if @declarators.length == 1 && @declarators[0] is VariableIdentifierDeclarator {
			return @declarators[0]._variable
		}
		else {
			return null
		}
	} # }}}
	isAutoTyping() => @autotype
	isAwait() => @await
	isDeclararingVariable(name: String) { # {{{
		for var declarator in @declarators {
			if declarator.isDeclararingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isDuplicate(scope) { # {{{
		for var declarator in @declarators {
			if declarator.isDuplicate(scope) {
				return true
			}
		}

		return false
	} # }}}
	isExpectingType() => @declarators[0].isStronglyTyped()
	isImmutable() => @immutable
	isLateInit() => @lateInit
	isUsingVariable(name) { # {{{
		if @hasValue {
			return @value.isUsingVariable(name)
		}

		if @hasExpression {
			return @expression.right().isUsingVariable(name)
		}

		return false
	} # }}}
	isUsingInstanceVariable(name) { # {{{
		if @hasValue {
			return @value.isUsingInstanceVariable(name)
		}

		if @hasExpression {
			return @expression.right().isUsingInstanceVariable(name)
		}

		return false
	} # }}}
	isUsingStaticVariable(class, varname) { # {{{
		if @hasValue {
			return @value.isUsingStaticVariable(class, varname)
		}

		if @hasExpression {
			return @expression.right().isUsingStaticVariable(class, varname)
		}

		return false
	} # }}}
	listAssignments(array: Array): valueof array { # {{{
		for var declarator in @declarators {
			declarator.listAssignments(array)
		}
	} # }}}
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		if @hasValue {
			@value.listNonLocalVariables(scope, variables)
		}
		else if @hasExpression {
			@expression.right().listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	setModifier(modifier: ModifierKind) { # {{{
		if modifier == ModifierKind.Dynamic {
			@autotype = false
			@immutable = false
			@rebindable = true
		}
		else if modifier == ModifierKind.Mutable {
			@immutable = false
			@rebindable = true
		}
		else if modifier == ModifierKind.LateInit {
			@lateInit = true
		}
	} # }}}
	toAwaitStatementFragments(fragments, statements) { # {{{
		var line = fragments.newLine()

		var item = @value.toFragments(line, Mode.None)

		statements.unshift(this)

		item(statements)

		line.done()
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @hasValue {
			if @value.isAwaiting() {
				return this.toAwaitStatementFragments^^(fragments, ...)
			}
			else if @value.isInSituStatement() {
				var declarator = @declarators[0]

				fragments.newLine().code('let ').compile(declarator).done()
			}
			else {
				var declarator = @declarators[0]

				var line = fragments.newLine()

				if @toDeclareAll {
					if @options.format.variables == 'es5' {
						line.code('var ')
					}
					else if @rebindable || @redeclared || @mixedMutability {
						line.code('let ')
					}
					else {
						line.code('const ')
					}
				}

				declarator.toAssignmentFragments(line)

				line.done()
			}
		}
		else if @hasExpression {
			@expression.toFragments(fragments, mode)
		}
		else if @redeclared {
			var line = fragments.newLine()

			for var declarator, index in @declarators {
				line.code($comma) if index != 0

				line.compile(declarator).code(' = null')
			}

			line.done()
		}
	} # }}}
	toInlineFragments(fragments, mode) { # {{{
		if @value.isAwaiting() {
			NotImplementedException.throw(this)
		}
		else {
			@declarators[0].toAssignmentFragments(fragments)
		}
	} # }}}
	type() => @type
	value() => @value
	override walkVariable(fn) { # {{{
		for var declarator in @declarators {
			declarator.walkVariable(fn)
		}
	} # }}}
}

class VariableBindingDeclarator extends AbstractNode {
	private {
		@binding
		@type: Type?						= null
	}
	analyse() { # {{{
		@binding = $compile.expression(@data.name, this)

		@binding.setAssignment(AssignmentType.Declaration)

		if @parent.isImmutable() {
			@binding.flagImmutable()
		}

		@binding.analyse()

		@parent.defineVariables(@binding)
	} # }}}
	override prepare(target, targetMode) { # {{{
		if ?@data.type {
			@setDeclaredType(Type.fromAST(@data.type, this))
		}
		else if @parent.hasValue() {
			pass
		}
		else if @parent.isImmutable() && !@parent.hasExpression() {
			@setDeclaredType(@parent.type())
		}
	} # }}}
	translate() { # {{{
		@binding.translate()
	} # }}}
	export(recipient) { # {{{
		@binding.export(recipient)
	} # }}}
	flagDefinitive()
	isDeclararingVariable(name: String) => @binding.isDeclararingVariable(name)
	isDuplicate(scope) { # {{{
		return false
	} # }}}
	isRedeclared() => @binding.isRedeclared()
	isSplitAssignment() => @binding.isSplitAssignment()
	isStronglyTyped() => true
	listAssignments(array: Array): valueof array { # {{{
		@binding.listAssignments(array)
	} # }}}
	setDeclaredType(type: Type) { # {{{
		if !?@type {
			if !type.isAny() {
				if @binding is ArrayBinding {
					unless type.isBroadArray() {
						TypeException.throwInvalidBinding('Array', this)
					}
				}
				else {
					unless type.isBroadObject() {
						TypeException.throwInvalidBinding('Object', this)
					}
				}
			}

			@type = type
		}
	} # }}}
	setRealType(type: Type) { # {{{
		if !type.isAny() {
			if @binding is ArrayBinding {
				unless type.isBroadArray() {
					TypeException.throwInvalidBinding('Array', this)
				}
			}
			else {
				unless type.isBroadObject() {
					TypeException.throwInvalidBinding('Object', this)
				}
			}
		}

		@binding
			..type(@type)
			..value(@parent.value()) if @parent.hasValue()
			..prepare()
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@binding)
	} # }}}
	toAssertFragments(fragments, value) => @binding.toAssertFragments(fragments, value, true)
	toAssignmentFragments(fragments, value? = null) => @binding.toAssignmentFragments(fragments, value ?? @parent.value())
	type() => @type
	override walkVariable(fn) { # {{{
		@binding.walkVariable(fn)
	} # }}}
}

class VariableIdentifierDeclarator extends AbstractNode {
	private late {
		@assert: Boolean					= false
		@identifier: IdentifierLiteral
		@lateInit: Boolean					= false
		@name: String
		@nullable: Boolean					= false
		@redeclared: Boolean				= false
		@type: Type?						= null
		@variable: Variable
	}
	analyse() { # {{{
		@name = @data.name.name

		@redeclared = @scope.hasDeclaredVariable(@name)

		@identifier = IdentifierLiteral.new(@data.name, this, @scope)
			..setAssignment(AssignmentType.Declaration)
			..analyse()

		@parent.defineVariables(@identifier)

		@variable = @identifier.variable()
		@lateInit = @parent.isLateInit()

		if @lateInit {
			@variable.flagLateInit()
		}

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Nullable {
				@nullable = true
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if ?@data.type {
			@type = Type.fromAST(@data.type, this)

			if @type.isNull() {
				TypeException.throwNullTypeVariable(@name, this)
			}

			@variable.setDeclaredType(@type, @parent.hasValue()).flagDefinitive()
		}
		else if @parent.hasValue() {
			pass
		}
		else {
			@type = AnyType.NullableUnexplicit

			@variable.setDeclaredType(@type, false).flagDefinitive()
		}
	} # }}}
	translate() { # {{{
		@identifier.translate()

		if @lateInit && !@variable.isInitialized() {
			SyntaxException.throwNotInitializedVariable(@name, this)
		}
	} # }}}
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	flagDefinitive() { # {{{
		@variable.flagDefinitive()
	} # }}}
	isDuplicate(mut scope) { # {{{
		if scope.hasDeclaredVariable(@name) {
			return true
		}

		while scope.isInline() {
			scope = scope.parent()

			if scope.hasDeclaredVariable(@name) {
				return true
			}
		}

		return false
	} # }}}
	isDeclararingVariable(name: String) => @name == name
	isRedeclared() => @redeclared || @scope.isRedeclaredVariable(@name)
	isSplitAssignment() => false
	isStronglyTyped() => ?@data.type
	listAssignments(array: Array): valueof array { # {{{
		@identifier.listAssignments(array)
	} # }}}
	name() => @name
	setDeclaredType(mut type: Type) { # {{{
		if !?@type {
			if !?@data.type {
				type = type.unspecify()
			}

			if @nullable && !type.isNullable() {
				@variable.setDeclaredType(type.setNullable(true))
			}
			else {
				@variable.setDeclaredType(type)
			}

			@type = type

			@identifier.prepare()
		}
	} # }}}
	setRealType(mut type: Type) { # {{{
		if ?@type {
			unless type.isAssignableToVariable(@type, true, false, false) {
				TypeException.throwInvalidAssignment(@name, @type, type, this)
			}

			@assert = !type.isAssignableToVariable(@type, false, false, false)

			if type.isLiberal() {
				if @type.isAlias() {
					type = @type.tryCastingTo(type)
				}

				if @type.isObject() && type is ObjectType {
					if @type.hasRest() {
						if @type is ObjectType {
							type.setRestType(@type.getRestType())
						}
					}
					else {
						type.unflagLiberal()
					}
				}
			}
		}

		if @nullable && !type.isNullable() {
			@variable.setRealType(type.setNullable(true))
		}
		else {
			@variable.setRealType(type)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@identifier)
	} # }}}
	toAssertFragments(fragments, value)
	toAssignmentFragments(fragments, value ??= @parent.value()) { # {{{
		fragments.compile(@identifier).code($equals)

		if @assert {
			fragments.code(`\($runtime.helper(this)).assert(`)
		}

		if value is DisruptiveExpression {
			fragments.wrap(value)
		}
		else {
			fragments.compile(value)
		}

		if @assert {
			fragments.code(`, \($quote(@type.toQuote(true))), \(if @nullable set '1' else '0'), `)

			@type.toAwareTestFunctionFragments('value', false, false, true, false, null, null, fragments, this)

			fragments.code(')')
		}
	} # }}}
	type() => @type
	variable() => @variable
	override walkVariable(fn) { # {{{
		fn(@variable.getSecureName(), @variable.getRealType())
	} # }}}
}
