const $function = {
	arity(parameter) { // {{{
		for i from 0 til parameter.modifiers.length {
			if parameter.modifiers[i].kind == ParameterModifier::Rest {
				return parameter.modifiers[i].arity
			}
		}
		
		return null
	} // }}}
	isArgumentsRequired(node) { // {{{
		if node._data.kind == Kind::ArrayComprehension {
			return false
		}
		
		let signature = $function.signature(node._data, node)
		
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
		let signature = $function.signature(data, node)
		
		for parameter, i in node._parameters {
			if signature.parameters[i].rest {
				$throw(`Parameter can't be a rest parameter at line \(parameter.start.line)`, node)
			}
			else if parameter._defaultValue != null {
				$throw(`Parameter can't have a default value at line \(parameter.start.line)`, node)
			}
			else if parameter._nullable {
				$throw(`Parameter can't be nullable at line \(parameter.start.line)`, node)
			}
			else if parameter._anonymous {
				$throw(`Parameter must be named at line \(parameter.start.line)`, node)
			}
			
			fragments.code($comma) if i
			
			parameter.toParameterFragments(fragments)
		}
		
		return fn(fragments)
	} // }}}
	parametersES6(node, fragments, fn) { // {{{
		let data = node._data
		let signature = $function.signature(data, node)
		let rest = false
		
		for parameter, i in node._parameters {
			if parameter._anonymous {
				$throw(`Parameter must be named at line \(parameter.start.line)`, node)
			}
			
			fragments.code($comma) if i
			
			if signature.parameters[i].rest {
				fragments.code('...')
				
				parameter.toParameterFragments(fragments)
				
				rest = true
			}
			else if rest {
				$throw(`Parameter must be before the rest parameter at line \(parameter.start.line)`, node)
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
		let signature = $function.signature(data, node)
		//console.log(signature)
		
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
				if parameter.min {
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
		
		let inc = false
		let l = rest != -1 ? rest : node._parameters.length
		
		if (rest != -1 && !fr && (db == 0 || db + 1 == rest)) || (rest == -1 && ((!signature.async && signature.max == l && (db == 0 || db == l)) || (signature.async && signature.max == l + 1 && (db == 0 || db == l + 1)))) { // {{{
			let names = []
			
			for parameter, i in node._parameters while i < l {
				fragments.code($comma) if i
				
				parameter.toParameterFragments(fragments)
				
				names.push(parameter._name)
			}
			
			if !ra && rest != -1 && (signature.parameters[rest].type == 'Any' || !maxa) && node._options.format.parameters == 'es6' {
				parameter = node._parameters[rest]
				
				if rest {
					fragments.code(', ')
				}
				
				fragments.code('...')
				
				parameter.toParameterFragments(fragments)
				
				names.push(parameter._name)
			}
			else if signature.async && !ra {
				if l {
					fragments.code(', ')
				}
				
				fragments.code('__ks_cb')
			}
			
			fragments = fn(fragments)
			
			if ra {
				fragments
					.newControl()
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.line('throw new Error("Wrong number of arguments")')
					.done()
			}
			
			for parameter, i in node._parameters while i < l {
				if !parameter._anonymous && (node._options.format.parameters == 'es5' || (node._options.format.parameters == 'es6' && !parameter._nullable) || parameter._defaultValue != null) {
					ctrl = fragments
						.newControl()
						.code('if(').compile(parameter).code(' === undefined')
					
					if !parameter._nullable {
						ctrl.code(' || ').compile(parameter).code(' === null')
					}
					
					ctrl.code(')').step()
					
					if parameter._defaultValue != null {
						ctrl
							.newLine()
							.compile(parameter)
							.code($equals)
							.compile(parameter._defaultValue)
							.done()
					}
					else if parameter._nullable {
						ctrl
							.newLine()
							.compile(parameter)
							.code($equals, 'null')
							.done()
					}
					else {
						ctrl.line('throw new Error("Missing parameter \'', parameter._name, '\'")')
					}
					
					ctrl.done()
				}
				
				if !$type.isAny(parameter._type) {
					ctrl = fragments
						.newControl()
						.code('if(')
					
					if parameter._nullable {
						ctrl.code(names[i], ' !== null && ')
					}
					
					ctrl.code('!')
					
					$type.check(node, ctrl, names[i], parameter._type)
					
					ctrl
						.code(')')
						.step()
						.line('throw new Error("Invalid type for parameter \'', parameter._name, '\'")')
					
					ctrl.done()
				}
			}
			
			if ra {
				parameter = data.parameters[rest]
				
				if signature.parameters[rest].type == 'Any' {
					if parameter.name {
						fragments.line($variable.scope(node), '__ks_i')
						
						fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = arguments.length > ' + (maxb + ra) + ' ? Array.prototype.slice.call(arguments, ' + maxb + ', __ks_i = arguments.length - ' + ra + ') : (__ks_i = ' + maxb + ', [])')
					}
					else {
						fragments.line($variable.scope(node), '__ks_i = arguments.length > ' + (maxb + ra) + ' ? arguments.length - ' + ra + ' : ' + maxb)
					}
				}
				else {
					fragments.line($variable.scope(node), '__ks_i')
					
					if parameter.name {
						fragments.line($variable.scope(node), parameter.name, parameter.name.name, ' = []')
					}
				}
			}
			else if rest != -1 && signature.parameters[rest].type != 'Any' && maxa {
				parameter = data.parameters[rest]
				
				if maxb {
				}
				else {
					fragments.line($variable.scope(node), '__ks_i = -1')
				}
			
				if parameter.name {
					fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = []')
				}
				
				ctrl = fragments
					.newControl()
					.code('while(')
				
				$type.check(node, ctrl, 'arguments[++__ks_i]', parameter.type)
				
				ctrl
					.code(')')
					.step()
				
				if parameter.name {
					ctrl.line(parameter.name.name, parameter.name, '.push(arguments[__ks_i])')
				}
				
				ctrl.done()
			}
			else if rest != -1 && node._options.format.parameters == 'es5' {
				parameter = node._parameters[rest]
				
				fragments
					.newLine()
					.code($variable.scope(node))
					.compile(parameter)
					.code($equals, `Array.prototype.slice.call(arguments, \(maxb), arguments.length)`)
					.done()
			}
			
			if rest != -1 && (parameter = node._parameters[rest])._defaultValue != null {
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
			
			if rest != -1 {
				parameter = data.parameters[rest]
				
				if (arity = $function.arity(parameter)) && arity.min {
					fragments
						.newControl()
						.code('if(', parameter.name.name, parameter.name, '.length < ', arity.min, ')')
						.step()
						.line('throw new Error("Wrong number of arguments")')
						.done()
				}
			}
			else if signature.async && !ra {
				node.module().flag('Type')
				
				fragments
					.newControl()
					.code('if(!', $runtime.type(node), '.isFunction(__ks_cb))')
					.step()
					.line('throw new Error("Invalid callback")')
					.done()
			}
		} // }}}
		else { // {{{
			fragments = fn(fragments)
			
			if signature.min {
				fragments
					.newControl()
					.code('if(arguments.length < ', signature.min, ')')
					.step()
					.line('throw new Error("Wrong number of arguments")')
					.done()
			}
				
			fragments.line($variable.scope(node), '__ks_i = -1')
			
			let required = rb
			let optional = 0
			
			for i from 0 til l {
				parameter = data.parameters[i]
				
				if arity = $function.arity(parameter) { // {{{
					required -= arity.min
					
					if parameter.name {
						if $type.isAny(parameter.type) {
							if required {
								fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length - ', required, ', __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
								}
							}
							else {
								fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = Array.prototype.slice.call(arguments, __ks_i + 1, Math.min(arguments.length, __ks_i + ', arity.max + 1, '))')
								
								if i + 1 < data.parameters.length {
									fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
								}
							}
						}
						else {
							fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = []')
							
							ctrl = fragments.newControl()
							
							if required {
								ctrl.code('while(__ks_i < arguments.length - ', required, ' && ')
							}
							else {
								ctrl.code('while(__ks_i + 1 < arguments.length && ')
							}
							
							ctrl
								.code(parameter.name.name, parameter.name, '.length < ', arity.max, ' )')
								.step()
								.done()
						}
					}
					else {
					}
					
					optional += arity.max - arity.min
				} // }}}
				else { // {{{
					if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
						ctrl = fragments
							.newControl()
							.code('if(arguments.length > ', signature.min + optional, ')')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = arguments[++__ks_i]')
							}
							else {
								ctrl.line('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl()
								.code('if(')
							
							$type.check(node, ctrl2, 'arguments[__ks_i + 1]', parameter.type)
							
							ctrl2
								.code(')')
								.step()
								.line('var ', parameter.name.name, parameter.name, ' = arguments[++__ks_i]')
							
							ctrl2
								.step()
								.code('else')
								.step()
							
							if rest == -1 {
								ctrl2.line('throw new Error("Invalid type for parameter \'', parameter.name.name, parameter.name, '\'")')
							}
							else if parameter.defaultValue {
								ctrl2
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl2.line('var ', parameter.name.name, parameter.name, ' = null')
							}
							
							ctrl2.done()
						}
						
						if parameter.name {
							ctrl.step().code('else').step()
						
							if parameter.defaultValue {
								ctrl
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = null')
							}
						}
						
						ctrl.done()
						
						++optional
					}
					else {
						if $type.isAny(parameter.type) {
							if parameter.name {
								fragments.line('var ', parameter.name.name, parameter.name, ' = arguments[++__ks_i]')
							}
							else {
								fragments.line('++__ks_i')
							}
						}
						else {
							if parameter.name {
								ctrl = fragments
									.newControl()
									.code('if(')
								
								$type.check(node, ctrl, 'arguments[++__ks_i]', parameter.type)
								
								ctrl
									.code(')')
									.step()
									.line('var ', parameter.name.name, parameter.name, ' = arguments[__ks_i]')
								
								ctrl
									.step()
									.code('else throw new Error("Invalid type for parameter \'', parameter.name.name, parameter.name, '\'")')
									.done()
							}
							else {
								ctrl = fragments
									.newControl()
									.code('if(!')
								
								$type.check(node, ctrl, 'arguments[++__ks_i]', parameter.type)
								
								ctrl
									.code(')')
									.step()
									.line('throw new Error("Wrong type of arguments")')
									.done()
							}
						}
						
						--required
					}
				}
				// }}}
			}
			
			if rest != -1 { // {{{
				parameter = data.parameters[rest]
				
				if ra {
					if parameter.name {
						fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = arguments.length > __ks_i + ', ra + 1, ' ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - ' + ra + ') : []')
						
						if l + 1 < data.parameters.length {
							fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
						}
					}
					else if l + 1 < data.parameters.length {
						fragments
							.newControl()
							.code('if(arguments.length > __ks_i + ' , ra + 1, ')')
							.step()
							.line('__ks_i = arguments.length - ', ra + 1)
							.done()
					}
				}
				else {
					if parameter.name {
						fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : []')
						
						if l + 1 < data.parameters.length {
							fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
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
			
			for i from rest + 1 til data.parameters.length {
				parameter = data.parameters[i]
				
				if arity = $function.arity(parameter) {
					if arity.min {
						if parameter.name {
							if $type.isAny(parameter.type) {
								fragments.line($variable.scope(node), parameter.name.name, parameter.name, ' = Array.prototype.slice.call(arguments, __ks_i + 1, __ks_i + ', arity.min + 1, ')')
								
								if i + 1 < data.parameters.length {
									fragments.line('__ks_i += ', parameter.name.name, parameter.name, '.length')
								}
							}
							else {
							}
						}
						else {
						}
					}
					else {
					}
				}
				else if (parameter.type && parameter.type.nullable) || parameter.defaultValue {
					if signature.parameters[rest].type == 'Any' {
						if parameter.name {
							if parameter.defaultValue {
								fragments
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								fragments.line('var ', parameter.name.name, parameter.name, ' = null')
							}
						}
					}
					else {
						ctrl = fragments
							.newControl()
							.code('if(arguments.length > __ks_m)')
							.step()
						
						if $type.isAny(parameter.type) {
							if parameter.name {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = arguments[', inc ? '++' : '', '__ks_i]')
							}
							else {
								ctrl.line('++__ks_i')
							}
						}
						else {
							ctrl2 = ctrl
								.newControl()
								.code('if(')
							
							$type.check(node, ctrl2, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type)
							
							ctrl2
								.code(')')
								.step()
								.line('var ', parameter.name.name, parameter.name, ' = arguments[__ks_i]')
							
							ctrl2
								.step()
								.code('else')
								.step()
							
							if parameter.defaultValue {
								ctrl2
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl2.line('var ', parameter.name.name, parameter.name, ' = null')
							}
							
							ctrl2.done()
						}
						
						if parameter.name {
							ctrl.step().code('else').step()
						
							if parameter.defaultValue {
								ctrl
									.newLine()
									.code('var ', parameter.name.name, parameter.name, ' = ')
									.compile(node._parameters[i]._defaultValue)
									.done()
							}
							else {
								ctrl.line('var ', parameter.name.name, parameter.name, ' = null')
							}
						}
						
						ctrl.done()
						
						if !inc {
							inc = true
						}
					}
				}
				else {
					if $type.isAny(parameter.type) {
						if parameter.name {
							fragments.line('var ', parameter.name.name, parameter.name, ' = arguments[', inc ? '++' : '', '__ks_i]')
						}
						else {
							fragments.line(inc ? '++' : '', '__ks_i')
						}
					}
					else {
						if parameter.name {
							ctrl = fragments
								.newControl()
								.code('if(')
							
							$type.check(node, ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type)
							
							ctrl
								.code(')')
								.step()
								.line('var ', parameter.name.name, parameter.name, ' = arguments[__ks_i]')
							
							ctrl
								.step()
								.code('else throw new Error("Invalid type for parameter \'', parameter.name.name, parameter.name, '\'")')
								.done()
						}
						else {
							ctrl = fragments
								.newControl()
								.code('if(!')
							
							$type.check(node, ctrl, 'arguments[' + (inc ? '++' : '') + '__ks_i]', parameter.type)
							
							ctrl
								.code(')')
								.step()
								.line('throw new Error("Wrong type of arguments")')
								.done()
						}
					}
					
					if !inc {
						inc = true
					}
				}
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
				if modifier.kind == FunctionModifier::Async {
					signature.async = true
				}
			}
		}
		
		let scope = node.scope()
		for parameter in data.parameters {
			signature.parameters.push(parameter = $function.signatureParameter(parameter, scope))
			
			if parameter.max == Infinity {
				if signature.max == Infinity {
					$throw('Function can have only one rest parameter', node)
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
			min: parameter.defaultValue || (parameter.type && parameter.type.nullable) ? 0 : 1,
			max: 1
		}
		
		if parameter.modifiers {
			for modifier in parameter.modifiers {
				if modifier.kind == ParameterModifier::Rest {
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
				if $function.useThisVariable(node._data.body) {
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
	useThisVariable(data) { // {{{
		switch data.kind {
			Kind::ArrayExpression => {
				for value in data.values {
					if $function.useThisVariable(value) {
						return true
					}
				}
			}
			Kind::BinaryOperator => {
				if $function.useThisVariable(data.left) || $function.useThisVariable(data.right) {
					return true
				}
			}
			Kind::Block => {
				for statement in data.statements {
					if $function.useThisVariable(statement) {
						return true
					}
				}
			}
			Kind::CallExpression => {
				if $function.useThisVariable(data.callee) {
					return true
				}
				
				for arg in data.arguments {
					if $function.useThisVariable(arg) {
						return true
					}
				}
			}
			Kind::CreateExpression => {
				if $function.useThisVariable(data.class) {
					return true
				}
				
				for arg in data.arguments {
					if $function.useThisVariable(arg) {
						return true
					}
				}
			}
			Kind::EnumExpression => return false
			Kind::Identifier => return data.name == 'this'
			Kind::IfStatement => {
				if $function.useThisVariable(data.condition) || $function.useThisVariable(data.then) {
					return true
				}
				
				for value in data.elseifs {
					if $function.useThisVariable(value) {
						return true
					}
				}
				
				if data.else? && data.$function.useThisVariable(data.else) {
					return true
				}
			}
			Kind::Literal => return false
			Kind::MemberExpression => return $function.useThisVariable(data.object)
			Kind::NumericExpression => return false
			Kind::ObjectExpression => {
				for property in data.properties {
					if $function.useThisVariable(property.value) {
						return true
					}
				}
			}
			Kind::ReturnStatement => return $function.useThisVariable(data.value)
			Kind::UnaryExpression => return $function.useThisVariable(data.argument)
			=> {
				console.error(data)
				$throw('Unknow kind ' + data.kind)
			}
		}
		
		return false
	} // }}}
}

class FunctionDeclaration extends Statement {
	private {
		_async		= false
		_parameters
		_statements
		_variable
	}
	$create(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		$variable.define(this, @scope, {
			kind: Kind::Identifier,
			name: 'this'
		}, VariableKind::Variable)
		
		@variable = $variable.define(this, this.greatScope(), @data.name, VariableKind::Function, @data.type)
		
		for modifier in @data.modifiers {
			if modifier.kind == FunctionModifier::Async {
				@variable.async = true
			}
		}
		
		@parameters = [new Parameter(parameter, this) for parameter in @data.parameters]
		
		@statements = [$compile.statement(statement, this) for statement in $body(@data.body)]
		
		let variable
		for error in @data.throws {
			if variable !?= $variable.fromAST(error, this) {
				$throw(`Undefined variable '\(error.name)' at line \(error.start.line)`, this)
			}
			else if variable.kind != VariableKind::Class {
				$throw(`Error '\(error.name)' must be a class (line \(error.start.line))`, this)
			}
			
			@variable.throws.push(error.name)
		}
	} // }}}
	fuse() { // {{{
		for parameter in this._parameters {
			parameter.analyse()
			parameter.fuse()
		}
		
		for statement in this._statements {
			statement.analyse()
			
			this._async = statement.isAsync() if !this._async
		}
		
		for statement in this._statements {
			statement.fuse()
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
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('function ' + this._data.name.name + '(')
		
		$function.parameters(this, ctrl, func(node) {
			return node.code(')').step()
		})
		
		if this._async {
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
		_anonymous		= false
		_defaultValue	= null
		_name			= null
		_nullable		= false
		_type
		_variable		= null
	}
	analyse() { // {{{
		let data = this._data
		let parent = this._parent
		
		this._type = data.type
		
		if data.name? {
			let signature = $function.signatureParameter(data, this._scope)
			
			if signature.rest {
				$variable.define(this, this._scope, data.name, VariableKind::Variable, {
					kind: Kind::TypeReference
					typeName: {
						kind: Kind::Identifier
						name: 'Array'
					}
				})
			}
			else {
				$variable.define(this, this._scope, data.name, $variable.kind(data.type), data.type)
			}
			
			this._variable = $compile.expression(data.name, parent)
		}
		else {
			let name = {
				kind: Kind::Identifier
				name: this._scope.acquireTempName()
			}
			
			$variable.define(this, this._scope, name, VariableKind::Variable)
			
			this._variable = $compile.expression(name, parent)
			this._anonymous = true
		}
		
		if data.defaultValue? {
			this._defaultValue = $compile.expression(data.defaultValue, parent)
		}
		
		this._name = this._variable._value
		this._nullable = this._data.type?.nullable
	} // }}}
	fuse() {// {{{
		if this._defaultValue != null {
			this._defaultValue.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._variable)
	} // }}}
	toParameterFragments(fragments) { // {{{
		fragments.compile(this._variable)
		
		fragments.code(' = null') if this._nullable && !?this._data.defaultValue && this._options.format.parameters == 'es6'
	} // }}}
}