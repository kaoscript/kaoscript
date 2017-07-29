extern eval

enum MacroVariableKind {
	AST
	AutoEvaluated
}

func $evaluate(source) { // {{{
	const compiler = new Compiler('__ks__')
	
	compiler.compile('#![bin]\nreturn ' + source)
	
	//console.log(compiler.toSource())
	
	return eval(`(function() {\(compiler.toSource())})()`)
} // }}}

func $nil() { // {{{
} // }}}

func $reificate(data, kind) { // {{{
	return $ast.toSource(data, $nil)
} // }}}

class Macro extends AbstractNode {
	private {
		_fn: Function
		_name: String
		_parameters: Object			= {}
		_type: MacroType
	}
	constructor(@data, @parent) { // {{{
		super(data, parent, new Scope())
		
		@scope.addNative('Identifier')
		@scope.addNative('Expression')
		
		@name = data.name.name
		@type = MacroType.fromAST(data, this)
		
		const builder = new FragmentBuilder(0, FragmentTarget::Kaoscript)
		
		const line = builder.newLine().code('func(__ks_evaluate, __ks_reificate')
		
		let auto
		for data in @data.parameters {
			line.code(', ', data.name.name)
			
			if data.defaultValue? {
				line.code(' = ', $ast.toSource(data.defaultValue, $nil))
			}
			
			auto = false
			
			for modifier in data.modifiers until auto {
				if modifier.kind == ModifierKind::AutoEvaluate {
					auto = true
				}
			}
			
			@parameters[data.name.name] = auto ? MacroVariableKind::AutoEvaluated : MacroVariableKind::AST
		}
		
		const block = line.code(')').newBlock()
		
		for name, kind of @parameters {
			if kind == MacroVariableKind::AutoEvaluated {
				block.line(`\(name) = __ks_evaluate(__ks_reificate(\(name), 3))`)
			}
		}
		
		block.line('let __ks_src = ""')
		
		for statement in $ast.block(@data.body).statements {
			if statement.kind == NodeKind::MacroExpression {
				this.toStatementFragments(statement, block)
			}
			else {
				block.line($ast.toSource(statement, $nil))
			}
		}
		
		block.line('return __ks_src').done()
		
		line.done()
		
		let source = ''
		
		for fragment in builder.toArray() {
			source += fragment.code
		}
		
		//console.log(source)
		
		@fn = $evaluate(source)
	} // }}}
	analyse()
	prepare()
	translate()
	execute(arguments: Array, parent) { // {{{
		const module = this.module()
		
		const args = [$evaluate, $reificate].concat(arguments)
		
		/* for argument in arguments {
			/* args.push($ast.toValue(argument, this)) */
			args.push(argument)
		} */
		
		let data = @fn(...args)
		//console.log(data)
		
		try {
			data = module.parse(data, path)
		}
		catch error {
			error.filename = path
			
			throw error
		}
		
		const statements = []
		
		for statement in data.body when statement ?= $compile.statement(statement, parent) {
			statements.push(statement)
		}
		
		return statements
	} // }}}
	isInstanceMethod() => false
	matchArguments(arguments: Array) => @type.matchArguments(arguments)
	name() => @name
	statement() => this
	type() => @type
	private toStatementFragments(data, fragments) { // {{{
		const line = fragments.newLine().code('__ks_src += ')
		
		for element, index in data.elements {
			if index != 0 {
				line.code(' + ')
			}
			
			switch element.kind {
				NodeKind::Literal => {
					line.code($quote(element.value.replace(/\\/g, '\\\\')))
				}
				NodeKind::MacroVariable => {
					if element.expression.kind == NodeKind::Identifier {
						if @parameters[element.expression.name] == MacroVariableKind::AST {
							line.code(`__ks_reificate(\(element.expression.name), \(element.reification.kind))`)
						}
						else {
							line.code(element.expression.name)
						}
					}
					else {
						line.code(`__ks_reificate(\($ast.toSource(element.expression, $nil)), \(element.reification.kind))`)
					}
				}
			}
		}
		
		line.done()
	} // }}}
}

class MacroType extends FunctionType {
	static fromAST(data, node: AbstractNode) { // {{{
		const domain = node.scope().domain()
		
		return new MacroType([MacroParameterType.fromAST(parameter, domain, false, node) for parameter in data.parameters], data, node)
	} // }}}
	static import(data, references, domain: Domain, node: AbstractNode): MacroType { // {{{
		const type = new MacroType()
		
		type._min = data.min
		type._max = data.max
		
		type._parameters = [MacroParameterType.import(parameter, references, domain, node) for parameter in data.parameters]
		
		type.updateArguments()
		
		return type
	} // }}}
	export() => { // {{{
		min: @min
		max: @max
		parameters: [parameter.export() for parameter in @parameters]
	} // }}}
	match(that: MacroType): Boolean { // {{{
		if that.min() < @min || that.max() > @max {
			return false
		}
		
		const params = that.parameters()
		
		if @parameters.length == params.length {
			for parameter, i in @parameters {
				if !parameter.match(params[i]) {
					return false
				}
			}
		}
		else if @hasRest {
			throw new NotImplementedException()
		}
		else {
			throw new NotImplementedException()
		}
		
		return true
	} // }}}
}

class MacroParameterType extends ParameterType {
	static {
		fromAST(data, domain: Domain, defined: Boolean, node: AbstractNode) { // {{{
			const type = Type.fromAST(data.type, domain, false, node)
			
			let min: Number = data.defaultValue? ? 0 : 1
			let max: Number = 1
			
			let nf = true
			for modifier in data.modifiers while nf {
				if modifier.kind == ModifierKind::Rest {
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
			
			return new MacroParameterType(type, min, max)
		} // }}}
	}
	clone() => new MacroParameterType(@type, @min, @max)
	matchArgument(argument) { // {{{
		//console.log(@type)
		//console.log(argument)
		
		if @type.isAny() {
			return true
		}
		
		switch @type.name() {
			'Expression' => {
				return	argument.kind == NodeKind::UnaryExpression ||
						argument.kind == NodeKind::BinaryExpression ||
						argument.kind == NodeKind::PolyadicExpression ||
						$expressions[argument.kind]?
			}
			'Identifier' => {
				return argument.kind == NodeKind::Identifier
			}
			'Number' => {
				return argument.kind == NodeKind::NumericExpression
			}
			'String' => {
				return argument.kind == NodeKind::Literal
			}
		}
		
		return false
	} // }}}
}

class CallMacroStatement extends Statement {
	private {
		_statements: Array
	}
	analyse() { // {{{
		const macro = this.scope().getMacro(@data, this)
		
		@statements = macro.execute(@data.arguments, this)
		
		for statement in @statements {
			statement.analyse()
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			statement.prepare()
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isAwait() { // {{{
		for statement in @statements {
			if statement.isAwait() {
				return true
			}
		}
		
		return false
	} // }}}
	isExit() { // {{{
		for statement in @statements {
			if statement.isExit() {
				return true
			}
		}
		
		return false
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}