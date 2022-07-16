class Substitude {
	isSkippable() => false
}

class CallThisConstructorSubstitude extends Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_result
	}
	constructor(@data, @arguments, @class, node) { // {{{
		super()

		const assessement = class.type().getConstructorAssessment(class.name(), node)

		if const result = Router.matchArguments2(assessement, @arguments, node) {
			@result = result
		}
		else {
			ReferenceException.throwNoMatchingConstructor(class.name(), @arguments, node)
		}
	} // }}}
	isInitializingInstanceVariable(name) { // {{{
		if @result is not LenientCallMatchResult {
			for const {function} in @result.matches {
				if !function.isInitializingInstanceVariable(name) {
					return false
				}
			}
		}

		return true
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		if @result is LenientCallMatchResult {
			fragments.code(`\(@class.path()).prototype.__ks_cons_rt.call(null, this, [`)

			for argument, index in @arguments {
				fragments.code($comma) if index != 0

				fragments.compile(argument)
			}

			fragments.code(']')
		}
		else {
			if @result.matches.length == 1 {
				const { function, arguments } = @result.matches[0]

				fragments.code(`\(@class.path()).prototype.__ks_cons_\(function.index())`).code('.call(this')

				Router.toArgumentsFragments(arguments, @arguments, function, true, fragments, mode)
			}
			else {
				throw new NotImplementedException()
			}
		}
	} // }}}
	type() => Type.Void
}

class CallHybridThisConstructorES6Substitude extends CallThisConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		if @result is LenientCallMatchResult {
			fragments.code(`__ks_cons_rt([`)

			for argument, index in @arguments {
				fragments.code($comma) if index > 0

				fragments.compile(argument)
			}

			fragments.code(']')
		}
		else {
			if @result.matches.length == 1 {
				const { function, arguments } = @result.matches[0]

				fragments.code(`__ks_cons_\(function.index())`).code('(')

				Router.toArgumentsFragments(arguments, @arguments, function, false, fragments, mode)
			}
			else {
				throw new NotImplementedException()
			}
		}
	} // }}}
}

class CallSuperConstructorSubstitude extends Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_result
		_skippable: Boolean				= false
	}
	constructor(@data, @arguments, @class, node) { // {{{
		super()

		const extends = @class.type().extends()
		const assessment = extends.type().getConstructorAssessment(extends.name(), node)

		if const result = Router.matchArguments2(assessment, @arguments, node) {
			@result = result
			@skippable = !(extends.isAlien() || extends.isHybrid()) && @result.matches?.length == 0
		}
		else if extends.type().isExhaustiveConstructor(node) {
			ReferenceException.throwNoMatchingConstructor(extends.name(), @arguments, node)
		}
	} // }}}
	isInitializingInstanceVariable(name) { // {{{
		if !?@result {
			return false
		}
		else if @result is LenientCallMatchResult {
			for const constructor in @class.type().extends().type().listAccessibleConstructors() {
				if !constructor.isInitializingInstanceVariable(name) {
					return false
				}
			}
		}
		else if @result.matches.length == 0 {
			return false
		}
		else {
			for const {function} in @result.matches {
				if !function.isInitializingInstanceVariable(name) {
					return false
				}
			}
		}

		return true
	} // }}}
	isNullable() => false
	isSkippable() => @skippable
	toFragments(fragments, mode) { // {{{
		if !?@result || @result is LenientCallMatchResult {
			fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons_rt.call(null, this, [`)

			for argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}

			fragments.code(']')
		}
		else {
			if @result.matches.length == 1 {
				const { function, arguments } = @result.matches[0]

				fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons_\(function.index())`).code('.call(this')

				for const argument, index in arguments {
					fragments.code($comma)

					if !?argument {
						fragments.code('void 0')
					}
					else if argument is Number {
						@arguments[argument].toArgumentFragments(fragments, mode)
					}
					else {
						for const arg, i in argument {
							fragments.code($comma)

							@arguments[arg].toArgumentFragments(fragments, mode)
						}
					}
				}
			}
			else {
				throw new NotImplementedException()
			}
		}
	} // }}}
	type() => Type.Void
}

