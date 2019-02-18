let $keywords = { // {{{
	abstract: true
	arguments: true
	boolean: true
	break: true
	byte: true
	case: true
	catch: true
	char: true
	class: true
	const: true
	constructor: true
	continue: true
	debugger: true
	default: true
	delete: true
	destructor: true
	do: true
	double: true
	else: true
	enum: true
	export: true
	extends: true
	finally: true
	float: true
	for: true
	function: true
	goto: true
	if: true
	implements: true
	import: true
	in: true
	instanceof: true
	int: true
	interface: true
	long: true
	native: true
	new: true
	package: true
	private: true
	protected: true
	public: true
	return: true
	sealed: true
	short: true
	static: true
	switch: true
	synchronized: true
	throw: true
	throws: true
	transient: true
	try: true
	typeof: true
	var: true
	void: true
	volatile: true
	while: true
	with: true
} // }}}

class AbstractScope {
	private {
		_body: Array		= []
		_macros				= {}
		_natives			= {}
		_parent
		_prepared			= false
		_references			= {}
		_renamedIndexes 	= {}
		_renamedVariables	= {}
		_scopeParent		= null
		_variables			= {}
	}
	constructor(@parent = null) { // {{{
		if parent? {
			while parent? && !(parent is Scope) {
				parent = parent._parent
			}

			if parent? {
				@scopeParent = parent
			}
		}
	} // }}}
	addMacro(name: String, macro: MacroDeclaration) { // {{{
		if @macros[name] is Array {
			const type = macro.type()
			let na = true

			for m, index in @macros[name] while na {
				if m.type().matchContentTo(type) {
					@macros[name].splice(index, 0, macro)

					na = false
				}
			}

			if na {
				@macros[name].push(macro)
			}
		}
		else {
			@macros[name] = [macro]
		}
	} // }}}
	addNative(name: String) { // {{{
		@natives[name] = new Variable(name, true, false, Type.Any)
	} // }}}
	addNative(name: String, type: String) { // {{{
		@natives[name] = new Variable(name, true, false, this.reference(type))
	} // }}}
	addVariable(name: String, variable: Variable, node?) { // {{{
		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		if $keywords[name] == true {
			let index = @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)

			while @variables[newName] is Variable {
				newName = '__ks_' + name + '_' + (++index)
			}

			@renamedIndexes[name] = index
			@renamedVariables[name] = newName
		}

		@variables[name] = variable

		return this
	} // }}}
	define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable { // {{{
		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type)

		this.addVariable(name, variable, node)

		return variable
	} // }}}
	getLocalVariable(name): Variable { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else if @natives[name] is Variable {
			return @natives[name]
		}
		else {
			return null
		}
	} // }}}
	getMacro(data, parent) { // {{{
		if data.callee.kind == NodeKind::Identifier {
			if @macros[data.callee.name]? {
				for macro in @macros[data.callee.name] {
					if macro.matchArguments(data.arguments) {
						return macro
					}
				}
			}

			SyntaxException.throwUnmatchedMacro(data.callee.name, parent, data)
		}
		else {
			const path = Generator.generate(data.callee)

			if @macros[path]? {
				for macro in @macros[path] {
					if macro.matchArguments(data.arguments) {
						return macro
					}
				}
			}

			SyntaxException.throwUnmatchedMacro(path, parent, data)
		}
	} // }}}
	getVariable(name): Variable { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else if @natives[name] is Variable {
			return @natives[name]
		}
		else if @parent? {
			return @parent.getVariable(name)
		}
		else {
			return null
		}
	} // }}}
	hasDeclaredLocalVariable(name) => @variables[name] is Variable || @variables[name] == false
	hasLocalVariable(name) => @variables[name] is Variable || @natives[name] is Variable
	hasMacro(name) => @macros[name] is Array
	hasVariable(name) => @variables[name] is Variable || @natives[name] is Variable || @parent?.hasVariable(name)
	listMacros(name) => @macros[name]
	parent() => @parent
	reference(value) { // {{{
		switch value {
			is AnyType => return this.resolveReference('Any')
			is ClassVariableType => return this.reference(value.type())
			is NamedType => return value.reference(this)
			is ReferenceType => return this.resolveReference(value.name(), value.isNullable())
			is String => return this.resolveReference(value)
			is Variable => return this.resolveReference(value.name())
			=> {
				console.log(value)
				throw new NotImplementedException()
			}
		}
	} // }}}
	private resolveReference(name: String, nullable = false) { // {{{
		if @variables[name] is Variable || @natives[name] is Variable || !?@parent {
			const hash = `\(name)\(nullable ? '?' : '')`

			if @references[hash] is not ReferenceType {
				@references[hash] = new ReferenceType(this, name, nullable)
			}

			return @references[hash]
		}
		else {
			return @parent.resolveReference(name, nullable)
		}
	} // }}}
	reassignReference(oldName, newName, newScope) { // {{{
		if @references[oldName]? {
			@references[oldName].reassign(newName, newScope)
		}
	} // }}}
	removeVariable(name) { // {{{
		if @variables[name] is Variable {
			@variables[name] = false
		}
		else {
			@parent?.removeVariable(name)
		}

		return this
	} // }}}
	rename(name, newName = this.newRenamedVariable(name)) { // {{{
		if newName != name {
			@renamedVariables[name] = newName
		}

		return this
	} // }}}
	replaceVariable(name: String, variable: Variable) { // {{{
		@variables[name] = variable

		return this
	} // }}}
}

