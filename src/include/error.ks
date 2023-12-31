extern sealed class Error

Error.prepareStackTrace = func(error: Error, stack: Array) { # {{{
	var mut message = error.toString()

	for i from 0 to~ Math.min(12, stack.length) {
		message += '\n    ' + stack[i].toString()
	}

	return message
} # }}}

func $joinQuote(values: String[], conjunction: String = 'or'): String { # {{{
	var last = values.length - 1

	if last > 0 {
		var mut result = '"'

		for var value, index in values {
			if index == last {
				result += `" \(conjunction) "`
			}
			else if index > 0 {
				result += '", "'
			}

			result += value
		}

		result += '"'

		return result
	}
	else {
		return `"\(values[0])"`
	}
} # }}}

export class Exception extends Error {
	public {
		fileName: String?		= null
		lineNumber: Number		= 0
		message: String
		name: String
	}

	static {
		validateReportedError(mut error: Type, node) { # {{{
			#![rules(ignore-misfit)]

			until error is NamedType {
				if error.isExtending() {
					error = error.extends()
				}
				else {
					error = node.scope().getVariable('Error').type()
				}
			}

			var options = node._options.error

			if options.level == 'fatal' {
				if !node.parent().isConsumedError(error) {
					if options.ignore.length == 0 {
						SyntaxException.throwUnreportedError(error.name(), node)
					}
					else {
						var hierarchy = error.getHierarchy()

						var mut nf = true

						for var name in hierarchy while nf {
							if options.ignore:!(Array).contains(name) {
								nf = false
							}
						}

						if nf {
							SyntaxException.throwUnreportedError(error.name(), node)
						}
						else if options.raise.length != 0 {
							for var name in hierarchy {
								if options.raise:!(Array).contains(name) {
									SyntaxException.throwUnreportedError(error.name(), node)
								}
							}
						}
					}
				}
			}
		} # }}}
	}

	constructor(@message) { # {{{
		super()

		@name = this.constructor.name
	} # }}}

	constructor(@message, @fileName, @lineNumber) { # {{{
		this(message)
	} # }}}

	constructor(@message, node: AbstractNode) { # {{{
		this(message, node.file(), node._data.start.line)
	} # }}}

	constructor(@message, node: AbstractNode, data) { # {{{
		this(message, node.file(), data.start.line)
	} # }}}

	toString() { # {{{
		if @lineNumber == 0 {
			if @message.length == 0{
				return `\(this.name): Unexpected error`
			}
			else {
				return `\(this.name): \(@message)`
			}
		}
		else {
			if @message.length == 0 {
				return `\(this.name): \(@fileName):\(@lineNumber)`
			}
			else {
				return `\(this.name): \(@message) (\(@fileName):\(@lineNumber))`
			}
		}
	} # }}}
}

export class IOException extends Exception {
	static {
		throwNotFoundFile(path, node): Never ~ IOException { # {{{
			throw IOException.new(`The file "\(path)" can't be found`, node)
		} # }}}
		throwNotFoundFile(path, directory, node): Never ~ IOException { # {{{
			throw IOException.new(`The file "\(path)" can't be found in the directory "\(directory)"`, node)
		} # }}}
		throwNotFoundModule(name, node): Never ~ IOException { # {{{
			throw IOException.new(`The module "\(name)" can't be found`, node)
		} # }}}
		throwNotFoundModule(name, directory, node): Never ~ IOException { # {{{
			throw IOException.new(`The module "\(name)" can't be found in the directory "\(directory)"`, node)
		} # }}}
	}
}

export class NotImplementedException extends Exception {
	static {
		throw(...arguments): Never ~ NotImplementedException { # {{{
			throw NotImplementedException.new(...arguments)
		} # }}}
	}
	constructor(message = 'Not Implemented') { # {{{
		super(message)
	} # }}}
	constructor(message = 'Not Implemented', node: AbstractNode) { # {{{
		super(message, node)
	} # }}}
	constructor(message = 'Not Implemented', node: AbstractNode, data) { # {{{
		super(message, node, data)
	} # }}}
	constructor(message = 'Not Implemented', fileName, lineNumber) { # {{{
		super(message, fileName, lineNumber)
	} # }}}
}

export class NotSupportedException extends Exception {
	static {
		throw(...arguments): Never ~ NotSupportedException { # {{{
			throw NotSupportedException.new(...arguments)
		} # }}}
		throwBitmaskLength(name, length, node): Never ~ NotSupportedException { # {{{
			throw ReferenceException.new(`Bitmask of length \(length) aren't supported`, node)
		} # }}}
	}
	constructor(message = 'Not Supported') { # {{{
		super(message)
	} # }}}
	constructor(message = 'Not Supported', node: AbstractNode) { # {{{
		super(message, node)
	} # }}}
	constructor(message = 'Not Supported', node: AbstractNode, data) { # {{{
		super(message, node, data)
	} # }}}
}

