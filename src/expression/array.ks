class ArrayExpression extends Expression {
	private late {
		@canConcat: Boolean			= true
		@flatten: Boolean			= false
		@nullableHelper: Boolean	= false
		@restrictive: Boolean	= false
		@type: Type
		@useHelper: Boolean			= false
		@values: Array				= []
	}
	analyse() { # {{{
		for var data in @data.values {
			var value =
				if data.kind == AstKind.RestrictiveExpression {
					@restrictive = true

					set ArrayRestrictiveMember.new(data, this)
				}
				else {
					set $compile.expression(data, this)
				}

			value.analyse()

			@values.push(value)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		var subtarget = if target.isArray() set target.parameter() else AnyType.NullableUnexplicit

		var mut spread = false

		for var value in @values {
			value.prepare(subtarget)

			spread ||= value.type().isSpread()
		}

		if spread {
			@canConcat = @values.length > 1

			var first = @values[0]
			var mut type = first.type().discardValue().discardSpread()

			@prepareValue(first)

			for var value in @values from 1 {
				if ?type && !type.equals(value.type().discardValue().discardSpread()) {
					type = null
				}

				@prepareValue(value)
			}

			if ?type {
				@type = Type.arrayOf(type, @scope)
			}
			else {
				@type = @scope.reference('Array')
			}
		}
		else {
			@type = ArrayType.new(@scope).flagComplete()

			for var value in @values {
				@type.addProperty(value.type().discardValue())
			}
		}
	} # }}}
	translate() { # {{{
		for var value in @values {
			value.translate()
		}
	} # }}}
	override isAccessibleAliasType(value) => true
	isInverted() { # {{{
		for var value in @values {
			if value.isInverted() {
				return true
			}
		}

		return false
	} # }}}
	isMatchingType(type: Type) { # {{{
		if @values.length == 0 {
			return type.isAny() || type.isArray()
		}
		else {
			return @type.matchContentOf(type)
		}
	} # }}}
	isNotEmpty() => @values.length > 0
	isUsingVariable(name) { # {{{
		for var value in @values {
			if value.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		for var value in @values {
			value.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	prepareValue(value) { # {{{
		if value.isSpread() {
			if value.useHelper() {
				@useHelper = true
				@nullableHelper = value.argument().type().isNullable()
			}
		}
		else {
			@canConcat = false
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @restrictive {
			@toRestrictiveFragments(fragments, mode)
		}
		else if @useHelper {
			if @canConcat {
				fragments.code(`\($runtime.helper(this)).concatArray(\(if @nullableHelper set '1' else '0')`)

				for var value, index in @values {
					fragments
						..code($comma)
						..compile(value.argument())
				}

				fragments.code(')')
			}
			else {
				fragments.code('[')

				for var value, index in @values {
					fragments.code($comma) if index != 0

					value.toArgumentFragments(fragments)
				}

				fragments.code(']')
			}
		}
		else if @flatten {
			CallExpression.toFlattenArgumentsFragments(fragments, @values)
		}
		else {
			fragments.code('[')

			for var value, index in @values {
				fragments
					..code($comma) if index != 0
					..compile(value)
			}

			fragments.code(']')
		}
	} # }}}
	toInvertedFragments(fragments, callback) { # {{{
		for var value in @values {
			if value.isInverted() {
				return value.toInvertedFragments(fragments, callback)
			}
		}
	} # }}}
	toRestrictiveFragments(fragments, mode) { # {{{
		var mut varname = 'a'

		if @isUsingVariable('a') {
			if !@isUsingVariable('l') {
				varname = 'l'
			}
			else if !@isUsingVariable('_') {
				varname = '_'
			}
			else {
				varname = '__ks__'
			}
		}

		fragments.code('(() =>')

		var block = fragments.newBlock()

		var mut line = block.newLine().code(`\($const(this))\(varname) = [`)

		var mut arrayOpened = true
		var mut pushOpened = false
		var mut comma = false
		var mut unknown = false

		for var value, index in @values {
			if value is ArrayRestrictiveMember {
				if arrayOpened {
					line.code(`]`).done()
					arrayOpened = false
				}
				else if pushOpened {
					line.code(`)`).done()
					pushOpened = false
				}

				value.toRestrictiveFragments(block, (expression, writer) => {
					if unknown || expression.type().isSpread() {
						writer.newLine().code(`\(varname).push(`).compile(expression).code(')').done()
					}
					else {
						writer.newLine().code(`\(varname)[\(index)] = `).compile(expression).done()
					}
				})

				unknown = true
			}
			else {
				if arrayOpened || pushOpened {
					if comma {
						line.code($comma)
					}
					else {
						comma = true
					}

					line.compile(value)
				}
				else {
					line = block.newLine().code(`\(varname).push(`).compile(value)
					pushOpened = true
				}

				unknown ||= value.type().isSpread()
			}
		}

		if arrayOpened {
			line.code(`]`).done()
		}
		else if pushOpened {
			line.code(`)`).done()
		}

		block.line(`return \(varname)`).done()

		fragments.code(')()')
	} # }}}
	toQuote() { # {{{
		var mut fragments = '['

		for var value, index in @values {
				if index != 0 {
					fragments += ', '
				}

				fragments += value.toQuote()
			}

		fragments += ']'

		return fragments
	} # }}}
	type() => @type
	validateType(type: ArrayType) { # {{{
		for var value, index in @values {
			if var propertyType ?= type.getProperty(index) {
				value.validateType(propertyType)
			}
		}
	} # }}}
	validateType(type: ReferenceType) { # {{{
		if type.hasParameters() {
			var parameter = type.parameter(0)

			for var value in @values {
				value.validateType(parameter)
			}
		}
	} # }}}
}

class ArrayRestrictiveMember extends Expression {
	private late {
		@condition
		@expression
	}
	analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
			..analyse()

		@expression = $compile.expression(@data.expression, this)
			..analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

		@expression.prepare(target, targetMode)
	} # }}}
	translate() { # {{{
		@condition.translate()
		@expression.translate()
	} # }}}
	toRestrictiveFragments(fragments, setter) { # {{{
		var ctrl = fragments.newControl()

		if @data.operator.kind == RestrictiveOperatorKind.If {
			ctrl
				.code('if(')
				.compileCondition(@condition)
		}
		else {
			ctrl
				.code('if(!')
				.wrapCondition(@condition)
		}

		ctrl.code(')').step()

		setter(@expression, ctrl)

		ctrl.done()
	} # }}}
}

class ArrayRange extends Expression {
	private late {
		@by				= null
		@from
		@to
		@type: Type
	}
	analyse() { # {{{
		@from = $compile.expression(@data.from ?? @data.then, this)
		@from.analyse()

		@to = $compile.expression(@data.to ?? @data.til, this)
		@to.analyse()

		if ?@data.by {
			@by = $compile.expression(@data.by, this)
			@by.analyse()
		}

	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = Type.arrayOf(@scope.reference('Number'), @scope)

		@from.prepare(@scope.reference('Number'))
		@to.prepare(@scope.reference('Number'))
		@by.prepare(@scope.reference('Number')) if ?@by
	} # }}}
	translate() { # {{{
		@from.translate()
		@to.translate()

		if @by != null {
			@by.translate()
		}
	} # }}}
	isUsingVariable(name) => @from.isUsingVariable(name) || @to.isUsingVariable(name) || @by?.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@from.listNonLocalVariables(scope, variables)
		@to.listNonLocalVariables(scope, variables)
		@by?.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		@module().flag('Helper')

		fragments
			.code($runtime.helper(this), '.newArrayRange(')
			.compile(@from)
			.code($comma)
			.compile(@to)

		if @by == null {
			fragments.code(', 1')
		}
		else {
			fragments.code(', ').compile(@by)
		}

		fragments.code($comma, ?@data.from, $comma, ?@data.to, ')')
	} # }}}
	type() => @type
}
