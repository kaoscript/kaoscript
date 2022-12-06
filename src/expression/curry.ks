class CurryExpression extends CallExpression {
	override prepare(target, targetMode) { # {{{
		for var argument in @arguments {
			argument.prepare(AnyType.NullableUnexplicit)

			if argument.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(argument, this)
			}
		}

		for var argument in @arguments until @flatten {
			if argument is UnaryOperatorSpread && !argument.argument().type().isArray() {
				@flatten = true
			}
		}

		if ?@object {
			@property = @data.callee.property.name

			@object.prepare(AnyType.NullableUnexplicit)

			if @object.type().isClassInstance() && @data.scope.kind != ScopeKind::This {
				SyntaxException.throwOnlyThisScope(this)
			}

			@addCallee(new DefaultCallee(@data, @object, null, this))
		}
		else {
			if @data.callee.kind == NodeKind::ThisExpression && @data.scope.kind != ScopeKind::This {
				SyntaxException.throwOnlyThisScope(this)
			}

			@addCallee(new DefaultCallee(@data, null, null, this))
		}
	} # }}}
	toCallFragments(fragments, mode) { # {{{
		if @callees.length == 1 {
			@callees[0].toCurryFragments(fragments, mode, this)
		}
		else if @callees.length == 2 {
			@module().flag('Type')

			@callees[0].toPositiveTestFragments(fragments, this)

			fragments.code(' ? ')

			@callees[0].toCurryFragments(fragments, mode, this)

			fragments.code(') : ')

			@callees[1].toCurryFragments(fragments, mode, this)
		}
		else {
			throw new NotImplementedException(this)
		}
	} # }}}
	type() => @scope.reference('Function')
}
