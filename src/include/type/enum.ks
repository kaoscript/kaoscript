enum EnumTypeKind<String> {
	Bit
	Number
	String
}

class EnumType extends Type {
	private {
		@alteration: Boolean							= false
		@alterationReference: ClassType?
		@assessment										= null
		@exhaustiveness									= {
			instanceMethods: {}
			staticMethods: {}
		}
		@function: FunctionType?						= null
		@index: Number									= -1
		@instanceAssessments: Dictionary				= {}
		@instanceMethods: Dictionary					= {}
		@kind: EnumTypeKind
		@length: Number?
		@staticAssessments: Dictionary					= {}
		@staticMethods: Dictionary						= {}
		@type: Type
		@variables: Dictionary<EnumVariableType>		= {}
		@sequences	 									= {
			defaults:			-1
			instanceMethods:	{}
			staticMethods:		{}
		}
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): EnumType { # {{{
			var type = new EnumType(scope, EnumTypeKind(data.type))

			type._exhaustive = data.exhaustive
			type._index = data.sequenceIndex

			if ?data.sequences {
				type._sequences.defaults = data.sequences[0]
			}

			if ?data.length {
				type._length = data.length
			}

			for var name in data.variables {
				type.addVariable(name)
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
					for method in methods {
						type.dedupInstanceMethod(name, EnumMethodType.import(method, metadata, references, alterations, queue, scope, node))
					}
				}

				for var methods, name of data.staticMethods {
					for method in methods {
						type.dedupStaticMethod(name, EnumMethodType.import(method, metadata, references, alterations, queue, scope, node))
					}
				}
			})

			return type
		} # }}}
	}
	constructor(@scope, @kind = EnumTypeKind::Number) { # {{{
		super(scope)

		if @kind == EnumTypeKind::String {
			@type = scope.reference('String')
		}
		else {
			@type = scope.reference('Number')
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
		var options = Attribute.configure(data, null, AttributeTarget::Property, node.file())

		switch data.kind {
			NodeKind::FieldDeclaration => {
				this.addVariable(data.name.name)
			}
			NodeKind::MethodDeclaration => {
				var mut instance = true
				for i from 0 til data.modifiers.length while instance {
					instance = false if data.modifiers[i].kind == ModifierKind::Static
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
					this.dedupInstanceMethod(data.name.name!!, type)
				}
				else {
					this.dedupStaticMethod(data.name.name!!, type)
				}
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(data.kind)`, node)
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
	addVariable(name: String) { # {{{
		var variable = new EnumVariableType()

		@variables[name] = variable

		if @alteration {
			variable.flagAlteration()
		}

		return variable
	} # }}}
	assessment(reference: ReferenceType, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess([this.function(reference, node)], reference.name(), node)
		}

		return @assessment
	} # }}}
	clone() { # {{{
		var that = new EnumType(@scope)

		return that.copyFrom(this)
	} # }}}
	copyFrom(src: EnumType) { # {{{
		@alien = src._alien
		@sealed = src._sealed
		@system = src._system
		@requirement = src._requirement
		@required = src._required

		for var methods, name of src._staticMethods {
			@staticMethods[name] = [].concat(methods)
		}
		for var methods, name of src._instanceMethods {
			@instanceMethods[name] = [].concat(methods)
		}

		for var variable, name of src._variables {
			@variables[name] = variable
		}

		@exhaustive = src._exhaustive
		@exhaustiveness = Dictionary.clone(src._exhaustiveness)
		@sequences = Dictionary.clone(src._sequences)

		if @requirement || @alien {
			this.setAlterationReference(src)
		}

		return this
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

		return this.addInstanceMethod(name, type)
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

		return this.addStaticMethod(name, type)
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var exhaustive = this.isExhaustive()

		var export = {
			kind: TypeKind::Enum
			type: @kind
			sequenceIndex: @index
			exhaustive
			variables: [name for var _, name of @variables]
			instanceMethods: {}
			staticMethods: {}
		}

		if @kind == EnumTypeKind::Bit {
			export.length = @length
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

			if !Dictionary.isEmpty(@exhaustiveness.staticMethods) {
				exhaustiveness.staticMethods = @exhaustiveness.staticMethods
				notEmpty = true
			}

			if !Dictionary.isEmpty(@exhaustiveness.instanceMethods) {
				exhaustiveness.instanceMethods = @exhaustiveness.instanceMethods
				notEmpty = true
			}

			if notEmpty {
				export.exhaustiveness = exhaustiveness
			}
		}

		return export
	} # }}}
	function(reference, node) { # {{{
		if @function == null {
			var scope = node.scope()

			@function = new FunctionType(scope)

			@function.addParameter(@type, 'value', 1, 1)

			@function.setReturnType(reference.setNullable(true))
		}

		return @function
	} # }}}
	hasVariable(name: String) => ?@variables[name]
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
	getInstantiableMethod(name: String, type: FunctionType, mode: MatchingMode) { # {{{
		var result = []

		if var methods ?= @instanceMethods[name] {
			for method in methods {
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
	getProperty(name: String) { # {{{
		if name == 'value' {
			return @type
		}
		else {
			return null
		}
	} # }}}
	hasInstanceMethod(name) { # {{{
		if @instanceMethods[name] is Array {
			return true
		}
		else {
			return false
		}
	} # }}}
	hasStaticMethod(name) { # {{{
		if @staticMethods[name] is Array {
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
	hasProperty(name: String) => name == 'value'
	incDefaultSequence() { # {{{
		@sequences.defaults += 1

		return @sequences.defaults
	} # }}}
	index() => @index
	index(@index) => @index
	override isComparableWith(type) { # {{{
		if this.isNumber() {
			return type.canBeNumber()
		}
		else if this.isString() {
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
	isExhaustiveInstanceMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveInstanceMethod(name)
	isExhaustiveStaticMethod(name) { # {{{
		if @exhaustiveness.staticMethods[name] == false {
			return false
		}
		else {
			return true
		}
	} # }}}
	isExhaustiveStaticMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveStaticMethod(name)
	isFlags() => @kind == EnumTypeKind::Bit
	isMergeable(type) => type.isEnum()
	isNumber() => @type.isNumber()
	isString() => @type.isString()
	isSubsetOf(value: EnumType, mode: MatchingMode) => mode ~~ MatchingMode::Similar
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Similar {
			return value.name() == 'Enum'
		}

		return false
	} # }}}
	kind() => @kind
	length(): @length
	length(@length): this
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
	listVariables() => [name for var _, name of @variables]
	setAlterationReference(@alterationReference) { # {{{
		@alteration = true
	} # }}}
	shallBeNamed() => true
	step()  { # {{{
		@index += 1

		return @index
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
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

class EnumVariableType {
	private {
		@alteration: Boolean	= false
	}
	flagAlteration() { # {{{
		@alteration = true

		return this
	} # }}}
	isAlteration() => @alteration
	unflagAlteration() { # {{{
		@alteration = false

		return this
	} # }}}
}

class EnumMethodType extends FunctionType {
	private {
		@access: Accessibility					= Accessibility::Public
		@alteration: Boolean					= false
		@instance: Boolean						= false
	}
	static {
		fromAST(data, node: AbstractNode): EnumMethodType { # {{{
			var scope = node.scope()

			return new EnumMethodType([ParameterType.fromAST(parameter, true, scope, false, node) for parameter in data.parameters], data, node)
		} # }}}
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): EnumMethodType { # {{{
			var data = index
			var type = new EnumMethodType(scope)

			type._identifier = data.id
			type._access = data.access
			type._async = data.async
			type._min = data.min
			type._max = data.max

			queue.push(() => {
				type._errors = [Type.import(error, metadata, references, alterations, queue, scope, node) for error in data.errors]

				type._returnType = Type.import(data.returns, metadata, references, alterations, queue, scope, node)

				type._parameters = [ParameterType.import(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

				type.updateParameters()
			})

			return type
		} # }}}
	}
	clone() { # {{{
		var clone = new EnumMethodType(@scope)

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
			min: @min
			max: @max
			parameters: [parameter.export(references, indexDelta, mode, module) for parameter in @parameters]
			returns: @returnType.toReference(references, indexDelta, mode, module)
			errors: [error.toReference(references, indexDelta, mode, module) for error in @errors]
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
