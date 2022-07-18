class PolyadicOperatorAnd extends PolyadicOperatorExpression {
	prepare() { # {{{
		for operand in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			unless operand.type().canBeBoolean() {
				TypeException.throwInvalidOperand(operand, Operator::And, this)
			}

			for const data, name of operand.inferWhenTrueTypes({}) {
				@scope.updateInferable(name, data, this)
			}
		}
	} # }}}
	inferTypes(inferables) { # {{{
		const scope = this.statement().scope()

		for const operand, index in @operands {
			for const data, name of operand.inferTypes({}) {
				if inferables[name]? {
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
						if const variable = scope.getVariable(name) {
							const type = variable.getRealType()

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
	inferWhenFalseTypes(inferables) => this.inferTypes(inferables)
	inferWhenTrueTypes(inferables) { # {{{
		for const operand in @operands {
			for const data, name of operand.inferWhenTrueTypes({}) {
				inferables[name] = data
			}
		}

		return inferables
	} # }}}
	toFragments(fragments, mode) { # {{{
		let nf = false

		for const operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('&&', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}

			fragments.wrapBoolean(operand)
		}
	} # }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorAnd extends PolyadicOperatorAnd {
	analyse() { # {{{
		for const data in [@data.left, @data.right] {
			operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class PolyadicOperatorOr extends PolyadicOperatorExpression {
	prepare() { # {{{
		const lastIndex = @operands.length - 1
		const originals = {}

		for const operand, index in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			unless operand.type().canBeBoolean() {
				TypeException.throwInvalidOperand(operand, Operator::And, this)
			}

			if index < lastIndex {
				for const data, name of operand.inferWhenFalseTypes({}) {
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

		for const data, name of originals {
			@scope.updateInferable(name, data, this)
		}
	} # }}}
	inferTypes(inferables) { # {{{
		const scope = this.statement().scope()

		for const operand, index in @operands {
			for const data, name of operand.inferTypes({}) {
				if inferables[name]? {
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
						if const variable = scope.getVariable(name) {
							const type = variable.getRealType()

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
		const scope = this.statement().scope()

		for const operand, index in @operands {
			for const data, name of operand.inferWhenFalseTypes({}) {
				if inferables[name]? {
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
						if const variable = scope.getVariable(name) {
							const type = variable.getRealType()

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
		const scope = this.statement().scope()

		const whenTrue = {}

		for const operand, index in @operands {
			for const data, name of operand.inferTypes({}) {
				if inferables[name]? {
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
					if const variable = scope.getVariable(name) {
						const type = variable.getRealType()

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
				for const data, name of operand.inferWhenTrueTypes({}) when data.isVariable {
					whenTrue[name] = [data.type]
				}
			}
			else {
				for const data, name of operand.inferWhenTrueTypes({}) when data.isVariable && whenTrue[name]? {
					whenTrue[name].push(data.type)
				}
			}
		}

		for const types, name of whenTrue when types.length != 1 {
			if const variable = scope.getVariable(name) {
				inferables[name] = {
					isVariable: true
					type: Type.union(@scope, ...types)
				}
			}
		}

		return inferables
	} # }}}
	toFragments(fragments, mode) { # {{{
		let nf = false

		for const operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('||', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}

			fragments.wrapBoolean(operand)
		}
	} # }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorOr extends PolyadicOperatorOr {
	analyse() { # {{{
		for const data in [@data.left, @data.right] {
			operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class PolyadicOperatorImply extends PolyadicOperatorOr {
	toFragments(fragments, mode) { # {{{
		const l = @operands.length - 2
		fragments.code('!('.repeat(l))

		fragments.code('!').wrapBoolean(@operands[0])

		for const operand in @operands from 1 til -1 {
			fragments.code(' || ').wrapBoolean(operand).code(')')
		}

		fragments.code(' || ').wrapBoolean(@operands[@operands.length - 1])
	} # }}}
}

class BinaryOperatorImply extends BinaryOperatorOr {
	toFragments(fragments, mode) { # {{{
		fragments
			.code('!')
			.wrapBoolean(@operands[0])
			.code(' || ')
			.wrapBoolean(@operands[1])
	} # }}}
}

class PolyadicOperatorXor extends PolyadicOperatorAnd {
	inferWhenFalseTypes(inferables) => this.inferWhenTrueTypes(inferables)
	toFragments(fragments, mode) { # {{{
		const l = @operands.length - 2
		fragments.code('('.repeat(l))

		fragments.wrapBoolean(@operands[0])

		for const operand in @operands from 1 til -1 {
			fragments.code(' !== ').wrapBoolean(operand).code(')')
		}

		fragments.code(' !== ').wrapBoolean(@operands[@operands.length - 1])
	} # }}}
}

class BinaryOperatorXor extends BinaryOperatorAnd {
	inferWhenFalseTypes(inferables) => this.inferWhenTrueTypes(inferables)
	toFragments(fragments, mode) { # {{{
		fragments
			.wrapBoolean(@operands[0])
			.code($space)
			.code('!==', @data.operator)
			.code($space)
			.wrapBoolean(@operands[1])
	} # }}}
}