class CallHybridSuperConstructorES6Substitude extends CallSuperConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		fragments.code(`super(`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}
	} // }}}
}

class CallSuperMethodES6Substitude extends Substitude {
	private lateinit {
		_extendsName: String
		_name: String
		_precise: Boolean
		_result: CallMatchResult
	}
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_method: ClassMethodDeclaration
	}
	constructor(@data, @arguments, @method, @class) { // {{{
		super()

		const assessment = @class.type().extends().type().getInstantiableAssessment(@method.name(), @method)

		const result = Router.matchArguments2(assessment, @arguments, @method)

		if ?result {
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
			ReferenceException.throwNoMatchingClassMethod(@method.name(), @class.name(), [argument.type() for const argument in @arguments], @method)
		}

		@extendsName = @class.type().extends().name()
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		if @precise {
			fragments.code(`super.\(@name)(`)

			for const argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@name).call(null, this, \(@extendsName).prototype, [`)

			for const argument, index in @arguments {
				fragments.code($comma) if index > 0

				fragments.compile(argument)
			}

			fragments.code(']')
		}
	} // }}}
	type() { // {{{
		if @result is PreciseCallMatchResult {
			if @result.matches.length == 1 {
				return @result.matches[0].function.getReturnType()
			}
			else {
				return Type.union(@method.scope(), ...[match.function.getReturnType() for const match in @result.matches])
			}
		}
		else {
			return Type.union(@method.scope(), ...[fn.getReturnType() for const fn in @result.possibilities])
		}
	} // }}}
}

class CallSealedSuperMethodSubstitude extends Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_method: ClassMethodDeclaration
		_name: String
		_result: CallMatchResult
		_sealed: Boolean					= false
	}
	constructor(@data, @arguments, @method, @class) { // {{{
		super()

		const assessment = @class.type().extends().type().getInstantiableAssessment(@method.name(), @method)

		const result = Router.matchArguments2(assessment, @arguments, @method)

		if ?result {
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
			throw new NotImplementedException(@method)
		}
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		if @sealed {
			fragments.code(`\(@class.type().extends().getSealedPath()).\(@name).call(this`)

			for const argument in @arguments {
				fragments.code($comma).compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@name)(`)

			for const argument, index in @arguments {
				fragments.code($comma) if index != 0

				fragments.compile(argument)
			}
		}
	} // }}}
	type() { // {{{
		if @result is PreciseCallMatchResult {
			if @result.matches.length == 1 {
				return @result.matches[0].function.getReturnType()
			}
			else {
				return Type.union(@method.scope(), ...[match.function.getReturnType() for const match in @result.matches])
			}
		}
		else {
			return Type.union(@method.scope(), ...[fn.getReturnType() for const fn in @result.possibilities])
		}
	} // }}}
}

class MemberSealedSuperMethodSubstitude extends Substitude {
	private lateinit {
		_result: CallMatchResult
	}
	private {
		_arguments
		_class: NamedType<ClassType>
		_extendsType: NamedType<ClassType>
		_property: String
		_sealed: Boolean					= false
	}
	constructor(@property, @arguments, @class, node) { // {{{
		super()

		@extendsType = @class.type().extends()

		if const property = @extendsType.type().getInstanceProperty(@property) {
			@sealed = property.isSealed()
		}
	} // }}}
	isNullable() => false
	setCallMatchResult(@result)
	toFragments(fragments, mode) { // {{{
		if @sealed {
			if const index = @extendsType.type().getSharedMethodIndex(@property) {
				fragments.code(`\(@extendsType.getSealedPath())._im_\(index)_\(@property)(this`)
			}
			else {
				fragments.code(`\(@extendsType.getSealedPath())._im_\(@property)(this`)
			}

			for const argument in @arguments {
				fragments.code($comma).compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@property)(`)

			for const argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
	} // }}}
	type() { // {{{
		if @result is LenientCallMatchResult {
			throw new NotImplementedException()
		}
		else if @result.matches.length == 1 {
			return @result.matches[0].function.getReturnType()
		}
		else {
			throw new NotImplementedException()
		}
	} // }}}
}
