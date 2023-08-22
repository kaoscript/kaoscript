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
