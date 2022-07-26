class ThisCallee extends Callee {
	private {
		@expression
		@flatten: Boolean
		@methods: Array<FunctionType>
		@node: CallExpression
		@property: String
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, @expression, @property, @methods, @node) { # {{{
		super(data)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		const types = []
		for const method in methods {
			this.validate(method, node)
			
			types.push(method.getReturnType())
		}
		
		@type = Type.union(@node.scope(), ...types)
	} # }}}
	override hashCode() { # {{{
		return `this`
	} # }}}
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		for const method in @methods {
			if method.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		const name = @node.scope().getVariable('this').getSecureName()

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
					fragments.code(`\(name).\(@property)(`)

					for const argument, index in node._arguments {
						fragments.code($comma) if index != 0

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
			}
		}
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
