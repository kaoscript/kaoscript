enum EnumKind {
	Flags
	Number
	String
}

class EnumDeclaration extends Statement {
	private {
		_dependentValues	= []
		_kind				= EnumKind::Number
		_name
		_new
		_values				= []
		_variable
	}
	analyse() { // {{{
		@variable = $variable.define(this, @scope, @data.name, true, VariableKind::Enum, @data.type)
		
		@new = @variable.new
		
		if @variable.type == 'String' {
			@kind = EnumKind::String
		}
		else if @data.attributes? {
			let nf = true
			for attr in @data.attributes while nf {
				if attr.kind == NodeKind::AttributeDeclaration && attr.declaration.kind == NodeKind::Identifier && attr.declaration.name == 'flags' {
					nf = false
					
					@kind = EnumKind::Flags
					
					if @new {
						@variable.counter = -2
					}
				}
			}
		}
		
		@name = $compile.expression(@data.name, this)
		@name.analyse()
		
		switch @kind {
			EnumKind::Flags => {
				for data in @data.members {
					if data.value? {
						if data.value.kind == NodeKind::PolyadicExpression && data.value.operator.kind == BinaryOperatorKind::BitwiseOr {
							@dependentValues.push({
								name: data.name.name
								operands: data.value.operands
							})
						}
						else {
							@variable.counter = $toInt(data.value, @variable.counter + 1)
							
							@values.push({
								name: data.name.name
								value: @variable.counter < 0 ? 0 : 1 << @variable.counter
							})
						}
					}
					else {
						++@variable.counter
						
						@values.push({
							name: data.name.name
							value: @variable.counter < 0 ? 0 : 1 << @variable.counter
						})
					}
				}
			}
			EnumKind::String => {
				for data in @data.members {
					@values.push({
						name: data.name.name
						value: $quote(data.name.name.toLowerCase())
					})
				}
			}
			EnumKind::Number => {
				let value
				for data in @data.members {
					if data.value? {
						@variable.counter = $toInt(data.value, @variable.counter + 1)
					}
					else {
						++@variable.counter
					}
					
					@values.push({
						name: data.name.name
						value: @variable.counter
					})
				}
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		if @new {
			let line = fragments.newLine().code($variable.scope(this), @variable.name.name, $equals)
			let object = line.newObject()
			
			for member in @values {
				object.line(member.name, ': ', member.value)
			}
			
			object.done()
			line.done()
		}
		else {
			for member in @values {
				fragments
					.newLine()
					.compile(@name)
					.code('.', member.name, ' = ', member.value)
					.done()
			}
		}
		
		if @dependentValues.length > 0 {
			let line
			
			for member in @dependentValues {
				line = fragments
					.newLine()
					.compile(@name)
					.code('.', member.name, ' = ')
				
				for value, i in member.operands {
					line.code(' | ') if i > 0
					
					line.compile(@name).code('.', value.name)
				}
				
				line.done()
			}
		}
	} // }}}
}