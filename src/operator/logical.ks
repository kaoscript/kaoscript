class PolyadicOperatorAnd extends PolyadicOperatorExpression {
	private late {
		@expectingEnum: Boolean		= true
		@native: Boolean		= false
		@operand: OperandType	= OperandType::Any
		@type: Type
	}
	override prepare(target) { # {{{
		var mut nullable = false
		var mut boolean = true
		var mut number = true
		var mut native = true

		if target? {
			boolean = target.canBeBoolean()
			number = target.canBeNumber()

			if !target.canBeEnum() {
				@expectingEnum = false
			}
		}

		for var operand in @operands {
			operand.prepare(target)

			var type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if type.isBoolean() {
				number = false
			}
			else if type.isNumber() {
				if type.isNullable() {
					nullable = true
					native = false
				}

				boolean = false
			}
			else if type.isNull() {
				nullable = true
			}
			else if type.canBeBoolean() {
				if type.isNullable() {
					nullable = true
				}

				if !type.canBeNumber() {
					number = false
				}
				else if !boolean {
					native = false
				}
			}
			else if type.canBeNumber() {
				if type.isNullable() {
					nullable = true
				}

				boolean = false
				native = false
			}
			else {
				TypeException.throwInvalidOperand(operand, @operator(), this)
			}

			for var data, name of operand.inferWhenTrueTypes({}) {
				@scope.updateInferable(name, data, this)
			}
		}

		if !boolean && !number {
			if target? {
				TypeException.throwUnexpectedExpression(this, target, this)
			}
			else {
				TypeException.throwInvalidOperation(this, @operator(), this)
			}
		}

		if boolean {
			if number {
				@type = new UnionType(@scope, [@scope.reference('Boolean'), @scope.reference('Number')])

				if nullable {
					@type = @type.setNullable(true)
				}
			}
			else {
				@type = @scope.reference('Boolean')
				@operand = OperandType::Boolean
				@native = true
			}
		}
		else if number {
			if target?.isEnum() {
				@type = target
				@operand = OperandType::Enum
			}
			else {
				@type = @scope.reference('Number')
				@operand = OperandType::Number
				@expectingEnum = false
			}

			@native = native

			if nullable {
				@type = @type.setNullable(true)
			}
		}
	} # }}}
	inferTypes(inferables) { # {{{
		return inferables unless @operand == OperandType::Boolean

		var scope = this.statement().scope()

		for var operand, index in @operands {
			for var data, name of operand.inferTypes({}) {
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
						if var variable = scope.getVariable(name) {
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
	inferWhenFalseTypes(inferables) => this.inferTypes(inferables)
	inferWhenTrueTypes(inferables) { # {{{
		return inferables unless @operand == OperandType::Boolean

		for var operand in @operands {
			for var data, name of operand.inferWhenTrueTypes({}) {
				inferables[name] = data
			}
		}

		return inferables
	} # }}}
	isBooleanComputed(junction: Junction) => junction != Junction::AND
	operator() => Operator::And
	symbol() => '&&'
	toFragments(fragments, mode) { # {{{
		if @native {
			if @operand == OperandType::Boolean {
				for var operand, index in @operands {
					if index > 0 {
						fragments
							.code($space)
							.code('&&', @data.operator)
							.code($space)
					}

					fragments.wrapBoolean(operand, Mode::None, Junction::AND)
				}
			}
			else {
				if @expectingEnum {
					fragments.code(@type.name(), '(')
				}

				for var operand, index in @operands {
					if index > 0 {
						fragments
							.code($space)
							.code('&', @data.operator)
							.code($space)
					}

					fragments.wrap(operand)
				}

				if @expectingEnum {
					fragments.code(@type.name(), ')')
				}
			}
		}
		else {
			fragments.code(`\($runtime.operator(this))`)

			if @operand == OperandType::Number {
				fragments.code('.andNum(')
			}
			else {
				fragments.code('.and(')
			}

			for var operand, index in @operands {
				fragments.code($comma) if index > 0

				fragments.compile(operand)
			}

			fragments.code(')')
		}
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		@toFragments(fragments, mode)
	} # }}}
	type(): @type
}

class BinaryOperatorAnd extends PolyadicOperatorAnd {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class PolyadicOperatorOr extends PolyadicOperatorExpression {
	private late {
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
		@operand: OperandType		= OperandType::Any
		@type: Type
	}
	override prepare(target) { # {{{
		var mut nullable = false
		var mut boolean = true
		var mut number = true
		var mut native = true

		if target? {
			boolean = target.canBeBoolean()
			number = target.canBeNumber()

			if !target.canBeEnum() {
				@expectingEnum = false
			}
		}

		var lastIndex = @operands.length - 1
		var originals = {}

		for var operand, index in @operands {
			operand.prepare(target)

			var type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if type.isBoolean() {
				number = false
			}
			else if type.isNumber() {
				if type.isNullable() {
					nullable = true
					native = false
				}

				boolean = false
			}
			else if type.canBeBoolean() {
				if type.isNullable() {
					nullable = true
				}

				if !type.canBeNumber() {
					number = false
				}
				else if !boolean {
					native = false
				}
			}
			else if type.canBeNumber() {
				if type.isNullable() {
					nullable = true
				}

				boolean = false
				native = false
			}
			else {
				TypeException.throwInvalidOperand(operand, @operator(), this)
			}

			if boolean && index < lastIndex {
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

		if !boolean && !number {
			if target? {
				TypeException.throwUnexpectedExpression(this, target, this)
			}
			else {
				TypeException.throwInvalidOperation(this, @operator(), this)
			}
		}

		if boolean {
			if number {
				@type = new UnionType(@scope, [@scope.reference('Boolean'), @scope.reference('Number')])

				if nullable {
					@type = @type.setNullable(true)
				}
			}
			else {
				@type = @scope.reference('Boolean')
				@operand = OperandType::Boolean
				@native = true
			}

			for var data, name of originals {
				@scope.updateInferable(name, data, this)
			}
		}
		else if number {
			if target?.isEnum() {
				@type = target
				@operand = OperandType::Enum
			}
			else {
				@type = @scope.reference('Number')
				@operand = OperandType::Number
				@expectingEnum = false
			}

			@native = native

			if nullable {
				@type = @type.setNullable(true)
			}
		}
	} # }}}
	inferTypes(inferables) { # {{{
		return inferables unless @operand == OperandType::Boolean

		var scope = this.statement().scope()

		for var operand, index in @operands {
			for var data, name of operand.inferTypes({}) {
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
						if var variable = scope.getVariable(name) {
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
		return inferables unless @operand == OperandType::Boolean

		var scope = this.statement().scope()

		for var operand, index in @operands {
			for var data, name of operand.inferWhenFalseTypes({}) {
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
						if var variable = scope.getVariable(name) {
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
		return inferables unless @operand == OperandType::Boolean

		var scope = this.statement().scope()

		var whenTrue = {}

		for var operand, index in @operands {
			for var data, name of operand.inferTypes({}) {
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
					if var variable = scope.getVariable(name) {
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
				for var data, name of operand.inferWhenTrueTypes({}) when data.isVariable && whenTrue[name]? {
					whenTrue[name].push(data.type)
				}
			}
		}

		for var types, name of whenTrue when types.length != 1 {
			if var variable = scope.getVariable(name) {
				inferables[name] = {
					isVariable: true
					type: Type.union(@scope, ...types)
				}
			}
		}

		return inferables
	} # }}}
	isBooleanComputed(junction: Junction) => junction != Junction::OR
	operator() => Operator::Or
	symbol() => '||'
	toFragments(fragments, mode) { # {{{
		if @native {
			if @operand == OperandType::Boolean {
				for var operand, index in @operands {
					if index > 0 {
						fragments
							.code($space)
							.code('||', @data.operator)
							.code($space)
					}

					fragments.wrapBoolean(operand, Mode::None, Junction::OR)
				}
			}
			else {
				if @expectingEnum {
					fragments.code(@type.name(), '(')
				}

				for var operand, index in @operands {
					if index > 0 {
						fragments
							.code($space)
							.code('|', @data.operator)
							.code($space)
					}

					fragments.wrap(operand)
				}

				if @expectingEnum {
					fragments.code(')')
				}
			}
		}
		else {
			fragments.code(`\($runtime.operator(this))`)

			if @operand == OperandType::Boolean {
				fragments.code('.orBool(')
			}
			else if @operand == OperandType::Number {
				fragments.code('.orNum(')
			}
			else {
				fragments.code('.or(')
			}

			for var operand, index in @operands {
				fragments.code($comma) if index > 0

				fragments.compile(operand)
			}

			fragments.code(')')
		}
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		@toFragments(fragments, mode)
	} # }}}
	type(): @type
}

class BinaryOperatorOr extends PolyadicOperatorOr {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class PolyadicOperatorImply extends PolyadicOperatorOr {
	operator() => Operator::Imply
	symbol() => '->'
	toFragments(fragments, mode) { # {{{
		var l = @operands.length - 2
		fragments.code('!('.repeat(l))

		fragments.code('!').wrapBoolean(@operands[0])

		for var operand in @operands from 1 til -1 {
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
	operator() => Operator::Xor
	symbol() => '^^'
	toFragments(fragments, mode) { # {{{
		if @native {
			if @operand == OperandType::Boolean {
				var l = @operands.length - 2

				if l > 0 {
					fragments.code('('.repeat(l))

					fragments.wrapBoolean(@operands[0])

					for var operand in @operands from 1 til -1 {
						fragments.code(' !== ').wrapBoolean(operand).code(')')
					}

					fragments.code(' !== ').wrapBoolean(@operands[@operands.length - 1])
				}
				else {
					fragments
						.wrapBoolean(@operands[0])
						.code($space)
						.code('!==', @data.operator)
						.code($space)
						.wrapBoolean(@operands[1])
				}
			}
			else {
				for var operand, index in @operands {
					if index > 0 {
						fragments
							.code($space)
							.code('^', @data.operator)
							.code($space)
					}

					fragments.wrap(operand)
				}
			}
		}
		else {
			fragments.code(`\($runtime.operator(this))`)

			if @operand == OperandType::Number {
				fragments.code('.xorNum(')
			}
			else {
				fragments.code('.xor(')
			}

			for var operand, index in @operands {
				fragments.code($comma) if index > 0

				fragments.compile(operand)
			}

			fragments.code(')')
		}
	} # }}}
}

class BinaryOperatorXor extends PolyadicOperatorXor {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}
