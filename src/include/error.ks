extern sealed class Error

Error.prepareStackTrace = func(error: Error, stack: Array) { // {{{
	let message = error.toString()

	for i from 0 til Math.min(12, stack.length) {
		message += '\n    ' + stack[i].toString()
	}

	return message
} // }}}

export class Exception extends Error {
	public {
		fileName: String?		= null
		lineNumber: Number		= 0
		message: String
		name: String
	}

	static {
		validateReportedError(error: Type, node) { // {{{
			#![rules(ignore-misfit)]

			until error is NamedType {
				if error.isExtending() {
					error = error.extends()
				}
				else {
					error = node.scope().getVariable('Error').type()
				}
			}

			let options = node._options.error

			if options.level == 'fatal' {
				if !node.parent().isConsumedError(error) {
					if options.ignore.length == 0 {
						SyntaxException.throwUnreportedError(error.name(), node)
					}
					else {
						const hierarchy = error.getHierarchy()

						let nf = true

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
		} // }}}
	}

	constructor(@message) { // {{{
		super()

		@name = this.constructor.name
	} // }}}

	constructor(@message, @fileName, @lineNumber) { // {{{
		this(message)
	} // }}}

	constructor(@message, node: AbstractNode) { // {{{
		this(message, node.file(), node._data.start.line)
	} // }}}

	constructor(@message, node: AbstractNode, data) { // {{{
		this(message, node.file(), data.start.line)
	} // }}}

	toString() { // {{{
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
				return `\(this.name): line \(@lineNumber), file "\(@fileName)"`
			}
			else {
				return `\(this.name): \(@message) (line \(@lineNumber), file "\(@fileName)")`
			}
		}
	} // }}}
}

export class IOException extends Exception {
	static {
		throwNotFoundFile(path, node) ~ IOException { // {{{
			throw new IOException(`The file "\(path)" can't be found`, node)
		} // }}}
		throwNotFoundFile(path, directory, node) ~ IOException { // {{{
			throw new IOException(`The file "\(path)" can't be found in the directory "\(directory)"`, node)
		} // }}}
		throwNotFoundModule(name, node) ~ IOException { // {{{
			throw new IOException(`The module "\(name)" can't be found`, node)
		} // }}}
		throwNotFoundModule(name, directory, node) ~ IOException { // {{{
			throw new IOException(`The module "\(name)" can't be found in the directory "\(directory)"`, node)
		} // }}}
	}
}

export class NotImplementedException extends Exception {
	static {
		throw(...arguments): Never ~ NotImplementedException { // {{{
			throw new NotImplementedException(...arguments)
		} // }}}
	}
	constructor(message = 'Not Implemented') { // {{{
		super(message)
	} // }}}
	constructor(message = 'Not Implemented', node: AbstractNode) { // {{{
		super(message, node)
	} // }}}
	constructor(message = 'Not Implemented', node: AbstractNode, data) { // {{{
		super(message, node, data)
	} // }}}
	constructor(message = 'Not Implemented', fileName, lineNumber) { // {{{
		super(message, fileName, lineNumber)
	} // }}}
}

export class NotSupportedException extends Exception {
	static {
		throw(...arguments) ~ NotSupportedException { // {{{
			throw new NotSupportedException(...arguments)
		} // }}}
	}
	constructor(message = 'Not Supported') { // {{{
		super(message)
	} // }}}
	constructor(message = 'Not Supported', node: AbstractNode) { // {{{
		super(message, node)
	} // }}}
	constructor(message = 'Not Supported', node: AbstractNode, data) { // {{{
		super(message, node, data)
	} // }}}
}

export class ReferenceException extends Exception {
	static {
		throwAlreadyDefinedField(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Field "\(name)" is already defined by its parent class`, node)
		} // }}}
		throwBindingExceedArray(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The destructuring variable "\(name)" can't be matched`, node)
		} // }}}
		throwDefined(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`"\(name)" should not be defined`, node)
		} // }}}
		throwImmutable(name: String, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The identifier "\(name)" is immutable`, node)
		} // }}}
		throwImmutable(node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The expression "\(node.toQuote())" is immutable`, node)
		} // }}}
		throwImmutableField(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The class variable "\(name)" is immutable`, node)
		} // }}}
		throwInvalidAssignment(node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Invalid left-hand side in assignment`, node)
		} // }}}
		throwLoopingAlias(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Alias "@\(name)" is looping on itself`, node)
		} // }}}
		throwNoMatchingConstructor(name, arguments, node) ~ ReferenceException { // {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The constructor of class "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The constructor of class "\(name)" can't be matched to given arguments (\([`\(argument.type().toQuote())` for const argument in arguments].join(', ')))`, node)
			}
		} // }}}
		throwNoMatchingFunction(name, arguments, node) ~ ReferenceException { // {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The function "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The function "\(name)" can't be matched to given arguments (\([`\(argument.type().toQuote())` for const argument in arguments].join(', ')))`, node)
			}
		} // }}}
		throwNoMatchingFunctionInNamespace(name, namespace, arguments, node) ~ ReferenceException { // {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The function "\(name)" in namespace \(namespace.toQuote(true)) can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The function "\(name)" in namespace \(namespace.toQuote(true)) can't be matched to given arguments (\([`\(argument.type().toQuote())` for const argument in arguments].join(', ')))`, node)
			}
		} // }}}
		throwNoMatchingClassMethod(method, class, arguments, node) ~ ReferenceException { // {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The method "\(method)" of the class "\(class)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The method "\(method)" of the class "\(class)" can't be matched to given arguments (\([`\(argument.toQuote())` for const argument in arguments].join(', ')))`, node)
			}
		} // }}}
		throwNoMatchingEnumMethod(method, enum, arguments, node) ~ ReferenceException { // {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The method "\(method)" of the enum "\(enum)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The method "\(method)" of the enum "\(enum)" can't be matched to given arguments (\([`\(argument.toQuote())` for const argument in arguments].join(', ')))`, node)
			}
		} // }}}
		throwNoMatchingStruct(name, arguments, node) ~ ReferenceException { // {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The struct "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The struct "\(name)" can't be matched to given arguments (\([`\(argument.type().toQuote())` for const argument in arguments].join(', ')))`, node)
			}
		} // }}}
		throwNoMatchingTuple(name, arguments, node) ~ ReferenceException { // {{{
			if arguments.length == 0 {
				throw new ReferenceException(`The tuple "\(name)" can't be matched to no arguments`, node)
			}
			else {
				throw new ReferenceException(`The tuple "\(name)" can't be matched to given arguments (\([`\(argument.type().toQuote())` for const argument in arguments].join(', ')))`, node)
			}
		} // }}}
		throwNotDefined(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`"\(name)" is not defined`, node)
		} // }}}
		throwNotDefinedEnumElement(element, enum, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Element "\(element)" is not defined in enum "\(enum)"`, node)
		} // }}}
		throwNotDefinedInModule(name, module, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`"\(name)" is not defined in the module "\(module)"`, node)
		} // }}}
		throwNotDefinedMember(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Member "\(name)" is not defined`, node)
		} // }}}
		throwNotDefinedProperty(name, node): Never ~ ReferenceException { // {{{
			throw new ReferenceException(`Property "\(name)" is not defined`, node)
		} // }}}
		throwNotExportable(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The exported variable "\(name)" is not exportable`, node)
		} // }}}
		throwNotFoundClassMethod(method, class, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The method "\(method)" can't be found in the class "\(class)"`, node)
		} // }}}
		throwNotFoundEnumMethod(method, enum, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The method "\(method)" can't be found in the enum "\(enum)"`, node)
		} // }}}
		throwNotPassed(name, module, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`To overwrite "\(name)", it needs to be passed to the module "\(module)"`, node)
		} // }}}
		throwNullExpression(expression, node) ~ TypeException { // {{{
			throw new ReferenceException(`The expression \(expression.toQuote(true)) is "null"`, node)
		} // }}}
		throwUndefinedBindingVariable(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The destructuring variable "\(name)" can't be matched`, node)
		} // }}}
		throwUndefinedClassField(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The class field "\(name)" isn't defined`, node)
		} // }}}
		throwUndefinedInstanceField(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The instance field "\(name)" isn't defined`, node)
		} // }}}
		throwUndefinedFunction(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`The function "\(name)" can't be found`, node)
		} // }}}
	}
}

