enum EnumTypeKind<String> {
	Number
	String
}

class EnumType extends Type {
	private {
		@aliases: Object<EnumAliasType>					= {}
		@alteration: Boolean							= false
		@alterationReference: ClassType?
		@assessment										= null
		@exhaustiveness									= {
			instanceMethods: {}
			staticMethods: {}
		}
		@function: FunctionType?						= null
		@generator 										= {
			initial: 0
			step: 1
			next: 0
		}
		@instanceAssessments: Object					= {}
		@instanceMethods: Object						= {}
		@kind: EnumTypeKind
		@nextIndex: Number								= 0
		@staticAssessments: Object						= {}
		@staticMethods: Object							= {}
		@type: Type
		@values: Object<EnumValueType>					= {}
		@sequences	 									= {
			defaults:			-1
			instanceMethods:	{}
			staticMethods:		{}
		}
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): EnumType { # {{{
			var type = EnumType.new(scope, EnumTypeKind(data.type))

			type._exhaustive = data.exhaustive
			type._nextIndex = data.nextIndex

			if ?data.generator {
				type._generator = data.generator
			}

			if ?data.sequences {
				type._sequences.defaults = data.sequences[0]
			}

			for var { name, index? } in data.values {
				var value = EnumValueType.new(name, index)

				type.addValue(value)
			}

			for var { name, originals, top? } in data.aliases {
				var value = EnumAliasType.new(name, originals, top)

				type.addAlias(value)
			}

			if data.exhaustive && ?data.exhaustiveness {
				if ?data.exhaustiveness.instanceMethods {
					type._exhaustiveness.instanceMethods = data.exhaustiveness.instanceMethods
				}

				if ?data.exhaustiveness.staticMethods {
					type._exhaustiveness.staticMethods = data.exhaustiveness.staticMethods
				}
			}

			queue.push(() => {
				for var methods, name of data.instanceMethods {
					for var method in methods {
						type.dedupInstanceMethod(name, EnumMethodType.import(method, metadata, references, alterations, queue, scope, node))
					}
				}

				for var methods, name of data.staticMethods {
					for var method in methods {
						type.dedupStaticMethod(name, EnumMethodType.import(method, metadata, references, alterations, queue, scope, node))
					}
				}
			})

			return type.flagComplete()
		} # }}}
	}
	constructor(@scope, @kind = EnumTypeKind.Number) { # {{{
		super(scope)

		if @kind == EnumTypeKind.String {
			@type = scope.reference('String')
		}
		else {
			@type = scope.reference('Number')
		}
	} # }}}
	addAlias(value: EnumAliasType) { # {{{
		@aliases[value.name()] = value

		if @alteration {
			value.flagAlteration()
		}

		return value
	} # }}}
	addInstanceMethod(name: String, type: EnumMethodType): Number? { # {{{
		@sequences.instanceMethods[name] ??= 0

		var mut index = type.index()
		if index == -1 {
			index = @sequences.instanceMethods[name]

			@sequences.instanceMethods[name] += 1

			type.index(index)
		}
		else {
			if index >= @sequences.instanceMethods[name] {
				@sequences.instanceMethods[name] = index + 1
			}
		}

		if @instanceMethods[name] is Array {
			@instanceMethods[name].push(type)
		}
		else {
			@instanceMethods[name] = [type]
		}

		type.flagInstance()

		if @alteration {
			type.flagAlteration()
		}

		return index
	} # }}}
	addPropertyFromAST(data, node) { # {{{
		var options = Attribute.configure(data, null, AttributeTarget.Property, node.file())

		match data.kind {
			NodeKind.EnumValue {
				@createValue(data.name.name)
			}
			NodeKind.MethodDeclaration {
				var mut instance = true
				for i from 0 to~ data.modifiers.length while instance {
					instance = false if data.modifiers[i].kind == ModifierKind.Static
				}

				var type = EnumMethodType.fromAST(data, node)

				if options.rules.nonExhaustive {
					if instance {
						@exhaustiveness.instanceMethods[data.name.name] = false
					}
					else {
						@exhaustiveness.staticMethods[data.name.name] = false
					}
				}

				if instance {
					@dedupInstanceMethod(data.name.name!!, type)
				}
				else {
					@dedupStaticMethod(data.name.name!!, type)
				}
			}
			else {
				throw NotSupportedException.new(`Unexpected kind \(data.kind)`, node)
			}
		}
	} # }}}
	addStaticMethod(name: String, type: EnumMethodType): Number? { # {{{
		if @staticMethods[name] is not Array {
			@staticMethods[name] = []
			@sequences.staticMethods[name] = 0
		}

		var mut index = type.index()
		if index == -1 {
			index = @sequences.staticMethods[name]

			@sequences.staticMethods[name] += 1

			type.index(index)
		}
		else {
			if index >= @sequences.staticMethods[name] {
				@sequences.staticMethods[name] = index + 1
			}
		}

		@staticMethods[name].push(type)

		if @alteration {
			type.flagAlteration()
		}

		return index
	} # }}}
	addValue(value: EnumValueType) { # {{{
		@values[value.name()] = value

		if @alteration {
			value.flagAlteration()
		}

		return value
	} # }}}
	assessment(reference: ReferenceType, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess([@function(reference, node)], reference.name(), node)
		}

		return @assessment
	} # }}}
	clone() { # {{{
		var that = EnumType.new(@scope)

		return that.copyFrom(this)
	} # }}}
	copyFrom(src: EnumType) { # {{{
		@alien = src._alien
		@sealed = src._sealed
		@system = src._system
		@requirement = src._requirement
		@required = src._required

		@generator = {...src._generator}
		@nextIndex = src._nextIndex

		for var methods, name of src._staticMethods {
			@staticMethods[name] = [...methods!?]
		}
		for var methods, name of src._instanceMethods {
			@instanceMethods[name] = [...methods!?]
		}

		@aliases = {...src._aliases}
		@values = {...src._values}

		@exhaustive = src._exhaustive
		@exhaustiveness = Object.clone(src._exhaustiveness)
		@sequences = Object.clone(src._sequences)

		if @requirement || @alien {
			this.setAlterationReference(src)
		}

		return this
	} # }}}
	createAlias(name: String): EnumAliasType { # {{{
		var type = EnumAliasType.new(name)

		@addAlias(type)

		return type
	} # }}}
	createValue(name: String): { type: EnumValueType, value: String } { # {{{
		var late type, value

		if @kind == .Number {
			type = EnumValueType.new(name, @nextIndex)
			value = `\(@generator.next)`

			@generator.next += @generator.step
		}
		else {
			type = EnumValueType.new(name, @nextIndex)
			value = $quote(name.toLowerCase())
		}

		@addValue(type)

		@nextIndex += 1

		return { type, value }
	} # }}}
	createValue(name: String, value: String): { type: EnumValueType, value: String } { # {{{
		var type = EnumValueType.new(name, @nextIndex)
		var result = $quote(value)

		@addValue(type)

		@nextIndex += 1

		return { type, value: result }
	} # }}}
	createValue(name: String, value: Number): { type: EnumValueType, value: String } { # {{{
		var type = EnumValueType.new(name, @nextIndex)

		@addValue(type)

		@nextIndex += 1
		@generator.next = value + @generator.step

		return { type, value: `\(value)` }

	} # }}}
	dedupInstanceMethod(name: String, type: EnumMethodType): Number? { # {{{
		if var index ?= type.index() {
			if @instanceMethods[name] is Array {
				for var method in @instanceMethods[name] {
					if method.index() == index {
						return index
					}
				}
			}
		}

		return @addInstanceMethod(name, type)
	} # }}}
	dedupStaticMethod(name: String, type: EnumMethodType): Number? { # {{{
		if var index ?= type.index() {
			if @staticMethods[name] is Array {
				for var method in @staticMethods[name] {
					if method.index() == index {
						return index
					}
				}
			}
		}

		return @addStaticMethod(name, type)
	} # }}}
	explodeVarnames(...values: { name: String }): String[] { # {{{
		var result = []

		for var { name } in values {
			var value = @values[name] ?? @aliases[name]

			result.pushUniq(name)

			if value.isAlias() {
				result.pushUniq(...value.originals()!?)
			}
		}

		return result
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var exhaustive = @isExhaustive()

		var export = {
			kind: TypeKind.Enum
			type: @kind
			exhaustive
			nextIndex: @nextIndex
			values: [value.export(references, indexDelta, mode, module) for var value of @values]
			aliases: [alias.export(references, indexDelta, mode, module) for var alias of @aliases]
			instanceMethods: {}
			staticMethods: {}
		}

		if @kind == .Number {
			export.generator = @generator
		}

		for var methods, name of @instanceMethods {
			export.instanceMethods[name] = [method.export(references, indexDelta, mode, module) for var method in methods when method.isExportable(mode)]
		}

		for var methods, name of @staticMethods {
			export.staticMethods[name] = [method.export(references, indexDelta, mode, module) for var method in methods when method.isExportable(mode)]
		}

		export.sequences = [
			@sequences.defaults
		]

		if exhaustive {
			var exhaustiveness = {}
			var mut notEmpty = false

			if !Object.isEmpty(@exhaustiveness.staticMethods) {
				exhaustiveness.staticMethods = @exhaustiveness.staticMethods
				notEmpty = true
			}

			if !Object.isEmpty(@exhaustiveness.instanceMethods) {
				exhaustiveness.instanceMethods = @exhaustiveness.instanceMethods
				notEmpty = true
			}

			if notEmpty {
				export.exhaustiveness = exhaustiveness
			}
		}

		return export
	} # }}}
	function(): valueof @function
	function(reference, node) { # {{{
		if @function == null {
			var scope = node.scope()

			@function = FunctionType.new(scope)

			@function.addParameter(@type, 'value', 1, 1)

			@function.setReturnType(reference.setNullable(true))
		}

		return @function
	} # }}}
	getInstanceAssessment(name: String, node: AbstractNode) { # {{{
		if var assessment ?= @instanceAssessments[name] {
			return assessment
		}
		else if var methods ?= @instanceMethods[name] {
			var assessment = Router.assess([...methods], name, node)

			@instanceAssessments[name] = assessment

			return assessment
		}
		else {
			return null
		}
	} # }}}
	getInstanceProperty(name: String) { # {{{
		if name == 'value' {
			return @type
		}
		else if var methods ?#= @instanceMethods[name] {
			if methods.length == 1 {
				return methods[0]
			}
		}

		return null
	} # }}}
	getInstantiableMethod(name: String, type: FunctionType, mode: MatchingMode) { # {{{
		var result = []

		if var methods ?= @instanceMethods[name] {
			for var method in methods {
				if method.isSubsetOf(type, mode) {
					result.push(method)
				}
			}
		}

		if result.length == 1 {
			return result[0]
		}
		else {
			return null
		}
	} # }}}
	getOnlyAliases() => @aliases
	getOriginalValueCount(...names: { name: String }): Number { # {{{
		var mut result = 0

		for var { name } in names {
			if var value ?= @aliases[name] {
				result += value.originals().length:Number
			}
			else {
				result += 1
			}
		}

		return result
	} # }}}
	getStaticAssessment(name: String, node: AbstractNode) { # {{{
		if var assessment ?= @staticAssessments[name] {
			return assessment
		}
		else if var methods ?= @staticMethods[name] {
			var assessment = Router.assess([...methods], name, node)

			@staticAssessments[name] = assessment

			return assessment
		}
		else {
			return null
		}
	} # }}}
	getStaticMethod(name: String): Type? { # {{{
		if var methods ?#= @staticMethods[name] {
			if methods.length == 1 {
				return methods[0]
			}
		}

		return null
	} # }}}
	getTopProperty(name: String): String { # {{{
		if var value ?= @aliases[name] {
			return value.getTopAlias() ?? name
		}
		else {
			return name
		}
	} # }}}
	getValue(name: String) => @values[name] ?? @aliases[name]
	hasInstanceMethod(name) { # {{{
		if @instanceMethods[name] is Array {
			return true
		}
		else {
			return false
		}
	} # }}}
	hasMatchingInstanceMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @instanceMethods[name] is Array {
			for var method in @instanceMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} # }}}
	hasMatchingStaticMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @staticMethods[name] is Array {
			for var method in @staticMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} # }}}
	hasProperty(name: String) => ?@values[name] || ?@aliases[name]
	hasStaticMethod(name: String) => ?@staticMethods[name]
	hasValue(name: String) => ?@values[name] || ?@aliases[name]
	incDefaultSequence() { # {{{
		@sequences.defaults += 1

		return @sequences.defaults
	} # }}}
	override isComparableWith(type) { # {{{
		if @isNumber() {
			return type.canBeNumber()
		}
		else if @isString() {
			return type.canBeString()
		}
		else {
			return false
		}
	} # }}}
	isEnum() => true
	isExhaustiveInstanceMethod(name) { # {{{
		if @exhaustiveness.instanceMethods[name] == false {
			return false
		}
		else {
			return true
		}
	} # }}}
	isExhaustiveInstanceMethod(name, node) => @isExhaustive(node) && @isExhaustiveInstanceMethod(name)
	isExhaustiveStaticMethod(name) { # {{{
		if @exhaustiveness.staticMethods[name] == false {
			return false
		}
		else {
			return true
		}
	} # }}}
	isExhaustiveStaticMethod(name, node) => @isExhaustive(node) && @isExhaustiveStaticMethod(name)
	isMergeable(type) => type.isEnum()
	isNumber() => @type.isNumber()
	isString() => @type.isString()
	assist isSubsetOf(value: EnumType, generics, subtypes, mode) => mode ~~ MatchingMode.Similar
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Similar {
			return value.name() == 'Enum'
		}

		return false
	} # }}}
	kind() => @kind
	listMatchingInstanceMethods(name, type: FunctionType, mode: MatchingMode) { # {{{
		var results: Array = []

		if @instanceMethods[name] is Array {
			for var method in @instanceMethods[name] {
				if method.isMatching(type, mode) {
					results.push(method)
				}
			}
		}

		return results
	} # }}}
	listValueNames() => [name for var value, name of @values]
	setAlterationReference(@alterationReference) { # {{{
		@alteration = true
	} # }}}
	shallBeNamed() => true
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new()
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('enum', @sequences.defaults)

		for var sequence, name of @sequences.staticMethods {
			variations.push(name, sequence)
		}

		for var sequence, name of @sequences.instanceMethods {
			variations.push(name, sequence)
		}
	} # }}}
	type() => @type
}

