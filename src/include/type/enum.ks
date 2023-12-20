enum EnumTypeKind<String> {
	Number
	String
}

class EnumType extends Type {
	private {
		@aliases: Object<EnumAliasType>					= {}
		@alteration: Boolean							= false
		@alterationReference: ClassType?
		@exhaustiveness									= {
			instanceMethods: {}
			staticMethods: {}
		}
		@fields: EnumFieldType{}						= {}
		@fieldAssessment?
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
		@staticFields: Object							= {}
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
				var value = EnumValueType.new(name, index, null)

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
				for var field in data.fields {
					type.addField(EnumFieldType.import(field, metadata, references, alterations, queue, scope, node))
				}

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
	addField(type: EnumFieldType) { # {{{
		@fields[type.name()] = type

		if @alteration {
			type.flagAlteration()
		}
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
	buildMatcher(name: String, node) { # {{{
		var fn = FunctionType.new(node.scope())

		for var field of @fields when !field.isInbuilt() {
			fn.addParameter(field.type(), field.name(), 1, 1)
		}

		@fieldAssessment = Router.assess([fn], name, node)
	} # }}}
	override canBeRawCasted() => true
	override canBeString(_) => @type.isString()
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
			type = EnumValueType.new(name, @nextIndex, @generator.next)
			value = `\(type.value())`

			@generator.next += @generator.step
		}
		else {
			type = EnumValueType.new(name, @nextIndex, name.toLowerCase())
			value = $quote(type.value())
		}

		@addValue(type)

		@nextIndex += 1

		return { type, value }
	} # }}}
	createValue(name: String, value: String): { type: EnumValueType, value: String } { # {{{
		var type = EnumValueType.new(name, @nextIndex, value)
		var result = $quote(type.value())

		@addValue(type)

		@nextIndex += 1

		return { type, value: result }
	} # }}}
	createValue(name: String, value: Number): { type: EnumValueType, value: String } { # {{{
		var type = EnumValueType.new(name, @nextIndex, value)

		@addValue(type)

		@nextIndex += 1
		@generator.next = value + @generator.step

		return { type, value: `\(type.value())` }

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
			fields: [field.export(references, indexDelta, mode, module) for var field, name of @fields when !field.isInbuilt()]
			instanceMethods: {}
			staticMethods: {}
		}

		if @kind == .Number {
			export.generator = @generator
		}

		for var methods, name of @instanceMethods {
			var exports = [method.export(references, indexDelta, mode, module) for var method in methods when !method.isInbuilt() && method.isExportable(mode)]

			export.instanceMethods[name] = exports if ?#exports
		}

