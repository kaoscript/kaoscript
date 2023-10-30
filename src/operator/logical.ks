class PolyadicOperatorLogicalAnd extends PolyadicOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var mut callable = false

		for var operand, index in @operands {
			operand.prepare(target, TargetMode.Permissive)

			callable ||= operand.isCallable()

			var type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if type.isBoolean() || type.canBeBoolean() {
				pass
			}
			else {
				TypeException.throwInvalidOperand(operand, this.operator(), this)
			}

			for var data, name of operand.inferWhenTrueTypes({}) {
				@scope.updateInferable(name, data, this)
			}
		}

		if target.isVoid() {
			unless callable {
				SyntaxException.throwDeadCode(this)
			}
		}
		else if !target.canBeBoolean() {
			TypeException.throwUnexpectedExpression(this, target, this)
		}

		@type = @scope.reference('Boolean')
	} # }}}
	inferTypes(inferables) { # {{{
		var scope = @statement().scope()

		for var operand, index in @operands {
			for var data, name of operand.inferTypes({}) {
				if ?inferables[name] {
					if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
						inferables[name] = data
					}
					else {
						inferables[name] = {
							isVariable: data.isVariable
							type: Type.union(@scope, inferables[name].type, data.type)
						}
					}
				}
				else {
					if index != 0 && data.isVariable {
						if var variable ?= scope.getVariable(name) {
							var type = variable.getRealType()

							if data.type.equals(type) || data.type.isMorePreciseThan(type) {
								inferables[name] = data
							}
							else {
								inferables[name] = {
									isVariable: true
									type: Type.union(@scope, type, data.type)
								}
							}
						}
						else {
							inferables[name] = data
						}
					}
					else {
						inferables[name] = data
					}
				}
			}
		}

		return inferables
	} # }}}
	inferWhenFalseTypes(inferables) => @inferTypes(inferables)
	inferWhenTrueTypes(inferables) { # {{{
		for var operand in @operands {
			for var data, name of operand.inferWhenTrueTypes({}) {
				inferables[name] = data
			}
		}

		return inferables
	} # }}}
	isBooleanComputed(junction: Junction) => junction != Junction.AND
	operator() => Operator.LogicalAnd
	symbol() => '&&'
	toFragments(fragments, mode) { # {{{
		for var operand, index in @operands {
			if index > 0 {
				fragments
					.code($space)
					.code('&&', @data.operator)
					.code($space)
			}

			fragments.wrapCondition(operand, Mode.None, Junction.AND)
		}
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		@toFragments(fragments, mode)
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if junction == Junction.OR {
			fragments.code('(')

			@toFragments(fragments, mode)

			fragments.code(')')
		}
		else {
			@toFragments(fragments, mode)
		}
	} # }}}
	type(): valueof @type
}

