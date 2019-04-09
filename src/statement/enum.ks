class EnumDeclaration extends Statement {
	private {
		_composites: Array			= []
		_enum: EnumType
		_name: String
		_new: Boolean				= true
		_values: Array				= []
		_type: NamedType<EnumType>
		_variable: Variable
	}
	analyse() { // {{{
		@name = @data.name.name

		if @variable ?= @scope.getVariable(@name) {
			@new = false
		}
		else {
			const type = Type.fromAST(@data.type, this)

			if type.isString() {
				@enum = new EnumType(@scope, EnumTypeKind::String)
			}
			else if @data.attributes? {
				let nf = true
				for attr in @data.attributes while nf {
					if attr.kind == NodeKind::AttributeDeclaration && attr.declaration.kind == NodeKind::Identifier && attr.declaration.name == 'flags' {
						nf = false

						@enum = new EnumType(@scope, EnumTypeKind::Flags)
					}
				}

				if nf {
					@enum = new EnumType(@scope)
				}
			}
			else {
				@enum = new EnumType(@scope)
			}

			@type = new NamedType(@name, @enum)

			@variable = @scope.define(@name, true, @type, this)
		}
	} // }}}
	prepare() { // {{{
		if !@new {
			@type = @variable.type()
			@enum = @type.type()
		}

		switch @enum.kind() {
			EnumTypeKind::Flags => {
				for data in @data.members {
					if data.value? {
						if data.value.kind == NodeKind::BinaryExpression && data.value.operator.kind == BinaryOperatorKind::BitwiseOr {
							@composites.push({
								name: data.name.name
								components: [data.value.left, data.value.right]
							})

							@enum.addElement(data.name.name)
						}
						else if data.value.kind == NodeKind::PolyadicExpression && data.value.operator.kind == BinaryOperatorKind::BitwiseOr {
							@composites.push({
								name: data.name.name
								components: data.value.operands
							})

							@enum.addElement(data.name.name)
						}
						else {
							if data.value.kind == NodeKind::NumericExpression {
								@enum.index(data.value.value)
							}
							else {
								throw new NotSupportedException(this)
							}

							@values.push({
								name: data.name.name
								value: @enum.index() <= 0 ? 0 : 1 << (@enum.index() - 1)
							})

							@enum.addElement(data.name.name)
						}
					}
					else {
						@values.push({
							name: data.name.name
							value: @enum.step().index() <= 0 ? 0 : 1 << (@enum.index() - 1)
						})

						@enum.addElement(data.name.name)
					}
				}
			}
			EnumTypeKind::String => {
				let value
				for data in @data.members {
					if data.value? {
						if data.value.kind == NodeKind::Literal {
							value = $quote(data.value.value)
						}
						else {
							throw new NotSupportedException(this)
						}
					}
					else {
						value = $quote(data.name.name.toLowerCase())
					}

					@values.push({
						name: data.name.name
						value: value
					})

					@enum.addElement(data.name.name)
				}
			}
			EnumTypeKind::Number => {
				for data in @data.members {
					if data.value? {
						if data.value.kind == NodeKind::NumericExpression {
							@enum.index(data.value.value)
						}
						else {
							throw new NotSupportedException(this)
						}
					}
					else {
						@enum.step()
					}

					@values.push({
						name: data.name.name
						value: @enum.index()
					})

					@enum.addElement(data.name.name)
				}
			}
		}
	} // }}}
	translate()
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	name() => @name
	toStatementFragments(fragments, mode) { // {{{
		if @new {
			const line = fragments.newLine().code($runtime.scope(this), @name, $equals)
			const object = line.newObject()

			for member in @values {
				object.line(member.name, ': ', member.value)
			}

			object.done()
			line.done()
		}
		else {
			for member in @values {
				fragments.line(@name, '.', member.name, ' = ', member.value)
			}
		}

		if @composites.length > 0 {
			let line

			for member in @composites {
				line = fragments
					.newLine()
					.code(@name, '.', member.name, ' = ')

				for value, i in member.components {
					line.code(' | ') if i > 0

					line.code(@name, '.', value.name)
				}

				line.done()
			}
		}
	} // }}}
	type() => @type
}