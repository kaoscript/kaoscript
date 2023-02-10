enum AttributeData {
	Conditional
}

bitmask AttributeTarget {
	Class			= 1
	Conditional
	Constructor
	Field
	Global
	Method
	Parameter
	Property
	Statement
}

var $attributes = {}
var $semverRegex = /^(\w+)(?:-v((?:\d+)(?:\.\d+)?(?:\.\d+)?))?$/

var $rules = {
	'assert-override':				['assertOverride', true]
	'dont-assert-override':			['assertOverride', false]
	'ignore-error':					['ignoreError', true]
	'ignore-misfit':				['ignoreMisfit', true]
	'dont-ignore-misfit':			['ignoreMisfit', false]
	// TODO should be by default
	'no-undefined':					['noUndefined', true]
	'non-exhaustive':				['nonExhaustive', true]
}

class Attribute {
	static {
		conditional(data, node) { # {{{
			if data.attributes?.length > 0 {
				for var attr in data.attributes {
					if var attribute ?= Attribute.get(attr.declaration, AttributeTarget.Conditional) {
						return attribute.evaluate(node)
					}
				}
			}

			return true
		} # }}}
		configure(data, mut options?, mode, fileName, force = false) { # {{{
			var clone = !force && options != null && AttributeTarget.Global !~ mode

			if options == null {
				options = {
					rules: {}
				}
			}

			if #data.attributes {
				var cloned = {}

				if force {
					options = Object.clone(options)
				}
				else if clone {
					var original = options

					options = {}

					for var value, key of original {
						options[key] = value
					}
				}

				for var attr in data.attributes {
					if var attribute ?= Attribute.get(attr.declaration, mode) {
						if clone {
							options = attribute.clone(options, cloned)
						}

						options = attribute.configure(options, fileName, attr.start.line)
					}
				}
			}

			return options
		} # }}}
		get(data, targets) { # {{{
			var dyn name = null

			if data.kind == NodeKind.AttributeExpression {
				name = data.name.name
			}
			else if data.kind == NodeKind.Identifier {
				name = data.name
			}

			if ?name && (clazz ?= $attributes[name]) && clazz.target() ~~ targets {
				return new clazz(data)
			}
			else {
				return null
			}
		} # }}}
		register(class: Class) { # {{{
			var mut name = class.name:String.toFirstLowerCase().dasherize()

			if name.length > 10 && name.substr(-10) == '-attribute' {
				name = name.substr(0, name.length - 10)
			}

			$attributes[name] = class
		} # }}}
	}
}

class ElseAttribute extends Attribute {
	static {
		target() => AttributeTarget.Conditional
	}
	constructor(data)
	clone(options, cloned) => options
	evaluate(node) { # {{{
		if var flag ?= node.getAttributeData(AttributeData.Conditional) {
			return !flag
		}
		else {
			SyntaxException.throwNoIfAttribute()
		}
	} # }}}
}

class ErrorAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Global + AttributeTarget.Property + AttributeTarget.Statement
	}
	constructor(@data)
	clone(options, cloned) { # {{{
		if !?cloned.error {
			options.error = Object.clone(options.error)

			cloned.error = true
		}

		return options
	} # }}}
	configure(options, fileName, lineNumber) { # {{{
		for arg in @data.arguments {
			match arg.kind {
				NodeKind.AttributeExpression {
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
				NodeKind.Identifier {
					match arg.name {
						'off' => options.error.level = 'off'
					}
				}
			}
		}

		return options
	} # }}}
}

class FormatAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Global + AttributeTarget.Statement
	}
	constructor(@data)
	clone(options, cloned) { # {{{
		if !?cloned.format {
			options.format = Object.clone(options.format)

			cloned.format = true
		}

		return options
	} # }}}
	configure(options, fileName, lineNumber) { # {{{
		for arg in @data.arguments {
			if arg.kind == NodeKind.AttributeOperation {
				options.format[arg.name.name] = arg.value.value
			}
		}

		return options
	} # }}}
}

class IfAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Conditional
	}
	constructor(@data)
	clone(options, cloned) => options
	compareVersion(a, b) { # {{{
		var as = a.split('.')
		var bs = b.split('.')

		var mut ai = parseInt(as[0])
		var mut bi = parseInt(bs[0])

		if ai < bi {
			return -1
		}
		else if ai > bi {
			return 1
		}
		else {
			ai = as.length == 1 ? 0 : parseInt(as[1])
			bi = bs.length == 1 ? 0 : parseInt(bs[1])

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
	} # }}}
	evaluate(node) { # {{{
		if @data.arguments.length != 1 {
			SyntaxException.throwTooMuchAttributesForIfAttribute()
		}

		var flag = @evaluate(@data.arguments[0], node.target())

		node.setAttributeData(AttributeData.Conditional, flag)

		return flag
	} # }}}
	evaluate(data, target) { # {{{
		if data.kind == NodeKind.AttributeExpression {
			match data.name.name {
				'all' {
					for arg in data.arguments when !@evaluate(arg, target) {
						return false
					}

					return true
				}
				'any' {
					for arg in data.arguments when @evaluate(arg, target) {
						return true
					}

					return false
				}
				'gt' {
					if var match ?= $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name || !?match[2] {
							return false
						}

						return @compareVersion(target.version, match[2]) > 0
					}
					else {
						return false
					}
				}
				'gte' {
					if var match ?= $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name {
							return false
						}
						else if !?match[2] {
							return true
						}

						return @compareVersion(target.version, match[2]) >= 0
					}
					else {
						return false
					}
				}
				'lt' {
					if var match ?= $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name || !?match[2] {
							return false
						}

						return @compareVersion(target.version, match[2]) < 0
					}
					else {
						return false
					}
				}
				'lte' {
					if var match ?= $semverRegex.exec(data.arguments[0].name) {
						if match[1] != target.name {
							return false
						}
						else if !?match[2] {
							return true
						}

						return @compareVersion(target.version, match[2]) <= 0
					}
					else {
						return false
					}
				}
				'none' {
					for arg in data.arguments when @evaluate(arg, target) {
						return false
					}

					return true
				}
				'one' {
					var mut count = 0

					for arg in data.arguments when @evaluate(arg, target) {
						count += 1
					}

					return count == 1
				}
				else {
					console.info(data)
					throw new NotImplementedException()
				}
			}
		}
		else if data.kind == NodeKind.Identifier {
			if match ?= $semverRegex.exec(data.name) {
				if ?match[2] {
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
	} # }}}
}

class ParseAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Global + AttributeTarget.Statement
	}
	constructor(@data)
	clone(options, cloned) { # {{{
		if !?cloned.parse {
			options.parse = Object.clone(options.parse)

			cloned.parse = true
		}

		return options
	} # }}}
	configure(options, fileName, lineNumber) { # {{{
		for arg in @data.arguments {
			if arg.kind == NodeKind.AttributeOperation {
				options.parse[arg.name.name] = arg.value.value
			}
		}

		return options
	} # }}}
}

class RetainAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Parameter
	}
	constructor(@data)
	clone(options, cloned) { # {{{
		if !?cloned.parameters {
			options.parameters = Object.clone(options.parameters)

			cloned.parameters = true
		}

		return options
	} # }}}
	configure(options, fileName, lineNumber) { # {{{
		options.parameters.retain = true

		return options
	} # }}}
}

class RetainParametersAttribute extends RetainAttribute {
	static {
		target() => AttributeTarget.Global + AttributeTarget.Statement
	}
}

class RulesAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Global + AttributeTarget.Property + AttributeTarget.Statement
	}
	constructor(@data)
	clone(options, cloned) { # {{{
		if !?cloned.rules {
			options.rules = Object.clone(options.rules)

			cloned.rules = true
		}

		return options
	} # }}}
	configure(options, fileName, lineNumber) { # {{{
		for var argument in @data.arguments {
			if argument.kind == NodeKind.Identifier {
				var name = argument.name.toLowerCase()

				if var data ?= $rules[name] {
					options.rules[data[0]] = data[1]
				}
				else {
					SyntaxException.throwInvalidRule(name, fileName, lineNumber)
				}
			}
		}

		return options
	} # }}}
}

class RuntimeAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Global
	}
	constructor(@data)
	configure(options, fileName, lineNumber) { # {{{
		for var arg in @data.arguments {
			if arg.kind == NodeKind.AttributeOperation {
				if arg.name.name == 'package' {
					options.runtime.helper.package = options.runtime.type.package = arg.value.value
				}
				else if arg.name.name == 'prefix' {
					var prefix = arg.value.value

					options.runtime.helper.alias = prefix + options.runtime.helper.alias
					options.runtime.operator.alias = prefix + options.runtime.operator.alias
					options.runtime.type.alias = prefix + options.runtime.type.alias
				}
			}
			else if arg.kind == NodeKind.AttributeExpression {
				if arg.name.name == 'helper' {
					for var arg in arg.arguments {
						if arg.kind == NodeKind.AttributeOperation {
							match arg.name.name {
								'alias' => options.runtime.helper.alias = arg.value.value
								'member' => options.runtime.helper.member = arg.value.value
								'package' => options.runtime.helper.package = arg.value.value
							}
						}
					}
				}
				else if arg.name.name == 'operator' {
					for var arg in arg.arguments {
						if arg.kind == NodeKind.AttributeOperation {
							match arg.name.name {
								'alias' => options.runtime.operator.alias = arg.value.value
								'member' => options.runtime.operator.member = arg.value.value
								'package' => options.runtime.operator.package = arg.value.value
							}
						}
					}
				}
				else if arg.name.name == 'type' {
					for var arg in arg.arguments {
						if arg.kind == NodeKind.AttributeOperation {
							match arg.name.name {
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
	} # }}}
}

class TargetAttribute extends Attribute {
	private {
		@data
	}
	static {
		target() => AttributeTarget.Global + AttributeTarget.Statement
	}
	constructor(@data)
	clone(options, cloned) { # {{{
		if !?cloned.target {
			options.target = Object.clone(options.target)

			cloned.target = true
		}
		if !?cloned.parse {
			options.parse = Object.clone(options.parse)

			cloned.parse = true
		}
		if !?cloned.format {
			options.format = Object.clone(options.format)

			cloned.format = true
		}

		return options
	} # }}}
	configure(mut options, fileName, lineNumber) { # {{{
		for argument in @data.arguments {
			if argument.kind == NodeKind.Identifier {
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
	} # }}}
}

Attribute.register(ElseAttribute)
Attribute.register(ErrorAttribute)
Attribute.register(FormatAttribute)
Attribute.register(IfAttribute)
Attribute.register(ParseAttribute)
Attribute.register(ParseAttribute)
Attribute.register(RetainAttribute)
Attribute.register(RetainParametersAttribute)
Attribute.register(RulesAttribute)
Attribute.register(RuntimeAttribute)
Attribute.register(TargetAttribute)
