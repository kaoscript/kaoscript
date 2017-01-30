enum AttributeTarget {
	Class			= 1
	Conditional		= 2
	Constructor		= 4
	Field			= 8
	Global			= 16
	Method			= 32
	Property		= 64
	Statement		= 128
}

const $attributes = {}
const $semverRegex = /(\w+)(?:\-v(0|[1-9]\d*))?$/

class Attribute {
	static {
		conditional(data, target) { // {{{
			if data.attributes?.length > 0 {
				let attribute
				
				for attr in data.attributes {
					if attr.declaration.kind == NodeKind::AttributeExpression && (attribute ?= Attribute.get(attr.declaration, AttributeTarget::Conditional)) {
						return attribute.evaluate(target)
					}
				}
			}
			
			return true
		} // }}}
		configure(data, options, targets) { // {{{
			let nc = true
			
			if data.attributes?.length > 0 {
				let attribute
				for attr in data.attributes {
					if attr.declaration.kind == NodeKind::AttributeExpression && (attribute ?= Attribute.get(attr.declaration, targets)) {
						if nc {
							options = Object.clone(options)
							
							nc = false
						}
						
						attribute.configure(options)
					}
				}
			}
			
			return options
		} // }}}
		get(data, targets) { // {{{
			if (clazz ?= $attributes[data.name.name]) && clazz.target() & targets > 0 {
				return new clazz(data)
			}
			else {
				return null
			}
		} // }}}
		/* register(class: Class) {
			console.log(class.name)
			let name = clazz.name.toLowerCase()
			
			if name.length > 9 && name.substr(-9) == 'attribute' {
				name = name.substr(0, name.length - 9)
			}
			
			$attributes[name] = clazz
		} */
		register(clazz) { // {{{
			let name = clazz.name.toLowerCase()
			
			if name.length > 9 && name.substr(-9) == 'attribute' {
				name = name.substr(0, name.length - 9)
			}
			
			$attributes[name] = clazz
		} // }}}
	}
}

class ErrorAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Global | AttributeTarget::Statement
	}
	constructor(@data)
	configure(options) { // {{{
		for arg in @data.arguments {
			switch arg.kind {
				NodeKind::AttributeExpression => {
					if arg.name.name == 'ignore' {
						for a in arg.arguments {
							options.error.ignore.push(a.name)
						}
					}
					else if arg.name.name == 'raise' {
						for a in arg.arguments {
							options.error.raise.push(a.name)
						}
					}
				}
				NodeKind::Identifier => {
					switch arg.name {
						'off' => options.error.level = 'off'
					}
				}
			}
		}
	} // }}}
}

class FormatAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Global | AttributeTarget::Statement
	}
	constructor(@data)
	configure(options) { // {{{
		for arg in @data.arguments {
			if arg.kind == NodeKind::AttributeOperation {
				options.format[arg.name.name] = arg.value.value
			}
		}
	} // }}}
}

class IfAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Conditional
	}
	constructor(@data)
	evaluate(target) { // {{{
		if @data.arguments.length != 1 {
			$throw(`Expected 1 argument for if() at line \(@data.start.line)`)
		}
		return this.evaluate(@data.arguments[0], target)
	} // }}}
	evaluate(data, target) { // {{{
		if data.kind == NodeKind::AttributeExpression {
			if data.name.name == 'all' {
				for arg in data.arguments when !this.evaluate(arg, target) {
					return false
				}
				
				return true
			}
			else if data.name.name == 'any' {
				for arg in data.arguments when this.evaluate(arg, target) {
					return true
				}
				
				return false
			}
		}
		else if data.kind == NodeKind::Identifier {
			if match ?= $semverRegex.exec(data.name) {
				if match[2]? {
					return target.name == match[1] && target.version == match[2]
				}
				else {
					return target.name == match[1]
				}
			}
			else {
				return false
			}
		}
	} // }}}
}

class ParseAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Global | AttributeTarget::Statement
	}
	constructor(@data)
	configure(options) { // {{{
		for arg in @data.arguments {
			if arg.kind == NodeKind::AttributeOperation {
				options.parse[arg.name.name] = arg.value.value
			}
		}
	} // }}}
}

class RuntimeAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Global
	}
	constructor(@data)
	configure(options) { // {{{
		for arg in @data.arguments {
			if arg.kind == NodeKind::AttributeOperation {
				if arg.name.name == 'package' {
					options.runtime.helper.package = options.runtime.type.package = arg.value.value
				}
			}
			else if arg.kind == NodeKind::AttributeExpression {
				if arg.name.name == 'helper' {
					for let arg in arg.arguments {
						if arg.kind == NodeKind::AttributeOperation {
							switch arg.name.name {
								'alias' => options.runtime.helper.alias = arg.value.value
								'member' => options.runtime.helper.member = arg.value.value
								'package' => options.runtime.helper.package = arg.value.value
							}
						}
					}
				}
				else if arg.name.name == 'type' {
					for let arg in arg.arguments {
						if arg.kind == NodeKind::AttributeOperation {
							switch arg.name.name {
								'alias' => options.runtime.type.alias = arg.value.value
								'member' => options.runtime.type.member = arg.value.value
								'package' => options.runtime.type.package = arg.value.value
							}
						}
					}
				}
			}
		}
	} // }}}
}

Attribute.register(ErrorAttribute)
Attribute.register(FormatAttribute)
Attribute.register(IfAttribute)
Attribute.register(ParseAttribute)
Attribute.register(RuntimeAttribute)