class EnumValueType {
	private {
		@alteration: Boolean	= false
		@index: Number?			= null
		@name: String
	}
	constructor(@name)
	constructor(@name, @index)
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			@name
			@index if ?@index
		}
	} # }}}
	flagAlteration() { # {{{
		@alteration = true

		return this
	} # }}}
	index() => @index
	isAlias() => false
	isAlteration() => @alteration
	isTopDerivative() => false
	name() => @name
	unflagAlteration() { # {{{
		@alteration = false

		return this
	} # }}}
}

class EnumAliasType {
	private {
		@alteration: Boolean	= false
		@name: String
		@originals:	String[]	= []
		@top: String?			= null
	}
	constructor(@name)
	constructor(@name, @originals, @top)
	addAlias(name: String, enum: EnumType) { # {{{
		if var value ?= enum.getValue(name) ;; value.isAlias() {
			@originals.pushUniq(...value.originals()!?)
		}
		else {
			@originals.pushUniq(name)
		}
	} # }}}
	addOriginals(...names: String) { # {{{
		@originals.pushUniq(...names)
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			@name
			@originals
			@top if ?@top
		}
	} # }}}
	flagAlteration() { # {{{
		@alteration = true

		return this
	} # }}}
	getTopAlias() => @top
	isAlias() => true
	isAlteration() => @alteration
	isDerivative() => @originals.length > 1
	isTopDerivative() => @originals.length > 1 && !?@top
	name() => @name
	original() => @originals[0]
	originals() => @originals
	setAlias(name: String, enum: EnumType) { # {{{
		if var value ?= enum.getValue(name) ;; value.isAlias() {
			@originals.pushUniq(...value.originals()!?)

			if @originals.length > 1 {
				@top = value.getTopAlias() ?? name
			}
		}
		else {
			@originals.pushUniq(name)
		}
	} # }}}
}