export class SyntaxException extends Exception {
	static {
		throwAfterDefaultClause(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Clause is must be before the default clause`, node)
		} // }}}
		throwAfterRestParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter must be before the rest parameter`, node)
		} // }}}
		throwAlreadyDeclared(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Identifier "\(name)" has already been declared`, node)
		} // }}}
		throwDeadCode(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Dead code`, node)
		} // }}}
		throwDuplicateConstructor(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The constructor is matching an existing constructor`, node)
		} // }}}
		throwDuplicateKey(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Duplicate key has been found in object`, node)
		} // }}}
		throwDuplicateMethod(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The method "\(name)" is matching an existing method`, node)
		} // }}}
		throwEnumOverflow(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The bit flags enum "\(name)" can only have at most 53 bits.`, node)
		} // }}}
		throwIdenticalConstructor(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The constructor is identical with another constructor`, node)
		} // }}}
		throwIdenticalFunction(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The function "\(name)" is identical with another function "\(name)"`, node)
		} // }}}
		throwIdenticalMethod(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The method "\(name)" is identical with another method "\(name)"`, node)
		} // }}}
		throwIllegalStatement(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The statement "\(name)" is illegal`, node)
		} // }}}
		throwInvalidAwait(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`"await" can only be used in functions or binary module`, node)
		} // }}}
		throwInvalidEnumAccess(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Accessing an enum can only be done with "::"`, node)
		} // }}}
		throwInvalidEnumValue(data, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The enum's value isn't valid`, node, data)
		} // }}}
		throwInvalidForcedTypeCasting(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The forced type casting "!!" can't determine the expected type`, node)
		} // }}}
		throwInvalidLateInitAssignment(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" can't be initialized by the statement at`, node)
		} // }}}
		throwInvalidMethodReturn(className, methodName, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Method "\(methodName)" of the class "\(className)" has an invalid return type`, node)
		} // }}}
		throwInvalidImportAliasArgument(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Aliases arguments can't be used with classic JavaScript module`, node)
		} // }}}
		throwInvalidIdentifier(value, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`"\(value)" is an invalid identifier`, node)
		} // }}}
		throwInvalidSyncMethods(className, methodName, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Method "\(methodName)" of the class "\(className)" can be neither sync nor async`, node)
		} // }}}
		throwInvalidRule(name, fileName, lineNumber) ~ SyntaxException { // {{{
			throw new SyntaxException(`The rule "\(name)" is invalid`, fileName, lineNumber)
		} // }}}
		throwLoopingImport(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The import "\(name)" is looping`, node)
		} // }}}
		throwMismatchedInclude(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Inclusions of "\(name)" should have the same version`, node)
		} // }}}
		throwMissingAbstractMethods(name, methods, node) ~ SyntaxException { // {{{
			const fragments = []

			for const methods, name of methods {
				for const method in methods {
					fragments.push(`"\(name)\(method.toQuote())"`)
				}
			}

			throw new SyntaxException(`Class "\(name)" doesn't implement the following abstract method\(fragments.length > 1 ? 's' : ''): \(fragments.join(', '))`, node)
		} // }}}
		throwMissingAssignmentIfFalse(name, node): Never ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized when the condition is false`, node)
		} // }}}
		throwMissingAssignmentIfNoElse(name, node): Never ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized due to the missing "else" statement`, node)
		} // }}}
		throwMissingAssignmentIfTrue(name, node): Never ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized when the condition is true`, node)
		} // }}}
		throwMissingAssignmentSwitchClause(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized by the clause at`, node)
		} // }}}
		throwMissingAssignmentSwitchNoDefault(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't fully initialized due to the missing default clause`, node)
		} // }}}
		throwMissingRequirement(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`import is missing the argument "\(name)"`, node)
		} // }}}
		throwMissingStructField(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The field "\(name)" is missing to create the struct`, node)
		} // }}}
		throwMissingTupleField(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The field "\(name)" is missing to create the tuple`, node)
		} // }}}
		throwMixedOverloadedFunction(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Overloaded functions can't mix sync/async`, node)
		} // }}}
		throwNoDefaultParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter can't have a default value`, node)
		} // }}}
		throwNoExport(module, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`No export can be found in module "\(module)"`, node)
		} // }}}
		throwNoNullParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter can't be nullable`, node)
		} // }}}
		throwNoRestParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter can't be a rest parameter`, node)
		} // }}}
		throwNoSuitableOverride(class, name, parameters, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`"\(class.toQuote()).\(name)\(FunctionType.toQuote(parameters))" can't be matched to any suitable method to override`, node)
		} // }}}
		throwNoSuitableOverwrite(class, name, type, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`"\(class.toQuote()).\(name)\(type.toQuote())" can't be matched to any suitable method to overwrite`, node)
		} // }}}
		throwNoSuperCall(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Call "super()" is missing`, node)
		} // }}}
		throwNotAbstractClass(className, methodName, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Method "\(methodName)" is abstract but the class "\(className)" is not`, node)
		} // }}}
		throwNotBinary(tag, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Binary file can't use "\(tag)" statement`, node)
		} // }}}
		throwNotCompatibleConstructor(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parent's constructor of class "\(name)" can't be called`, node)
		} // }}}
		throwNotEnoughStructFields(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`There is not enough fields to create the struct`, node)
		} // }}}
		throwNotEnoughTupleFields(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`There is not enough fields to create the tuple`, node)
		} // }}}
		throwNotFullyInitializedVariable(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" is only partially initialized`, node)
		} // }}}
		throwNotInitializedField(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The class variable "\(name)" isn't initialized`, node)
		} // }}}
		throwNotInitializedVariable(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The lateinit variable "\(name)" isn't initialized`, node)
		} // }}}
		throwNotNamedParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter must be named`, node)
		} // }}}
		throwNotOverloadableFunction(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Variable "\(name)" is not an overloadable function`, node)
		} // }}}
		throwNotSealedOverwrite(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`A method can be overwritten only in a sealed class`, node)
		} // }}}
		throwReservedClassMethod(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Class method "\(name)" is reserved`, node)
		} // }}}
		throwReservedClassVariable(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Class variable "\(name)" is reserved`, node)
		} // }}}
		throwTooMuchAttributesForIfAttribute() ~ SyntaxException { // {{{
			throw new SyntaxException(`Expected 1 argument for 'if' attribute`)
		} // }}}
		throwTooMuchStructFields(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`There is too much fields to create the struct`, node)
		} // }}}
		throwTooMuchTupleFields(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`There is too much fields to create the tuple`, node)
		} // }}}
		throwTooMuchRestParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Rest parameter has already been declared`, node)
		} // }}}
		throwUnexpectedAlias(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Alias "@\(name)" is expected in an instance method/variable`, node)
		} // }}}
		throwUnmatchedMacro(name, node, data) ~ SyntaxException { // {{{
			throw new SyntaxException(`The macro "\(name)" can't be matched`, node, data)
		} // }}}
		throwUnnamedWildcardImport(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Wilcard import can't be named`, node)
		} // }}}
		throwUnrecognizedStructField(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The argument "\(name)" isn't recognized to create the struct`, node)
		} // }}}
		throwUnrecognizedTupleField(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The argument "\(name)" isn't recognized to create the tuple`, node)
		} // }}}
		throwUnreportedError(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`An error is unreported, it must be caught or declared to be thrown`, node)
		} // }}}
		throwUnreportedError(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`An error "\(name)" is unreported, it must be caught or declared to be thrown`, node)
		} // }}}
		throwUnsupportedDestructuringAssignment(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`The current destructuring assignment is unsupported`, node)
		} // }}}
	}
}

