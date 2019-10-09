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
	never: true
	new: true
	override: true
	overwrite: true
	package: true
	private: true
	protected: true
	public: true
	return: true
	sealed: true
	short: true
	static: true
	super: true
	switch: true
	synchronized: true
	this: true
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
	Function
	Hollow
	InlineBlock
	Macro
	Operation
}

abstract class Scope {
	static {
		isTempName(name: String): Boolean => name.length > 5 && name.substr(0, 5) == '__ks_'
	}
	abstract acquireTempName(declare: Boolean = true): String
	private abstract declareVariable(name: String): String?
	abstract define(name: String, immutable: Boolean, type: Type = null, initialized: Boolean = false, node: AbstractNode): Variable
	abstract defineVariable(variable: Variable, node: AbstractNode)
	abstract getDefinedVariable(name: String): Variable?
	abstract getRenamedIndex(name: String): Number
	abstract getVariable(name: String, line: Number = -1): Variable
	abstract hasDeclaredVariable(name: String): Boolean
	abstract hasDefinedVariable(name: String): Boolean
	abstract hasVariable(name: String, line: Number = -1): Boolean
	hasMacro(name: String): Boolean => false
	isBleeding(): Boolean => false
	isInline(): Boolean => false
	isPredefinedVariable(name: String): Boolean => (variable ?= this.getVariable(name)) && variable.isPredefined()
	abstract reference(value, nullable: Boolean = false, parameters: Array = []): ReferenceType
	abstract resolveReference(name: String, nullable: Boolean, parameters: Array): ReferenceType
}

include {
	'./scope/bleeding'
	'./scope/block'
	'./scope/function'
	'./scope/hollow'
	'./scope/inline'
	'./scope/import'
	'./scope/macro'
	'./scope/namespace'
	'./scope/module'
	'./scope/operation'
}