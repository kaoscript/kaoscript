func $return(data? = null) { # {{{
	return {
		kind: NodeKind::ReturnStatement
		value: data
		start: data.start
	}
} # }}}

class ArrayComprehensionForFrom extends Expression {
	private {
		@bindingScope
		@body
		@bodyScope
		@from
		@to
		@step				= null
		@variable
		@when			= null
	}
	analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType::InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		@bindingScope.define(@data.loop.variable.name, false, @scope.reference('Number'), true, this)

		@variable = $compile.expression(@data.loop.variable, this, @bindingScope)
		@variable.analyse()

		@from = $compile.expression(@data.loop.from, this, @scope)
		@from.analyse()

		@to = $compile.expression(@data.loop.to, this, @scope)
		@to.analyse()

		if ?@data.loop.step {
			@step = $compile.expression(@data.loop.step, this, @scope)
			@step.analyse()
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.initiate()
		@body.analyse()

		if ?@data.loop.when {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.initiate()
			@when.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.isAny() || target.isArray() {
			TypeException.throwInvalidComprehensionType(target, this)
		}

		@variable.prepare(AnyType.NullableUnexplicit)
		@from.prepare(@scope.reference('Number'))
		@to.prepare(@scope.reference('Number'))
		@step?.prepare(@scope.reference('Number'))
		@when?.prepare(@scope.reference('Boolean'))
		@body.prepare(target.isArray() ? target.parameter() : AnyType.NullableUnexplicit)
	} # }}}
	translate() { # {{{
		@variable.translate()
		@from.translate()
		@to.translate()
		@step?.translate()
		@body.translate()
		@when?.translate()
	} # }}}
	isUsingVariable(name) =>	@from.isUsingVariable(name) ||
								@to.isUsingVariable(name) ||
								@step?.isUsingVariable(name) ||
								@when?.isUsingVariable(name) ||
								@body.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@from.listNonLocalVariables(scope, variables)
		@to.listNonLocalVariables(scope, variables)
		@step?.listNonLocalVariables(scope, variables)
		@when?.listNonLocalVariables(scope, variables)
		@body?.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		@module().flag('Helper')

		var surround = $function.surround(@data.body, this)

		fragments
			.code($runtime.helper(this), '.mapRange(')
			.compile(@from)
			.code($comma)
			.compile(@to)

		if ?@step {
			fragments.code($comma).compile(@step)
		}
		else {
			fragments.code(', 1')
		}

		fragments.code($comma, !$ast.hasModifier(@data.loop.from, ModifierKind::Ballpark), $comma, !$ast.hasModifier(@data.loop.to, ModifierKind::Ballpark), $comma)

		fragments
			.code(surround.beforeParameters)
			.compile(@variable)
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if ?@when {
			var surround = $function.surround(@data.loop.when, this)

			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@variable)
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} # }}}
	type() => @scope.reference('Array')
}

class ArrayComprehensionForIn extends Expression {
	private late {
		@bindingScope
		@body
		@bodyScope
		@declaration: Boolean				= false
		@declaredVariables: Array			= []
		@declareIndex: Boolean				= false
		@declareValue: Boolean				= false
		@descending: Boolean				= false
		@expression
		@index
		@immutable: Boolean					= false
		@type: Type
		@value
		@valueName: String
		@when								= null
	}
	analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType::InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		for var modifier in @data.loop.modifiers {
			if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
			else if modifier.kind == ModifierKind::Descending {
				@descending = true
			}
		}

		@expression = $compile.expression(@data.loop.expression, this, @scope)
		@expression.analyse()