export class TypeException extends Exception {
	static {
		throwCannotBeInstantiated(name, node) ~ TypeException { // {{{
			throw new TypeException(`Class "\(name)" is abstract so it can't be instantiated`, node)
		} // }}}
		throwConstructorWithoutNew(name, node): Never ~ TypeException { // {{{
			throw new TypeException(`Class constructor "\(name)" cannot be invoked without 'new'`, node)
		} // }}}
		throwExpectedReturnedValue(type, node) ~ TypeException { // {{{
			throw new TypeException(`A value of type \(type.toQuote(true)) is expected to be returned`, node)
		} // }}}
		throwExpectedThrownError(node) ~ TypeException { // {{{
			throw new TypeException(`An error is expected to be thrown`, node)
		} // }}}
		throwImplFieldToSealedType(node) ~ TypeException { // {{{
			throw new TypeException(`impl can add field to only non-sealed type`, node)
		} // }}}
		throwImplInvalidType(node) ~ TypeException { // {{{
			throw new TypeException(`impl has an invalid type`, node)
		} // }}}
		throwInvalid(name, node) ~ TypeException { // {{{
			throw new TypeException(`Invalid type "\(name)"`, node)
		} // }}}
		throwInvalidAssignement(name: String, declaredType: Type, valueType: Type, node) ~ TypeException { // {{{
			if valueType.isNull() {
				throw new TypeException(`The variable "\(name)" of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw new TypeException(`The variable "\(name)" of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} // }}}
		throwInvalidAssignement(name: AbstractNode, declaredType: Type, valueType: Type, node) ~ TypeException { // {{{
			if valueType.isNull() {
				throw new TypeException(`The variable \(name.toQuote(true)) of type \(declaredType.toQuote(true)) can't be assigned with the value "null"`, node)
			}
			else {
				throw new TypeException(`The variable \(name.toQuote(true)) of type \(declaredType.toQuote(true)) can't be assigned with a value of type \(valueType.toQuote(true))`, node)
			}
		} // }}}
		throwInvalidBinding(expected, node) ~ TypeException { // {{{
			throw new TypeException(`The binding is expected to be of type "\(expected)"`, node)
		} // }}}
		throwInvalidCasting(node) ~ TypeException { // {{{
			throw new TypeException(`Only variables can be casted`, node)
		} // }}}
		throwInvalidComparison(left: AbstractNode, right: AbstractNode, node) ~ TypeException { // {{{
			throw new TypeException(`The expression \(left.toQuote(true)) of type \(left.type().toQuote(true)) can't be compared to a value of type \(right.type().toQuote(true))`, node)
		} // }}}
		throwInvalidCondition(expression, node) ~ TypeException { // {{{
			throw new TypeException(`The condition \(expression.toQuote(true)) is expected to be of type "Boolean" or "Any" and not of type \(expression.type().toQuote(true))`, node)
		} // }}}
		throwInvalidForInExpression(node) ~ TypeException { // {{{
			throw new TypeException(`"for..in" must be used with an array`, node)
		} // }}}
		throwInvalidForOfExpression(node) ~ TypeException { // {{{
			throw new TypeException(`"for..of" must be used with a dictionary`, node)
		} // }}}
		throwInvalidOperand(expression, operator, node) ~ TypeException { // {{{
			throw new TypeException(`The expression \(expression.toQuote(true)) of type \(expression.type().toQuote(true)) is expected to be of type "\($operatorTypes[operator].join('", "'))" or "Any" in a \(operator) operation`, node)
		} // }}}
		throwInvalidSpread(node) ~ TypeException { // {{{
			throw new TypeException(`Spread operator require an array`, node)
		} // }}}
		throwInvalidTypeChecking(left, right, node) ~ TypeException { // {{{
			throw new TypeException(`The variable of type \(left.toQuote(true)) can never be of type \(right.toQuote(true))`, node)
		} // }}}
		throwNotAlien(name, node) ~ TypeException { // {{{
			throw new TypeException(`The type "\(name)" must be declared externally`, node)
		} // }}}
		throwNotAsyncFunction(name, node) ~ TypeException { // {{{
			throw new TypeException(`The function "\(name)" is not asynchronous`, node)
		} // }}}
		throwNotCastableTo(valueType: Type, castingType: Type, node) ~ TypeException { // {{{
			throw new TypeException(`The type \(valueType.toQuote(true)) can't be casted as a \(castingType.toQuote(true))`, node)
		} // }}}
		throwNotClass(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not a class`, node)
		} // }}}
		throwNotCompatibleArgument(varname, argname, modname, node) ~ ReferenceException { // {{{
			throw new TypeException(`The variable "\(varname)" and the argument "\(argname)" of the module "\(modname)" aren't compatible`, node)
		} // }}}
		throwNotCompatibleDefinition(varname, argname, modname, node) ~ ReferenceException { // {{{
			throw new TypeException(`The definition for "\(varname)" and the variable "\(argname)" of the module "\(modname)" aren't compatible`, node)
		} // }}}
		throwNotEnum(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not an enum`, node)
		} // }}}
		throwNotNamespace(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not a namespace`, node)
		} // }}}
		throwNotNullableExistential(expression, node) ~ TypeException { // {{{
			throw new TypeException(`The existential test of \(expression.toQuote(true)) is always positive`, node)
		} // }}}
		throwNotNullableOperand(expression, operator, node) ~ TypeException { // {{{
			throw new TypeException(`The operand \(expression.toQuote(true)) can't be nullable in a \(operator) operation`, node)
		} // }}}
		throwNotStruct(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not a struct`, node)
		} // }}}
		throwNotTuple(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not a tuple`, node)
		} // }}}
		throwNotSyncFunction(name, node) ~ TypeException { // {{{
			throw new TypeException(`The function "\(name)" is not synchronous`, node)
		} // }}}
		throwNullableCaller(property, node) ~ TypeException { // {{{
			throw new TypeException(`The caller of "\(property)" can't be nullable`, node)
		} // }}}
		throwNullTypeChecking(type, node) ~ TypeException { // {{{
			throw new TypeException(`The variable is "null" and can't be checked against the type \(type.toQuote(true))`, node)
		} // }}}
		throwNullTypeVariable(name, node) ~ TypeException { // {{{
			throw new TypeException(`The variable "\(name)" can't be of type "Null"`, node)
		} // }}}
		throwRequireClass(node) ~ TypeException { // {{{
			throw new TypeException(`An instance is required`, node)
		} // }}}
		throwUnexpectedExportType(name, expected, unexpected, node) ~ TypeException { // {{{
			throw new TypeException(`The type of export "\(name)" must be \(expected.toQuote(true)) and not \(unexpected.toQuote(true))`, node)
		} // }}}
		throwUnexpectedInoperative(operand, node) ~ TypeException { // {{{
			throw new TypeException(`The operand \(operand.toQuote(true)) can't be of type \(operand.type().toQuote(true))`, node)
		} // }}}
		throwUnexpectedReturnedValue(node) ~ TypeException { // {{{
			throw new TypeException(`No values are expected to be returned`, node)
		} // }}}
		throwUnexpectedReturnType(expected, unexpected, node) ~ TypeException { // {{{
			throw new TypeException(`The return type must be \(expected.toQuote(true)) and not \(unexpected.toQuote(true))`, node)
		} // }}}
		throwUnnecessaryTypeChecking(type, node) ~ TypeException { // {{{
			throw new TypeException(`The variable is always of type \(type.toQuote(true))`, node)
		} // }}}
	}
}