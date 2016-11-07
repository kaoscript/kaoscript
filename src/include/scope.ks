let $keywords = { // {{{
	abstract: true
	boolean: true
	break: true
	byte: true
	case: true
	catch: true
	char: true
	class: true
	const: true
	continue: true
	debugger: true
	default: true
	delete: true
	do: true
	double: true
	else: true
	enum: true
	export: true
	extends: true
	final: true
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
		_variables			= {}
	}
	AbstractScope(@parent = null)
	addVariable(name, definition) { // {{{
		if $keywords[name] == true {
			let index = this._renamedIndexes[name] ? this._renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)
			
			while this._variables[newName] {
				newName = '__ks_' + name + '_' + (++index)
			}
			
			this._renamedIndexes[name] = index
			this._renamedVariables[name] = newName
		}
		
		this._variables[name] = definition
		
		return this
	} // }}}
	getVariable(name) { // {{{
		if this._variables[name] is Object {
			return this._variables[name]
		}
		else if this._parent? {
			return this._parent.getVariable(name)
		}
		else {
			return null
		}
	} // }}}
	hasVariable(name) { // {{{
		return this._variables[name] is Object || (this._parent? && this._parent.hasVariable(name))
	} // }}}
	parent() => this._parent
	rename(name) { // {{{
		let newName = this.newRenamedVariable(name)
		if newName != name {
			this._renamedVariables[name] = newName
		}
	
		return this
	} // }}}
}

class Scope extends AbstractScope {
	private {
		_scopeParent
		_tempNextIndex 		= 0
		_tempNames			= {}
		_tempNameCount		= 0
		_tempParentNames	= {}
	}
	Scope(parent) { // {{{
		super(parent)
		
		while parent? && !(parent is Scope) {
			parent = parent._parent
		}
		
		if parent? {
			this._scopeParent = parent
			this._tempNextIndex = parent._tempNextIndex
		}
	} // }}}
	acquireTempName(statement: Statement?, assignment = false) { // {{{
		if this._scopeParent && (name ?= this._scopeParent.acquireTempNameFromKid()) {
			this._tempParentNames[name] = true
			
			return name
		}
		
		if this._tempNameCount {
			for i from 0 til this._tempNextIndex when this._tempNames[i] {
				--this._tempNameCount
				
				name = this._tempNames[i]
				
				this._tempNames[i] = false
				
				return name
			}
		}
		else {
			let name = '__ks_' + this._tempNextIndex
			
			++this._tempNextIndex
			
			statement._variables.pushUniq(name) if statement?
			
			return name
		}
	} // }}}
	private acquireTempNameFromKid() { // {{{
		if this._parent && (name ?= this._parent.acquireTempNameFromKid()) {
			this._tempParentNames[name] = true
			
			return name
		}
		
		if this._tempNameCount {
			for i from 0 til this._tempNextIndex when this._tempNames[i] {
				--this._tempNameCount
				
				name = this._tempNames[i]
				
				this._tempNames[i] = false
				
				return name
			}
		}
		
		return null
	} // }}}
	getRenamedVariable(name) { // {{{
		if this._renamedVariables[name] {
			return this._renamedVariables[name]
		}
		else {
			return name
		}
	} // }}}
	newRenamedVariable(name) { // {{{
		if this._variables[name] {
			let index = this._renamedIndexes[name] ? this._renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)
			
			while this._variables[newName] {
				newName = '__ks_' + name + '_' + (++index)
			}
			
			this._renamedIndexes[name] = index
			
			return newName
		}
		else {
			return name
		}
	} // }}}
	releaseTempName(name) { // {{{
		if name.length > 5 && name.substr(0, 5) == '__ks_' {
			if this._scopeParent && this._tempParentNames[name] {
				this._scopeParent.releaseTempNameFromKid(name)
				
				this._tempParentNames[name] = false
			}
			else {
				++this._tempNameCount
				
				this._tempNames[name.substr(5)] = name
			}
		}
		
		return this
	} // }}}
	private releaseTempNameFromKid(name) { // {{{
		if this._parent && this._tempParentNames[name] {
			this._parent.releaseTempNameFromKid(name)
			
			this._tempParentNames[name] = false
		}
		else {
			++this._tempNameCount
				
			this._tempNames[name.substr(5)] = name
		}
	} // }}}
	updateTempNames() { // {{{
		if this._parent && this._parent._tempNextIndex > this._tempNextIndex {
			this._tempNextIndex = this._parent._tempNextIndex
		}
	} // }}}
}

class XScope extends AbstractScope {
	acquireTempName(statement: Statement?, assignment = false) { // {{{
		return this._parent.acquireTempName(statement, assignment)
	} // }}}
	getRenamedVariable(name) { // {{{
		if this._renamedVariables[name] {
			return this._renamedVariables[name]
		}
		else if this._variables[name] {
			return name
		}
		else {
			return this._parent.getRenamedVariable(name)
		}
	} // }}}
	newRenamedVariable(name) { // {{{
		if this._variables[name] {
			let index = this._renamedIndexes[name] ? this._renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)
			
			while this._variables[newName] {
				newName = '__ks_' + name + '_' + (++index)
			}
			
			this._renamedIndexes[name] = index
			
			return newName
		}
		else {
			return this._parent.newRenamedVariable(name)
		}
	} // }}}
	releaseTempName(name) { // {{{
		this._parent.releaseTempName(name)
		
		return this
	} // }}}
	updateTempNames() { // {{{
	} // }}}
}