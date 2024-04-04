class DisruptiveExpression extends Expression {
	private late {
		@acquiredReusable: Boolean				= false
		@analysed: Boolean						= false
		@condition
		@declarator
		@disruptedExpression
		@disruption
		@mainExpression
		@newExpression: Boolean					= false
		@prepared: Boolean						= false
		@releasedReusable: Boolean				= false
		@reusable: Boolean						= false
		@reuseName: String?						= null
		@rootExpression: Boolean				= false
		@tested: Boolean						= false
		@translated: Boolean					= false
		@type: Type
		@valueName: String?						= null
	}
	override analyse() { # {{{
		return if @analysed

		@analysed = true

		var mut parent = @parent

		while parent is not Statement {
			if parent is DisruptiveExpression {
				@disruption = parent
			}

			parent = parent.parent()
		}

		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@mainExpression = $compile.expression(@data.mainExpression, this)
		@mainExpression.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		return if @prepared

		@prepared = true

		@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

		@condition.acquireReusable(false)
		@condition.releaseReusable()

		@mainExpression.prepare(AnyType.NullableUnexplicit)

		var mType = @mainExpression.type()

		if !?@reuseName && @mainExpression.isReusingName() {
			@reuseName = @mainExpression.getReuseName()
		}

		@disruptedExpression = $compile.expression(@data.disruptedExpression, this)
		@disruptedExpression.analyse()

		@disruptedExpression.prepare(target, targetMode)

		@type = Type.union(@scope, mType, @disruptedExpression.type())

		if !@newExpression && !?@reuseName && (@disruptedExpression.isNullable() || @mainExpression.isDisrupted()) {
			@reuseName = @scope.acquireTempName()

			@scope.define(@reuseName, false, mType, true, this)

			@mainExpression.setReuseName(@reuseName)

			@rootExpression = true
		}

		if ?@reuseName {
			if @disruptedExpression.isComputed() {
				@disruptedExpression.setReuseName(@reuseName)
			}
			else if @mainExpression.isComposite() {
				@mainExpression.setReuseName(@reuseName)
			}
		}
	} # }}}
	override translate() { # {{{
		return if @translated

		@translated = true

		@condition.translate()
		@mainExpression.translate()
		@disruptedExpression.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		return if @acquiredReusable

		@acquiredReusable = true

		if acquire && !@newExpression && !?@reuseName {
			@reuseName =
				if @parent is CallExpression {
					set @parent.getReuseName()
				}
				else {
					set @scope.acquireTempName()
				}

			@rootExpression = true
		}

		if @mainExpression.isUndisruptivelyNullable() || @mainExpression.isComposite() {
			if ?@reuseName {
				@mainExpression
					..setReuseName(@reuseName)
					..acquireReusable(false)
			}
			else {
				@mainExpression.acquireReusable(true)
			}
		}

		@disruptedExpression.acquireReusable(@disruptedExpression.isUndisruptivelyNullable())
	} # }}}
	flagNewExpression() { # {{{
		@newExpression = true
	} # }}}
	override getASTReference(name) { # {{{
		if name == 'main' {
			return @mainExpression
		}

		return null
	} # }}}
	getReuseName() { # {{{
		if !?@reuseName {
			if ?@disruption {
				@reuseName = @disruption.getReuseName()
			}
			else {
				@reuseName = @scope.acquireTempName()

				@scope.define(@reuseName, false, @mainExpression.type(), true, this)
			}
		}

		return @reuseName
	} # }}}
	getValueName() => @valueName
	isComposite() => !@reusable
	isComputed() => !@reusable
	isDisrupted() => !@tested
	isNullable() => !@tested && @disruptedExpression.isNullable()
	isNullableComputed() => !@tested && @disruptedExpression.isNullableComputed()
	isReusable() => @reusable
	isReusingName() => ?@reuseName
	isUndisruptivelyNullable() => false
	releaseReusable() { # {{{
		return if @releasedReusable

		@releasedReusable = true

		@mainExpression.releaseReusable()
	} # }}}
	override setReuseName(name % @reuseName)
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @newExpression {
			var mut disrupted = @mainExpression.isDisrupted()

			if disrupted {
				if @mainExpression.isUndisruptivelyNullable() {
					fragments
						.wrapNullable(@mainExpression)
						.code(' && (')
						.compileReusable(@mainExpression)
						.code(', true)')
						.code(' ? ')
				}
				else {
					if @mainExpression is DisruptiveExpression {
						var nullable = @mainExpression.isNullable()

						@mainExpression.toDisruptedFragments(fragments)

						if nullable {
							fragments.code(' ? ')
						}
						else {
							fragments.code(' && ')

							disrupted = false
						}
					}
					else {
						if @mainExpression.isComposite() {
							fragments
								.code('(')
								.compileReusable(@mainExpression)
								.code(', true)')
						}
						else {
							@mainExpression.toDisruptedFragments(fragments)
						}

						fragments.code(' && ')

						disrupted = false
					}
				}
			}
			else if @mainExpression.isComposite() {
				if @mainExpression.isNullable() {
					fragments
						.wrapNullable(@mainExpression)
						.code(' && (')
						.compileReusable(@mainExpression)
						.code(', true)')
						.code(' ? ')

					disrupted = true
				}
				else {
					fragments
						.code('(')
						.compileReusable(@mainExpression)
						.code(', true) && ')
				}
			}

			if @data.operator.kind == RestrictiveOperatorKind.If {
				fragments.compileCondition(@condition)
			}
			else {
				fragments.code('!').wrapCondition(@condition)
			}

			fragments
				.code(' ? ')
				.compile(@disruptedExpression)
				.code(' : ')

			if @parent is ExpressionStatement {
				fragments.code('null')
			}
			else {
				fragments.compile(@reuseName ?? @mainExpression)
			}

			if disrupted {
				fragments.code(' : null')
			}
		}
		else {
			if @mainExpression.isComposite() {
				fragments.compileReusable(@mainExpression).code(', ')
			}

			if @data.operator.kind == RestrictiveOperatorKind.If {
				fragments.compileCondition(@condition)
			}
			else {
				fragments.code('!').wrapCondition(@condition)
			}

			fragments
				.code(' ? ')
				.compile(@disruptedExpression)
				.code(' : ')
				.compile(@mainExpression)
		}
	} # }}}
	toDisruptedFragments(fragments) { # {{{
		var disrupted = @mainExpression.isDisrupted()
		var mut nullable = false
		var mut opened = false

		if disrupted {
			if @mainExpression.isUndisruptivelyNullable() {
				fragments
					.wrapNullable(@mainExpression)
					.code(' && (')
					.compileReusable(@mainExpression)
					.code(', true) && ')
			}
			else {
				if @mainExpression.isNullable() && @mainExpression is DisruptiveExpression {
					fragments.code('(')

					@mainExpression.toDisruptedFragments(fragments)

					fragments.code(') && ')
				}
				else if @mainExpression.isComposite() {
					fragments
						.code('(')
						.compileReusable(@mainExpression)
						.code(', true) && ')
				}
				else {
					fragments.code('(')

					@mainExpression.toDisruptedFragments(fragments)

					fragments.code(') && ')
				}
			}
		}
		else if @mainExpression.isComposite() {
			if @mainExpression.isNullable() {
				fragments
					.wrapNullable(@mainExpression)
					.code(' && (')
					.compileReusable(@mainExpression)
					.code(', true)')
					.code(' ? ')

				nullable = true
			}
			else {
				if !opened {
					fragments.code('(')

					opened = true
				}

				fragments.compileReusable(@mainExpression)
			}
		}

		if @rootExpression && !@disruptedExpression.isNullable() {
			fragments
				.code(opened ? ', ' : '(')
				.code(`\(@reuseName) = `)

			if @data.operator.kind == RestrictiveOperatorKind.If {
				fragments.compileCondition(@condition)
			}
			else {
				fragments.code('!').wrapCondition(@condition)
			}

			fragments.code(' ? ')

			if @disruptedExpression.isNullable() {
				@disruptedExpression.toAlternativeFragments(fragments, @toResultFragments)
			}
			else {
				@disruptedExpression.toFragments(fragments, Mode.None)
			}

			fragments
				.code(' : ')
				.compile(@mainExpression)
				.code(', true)')

			@reusable = true
		}
		else {
			fragments.code(opened ? ', ' : '(')

			if @data.operator.kind == RestrictiveOperatorKind.If {
				fragments.compileCondition(@condition)
			}
			else {
				fragments.code('!').wrapCondition(@condition)
			}

			fragments.code(' ? ')

			if @disruptedExpression.isNullable() {
				@disruptedExpression.toAlternativeFragments(fragments, @toResultFragments)
			}
			else {
				@disruptedExpression.toFragments(fragments, Mode.None)
			}

			fragments.code(' : ')

			if @rootExpression {
				if @mainExpression.isReusingName() && @mainExpression.isReusable() && @mainExpression.getReuseName() == @reuseName {
					fragments.code('true')
				}
				else {
					fragments.code(`(\(@reuseName) = `).compile(@mainExpression).code(', true)')
				}

				@reusable = true
			}
			else {
				fragments.code('true')
			}

			fragments.code(')')
		}

		if nullable {
			fragments.code(' : false')
		}

		@tested = true
	} # }}}
	toResultFragments(fragments, consequent, cb) { # {{{
		if consequent {
			fragments.code(`(\(@reuseName) = `)

			cb(fragments)

			fragments.code(', true)')

			@reusable = true
		}
		else {
			fragments.code('false')
		}
	} # }}}
	toNullableFragments(fragments) { # {{{
		@toDisruptedFragments(fragments)
	} # }}}
	toReusableFragments(fragments) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else {
			fragments
				.code(`\(@reuseName) = `)
				.wrap(this)

			@reusable = true
		}
	} # }}}
	type() => @type
}
