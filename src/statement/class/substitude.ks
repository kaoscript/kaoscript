class CallThisConstructorSubstitude extends Substitude {
	private {
		@arguments
		@class: NamedType<ClassType>
		@data
		@result
	}
	constructor(@data, @arguments, @class, node) { # {{{
		super()

		var assessment = class.type().getConstructorAssessment(class.name(), null, node)

		match Router.matchArguments(assessment, null, @arguments, [], node) {
			is LenientCallMatchResult | PreciseCallMatchResult with var result {
				@result = result
			}
			else {
				ReferenceException.throwNoMatchingConstructor(class.name(), @arguments, node)
			}
		}
	} # }}}
	isInitializingInstanceVariable(name) { # {{{
		if @result is PreciseCallMatchResult {
			for var { function } in @result.matches {
				return false unless function.isInitializingInstanceVariable(name)
			}
		}
		else {
			for var function in @result.possibilities {
				return false unless function.isInitializingInstanceVariable(name)
			}
		}

		return true
	} # }}}
	isNullable() => false
	toFragments(fragments, mode) { # {{{
		if @result is LenientCallMatchResult {
			fragments.code(`\(@class.path()).prototype.__ks_cons_rt.call(null, this, [`)

			for var argument, index in @arguments {
				fragments.code($comma) if index != 0

				fragments.compile(argument)
			}

			fragments.code(']')
		}
		else {
			if @result.matches.length == 1 {
				var { function, positions } = @result.matches[0]

				fragments.code(`\(@class.path()).prototype.__ks_cons_\(function.index())`).code('.call(this')

				Router.Argument.toFragments(positions, null, @arguments, function, false, true, true, fragments, mode)
			}
			else {
				throw NotImplementedException.new()
			}
		}
	} # }}}
	type() => Type.Void
}

class CallHybridThisConstructorES6Substitude extends CallThisConstructorSubstitude {
	toFragments(fragments, mode) { # {{{
		if @result is LenientCallMatchResult {
			fragments.code(`__ks_cons_rt([`)

			for var argument, index in @arguments {
				fragments.code($comma) if index > 0

				fragments.compile(argument)
			}

			fragments.code(']')
		}
		else {
			if @result.matches.length == 1 {
				var { function, positions } = @result.matches[0]

				fragments.code(`__ks_cons_\(function.index())`).code('(')

				Router.Argument.toFragments(positions, null, @arguments, function, false, false, true, fragments, mode)
			}
			else {
				throw NotImplementedException.new()
			}
		}
	} # }}}
}

class CallSuperConstructorSubstitude extends Substitude {
	private {
		@arguments
		@class: NamedType<ClassType>
		@data
		@result
		@skippable: Boolean				= false
	}
	constructor(@data, @arguments, @class, node) { # {{{
		super()

		var extends = @class.type().extends()
		var assessment = extends.type().getConstructorAssessment(extends.name(), null, node)

		match Router.matchArguments(assessment, null, @arguments, [], node) {
			is LenientCallMatchResult | PreciseCallMatchResult with var result {
				@result = result
				@skippable = !(extends.isAlien() || extends.isHybrid()) && @result.matches?.length == 0
			}
			else {
				if extends.type().isExhaustiveConstructor(node) {
					ReferenceException.throwNoMatchingConstructor(extends.name(), @arguments, node)
				}
			}
		}
	} # }}}
	isInitializingInstanceVariable(name) { # {{{
		if !?@result {
			return false
		}
		else if @result is LenientCallMatchResult {
			for var constructor in @class.type().extends().type().listAccessibleConstructors() {
				if !constructor.isInitializingInstanceVariable(name) {
					return false
				}
			}
		}
		else if @result.matches.length == 0 {
			return false
		}
		else {
			for var {function} in @result.matches {
				if !function.isInitializingInstanceVariable(name) {
					return false
				}
			}
		}

		return true
	} # }}}
	isNullable() => false
	isSkippable() => @skippable
	toFragments(fragments, mode) { # {{{
		if @result is PreciseCallMatchResult && @result.matches.length == 1 {
			var { function, positions } = @result.matches[0]

			fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons_\(function.index())`).code('.call(this')

			Router.Argument.toFragments(positions, null, @arguments, function, false, true, true, fragments, mode)
		}
		else {
			fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons_rt.call(null, this, [`)

			for var argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}

			fragments.code(']')
		}
	} # }}}
	type() => Type.Void
}

class CallHybridSuperConstructorES6Substitude extends CallSuperConstructorSubstitude {
	toFragments(fragments, mode) { # {{{
		fragments.code(`super(`)

		for var argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}
	} # }}}
}

