const $function = {
	arity(parameter) { // {{{
		for i from 0 til parameter.modifiers.length {
			if parameter.modifiers[i].kind == ModifierKind::Rest {
				return parameter.modifiers[i].arity
			}
		}
		
		return null
	} // }}}
	parameters(node, fragments, arrow, fn) { // {{{
		if node._options.parse.parameters == 'es5' {
			return $function.parametersES5(node, fragments, fn)
		}
		else if node._options.parse.parameters == 'es6' {
			return $function.parametersES6(node, fragments, fn)
		}
		else {
			return $function.parametersKS(node, fragments, arrow, fn)
		}
	} // }}}
	parametersES5(node, fragments, fn) { // {{{
		let data = node._data
		let signature = node._signature
		
		for parameter, i in node._parameters {
			if parameter._rest {
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
		let rest = false
		
		for parameter, i in node._parameters {
			if parameter._anonymous {
				SyntaxException.throwNotNamedParameter(node)
			}
			
			fragments.code($comma) if i
			
			if parameter._rest {
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
	parametersKS(node, fragments, arrow, fn) { // {{{
		const data = node._data
		const parameters = node._parameters
		const signature = node._signature
		const name = arrow ? '__ks_arguments' : 'arguments'
		
		let parameter, ctrl
		let maxb = 0
		let rb = 0
		let db = 0
		let rr = 0
		let maxa = 0
		let ra = 0
		let fr = false
		
		let rest = -1
		for parameter, i in parameters {
			if rest != -1 {
				if parameter._signature.min != 0 {
					ra += parameter._signature.min
				}
				
				maxa += parameter._signature.max
				
				if parameter._rest {
					fr = true
				}
			}
			else if parameter._signature.max == Infinity {
				rest = i
				rr = parameter._signature.min
			}
			else {
				if parameter._signature.min == 0 {
					++db
				}
				else {
					rb += parameter._signature.min
				}
				
				maxb += parameter._signature.max
				
				if parameter._signature.rest {
					fr = true
				}
			}
		}
		
		if signature.async {
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
		
		if	!arrow &&
			(
				(rest != -1 && !fr && (db == 0 || db + 1 == rest)) ||
				(
					rest == -1 &&
					(
						(!signature.async && signature.max == l && (db == 0 || db == l)) ||
						(signature.async && signature.max == l + 1 && (db == 0 || db == l + 1))
					)
				)
			)
		{ // {{{
			for parameter, i in parameters while i < l {
				fragments.code($comma) if i > 0
				
				parameter.toParameterFragments(fragments)
			}
			
			if ra == 0 && rest != -1 && (parameters[rest]._signature.type == 'Any' || maxa == 0) && node._options.format.parameters == 'es6' {
				parameter = parameters[rest]
				
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
			
			for parameter, i in parameters while i < l {
				parameter.toValidationFragments(fragments)
			}
			
			if rest != -1 {
				parameter = parameters[rest]
				
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
			if arrow {
				fragments.code('...__ks_arguments')
			}
			
			fragments = fn(fragments)
			
			if rb + ra > 0 {
				fragments
					.newControl()
					.code(`if(\(name).length < \(signature.min))`)
					.step()
					.line(`throw new SyntaxError("wrong number of arguments (" + \(name).length + " for \(signature.min))")`)
					.done()
			}
				
			fragments.line($variable.scope(node), '__ks_i = -1')
			
			context = {
				name: name
				required: rb
				optional: signature.min
				temp: false
				length: data.parameters.length
			}
			
			for i from 0 til l {
				parameters[i].toBeforeRestFragments(fragments, context, i)
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
							.code($variable.scope(node))
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
							.code($variable.scope(node))
							.compile(parameter)
							.code(` = \(name).length > ++__ks_i ? Array.prototype.slice.call(\(name), __ks_i, __ks_i = \(name).length) : []`)
							.done()
						
						if parameter._signature.type != 'Any' && l + 1 < data.parameters.length {
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
			
			if ra != maxa && parameter._signature.type != 'Any' {
				if ra {
					fragments.line($variable.scope(node), '__ks_m = __ks_i + ', ra)
				}
				else {
					fragments.line($variable.scope(node), '__ks_m = __ks_i')
				}
			}
			
			context = {
				name: name
				any: parameter._signature.type == 'Any'
				increment: false
				temp: context? ? context.temp : false
				length: parameters.length
			}
			
			for i from rest + 1 til parameters.length {
				parameters[i].toAfterRestFragments(fragments, context, i)
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
		while parent? && !(parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration) {
			parent = parent.parent()
		}
		
		if parent?._instance {
			if $function.useThisVariable(node._data.body, node) {
				if node._options.format.functions == 'es5' {
					return {
						arrow: false
						beforeParameters: 'Helper.vcurry(function('
						afterParameters: ')'
						footer: ', this)'
					}
				}
				else {
					return {
						arrow: true
						beforeParameters: '('
						afterParameters: ') =>'
						footer: ''
					}
				}
			}
			else {
				return {
					arrow: false
					beforeParameters: 'function('
					afterParameters: ')'
					footer: ''
				}
			}
		}
		else {
			return {
				arrow: false
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
			NodeKind::ThisExpression => return true
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
		}, true, VariableKind::Variable)
		
		@variable = $variable.define(this, this.greatScope(), @data.name, true, VariableKind::Function, @data.type)
		
		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))
			
			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}
		
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Async {
				@variable.async = true
			}
		}
		
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
		
		@statements = []
		for statement in $body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
			
			if statement.isAwait() {
				@await = true
			}
		}
		
		for statement in @statements {
			statement.prepare()
		}
		
		@signature = Signature.fromNode(this)
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		for statement in @statements {
			statement.translate()
		}
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
		
		$function.parameters(this, ctrl, false, func(node) {
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
		_setterAlias: Boolean				= false
		_signature
		_thisAlias: Boolean					= false
		_type								= null
		_variable							= null
	}
	static type(data, node) { // {{{
		if node.isMethod() && data.name? {
			let name = data.name.name
			
			let type
			for modifier in data.modifiers {
				if modifier.kind == ModifierKind::ThisAlias && (type ?= node.getAliasType(name, node)) {
					return type
				}
			}
		}
		
		return data.type
	} // }}}
	analyse() { // {{{
		@anonymous = !?@data.name
		
		if @data.defaultValue? {
			@defaultValue = $compile.expression(@data.defaultValue, @parent)
			@hasDefaultValue = true
			
			@defaultValue.analyse()
		}
		
		for modifier in @data.modifiers while !@rest {
			if modifier.kind == ModifierKind::Rest {
				@rest = true
			}
		}
		
		if @anonymous {
			let name = {
				kind: NodeKind::Identifier
				name: @scope.acquireTempName()
			}
			
			$variable.define(this, @scope, name, false, VariableKind::Variable)
			
			@variable = $compile.expression(name, @parent)
		}
		else {
			if @rest {
				$variable.define(this, @scope, @data.name, false, VariableKind::Variable, {
					kind: NodeKind::TypeReference
					typeName: {
						kind: NodeKind::Identifier
						name: 'Array'
					}
				})
			}
			else {
				$variable.define(this, @scope, @data.name, false, VariableKind::Variable)
			}
			
			@variable = $compile.expression(@data.name, @parent)
		}
		
		@name = @variable._value
	} // }}}
	prepare() { // {{{
		if @parent.isMethod() {
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
					@type = @parent.getAliasType(@data.name.name, this)
				}
			}
			
			@type ??= @data.type
		}
		else {
			for modifier in @data.modifiers {
				if modifier.kind == ModifierKind::ThisAlias {
					SyntaxException.throwOutOfClassAlias(this)
				}
			}
			
			@type = @data.type
		}
		
		@nullable = !!@type?.nullable
		
		if @hasDefaultValue {
			if !@nullable && @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				@nullable = true
			}
			
			@maybeHeadedDefaultValue = @options.format.parameters == 'es6' && @nullable
			
			@defaultValue.prepare()
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
		
		if !@anonymous && !@rest {
			$variable.retype(this, @scope, @data.name, $variable.kind(@type), @type)
		}
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
	isAnonymous() => @anonymous
	isSetterAlias() => @setterAlias
	name() => @name
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
					.line(`throw new TypeError("anonymous argument is not of type \($type.toQuote(@signature.type))")`)
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
						.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, __ks_i + \(arity.min + 1))`)
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
						fragments.line(`\($variable.scope(this))__ks__`)
						
						context.temp = true
					}
					
					let line = fragments
						.newLine()
						.code($variable.scope(this))
						.compile(@variable)
						.code(` = \(context.name).length > __ks_m && (__ks__ = \(context.name)[__ks_i\(context.increment ? ' + 1' : '')]) !== void 0 && `)
					
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
					.code(` = \(context.name)[`, context.increment ? '++' : '', '__ks_i]')
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
							.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length - \(context.required), __ks_i + \(arity.max + 1)))`)
							.done()
					}
					else {
						fragments
							.newLine()
							.code($variable.scope(this))
							.compile(@variable)
							.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length, __ks_i + \(arity.max + 1)))`)
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
						.code($variable.scope(this))
						.compile(@variable)
						.done()
					
					let ctrl = fragments
						.newControl()
						.code(`if(\(context.name).length > \(context.optional) && (`)
						.compile(@variable)
						.code(` = \(context.name)[++__ks_i]) !== void 0`)
					
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
							.code(` = \(context.name)[++__ks_i]`)
							.done()
						
						this.toValidationFragments(fragments)
					}
				}
				else {
					fragments
						.newLine()
						.code($variable.scope(this))
						.compile(@variable)
						.code(` = \(context.name)[++__ks_i]`)
						.done()
					
					this.toValidationFragments(fragments)
				}
				
				--context.required
			}
		}
	} // }}}
	type() => @type
}

class Signature {
	public {
		access: MemberAccess	= MemberAccess::Public
		async: Boolean			= false
		min: Number				= 0
		max: Number				= 0
		parameters				= []
		throws					= []
	}
	static fromAST(data, parent) { // {{{
		let that = new Signature()
		
		let signature, last
		for parameter in data.parameters {
			signature = {
				type: $signature.type(parameter.type, parent.scope())
				min: parameter.defaultValue? ? 0 : 1
				max: 1
			}
			
			let nf = true
			for modifier in parameter.modifiers while nf {
				if modifier.kind == ModifierKind::Rest {
					if modifier.arity {
						signature.min = modifier.arity.min
						signature.max = modifier.arity.max
					}
					else {
						signature.min = 0
						signature.max = Infinity
					}
					
					nf = true
				}
			}
			
			if !?last || !$method.sameType(signature.type, last.type) {
				if last? {
					if last.max == Infinity {
						if that.max == Infinity {
							SyntaxException.throwTooMuchRestParameter(parent)
						}
						else {
							that.max = Infinity
						}
					}
					else {
						that.max += last.max
					}
					
					that.min += last.min
				}
				
				that.parameters.push(last = Object.clone(signature))
			}
			else {
				if signature.max == Infinity {
					last.max = Infinity
				}
				else {
					last.max += signature.max
				}
				
				last.min += signature.min
			}
		}
		
		if last? {
			if last.max == Infinity {
				if that.max == Infinity {
					SyntaxException.throwTooMuchRestParameter(parent)
				}
				else {
					that.max = Infinity
				}
			}
			else {
				that.max += last.max
			}
			
			that.min += last.min
		}
		
		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Async {
				that.async = true
			}
			else if modifier.kind == ModifierKind::Private {
				that.access = MemberAccess::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				that.access = MemberAccess::Protected
			}
		}
		
		if that.async {
			if signature?.type == 'Function' {
				++signature.min
				++signature.max
			}
			else {
				that.parameters.push({
					type: 'Function'
					min: 1
					max: 1
				})
			}
			
			++that.min
			++that.max
		}
		
		if data.type? {
			that.type = $signature.type($type.type(data.type, parent.scope(), parent), parent.scope())
		}
		
		if data.throws? {
			that.throws = [t.name for t in data.throws]
		}
		
		return that
	} // }}}
	static fromNode(parent) { // {{{
		let that = new Signature()
		
		let signature, last
		for parameter in parent._parameters {
			signature = parameter._signature
			
			if !?last || !$method.sameType(signature.type, last.type) {
				if last? {
					if last.max == Infinity {
						if that.max == Infinity {
							SyntaxException.throwTooMuchRestParameter(parent)
						}
						else {
							that.max = Infinity
						}
					}
					else {
						that.max += last.max
					}
					
					that.min += last.min
				}
				
				that.parameters.push(last = Object.clone(signature))
			}
			else {
				if signature.max == Infinity {
					last.max = Infinity
				}
				else {
					last.max += signature.max
				}
				
				last.min += signature.min
			}
		}
		
		if last? {
			if last.max == Infinity {
				if that.max == Infinity {
					SyntaxException.throwTooMuchRestParameter(parent)
				}
				else {
					that.max = Infinity
				}
			}
			else {
				that.max += last.max
			}
			
			that.min += last.min
		}
		
		for modifier in parent._data.modifiers {
			if modifier.kind == ModifierKind::Async {
				that.async = true
			}
			else if modifier.kind == ModifierKind::Private {
				that.access = MemberAccess::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				that.access = MemberAccess::Protected
			}
		}
		
		if that.async {
			if signature?.type == 'Function' {
				++signature.min
				++signature.max
			}
			else {
				that.parameters.push({
					type: 'Function'
					min: 1
					max: 1
				})
			}
			
			++that.min
			++that.max
		}
		
		if parent._data.type? {
			that.type = $signature.type($type.type(parent._data.type, parent.scope(), parent), parent.scope())
		}
		
		if parent._data.throws? {
			that.throws = [t.name for t in parent._data.throws]
		}
		
		return that
	} // }}}
}