export class ReferenceException extends Exception {
	static {
		throwAliasTypeVariable(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The type "\(name)" is not a variable`, node)
		} # }}}
		throwAlreadyDefinedField(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`Field "\(name)" is already defined`, node)
		} # }}}
		throwBindingExceedArray(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The destructuring variable "\(name)" can't be matched`, node)
		} # }}}
		throwConfusingArguments(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The arguments (indexed/named) can be matched to the function "\(name)" in multiple ways`, node)
		} # }}}
		throwDefined(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`"\(name)" should not be defined`, node)
		} # }}}
		throwImmutable(name: String, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The identifier "\(name)" is immutable`, node)
		} # }}}
		throwImmutable(node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The expression "\(node.toQuote())" is immutable`, node)
		} # }}}
		throwImmutableField(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The class variable "\(name)" is immutable`, node)
		} # }}}
		throwIncompleteVariable(argname, modname, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The variable "\(argname)" must be complete before passing it to the module "\(modname)"`, node)
		} # }}}
		throwInvalidAssignment(node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`No value can be assigned to the expression \(node.toQuote(true))`, node)
		} # }}}
		throwLoopingAlias(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`Alias "@\(name)" is looping on itself`, node)
		} # }}}
		throwMissingThisContext(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The function "\(name)" is missing the "this" context`, node)
		} # }}}
		throwNoAssignableThisInMethod(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The method "\(name)" can't be rebinded to a new "this" context`, node)
		} # }}}
		throwNoMatchingBitmaskConstructor(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The bitmask "\(name)" can't be constructed with no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The bitmask "\(name)" can't be constructed with given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingConstructor(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The constructor of class "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The constructor of class "\(name)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingFunction(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The function "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The function "\(name)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingFunctionInNamespace(name, namespace, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The function "\(name)" in namespace \(namespace.toQuote(true)) can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The function "\(name)" in namespace \(namespace.toQuote(true)) can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingEnumConstructor(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The enum "\(name)" can't be constructed with no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The enum "\(name)" can't be constructed with given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingEnumMethod(method, enum, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The method "\(method)" of the enum "\(enum)" can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The method "\(method)" of the enum "\(enum)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingMacro(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The macro "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The macro "\(name)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingStaticMethod(method, class, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The method "\(method)" of the class "\(class)" can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The method "\(method)" of the class "\(class)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingThis(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The "this" context of function "\(name)" can't be matched`, node)
		} # }}}
		throwUnrecognizedNamedArgument(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The argument "\(name)" isn't recognized`, node)
		} # }}}
		throwNoMatchingStruct(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The struct "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The struct "\(name)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingTuple(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw ReferenceException.new(`The tuple "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw ReferenceException.new(`The tuple "\(name)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNotDefined(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`"\(name)" is not defined`, node)
		} # }}}
		throwNotDefinedEnumElement(element, enum, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`Element "\(element)" is not defined in enum "\(enum)"`, node)
		} # }}}
		throwNotDefinedInModule(name, module, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`"\(name)" is not defined in the module "\(module)"`, node)
		} # }}}
		throwNotDefinedMember(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`Member "\(name)" is not defined`, node)
		} # }}}
		throwNotDefinedProperty(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`Property "\(name)" is not defined`, node)
		} # }}}
		throwNotDefinedProperty(expression, property, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The property \(property) isn't defined in the expression \(expression.toQuote(true)) of type \(expression.type().toQuote(true))`, node)
		} # }}}
		throwNotDefinedType(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`Type "\(name)" is not defined`, node)
		} # }}}
		throwNotDeterminableProperty(expression, property, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The property \(property) can't be ascertained from the expression \(expression.toQuote(true)) of type \(expression.type().toQuote(true))`, node)
		} # }}}
		throwNotExportable(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The exported variable "\(name)" is not exportable`, node)
		} # }}}
		throwNotFoundEnumMethod(method, enum, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The method "\(method)" can't be found in the enum "\(enum)"`, node)
		} # }}}
		throwNotFoundStaticMethod(method, class, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The method "\(method)" can't be found in the class "\(class)"`, node)
		} # }}}
		throwNotPassed(name, module, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`To overwrite "\(name)", it needs to be passed to the module "\(module)"`, node)
		} # }}}
		throwNotNullableProxy(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The proxy "\(name)" can't be null`, node)
		} # }}}
		throwNotYetDefinedType(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`Type "\(name)" isn't yet fully defined`, node)
		} # }}}
		throwNoTypeProxy(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The proxy "\(name)" must be typed`, node)
		} # }}}
		throwNoTypeProxy(name, property, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The property "\(property)" of the proxy "\(name)" must be typed`, node)
		} # }}}
		throwNullExpression(expression, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The expression \(expression.toQuote(true)) is "null"`, node)
		} # }}}
		throwUncompleteType(type, mainType, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The type \(type.toQuote(true)) needs to be declared before \(mainType.toQuote(true))`, node)
		} # }}}
		throwUndefinedBindingVariable(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The destructuring variable "\(name)" can't be matched`, node)
		} # }}}
		throwUndefinedInstanceField(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The instance field "\(name)" isn't defined`, node)
		} # }}}
		throwUndefinedFunction(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The function "\(name)" can't be found`, node)
		} # }}}
		throwUndefinedStaticField(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The class field "\(name)" isn't defined`, node)
		} # }}}
		throwUndefinedVariantField(variant, field, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The variant "\(variant)" doesn't have a field named "\(field)"`, node)
		} # }}}
		throwUnresolvedImplicitProperty(name, node): Never ~ ReferenceException { # {{{
			throw ReferenceException.new(`The implicit property ".\(name)" couldn't be resolved`, node)
		} # }}}
	}
}