		if ?@data.loop.value {
			@value = $compile.expression(@data.loop.value, this, @bindingScope)
			@value.setAssignment(AssignmentType::Expression)
			@value.analyse()

			for var name in @value.listAssignments([]) {
				var variable = @scope.getVariable(name)

				if @declaration || variable == null {
					@declareValue = true

					@declaredVariables.push(@bindingScope.define(name, @immutable, AnyType.NullableUnexplicit, true, this))
				}
				else if variable.isImmutable() {
					ReferenceException.throwImmutable(name, this)
				}
			}
		}
		else {
			@valueName = @bindingScope.acquireTempName()
		}

		if ?@data.loop.index {
			var variable = @bindingScope.getVariable(@data.loop.index.name)

			if @declaration || variable == null {
				@bindingScope.define(@data.loop.index.name, @immutable, @bindingScope.reference('Number'), true, this)

				@declareIndex = true
			}
			else if variable.isImmutable() {
				ReferenceException.throwImmutable(@data.loop.index.name, this)
			}

			@index = $compile.expression(@data.loop.index, this, @bindingScope)
			@index.analyse()
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.initiate()
		@body.analyse()

		if ?@data.loop.when {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.initiate()
			@when.analyse()
		}

		@bindingScope.releaseTempName(@valueName) if ?@valueName
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.isAny() || target.isArray() {
			TypeException.throwInvalidComprehensionType(target, this)
		}

		@expression.prepare(@scope.reference('Array'))

		var type = @expression.type()
		unless type.isAny() || type.isArray() {
			TypeException.throwInvalidForInExpression(this)
		}

		if ?@value {
			var parameterType = type.parameter()

			var valueType = Type.fromAST(@data.type, this)
			unless parameterType.matchContentOf(valueType) {
				TypeException.throwInvalidAssignement(@value, valueType, parameterType, this)
			}

			var realType = parameterType.isMorePreciseThan(valueType) ? parameterType : valueType

			if @value is IdentifierLiteral {
				if @declareValue {
					@value.type(realType, @bindingScope, this)
				}
				else {
					@bindingScope.replaceVariable(@value.name(), realType, this)
				}
			}
			else {
				for var name in @value.listAssignments([]) {
					@bindingScope.replaceVariable(name, realType.getProperty(name), this)
				}
			}
		}

		if ?@index {
			unless @declareIndex {
				@bindingScope.replaceVariable(@data.loop.index.name, @bindingScope.reference('Number'), this)
			}

			@index.prepare(@scope.reference('Number'))
		}

		@body.prepare(target.isArray() ? target.parameter() : AnyType.NullableUnexplicit)

		if @body.type().isAny() {
			@type = @scope.reference('Array')
		}
		else {
			@type = Type.arrayOf(@body.type(), @scope)
		}

		if ?@when {
			@when.prepare(@scope.reference('Boolean'))
		}
	} # }}}
	translate() { # {{{
		@expression.translate()
		@value.translate() if ?@value
		@index.translate() if ?@index
		@body.translate()
		@when.translate() if ?@when
	} # }}}
	isUsingVariable(name) => @expression.isUsingVariable(name) || (@when != null && @when.isUsingVariable(name)) || @body.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@expression.listNonLocalVariables(scope, variables)
		@when?.listNonLocalVariables(scope, variables)
		@body?.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		@module().flag('Helper')

		var surround = $function.surround(@data.body, this)

		fragments
			.code($runtime.helper(this), '.mapArray(')
			.compile(@expression)
			.code(', ')

		fragments
			.code(surround.beforeParameters)
			.compile(@value ?? @valueName)

		fragments.code($comma).compile(@index) if ?@index

		fragments
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if ?@when {
			var surround = $function.surround(@data.loop.when, this)

			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@value ?? @valueName)

			fragments.code($comma).compile(@index) if ?@index

			fragments
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} # }}}
	type() => @type
}

class ArrayComprehensionForOf extends Expression {
	private late {
		@bindingScope
		@body
		@bodyScope
		@declaration: Boolean				= false
		@defineKey: Boolean					= false
		@defineValue: Boolean				= false
		@expression
		@key
		@keyName
		@immutable: Boolean					= false
		@value
		@when								= null
	}
	analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType::InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		for var modifier in @data.loop.modifiers {
			if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
		}

