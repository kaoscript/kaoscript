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
const $semverRegex = /^(\w+)(?:-v((?:\d+)(?:\.\d+)?(?:\.\d+)?))?$/

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
	constructor(data)
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
	compareVersion(a, b) { // {{{
		a = a.split('.')
		b = b.split('.')

		let ai = parseInt(a[0])
		let bi = parseInt(b[0])
		if ai < bi {
			return -1
		}
		else if ai > bi {
			return 1
		}
		else {
			ai = a.length == 1 ? 0 : parseInt(a[1])
			bi = b.length == 1 ? 0 : parseInt(b[1])

			if ai < bi {
				return -1
			}
			else if ai > bi {
				return 1
			}
			else {
				return 0
			}
		}
	} // }}}
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
			switch data.name.name {
				'all' => {
					for arg in data.arguments when !this.evaluate(arg, target) {
						return false
					}

					return true
				}
				'any' => {
					for arg in data.arguments when this.evaluate(arg, target) {
						return true
					}

					return false
				}
				'gt' => {
					if const match = $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name || !?match[2] {
							return false
						}

						return this.compareVersion(target.version, match[2]) > 0
					}
					else {
						return false
					}
				}
				'gte' => {
					if const match = $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name {
							return false
						}
						else if !?match[2] {
							return true
						}

						return this.compareVersion(target.version, match[2]) >= 0
					}
					else {
						return false
					}
				}
				'lt' => {
					if const match = $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name || !?match[2] {
							return false
						}

						return this.compareVersion(target.version, match[2]) < 0
					}
					else {
						return false
					}
				}
				'lte' => {
					if const match = $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name {
							return false
						}
						else if !?match[2] {
							return true
						}

						return this.compareVersion(target.version, match[2]) <= 0
					}
					else {
						return false
					}
				}
				'none' => {
					for arg in data.arguments when this.evaluate(arg, target) {
						return false
					}

					return true
				}
				'one' => {
					let count = 0

					for arg in data.arguments when this.evaluate(arg, target) {
						++count
					}

					return count == 1
				}
				=> {
					console.info(data)
					throw new NotImplementedException()
				}
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

class RulesAttribute extends Attribute {
	private {
		_data
	}
	static {
		target() => AttributeTarget::Global
	}
	constructor(@data)
	configure(options) { // {{{
		for const argument in @data.arguments {
			if argument.kind == NodeKind::Identifier {
				const name = argument.name.toLowerCase().replace(/[-_\s]+(.)/g, (m, l) => l.toUpperCase())

				options.rules[name] = true
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

				options = $expandOptions(options)
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
Attribute.register(RulesAttribute)
Attribute.register(RuntimeAttribute)
Attribute.register(TargetAttribute)