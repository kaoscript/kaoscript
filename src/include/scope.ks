var $keywords = { # {{{
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
} # }}}

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
	acquireUnusedTempName(): String? => null
	commitTempVariables(variables: Array): Void
	getChunkType(name: String, line: Number?): Type? => null
	getLineOffset(): Number => 0
	getMacro(data, parent): MacroDeclaration? => null
	getRawLine(): Number => 0
	getTempIndex(): Number => -1
	hasBleedingVariable(name: String): Boolean => @hasDefinedVariable(name)
	hasMacro(name: String): Boolean => false
	isBleeding(): Boolean => false
	isInline(): Boolean => false
	isPredefinedVariable(name: String): Boolean => (variable ?= @getVariable(name)) && variable.isPredefined()
	isRenamed(name: String, newName: String, scope: Scope, mode: MatchingMode) => name == newName
	isRenamedVariable(name: String): Boolean => false
	line(): Number => 0
	module(): ModuleScope? => null
	parent(): Scope? => null
	reference(value: AnyType): ReferenceType => @resolveReference('Any')
	reference(value: ArrayType): ReferenceType { # {{{
		if value.hasProperties() {
			throw new NotSupportedException()
		}

		if value.hasRest() {
			return @resolveReference('Array', value.isNullable(), [value.parameter()])
		}

		return @resolveReference('Array', value.isNullable())
	} # }}}
	reference(value: ClassVariableType): ReferenceType => this.reference(value.type())
	reference(value: DictionaryType): ReferenceType { # {{{
		if value.hasProperties() {
			throw new NotSupportedException()
		}

		if value.hasRest() {
			return @resolveReference('Dictionary', value.isNullable(), [value.parameter()])
		}

		return @resolveReference('Dictionary', value.isNullable())
	} # }}}
	reference(value: NamedType): ReferenceType { # {{{
		if value.hasContainer() {
			return value.container().scope().reference(value.name())
		}
		else {
			return @resolveReference(value.name())
		}
	} # }}}
	reference(value: ReferenceType): ReferenceType => @resolveReference(value.name(), value.isExplicitlyNull(), [...value.parameters()])
	reference(value: Variable): ReferenceType => @resolveReference(value.name())
	reference(value: Type): ReferenceType { # {{{
		throw new NotImplementedException()
	} # }}}
	reference(value: String, nullable: Boolean = false, parameters: Array = []): ReferenceType { # {{{
		return @resolveReference(value, nullable, parameters)
	} # }}}
	renameNext(name: String, line: Number): Void
	abstract {
		acquireTempName(declare: Boolean = true): String
		authority(): Scope
		block(): Scope
		define(name: String, immutable: Boolean, type: Type? = null, initialized: Boolean = false, node: AbstractNode): Variable
		defineVariable(variable: Variable, node: AbstractNode): Void
		getDefinedVariable(name: String): Variable?
		getRenamedIndex(name: String): Number
		getVariable(name: String, line: Number = -1): Variable?
		hasDeclaredVariable(name: String): Boolean
		hasDefinedVariable(name: String): Boolean
		hasVariable(name: String, line: Number = -1): Boolean
		isMatchingType(a: Type, b: Type, mode: MatchingMode): Boolean
		releaseTempName(name: String): Void
		resolveReference(name: String, explicitlyNull: Boolean = false, parameters: Array = []): ReferenceType
	}
	private abstract {
		declareVariable(name: String, scope: Scope): String?
	}
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
