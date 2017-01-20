extern sealed class Error

class Exception extends Error {
	public {
		fileName: String
		lineNumber: Number
		message: String
	}
	
	$create(@message, @fileName: String, @lineNumber: Number) { // {{{
		if !?this.stack {
			@captureStackTrace()
		}
	} // }}}
	
	$create(message, node: AbstractNode) { // {{{
		this(message, node.file(), node._data.start.line)
	} // }}}
	
	$create(message, node: AbstractNode, data) { // {{{
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
		if @message.length {
			return `\(this.name): \(@message) (line \(@lineNumber), file "\(@fileName)")`
		}
		else {
			return `\(this.name): line \(@lineNumber), file "\(@fileName)"`
		}
	} // }}}
}

class IOException extends Exception {
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

class NotImplementedException extends Exception {
	$create(message = 'Not Implemented', node: AbstractNode) { // {{{
		super(message, node)
	} // }}}
	/* $create(message = 'Not Implemented', node: AbstractNode, data) {
		super(message, node, data)
	}
	$create(message = 'Not Implemented', fileName: String, lineNumber: Number) {
		super(message, fileName, lineNumber)
	} */
}

class NotSupportedException extends Exception {
	$create(message = 'Not Supported', node: AbstractNode) { // {{{
		super(message, node)
	} // }}}
}

class ReferenceException extends Exception {
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

class SyntaxException extends Exception {
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
		throwMissingAbstractMethods(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Class "\(name)" is not abstract and does not override all abstract methods`, node)
		} // }}}
		throwMissingRequirement(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`import is missing the argument "\(name)"`, node)
		} // }}}
		throwNoDefaultParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter can't have a default value`, node)
		} // }}}
		throwNoRestParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter can't be a rest parameter`, node)
		} // }}}
		throwNoNullParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Parameter can't be nullable`, node)
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
		throwTooMuchRestParameter(node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Rest parameter has already been declared`, node)
		} // }}}
		throwUnreportedError(name, node) ~ SyntaxException { // {{{
			throw new SyntaxException(`Error "\(name)" is unreported, it must be caught or declared to be thrown`, node)
		} // }}}
	}
}

class TypeException extends Exception {
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