const $function = {
	arity(parameter) { // {{{
		for i from 0 til parameter.modifiers.length {
			if parameter.modifiers[i].kind == ModifierKind::Rest {
				return parameter.modifiers[i].arity
			}
		}
		
		return null
	} // }}}
	isArgumentsRequired(node) { // {{{
		if node._data.kind == NodeKind::ArrayComprehension {
			return false
		}
		
		let signature = node._signature
		
		let optional = false
		for parameter, i in signature.parameters {
			if optional {
				if parameter.min > 0 {
					return true
				}
			}
			else if parameter.max == Infinity || parameter.min == 0 {
				optional = true
			}
		}
		
		return false
	} // }}}
	parameters(node, fragments, fn) { // {{{
		if node._options.parse.parameters == 'es5' {
			return $function.parametersES5(node, fragments, fn)
		}
		else if node._options.parse.parameters == 'es6' {
			return $function.parametersES6(node, fragments, fn)
		}
		else {
			return $function.parametersKS(node, fragments, fn)
		}
	} // }}}
	parametersES5(node, fragments, fn) { // {{{
		let data = node._data
		let signature = node._signature
		
		for parameter, i in node._parameters {
			if signature.parameters[i].rest {
				SyntaxException.throwNoRestParameter(node)
			}
			else if parameter._defaultValue != null {
				SyntaxException.throwNoDefaultParameter(node)
			}
			else if parameter._nullable {
				SyntaxException.throwNoNullParameter(node)
			}
			else if parameter._anonymous {
				SyntaxException.throwNotNamedParameter(node)
			}
			
			fragments.code($comma) if i
			
			parameter.toParameterFragments(fragments)
		}
		
		return fn(fragments)
	} // }}}
	parametersES6(node, fragments, fn) { // {{{
		let data = node._data
		let signature = node._signature
		let rest = false
		
		for parameter, i in node._parameters {
			if parameter._anonymous {
				SyntaxException.throwNotNamedParameter(node)
			}
			
			fragments.code($comma) if i
			
			if signature.parameters[i].rest {
				parameter.toParameterFragments(fragments)
				
				rest = true
			}
			else if rest {
				SyntaxException.throwAfterRestParameter()
			}
			else {
				parameter.toParameterFragments(fragments)
			}
			
			if parameter._defaultValue != null {
				fragments.code(' = ').compile(parameter._defaultValue)
			}
		}
		
		return fn(fragments)
	} // }}}
	parametersKS(node, fragments, fn) { // {{{
		let data = node._data
		let signature = node._signature
		
		let parameter, ctrl
		let maxb = 0
		let rb = 0
		let db = 0
		let rr = 0
		let maxa = 0
		let ra = 0
		let fr = false
		
		let rest = -1
		for parameter, i in signature.parameters {
			if rest != -1 {
				if parameter.min != 0 {
					ra += parameter.min
				}
				
				maxa += parameter.max
				
				if parameter.rest {
					fr = true
				}
			}
			else if parameter.max == Infinity {
				rest = i
				rr = parameter.min
			}
			else {
				if parameter.min == 0 {
					++db
				}
				else {
					rb += parameter.min
				}
				
				maxb += parameter.max
				
				if parameter.rest {
					fr = true
				}
			}
		}
		
		let l = rest != -1 ? rest : node._parameters.length
		let context
		
		if (rest != -1 && !fr && (db == 0 || db + 1 == rest)) || (rest == -1 && ((!signature.async && signature.max == l && (db == 0 || db == l)) || (signature.async && signature.max == l + 1 && (db == 0 || db == l + 1)))) { // {{{
			for parameter, i in node._parameters while i < l {
				fragments.code($comma) if i > 0
				
				parameter.toParameterFragments(fragments)
			}
			
			if ra == 0 && rest != -1 && (signature.parameters[rest].type == 'Any' || maxa == 0) && node._options.format.parameters == 'es6' {
				parameter = node._parameters[rest]
				
				fragments.code($comma) if rest > 0
				
				parameter.toParameterFragments(fragments)
			}
			else if signature.async && ra == 0 {
				fragments.code($comma) if l > 0
				
				fragments.code('__ks_cb')
			}
			
			fragments = fn(fragments)
			
			if rb + ra > 0 {
				fragments
					.newControl()
					.code(`if(arguments.length < \(signature.min))`)
					.step()
					.line(`throw new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min))")`)
					.done()
			}
			
			for parameter, i in node._parameters while i < l {
				parameter.toValidationFragments(fragments)
			}
			
			if rest != -1 {
				parameter = node._parameters[rest]
				
				if ra > 0 {
					if parameter._anonymous {
						fragments.line(`\($variable.scope(node)) __ks_i = arguments.length > \(maxb + ra) ? arguments.length - \(ra) : \(maxb)`)
					}
					else {
						fragments.line($variable.scope(node), '__ks_i')
						
						if parameter._signature.type == 'Any' {
							fragments
								.newLine()
								.code($variable.scope(node))
								.compile(parameter)
								.code(` = arguments.length > \(maxb + ra) ? Array.prototype.slice.call(arguments, \(maxb), __ks_i = arguments.length - \(ra)) : (__ks_i = \(maxb), [])`)
								.done()
						}
						else {
							fragments
								.newLine()
								.code($variable.scope(node))
								.compile(parameter)
								.code(' = []')
								.done()
						}
					}
				}
				else if parameter._signature.type != 'Any' && maxa > 0 {
					if maxb > 0 {
						throw new NotImplementedException(node)
					}
					else {
						fragments.line($variable.scope(node), '__ks_i = -1')
					}
				
					if parameter._anonymous {
						ctrl = fragments
							.newControl()
							.code('while(')
						
						$type.check(node, ctrl, 'arguments[++__ks_i]', parameter._type)
						
						ctrl
							.code(')')
							.step()
							.done()
					}
					else {
						fragments
							.newLine()
							.code($variable.scope(node))
							.compile(parameter)
							.code(' = []')
							.done()
						
						ctrl = fragments
							.newControl()
							.code('while(')
						
						$type.check(node, ctrl, 'arguments[++__ks_i]', parameter._type)
						
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
						.code($variable.scope(node))
						.compile(parameter)
						.code($equals, `Array.prototype.slice.call(arguments, \(maxb), arguments.length)`)
						.done()
				}
				
				if parameter._hasDefaultValue {
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
					
					ctrl
						.newLine()
						.code(`throw new SyntaxError("wrong number of rest values (" + `)
						.compile(parameter)
						.code(`.length + " for at least \(arity.min))")`)
						.done()
					
					ctrl.done()
				}
			}
			
			if signature.async && ra == 0 {
				node.module().flag('Type')
				
				fragments
					.newControl()
					.code('if(!', $runtime.type(node), '.isFunction(__ks_cb))')
					.step()
					.line(`throw new TypeError("'callback' must be a function")`)
					.done()
			}
		} // }}}
		else { // {{{
			fragments = fn(fragments)
			
			if rb + ra > 0 {
				fragments
					.newControl()
					.code(`if(arguments.length < \(signature.min))`)
					.step()
					.line(`throw new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min))")`)
					.done()
			}
				
			fragments.line($variable.scope(node), '__ks_i = -1')
			
			context = {
				required: rb
				optional: signature.min
				temp: false
				length: data.parameters.length
			}
			
			for i from 0 til l {
				node._parameters[i].toBeforeRestFragments(fragments, context, i)
			}
			
			if rest != -1 { // {{{
				parameter = node._parameters[rest]
				
				if ra > 0 {
					if parameter._anonymous {
						if l + 1 < data.parameters.length {
							fragments
								.newControl()
								.code(`if(arguments.length > __ks_i + \(ra + 1))`)
								.step()
								.line(`__ks_i = arguments.length - \(ra + 1)`)
								.done()
						}
					}
					else {
						fragments
							.newLine()
							.code($variable.scope(node))
							.compile(parameter)
							.code(` = arguments.length > __ks_i + \(ra + 1) ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - \(ra)) : []`)
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
							.code($variable.scope(node))
							.compile(parameter)
							.code(' = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : []')
							.done()
						
						if signature.parameters[rest].type != 'Any' && l + 1 < data.parameters.length {
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
		
		if ra || maxa { // {{{
			if ra != maxa && signature.parameters[rest].type != 'Any' {
				if ra {
					fragments.line($variable.scope(node), '__ks_m = __ks_i + ', ra)
				}
				else {
					fragments.line($variable.scope(node), '__ks_m = __ks_i')
				}
			}
			
			context = {
				any: signature.parameters[rest].type == 'Any'
				increment: false
				temp: context? ? context.temp : false
				length: data.parameters.length
			}
			
			for i from rest + 1 til data.parameters.length {
				node._parameters[i].toAfterRestFragments(fragments, context, i)
			}
		} // }}}
		
		return fragments
	} // }}}
	signature(data, node) { // {{{
		let signature = {
			min: 0,
			max: 0,
			parameters: []
		}
		
		if data.modifiers {
			for modifier in data.modifiers {
				if modifier.kind == ModifierKind::Async {
					signature.async = true
				}
			}
		}
		
		let scope = node.scope()
		for parameter in data.parameters {
			signature.parameters.push(parameter = $function.signatureParameter(parameter, scope))
			
			if parameter.max == Infinity {
				if signature.max == Infinity {
					SyntaxException.throwTooMuchRestParameter(node)
				}
				else {
					signature.max = Infinity
				}
			}
			else {
				signature.max += parameter.max
			}
			
			signature.min += parameter.min
		}
		
		if signature.async {
			signature.parameters.push({
				type: 'Function',
				min: 1,
				max: 1
			})
			
			++signature.min
			++signature.max
		}
		
		return signature
	} // }}}
	signatureParameter(parameter, scope) { // {{{
		let signature = {
			type: $signature.type(parameter.type, scope),
			min: parameter.defaultValue? ? 0 : 1,
			max: 1
		}
		
		if parameter.modifiers {
			for modifier in parameter.modifiers {
				if modifier.kind == ModifierKind::Rest {
					signature.rest = true
					
					if modifier.arity {
						signature.min = modifier.arity.min
						signature.max = modifier.arity.max
					}
					else {
						signature.min = 0
						signature.max = Infinity
					}
				}
			}
		}
		
		return signature
	} // }}}
	surround(node) { // {{{
		let parent = node._parent
		while parent? && !(parent is MethodDeclaration || parent is ImplementClassMethodDeclaration) {
			parent = parent.parent()
		}
		
		if parent?._instance {
			if node._options.format.functions == 'es5' || $function.isArgumentsRequired(node) {
				if $function.useThisVariable(node._data.body, node) {
					return {
						beforeParameters: 'Helper.vcurry(function('
						afterParameters: ')'
						footer: ', this)'
					}
				}
				else {
					return {
						beforeParameters: 'function('
						afterParameters: ')'
						footer: ''
					}
				}
			}
			else {
				return {
					beforeParameters: '('
					afterParameters: ') =>'
					footer: ''
				}
			}
		}
		else {
			return {
				beforeParameters: 'function('
				afterParameters: ')'
				footer: ''
			}
		}
	} // }}}
	useThisVariable(data, node) { // {{{
		switch data.kind {
			NodeKind::ArrayExpression => {
				for value in data.values {
					if $function.useThisVariable(value, node) {
						return true
					}
				}
			}
			NodeKind::BinaryExpression => {
				if $function.useThisVariable(data.left, node) || $function.useThisVariable(data.right, node) {
					return true
				}
			}
			NodeKind::Block => {
				for statement in data.statements {
					if $function.useThisVariable(statement, node) {
						return true
					}
				}
			}
			NodeKind::CallExpression => {
				if $function.useThisVariable(data.callee, node) {
					return true
				}
				
				for arg in data.arguments {
					if $function.useThisVariable(arg, node) {
						return true
					}
				}
			}
			NodeKind::CreateExpression => {
				if $function.useThisVariable(data.class, node) {
					return true
				}
				
				for arg in data.arguments {
					if $function.useThisVariable(arg, node) {
						return true
					}
				}
			}
			NodeKind::EnumExpression => return false
			NodeKind::Identifier => return data.name == 'this'
			NodeKind::IfStatement => {
				if $function.useThisVariable(data.condition, node) || $function.useThisVariable(data.whenTrue, node) {
					return true
				}
				
				if data.whenFalse? && data.$function.useThisVariable(data.whenFalse, node) {
					return true
				}
			}
			NodeKind::Literal => return false
			NodeKind::MemberExpression => return $function.useThisVariable(data.object, node)
			NodeKind::NumericExpression => return false
			NodeKind::ObjectExpression => {
				for property in data.properties {
					if $function.useThisVariable(property.value, node) {
						return true
					}
				}
			}
			NodeKind::ReturnStatement => return $function.useThisVariable(data.value, node)
			NodeKind::UnaryExpression => return $function.useThisVariable(data.argument, node)
			=> {
				throw new NotSupportedException(`Unknow kind \(data.kind)`, node)
			}
		}
		
		return false
	} // }}}
}

class FunctionDeclaration extends Statement {
	private {
		_await: Boolean		= false
		_parameters
		_signature
		_statements
		_variable
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		$variable.define(this, @scope, {
			kind: NodeKind::Identifier,
			name: 'this'
		}, VariableKind::Variable)
		
		@variable = $variable.define(this, this.greatScope(), @data.name, VariableKind::Function, @data.type)
		
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Async {
				@variable.async = true
			}
		}
		
		@parameters = [new Parameter(parameter, this) for parameter in @data.parameters]
		
		@statements = [$compile.statement(statement, this) for statement in $body(@data.body)]
		
		let variable
		for error in @data.throws {
			if variable !?= $variable.fromAST(error, this) {
				ReferenceException.throwNotDefined(error.name, this)
			}
			else if variable.kind != VariableKind::Class {
				TypeException.throwNotClass(error.name, this)
			}
			
			@variable.throws.push(error.name)
		}
	} // }}}
	fuse() { // {{{
		this.compile(@parameters)
		
		this.compile(@statements)
		
		for statement in @statements while !@await {
			@await = statement.isAwait()
		}
		
		@signature = new Signature(this)
	} // }}}
	isConsumedError(name, variable): Boolean { // {{{
		if @variable.throws.length > 0 {
			for x in @variable.throws {
				return true if $error.isConsumed(x, name, variable, @scope)
			}
		}
		
		return false
	} // }}}
	isMethod() => false
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('function ' + this._data.name.name + '(')
		
		$function.parameters(this, ctrl, func(node) {
			return node.code(')').step()
		})
		
		if @await {
			let stack = []
			
			let f = ctrl
			let m = Mode::None
			
			let item
			for statement in this._statements {
				if item ?= statement.toFragments(f, m) {
					f = item.fragments
					m = item.mode
					
					stack.push(item)
				}
			}
			
			for item in stack {
				item.done(item.fragments)
			}
		}
		else {
			for statement in this._statements {
				ctrl.compile(statement, Mode::None)
			}
		}
		
		ctrl.done()
	} // }}}
}

class Parameter extends AbstractNode {
	private {
		_anonymous: Boolean
		_defaultValue						= null
		_hasDefaultValue: Boolean			= false
		_header: Boolean					= false
		_maybeHeadedDefaultValue: Boolean	= false
		_name: String						= null
		_nullable: Boolean					= false
		_rest: Boolean						= false
		_signature
		_type								= null
		_variable							= null
	}
	analyse() { // {{{
		@anonymous = !?@data.name
		
		if @parent.isMethod() {
			if !@anonymous {
				let nf = true
				let name = @data.name.name
				
				for modifier in @data.modifiers while nf {
					if modifier.kind == ModifierKind::Alias {
						if variable ?= @parent.getInstanceVariable(name) {
							@type = $type.reference(variable.type) if variable.type?
						}
						else if variable ?= @parent.getInstanceVariable('_' + name) {
							@type = $type.reference(variable.type) if variable.type?
						}
						else if variable ?= @parent.getInstanceMethod(name) {
							@type = $type.reference(variable.type) if variable.type?
						}
						else {
							ReferenceException.throwNotDefinedMember(name, this)
						}
						
						nf = false
					}
				}
			}
			
			@type ??= @data.type
		}
		else {
			for modifier in @data.modifiers {
				if modifier.kind == ModifierKind::Alias {
					SyntaxException.throwOutOfClassAlias(this)
				}
			}
			
			@type = @data.type
		}
		
		@nullable = @type?.nullable
		
		if @data.defaultValue? {
			@defaultValue = $compile.expression(@data.defaultValue, @parent)
			@hasDefaultValue = true
			
			if !@nullable && @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				@nullable = true
			}
			
			@maybeHeadedDefaultValue = @options.format.parameters == 'es6' && @nullable
		}
		
		@signature = {
			type: $signature.type(@type, @scope)
			min: @hasDefaultValue ? 0 : 1
			max: 1
		}
		
		let nf = true
		for modifier in @data.modifiers while nf {
			if modifier.kind == ModifierKind::Rest {
				@rest = @signature.rest = true
				
				if modifier.arity {
					@signature.min = modifier.arity.min
					@signature.max = modifier.arity.max
				}
				else {
					@signature.min = 0
					@signature.max = Infinity
				}
				
				nf = true
			}
		}
		
		if @anonymous {
			let name = {
				kind: NodeKind::Identifier
				name: @scope.acquireTempName()
			}
			
			$variable.define(this, @scope, name, VariableKind::Variable)
			
			@variable = $compile.expression(name, @parent)
		}
		else {
			if @rest {
				$variable.define(this, @scope, @data.name, VariableKind::Variable, {
					kind: NodeKind::TypeReference
					typeName: {
						kind: NodeKind::Identifier
						name: 'Array'
					}
				})
			}
			else {
				$variable.define(this, @scope, @data.name, $variable.kind(@type), @type)
			}
			
			@variable = $compile.expression(@data.name, @parent)
		}
		
		@name = @variable._value
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
	fuse() {// {{{
		if @defaultValue != null {
			@defaultValue.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@variable)
	} // }}}
	toParameterFragments(fragments) { // {{{
		fragments.code('...') if @rest
		
		fragments.compile(@variable)
		
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
	toValidationFragments(fragments) { // {{{
		if @anonymous {
			if @signature.type != 'Any' && !@hasDefaultValue {
				let ctrl = fragments
					.newControl()
					.code('if(')
				
				if @nullable {
					ctrl.compile(@variable).code(' !== null && ')
				}
				
				ctrl.code('!')
				
				$type.check(this, ctrl, @scope.getRenamedVariable(@name), @type)
				
				ctrl
					.code(')')
					.step()
					.line(`throw new TypeError("anonymous argument is not of type '\(@signature.type)'")`)
					.done()
			}
		}
		else {
			let ctrl
			
			if @hasDefaultValue {
				if !@header || !@maybeHeadedDefaultValue {
					ctrl = fragments
						.newControl()
						.code('if(').compile(@variable).code(' === void 0')
					
					if !@nullable {
						ctrl.code(' || ').compile(@variable).code(' === null')
					}
					
					ctrl.code(')').step()
					
					ctrl
						.newLine()
						.compile(@variable)
						.code($equals)
						.compile(@defaultValue)
						.done()
				}
			}
			else {
				ctrl = fragments.newControl()
				
				if @nullable {
					ctrl.code('if(').compile(@variable).code(' === void 0').code(')')
						.step()
						.newLine()
						.compile(@variable).code(' = null')
						.done()
				}
				else {
					ctrl
						.code('if(').compile(@variable).code(' === void 0').code(' || ').compile(@variable).code(' === null').code(')')
						.step()
						.line(`throw new TypeError("'\(@name)' is not nullable")`)
				}
			}
			
			if @signature.type != 'Any' {
				if ctrl? {
					ctrl.step().code('else ')
				}
				else {
					ctrl = fragments.newControl()
				}
				
				ctrl.code('if(')
				
				if @nullable {
					ctrl.compile(@variable).code(' !== null && ')
				}
				
				ctrl.code('!')
				
				$type.check(this, ctrl, @scope.getRenamedVariable(@name), @type)
				
				ctrl
					.code(')')
					.step()
					.line(`throw new TypeError("'\(@name)' is not of type \($type.toQuote(@signature.type))")`)
			}
			
			ctrl.done() if ctrl?
		}
	} // }}}
	toAfterRestFragments(fragments, context, index) { // {{{
		if arity ?= this.arity() {
			if @anonymous {
				throw new NotImplementedException(this)
			}
			else {
				if @signature.type == 'Any' {
					fragments
						.newLine()
						.code($variable.scope(this))
						.compile(@variable)
						.code(` = Array.prototype.slice.call(arguments, __ks_i + 1, __ks_i + \(arity.min + 1))`)
						.done()
					
					if index + 1 < context.length {
						fragments
							.newLine()
							.code('__ks_i += ')
							.compile(@variable)
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
						.code($variable.scope(this))
						.compile(@variable)
						.code($equals)
						.compile(@defaultValue)
						.done()
				}
			}
			else {
				if @signature.type == 'Any' {
					if !context.temp {
						fragments.line(`\($variable.scope(this))__ks__`)
						
						context.temp = true
					}
					
					let line = fragments
						.newLine()
						.code($variable.scope(this))
						.compile(@variable)
						.code(` = arguments.length > __ks_m && (__ks__ = arguments[\(context.increment ? '++' : '')__ks_i]) !== void 0`)
					
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
						fragments.line(`\($variable.scope(this))__ks__`)
						
						context.temp = true
					}
					
					let line = fragments
						.newLine()
						.code($variable.scope(this))
						.compile(@variable)
						.code(` = arguments.length > __ks_m && (__ks__ = arguments[__ks_i\(context.increment ? ' + 1' : '')]) !== void 0 && `)
					
					if @nullable {
						line.code('(__ks__ === null || ')
						
						$type.check(this, line, '__ks__', @type)
						
						line.code(')')
					}
					else {
						$type.check(this, line, '__ks__', @type)
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
					.code($variable.scope(this))
					.compile(@variable)
					.code(' = arguments[', context.increment ? '++' : '', '__ks_i]')
					.done()
				
				this.toValidationFragments(fragments)
			}
			
			context.increment = true
		}
	} // }}}
	toBeforeRestFragments(fragments, context, index) { // {{{
		if arity ?= this.arity() {
			context.required -= arity.min
			
			if @anonymous {
				throw new NotImplementedException(this)
			}
			else {
				if @signature.type == 'Any' {
					if context.required > 0 {
						fragments
							.newLine()
							.code($variable.scope(this))
							.compile(@variable)
							.code(` = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - \(context.required), __ks_i + \(arity.max + 1)))`)
							.done()
					}
					else {
						fragments
							.newLine()
							.code($variable.scope(this))
							.compile(@variable)
							.code(` = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + \(arity.max + 1)))`)
							.done()
					}
					
					if index + 1 < context.length {
						fragments
							.newLine()
							.code('__ks_i += ')
							.compile(@variable)
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
				if @signature.type == 'Any' {
					if !context.temp {
						fragments.line(`\($variable.scope(this))__ks__`)
						
						context.temp = true
					}
					
					let line = fragments
						.newLine()
						.code($variable.scope(this))
						.compile(@variable)
						.code(` = arguments.length > \(context.optional) && (__ks__ = arguments[++__ks_i]) !== void 0`)
					
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
						.code($variable.scope(this))
						.compile(@variable)
						.done()
					
					let ctrl = fragments
						.newControl()
						.code(`if(arguments.length > \(context.optional) && (`)
						.compile(@variable)
						.code(' = arguments[++__ks_i]) !== void 0')
					
					if !@nullable {
						ctrl.code(' && ').compile(@variable).code(' !== null')
					}
					
					ctrl.code(')').step()
					
					if @nullable {
						let ctrl2 =	ctrl
							.newControl()
							.code('if(')
							.compile(@variable)
							.code(' !== null && !')
						
						$type.check(this, ctrl2, @scope.getRenamedVariable(@name), @type)
						
						ctrl2
							.code(')')
							.step()
							.line(`throw new TypeError("'\(@name)' is not of type \($type.toQuote(@signature.type))")`)
							.done()
					}
					else {
						let ctrl2 =	ctrl
							.newControl()
							.code('if(!')
						
						$type.check(this, ctrl2, @scope.getRenamedVariable(@name), @type)
						
						ctrl2
							.code(')')
							.step()
							.line(`throw new TypeError("'\(@name)' is not of type \($type.toQuote(@signature.type))")`)
							.done()
					}
					
					ctrl.step().code('else').step()
					
					ctrl
						.newLine()
						.compile(@variable)
						.code($equals)
						.compile(@defaultValue)
						.done()
						
					ctrl.done()
				}
				
				++context.optional
			}
			else {
				if @signature.type == 'Any' {
					if @anonymous {
						fragments.line('++__ks_i')
					}
					else {
						fragments
							.newLine()
							.code($variable.scope(this))
							.compile(@variable)
							.code(' = arguments[++__ks_i]')
							.done()
						
						this.toValidationFragments(fragments)
					}
				}
				else {
					fragments
						.newLine()
						.code($variable.scope(this))
						.compile(@variable)
						.code(' = arguments[++__ks_i]')
						.done()
					
					this.toValidationFragments(fragments)
				}
				
				--context.required
			}
		}
	} // }}}
}

class Signature {
	public {
		async: Boolean	= false
		min: Number		= 0
		max: Number		= 0
		parameters		= []
	}
	constructor(parent) { // {{{
		let signature
		for parameter in parent._parameters {
			@parameters.push(signature = parameter._signature)
			
			if signature.max == Infinity {
				if @max == Infinity {
					SyntaxException.throwTooMuchRestParameter(this)
				}
				else {
					@max = Infinity
				}
			}
			else {
				@max += signature.max
			}
			
			@min += signature.min
		}
		
		for modifier in parent._data.modifiers while !@async {
			if modifier.kind == ModifierKind::Async {
				@async = true
			}
		}
		
		if @async {
			@parameters.push({
				type: 'Function'
				min: 1
				max: 1
			})
			
			++@min
			++@max
		}
	} // }}}
}