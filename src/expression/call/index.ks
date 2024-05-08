class CallExpression extends Expression {
	private late {
		@acquiredReusable: Boolean				= false
		@analysed: Boolean						= false
		@arguments: Array						= []
		@assessment: Router.Assessment?
		@await: Boolean							= false
		@callee: Expression?					= null
		@callees: Callee[]						= []
		@calleeByHash: Object<Callee>			= {}
		@flatten: Boolean						= false
		@hasDefaultCallee: Boolean				= false
		@named: Boolean							= false
		@matchingMode: ArgumentMatchMode		= .BestMatch
		@nullable: Boolean						= false
		@nullableComputed: Boolean				= false
		@nullableTesting: Boolean				= false
		@object: Expression?					= null
		@prepared: Boolean						= false
		@preparedArguments: Boolean				= false
		@property: String
		@releasedReusable: Boolean				= false
		@reusable: Boolean						= false
		@reuseName: String?						= null
		@tested: Boolean						= false
		@testedType: Type
		@thisScope
		@thisType: Type?						= null
		@translated: Boolean					= false
		@type: Type
	}
	static {
		toFlattenArgumentsFragments(fragments, arguments, prefill? = null) { # {{{
			if arguments.length == 0 {
				fragments.code('[]')
			}
			else if arguments.length == 1 && !?prefill && arguments[0].isSpread() && arguments[0].argument().type().isArray() {
				arguments[0].argument().toArgumentFragments(fragments)
			}
			else {
				if prefill == null {
					fragments.code('[].concat(')
				}
				else {
					fragments.code('[').compile(prefill).code('].concat(')
				}

				var mut opened = false

				for var argument, index in arguments {
					if argument.isSpread() {
						if opened {
							fragments.code('], ')

							opened = false
						}
						else if index != 0 {
							fragments.code($comma)
						}

						argument.argument().toArgumentFragments(fragments)
					}
					else {
						if index != 0 {
							fragments.code($comma)
						}

						if !opened {
							fragments.code('[')

							opened = true
						}

						argument.toArgumentFragments(fragments)
					}
				}

				if opened {
					fragments.code(']')
				}

				fragments.code(')')
			}
		} # }}}
	}
	analyse() { # {{{
		return if @analysed

		@analysed = true

		for var data in @data.arguments {
			var argument = $compile.expression(data, this)

			argument.analyse()

			if argument.isAwait() {
				@await = true
			}

			if argument is NamedArgument {
				@named = true
			}

			@arguments.push(argument)
		}

		if @data.callee.kind == NodeKind.MemberExpression {
			var mut computed = false
			var mut nullable = false

			for var modifier in @data.callee.modifiers {
				if modifier.kind == ModifierKind.Computed {
					computed = true

					break
				}
				else if modifier.kind == ModifierKind.Nullable {
					nullable = true
				}
			}

			if !computed {
				@object = $compile.expression(@data.callee.object, this)
					..analyse()

				@property = @data.callee.property.name
				@nullableTesting = nullable
			}
		}
		else {
			@callee = $compile.expression(@data.callee, this)
				..analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		return if @prepared

		@prepared = true

		@prepareThisScope()

		if ?@object {
			@object.prepare(AnyType.NullableUnexplicit)

			@object.makeMemberCallee(@property, @nullableTesting, null, this)

			// TODO! test if method is modifing the object
			if @matchingMode == .BestMatch {
				@object.unspecify()
			}
		}
		else if ?@callee {
			@callee.prepare(AnyType.NullableUnexplicit)

			@callee.makeCallee(null, this)
		}
		else {
			if @named {
				NotImplementedException.throw(this)
			}

			@prepareArguments()

			@addCallee(DefaultCallee.new(@data, null, null, this))
		}

		if #@callees == 1 {
			@nullable = @callees[0].isNullable()
			@nullableComputed = @callees[0].isNullableComputed()

			@testedType = @type = @callees[0].type()

			if @nullableTesting {
				if @type.isExplicit() {
					@type = @type.setNullable(true)
				}
				else {
					@type = UnionType.new(@scope(), [@type, Type.Null])
				}
			}
		}
		else {
			@nullable = false
			@nullableComputed = false
			@callees = Type.sort(@callees, callee => callee.getTestType())

			var types = []

			for var callee in @callees {
				var type = callee.type()

				if !types.any((item, _, _) => type.equals(item)) {
					types.push(type)
				}

				@nullable ||= callee.isNullable()
				@nullableComputed ||= callee.isNullableComputed()
			}

			if @nullableTesting {
				@testedType = Type.union(@scope(), ...types)

				@type = UnionType.new(@scope(), [...types, Type.Null])
			}
			else {
				@testedType = @type = Type.union(@scope(), ...types)
			}

		}
		// echo('-- callees --')
		// echo(@callees)
		// echo(@property)
		// echo(@testedType.hashCode())
		// echo(@type.hashCode())
	} # }}}
	translate() { # {{{
		return if @translated

		@translated = true

		for var argument in @arguments {
			argument.translate()
		}

		for var callee in @callees {
			callee.translate()
		}

		@thisScope?.translate()
	} # }}}
	acquireReusable(mut acquire) { # {{{
		return if @acquiredReusable

		@acquiredReusable = true

		if acquire {
			@reuseName = @scope.acquireTempName()
		}

		if #@callees == 1 {
			@callees[0].acquireReusable(acquire)
		}
		else if #@callees > 1 {
			for var callee in @callees to~ -1 {
				callee.acquireReusable(true)
			}

			@callees.last().acquireReusable(acquire)
		}

		for var argument in @arguments {
			argument.acquireReusable(@callees.some((callee, ...) => callee.shouldArgumentUseReusable(argument)))
		}
	} # }}}
	addCallee(callee: Callee) { # {{{
		@prepareArguments()

		if var hash ?= callee.hashCode() {
			if var main ?= @calleeByHash[hash] {
				main.mergeWith(callee)
			}
			else {
				@callees.push(callee)
				@calleeByHash[hash] = callee
			}
		}
		else {
			@callees.push(callee)
		}
	} # }}}
	argument(index: Number) => @arguments[index]
	arguments() => @arguments
	assessment() => @assessment
	callees() => @callees
	getArgumentsWith(@assessment) { # {{{
		@prepareArguments()

		return @arguments
	} # }}}
	getCallScope(): valueof @thisScope
	getMatchingMode(): valueof @matchingMode
	getReuseName() => @reuseName
	override getTestedType() => @testedType
	inferTypes(inferables) { # {{{
		if ?@object {
			@object.inferTypes(inferables)

			if @nullable && @object.isInferable() {
				inferables[@object.path()] = {
					isVariable: @object.isVariable()
					type: @object.type().discardValue().setNullable(false)
				}
			}
		}

		for var argument in @arguments {
			argument.inferTypes(inferables)
		}

		return inferables
	} # }}}
	isAwait() => @await
	isAwaiting() { # {{{
		for var argument in @arguments {
			if argument.isAwaiting() {
				return true
			}
		}

		return false
	} # }}}
	isBitmaskCreate() => @callees.length == 1 && @callees[0] is BitmaskCreateCallee
	isCallable() => !@reusable
	isContinuousInlineReturn() => @type.isNever()
	isComposite() => !@reusable
	isComputed() => ((@isNullable() || #@callees > 1) && !@tested) || (#@callees == 1 && @callees[0].isComputed())
	isDisrupted() => @object?.isDisrupted() ?? false
	isEnumCreate() => @callees.length == 1 && @callees[0] is EnumCreateCallee
	override isExit(mode) => @type.isNever()
	isExpectingType() => true
	override isInitializingInstanceVariable(name) { # {{{
		for var argument in @arguments {
			if argument.isInitializingInstanceVariable(name) {
				return true
			}
		}

		for var callee in @callees {
			if !callee.isInitializingInstanceVariable(name) {
				return false
			}
		}

		return true
	} # }}}
	isInverted() { # {{{
		for var argument in @arguments {
			if argument.isInverted() {
				return true
			}
		}

		if ?@object {
			return @object.isInverted()
		}

		return false
	} # }}}
	isNullable() { # {{{
		return false if @tested

		for var callee in @callees {
			if callee.isNullable() {
				return true
			}
		}

		return false
	} # }}}
	isNullableComputed() { # {{{
		for var callee in @callees {
			if callee.isNullableComputed() {
				return true
			}
		}

		return false
	} # }}}
	isReferenced() { # {{{
		for var callee in @callees {
			if callee.isReferenced() {
				return true
			}
		}

		return false
	} # }}}
	isReusable() => @reusable
	isReusingName() => ?@reuseName
	isSkippable() => @callees.length == 1 && @callees[0].isSkippable()
	isUndisruptivelyNullable() { # {{{
		return false if @tested

		for var callee in @callees {
			if callee.isUndisruptivelyNullable() {
				return true
			}
		}

		return false
	} # }}}
	isUsingInstanceVariable(name) { # {{{
		if @object != null {
			if @object.isUsingInstanceVariable(name) {
				return true
			}
		}
		else if @data.callee.kind == NodeKind.Identifier && @data.callee.name == name {
			return true
		}

		for var argument in @arguments {
			if argument.isUsingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override isUsingNonLocalVariables(scope) { # {{{
		if @object != null {
			return true if @object.isUsingNonLocalVariables(scope)
		}
		else if @data.callee.kind == NodeKind.Identifier {
			var variable = @scope.getVariable(@data.callee.name)

			if !scope.hasDeclaredVariable(variable.name()) {
				return true
			}
		}

		for var argument in @arguments {
			return true if argument.isUsingNonLocalVariables(scope)
		}

		return false
	} # }}}
	isUsingStaticVariable(class, varname) { # {{{
		if @object != null {
			if @object.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		for var argument in @arguments {
			if argument.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariable(name) { # {{{
		if @object != null {
			if @object.isUsingVariable(name) {
				return true
			}
		}
		else if @data.callee.kind == NodeKind.Identifier && @data.callee.name == name {
			return true
		}

		for var argument in @arguments {
			if argument.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override listLocalVariables(scope, variables) { # {{{
		if @object != null {
			@object.listLocalVariables(scope, variables)
		}
		else if @data.callee.kind == NodeKind.Identifier {
			var variable = @scope.getVariable(@data.callee.name)

			if scope.hasDeclaredVariable(variable.name()) {
				variables.pushUniq(variable)
			}
		}

		for var argument in @arguments {
			argument.listLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		if @object != null {
			@object.listNonLocalVariables(scope, variables)
		}
		else if @data.callee.kind == NodeKind.Identifier {
			var variable = @scope.getVariable(@data.callee.name)

			if !variable.isModule() && !scope.hasDeclaredVariable(variable.name()) {
				variables.pushUniq(variable)
			}
		}

		for var argument in @arguments {
			argument.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	override makeCallee(generics, node) { # {{{
		node.prepareArguments()

		node.addCallee(DefaultCallee.new(node.data(), null, null, node))
	} # }}}
	matchArguments(@assessment, generics: AltType[] = []): CallMatchResult { # {{{
		@prepareArguments()

		return Router.matchArguments(@assessment, @thisType, @arguments, generics, @matchingMode, this)
	} # }}}
	object() => @object
	prepareArguments() { # {{{
		return if @preparedArguments

		for var argument in @arguments {
			argument
				..flagNewExpression()
				..prepare(AnyType.NullableUnexplicit)

			if argument.isDerivative() {
				TypeException.throwNotUniqueValue(argument, this)
			}

			if argument.type()?.isInoperative() {
				TypeException.throwUnexpectedInoperative(argument, this)
			}

			argument.unspecify()
		}

		for var argument in @arguments until @flatten {
			if argument.isSpread() && !argument.isSpreadable() {
				@flatten = true
			}
		}

		@preparedArguments = true
	} # }}}
	prepareThisScope() { # {{{
		if @data.scope.kind == ScopeKind.Argument {
			@thisScope = $compile.expression(@data.scope.value, this)
			@thisScope.analyse()
			@thisScope.prepare(AnyType.NullableUnexplicit)

			@thisType = @thisScope.type()
		}
	} # }}}
	releaseReusable() { # {{{
		return if @releasedReusable

		@releasedReusable = true

		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}

		for var callee in @callees {
			callee.releaseReusable()
		}
	} # }}}
	override setReuseName(name) { # {{{
		@reuseName ??= name
	} # }}}
	toFragments(fragments, mode) { # {{{
		if mode == Mode.Async {
			for var argument in @arguments {
				if argument.isAwaiting() {
					return argument.toFragments(fragments, mode)
				}
			}

			@toCallFragments(fragments, mode)

			fragments.code(', ') if @arguments.length != 0
		}
		else {
			if @reusable {
				fragments.code(@reuseName)
			}
			else {
				var disrupted = @object?.isDisrupted() && @object.isNullable()
				var testing = @isNullable()

				if disrupted {
					@object.toDisruptedFragments(fragments)

					fragments.code(if testing set ' && ' else ' ? ')
				}

				if testing {
					fragments.wrapNullable(this)

					fragments.code(' ? ')

					@tested = true

					@toFragments(fragments, mode)
				}
				else {
					for var argument in @arguments {
						if argument.isAwaiting() {
							return argument.toFragments(fragments, mode)
						}
					}

					@toCallFragments(fragments, mode)

					fragments.code(')')
				}

				if disrupted || testing {
					fragments.code(' : null')
				}
			}
		}
	} # }}}
	toAlternativeFragments(fragments, cb) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @isNullable() && !@tested {
			fragments.wrapNullable(this).code(' ? ')

			@tested = true

			cb(fragments, true, (writer) => @toFragments(writer, Mode.None))

			fragments.code(' : ')

			cb(fragments, false, (_) => {})
		}
		else {
			for var argument in @arguments {
				if argument.isAwaiting() {
					return argument.toFragments(fragments, Mode.None)
				}
			}

			@toCallFragments(fragments, Mode.None)

			fragments.code(')')
		}
	} # }}}
	toDisruptedFragments(fragments) { # {{{
		if @callees.length == 1 {
			@callees[0].toDisruptedFragments(fragments, this)
		}
		else {
			NotImplementedException.throw(this)
		}
	} # }}}
	toCallFragments(fragments, mode) { # {{{
		if #@callees == 1 {
			@callees[0].toFragments(fragments, mode, this)
		}
		else {
			for var callee in @callees to~ -1 {
				callee.toPositiveTestFragments(fragments, this)

				fragments.code(' ? ')

				callee.toFragments(fragments, mode, this)

				fragments.code(') : ')

			}

			@callees.last().toFragments(fragments, mode, this)
		}
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if mode == Mode.Async {
			@toCallFragments(fragments, mode)

			fragments.code(', ') if @arguments.length != 0
		}
		else {
			if @reusable {
				fragments.code(@reuseName)

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}
			}
			else if @isNullable() && !@tested {
				fragments.wrapNullable(this).code(' ? ')

				@tested = true

				this.toFragments(fragments, mode)

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}

				fragments.code(' : false')
			}
			else {
				@toCallFragments(fragments, mode)

				fragments.code(')')

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}
			}
		}
	} # }}}
	toInvertedFragments(fragments, callback) { # {{{
		for var argument in @arguments {
			if argument.isInverted() {
				return argument.toInvertedFragments(fragments, callback)
			}
		}

		@object.toInvertedFragments(fragments, callback)
	} # }}}
	toQuote() { # {{{
		var mut fragments = ''

		if ?@object {
			fragments += `\(@object.toQuote()).\(@property)`
		}
		else if @data.callee.kind == NodeKind.Identifier {
			fragments += @data.callee.name
		}
		else if @data.callee.kind == NodeKind.ThisExpression {
			fragments += `@\(@data.callee.name.name)`
		}
		else {
			NotImplementedException.throw(this)
		}

		fragments += '()'

		return fragments
	} # }}}
	toNullableFragments(fragments) { # {{{
		if !@tested {
			@tested = true

			if @callees.length > 1 {
				for var callee in @callees from 1 {
					callee.flagNullTested()
				}
			}

			@callees[0].toNullableFragments(fragments, this)
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		if !@reusable && ?@reuseName {
			fragments
				.code(@reuseName, $equals)
				.compile(this)

			@reusable = true
		}
		else {
			fragments.compile(this)
		}
	} # }}}
	type() => @type
	walkNode(fn) { # {{{
		return false unless fn(this)

		if ?@object {
			return false unless @object.walkNode(fn)
		}

		for var argument in @arguments {
			return false unless argument.walkNode(fn)
		}

		return true
	} # }}}
}

class NamedArgument extends Expression {
	private late {
		@name: String
		@value: Expression
	}
	analyse() { # {{{
		@name = @data.name.name

		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target)
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	getDefaultValue() => 'void 0'
	isAwait() => @value.isAwait()
	isExpectingType() => true
	override isFitting() => @value.isFitting()
	isUsingVariable(name) => @value.isUsingVariable(name)
	name() => @name
	type() => @value.type()
	toFragments(fragments, mode) { # {{{
		@value.toFragments(fragments, mode)
	} # }}}
}

class PlaceholderArgument extends Expression {
	private late {
		@type: Type
	}
	analyse() { # {{{
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = PlaceholderType.new(@scope)

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Rest {
				@type.flagRest()

				break
			}
		}

		if ?@data.index {
			@type.index(@data.index.value)
		}
	} # }}}
	translate() { # {{{
	} # }}}
	type() => @type
	toFragments(fragments, mode) { # {{{
	} # }}}
}

class PlaceholderType extends Type {
	private {
		@index: Number?		= null
		@rest: Boolean		= false
	}
	override clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		throw NotSupportedException.new()
	} # }}}
	flagRest(): Void { # {{{
		@rest = true
	} # }}}
	index(): valueof @index
	index(@index): Void
	isPlaceholder() => true
	isRest(): valueof @rest
	isSpread(): valueof @rest
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) => true
	parameter(index) => AnyType.NullableUnexplicit
	override toFragments(fragments, node) { # {{{
		throw NotSupportedException.new()
	} # }}}
	override toQuote() { # {{{
		if @rest {
			return '...'
		}
		else if ?@index {
			return `^\(@index)`
		}
		else {
			return '^'
		}
	} # }}}
	override toVariations(variations) { # {{{
		throw NotSupportedException.new()
	} # }}}
}

class PositionalArgument extends Expression {
	private late {
		@value: Expression
	}
	analyse() { # {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target)
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	isAwait() => @value.isAwait()
	type() => @value.type()
	toFragments(fragments, mode) { # {{{
		@value.toFragments(fragments, mode)
	} # }}}
}

class Substitude {
	isInitializingInstanceVariable(name) => false
	isSkippable() => false
	toFragments(fragments, mode)
}

include {
	'./callee.ks'
	'./callee/constructor.ks'
	'./callee/default.ks'
	'./callee/bitmask-create.ks'
	'./callee/enum-create.ks'
	'./callee/enum-method.ks'
	'./callee/inverted-precise-method.ks'
	'./callee/lenient-function.ks'
	'./callee/lenient-method.ks'
	'./callee/lenient-this.ks'
	'./callee/precise-function.ks'
	'./callee/precise-method.ks'
	'./callee/precise-this.ks'
	'./callee/sealed.ks'
	'./callee/sealed-function.ks'
	'./callee/sealed-method.ks'
	'./callee/sealed-precise-method.ks'
	'./callee/substitute.ks'
}
