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
		_parent
		_prepared			= false
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
	addVariable(name, definition) { // {{{
		if $keywords[name] == true {
			let index = @renamedIndexes[name] ? @renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)
			
			while @variables[newName] {
				newName = '__ks_' + name + '_' + (++index)
			}
			
			@renamedIndexes[name] = index
			@renamedVariables[name] = newName
		}
		
		@variables[name] = definition
		
		return this
	} // }}}
	getVariable(name) { // {{{
		if @variables[name] is Object {
			return @variables[name]
		}
		else if @parent? {
			return @parent.getVariable(name)
		}
		else {
			return null
		}
	} // }}}
	hasVariable(name, lookAtParent = true) { // {{{
		return @variables[name] is Object || (lookAtParent && @parent?.hasVariable(name))
	} // }}}
	isDeclaredVariable(name, lookAtParent = true) { // {{{
		return @variables[name]? || (lookAtParent && @parent?.isDeclaredVariable(name))
	} // }}}
	parent() => @parent
	removeVariable(name) { // {{{
		if @variables[name] is Object {
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
}

class Scope extends AbstractScope {
	private {
		_tempNextIndex 		= 0
		_tempNames			= {}
		_tempParentNames	= {}
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
		
		statement._variables.pushUniq(name) if statement?
		
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