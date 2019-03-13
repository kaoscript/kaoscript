enum AttributeData {
	Conditional
}

#[flags]
enum AttributeTarget {
	Class			= 0
	Conditional
	Constructor
	Field
	Global
	Method
	Property
	Statement
}

const $attributes = {}
const $semverRegex = /(\w+)(?:\-v(0|[1-9]\d*))?$/

class Attribute {
	static {
		conditional(data, node) { // {{{
			if data.attributes?.length > 0 {
				for const attr in data.attributes {
					if const attribute = Attribute.get(attr.declaration, AttributeTarget::Conditional) {
						return attribute.evaluate(node)
					}
				}
			}

			return true
		} // }}}
		configure(data, options, clone, targets) { // {{{
			if data.attributes?.length > 0 {
				for const attr in data.attributes {
					if const attribute = Attribute.get(attr.declaration, targets) {
						if clone {
							options = Object.clone(options)

							clone = false
						}

						options = attribute.configure(options)
					}
				}
			}

			return options
		} // }}}
		get(data, targets) { // {{{
			let name = null

			if data.kind == NodeKind::AttributeExpression {
				name = data.name.name
			}
			else if data.kind == NodeKind::Identifier {
				name = data.name
			}

			if ?name && (clazz ?= $attributes[name]) && clazz.target() & targets > 0 {
				return new clazz(data)
			}
			else {
				return null
			}
		} // }}}
		register(class: Class) { // {{{
			let name = class.name.toLowerCase()

			if name.length > 9 && name.substr(-9) == 'attribute' {
				name = name.substr(0, name.length - 9)
			}

			$attributes[name] = class
		} // }}}
	}
}

class ElseAttribute extends Attribute {
	static {
		target() => AttributeTarget::Conditional
	}
	constructor(data) { // {{{
		super()
	} // }}}
	evaluate(node) { // {{{
		if const flag = node.getAttributeData(AttributeData::Conditional) {
			return !flag
		}
		else {
			SyntaxException.throwNoIfAttribute()
		}
	} // }}}
}

class ErrorAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Global | AttributeTarget::Property | AttributeTarget::Statement
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

		return options
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

		return options
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
	evaluate(node) { // {{{
		if @data.arguments.length != 1 {
			SyntaxException.throwTooMuchAttributesForIfAttribute()
		}

		const flag = this.evaluate(@data.arguments[0], node.target())

		node.setAttributeData(AttributeData::Conditional, flag)

		return flag
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
			else if data.name.name == 'none' {
				for arg in data.arguments when this.evaluate(arg, target) {
					return false
				}

				return true
			}
			else if data.name.name == 'one' {
				let count = 0

				for arg in data.arguments when this.evaluate(arg, target) {
					++count
				}

				return count == 1
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

		return options
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

		return options
	} // }}}
}

class TargetAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Global | AttributeTarget::Statement
	}
	constructor(@data)
	configure(options) { // {{{
		for argument in @data.arguments {
			if argument.kind == NodeKind::Identifier {
				if match !?= $targetRegex.exec(argument.name) {
					throw new Error(`Invalid target syntax: \(argument.name)`)
				}

				options.target = {
					name: match[1],
					version: match[2]
				}

				if !?$targets[options.target.name] {
					throw new Error(`Undefined target '\(options.target.name)'`)
				}
				else if !?$targets[options.target.name][options.target.version] {
					throw new Error(`Undefined target's version '\(options.target.version)'`)
				}

				options = Object.defaults(options, $targets[options.target.name][options.target.version])
			}
		}

		return options
	} // }}}
}

Attribute.register(ElseAttribute)
Attribute.register(ErrorAttribute)
Attribute.register(FormatAttribute)
Attribute.register(IfAttribute)
Attribute.register(ParseAttribute)
Attribute.register(RuntimeAttribute)
Attribute.register(TargetAttribute)