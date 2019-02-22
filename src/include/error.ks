extern sealed class Error

Error.prepareStackTrace = func(error: Error, stack: Array) { // {{{
	let message = error.toString()

	for i from 0 til Math.min(8, stack.length) {
		message += '\n    ' + stack[i].toString()
	}

	return message
} // }}}

export class Exception extends Error {
	public {
		fileName: String		= null
		lineNumber: Number		= 0
		message: String
		name: String
	}

	static {
		validateReportedError(error: Type, node) { // {{{
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
	constructor(message = 'Not Supported') { // {{{
		super(message)
	} // }}}
	constructor(message = 'Not Supported', node: AbstractNode) { // {{{
		super(message, node)
	} // }}}
}

export class ReferenceException extends Exception {
	static {
		throwAlreadyDefinedField(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Field "\(name)" is already defined by its parent class`, node)
		} // }}}
		throwImmutable(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Identifier "\(name)" is immutable`, node)
		} // }}}
		throwNotDefined(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`"\(name)" is not defined`, node)
		} // }}}
		throwNotDefinedField(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Field "\(name)" is not defined`, node)
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
		throwNotDefinedMethod(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Method "\(name)" is not defined`, node)
		} // }}}
		throwNotDefinedProperty(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Property "\(name)" is not defined`, node)
		} // }}}
		throwNotPassed(name, module, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`To overwrite "\(name)", it needs to be passed to the module "\(module)"`, node)
		} // }}}
		throwSelfDefinedVariable(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Variable "\(name)" is being self-defined`, node)
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
		throwDuplicateKey(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Duplicate key has been found in object`, node)
		} // }}}
		throwInvalidAwait(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`"await" can only be used in functions or binary module`, node)
		} // }}}
		throwInvalidEnumAccess(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Accessing an enum can only be done with "::"`, node)
		} // }}}
		throwInvalidMethodReturn(className, methodName, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Method "\(methodName)" of the class "\(className)" has an invalid return type`, node)
		} // }}}
		throwInvalidNamedArgument(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Argument "\(name)" can't be a named argument`, node)
		} // }}}
		throwInvalidSyncMethods(className, methodName, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Method "\(methodName)" of the class "\(className)" can be neither sync nor async`, node)
		} // }}}
		throwMismatchedInclude(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Inclusions of "\(name)" should have the same version`, node)
		} // }}}
		throwMissingAbstractMethods(name, methods, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Class "\(name)" doesn't implement the following abstract methods: "\(methods.join('", "'))"`, node)
		} // }}}
		throwMissingRequirement(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`import is missing the argument "\(name)"`, node)
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
		throwNotDifferentiableFunction(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Overloaded functions can't be differentiated`, node)
		} // }}}
		throwNotDifferentiableMethods(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Methods can't be differentiated`, node)
		} // }}}
		throwNotNamedParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter must be named`, node)
		} // }}}
		throwNotOverloadableFunction(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Variable "\(name)" is not an overloadable function`, node)
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
		throwTooMuchRestParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Rest parameter has already been declared`, node)
		} // }}}
		throwUnexpectedAlias(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Alias "@\(name)" is expected in an instance method/variable`, node)
		} // }}}
		throwUnmatchedMacro(name, node, data) ~ SyntaxException { // {{{
			throw new SyntaxException(`Macro "\(name)" can't be matched`, node, data)
		} // }}}
		throwUnnamedWildcardImport(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Wilcard import can't be named`, node)
		} // }}}
		throwUnreportedError(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`An error is unreported, it must be caught or declared to be thrown`, node)
		} // }}}
		throwUnreportedError(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`An error "\(name)" is unreported, it must be caught or declared to be thrown`, node)
		} // }}}
	}
}

export class TypeException extends Exception {
	static {
		throwCannotBeInstantiated(name, node) ~ TypeException { // {{{
			throw new TypeException(`Class "\(name)" is abstract so it can't be instantiated`, node)
		} // }}}
		throwConstructorWithoutNew(name, node) ~ TypeException { // {{{
			throw new TypeException(`Class constructor "\(name)" cannot be invoked without 'new'`, node)
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
		throwInvalidBinding(expected, node) ~ TypeException { // {{{
			throw new TypeException(`The binding is expected to be of type "\(expected)"`, node)
		} // }}}
		throwInvalidCasting(node) ~ TypeException { // {{{
			throw new TypeException(`Only variables can be casted`, node)
		} // }}}
		throwInvalidForInExpression(node) ~ TypeException { // {{{
			throw new TypeException(`"for..in" must be used with an array`, node)
		} // }}}
		throwInvalidForOfExpression(node) ~ TypeException { // {{{
			throw new TypeException(`"for..of" must be used with an object`, node)
		} // }}}
		throwInvalidSpread(node) ~ TypeException { // {{{
			throw new TypeException(`Spread operator require an array`, node)
		} // }}}
		throwInvalidTypeChecking(node) ~ TypeException { // {{{
			throw new TypeException(`Type checking has incompatible type`, node)
		} // }}}
		throwNoMatchingConstructor(name, node) ~ TypeException { // {{{
			throw new TypeException(`Constructor of class "\(name)" can't be matched to given arguments`, node)
		} // }}}
		throwNoMatchingFunction(node) ~ TypeException { // {{{
			throw new TypeException(`Function can't be matched to given arguments`, node)
		} // }}}
		throwNotAsyncFunction(name, node) ~ TypeException { // {{{
			throw new TypeException(`The function "\(name)" is not asynchronous`, node)
		} // }}}
		throwNotClass(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not a class`, node)
		} // }}}
		throwNotCompatible(varname, argname, modname, node) ~ ReferenceException { // {{{
			throw new TypeException(`The variable "\(varname)" and the argument "\(argname)" of the module "\(modname)" aren't compatible`, node)
		} // }}}
		throwNotNamespace(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not a namespace`, node)
		} // }}}
		throwNotSyncFunction(name, node) ~ TypeException { // {{{
			throw new TypeException(`The function "\(name)" is not synchronous`, node)
		} // }}}
		throwRequireClass(node) ~ TypeException { // {{{
			throw new TypeException(`An instance is required`, node)
		} // }}}
		throwUnexpectedReturnedType(type, node) ~ TypeException { // {{{
			throw new TypeException(`Expected returned type \(type.toQuote())`, node)
		} // }}}
	}
}