class PolyadicOperatorLogicalOr extends PolyadicOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var mut callable = false

		var lastIndex = @operands.length - 1
		var originals = {}

		for var operand, index in @operands {
			operand.prepare(target)

			callable ||= operand.isCallable()

			var type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if type.isBoolean() || type.canBeBoolean() {
				pass
			}
			else {
				TypeException.throwInvalidOperand(operand, this.operator(), this)
			}

			if index < lastIndex {
				for var data, name of operand.inferWhenFalseTypes({}) {
					if data.isVariable && !?originals[name] {
						originals[name] = {
							isVariable: true
							type: @scope.getVariable(name).getRealType()
						}
					}

					@scope.updateInferable(name, data, this)
				}
			}
		}

		if target.isVoid() {
			unless callable {
				SyntaxException.throwDeadCode(this)
			}
		}
		else if !target.canBeBoolean() {
			TypeException.throwUnexpectedExpression(this, target, this)
		}

		@type = @scope.reference('Boolean')

		for var data, name of originals {
			@scope.updateInferable(name, data, this)
		}
	} # }}}
	inferTypes(inferables) { # {{{
		var scope = @statement().scope()

		for var operand, index in @operands {
			for var data, name of operand.inferTypes({}) {
				if ?inferables[name] {
					if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
						inferables[name] = data
					}
					else {
						inferables[name] = {
							isVariable: data.isVariable
							type: Type.union(@scope, inferables[name].type, data.type)
						}
					}
				}
				else {
					if index != 0 && data.isVariable {
						if var variable ?= scope.getVariable(name) {
							var type = variable.getRealType()

							if data.type.equals(type) || data.type.isMorePreciseThan(type) {
								inferables[name] = data
							}
							else {
								inferables[name] = {
									isVariable: true
									type: Type.union(@scope, type, data.type)
								}
							}
						}
						else {
							inferables[name] = data
						}
					}
					else {
						inferables[name] = data
					}
				}
			}
		}

		return inferables
	} # }}}
	inferWhenFalseTypes(inferables) { # {{{
		var scope = @statement().scope()

		for var operand, index in @operands {
			for var data, name of operand.inferWhenFalseTypes({}) {
				if ?inferables[name] {
					if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
						inferables[name] = data
					}
					else {
						inferables[name] = {
							isVariable: data.isVariable
							type: Type.union(@scope, inferables[name].type, data.type)
						}
					}
				}
				else {
					if index != 0 && data.isVariable {
						if var variable ?= scope.getVariable(name) {
							var type = variable.getRealType()

							if data.type.equals(type) || data.type.isMorePreciseThan(type) {
								inferables[name] = data
							}
							else {
								inferables[name] = {
									isVariable: true
									type: Type.union(@scope, type, data.type)
								}
							}
						}
						else {
							inferables[name] = data
						}
					}
					else {
						inferables[name] = data
					}
				}
			}
		}

		return inferables
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		var scope = @statement().scope()

		var whenTrue = {}

		for var operand, index in @operands {
			for var data, name of operand.inferTypes({}) {
				if ?inferables[name] {
					if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
						inferables[name] = data
					}
					else {
						inferables[name] = {
							isVariable: data.isVariable
							type: Type.union(@scope, inferables[name].type, data.type)
						}
					}
				}
				else if index != 0 && data.isVariable {
					if var variable ?= scope.getVariable(name) {
						var type = variable.getRealType()

						if data.type.equals(type) || data.type.isMorePreciseThan(type) {
							inferables[name] = data
						}
						else {
							inferables[name] = {
								isVariable: true
								type: Type.union(@scope, type, data.type)
							}
						}
					}
					else {
						inferables[name] = data
					}
				}
				else {
					inferables[name] = data
				}
			}

			if index == 0 {
				for var data, name of operand.inferWhenTrueTypes({}) when data.isVariable {
					whenTrue[name] = [data.type]
				}
			}
			else {
				for var data, name of operand.inferWhenTrueTypes({}) when data.isVariable && ?whenTrue[name] {
					whenTrue[name].push(data.type)
				}
			}
		}

		for var types, name of whenTrue when types.length != 1 {
			if var variable ?= scope.getVariable(name) {
				inferables[name] = {
					isVariable: true
					type: Type.union(@scope, ...types!?)
				}
			}
		}

		return inferables
	} # }}}
	isBooleanComputed(junction: Junction) => junction != Junction.OR
	operator() => Operator.LogicalOr
	symbol() => '||'
	toFragments(fragments, mode) { # {{{
		for var operand, index in @operands {
			if index > 0 {
				fragments
					.code($space)
					.code('||', @data.operator)
					.code($space)
			}

			fragments.wrapCondition(operand, Mode.None, Junction.OR)
		}
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		@toFragments(fragments, mode)
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if junction == Junction.AND {
			fragments.code('(')

			@toFragments(fragments, mode)

			fragments.code(')')
		}
		else {
			@toFragments(fragments, mode)
		}
	} # }}}
	type(): valueof @type
}

class PolyadicOperatorLogicalImply extends PolyadicOperatorLogicalOr {
	operator() => Operator.LogicalImply
	symbol() => '->'
	toFragments(fragments, mode) { # {{{
		var l = @operands.length - 2

		fragments.code('!('.repeat(l))

		fragments.code('!').wrapCondition(@operands[0])

		for var operand in @operands from 1 to~ -1 {
			fragments.code(' || ').wrapCondition(operand).code(')')
		}

		fragments.code(' || ').wrapCondition(@operands[@operands.length - 1])
	} # }}}
}