class Scope extends AbstractScope {
	private {
		_stashes				= {}
		_tempNextIndex 			= 0
		_tempNames				= {}
		_tempParentNames		= {}
	}
	acquireTempName(statement: Statement = null) { // {{{
		this.updateTempNames()

		if name ?= @scopeParent?.acquireTempNameFromKid() {
			@tempParentNames[name] = true

			return name
		}

		for name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		while @tempParentNames[name = '__ks_' + @tempNextIndex] {
			++@tempNextIndex
		}

		++@tempNextIndex

		if statement != null {
			statement._assignments.pushUniq(name)
		}

		return name
	} // }}}
	private acquireTempNameFromKid() { // {{{
		if name ?= @parent?.acquireTempNameFromKid() {
			return name
		}

		for name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		return null
	} // }}}
	addStash(name, ...fn) { // {{{
		if ?@stashes[name] {
			@stashes[name].push(fn)
		}
		else {
			@stashes[name] = [fn]
		}
	} // }}}
	getRenamedVariable(name) { // {{{
		if @renamedVariables[name] is String {
			return @renamedVariables[name]
		}
		else if @scopeParent? {
			return @scopeParent.getRenamedVariable(name)
		}
		else {
			return name
		}
	} // }}}
	newRenamedVariable(name, variables = @variables) { // {{{
		if variables[name]? {
			let index = @renamedIndexes[name] ? @renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)

			while variables[newName] {
				newName = '__ks_' + name + '_' + (++index)
			}

			@renamedIndexes[name] = index

			return newName
		}
		else {
			return name
		}
	} // }}}
	processStash(name) { // {{{
		const stash = @stashes[name]
		if ?stash {
			delete @stashes[name]

			let variable = this.getVariable(name)
			for let fn in stash {
				if fn[0](variable) {
					break
				}
			}

			variable = this.getVariable(name)
			for let fn in stash {
				fn[1](variable)
			}

			return true
		}
		else {
			return false
		}
	} // }}}
	releaseTempName(name) { // {{{
		if name.length > 5 && name.substr(0, 5) == '__ks_' {
			if @scopeParent && @tempParentNames[name] {
				@scopeParent.releaseTempNameFromKid(name)

				@tempParentNames[name] = false
			}
			else {
				@tempNames[name] = true
			}
		}

		return this
	} // }}}
	private releaseTempNameFromKid(name) { // {{{
		if @parent && @tempParentNames[name] {
			@parent.releaseTempNameFromKid(name)

			@tempParentNames[name] = false
		}
		else {
			@tempNames[name] = true
		}
	} // }}}
	updateTempNames() { // {{{
		if @parent? {
			@parent.updateTempNames()

			if @parent._tempNextIndex > @tempNextIndex {
				@tempNextIndex = @parent._tempNextIndex
			}
		}
	} // }}}
}

class XScope extends AbstractScope {
	acquireTempName(statement: Statement = null) { // {{{
		return @parent.acquireTempName(statement)
	} // }}}
	getRenamedVariable(name) { // {{{
		if @renamedVariables[name] is String {
			return @renamedVariables[name]
		}
		else if @variables[name]? {
			return name
		}
		else {
			return @parent.getRenamedVariable(name)
		}
	} // }}}
	newRenamedVariable(name, variables = @variables) { // {{{
		if variables[name]? {
			return @scopeParent.newRenamedVariable(name, variables)
		}
		else {
			return @parent.newRenamedVariable(name)
		}
	} // }}}
	releaseTempName(name) { // {{{
		@parent.releaseTempName(name)

		return this
	} // }}}
	updateTempNames() { // {{{
	} // }}}
}

class ModuleScope extends Scope {
	private {
		_predefined		= {}
	}
	constructor() { // {{{
		super()

		@predefined.__Array = Variable.createPredefinedClass('Array', this)
		@predefined.__Boolean = Variable.createPredefinedClass('Boolean', this)
		@predefined.__Class = Variable.createPredefinedClass('Class', this)
		@predefined.__Date = Variable.createPredefinedClass('Date', this)
		@predefined.__Error = Variable.createPredefinedClass('Error', this)
		@predefined.__Function = Variable.createPredefinedClass('Function', this)
		@predefined.__Number = Variable.createPredefinedClass('Number', this)
		@predefined.__Object = Variable.createPredefinedClass('Object', this)
		@predefined.__String = Variable.createPredefinedClass('String', this)
		@predefined.__RegExp = Variable.createPredefinedClass('RegExp', this)

		@predefined.__false = new Variable('false', true, true, this.reference('Boolean'))
		@predefined.__null = new Variable('null', true, true, Type.Any)
		@predefined.__true = new Variable('true', true, true, this.reference('Boolean'))
		@predefined.__Infinity = new Variable('Infinity', true, true, this.reference('Number'))
		@predefined.__Math = new Variable('Math', true, true, this.reference('Object'))
		@predefined.__NaN = new Variable('NaN', true, true, this.reference('Number'))
	} // }}}
	getVariable(name): Variable { // {{{
		if $types[name] is String {
			name = $types[name]
		}

		if @variables[name] is Variable {
			return @variables[name]
		}
		else if @natives[name] is Variable {
			return @natives[name]
		}
		else if @predefined[`__\(name)`] is Variable {
			return @predefined[`__\(name)`]
		}
		else {
			return null
		}
	} // }}}
	hasVariable(name) { // {{{
		if $types[name] is String {
			name = $types[name]
		}

		return @variables[name] is Variable || $natives[name] == true || @predefined[`__\(name)`] is Variable
	} // }}}
}

class ImportScope extends Scope {
}

class NamespaceScope extends Scope {
	addVariable(name: String, variable: Variable) { // {{{
		if $keywords[name] == true {
			let index = @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)

			while @variables[newName] is Variable {
				newName = '__ks_' + name + '_' + (++index)
			}

			@renamedIndexes[name] = index
			@renamedVariables[name] = newName
		}

		@variables[name] = variable

		return this
	} // }}}
}