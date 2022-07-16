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
	false: true
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
	namespace: true
	native: true
	never: true
	new: true
	null: true
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
	struct: true
	super: true
	switch: true
	synchronized: true
	this: true
	throw: true
	throws: true
	transient: true
	true: true
	try: true
	tuple: true
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
	abstract authority(): Scope
	abstract block(): Scope
	private abstract declareVariable(name: String, scope: Scope): String?
	abstract define(name: String, immutable: Boolean, type: Type = null, initialized: Boolean = false, node: AbstractNode): Variable
	abstract defineVariable(variable: Variable, node: AbstractNode)
	abstract getDefinedVariable(name: String): Variable?
	getLineOffset(): Number => 0
	abstract getRenamedIndex(name: String): Number
	abstract getVariable(name: String, line: Number = -1): Variable?
	hasBleedingVariable(name: String): Boolean => this.hasDefinedVariable(name)
	abstract hasDeclaredVariable(name: String): Boolean
	abstract hasDefinedVariable(name: String): Boolean
	hasMacro(name: String): Boolean => false
	abstract hasVariable(name: String, line: Number = -1): Boolean
	isBleeding(): Boolean => false
	isInline(): Boolean => false
	isPredefinedVariable(name: String): Boolean => (variable ?= this.getVariable(name)) && variable.isPredefined()
	isRenamed(name: String, newName: String, scope: Scope, mode: MatchingMode) => name == newName
	line(): Number => 0
	parent() => null
	abstract reference(value): ReferenceType
	abstract resolveReference(name: String): ReferenceType
}

struct VariableBrief {
	name: String
	type: Type
	variable: Boolean	= false
	immutable: Boolean	= false
	lateInit: Boolean	= false
	instance: Boolean	= false
	static: Boolean		= false
	class: String?		= null
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
