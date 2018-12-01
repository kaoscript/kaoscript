enum ParameterMode {
	ArrowFunction
	Default
	HybridConstructor
	OverloadedFunction
}

enum ParameterWrongDoing {
	BadType
	NotNullable
}

class Parameter extends AbstractNode {
	private {
		_anonymous: Boolean
		_defaultValue						= null
		_hasDefaultValue: Boolean			= false
		_header: Boolean					= false
		_maybeHeadedDefaultValue: Boolean	= false
		_name
		_nullable: Boolean					= false
		_rest: Boolean						= false
		_setterAlias: Boolean				= false
		_thisAlias: Boolean					= false
		_type: Type
		_variable: Variable					= null
	}
	static toFragments(node, fragments, mode, fn, wrongdoer = Parameter.toWrongDoingFragments) { // {{{
		if node._options.parse.parameters == 'es5' {
			return Parameter.toES5Fragments(node, fragments, fn)
		}
		else if node._options.parse.parameters == 'es6' {
			return Parameter.toES6Fragments(node, fragments, fn)
		}
		else {
			return Parameter.toKSFragments(node, fragments, mode, fn, wrongdoer)
		}
	} // }}}
	static toES5Fragments(node, fragments, fn) { // {{{
		const data = node.data()

		for parameter, i in node.parameters() {
			if parameter.isRest() {
				SyntaxException.throwNoRestParameter(node)
			}
			else if parameter.hasDefaultValue() {
				SyntaxException.throwNoDefaultParameter(node)
			}
			else if parameter.isNullable() {
				SyntaxException.throwNoNullParameter(node)
			}
			else if parameter.isAnonymous() {
				SyntaxException.throwNotNamedParameter(node)
			}

			fragments.code($comma) if i

			parameter.toParameterFragments(fragments)
		}

		return fn(fragments)
	} // }}}
	static toES6Fragments(node, fragments, fn) { // {{{
		const data = node.data()
		let rest = false

		for parameter, i in node.parameters() {
			if parameter.isAnonymous() {
				SyntaxException.throwNotNamedParameter(node)
			}

			fragments.code($comma) if i

			if parameter.isRest() {
				parameter.toParameterFragments(fragments)

				rest = true
			}
			else if rest {
				SyntaxException.throwAfterRestParameter()
			}
			else {
				parameter.toParameterFragments(fragments)
			}

			if parameter.hasDefaultValue() {
				fragments.code(' = ').compile(parameter._defaultValue)
			}
		}

		return fn(fragments)
	} // }}}
	static toKSFragments(node, fragments, mode: ParameterMode, fn, wrongdoer) { // {{{
		const data = node.data()
		const parameters = node.parameters()
		const signature = node.type()
		const async = signature.isAsync()

		const name = (mode == ParameterMode::Default || mode == ParameterMode::OverloadedFunction) ? 'arguments' : '__ks_arguments'

		let parameter, ctrl
		let maxb = 0
		let rb = 0
		let db = 0
		let rr = 0
		let maxa = 0
		let ra = 0
		let fr = false
		let rest = -1

		let type
		for parameter, i in parameters {
			type = parameter.type()

			if rest != -1 {
				if type.min() != 0 {
					ra += type.min()
				}

				maxa += type.max()

				if parameter.isRest() {
					fr = true
				}
			}
			else if type.max() == Infinity {
				rest = i
				rr = type.min()
			}
			else {
				if type.min() == 0 {
					++db
				}
				else {
					rb += type.min()
				}

				maxb += type.max()

				if parameter.isRest() {
					fr = true
				}
			}
		}

		if async {
			if rest != -1 {
				++ra
				++maxa
			}
			else {
				++rb
				++maxb
			}
		}

		let l = rest != -1 ? rest : parameters.length
		let context

		//console.log(signature)
		//console.log(rb, ra)
		//console.log(maxb, maxa)

		if	mode == ParameterMode::Default &&
			(
				(rest != -1 && !fr && (db == 0 || db + 1 == rest)) ||
				(rest == -1 && signature.max() == l && (db == 0 || db == l))
			)
		{ // {{{
			for parameter, i in parameters while i < l {
				fragments.code($comma) if i > 0

				parameter.toParameterFragments(fragments)
			}

			if ra == 0 && rest != -1 && (parameters[rest].type().isAny() || maxa == 0) && node._options.format.parameters == 'es6' {
				parameter = parameters[rest]

				fragments.code($comma) if rest > 0

				parameter.toParameterFragments(fragments)
			}
			else if async && ra == 0 {
				fragments.code($comma) if l > 0

				fragments.code('__ks_cb')
			}

			fragments = fn(fragments)

			if rb + ra > 0 {
				if async {
					node.module().flag('Type')

					if rest != -1 {
						fragments.line(`\($runtime.scope(node))__ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null`)
					}

					let ctrl = fragments
						.newControl()
						.code(`if(arguments.length < \(signature.min() + 1))`)
						.step()
						.line(`\($runtime.scope(node))__ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

					if rest == -1 {
						ctrl
							.newControl()
							.code(`if(arguments.length > 0 && Type.isFunction((__ks_cb = arguments[arguments.length - 1])))`)
							.step()
							.line(`return __ks_cb(__ks_error)`)
							.step()
							.code(`else`)
							.step()
							.line(`throw __ks_error`)
							.done()
					}
					else {
						ctrl
							.newControl()
							.code(`if(Type.isFunction(__ks_cb))`)
							.step()
							.line(`return __ks_cb(__ks_error)`)
							.step()
							.code(`else`)
							.step()
							.line(`throw __ks_error`)
							.done()
					}

					ctrl
						.step()
						.code(`else if(!Type.isFunction(__ks_cb))`)
						.step()
						.line(`throw new TypeError("'callback' must be a function")`)

					ctrl.done()
				}
				else {
					fragments
						.newControl()
						.code(`if(arguments.length < \(signature.min()))`)
						.step()
						.line(`throw new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min()))")`)
						.done()
				}
			}

			for parameter, i in parameters while i < l {
				parameter.toValidationFragments(fragments, wrongdoer)
			}

			if rest != -1 {
				parameter = parameters[rest]

				if ra > 0 {
					if parameter._anonymous {
						fragments.line(`\($runtime.scope(node)) __ks_i = arguments.length > \(maxb + ra) ? arguments.length - \(ra) : \(maxb)`)
					}
					else {
						fragments.line($runtime.scope(node), '__ks_i')

						if parameter.type().isAny() {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = arguments.length > \(maxb + ra) ? Array.prototype.slice.call(arguments, \(maxb), __ks_i = arguments.length - \(ra)) : (__ks_i = \(maxb), [])`)
								.done()
						}
						else {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(' = []')
								.done()
						}
					}
				}
				else if maxa > 0 && !parameter.type().isAny() {
					if maxb > 0 {
						throw new NotImplementedException(node)
					}
					else {
						fragments.line($runtime.scope(node), '__ks_i = -1')
					}

					if parameter._anonymous {
						ctrl = fragments
							.newControl()
							.code('while(')

						parameter.type().toTestFragments(ctrl, new Literal(false, node, node.scope(), 'arguments[++__ks_i]'))

						ctrl
							.code(')')
							.step()
							.done()
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(node))
							.compile(parameter)
							.code(' = []')
							.done()

						ctrl = fragments
							.newControl()
							.code('while(')

						parameter.type().toTestFragments(ctrl, new Literal(false, node, node.scope(), 'arguments[++__ks_i]'))

						ctrl
							.code(')')
							.step()

						ctrl
							.newLine()
							.compile(parameter)
							.code('.push(arguments[__ks_i])')
							.done()

						ctrl.done()
					}
				}
				else if node._options.format.parameters == 'es5' {
					fragments
						.newLine()
						.code($runtime.scope(node))
						.compile(parameter)
						.code($equals, `Array.prototype.slice.call(arguments, \(maxb), arguments.length)`)
						.done()
				}

				if parameter.hasDefaultValue() {
					ctrl = fragments
						.newControl()
						.code('if(')
						.compile(parameter)
						.code('.length === 0)')
						.step()

					ctrl
						.newLine()
						.compile(parameter)
						.code($equals)
						.compile(parameter._defaultValue)
						.done()

					ctrl.done()
				}

				if (arity ?= parameter.arity()) && arity.min > 0 {
					ctrl = fragments
						.newControl()
						.code(`if(`)
						.compile(parameter)
						.code(`.length < \(arity.min))`)
						.step()

					if async {
						ctrl
							.newLine()
							.code(`return __ks_cb(new SyntaxError("wrong number of rest values (" + `)
							.compile(parameter)
							.code(`.length + " for at least \(arity.min))"))`)
							.done()
					}
					else {
						ctrl
							.newLine()
							.code(`throw new SyntaxError("wrong number of rest values (" + `)
							.compile(parameter)
							.code(`.length + " for at least \(arity.min))")`)
							.done()
					}

					ctrl.done()
				}
			}
		} // }}}
		else { // {{{
			if mode == ParameterMode::ArrowFunction {
				fragments.code(`...\(name)`)
			}
			else if mode == ParameterMode::HybridConstructor {
				fragments.code(name)
			}

			fragments = fn(fragments)

			if rb + ra > 0 {
				if async {
					node.module().flag('Type')

					fragments.line(`\($runtime.scope(node))__ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null`)

					let ctrl = fragments
						.newControl()
						.code(`if(arguments.length < \(signature.min() + 1))`)
						.step()
						.line(`\($runtime.scope(node))__ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

					ctrl
						.newControl()
						.code(`if(Type.isFunction(__ks_cb))`)
						.step()
						.line(`return __ks_cb(__ks_error)`)
						.step()
						.code(`else`)
						.step()
						.line(`throw __ks_error`)
						.done()

					ctrl
						.step()
						.code(`else if(!Type.isFunction(__ks_cb))`)
						.step()
						.line(`throw new TypeError("'callback' must be a function")`)

					ctrl.done()
				}
				else if mode == ParameterMode::Default || mode == ParameterMode::ArrowFunction {
					fragments
						.newControl()
						.code(`if(\(name).length < \(signature.min()))`)
						.step()
						.line(`throw new SyntaxError("wrong number of arguments (" + \(name).length + " for \(signature.min()))")`)
						.done()
				}
			}

			fragments.line($runtime.scope(node), '__ks_i = -1')

			context = {
				name: name
				required: rb
				optional: signature.min()
				temp: false
				length: data.parameters.length
				async: async
			}

			for i from 0 til l {
				parameters[i].toBeforeRestFragments(fragments, context, i, wrongdoer)
			}

			if rest != -1 { // {{{
				parameter = parameters[rest]

				if ra > 0 {
					if parameter._anonymous {
						if l + 1 < data.parameters.length {
							fragments
								.newControl()
								.code(`if(\(name).length > __ks_i + \(ra + 1))`)
								.step()
								.line(`__ks_i = \(name).length - \(ra + 1)`)
								.done()
						}
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(node))
							.compile(parameter)
							.code(` = \(name).length > __ks_i + \(ra + 1) ? Array.prototype.slice.call(\(name), __ks_i + 1, \(name).length - \(ra)) : []`)
							.done()

						if l + 1 < data.parameters.length {
							fragments
								.newLine()
								.code('__ks_i += ')
								.compile(parameter)
								.code('.length')
								.done()
						}
					}
				}
				else {
					if !parameter._anonymous {
						fragments
							.newLine()
							.code($runtime.scope(node))
							.compile(parameter)
							.code(` = \(name).length > ++__ks_i ? Array.prototype.slice.call(\(name), __ks_i, __ks_i = \(name).length) : []`)
							.done()

						if !parameter.type().isAny() && l + 1 < data.parameters.length {
							fragments
								.newLine()
								.code('__ks_i += ')
								.compile(parameter)
								.code('.length')
								.done()
						}
					}
				}
			} // }}}
		} // }}}

		if ra != 0 || maxa != 0 { // {{{
			parameter = parameters[rest]

			if ra != maxa && !parameter.type().isAny() {
				if ra {
					fragments.line($runtime.scope(node), '__ks_m = __ks_i + ', ra)
				}
				else {
					fragments.line($runtime.scope(node), '__ks_m = __ks_i')
				}
			}

			context = {
				name: name
				any: parameter.type().isAny()
				increment: false
				temp: context? ? context.temp : false
				length: parameters.length
			}

			for i from rest + 1 til parameters.length {
				parameters[i].toAfterRestFragments(fragments, context, i, wrongdoer)
			}
		} // }}}

		return fragments
	} // }}}
	static toWrongDoingFragments(fragments, wrongdoing, data) { // {{{
		switch wrongdoing {
			ParameterWrongDoing::BadType => {
				if data.name? {
					if data.async {
						fragments.line(`return __ks_cb(new TypeError("'\(data.name)' is not of type \(data.type.toQuote())"))`)
					}
					else {
						fragments.line(`throw new TypeError("'\(data.name)' is not of type \(data.type.toQuote())")`)
					}
				}
				else {
					if data.async {
						fragments.line(`return __ks_cb(new TypeError("anonymous argument is not of type \(data.type.toQuote())"))`)
					}
					else {
						fragments.line(`throw new TypeError("anonymous argument is not of type \(data.type.toQuote())")`)
					}
				}
			}
			ParameterWrongDoing::NotNullable => {
				if data.async {
					fragments.line(`return __ks_cb(new TypeError("'\(data.name)' is not nullable"))`)
				}
				else {
					fragments.line(`throw new TypeError("'\(data.name)' is not nullable")`)
				}
			}
		}
	} // }}}
	analyse() { // {{{
		@anonymous = !?@data.name

		if @data.defaultValue? {
			@defaultValue = $compile.expression(@data.defaultValue, @parent)
			@hasDefaultValue = true

			@defaultValue.analyse()
		}

		if @anonymous {
			const name = @scope.acquireTempName()

			@variable = @scope.define(name, false, this)

			@name = $compile.expression($ast.identifier(name), @parent)
		}
		else {
			@variable = @scope.define(@data.name.name, false, this)

			@name = $compile.expression(@data.name, @parent)
		}
	} // }}}
	prepare() { // {{{
		let type: Type = null

		if @parent.isInstanceMethod() {
			if !@anonymous {
				for modifier in @data.modifiers {
					if modifier.kind == ModifierKind::SetterAlias {
						@setterAlias = true
					}
					else if modifier.kind == ModifierKind::ThisAlias {
						@thisAlias = true
					}
				}

				if @thisAlias {
					const alias = new AliasStatement(@data.name.name, @setterAlias, this)

					type = @scope.reference(alias.type())
				}
			}

			type ??= Type.fromAST(@data.type, this)
		}
		else {
			for modifier in @data.modifiers {
				if modifier.kind == ModifierKind::ThisAlias {
					SyntaxException.throwUnexpectedAlias(@data.name.name, this)
				}
			}

			type = Type.fromAST(@data.type, this)
		}

		@nullable = type.isNullable()

		let min: Number = 1
		let max: Number = 1

		let nf = true
		for modifier in @data.modifiers while nf {
			if modifier.kind == ModifierKind::Rest {
				@rest = true

				if modifier.arity {
					min = modifier.arity.min
					max = modifier.arity.max
				}
				else {
					min = 0
					max = Infinity
				}

				nf = true
			}
		}

		if @hasDefaultValue {
			if !@nullable && @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				@nullable = true
			}

			@maybeHeadedDefaultValue = @options.format.parameters == 'es6' && @nullable

			@defaultValue.prepare()

			min = 0
		}

