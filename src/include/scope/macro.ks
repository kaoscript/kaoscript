// natives
class MacroScope extends Scope {
	private {
		@labelIndex							= -1
		@matchingTypes: Object<Array>		= {}
		@predefined							= {}
		@references							= {}
		@renamedIndexes					 	= {}
		@renamedVariables					= {}
		@variables							= {}
	}
	constructor() { # {{{
		super()

		@predefined.__Array = Variable.createPredefinedClass('Array', this)
		@predefined.__Boolean = Variable.createPredefinedClass('Boolean', this)
		@predefined.__Class = Variable.createPredefinedClass('Class', this)
		@predefined.__Date = Variable.createPredefinedClass('Date', this)
		@predefined.__Enum = Variable.createPredefinedClass('Enum', this)
		@predefined.__Error = Variable.createPredefinedClass('Error', this)
		@predefined.__Function = Variable.createPredefinedClass('Function', this)
		@predefined.__Math = Variable.createPredefinedNamespace('Math', this)
		@predefined.__Namespace = Variable.createPredefinedClass('Namespace', this)
		@predefined.__Number = Variable.createPredefinedClass('Number', this)
		@predefined.__String = Variable.createPredefinedClass('String', this)
		@predefined.__Struct = Variable.createPredefinedClass('Struct', this)
		@predefined.__RegExp = Variable.createPredefinedClass('RegExp', this)
		@predefined.__Tuple = Variable.createPredefinedClass('Tuple', this)

		@predefined.__false = Variable.new('false', true, true, this.reference('Boolean'))
		@predefined.__null = Variable.new('null', true, true, NullType.Explicit)
		@predefined.__true = Variable.new('true', true, true, this.reference('Boolean'))
		@predefined.__Any = Variable.new('Any', true, true, AnyType.Explicit)
		@predefined.__Infinity = Variable.new('Infinity', true, true, this.reference('Number'))
		@predefined.__NaN = Variable.new('NaN', true, true, this.reference('Number'))
		@predefined.__Never = Variable.new('Null', true, true, Type.Never)
		@predefined.__Null = Variable.new('Null', true, true, NullType.Explicit)
		@predefined.__Primitive = Variable.new('Primitive', true, true, AliasType.new(this, UnionType.new(this, [this.reference('Boolean'), this.reference('Number'), this.reference('String')])))
		@predefined.__Object = Variable.createPredefinedClass('Object', ClassFeature.StaticMethod, this)
		@predefined.__Void = Variable.new('Void', true, true, Type.Void)

		// macro types
		@predefined.__Expression = Variable.createPredefinedClass('Expression', this)
		@predefined.__Identifier = Variable.createPredefinedClass('Identifier', this)
	} # }}}
	override acquireNewLabel() { # {{{
		@labelIndex += 1

		return `__ks_lbl_\(@labelIndex)`
	} # }}}
	acquireTempName(declare: Boolean = true) { # {{{
		throw NotSupportedException.new()
	} # }}}
	authority() => this
	block() => this
	override declareVariable(name, scope) { # {{{
		if $keywords[name] || ?@renamedIndexes[name] {
			var mut index = (@renamedIndexes[name] ?? 0) + 1
			var mut newName = '__ks_' + name + '_' + index

			while ?@variables[newName] {
				index += 1
				newName = '__ks_' + name + '_' + index
			}

			@renamedIndexes[name] = index

			return newName
		}
		else {
			return null
		}
	} # }}}
	override define(name, immutable, type, initialized, overwrite, node) { # {{{
		if @hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}
		else if @hasPredefinedVariable(name) {
			var variable = @getPredefinedType(name)

			if variable.isVirtual() {
				SyntaxException.throwAlreadyDeclared(name, node)
			}
			else if ?type && !(type.isAlien() || type.isSystem()) {
				SyntaxException.throwAlreadyDeclared(name, node)
			}
		}

		var variable = Variable.new(name, immutable, false, type, initialized)

		@defineVariable(variable, node)

		return variable
	} # }}}
	override defineVariable(variable, node) { # {{{
		var name = variable.name()

		if ?@variables[name] {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		@variables[name] = variable

		if var newName ?= @declareVariable(name, this) {
			@renamedVariables[name] = newName

			variable.renameAs(newName)
		}

		if var reference ?= @references[name] {
			reference.reset()
		}
	} # }}}
	getDefinedVariable(name: String) { # {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return null
		}
	} # }}}
	override getPredefinedType(name) { # {{{
		if ?@predefined[`__\(name)`] {
			return @predefined[`__\(name)`].getDeclaredType()
		}
		else {
			return null
		}
	} # }}}
	getRenamedIndex(name: String) => ?@renamedIndexes[name] ? @renamedIndexes[name] : 0
	getVariable(name, line = -1): Variable? { # {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else if @predefined[`__\(name)`] is Variable {
			return @predefined[`__\(name)`]
		}
		else {
			return null
		}
	} # }}}
	hasDeclaredVariable(name: String) => ?@variables[name]
	hasDefinedVariable(name: String) => ?@variables[name]
	override hasPredefinedVariable(name) { # {{{
		return @predefined[`__\(name)`] is Variable
	} # }}}
	hasVariable(name: String, line = -1) => ?@variables[name]
	isMatchingType(a: Type, b: Type, mode: MatchingMode) { # {{{
		var hash = a.toQuote()

		if var matches ?= @matchingTypes[hash] {
			for var type, i in matches step 2 {
				if type == b {
					return matches[i + 1]
				}
			}
		}
		else {
			@matchingTypes[hash] = []
		}

		@matchingTypes[hash].push(b, false)

		var index = @matchingTypes[hash].length

		var match = a.isSubsetOf(b, mode)

		@matchingTypes[hash][index - 1] = match

		return match
	} # }}}
	releaseTempName(name) { # {{{
		throw NotSupportedException.new()
	} # }}}
	override resolveReference(name, explicitlyNull, parameters, subtypes) { # {{{
		var hash = ReferenceType.toQuote(name, explicitlyNull, parameters, subtypes)

		@references[hash] ??= ReferenceType.new(this, name, explicitlyNull, parameters, subtypes)

		return @references[hash]
	} # }}}
}
