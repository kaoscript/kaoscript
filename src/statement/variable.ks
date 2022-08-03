class VariableDeclaration extends Statement {
	private late {
		_autotype: Boolean			= false
		_await: Boolean				= false
		_cascade: Boolean			= false
		_declarators: Array			= []
		_function					= null
		_hasInit: Boolean			= false
		_immutable: Boolean			= true
		_init
		_initScope: Scope
		_lateInit: Boolean			= false
		_rebindable: Boolean		= false
		_redeclared: Boolean		= false
		_toDeclareAll: Boolean		= true
		_try						= null
		_type: Type					= Type.Null
	}
	constructor(@data, @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)

		var mut ancestor = parent

		while ancestor? && !(
			ancestor is AnonymousFunctionExpression ||
			ancestor is ArrowFunctionExpression ||
			ancestor is FunctionDeclarator ||
			ancestor is ClassMethodDeclaration ||
			ancestor is ImplementClassMethodDeclaration ||
			ancestor is ImplementNamespaceFunctionDeclaration
		) {
			if ancestor is TryStatement {
				@try = ancestor
			}

			ancestor = ancestor.parent()
		}

		if ancestor? {
			@function = ancestor
		}
	} # }}}
	constructor(@data, @parent, @scope, @initScope, @cascade) { # {{{
		this(data, parent, scope)
	} # }}}
	override initiate() { # {{{
		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Dynamic {
				@immutable = false
				@rebindable = true
			}
			else if modifier.kind == ModifierKind::Mutable {
				@autotype = true
				@immutable = false
				@rebindable = true
			}
			else if modifier.kind == ModifierKind::LateInit {
				@lateInit = true
			}
		}

		var mut declarator
		for data in @data.variables {
			switch data.name.kind {
				NodeKind::ArrayBinding => {
					declarator = new VariableBindingDeclarator(data, this)
				}
				NodeKind::Identifier => {
					declarator = new VariableIdentifierDeclarator(data, this)
				}
				NodeKind::ObjectBinding => {
					declarator = new VariableBindingDeclarator(data, this)
				}
				=> {
					throw new NotImplementedException(this)
				}
			}

			declarator.analyse()

			@declarators.push(declarator)
		}
	} # }}}
	analyse() { # {{{
		if @data.init? {
			@hasInit = true

			if @immutable {
				@rebindable = ?@initScope
			}

			@initScope ??= this.newScope(@scope, ScopeType::Hollow)

			var line = @initScope.getRawLine()

			@initScope.line(line - 1)

			@init = $compile.expression(@data.init, this, @initScope)
			@init.analyse()

			@initScope.line(line)

			@await = @init.isAwait()

			if @await && !?@function && !this.module().isBinary() {
				SyntaxException.throwInvalidAwait(this)
			}
		}

		if @hasInit && @declarators.length == 1 {
			if @declarators[0] is VariableIdentifierDeclarator {
				this.reference(@declarators[0].name())
			}
		}

	} # }}}
	prepare() { # {{{
		var declarator = @declarators[0]

		if @hasInit {
			@init.prepare()

			@type = @init.type()

			if @type.isInoperative() {
				TypeException.throwUnexpectedInoperative(@init, this)
			}

			if @parent is IfStatement {
				@type = @type.setNullable(false)
			}

			if @autotype {
				if @type.isNull() {
					declarator.setDeclaredType(AnyType.NullableExplicit)
				}
				else {
					declarator.setDeclaredType(@type)
				}

				declarator.flagDefinitive()
			}
			else {
				declarator.setRealType(@type)
			}

			this.assignTempVariables(@initScope)
		}

		for var declarator in @declarators {
			declarator.prepare()

			if declarator.isRedeclared() {
				@redeclared = true
			}
		}

		if @hasInit {
			declarator.setRealType(@type)

			if declarator is VariableIdentifierDeclarator {
				if var type = declarator.type() {
					@init.validateType(type)
				}
			}

			@init.acquireReusable(declarator.isSplitAssignment())
			@init.releaseReusable()

			this.statement().assignTempVariables(@scope)
		}
		else {
			@type = @declarators[0].variable().getRealType()
		}
	} # }}}
	translate() { # {{{
		if @hasInit {
			@init.translate()
		}

		for declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	declarator() => @declarators[0]
	defineVariables(declarator) { # {{{
		var mut alreadyDeclared

		var assignments = []

		for var name in declarator.listAssignments([]) {
			if @scope.hasDefinedVariable(name) {
				SyntaxException.throwAlreadyDeclared(name, this)
			}

			alreadyDeclared = @scope.hasDeclaredVariable(name)

			var variable = @scope.define(name, this.isImmutable(), null, this)

			if alreadyDeclared {
				alreadyDeclared = !variable.isRenamed()
			}

			if alreadyDeclared {
				@toDeclareAll = false
			}
			else {
				assignments.push(variable.getSecureName())
			}
		}

		if @cascade {
			@parent.addAssignments(assignments)
		}
	} # }}}
	export(recipient) { # {{{
		for declarator in @declarators {
			declarator.export(recipient)
		}
	} # }}}
	hasInit() => @hasInit
	getIdentifierVariable() { # {{{
		if @declarators.length == 1 && @declarators[0] is VariableIdentifierDeclarator {
			return @declarators[0]._variable
		}
		else {
			return null
		}
	} # }}}
	init() => @init
	isAutoTyping() => @autotype
	isAwait() => @await
	isDeclararingVariable(name: String) { # {{{
		for declarator in @declarators {
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
	isUsingVariable(name) => @hasInit && @init.isUsingVariable(name)
	isUsingInstanceVariable(name) => @hasInit && @init.isUsingInstanceVariable(name)
	isUsingStaticVariable(class, varname) => @hasInit && @init.isUsingStaticVariable(class, varname)
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		if @hasInit {
			@init.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	toAwaitStatementFragments(fragments, statements) { # {{{
		var line = fragments.newLine()

		var item = @init.toFragments(line, Mode::None)

		statements.unshift(this)

		item(statements)

		line.done()
	} # }}}
	toFragments(fragments, mode) { # {{{
		var variables = this.assignments()
		if variables.length != 0 {
			fragments.newLine().code($runtime.scope(this) + variables.join(', ')).done()
		}

		if @hasInit {
			if @init.isAwaiting() {
				return this.toAwaitStatementFragments^@(fragments)
			}
			else {
				var declarator = @declarators[0]

				var mut line = fragments.newLine()

				if @toDeclareAll {
					if @options.format.variables == 'es5' {
						line.code('var ')
					}
					else if @rebindable || @redeclared {
						line.code('let ')
					}
					else {
						line.code('const ')
					}
				}

				declarator.toAssignmentFragments(line, @init)

				line.done()
			}
		}
		else {
			var mut line = fragments.newLine()

			if @toDeclareAll {
				if @options.format.variables == 'es5' {
					line.code('var ')
				}
				else {
					line.code('let ')
				}
			}

			for declarator, index in @declarators {
				line.code($comma) if index != 0

				line.compile(declarator).code(' = null')
			}

			line.done()
		}
	} # }}}
	toInlineFragments(fragments, mode) { # {{{
		if @init.isAwaiting() {
			NotImplementedException.throw(this)
		}
		else {
			@declarators[0].toAssignmentFragments(fragments, @init)
		}
	} # }}}
	type() => @type
	walk(fn) { # {{{
		for declarator in @declarators {
			declarator.walk(fn)
		}
	} # }}}
}

class VariableBindingDeclarator extends AbstractNode {
	private {
		_binding
		_type: Type?						= null
	}
	analyse() { # {{{
		@binding = $compile.expression(@data.name, this)

		@binding.setAssignment(AssignmentType::Declaration)

		if @parent.isImmutable() {
			@binding.flagImmutable()
		}

		@binding.analyse()

		@parent.defineVariables(@binding)
	} # }}}
	prepare() { # {{{
		if @data.type? {
			this.setDeclaredType(Type.fromAST(@data.type, this))
		}
		else if @parent.isImmutable() {
			this.setDeclaredType(@parent.type())
		}

		@binding.prepare()
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
	setDeclaredType(@type) { # {{{
		if !@type.isAny() {
			if @binding is ArrayBinding {
				unless type.isArray() || type.isTuple() {
					TypeException.throwInvalidBinding('Array', this)
				}
			}
			else {
				unless type.isDictionary() || type.isStruct() {
					TypeException.throwInvalidBinding('Dictionary', this)
				}
			}

			@binding.type(@type)
		}
	} # }}}
	setRealType(type: Type) { # {{{
		if !type.isAny() {
			if @binding is ArrayBinding {
				unless type.isArray() || type.isTuple() {
					TypeException.throwInvalidBinding('Array', this)
				}
			}
			else {
				unless type.isDictionary() || type.isStruct() {
					TypeException.throwInvalidBinding('Dictionary', this)
				}
			}
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@binding)
	} # }}}
	toAssignmentFragments(fragments, value) => @binding.toAssignmentFragments(fragments, value)
	walk(fn) { # {{{
		@binding.walk(fn)
	} # }}}
}

class VariableIdentifierDeclarator extends AbstractNode {
	private late {
		_identifier: IdentifierLiteral
		_lateInit: Boolean					= false
		_name: String
		_type: Type?						= null
		_variable: Variable
	}
	analyse() { # {{{
		@name = @data.name.name

		@identifier = new IdentifierLiteral(@data.name, this, @scope)
		@identifier.setAssignment(AssignmentType::Declaration)
		@identifier.analyse()

		@parent.defineVariables(@identifier)

		@variable = @identifier.variable()
		@lateInit = @parent.isLateInit()

		if @lateInit {
			@variable.flagLateInit()
		}
	} # }}}
	prepare() { # {{{
		if @data.type? {
			@type = Type.fromAST(@data.type, this)

			if @type.isNull() {
				TypeException.throwNullTypeVariable(@name, this)
			}

			@variable.setDeclaredType(@type, @parent.hasInit()).flagDefinitive()
		}
		else if @parent.isAutoTyping() {
			// do nothing
		}
		else if !@lateInit || !@parent.isImmutable() {
			if @parent.isImmutable() {
				@type = @variable.getRealType()
			}
			else {
				@type = AnyType.NullableUnexplicit
			}

			@variable.setDeclaredType(@type, @parent.hasInit()).flagDefinitive()
		}

		@identifier.prepare()
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
	isRedeclared() => @scope.isRedeclaredVariable(@name)
	isSplitAssignment() => false
	isStronglyTyped() => @data.type?
	name() => @name
	setDeclaredType(type: Type) { # {{{
		if @type == null {
			@variable.setDeclaredType(type)
		}
	} # }}}
	setRealType(type: Type) { # {{{
		if @type != null {
			if !type.isAssignableToVariable(@type, false) {
				TypeException.throwInvalidAssignement(@name, @type, type, this)
			}
		}

		@variable.setRealType(type)
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@identifier)
	} # }}}
	toAssignmentFragments(fragments, value) { # {{{
		fragments
			.compile(@identifier)
			.code($equals)
			.compile(value)
	} # }}}
	type() => @type
	variable() => @variable
	walk(fn) { # {{{
		fn(@variable.getSecureName(), @variable.getRealType())
	} # }}}
}