class EnumMethodType extends FunctionType {
	private {
		@access: Accessibility					= Accessibility.Public
		@alteration: Boolean					= false
		@instance: Boolean						= false
	}
	static {
		fromAST(data, node: AbstractNode): EnumMethodType { # {{{
			var scope = node.scope()

			return EnumMethodType.new([ParameterType.fromAST(parameter, true, scope, false, null, node) for var parameter in data.parameters], data, node)
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): EnumMethodType { # {{{
			var data = index
			var type = EnumMethodType.new(scope)

			type._identifier = data.id
			type._access = data.access
			type._async = data.async

			queue.push(() => {
				type._errors = [Type.import(error, metadata, references, alterations, queue, scope, node) for var error in data.errors]

				type._returnType = Type.import(data.returns, metadata, references, alterations, queue, scope, node)

				for var parameter in data.parameters {
					type.addParameter(ParameterType.import(parameter, metadata, references, alterations, queue, scope, node), node)
				}
			})

			return type
		} # }}}
	}
	clone() { # {{{
		var clone = EnumMethodType.new(@scope)

		FunctionType.clone(this, clone)

		clone._access = @access
		clone._alteration = @alteration
		clone._index = @index

		return clone
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var export = {
			index: @index
			access: @access
			async: @async
			parameters: [parameter.export(references, indexDelta, mode, module) for var parameter in @parameters]
			returns: @returnType.toReference(references, indexDelta, mode, module)
			errors: [error.toReference(references, indexDelta, mode, module) for var error in @errors]
		}

		return export
	} # }}}
	flagAlteration() { # {{{
		@alteration = true

		return this
	} # }}}
	flagInstance() { # {{{
		@instance = true

		return this
	} # }}}
	isInstance() => @instance
	isMethod() => true
}
