class EnumDeclaration extends Statement {
	private {
		_composites: Array				= []
		_name: String
		_new: Boolean					= true
		_values: Array				= []
		_type: EnumType
	}
	analyse() { // {{{
		@name = @data.name.name
		
		if variable ?= @scope.getVariable(@name) {
			@type = variable.type()
			@new = false
		}
		else {
			const domain = new ScopeDomain(@scope)
			const type = Type.fromAST(@data.type, this)
			
			if type.isString() {
				@type = new EnumType(@name, EnumKind::String, domain)
			}
			else if @data.attributes? {
				let nf = true
				for attr in @data.attributes while nf {
					if attr.kind == NodeKind::AttributeDeclaration && attr.declaration.kind == NodeKind::Identifier && attr.declaration.name == 'flags' {
						nf = false
						
						@type = new EnumType(@name, EnumKind::Flags, domain)
					}
				}
				
				if nf {
					@type = new EnumType(@name, domain)
				}
			}
			else {
				@type = new EnumType(@name, domain)
			}
			
			@scope.define(@name, true, @type, this)
		}
	} // }}}
	prepare() { // {{{
		switch @type.kind() {
			EnumKind::Flags => {
				for data in @data.members {
					if data.value? {
						if data.value.kind == NodeKind::PolyadicExpression && data.value.operator.kind == BinaryOperatorKind::BitwiseOr {
							@composites.push({
								name: data.name.name
								components: data.value.operands
							})
							
							@type.addElement(data.name.name)
						}
						else {
							if data.value.kind == NodeKind::NumericExpression {
								@type.index(data.value.value)
							}
							else {
								throw new NotSupportedException(this)
							}
							
							@values.push({
								name: data.name.name
								value: @type.index() <= 0 ? 0 : 1 << (@type.index() - 1)
							})
							
							@type.addElement(data.name.name)
						}
					}
					else {
						@values.push({
							name: data.name.name
							value: @type.step().index() <= 0 ? 0 : 1 << (@type.index() - 1)
						})
						
						@type.addElement(data.name.name)
					}
				}
			}
			EnumKind::String => {
				for data in @data.members {
					@values.push({
						name: data.name.name
						value: $quote(data.name.name.toLowerCase())
					})
					
					@type.addElement(data.name.name)
				}
			}
			EnumKind::Number => {
				let value
				for data in @data.members {
					if data.value? {
						if data.value.kind == NodeKind::NumericExpression {
							@type.index(data.value.value)
						}
						else {
							throw new NotSupportedException(this)
						}
					}
					else {
						@type.step()
					}
					
					@values.push({
						name: data.name.name
						value: @type.index()
					})
					
					@type.addElement(data.name.name)
				}
			}
		}
	} // }}}
	translate()
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
}