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
	InlineFunction
	Macro
	Method
	Operation
}

abstract class Scope {
	static {
		isTempName(name: String): Boolean => name.length > 5 && name.substr(0, 5) == '__ks_'
	}
	acquireUnusedTempName(): String? => null
	checkVariable(name: String, rebindable: Boolean, node): Void ~ ReferenceException { # {{{
		if var variable ?= @getVariable(name) {
			if rebindable && variable.isImmutable() {
				ReferenceException.throwImmutable(name, node)
			}
		}
		else {
			ReferenceException.throwNotDefined(name, node)
		}
	} # }}}
	commitTempVariables(variables: Array): Void
	getChunkType(name: String, line: Number?): Type? => null
	getLineOffset(): Number => 0
	getMacro(name: String): MacroDeclaration? => null
	getRawLine(): Number => 0
	getTempIndex(): Number => -1
	hasBleedingVariable(name: String): Boolean => @hasDefinedVariable(name)
	hasMacro(name: String): Boolean => false
	isBleeding(): Boolean => false
	isInline(): Boolean => false
	isPredefinedVariable(name: String): Boolean { # {{{
		if var variable ?= @getVariable(name) {
			return variable.isPredefined()
		}
		else {
			return false
		}
	} # }}}
	isRenamed(name: String, newName: String, scope: Scope, mode: MatchingMode) => name == newName
	isRenamedVariable(name: String): Boolean => false
	line(): Number => 0
	module(): ModuleScope? => null
	parent(): Scope? => null
	reference(value: AnyType): ReferenceType => @resolveReference('Any')
	reference(value: ArrayType): ReferenceType { # {{{
		if value.hasProperties() {
			throw NotSupportedException.new()
		}

		if value.hasRest() {
			return @resolveReference('Array', value.isNullable(), [value.parameter()])
		}

		return @resolveReference('Array', value.isNullable())
	} # }}}
	reference(value: ClassVariableType): ReferenceType => @reference(value.type())
	reference(value: NamedType): ReferenceType { # {{{
		if value.hasContainer() {
			return value.container().scope().reference(value.name())
		}
		else {
			return @resolveReference(value.name())
		}
	} # }}}
	reference(value: ObjectType): ReferenceType { # {{{
		if value.hasProperties() {
			throw NotSupportedException.new()
		}

		if value.hasRest() {
			return @resolveReference('Object', value.isNullable(), [value.parameter()])
		}

		return @resolveReference('Object', value.isNullable())
	} # }}}
	reference(value: ReferenceType): ReferenceType => @resolveReference(value.name(), value.isExplicitlyNull(), [...value.parameters()])
	reference(value: Variable): ReferenceType => @resolveReference(value.name())
	reference(value: Type): ReferenceType { # {{{
		throw NotImplementedException.new()
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
		getPredefinedType(name: String): Type?
		getRenamedIndex(name: String): Number
		getVariable(name: String, line: Number = -1): Variable?
		hasDeclaredVariable(name: String): Boolean
		hasDefinedVariable(name: String): Boolean
		hasPredefinedVariable(name: String): Boolean
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
	'./scope/bleeding.ks'
	'./scope/block.ks'
	'./scope/function.ks'
	'./scope/hollow.ks'
	'./scope/inline.ks'
	'./scope/import.ks'
	'./scope/macro.ks'
	'./scope/namespace.ks'
	'./scope/method.ks'
	'./scope/module.ks'
	'./scope/operation.ks'
}
