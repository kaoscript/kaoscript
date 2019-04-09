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

enum ScopeType {
	Bleeding
	Block
	InlineBlock
	Macro
	Refinable
}

abstract class Scope {
	static {
		isTempName(name: String): Boolean => name.length > 5 && name.substr(0, 5) == '__ks_'
	}
	private abstract declareVariable(name: String): String?
	abstract define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable
	abstract defineVariable(variable: Variable, node: AbstractNode)
	abstract getDefinedVariable(name: String): Variable?
	abstract getRenamedIndex(name: String): Number
	abstract getRenamedVariable(name: String): String
	abstract getVariable(name: String): Variable
	abstract hasDefinedVariable(name: String): Boolean
	abstract hasDeclaredVariable(name: String): Boolean
	abstract hasVariable(name: String): Boolean
	hasMacro(name: String): Boolean => false
	isBleeding(): Boolean => false
	isInline(): Boolean => false
	isPredefinedVariable(name: String): Boolean => (variable ?= this.getVariable(name)) && variable.isPredefined()
	abstract reference(value): ReferenceType
}

include {
	'./scope/bleeding'
	'./scope/block'
	'./scope/inline'
	'./scope/import'
	'./scope/macro'
	'./scope/namespace'
	'./scope/module'
	'./scope/refinable'
}