		@expression = $compile.expression(@data.loop.expression, this, @scope)
		@expression.analyse()

		if ?@data.loop.key {
			var keyVariable = @scope.getVariable(@data.loop.key.name)

			if @declaration || keyVariable == null {
				@bindingScope.define(@data.loop.key.name, @immutable, @bindingScope.reference('String'), true, this)

				@defineKey = true
			}
			else if keyVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.loop.key.name, this)
			}

			@key = $compile.expression(@data.loop.key, this, @bindingScope)
			@key.analyse()
		}
		else {
			@keyName = @bindingScope.acquireTempName()
		}

		if ?@data.loop.value {
			@value = $compile.expression(@data.loop.value, this, @bindingScope)
			@value.setAssignment(AssignmentType::Expression)
			@value.analyse()

			for var name in @value.listAssignments([]) {
				var variable = @bindingScope.getVariable(name)

				if @declaration || variable == null {
					@defineValue = true

					@bindingScope.define(name, @immutable, AnyType.NullableUnexplicit, true, this)
				}
				else if variable.isImmutable() {
					ReferenceException.throwImmutable(name, this)
				}
			}
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.initiate()
		@body.analyse()

		if ?@data.loop.when {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.initiate()
			@when.analyse()
		}

		@bindingScope.releaseTempName(@keyName) if ?@keyName
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.isAny() || target.isArray() {
			TypeException.throwInvalidComprehensionType(target, this)
		}

		@expression.prepare(AnyType.NullableUnexplicit)

		var type = @expression.type()
		if !(type.isAny() || type.isObject()) {
			TypeException.throwInvalidForOfExpression(this)
		}

		if ?@value {
			var parameterType = type.parameter()

			var valueType = Type.fromAST(@data.type, this)
			unless parameterType.matchContentOf(valueType) {
				TypeException.throwInvalidAssignement(@value, valueType, parameterType, this)
			}

			var realType = parameterType.isMorePreciseThan(valueType) ? parameterType : valueType

			if @value is IdentifierLiteral {
				if @defineValue {
					@value.type(realType, @bindingScope, this)
				}
				else {
					@bindingScope.replaceVariable(@value.name(), realType, this)
				}
			}
			else {
				for var name in @value.listAssignments([]) {
					@bindingScope.replaceVariable(name, realType.getProperty(name), this)
				}
			}
		}

		if ?@key {
			unless @defineKey {
				@bindingScope.replaceVariable(@data.key.name, @bindingScope.reference('String'), this)
			}

			@key.prepare(@scope.reference('String'))
		}

		@body.prepare(target.isArray() ? target.parameter() : AnyType.NullableUnexplicit)

		if ?@when {
			@when.prepare(@scope.reference('Boolean'))
		}
	} # }}}
	translate() { # {{{
		@expression.translate()
		@key.translate() if ?@key
		@value.translate() if ?@value
		@body.translate()
		@when.translate() if ?@when
	} # }}}
	isUsingVariable(name) => @expression.isUsingVariable(name) || (@when != null && @when.isUsingVariable(name)) || @body.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@expression.listNonLocalVariables(scope, variables)
		@when?.listNonLocalVariables(scope, variables)
		@body?.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		@module().flag('Helper')

		var surround = $function.surround(@data.body, this)

		fragments
			.code($runtime.helper(this), '.mapObject(')
			.compile(@expression)
			.code(', ')

		fragments
			.code(surround.beforeParameters)
			.compile(@key ?? @keyName)

		fragments.code($comma).compile(@value) if ?@value

		fragments
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if ?@when {
			var surround = $function.surround(@data.loop.when, this)

			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@key ?? @keyName)

			fragments.code($comma).compile(@value) if ?@value

			fragments
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} # }}}
	type() => @scope.reference('Array')
}

