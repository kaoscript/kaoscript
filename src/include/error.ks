extern sealed class Error

Error.prepareStackTrace = func(error: Error, stack: Array) { // {{{
	let message = error.toString()
	
	for i from 0 til stack.length {
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
		validateReportedError(error: ClassType, node) { // {{{
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
		@name = this.constructor.name
		
		if !?this.stack {
			@captureStackTrace()
		}
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
	
	private captureStackTrace() { // {{{
		if Error.captureStackTrace? {
			Error.captureStackTrace(this)
		}
		else {
			this.stack = (new Error()).stack
		}
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
		throwNotDefined(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`"\(name)" is not defined`, node)
		} // }}}
		throwNotDefinedField(name, node) ~ ReferenceException { // {{{
			throw new ReferenceException(`Field "\(name)" is not defined`, node)
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
		throwExclusiveWildcardImport(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Wilcard import is only supported for kaoscript file`, node)
		} // }}}
		throwImmutable(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Identifier "\(name)" is immutable`, node)
		} // }}}
		throwInvalidMethodReturn(className, methodName, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Method "\(methodName)" of the class "\(className)" has an invalid return type`, node)
		} // }}}
		throwMissingAbstractMethods(name, methods, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Class "\(name)" doesn't implement the following abstract methods: "\(methods.join('", "'))"`, node)
		} // }}}
		throwMissingRequirement(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`import is missing the argument "\(name)"`, node)
		} // }}}
		throwNoDefaultParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter can't have a default value`, node)
		} // }}}
		throwNotDifferentiableMethods(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Can't differentiate methods`, node)
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
		throwNotNamedParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter must be named`, node)
		} // }}}
		throwOutOfClassAlias(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Alias "@\(name)" must be inside a class`, node)
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
		throwUnreportedError(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Error "\(name)" is unreported, it must be caught or declared to be thrown`, node)
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
		throwNotClass(name, node) ~ TypeException { // {{{
			throw new TypeException(`Identifier "\(name)" is not a class`, node)
		} // }}}
	}
}