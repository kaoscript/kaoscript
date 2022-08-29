extern sealed class Error

Error.prepareStackTrace = func(error: Error, stack: Array) { # {{{
	var mut message = error.toString()

	for i from 0 til Math.min(12, stack.length) {
		message += '\n    ' + stack[i].toString()
	}

	return message
} # }}}

func $joinQuote(values: String[]): String { # {{{
	var last = values.length - 1

	if last > 0 {
		var mut result = '"'

		for var value, index in values {
			if index == last {
				result += '" or "'
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

						for name in hierarchy while nf {
							if options.ignore:Array.contains(name) {
								nf = false
							}
						}

						if nf {
							SyntaxException.throwUnreportedError(error.name(), node)
						}
						else if options.raise.length != 0 {
							for name in hierarchy {
								if options.raise:Array.contains(name) {
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
			throw new IOException(`The file "\(path)" can't be found`, node)
		} # }}}
		throwNotFoundFile(path, directory, node): Never ~ IOException { # {{{
			throw new IOException(`The file "\(path)" can't be found in the directory "\(directory)"`, node)
		} # }}}
		throwNotFoundModule(name, node): Never ~ IOException { # {{{
			throw new IOException(`The module "\(name)" can't be found`, node)
		} # }}}
		throwNotFoundModule(name, directory, node): Never ~ IOException { # {{{
			throw new IOException(`The module "\(name)" can't be found in the directory "\(directory)"`, node)
		} # }}}
	}
}

export class NotImplementedException extends Exception {
	static {
		throw(...arguments): Never ~ NotImplementedException { # {{{
			throw new NotImplementedException(...arguments)
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
			throw new NotSupportedException(...arguments)
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
		throwAlreadyDefinedField(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`Field "\(name)" is already defined by its parent class`, node)
		} # }}}
		throwBindingExceedArray(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The destructuring variable "\(name)" can't be matched`, node)
		} # }}}
		throwConfusingArguments(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The arguments (indexed/named) can be matched to the function "\(name)" in multiple ways`, node)
		} # }}}
		throwDefined(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`"\(name)" should not be defined`, node)
		} # }}}
		throwImmutable(name: String, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The identifier "\(name)" is immutable`, node)
		} # }}}
		throwImmutable(node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The expression "\(node.toQuote())" is immutable`, node)
		} # }}}
		throwImmutableField(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The class variable "\(name)" is immutable`, node)
		} # }}}
		throwIncompleteVariable(argname, modname, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The variable "\(argname)" must be complete before passing it to the module "\(modname)"`, node)
		} # }}}
		throwInvalidAssignment(node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`Any value can't be assigned to the expression \(node.toQuote(true))`, node)
		} # }}}
		throwLoopingAlias(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`Alias "@\(name)" is looping on itself`, node)
		} # }}}
		throwNoMatchingConstructor(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The constructor of class "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The constructor of class "\(name)" can't be matched to given arguments (\([`\(argument.type().toQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingFunction(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The function "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The function "\(name)" can't be matched to given arguments (\([`\(argument.toTypeQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingFunctionInNamespace(name, namespace, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The function "\(name)" in namespace \(namespace.toQuote(true)) can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The function "\(name)" in namespace \(namespace.toQuote(true)) can't be matched to given arguments (\([`\(argument.type().toQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingClassMethod(method, class, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The method "\(method)" of the class "\(class)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The method "\(method)" of the class "\(class)" can't be matched to given arguments (\([`\(argument.toQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingEnumMethod(method, enum, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The method "\(method)" of the enum "\(enum)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The method "\(method)" of the enum "\(enum)" can't be matched to given arguments (\([`\(argument.toQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwUnrecognizedNamedArgument(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The argument "\(name)" isn't recognized`, node)
		} # }}}
		throwNoMatchingStruct(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The struct "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The struct "\(name)" can't be matched to given arguments (\([`\(argument.type().toQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNoMatchingTuple(name, arguments, node): Never ~ ReferenceException { # {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The tuple "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The tuple "\(name)" can't be matched to given arguments (\([`\(argument.type().toQuote())` for var argument in arguments].join(', ')))`, node)
			}
		} # }}}
		throwNotDefined(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`"\(name)" is not defined`, node)
		} # }}}
		throwNotDefinedEnumElement(element, enum, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`Element "\(element)" is not defined in enum "\(enum)"`, node)
		} # }}}
		throwNotDefinedInModule(name, module, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`"\(name)" is not defined in the module "\(module)"`, node)
		} # }}}
		throwNotDefinedMember(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`Member "\(name)" is not defined`, node)
		} # }}}
		throwNotDefinedProperty(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`Property "\(name)" is not defined`, node)
		} # }}}
		throwNotDefinedType(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`Type "\(name)" is not defined`, node)
		} # }}}
		throwNotExportable(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The exported variable "\(name)" is not exportable`, node)
		} # }}}
		throwNotFoundClassMethod(method, class, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The method "\(method)" can't be found in the class "\(class)"`, node)
		} # }}}
		throwNotFoundEnumMethod(method, enum, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The method "\(method)" can't be found in the enum "\(enum)"`, node)
		} # }}}
		throwNotPassed(name, module, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`To overwrite "\(name)", it needs to be passed to the module "\(module)"`, node)
		} # }}}
		throwNullableAlias(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`An alias can't be null`, node)
		} # }}}
		throwNullExpression(expression, node): Never ~ TypeException { # {{{
			throw new ReferenceException(`The expression \(expression.toQuote(true)) is "null"`, node)
		} # }}}
		throwUndefinedBindingVariable(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The destructuring variable "\(name)" can't be matched`, node)
		} # }}}
		throwUndefinedClassField(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The class field "\(name)" isn't defined`, node)
		} # }}}
		throwUndefinedInstanceField(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The instance field "\(name)" isn't defined`, node)
		} # }}}
		throwUndefinedFunction(name, node): Never ~ ReferenceException { # {{{
			throw new ReferenceException(`The function "\(name)" can't be found`, node)
		} # }}}
	}
}

