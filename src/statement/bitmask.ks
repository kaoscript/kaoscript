class BitmaskDeclaration extends EnumDeclaration {
	private {
		@length: Number		= 16
	}
	initiate() { # {{{
		@name = @data.name.name
		@enum = EnumType.new(@scope, EnumTypeKind.Bit)
		@type = NamedType.new(@name, @enum)
		@variable = @scope.define(@name, true, @type, this)

		if ?@data.type {
			match @data.type.name {
				'u8' {
					@length = 8
				}
				'u32' {
					@length = 32
				}
				'u48' {
					@length = 48
				}
				'u64' {
					@length = 64
				}
				'u128' {
					@length = 128
				}
				'u256' {
					@length = 256
				}
			}
		}

		unless @length < 64 {
			NotSupportedException.throwBitmaskLength(@name, @length, this)
		}

		@enum.length(@length)
	} # }}}
	override createVariable(data) => BitmaskVariableDeclaration.new(data, this)
	length(): valueof @length
	override toMainTypeFragments(fragments) { # {{{
		if @length <= 32 {
			fragments.code('Number')
		}
		else {
			fragments.code('Object')
		}
	} # }}}
}

class BitmaskVariableDeclaration extends EnumVariableDeclaration {
	private late {
		@operands: Array
	}
	constructor(data, parent) { # {{{
		super(data, parent)
	} # }}}
	analyse() { # {{{
		var enum = @parent.type().type()
		var length = enum.length()
		var value = @data.value

		if ?value {
			match value.kind {
				// TODO!
				// NodeKind.BinaryExpression when value.operator.kind == BinaryOperatorKind.Addition | BinaryOperatorKind.BitwiseOr {
				NodeKind.BinaryExpression {
					if value.operator.kind == BinaryOperatorKind.Addition {
						@type = EnumVariableType.new(@name)
						@operands = [value.left, value.right]
					}
				}
				NodeKind.Identifier {
					@type = EnumVariableAliasType.new(@name)

					@type.setAlias(@name, enum)
				}
				NodeKind.NumericExpression {
					@type = EnumVariableType.new(@name)

					if value.radix == 2 {
						@value = `\(value.value)`

						if value.value > 0 {
							var binary = value.value.toString(2)
							var index = binary.length

							if binary.lastIndexOf('1') != 0 {
								NotImplementedException.throw(this)
							}

							if index > length {
								SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
							}

							enum.index(index)
						}
						else {
							enum.index(0)
						}
					}
					else {
						if value.value > length {
							SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
						}

						enum.index(value.value)

						@value = `\(enum.index() <= 0 ? 0 : Math.pow(2, enum.index() - 1))\(length > 32 ? 'n' : '')`
					}

					@type.value(@value)
				}
				NodeKind.PolyadicExpression when value.operator.kind == BinaryOperatorKind.Addition {
					@type = EnumVariableType.new(@name)
					@operands = value.operands
				}
				else {
					SyntaxException.throwInvalidEnumValue(value, this)
				}
			}
		}
		else {
			if enum.step() > length {
				SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
			}

			@type = EnumVariableType.new(@name)
			@value = `\(enum.index() <= 0 ? 0 : Math.pow(2, enum.index() - 1))\(length > 32 ? 'n' : '')`

			@type.value(@value)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if ?#@operands {
			var enum = @parent.type().type()

			if enum.length() > 32 {
				@value = ''

				for var { name }, index in @operands {
					@value += ' | ' if index > 0

					if var variable ?= enum.getVariable(name) {
						@value += variable.value()
					}
					else {
						NotImplementedException.throw(this)
					}
				}
			}
			else {
				var mut value = 0

				for var { name } in @operands {
					if var variable ?= enum.getVariable(name) {
						value +|= variable.value()
					}
					else {
						NotImplementedException.throw(this)
					}
				}

				@value = `\(value)`
			}

			@type.value(@value)
		}
	} # }}}
	toFragments(fragments) { # {{{
		if !@type.isAlias() {
			fragments.line(`\(@name): \(@value)`)
		}
	} # }}}
}