		for var methods, name of @staticMethods {
			var exports = [method.export(references, indexDelta, mode, module) for var method in methods when !method.isInbuilt() && method.isExportable(mode)]

			export.staticMethods[name] = exports if ?#exports
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
	fields() => @fields
	fieldAssessment() => @fieldAssessment
	fillProperties(name: String, node) { # {{{
		@fields['index'] = EnumFieldType.new(@scope, 'index', @scope.reference('Number')).flagInbuilt()
		@fields['name'] = EnumFieldType.new(@scope, 'name', @scope.reference('String')).flagInbuilt()
		@fields['value'] = EnumFieldType.new(@scope, 'value', @type).flagInbuilt()

		@staticFields['values'] = Type.arrayOf(@scope.reference(name), @scope)
		@staticFields['fields'] = Type.arrayOf(@scope.reference('String'), @scope)

		var thisType = @scope.reference(name).setNullable(true)

		@staticMethods['fromIndex'] = [
			EnumMethodType.new([ParameterType.new(@scope, @scope.reference('Number').setNullable(true), 1, 1)], {}, node).setReturnType(thisType).flagInbuilt()
		]
		@staticMethods['fromName'] = [
			EnumMethodType.new([ParameterType.new(@scope, @scope.reference('String').setNullable(true), 1, 1)], {}, node).setReturnType(thisType).flagInbuilt()
		]
		@staticMethods['fromValue'] = [
			EnumMethodType.new([ParameterType.new(@scope, @type.setNullable(true), 1, 1)], {}, node).setReturnType(thisType).flagInbuilt()
		]
	} # }}}
	getField(name: String) => @fields[name]
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
		if var methods ?#= @instanceMethods[name] {
			if methods.length == 1 {
				return methods[0]
			}
		}
		else if var field ?= @fields[name] {
			return field
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
	getStaticProperty(name: String) { # {{{
		if var methods ?#= @staticMethods[name] {
			if methods.length == 1 {
				return methods[0]
			}
		}
		else if var field ?= @staticFields[name] {
			return field
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
	hasField(name: String) => ?@fields[name]
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
	listFieldNames() => [name for var _, name of @fields]
	listValueNames() => [name for var _, name of @values]
	matchValueArguments(arguments, node) { # {{{
		return Router.matchArguments(@fieldAssessment, null, arguments, null, node)
	} # }}}
	setAlterationReference(@alterationReference) { # {{{
		@alteration = true
	} # }}}
	setInitialValue()
	setGenerator(initial: Expression, step: Expression? = null) { # {{{
		if initial is NumberLiteral {
			@generator.initial = @generator.next = initial.value()
		}
		else {
			NotImplementedException.throw()
		}

		if ?step {
			if step is NumberLiteral {
				@generator.step = step.value()
			}
			else {
				NotImplementedException.throw()
			}
		}
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
	values() => @values
}

class EnumValueType {
	private {
		@alteration: Boolean	= false
		@arguments: String{}	= {}
		@index: Number?			= null
		@name: String
		@value?
	}
	constructor(@name)
	// TODO!
	// constructor(@name, @index, @value)
	constructor(@name, @index, @value = null)
	argument(name: String) => @arguments[name]
	argument(name: String, value: String) { # {{{
		@arguments[name] = value
	} # }}}
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
	value() => @value
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

class EnumFieldType extends Type {
	private {
		@access: Accessibility	= Accessibility.Public
		@default: Boolean		= false
		@inbuilt: Boolean		= false
		@name: String
		@type: Type
	}
	static {
		fromAST(data, node: AbstractNode): EnumFieldType { # {{{
			var scope = node.scope()

			var type = if ?data.type {
				set EnumFieldType.new(scope, data.name.name, Type.fromAST(data.type, node))
			}
			else {
				set EnumFieldType.new(scope, data.name.name, Type.Unknown)
			}

			if ?data.modifiers {
				for var modifier in data.modifiers {
					match ModifierKind(modifier.kind) {
						ModifierKind.Internal {
							type.access(Accessibility.Internal)
						}
						ModifierKind.Private {
							type.access(Accessibility.Private)
						}
						ModifierKind.Protected {
							type.access(Accessibility.Protected)
						}
					}
				}
			}

			if ?data.value {
				type._default = true
			}

			return type
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): EnumFieldType { # {{{
			var data = index
			var type = EnumFieldType.new(scope, data.name, Type.import(data.type, metadata, references, alterations, queue, scope, node))

			type._access = Accessibility(data.access) ?? .Public
			type._default = data.default

			return type
		} # }}}
	}
	constructor(@scope, @name, @type) { # {{{
		super(scope)
	} # }}}
	access() => @access
	access(@access) => this
	override clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	discardVariable() => @type
	override export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var data = {
			access: @access
			name: @name
			type: @type.toReference(references, indexDelta, mode, module)
			default: @default
		}

		return data
	} # }}}
	flagInbuilt() { # {{{
		@inbuilt = true

		return this
	} # }}}
	isInbuilt() => @inbuilt
	name() => @name
	override toFragments(fragments, node)
	override toVariations(variations)
	type(): valueof @type
	type(@type): valueof this
}

class EnumMethodType extends FunctionType {
	private {
		@access: Accessibility			= Accessibility.Public
		@alteration: Boolean			= false
		@inbuilt: Boolean				= false
		@instance: Boolean				= false
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
	flagInbuilt() { # {{{
		@inbuilt = true

		return this
	} # }}}
	flagInstance() { # {{{
		@instance = true

		return this
	} # }}}
	isInbuilt() => @inbuilt
	isInstance() => @instance
	isMethod() => true
}