export class SyntaxException extends Exception {
	static {
		throwAfterDefaultClause(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Clause is must be before the default clause`, node)
		} # }}}
		throwAfterRestParameter(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Parameter must be before the rest parameter`, node)
		} # }}}
		throwAlreadyDeclared(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Identifier "\(name)" has already been declared`, node)
		} # }}}
		throwAlreadyImported(name, module, line, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The variable "\(name)" has already been imported by "\(module)" at line \(line)`, node)
		} # }}}
		throwDeadCode(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Dead code`, node)
		} # }}}
		throwDeadCodeParameter(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`A parameter's default value must be "null" when its type is "required" and "nullable"`, node)
		} # }}}
		throwDeadCodeParameter(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The default value of parameter "\(name)" must be "null" when its type is "required" and "nullable"`, node)
		} # }}}
		throwDuplicateConstructor(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The constructor is matching an existing constructor`, node)
		} # }}}
		throwDuplicateKey(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Duplicate key has been found in object`, node)
		} # }}}
		throwDuplicateMethod(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The method "\(name)" is matching an existing method`, node)
		} # }}}
		throwEnumOverflow(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The bit flags enum "\(name)" can only have at most 53 bits.`, node)
		} # }}}
		throwExcessiveRequirement(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The import don't require the argument "\(name)"`, node)
		} # }}}
		throwHiddenMethod(name, class1, method1, class2, method2, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The method "\(class1.toQuote()).\(name)\(method1.toQuote())" hides the method "\(class2.toQuote()).\(name)\(method2.toQuote())"`, node)
		} # }}}
		throwIdenticalConstructor(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The constructor is identical with another constructor`, node)
		} # }}}
		throwIdenticalFunction(name, type, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The function "\(name)\(type.toQuote())" is a duplicate`, node)
		} # }}}
		throwIdenticalMethod(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The method "\(name)" is matching another method with the same types of parameters`, node)
		} # }}}
		throwIllegalStatement(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The statement "\(name)" is illegal`, node)
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

			throw new SyntaxException(`The functions \(fragments) can't be distinguished`, node)
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
				throw new SyntaxException(`When there are no arguments, \(fragments)`, node)
			}
			else {
				throw new SyntaxException(`When the arguments are \(args), \(fragments)`, node)
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
				throw new SyntaxException(`The functions \(fragments) can't be distinguished when there are no arguments`, node)
			}
			else if count == 1 {
				throw new SyntaxException(`The functions \(fragments) can't be distinguished when there is only one argument`, node)
			}
			else {
				throw new SyntaxException(`The functions \(fragments) can't be distinguished when there are \(count) arguments`, node)
			}
		} # }}}
		throwInheritanceLoop(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`An inheritance loop is occurring the class "\(name)"`, node)
		} # }}}
		throwInvalidAwait(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`"await" can only be used in functions or binary module`, node)
		} # }}}
		throwInvalidEnumAccess(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Accessing an enum can only be done with "::"`, node)
		} # }}}
		throwInvalidEnumValue(data, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The enum's value isn't valid`, node, data)
		} # }}}
		throwInvalidForcedTypeCasting(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The forced type casting "!!" can't determine the expected type`, node)
		} # }}}
		throwInvalidLateInitAssignment(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" can't be initialized by the statement at`, node)
		} # }}}
		throwInvalidMethodReturn(className, methodName, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Method "\(methodName)" of the class "\(className)" has an invalid return type`, node)
		} # }}}
		throwInvalidImportAliasArgument(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Aliases arguments can't be used with classic JavaScript module`, node)
		} # }}}
		throwInvalidIdentifier(value, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`"\(value)" is an invalid identifier`, node)
		} # }}}
		throwInvalidSyncMethods(className, methodName, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Method "\(methodName)" of the class "\(className)" can be neither sync nor async`, node)
		} # }}}
		throwInvalidRule(name, fileName, lineNumber): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The rule "\(name)" is invalid`, fileName, lineNumber)
		} # }}}
		throwLoopingImport(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The import "\(name)" is looping`, node)
		} # }}}
		throwMismatchedInclude(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Inclusions of "\(name)" should have the same version`, node)
		} # }}}
		throwMissingAbstractMethods(name, methods, node): Never ~ SyntaxException { # {{{
			var fragments = []

			for var methods, name of methods {
				for var method in methods {
					fragments.push(`"\(name)\(method.toQuote())"`)
				}
			}

			throw new SyntaxException(`Class "\(name)" doesn't implement the following abstract method\(fragments.length > 1 ? 's' : ''): \(fragments.join(', '))`, node)
		} # }}}
		throwMissingAssignmentIfFalse(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized when the condition is false`, node)
		} # }}}
		throwMissingAssignmentIfNoElse(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized due to the missing "else" statement`, node)
		} # }}}
		throwMissingAssignmentIfTrue(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized when the condition is true`, node)
		} # }}}
		throwMissingAssignmentSwitchClause(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized by the clause at`, node)
		} # }}}
		throwMissingAssignmentSwitchNoDefault(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized due to the missing default clause`, node)
		} # }}}
		throwMissingRequirement(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`import is missing the argument "\(name)"`, node)
		} # }}}
		throwMissingRequirement(argname, modname, node): Never ~ ReferenceException { # {{{
			throw new TypeException(`The module "\(modname)" is missing the argument "\(argname)"`, node)
		} # }}}
		throwMissingStructField(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The field "\(name)" is missing to create the struct`, node)
		} # }}}
		throwMissingTupleField(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The field "\(name)" is missing to create the tuple`, node)
		} # }}}
		throwMixedOverloadedFunction(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Overloaded functions can't mix sync/async`, node)
		} # }}}
		throwNamedOnlyParameters(names: String[], node): Never ~ SyntaxException { # {{{
			if names.length == 1 {
				throw new SyntaxException(`The parameter "\(names[0])" must be passed by name`, node)
			}
			else {
				throw new SyntaxException(`The \($joinQuote(names)) parameters must be passed by name`, node)
			}
		} # }}}
		throwNoDefaultParameter(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Parameter can't have a default value`, node)
		} # }}}
		throwNoExport(module, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`No export can be found in module "\(module)"`, node)
		} # }}}
		throwNoNullParameter(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Parameter can't be nullable`, node)
		} # }}}
		throwNoOverridableConstructor(class, parameters, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The constructor "\(class.toQuote())\(FunctionType.toQuote(parameters))" can't override a suitable constructor`, node)
		} # }}}
		throwNoOverridableMethod(class, name, parameters, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The method "\(class.toQuote()).\(name)\(FunctionType.toQuote(parameters))" can't override a suitable method`, node)
		} # }}}
		throwNoRestParameter(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Parameter can't be a rest parameter`, node)
		} # }}}
		throwNoReturn(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The expression \(node.toQuote(true)) doesn't return a value.`, node)
		} # }}}
		throwNoSuitableOverwrite(class, name, type, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`"\(class.toQuote()).\(name)\(type.toQuote())" can't be matched to any suitable method to overwrite`, node)
		} # }}}
		throwNoSuperCall(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Call "super()" is missing`, node)
		} # }}}
		throwNotAbstractClass(className, methodName, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Method "\(methodName)" is abstract but the class "\(className)" is not`, node)
		} # }}}
		throwNotBinary(tag, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Binary file can't use "\(tag)" statement`, node)
		} # }}}
		throwNotCompatibleConstructor(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Parent's constructor of class "\(name)" can't be called`, node)
		} # }}}
		throwNotEnoughStructFields(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`There is not enough fields to create the struct`, node)
		} # }}}
		throwNotEnoughTupleFields(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`There is not enough fields to create the tuple`, node)
		} # }}}
		throwNotFullyInitializedVariable(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" is only partially initialized`, node)
		} # }}}
		throwNotInitializedField(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The class variable "\(name)" isn't initialized`, node)
		} # }}}
		throwNotInitializedVariable(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't initialized`, node)
		} # }}}
		throwNotNamedParameter(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Parameter must be named`, node)
		} # }}}
		throwNotOverloadableFunction(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Variable "\(name)" is not an overloadable function`, node)
		} # }}}
		throwNotSealedOverwrite(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`A method can be overwritten only in a sealed class`, node)
		} # }}}
		throwOnlyStaticImport(modname, node): Never ~ ReferenceException { # {{{
			throw new TypeException(`The arguments of the module "\(modname)" must have unmodified types`, node)
		} # }}}
		throwOnlyStaticImport(argname, modname, node): Never ~ ReferenceException { # {{{
			throw new TypeException(`The argument "\(argname)" of the module "\(modname)" must have an unmodified type`, node)
		} # }}}
		throwPositionalOnlyParameter(name: String, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The parameter "\(name)" must be passed by position`, node)
		} # }}}
		throwReservedClassMethod(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The class method "\(name)" is reserved`, node)
		} # }}}
		throwReservedClassVariable(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The class variable "\(name)" is reserved`, node)
		} # }}}
		throwShadowFunction(name, function, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The function "\(name)\(function.toQuote())" is been concealed by others functions`, node)
		} # }}}
		throwTooMuchAttributesForIfAttribute(): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Expected 1 argument for 'if' attribute`)
		} # }}}
		throwTooMuchStructFields(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`There is too much fields to create the struct`, node)
		} # }}}
		throwTooMuchTupleFields(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`There is too much fields to create the tuple`, node)
		} # }}}
		throwTooMuchRestParameter(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Rest parameter has already been declared`, node)
		} # }}}
		throwUnexpectedAlias(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Alias "@\(name)" is expected in an instance method/variable`, node)
		} # }}}
		throwUnmatchedImportArguments(names, node): Never ~ SyntaxException { # {{{
			var fragments = [`"\(name)"` for var name in names]

			throw new SyntaxException(`The import can't match the argument\(fragments.length > 1 ? 's' : ''): \(fragments.join(', '))`, node)
		} # }}}
		throwUnmatchedMacro(name, node, data): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The macro "\(name)" can't be matched`, node, data)
		} # }}}
		throwUnnamedWildcardImport(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`Wilcard import can't be named`, node)
		} # }}}
		throwUnrecognizedStructField(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The argument "\(name)" isn't recognized to create the struct`, node)
		} # }}}
		throwUnrecognizedTupleField(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The argument "\(name)" isn't recognized to create the tuple`, node)
		} # }}}
		throwUnreportedError(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`An error is unreported, it must be caught or declared to be thrown`, node)
		} # }}}
		throwUnreportedError(name, node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`An error "\(name)" is unreported, it must be caught or declared to be thrown`, node)
		} # }}}
		throwUnsupportedDestructuringAssignment(node): Never ~ SyntaxException { # {{{
			throw new SyntaxException(`The current destructuring assignment is unsupported`, node)
		} # }}}
	}
}