export class SyntaxException extends Exception {
	static {
		throwAfterDefaultClause(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Clause is must be before the default clause`, node)
		} # }}}
		throwAfterRestParameter(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Parameter must be before the rest parameter`, node)
		} # }}}
		throwAlreadyDeclared(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Identifier "\(name)" has already been declared`, node)
		} # }}}
		throwAlreadyImported(name, module, line, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The variable "\(name)" has already been imported by "\(module)" at line \(line)`, node)
		} # }}}
		throwBitmaskOverflow(name, length, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The bitmask "\(name)" can only have at most \(length) bits.`, node)
		} # }}}
		throwDeadCode(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Dead code`, node)
		} # }}}
		throwDeadCodeParameter(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`A parameter's default value must be "null" when its type is "required" and "nullable"`, node)
		} # }}}
		throwDeadCodeParameter(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The default value of parameter "\(name)" must be "null" when its type is "required" and "nullable"`, node)
		} # }}}
		throwDoNoExit(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The block doesn't return a value for every case`, node)
		} # }}}
		throwDuplicateConstructor(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The constructor is matching an existing constructor`, node)
		} # }}}
		throwDuplicateKey(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Duplicate key has been found in object`, node)
		} # }}}
		throwDuplicateMethod(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The method "\(name)" is matching an existing method`, node)
		} # }}}
		throwExcessiveRequirement(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The import don't require the argument "\(name)"`, node)
		} # }}}
		throwForBadSplit(kind, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`In \(kind) loop, the argument "split" must be greater than 0`, node)
		} # }}}
		throwForBadStep(kind, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The \(kind) loop can never be executed due to bad step`, node)
		} # }}}
		throwForDeadElse(kind, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The else block of the \(kind) loop can never called`, node)
		} # }}}
		throwForNoMatch(kind, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The \(kind) loop can never be executed due to bad low/high limits`, node)
		} # }}}
		throwForStepLtSplit(kind, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`In \(kind) loop, the argument "step" must be greater or equals to argument "split"`, node)
		} # }}}
		throwForUndeterminedSplit(kind, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`In \(kind) loop, the undetermined argument "split" can't be associated with a destructuring array`, node)
		} # }}}
		throwHiddenMethod(name, class1, method1, class2, method2, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The method "\(class1.toQuote()).\(name)\(method1.toQuote())" hides the method "\(class2.toQuote()).\(name)\(method2.toQuote())"`, node)
		} # }}}
		throwIdenticalConstructor(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The constructor is identical with another constructor`, node)
		} # }}}
		throwIdenticalField(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The field "\(name)" is identical with another field`, node)
		} # }}}
		throwIdenticalFunction(name, type, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The function "\(name)\(type.toQuote())" is a duplicate`, node)
		} # }}}
		throwIdenticalMethod(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The method "\(name)" is matching another method with the same types of parameters`, node)
		} # }}}
		throwIllegalStatement(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The statement "\(name)" is illegal`, node)
		} # }}}
		throwIdenticalIdentifier(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The identifier "\(name)" is already used`, node)
		} # }}}
		throwIdenticalMacro(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`A macro, named "\(name)", already exists`, node)
		} # }}}
		throwIncludeSelf(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`A file can't include itself`, node)
		} # }}}
		throwIndistinguishableFunctions(name: String, functions: Array<Type>, node): Never ~ SyntaxException { # {{{
			var last = functions.length - 1
			var mut fragments = ''

			for var function, i in functions {
				if i == last {
					fragments += ' and '
				}
				else if i != 0 {
					fragments += ', '
				}

				fragments += `"\(name)\(function.toQuote())"`
			}

			throw SyntaxException.new(`The functions \(fragments) can't be distinguished`, node)
		} # }}}
		throwIndistinguishableFunctions(name: String, arguments: Array<Type>, functions: Array<Type>, node): Never ~ SyntaxException { # {{{
			var args = `(\(arguments.map((type, _, _) => type.toQuote(true)).join(', ')))`

			var last = functions.length - 1
			var mut fragments = `the function "\(name)" can be matched with `

			for var function, i in functions {
				if i == last {
					fragments += ' or '
				}
				else if i != 0 {
					fragments += ', '
				}

				fragments += `"\(name)\(function.toQuote())"`
			}

			if arguments.length == 0 {
				throw SyntaxException.new(`When there are no arguments, \(fragments)`, node)
			}
			else {
				throw SyntaxException.new(`When the arguments are \(args), \(fragments)`, node)
			}
		} # }}}
		throwIndistinguishableFunctions(name: String, functions: Array<Type>, count: Number, node): Never ~ SyntaxException { # {{{
			var last = functions.length - 1
			var mut fragments = ''

			for var function, i in functions {
				if i == last {
					fragments += ' and '
				}
				else if i != 0 {
					fragments += ', '
				}

				fragments += `"\(name)\(function.toQuote())"`
			}

			if count == 0 {
				throw SyntaxException.new(`The functions \(fragments) can't be distinguished when there are no arguments`, node)
			}
			else if count == 1 {
				throw SyntaxException.new(`The functions \(fragments) can't be distinguished when there is only one argument`, node)
			}
			else {
				throw SyntaxException.new(`The functions \(fragments) can't be distinguished when there are \(count) arguments`, node)
			}
		} # }}}
		throwInheritanceLoop(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`An inheritance loop is occurring the class "\(name)"`, node)
		} # }}}
		throwInvalidASTReification(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`AST parameter doesn't support reification`, node)
		} # }}}
		throwInvalidAwait(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`"await" can only be used in functions or binary module`, node)
		} # }}}
		throwInvalidBitmaskValue(data, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The bitmask's value isn't valid`, node, data)
		} # }}}
		throwInvalidEnumValue(data, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The enum's value isn't valid`, node, data)
		} # }}}
		throwInvalidFinallyReturn(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`No "return" statements are allowed in a "finally" block`, node)
		} # }}}
		throwInvalidForcedTypeCasting(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The forced type casting "!!" can't determine the expected type`, node)
		} # }}}
		throwInvalidFunctionReturn(function, expectedReturn, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Function "\(function)" is expected to return the type "\(expectedReturn)"`, node)
		} # }}}
		throwInvalidLateInitAssignment(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" can't be initialized by the statement at`, node)
		} # }}}
		throwInvalidMethodReturn(className, methodName, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Method "\(methodName)" of the class "\(className)" has an invalid return type`, node)
		} # }}}
		throwInvalidImportAliasArgument(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Aliases arguments can't be used with classic JavaScript module`, node)
		} # }}}
		throwInvalidIdentifier(value, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`"\(value)" is an invalid identifier`, node)
		} # }}}
		throwInvalidSyncMethods(className, methodName, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Method "\(methodName)" of the class "\(className)" can be neither sync nor async`, node)
		} # }}}
		throwInvalidRule(name, fileName, lineNumber): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The rule "\(name)" is invalid`, fileName, lineNumber)
		} # }}}
		throwLessAccessibleMethod(class, name, parameters, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The method "\(class.toQuote()).\(name)\(FunctionType.toQuote(parameters))" is less accessible than the overriden method`, node)
		} # }}}
		throwLessAccessibleVariable(class, name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The variable "\(class.toQuote()).\(name)" is less accessible than the overriden variable`, node)
		} # }}}
		throwLoopingImport(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The import "\(name)" is looping`, node)
		} # }}}
		throwMismatchedInclude(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Inclusions of "\(name)" should have the same version`, node)
		} # }}}
		throwMissingAbstractMethods(name, methods, node): Never ~ SyntaxException { # {{{
			var fragments = []

			for var methods, name of methods {
				for var method in methods {
					fragments.push(`"\(name)\(method.toQuote())"`)
				}
			}

			throw SyntaxException.new(`Class "\(name)" doesn't implement the following abstract method\(fragments.length > 1 ? 's' : ''): \(fragments.join(', '))`, node)
		} # }}}
		throwMissingAssignmentIfFalse(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" isn't fully initialized when the condition is false`, node)
		} # }}}
		throwMissingAssignmentIfNoElse(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" isn't fully initialized due to the missing "else" statement`, node)
		} # }}}
		throwMissingAssignmentIfTrue(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" isn't fully initialized when the condition is true`, node)
		} # }}}
		throwMissingAssignmentMatchClause(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" isn't fully initialized by the clause at`, node)
		} # }}}
		throwMissingAssignmentMatchNoDefault(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" isn't fully initialized due to the missing default clause`, node)
		} # }}}
		throwMissingAssignmentTryClause(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" isn't fully initialized by the clause at`, node)
		} # }}}
		throwMissingElseClause(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The 'match' is missing the "else" clause`, node)
		} # }}}
		throwMissingProperties(kind, name, interface, { fields, functions }, node): Never ~ SyntaxException { # {{{
			var mut message = `\(kind) "\(name)" doesn't implement `

			if ?#fields {
				var fragments = []

				for var type, name of fields {
					fragments.push(`"\(name): \(type.toQuote())"`)
				}

				message += `the following field\(fragments.length > 1 ? 's' : ''): \(fragments.join(', '))`
			}

			if ?#functions {
				if ?#fields {
					message += " and "
				}

				var fragments = []

				for var type, name of functions {
					fragments.push(`"\(name)\(type.toQuote())"`)
				}

				message += `the following method\(fragments.length > 1 ? 's' : ''): \(fragments.join(', '))`
			}

			message += ` of the type \(interface.toQuote())`

			throw SyntaxException.new(message, node)
		} # }}}
		throwMissingRequirement(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`import is missing the argument "\(name)"`, node)
		} # }}}
		throwMissingRequirement(argname, modname, node): Never ~ ReferenceException { # {{{
			throw TypeException.new(`The module "\(modname)" is missing the argument "\(argname)"`, node)
		} # }}}
		throwMissingStructField(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The field "\(name)" is missing to create the struct`, node)
		} # }}}
		throwMissingTupleField(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The field "\(name)" is missing to create the tuple`, node)
		} # }}}
		throwMixedOverloadedFunction(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Overloaded functions can't mix sync/async`, node)
		} # }}}
		throwNamedOnlyParameters(names: String[], node): Never ~ SyntaxException { # {{{
			if names.length == 1 {
				throw SyntaxException.new(`The parameter "\(names[0])" must be passed by name`, node)
			}
			else {
				throw SyntaxException.new(`The \($joinQuote(names)) parameters must be passed by name`, node)
			}
		} # }}}
		throwNoDefaultParameter(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Parameter can't have a default value`, node)
		} # }}}
		throwNoExport(module, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`No export can be found in module "\(module)"`, node)
		} # }}}
		throwNoNullParameter(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Parameter can't be nullable`, node)
		} # }}}
		throwNoOverridableConstructor(class, parameters, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The constructor "\(class.toQuote())\(FunctionType.toQuote(parameters))" can't override a suitable constructor`, node)
		} # }}}
		throwNoAssistableMethod(class, name, parameters, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The method "\(class.toQuote()).\(name)\(FunctionType.toQuote(parameters))" can't assist a suitable method`, node)
		} # }}}
		throwNoOverridableMethod(class, name, parameters, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The method "\(class.toQuote()).\(name)\(FunctionType.toQuote(parameters))" can't override a suitable method`, node)
		} # }}}
		throwNoRestParameter(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Parameter can't be a rest parameter`, node)
		} # }}}
		throwNoReturn(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The expression \(node.toQuote(true)) doesn't return a value.`, node)
		} # }}}
		throwNoSuitableOverwrite(class, name, type, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`"\(class.toQuote()).\(name)\(type.toQuote())" can't be matched to any suitable method to overwrite`, node)
		} # }}}
		throwNoSuperCall(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Call "super()" is missing`, node)
		} # }}}
		throwNotAbstractClass(className, methodName, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Method "\(methodName)" is abstract but the class "\(className)" is not`, node)
		} # }}}
		throwNotArrayInterface(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The interface "\(name)" is not an array`, node)
		} # }}}
		throwNotBinary(tag, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Binary file can't use "\(tag)" statement`, node)
		} # }}}
		throwNotCompatibleConstructor(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Parent's constructor of class "\(name)" can't be called`, node)
		} # }}}
		throwNotEnoughStructFields(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`There is not enough fields to create the struct`, node)
		} # }}}
		throwNotEnoughTupleFields(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`There is not enough fields to create the tuple`, node)
		} # }}}
		throwNotFullyInitializedVariable(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" is only partially initialized`, node)
		} # }}}
		throwNotInitializedField(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The class variable "\(name)" isn't initialized`, node)
		} # }}}
		throwNotInitializedFields(names, node): Never ~ SyntaxException { # {{{
			if names.length == 1 {
				throw SyntaxException.new(`The class variable "\(names[0])" isn't initialized`, node)
			}
			else {
				throw SyntaxException.new(`The class variables \($joinQuote(names, 'and')) aren't initialized`, node)
			}
		} # }}}
		throwNotInitializedVariable(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The lateinit variable "\(name)" isn't initialized`, node)
		} # }}}
		throwNotMatchedPossibilities(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The 'match' doesn't match all possible values of the tested value`, node)
		} # }}}
		throwNotMatchedPossibilities(values, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The 'match' doesn't match the following values: \($joinQuote(values))`, node)
		} # }}}
		throwNotNamedParameter(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Parameter must be named`, node)
		} # }}}
		throwNotObjectInterface(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The interface "\(name)" is not an object`, node)
		} # }}}
		throwNotOverloadableFunction(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Variable "\(name)" is not an overloadable function`, node)
		} # }}}
		throwNotSealedOverwrite(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`A method can be overwritten only in a sealed class`, node)
		} # }}}
		throwNotYetDefined(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The variable "\(name)" isn't yet defined`, node)
		} # }}}
		throwOnlyStaticImport(modname, node): Never ~ SyntaxException { # {{{
			throw TypeException.new(`The arguments of the module "\(modname)" must have unmodified types`, node)
		} # }}}
		throwOnlyStaticImport(argname, modname, node): Never ~ SyntaxException { # {{{
			throw TypeException.new(`The argument "\(argname)" of the module "\(modname)" must have an unmodified type`, node)
		} # }}}
		throwOnlyThisScope(node): Never ~ SyntaxException { # {{{
			throw TypeException.new(`A method can only be curried with "^@"`, node)
		} # }}}
		throwPositionalOnlyParameter(name: String, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The parameter "\(name)" must be passed by position`, node)
		} # }}}
		throwReservedStaticMethod(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The class method "\(name)" is reserved`, node)
		} # }}}
		throwReservedStaticVariable(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The class variable "\(name)" is reserved`, node)
		} # }}}
		throwReservedThisVariable(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The variable "this" is reserved`, node)
		} # }}}
		throwShadowFunction(name, function, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The function "\(name)\(function.toQuote())" is been concealed by others functions`, node)
		} # }}}
		throwTooMuchAttributesForIfAttribute(): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Expected 1 argument for 'if' attribute`)
		} # }}}
		throwTooMuchStructFields(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`There is too much fields to create the struct`, node)
		} # }}}
		throwTooMuchTupleFields(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`There is too much fields to create the tuple`, node)
		} # }}}
		throwTooMuchRestParameter(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Rest parameter has already been declared`, node)
		} # }}}
		throwUnexpectedAlias(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Alias "@\(name)" is expected in an instance method/variable`, node)
		} # }}}
		throwUnmatchedImportArguments(names, node): Never ~ SyntaxException { # {{{
			var fragments = [`"\(name)"` for var name in names]

			throw SyntaxException.new(`The import can't match the argument\(fragments.length > 1 ? 's' : ''): \(fragments.join(', '))`, node)
		} # }}}
		throwUnmatchVariable(class, interface, varname, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The variable "\(varname)" doesn't match the one of \(interface.toQuote(true))`, node)
		} # }}}
		throwUnnamedWildcardImport(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`Wilcard import can't be named`, node)
		} # }}}
		throwUnrecognizedStructField(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The argument "\(name)" isn't recognized to create the struct`, node)
		} # }}}
		throwUnrecognizedTupleField(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The argument "\(name)" isn't recognized to create the tuple`, node)
		} # }}}
		throwUnreportedError(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`An error is unreported, it must be caught or declared to be thrown`, node)
		} # }}}
		throwUnreportedError(name, node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`An error "\(name)" is unreported, it must be caught or declared to be thrown`, node)
		} # }}}
		throwUnsupportedDestructuringArray(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`An optional element must be last in a destructuring array.`, node)
		} # }}}
		throwUnsupportedDestructuringAssignment(node): Never ~ SyntaxException { # {{{
			throw SyntaxException.new(`The current destructuring assignment is unsupported`, node)
		} # }}}
	}
}