		@type = new ParameterType(@scope, type, min, max)

		@variable.type(@rest ? Type.arrayOf(type, @scope) : type)
	} // }}}
	translate() { // {{{
		if @hasDefaultValue {
			@defaultValue.translate()
		}
	} // }}}
	arity() { // {{{
		if @rest {
			for i from 0 til @data.modifiers.length {
				if @data.modifiers[i].kind == ModifierKind::Rest {
					return @data.modifiers[i].arity
				}
			}
		}

		return null
	} // }}}
	hasDefaultValue() => @hasDefaultValue
	isAnonymous() => @anonymous
	isNullable() => @nullable
	isRest() => @rest
	isSetterAlias() => @setterAlias
	isThisAlias() => @thisAlias
	isUsingVariable(name) => @hasDefaultValue && @defaultValue.isUsingVariable(name)
	returnType() => @type.returnType()
	toFragments(fragments, mode) { // {{{
		fragments.compile(@name)
	} // }}}
	toParameterFragments(fragments) { // {{{
		fragments.code('...') if @rest

		fragments.compile(@name)

		if @maybeHeadedDefaultValue {
			if @hasDefaultValue {
				fragments.code($equals).compile(@defaultValue)
			}
			else {
				fragments.code(' = null')
			}
		}

		@header = true
	} // }}}
	toValidationFragments(fragments, wrongdoer) { // {{{
		const async = @parent.type().isAsync()

		if @anonymous {
			if !@type.type().isAny() && !@hasDefaultValue {
				let ctrl = fragments
					.newControl()
					.code('if(')

				if @nullable {
					ctrl.compile(@name).code(' !== null && ')
				}

				ctrl.code('!')

				@variable.type().toTestFragments(ctrl, this)

				ctrl
					.code(')')
					.step()

				wrongdoer(ctrl, ParameterWrongDoing::BadType, {
					async: async
					type: @type
				})

				ctrl.done()
			}
		}
		else {
			let ctrl = null

			if @hasDefaultValue {
				if !@header || !@maybeHeadedDefaultValue {
					ctrl = fragments
						.newControl()
						.code('if(').compile(@name).code(' === void 0')

					if !@nullable {
						ctrl.code(' || ').compile(@name).code(' === null')
					}

					ctrl.code(')').step()

					ctrl
						.newLine()
						.compile(@name)
						.code($equals)
						.compile(@defaultValue)
						.done()
				}
			}
			else {
				ctrl = fragments.newControl()

				if @nullable {
					ctrl.code('if(').compile(@name).code(' === void 0').code(')')
						.step()
						.newLine()
						.compile(@name).code(' = null')
						.done()
				}
				else {
					ctrl
						.code('if(').compile(@name).code(' === void 0').code(' || ').compile(@name).code(' === null').code(')')
						.step()

					wrongdoer(ctrl, ParameterWrongDoing::NotNullable, {
						async: async
						name: @variable.name()
					})
				}
			}

			if @rest {
				if !@variable.type().parameter().isAny() {
					throw new NotImplementedException(this)
				}
			}
			else if !@variable.type().isAny() {
				if ctrl? {
					ctrl.step().code('else ')
				}
				else {
					ctrl = fragments.newControl()
				}

				ctrl.code('if(')

				if @nullable {
					ctrl.compile(@name).code(' !== null && ')
				}

				ctrl.code('!')

				@variable.type().toTestFragments(ctrl, this)

				ctrl
					.code(')')
					.step()

				wrongdoer(ctrl, ParameterWrongDoing::BadType, {
					async: async
					name: @variable.name()
					type: @type
				})
			}

			if ctrl != null {
				ctrl.done()
			}
		}
	} // }}}
	toAfterRestFragments(fragments, context, index, wrongdoer) { // {{{
		if arity ?= this.arity() {
			if @anonymous {
				throw new NotImplementedException(this)
			}
			else {
				if @type.isAny() {
					fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(@name)
						.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, __ks_i + \(arity.min + 1))`)
						.done()

					if index + 1 < context.length {
						fragments
							.newLine()
							.code('__ks_i += ')
							.compile(@name)
							.code('.length')
							.done()
					}
				}
				else {
					throw new NotImplementedException(this)
				}
			}
		}
		else if @hasDefaultValue {
			if context.any {
				if !@anonymous {
					fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(@name)
						.code($equals)
						.compile(@defaultValue)
						.done()
				}
			}
			else {
				if @type.isAny() {
					if !context.temp {
						fragments.line(`\($runtime.scope(this))__ks__`)

						context.temp = true
					}

					let line = fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(@name)
						.code(` = \(context.name).length > __ks_m && (__ks__ = \(context.name)[\(context.increment ? '++' : '')__ks_i]) !== void 0`)

					if !@nullable {
						line.code(' && __ks__ !== null')
					}

					line
						.code(' ? __ks__ : ')
						.compile(@defaultValue)
						.done()
				}
				else {
					if !context.temp {
						fragments.line(`\($runtime.scope(this))__ks__`)

						context.temp = true
					}

					let line = fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(@name)
						.code(` = \(context.name).length > __ks_m && (__ks__ = \(context.name)[__ks_i\(context.increment ? ' + 1' : '')]) !== void 0 && `)

					if @nullable {
						line.code('(__ks__ === null || ')

						@type.toTestFragments(line, new Literal(false, this, @scope, '__ks__'))

						line.code(')')
					}
					else {
						@type.toTestFragments(line, new Literal(false, this, @scope, '__ks__'))
					}

					line
						.code(context.increment ? ' ? (++__ks_i, __ks__) : ' : ' ? __ks__ : ')
						.compile(@defaultValue)
						.done()
				}

				context.increment = true
			}
		}
		else {
			if @anonymous {
				fragments.line('++__ks_i') if context.increment
			}
			else {
				fragments
					.newLine()
					.code($runtime.scope(this))
					.compile(@name)
					.code(` = \(context.name)[`, context.increment ? '++' : '', '__ks_i]')
					.done()

				this.toValidationFragments(fragments, wrongdoer)
			}

			context.increment = true
		}
	} // }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer) { // {{{
		if arity ?= this.arity() {
			context.required -= arity.min

			if @anonymous {
				throw new NotImplementedException(this)
			}
			else {
				if @type.isAny() {
					if context.required > 0 {
						fragments
							.newLine()
							.code($runtime.scope(this))
							.compile(@name)
							.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length - \(context.required), __ks_i + \(arity.max + 1)))`)
							.done()
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(this))
							.compile(@name)
							.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length, __ks_i + \(arity.max + 1)))`)
							.done()
					}

					if index + 1 < context.length {
						fragments
							.newLine()
							.code('__ks_i += ')
							.compile(@name)
							.code('.length')
							.done()
					}
				}
				else {
					throw new NotImplementedException(this)
				}
			}

			context.optional += arity.max - arity.min
		}
		else {
			if @hasDefaultValue {
				if @type.isAny() {
					if !context.temp {
						fragments.line(`\($runtime.scope(this))__ks__`)

						context.temp = true
					}

					let line = fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(@name)
						.code(` = \(context.name).length > \(context.optional) && (__ks__ = \(context.name)[++__ks_i]) !== void 0`)

					if !@nullable {
						line.code(' && __ks__ !== null')
					}

					line
						.code(' ? __ks__ : ')
						.compile(@defaultValue)
						.done()
				}
				else {
					fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(@name)
						.done()

					let ctrl = fragments
						.newControl()
						.code(`if(\(context.name).length > \(context.optional) && (`)
						.compile(@name)
						.code(` = \(context.name)[++__ks_i]) !== void 0`)

					if !@nullable {
						ctrl.code(' && ').compile(@name).code(' !== null')
					}

					ctrl.code(')').step()

					if @nullable {
						let ctrl2 =	ctrl
							.newControl()
							.code('if(')
							.compile(@name)
							.code(' !== null && !')

						@type.toTestFragments(ctrl2, this)

						ctrl2
							.code(')')
							.step()

						wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
							async: context.async
							name: @variable.name()
							type: @type
						})

						ctrl2.done()
					}
					else {
						let ctrl2 =	ctrl
							.newControl()
							.code('if(!')

						@type.toTestFragments(ctrl2, this)

						ctrl2
							.code(')')
							.step()

						wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
							async: context.async
							name: @variable.name()
							type: @type
						})

						ctrl2.done()
					}

					ctrl.step().code('else').step()

					ctrl
						.newLine()
						.compile(@name)
						.code($equals)
						.compile(@defaultValue)
						.done()

					ctrl.done()
				}

				++context.optional
			}
			else {
				if @type.isAny() {
					if @anonymous {
						fragments.line('++__ks_i')
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(this))
							.compile(@name)
							.code(` = \(context.name)[++__ks_i]`)
							.done()

						this.toValidationFragments(fragments, wrongdoer)
					}
				}
				else {
					fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(@name)
						.code(` = \(context.name)[++__ks_i]`)
						.done()

					this.toValidationFragments(fragments, wrongdoer)
				}

				--context.required
			}
		}
	} // }}}
	type() => @type
}

class AliasStatement extends Statement {
	private {
		_name: String
		_parameter: Parameter
		_setter: Boolean
		_type: Type
		_variableName: String
	}
	constructor(@name, @setter, @parameter) { // {{{
		super({}, parameter.parent())

		parameter.parent().addAliasStatement(this)

		const class = parameter.parent().parent().type().discardAlias()

		if setter {
			if @type !?= class.getPropertySetter(name) {
				ReferenceException.throwNotDefinedMember(name, @parameter)
			}
		}
		else {
			if @type ?= class.getInstanceVariable(name) {
				@variableName = name
			}
			else if @type ?= class.getInstanceVariable(`_\(name)`) {
				@variableName = `_\(name)`
			}
			else if @type ?= class.getPropertySetter(name) {
				@setter = true
			}
			else {
				ReferenceException.throwNotDefinedMember(name, @parameter)
			}
		}
	} // }}}
	analyse()
	prepare()
	name() => @name
	translate()
	toStatementFragments(fragments, mode) { // {{{
		if @setter {
			fragments.newLine().code(`this.\(@name)(`).compile(@parameter).code(')').done()
		}
		else {
			fragments.newLine().code(`this.\(@variableName) = `).compile(@parameter).done()
		}
	} // }}}
	type() => @type
}