export class TargetException extends Exception {
	static {
		throwNotSupported(target, node): Never ~ TargetException { # {{{
			throw new TargetException(`The target "\(target.name)-v\(target.version)" isn't supported`, node)
		} # }}}
	}
}

export class TypeException extends Exception {
	static {
		throwCannotBeInstantiated(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Class "\(name)" is abstract so it can't be instantiated`, node)
		} # }}}
		throwConstructorWithoutNew(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Class constructor "\(name)" cannot be invoked without 'new'`, node)
		} # }}}
		throwExpectedReturnedValue(type, node): Never ~ TypeException { # {{{
			throw new TypeException(`A value of type \(type.toQuote(true)) is expected to be returned`, node)
		} # }}}
		throwExpectedThrownError(node): Never ~ TypeException { # {{{
			throw new TypeException(`An error is expected to be thrown`, node)
		} # }}}
		throwImplFieldToSealedType(node): Never ~ TypeException { # {{{
			throw new TypeException(`impl can add field to only non-sealed type`, node)
		} # }}}
		throwImplInvalidType(node): Never ~ TypeException { # {{{
			throw new TypeException(`impl has an invalid type`, node)
		} # }}}
		throwInvalid(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Invalid type "\(name)"`, node)
		} # }}}
		throwInvalidAssignement(declaredType: Type, valueType: Type, node): Never ~ TypeException { # {{{
			if valueType.isNull() {
				throw new TypeException(`The variable of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw new TypeException(`The variable of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} # }}}
		throwInvalidAssignement(name: String, declaredType: Type, valueType: Type, node): Never ~ TypeException { # {{{
			if valueType.isNull() {
				throw new TypeException(`The variable "\(name)" of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw new TypeException(`The variable "\(name)" of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} # }}}
		throwInvalidAssignement(name: AbstractNode, declaredType: Type, valueType: Type, node): Never ~ TypeException { # {{{
			if valueType.isNull() {
				throw new TypeException(`The variable \(name.toQuote(true)) of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw new TypeException(`The variable \(name.toQuote(true)) of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} # }}}
		throwInvalidBinding(expected, node): Never ~ TypeException { # {{{
			throw new TypeException(`The binding is expected to be of type "\(expected)"`, node)
		} # }}}
		throwInvalidCasting(node): Never ~ TypeException { # {{{
			throw new TypeException(`Only variables can be casted`, node)
		} # }}}
		throwInvalidComparison(left: AbstractNode, right: AbstractNode, node): Never ~ TypeException { # {{{
			throw new TypeException(`The expression \(left.toQuote(true)) of type \(left.type().toQuote(true)) can't be compared to a value of type \(right.type().toQuote(true))`, node)
		} # }}}
		throwInvalidComprehensionType(expected: Type, node): Never ~ TypeException { # {{{
			throw new TypeException(`An array comprehension can't be of type \(expected.toQuote(true))`, node)
		} # }}}
		throwInvalidCondition(expression, node): Never ~ TypeException { # {{{
			throw new TypeException(`The condition \(expression.toQuote(true)) of type \(expression.type().toQuote(true)) is expected to be of type "Boolean"`, node)
		} # }}}
		throwInvalidForInExpression(node): Never ~ TypeException { # {{{
			throw new TypeException(`"for..in" must be used with an array`, node)
		} # }}}
		throwInvalidForOfExpression(node): Never ~ TypeException { # {{{
			throw new TypeException(`"for..of" must be used with a dictionary`, node)
		} # }}}
		throwInvalidOperand(expression, operator, node): Never ~ TypeException { # {{{
			throw new TypeException(`The expression \(expression.toQuote(true)) of type \(expression.type().toQuote(true)) is expected to be of type \($joinQuote($operatorTypes[operator]))`, node)
		} # }}}
		throwInvalidOperation(expression, operator, node): Never ~ TypeException { # {{{
			throw new TypeException(`The elements of \(expression.toQuote(true)) are expected to be of type \($joinQuote($operatorTypes[operator]))`, node)
		} # }}}
		throwInvalidSpread(node): Never ~ TypeException { # {{{
			throw new TypeException(`Spread operator require an array`, node)
		} # }}}
		throwInvalidTypeChecking(left, right, node): Never ~ TypeException { # {{{
			throw new TypeException(`The variable of type \(left.toQuote(true)) can never be of type \(right.toQuote(true))`, node)
		} # }}}
		throwNotAlien(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`The type "\(name)" must be declared externally`, node)
		} # }}}
		throwNotAsyncFunction(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`The function "\(name)" is not asynchronous`, node)
		} # }}}
		throwNotCastableTo(valueType: Type, castingType: Type, node): Never ~ TypeException { # {{{
			throw new TypeException(`The type \(valueType.toQuote(true)) can't be casted as a \(castingType.toQuote(true))`, node)
		} # }}}
		throwNotClass(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Identifier "\(name)" is not a class`, node)
		} # }}}
		throwNotCompatibleArgument(argname, modname, node): Never ~ ReferenceException { # {{{
			throw new TypeException(`The argument "\(argname)" of the module "\(modname)" isn't compatible`, node)
		} # }}}
		throwNotCompatibleArgument(varname, argname, modname, node): Never ~ ReferenceException { # {{{
			throw new TypeException(`The variable "\(varname)" and the argument "\(argname)" of the module "\(modname)" aren't compatible`, node)
		} # }}}
		throwNotCompatibleDefinition(varname, argname, modname, node): Never ~ ReferenceException { # {{{
			throw new TypeException(`The definition for "\(varname)" and the variable "\(argname)" of the module "\(modname)" aren't compatible`, node)
		} # }}}
		throwNotEnum(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Identifier "\(name)" is not an enum`, node)
		} # }}}
		throwNotIterable(expression, node): Never ~ TypeException { # {{{
			throw new TypeException(`The non-emptiness test of \(expression.toQuote(true)) is always negative`, node)
		} # }}}
		throwNotNamespace(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Identifier "\(name)" is not a namespace`, node)
		} # }}}
		throwNotNullableExistential(expression, node): Never ~ TypeException { # {{{
			throw new TypeException(`The existential test of \(expression.toQuote(true)) is always positive`, node)
		} # }}}
		throwNotNullableOperand(expression, operator, node): Never ~ TypeException { # {{{
			throw new TypeException(`The operand \(expression.toQuote(true)) can't be nullable in a \(operator) operation`, node)
		} # }}}
		throwNotStruct(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Identifier "\(name)" is not a struct`, node)
		} # }}}
		throwNotTuple(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`Identifier "\(name)" is not a tuple`, node)
		} # }}}
		throwNotSyncFunction(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`The function "\(name)" is not synchronous`, node)
		} # }}}
		throwNullableCaller(property, node): Never ~ TypeException { # {{{
			throw new TypeException(`The caller of "\(property)" can't be nullable`, node)
		} # }}}
		throwNullTypeChecking(type, node): Never ~ TypeException { # {{{
			throw new TypeException(`The variable is "null" and can't be checked against the type \(type.toQuote(true))`, node)
		} # }}}
		throwNullTypeVariable(name, node): Never ~ TypeException { # {{{
			throw new TypeException(`The variable "\(name)" can't be of type "Null"`, node)
		} # }}}
		throwRequireClass(node): Never ~ TypeException { # {{{
			throw new TypeException(`An instance is required`, node)
		} # }}}
		throwUnexpectedExportType(name, expected, unexpected, node): Never ~ TypeException { # {{{
			throw new TypeException(`The type of export "\(name)" must be \(expected.toQuote(true)) and not \(unexpected.toQuote(true))`, node)
		} # }}}
		throwUnexpectedExpression(expression, target, node): Never ~ TypeException { # {{{
			throw new TypeException(`The expression \(expression.toQuote(true)) is expected to be of type \(target.toQuote(true))`, node)
		} # }}}
		throwUnexpectedInoperative(operand, node): Never ~ TypeException { # {{{
			throw new TypeException(`The operand \(operand.toQuote(true)) can't be of type \(operand.type().toQuote(true))`, node)
		} # }}}
		throwUnexpectedReturnedValue(node): Never ~ TypeException { # {{{
			throw new TypeException(`No values are expected to be returned`, node)
		} # }}}
		throwUnexpectedReturnType(expected, unexpected, node): Never ~ TypeException { # {{{
			throw new TypeException(`The return type must be \(expected.toQuote(true)) and not \(unexpected.toQuote(true))`, node)
		} # }}}
		throwUnnecessaryTypeChecking(type, node): Never ~ TypeException { # {{{
			throw new TypeException(`The variable is always of type \(type.toQuote(true))`, node)
		} # }}}
	}
}