export class TargetException extends Exception {
	static {
		throwNotSupported(target, node): Never ~ TargetException { # {{{
			throw TargetException.new(`The target "\(target.name)-v\(target.version)" isn't supported`, node)
		} # }}}
	}
}

export class TypeException extends Exception {
	static {
		throwAbstractInstantiation(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Class "\(name)" is abstract so it can't be instantiated`, node)
		} # }}}
		throwConstructorWithoutNew(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Class constructor "\(name)" cannot be invoked without 'new'`, node)
		} # }}}
		throwExpectedReturnedValue(type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`A value of type \(type.toQuote(true)) is expected to be returned`, node)
		} # }}}
		throwExpectedThrownError(node): Never ~ TypeException { # {{{
			throw TypeException.new(`An error is expected to be thrown`, node)
		} # }}}
		throwExpectedType(expression, type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression "\(expression)" is expected to be of type "\(type)"`, node)
		} # }}}
		throwInvalidInstantiation(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Class "\(name)" can't be instantiated`, node)
		} # }}}
		throwImplFieldToSealedType(node): Never ~ TypeException { # {{{
			throw TypeException.new(`impl can add field to only non-sealed type`, node)
		} # }}}
		throwImplInvalidField(name: String, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Class "\(name)" doesn't accept new field`, node)
		} # }}}
		throwImplInvalidInstanceMethod(name: String, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Class "\(name)" doesn't accept new instance method`, node)
		} # }}}
		throwImplInvalidStaticMethod(name: String, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Class "\(name)" doesn't accept new static method`, node)
		} # }}}
		throwImplInvalidType(node): Never ~ TypeException { # {{{
			throw TypeException.new(`impl has an invalid type`, node)
		} # }}}
		throwIncompatible(type1: Type, type2: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The types \(type1.toQuote(true)) and \(type2.toQuote(true)) aren't compatible`, node)
		} # }}}
		throwInvalid(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Invalid type "\(name)"`, node)
		} # }}}
		throwInvalidArgument(statement: String, argument: String, expectedType: Type, foundType: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`In the statement "\(statement)", the argument "\(argument)" must be of type \(expectedType.toQuote(true)) and not \(foundType.toQuote(true))`, node)
		} # }}}
		throwInvalidAssignment(declaredType: Type, valueType: Type, node): Never ~ TypeException { # {{{
			if valueType.isNull() {
				throw TypeException.new(`The variable of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw TypeException.new(`The variable of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} # }}}
		throwInvalidAssignment(name: String, declaredType: Type, valueType: Type, node): Never ~ TypeException { # {{{
			if valueType.isNull() {
				throw TypeException.new(`The variable "\(name)" of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw TypeException.new(`The variable "\(name)" of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} # }}}
		throwInvalidAssignment(name: AbstractNode, declaredType: Type, valueType: Type, node): Never ~ TypeException { # {{{
			if valueType.isNull() {
				throw TypeException.new(`The variable \(name.toQuote(true)) of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw TypeException.new(`The variable \(name.toQuote(true)) of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} # }}}
		throwInvalidBinding(expected, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The binding is expected to be of type "\(expected)"`, node)
		} # }}}
		throwInvalidCasting(node): Never ~ TypeException { # {{{
			throw TypeException.new(`Only variables can be casted`, node)
		} # }}}
		throwInvalidComparison(left: AbstractNode, right: AbstractNode, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(left.toQuote(true)) of type \(left.toTypeQuote(true)) can't be compared to a value of type \(right.toTypeQuote(true))`, node)
		} # }}}
		throwInvalidComprehensionType(expected: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`An array comprehension can't be of type \(expected.toQuote(true))`, node)
		} # }}}
		throwInvalidCondition(expression, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The condition \(expression.toQuote(true)) of type \(expression.toTypeQuote(true)) is expected to be of type "Boolean"`, node)
		} # }}}
		throwInvalidForInExpression(node): Never ~ TypeException { # {{{
			throw TypeException.new(`"for..in" must be used with an array`, node)
		} # }}}
		throwInvalidForOfExpression(node): Never ~ TypeException { # {{{
			throw TypeException.new(`"for..of" must be used with an object`, node)
		} # }}}
		throwInvalidFunctionType(expected: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The function can't be of type \(expected.toQuote(true))`, node)
		} # }}}
		throwInvalidIdentifierType(name: String, current: Type, expected: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The identifier "\(name)" of type \(current.toQuote(true)) is expected to be of type \(expected.toQuote(true))`, node)
		} # }}}
		throwInvalidLiteralType(value: String, current: Type, expected: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The literal \(value) of type \(current.toQuote(true)) is expected to be of type \(expected.toQuote(true))`, node)
		} # }}}
		throwInvalidObjectKeyType(current: Type, expected: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The object's key of type \(current.toQuote(true)) is expected to be of type \(expected.toQuote(true))`, node)
		} # }}}
		throwInvalidOperand(expression, operator, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(expression.toQuote(true)) of type \(expression.type().toQuote(true)) is expected to be of type \($joinQuote($operatorTypes[operator]))`, node)
		} # }}}
		throwInvalidOperation(expression, operator, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The elements of \(expression.toQuote(true)) are expected to be of type \($joinQuote($operatorTypes[operator]))`, node)
		} # }}}
		throwInvalidParameterType(current: Type, expected: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The parameter \(current.toQuote(true)) is expected to be of type \(expected.toQuote(true))`, node)
		} # }}}
		throwInvalidSpread(node): Never ~ TypeException { # {{{
			throw TypeException.new(`Spread operator require an array`, node)
		} # }}}
		throwInvalidTypeChecking(expression, type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The variable \(expression.toQuote(true)) of type \(expression.type().discardValue().toQuote(true)) can never be of type \(type.toQuote(true))`, node)
		} # }}}
		throwNotAlien(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The type "\(name)" must be declared externally`, node)
		} # }}}
		throwNotAsyncFunction(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The function "\(name)" is not asynchronous`, node)
		} # }}}
		throwNotBooleanVariant(expression: Expression, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(expression.toQuote(true)) is not a boolean variant`, node)
		} # }}}
		throwNotCastableTo(valueType: Type, castingType: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The type \(valueType.toQuote(true)) can't be casted as a \(castingType.toQuote(true))`, node)
		} # }}}
		throwNotClass(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not a class`, node)
		} # }}}
		throwNotCompatibleArgument(argname, modname, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The argument "\(argname)" of the module "\(modname)" isn't compatible`, node)
		} # }}}
		throwNotCompatibleArgument(varname, argname, modname, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The variable "\(varname)" and the argument "\(argname)" of the module "\(modname)" aren't compatible`, node)
		} # }}}
		throwNotCompatibleDefinition(varname, argname, modname, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The definition for "\(varname)" and the variable "\(argname)" of the module "\(modname)" aren't compatible`, node)
		} # }}}
		throwNotCreatable(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`No instance can be created from "\(name)"`, node)
		} # }}}
		throwNotEnum(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not an enum`, node)
		} # }}}
		throwNotFunction(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not a function`, node)
		} # }}}
		throwNotIterable(expression, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(expression.toQuote(true)) of type \(expression.type().toQuote(true)) isn't of an iterable type`, node)
		} # }}}
		throwNotNamespace(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not a namespace`, node)
		} # }}}
		throwNotNullableCaller(property, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The caller of "\(property)" can't be nullable`, node)
		} # }}}
		throwNotNullableExistential(expression, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The existential test of \(expression.toQuote(true)) is always positive`, node)
		} # }}}
		throwNotNullableMemberAccess(expression, property, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(expression.toQuote(true)) can't be nullable to access the property \(property)`, node)
		} # }}}
		throwNotNullableOperand(expression, operator, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The operand \(expression.toQuote(true)) can't be nullable in a \(operator) operation`, node)
		} # }}}
		throwNotNumber(expression: Expression, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(expression.toQuote(true)) is not a number`, node)
		} # }}}
		throwNotRetypeableTo(valueType: Type, castingType: Type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The type \(valueType.toQuote(true)) can't be retyped as a \(castingType.toQuote(true))`, node)
		} # }}}
		throwNotStruct(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not a struct`, node)
		} # }}}
		throwNotSyncFunction(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The function "\(name)" is not synchronous`, node)
		} # }}}
		throwNotTuple(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not a tuple`, node)
		} # }}}
		throwNotType(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not a type`, node)
		} # }}}
		throwNotUniqueValue(expression, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(expression.toQuote(true)) isn't an unique value`, node)
		} # }}}
		throwNotVariant(name: String, node): Never ~ TypeException { # {{{
			throw TypeException.new(`Identifier "\(name)" is not a variant`, node)
		} # }}}
		throwNullTypeChecking(type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The variable is "null" and can't be checked against the type \(type.toQuote(true))`, node)
		} # }}}
		throwNullTypeVariable(name, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The variable "\(name)" can't be of type "Null"`, node)
		} # }}}
		throwRequireClass(node): Never ~ TypeException { # {{{
			throw TypeException.new(`An instance is required`, node)
		} # }}}
		throwUndeterminedVariantType(type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The variant of type "\(type)" hasn't been determinated`, node)
		} # }}}
		throwUnexpectedExportType(name, expected, unexpected, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The type of export "\(name)" must be \(expected.toQuote(true)) and not \(unexpected.toQuote(true))`, node)
		} # }}}
		throwUnexpectedExpression(expression, target, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The expression \(expression.toQuote(true)) is expected to be of type \(target.toQuote(true))`, node)
		} # }}}
		throwUnexpectedInoperative(operand, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The operand \(operand.toQuote(true)) can't be of type \(operand.type().toQuote(true))`, node)
		} # }}}
		throwUnexpectedReturnedValue(node): Never ~ TypeException { # {{{
			throw TypeException.new(`No values are expected to be returned`, node)
		} # }}}
		throwUnexpectedReturnType(expected, unexpected, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The return type must be \(expected.toQuote(true)) and not \(unexpected.toQuote(true))`, node)
		} # }}}
		throwUnnecessaryCondition(expression, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The condition \(expression.toQuote(true)) has always the value \(expression.type().toQuote(true))`, node)
		} # }}}
		throwUnnecessaryTypeChecking(expression, type, node): Never ~ TypeException { # {{{
			throw TypeException.new(`The variable \(expression.toQuote(true)) is always of type \(type.toQuote(true))`, node)
		} # }}}
	}
}