class CallSuperMethodES6Substitude extends Substitude {
	private late {
		@extendsName: String
		@name: String
		@precise: Boolean
		@result: CallMatchResult
	}
	private {
		@arguments
		@class: NamedType<ClassType>
		@data
		@method: ClassMethodDeclaration
	}
	constructor(@data, @arguments, @method, @class) { # {{{
		super()

		var assessment = @class.type().extends().type().getInstantiableAssessment(@method.name(), null, @method)

		match Router.matchArguments(assessment, null, @arguments, [], @method) {
			is LenientCallMatchResult | PreciseCallMatchResult with var result {
				@result = result

				if result is PreciseCallMatchResult && result.matches.length == 1 {
					@name = `__ks_func_\(@method.name())_\(result.matches[0].function.index())`
					@precise = true
				}
				else {
					@name = `__ks_func_\(@method.name())_rt`
				}
			}
			else {
				ReferenceException.throwNoMatchingInstanceMethod(@method.name(), @class.name(), [argument.type() for var argument in @arguments], @method)
			}
		}

		@extendsName = @class.type().extends().name()
	} # }}}
	isNullable() => false
	toFragments(fragments, mode) { # {{{
		if @precise {
			fragments.code(`super.\(@name)(`)

			for var argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@name).call(null, this, \(@extendsName).prototype, [`)

			for var argument, index in @arguments {
				fragments.code($comma) if index > 0

				fragments.compile(argument)
			}

			fragments.code(']')
		}
	} # }}}
	type() { # {{{
		if @result is PreciseCallMatchResult {
			if @result.matches.length == 1 {
				return @result.matches[0].function.getReturnType()
			}
			else {
				return Type.union(@method.scope(), ...[match.function.getReturnType() for var match in @result.matches])
			}
		}
		else {
			return Type.union(@method.scope(), ...[fn.getReturnType() for var fn in @result.possibilities])
		}
	} # }}}
}

class CallSealedSuperMethodSubstitude extends Substitude {
	private {
		@arguments
		@class: NamedType<ClassType>
		@data
		@method: ClassMethodDeclaration
		@name: String
		@result: CallMatchResult
		@sealed: Boolean					= false
	}
	constructor(@data, @arguments, @method, @class) { # {{{
		super()

		var assessment = @class.type().extends().type().getInstantiableAssessment(@method.name(), null, @method)

		match Router.matchArguments(assessment, null, @arguments, [], @method) {
			is LenientCallMatchResult | PreciseCallMatchResult with var result {
				@result = result

				if result is PreciseCallMatchResult && result.matches.length == 1 {
					@name = `__ks_func_\(@method.name())_\(result.matches[0].function.index())`
					@sealed = result.matches[0].function.isSealed()
				}
				else {
					@name = `_im_\(@method.name())`
					@sealed = true
				}
			}
			else {
				throw NotImplementedException.new(@method)
			}
		}
	} # }}}
	isNullable() => false
	toFragments(fragments, mode) { # {{{
		if @sealed {
			fragments.code(`\(@class.type().extends().getSealedPath()).\(@name).call(this`)

			for var argument in @arguments {
				fragments.code($comma).compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@name)(`)

			for var argument, index in @arguments {
				fragments.code($comma) if index != 0

				fragments.compile(argument)
			}
		}
	} # }}}
	type() { # {{{
		if @result is PreciseCallMatchResult {
			if @result.matches.length == 1 {
				return @result.matches[0].function.getReturnType()
			}
			else {
				return Type.union(@method.scope(), ...[match.function.getReturnType() for var match in @result.matches])
			}
		}
		else {
			return Type.union(@method.scope(), ...[fn.getReturnType() for var fn in @result.possibilities])
		}
	} # }}}
}

class MemberSealedSuperMethodSubstitude extends Substitude {
	private late {
		@result: CallMatchResult
	}
	private {
		@arguments
		@class: NamedType<ClassType>
		@extendsType: NamedType<ClassType>
		@name: String
		@sealed: Boolean					= false
	}
	constructor(@name, @arguments, @class, node) { # {{{
		super()

		@extendsType = @class.type().extends()

		if var property ?= @extendsType.type().getInstanceProperty(@name) {
			@sealed = property.isSealed()
		}
	} # }}}
	isNullable() => false
	setCallMatchResult(@result)
	toFragments(fragments, mode) { # {{{
		if @sealed {
			if var index ?= @extendsType.type().getSharedMethodIndex(@name) {
				fragments.code(`\(@extendsType.getSealedPath())._im_\(index)_\(@name)(this`)
			}
			else {
				fragments.code(`\(@extendsType.getSealedPath())._im_\(@name)(this`)
			}

			for var argument in @arguments {
				fragments.code($comma).compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@name)(`)

			for var argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
	} # }}}
	type() { # {{{
		if @result is LenientCallMatchResult {
			throw NotImplementedException.new()
		}
		else if @result.matches.length == 1 {
			return @result.matches[0].function.getReturnType()
		}
		else {
			throw NotImplementedException.new()
		}
	} # }}}
}
