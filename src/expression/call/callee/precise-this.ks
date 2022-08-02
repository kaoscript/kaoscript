class PreciseThisCallee extends Callee {
	private {
		@alien: Boolean
		@arguments: Array<CallMatchArgument>
		@expression
		@flatten: Boolean
		@functions: Array<FunctionType>
		@index: Number
		@instance: Boolean
		@node: CallExpression
		@object
		@property: String
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, @expression, @property, match: CallMatch, @node) { # {{{
		super(data)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		this.validate(match.function, node)

		@functions = [match.function]
		@index = match.function.index()
		@alien = match.function.isAlien()
		@instance = match.function.isInstance()
		@arguments = match.arguments
		@type = match.function.getReturnType()
	} # }}}
	functions() => @functions
	override hashCode() { # {{{
		return `this:\(@property):\(@index):\(@alien):\(@instance):\(@arguments)`
	} # }}}
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		for var function in @functions {
			if function.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
		@functions.push(...that.functions())
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		var name = @node.scope().getVariable('this').getSecureName()

		if @flatten {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					throw new NotImplementedException(node)
				}
			}
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @alien {
						fragments.code(`\(name).\(@property)(`)
					}
					else if @instance {
						fragments.code(`\(name).__ks_func_\(@property)_\(@index)(`)
					}
					else {
						fragments.code(`\(name).__ks_sttc_\(@property)_\(@index)(`)
					}

					Router.toArgumentsFragments(@arguments, node._arguments, @functions[0], false, fragments, mode)
				}
			}
		}
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
