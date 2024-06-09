class LenientThisCallee extends LenientCallee {
	private {
		@expression
		@flatten: Boolean
		@generics: AltType[]
		@instance: Boolean
		@methods: Array<FunctionType>
		@node: CallExpression
		@property: String
		@scope: ScopeKind
		@sealed: Boolean					= false
	}
	constructor(@data, @expression, @property, @generics = [], @methods, @node) { # {{{
		super(data)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind
		@instance = methods[0].isInstance()

		for var method in methods {
			if method.isSealed() {
				@sealed = true

				break
			}
		}

		@buildType(methods, node)
	} # }}}
	override hashCode() { # {{{
		return `this`
	} # }}}
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		for var method in @methods {
			if method.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		var root = @expression.getClass().discard()
		var generic = root.isGenericInstanceMethod(@property)
		var arguments = node.arguments()

		if @flatten {
			if @sealed {
				var path = @expression.getClass().getAuxiliaryPath()

				if @instance {
					fragments.code(`\(path)._im_\(@property)`)
				}
				else {
					fragments.code(`\(path)._sm_\(@property)`)
				}

				fragments.code('.apply(null')

				CallExpression.toFlattenArgumentsFragments(fragments.code($comma), arguments, 'this')
			}
			else {
				if @scope == ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				else {
					var name = @node.scope().getVariable('this').getSecureName()

					fragments.code(`\(name).\(@property).apply(\(name)`)
				}

				CallExpression.toFlattenArgumentsFragments(fragments.code($comma), arguments)
			}
		}
		else {
			if @sealed {
				var path = @expression.getClass().getAuxiliaryPath()

				if @instance {
					fragments.code(`\(path)._im_\(@property)`)
				}
				else {
					fragments.code(`\(path)._sm_\(@property)`)
				}
			}
			else {
				var name = @node.scope().getVariable('this').getSecureName()

				fragments.code(`\(name).\(@property)`)
			}

			if @scope == ScopeKind.Argument {
				throw NotImplementedException.new(node)
			}
			else {
				fragments.code('(')

				if @sealed && @instance {
					fragments.code('this')

					for var argument, index in arguments {
						fragments.code($comma)

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
				else {
					if generic {
						fragments.code(`{`)

						for var { name, type }, index in @generics {
							fragments
								..code(`, `) if index > 0
								..code(`\(name): `)

							type.toAwareTestFunctionFragments('value', false, false, false, false, null, null, fragments, node)
						}

						fragments
							.code(`}`)
							.code(`, `) if ?#arguments
					}

					for var argument, index in arguments {
						fragments.code($comma) if index != 0

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
}
