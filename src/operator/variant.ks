class AssignmentOperatorVariantCoalescing extends AssignmentOperatorExpression {
	private late {
		@name: String
	}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if type.isVariant() {
			var root = type.discard()
			var variant = root.getVariantType()

			if variant.canBeBoolean() {
				@name = root.getVariantName()
			}
			else {
				TypeException.throwNotBooleanVariant(@left, this)
			}
		}
		else {
			TypeException.throwNotBooleanVariant(@left, this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.compile(@left)
			.code(`.\(@name) ? null : `)
			.compile(@left)
			.code($equals)
			.compile(@right)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl()

		ctrl
			.code('if(!')
			.compile(@left)
			.code(`.\(@name))`)
			.step()
			.newLine()
			.compile(@left)
			.code($equals)
			.compile(@right)
			.done()

		ctrl.done()
	} # }}}
	toQuote() => `\(@left.toQuote()) ?||= \(@right.toQuote())`
}

class AssignmentOperatorVariantYes extends AssignmentOperatorExpression {
	private late {
		@condition: Boolean		= false
		@lateinit: Boolean		= false
		@name: String
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target, targetMode) { # {{{
		SyntaxException.throwNoReturn(this) unless target.isVoid() || target.canBeBoolean() || @parent is ExpressionStatement

		super(AnyType.NullableUnexplicit)

		@right.acquireReusable(true)
		@right.releaseReusable()

		var rightType = @right.type()

		if rightType.isInoperative() {
			TypeException.throwUnexpectedInoperative(rightType, this)
		}

		if rightType.isVariant() {
			var root = rightType.discard()
			var variant = root.getVariantType()

			if variant.canBeBoolean() {
				@name = root.getVariantName()
				@type = rightType.clone()
					..addSubtype('true', @scope.reference('Boolean'), this)
			}
			else {
				TypeException.throwNotBooleanVariant(@right, this)
			}
		}
		else {
			TypeException.throwNotBooleanVariant(@right, this)
		}

		if @left.isVariable() {
			if @condition && @lateinit {
				@statement.initializeLateVariable(@left.name(), @type, true)
			}
			else {
				@left.initializeVariables(@type, this)
			}
		}
	} # }}}
	defineVariables(left) { # {{{
		return if @declaration

		if @condition {
			var names = []

			for var { name } in left.listAssignments([]) {
				if var variable ?= @scope.getVariable(name) {
					if variable.isLateInit() {
						@statement.addInitializableVariable(variable, true, this)
						@lateinit = true
					}
					else if variable.isImmutable() {
						ReferenceException.throwImmutable(name, this)
					}
				}
				else {
					names.push(name)
				}
			}

			if names.length > 0 {
				@statement.defineVariables(left, names, @scope, @leftMost, @leftMost == this)
			}
		}
		else {
			@statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
		}
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left.isVariable()
				type: @type
			}
		}

		return inferables
	} # }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { # {{{
		fragments.wrapReusable(@right).code(`.\(@name) ? `)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(' : null')
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if @right.isReusingName() && !@right.isReusable() {
			fragments.code('(').wrapReusable(@right).code(')')
		}
		else {
			fragments.compile(@right)
		}

		fragments.code(`.\(@name) ? (`)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', true) : false')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) ?|= \(@right.toQuote())`
	} # }}}
	type() => @scope.reference('Boolean')
	override validate(target)
}

class AssignmentOperatorVariantNo extends AssignmentOperatorVariantYes {
	toConditionFragments(fragments, mode, junction) { # {{{
		fragments.wrapReusable(@right).code(`.\(@name) ? (`)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', false) : true')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) !?|= \(@right.toQuote())`
	} # }}}
}

class PolyadicOperatorVariantCoalescing extends PolyadicOperatorExpression {
	private late {
		@names: String[]		= []
		@nullables: Boolean[]	= []
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var types = []
		var last = @operands.length - 1

		for var operand, index in @operands {
			operand.prepare()

			var mut type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if index < last {
				unless type.isVariant() {
					TypeException.throwNotBooleanVariant(operand, this)
				}

				var root = type.discard()
				var variant = root.getVariantType()

				unless variant.canBeBoolean() {
					TypeException.throwNotBooleanVariant(operand, this)
				}

				@names.push(root.getVariantName())
				@nullables.push(type.isNullable())

				operand.acquireReusable(true)
				operand.releaseReusable()

				match type {
					ReferenceType {
						if type.isNullable() {
							type = type.setNullable(false)
						}
						else {
							type = type.clone()
						}

						type.addSubtype('true', @scope.reference('Boolean'), this)
					}
					UnionType {
						var name = root.getVariantName()
						var unionTypes = []

						for var mut unionType in type.types() {
							if var subtypes ?#= unionType.getSubtypes() {
								if var filtereds ?#= [subtype for var subtype in subtypes when variant.getMainName(subtype.name) != 'false'] {
									if unionType.isNullable() {
										unionType = unionType.setNullable(false)
									}
									else {
										unionType = unionType.clone()
									}

									unionType.setSubtypes(filtereds)

									unionTypes.push(unionType)
								}
							}
							else {
								if unionType.isNullable() {
									unionType = unionType.setNullable(false)
								}
								else {
									unionType = unionType.clone()
								}

								unionType.addSubtype('true', @scope.reference('Boolean'), this)

								unionTypes.push(unionType)
							}
						}

						type = Type.union(@scope, ...unionTypes)
					}
					else {
						NotImplementedException.throw(this)
					}
				}

				var mut ne = true

				for var tt in types while ne {
					if tt.equals(type) {
						ne = false
					}
				}

				if ne {
					types.push(type)
				}
			}
			else {
				types.push(type)
			}
		}

		if #types == 1 {
			@type = types[0]
		}
		else {
			@type = Type.union(@scope, ...types)
		}
	} # }}}
	operator() => Operator.VariantCoalescing
	symbol() => '?||'
	toFragments(fragments, mode) { # {{{
		var last = @operands.length - 1

		for var operand, index in @operands to~ -1 {
			if @nullables[index] {
				fragments
					.code(`(\($runtime.type(this)).isValue(`)
					.compileReusable(operand)
					.code(') && ')
					.compile(operand)
					.code(`.\(@names[index])) ? `)
					.compile(operand)
					.code(' : ')
			}
			else {
				fragments
					.compileReusable(operand)
					.code(`.\(@names[index]) ? `)
					.compile(operand)
					.code(' : ')
			}
		}

		fragments.compile(@operands[last])
	} # }}}
	type() => @type
}

class BinaryOperatorVariantCoalescing extends PolyadicOperatorVariantCoalescing {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			var operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class UnaryOperatorVariant extends UnaryOperatorExpression {
	private late {
		@name: String
		@trueType: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		var type = @argument.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		if type.isVariant() {
			var root = type.discard()
			var variant = root.getVariantType()

			if variant.canBeBoolean() {
				@trueType = type.clone()
					..setSubtypes([{ name: 'true', type: @scope.reference('Boolean') }])

				@name = root.getVariantName()
			}
			else {
				TypeException.throwNotBooleanVariant(@argument, this)
			}
		}
		else {
			TypeException.throwNotBooleanVariant(@argument, this)
		}
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		@argument.inferTypes(inferables)

		if @argument.isInferable() {
			inferables[@argument.path()] = {
				isVariable: @argument.isVariable()
				type: @trueType
			}
		}

		return inferables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@argument).code(`.\(@name)`)
	} # }}}
	type() => @scope.reference('Boolean')
}