class PolyadicOperatorLogicalXor extends PolyadicOperatorLogicalAnd {
	inferWhenFalseTypes(inferables) => @inferWhenTrueTypes(inferables)
	operator() => Operator.LogicalXor
	symbol() => '^^'
	toFragments(fragments, mode) { # {{{
		var l = @operands.length - 2

		if l > 0 {
			fragments.code('('.repeat(l))

			fragments.wrapCondition(@operands[0])

			for var operand in @operands from 1 to~ -1 {
				fragments.code(' !== ').wrapCondition(operand).code(')')
			}

			fragments.code(' !== ').wrapCondition(@operands[@operands.length - 1])
		}
		else {
			fragments
				.wrapCondition(@operands[0])
				.code($space)
				.code('!==', @data.operator)
				.code($space)
				.wrapCondition(@operands[1])
		}
	} # }}}
}

abstract class LogicalAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private late {
		@native: Boolean		= true
	}
	abstract {
		operator(): Operator
		runtime(): String
		symbol(): String
		toBooleanFragments(fragments): Boolean
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		var mut nullable = false

		if @type.isBoolean() {
			pass
		}
		else if @type.canBeBoolean() {
			@native = false
		}
		else {
			TypeException.throwInvalidOperation(this, this.operator(), this)
		}

		@type = @scope.reference('Boolean')

		@left.acquireReusable(true)
		@left.releaseReusable()
	} # }}}
	native(): String => @symbol()
	toFragments(fragments, mode) { # {{{
		var mut next = true

		next = @toBooleanFragments(fragments)

		if next && @native {
			next = @toNativeFragments(fragments)
		}

		if next {
			fragments
				.compileReusable(@left)
				.code(' = ')
				.code($runtime.operator(this), `.\(@runtime())Bool(`)
				.compileReusable(@left)
				.code($comma)
				.compile(@right)
				.code(')')
		}
	} # }}}
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($space).code(@native(), @data.operator).code($space).compile(@right)

		return false
	} # }}}
	toQuote() => `\(@left.toQuote()) \(@symbol()) \(@right.toQuote())`
}

class AssignmentOperatorLogicalAnd extends LogicalAssignmentOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator.LogicalAnd
	runtime() => 'and'
	symbol() => '&&='
	toBooleanFragments(fragments) { # {{{
		if @left.type().isBoolean() {
			fragments.compileReusable(@left)
		}
		else {
			fragments.code('(').compileReusable(@left).code(' === true)')
		}

		fragments.code(' && (').compileReusable(@left).code(' = ')

		if @right.type().isBoolean() {
			fragments.compile(@right)
		}
		else {
			fragments.compile(@right).code(' === true')
		}

		fragments.code(')')

		return false
	} # }}}
}

class AssignmentOperatorLogicalOr extends LogicalAssignmentOperatorExpression {
	operator() => Operator.LogicalOr
	runtime() => 'or'
	symbol() => '||='
	toBooleanFragments(fragments) { # {{{
		if @left.type().isBoolean() {
			fragments.code('!').compileReusable(@left)
		}
		else {
			fragments.code('(').compileReusable(@left).code(' !== true)')
		}

		fragments.code(' && (').compileReusable(@left).code(' = ')

		if @right.type().isBoolean() {
			fragments.compile(@right)
		}
		else {
			fragments.compile(@right).code(' === true')
		}

		fragments.code(')')

		return false
	} # }}}
}

class AssignmentOperatorLogicalXor extends LogicalAssignmentOperatorExpression {
	operator() => Operator.LogicalXor
	runtime() => 'xor'
	symbol() => '^^='
	toBooleanFragments(fragments) => true
	toNativeFragments(fragments) { # {{{
		fragments.compileReusable(@left).code(' = ').compileReusable(@left).code(` !== `).compile(@right)

		return false
	} # }}}
}

class UnaryOperatorLogicalNegation extends UnaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if target.isVoid() {
			SyntaxException.throwDeadCode(this)
		}

		if !target.canBeBoolean() {
			TypeException.throwInvalidOperation(this, Operator.LogicalNegation, this)
		}

		var type = @argument.type()

		if type.isBoolean() || type.canBeBoolean() {
			pass
		}
		else {
			TypeException.throwInvalidOperand(@argument, Operator.LogicalNegation, this)
		}

		@type = @scope.reference('Boolean')
	} # }}}
	inferWhenFalseTypes(inferables) => @argument.inferWhenTrueTypes(inferables)
	inferWhenTrueTypes(inferables) => @argument.inferWhenFalseTypes(inferables)
	toFragments(fragments, mode) { # {{{
		fragments.code('!', @data.operator).wrapCondition(@argument)
	} # }}}
	type(): valueof @type
}