class ArrayComprehensionForRange extends Expression {
	private {
		@bindingScope
		@body
		@bodyScope
		@by				= null
		@from
		@to
		@value
		@when			= null
	}
	analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType::InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		@bindingScope.define(@data.loop.value.name, false, @scope.reference('Number'), true, this)

		@value = $compile.expression(@data.loop.value, this, @bindingScope)
		@value.analyse()

		@from = $compile.expression(@data.loop.from, this, @scope)
		@from.analyse()

		@to = $compile.expression(@data.loop.to, this, @scope)
		@to.analyse()

		if ?@data.loop.by {
			@by = $compile.expression(@data.loop.by, this, @scope)
			@body.analyse()
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.initiate()
		@body.analyse()

		if ?@data.loop.when {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.initiate()
			@when.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.isAny() || target.isArray() {
			TypeException.throwInvalidComprehensionType(target, this)
		}

		@value.prepare(AnyType.NullableUnexplicit)
		@from.prepare(@scope.reference('Number'))
		@to.prepare(@scope.reference('Number'))
		@by.prepare(@scope.reference('Number')) if ?@by
		@when.prepare(@scope.reference('Boolean')) if ?@when
		@body.prepare(target.isArray() ? target.parameter() : AnyType.NullableUnexplicit)
	} # }}}
	translate() { # {{{
		@value.translate()
		@from.translate()
		@to.translate()
		@by.translate() if ?@by
		@body.translate()
		@when.translate() if ?@when
	} # }}}
	isUsingVariable(name) =>	@from.isUsingVariable(name) ||
								@to.isUsingVariable(name) ||
								(@by != null && @by.isUsingVariable(name)) ||
								(@when != null && @when.isUsingVariable(name)) ||
								@body.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@from.listNonLocalVariables(scope, variables)
		@to.listNonLocalVariables(scope, variables)
		@by?.listNonLocalVariables(scope, variables)
		@when?.listNonLocalVariables(scope, variables)
		@body?.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		@module().flag('Helper')

		var surround = $function.surround(@data.body, this)

		fragments
			.code($runtime.helper(this), '.mapRange(')
			.compile(@from)
			.code($comma)
			.compile(@to)

		if ?@by {
			fragments.code(', ').compile(@by)
		}
		else {
			fragments.code(', 1')
		}

		fragments
			.code($comma, 'true', $comma, 'true', $comma)
			.code(surround.beforeParameters)
			.compile(@value)
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if ?@when {
			var surround = $function.surround(@data.loop.when, this)

			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@value)
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} # }}}
	type() => @scope.reference('Array')
}

class ArrayComprehensionRepeat extends Expression {
	private late {
		@body
		@bodyScope: Scope
		@to
		@toName: String
	}
	analyse() { # {{{
		@bodyScope = @newScope(@scope!?, ScopeType::InlineBlock)

		@to = $compile.expression(@data.loop.expression, this, @scope)
		@to.analyse()

		@body = $compile.block($return(@data.body), this, @bodyScope)
		@body.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.isAny() || target.isArray() {
			TypeException.throwInvalidComprehensionType(target, this)
		}

		@to.prepare(@scope.reference('Number'))
		@body.prepare(target.isArray() ? target.parameter() : AnyType.NullableUnexplicit)
	} # }}}
	translate() { # {{{
		@to.translate()
		@body.translate()
	} # }}}
	isUsingVariable(name) => @to.isUsingVariable(name) || @body.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@to.listNonLocalVariables(scope, variables)
		@body?.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		@module().flag('Helper')

		var surround = $function.surround(@data.body, this)

		fragments
			.code($runtime.helper(this), '.mapRange(0, ')
			.compile(@to)
			.code(', 1')
			.code($comma, 'true', $comma, 'true', $comma)
			.code(surround.beforeParameters)
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		fragments.code(')')
	} # }}}
	type() => @scope.reference('Array')
}
