enum EnumTypeKind<String> {
	Flags
	Number
	String
}

class EnumType extends Type {
	private {
		@alteration: Boolean							= false
		@alterationReference: ClassType?
		@exhaustiveness									= {
			instanceMethods: {}
			staticMethods: {}
		}
		@index: Number									= -1
		@instanceAssessments: Dictionary				= {}
		@instanceMethods: Dictionary					= {}
		@kind: EnumTypeKind
		@staticAssessments: Dictionary					= {}
		@staticMethods: Dictionary						= {}
		@type: Type
		@variables: Dictionary<EnumVariableType>		= {}
		@sequences	 									= {
			instanceMethods:	{}
			staticMethods:		{}
		}
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new EnumType(scope, EnumTypeKind.from(data.type))

			type._exhaustive = data.exhaustive
			type._index = data.index

			for const name in data.variables {
				type.addVariable(name)
			}

			if data.exhaustive && data.exhaustiveness? {
				if data.exhaustiveness.instanceMethods? {
					type._exhaustiveness.instanceMethods = data.exhaustiveness.instanceMethods
				}

				if data.exhaustiveness.staticMethods? {
					type._exhaustiveness.staticMethods = data.exhaustiveness.staticMethods
				}
			}

			for const methods, name of data.instanceMethods {
				for method in methods {
					type.dedupInstanceMethod(name, EnumMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
				}
			}

			for const methods, name of data.staticMethods {
				for method in methods {
					type.dedupStaticMethod(name, EnumMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
				}
			}

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new EnumType(scope, EnumTypeKind.from(data.type))

			type._exhaustive = data.exhaustive
			type._index = data.index

			for const name in data.variables {
				type.addVariable(name)
			}

			if data.exhaustive && data.exhaustiveness? {
				if data.exhaustiveness.instanceMethods? {
					type._exhaustiveness.instanceMethods = data.exhaustiveness.instanceMethods
				}

				if data.exhaustiveness.staticMethods? {
					type._exhaustiveness.staticMethods = data.exhaustiveness.staticMethods
				}
			}

			queue.push(() => {
				for const methods, name of data.instanceMethods {
					for method in methods {
						type.dedupInstanceMethod(name, EnumMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
					}
				}

				for const methods, name of data.staticMethods {
					for method in methods {
						type.dedupStaticMethod(name, EnumMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
					}
				}
			})

			return type
		} // }}}
	}
	constructor(@scope, @kind = EnumTypeKind::Number) { // {{{
		super(scope)

		if @kind == EnumTypeKind::String {
			@type = scope.reference('String')
		}
		else {
			@type = scope.reference('Number')
		}
	} // }}}
	addInstanceMethod(name: String, type: EnumMethodType): Number? { // {{{
		@sequences.instanceMethods[name] ??= 0

		let id = type.identifier()
		if id == -1 {
			id = @sequences.instanceMethods[name]++

			type.identifier(id)
		}
		else {
			if id >= @sequences.instanceMethods[name] {
				@sequences.instanceMethods[name] = id + 1
			}
		}

		if @instanceMethods[name] is Array {
			@instanceMethods[name].push(type)
		}
		else {
			@instanceMethods[name] = [type]
		}

		if @alteration {
			type.flagAlteration()
		}

		return id
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		const options = Attribute.configure(data, null, AttributeTarget::Property, node.file())

		switch data.kind {
			NodeKind::FieldDeclaration => {
				this.addVariable(data.name.name)
			}
			NodeKind::MethodDeclaration => {
				let instance = true
				for i from 0 til data.modifiers.length while instance {
					instance = false if data.modifiers[i].kind == ModifierKind::Static
				}

				const type = EnumMethodType.fromAST(data, node)

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
	} // }}}
	addStaticMethod(name: String, type: EnumMethodType): Number? { // {{{
		if @staticMethods[name] is not Array {
			@staticMethods[name] = []
			@sequences.staticMethods[name] = 0
		}

		let id = type.identifier()
		if id == -1 {
			id = @sequences.staticMethods[name]++

			type.identifier(id)
		}
		else {
			if id >= @sequences.staticMethods[name] {
				@sequences.staticMethods[name] = id + 1
			}
		}

		@staticMethods[name].push(type)

		if @alteration {
			type.flagAlteration()
		}

		return id
	} // }}}
	addVariable(name: String) { // {{{
		const variable = new EnumVariableType()

		@variables[name] = variable

		if @alteration {
			variable.flagAlteration()
		}

		return variable
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	dedupInstanceMethod(name: String, type: EnumMethodType): Number? { // {{{
		if const id = type.identifier() {
			if @instanceMethods[name] is Array {
				for const method in @instanceMethods[name] {
					if method.identifier() == id {
						return id
					}
				}
			}
		}

		return this.addInstanceMethod(name, type)
	} // }}}
	dedupStaticMethod(name: String, type: EnumMethodType): Number? { // {{{
		if const id = type.identifier() {
			if @staticMethods[name] is Array {
				for const method in @staticMethods[name] {
					if method.identifier() == id {
						return id
					}
				}
			}
		}

		return this.addStaticMethod(name, type)
	} // }}}
	export(references, mode) { // {{{
		const exhaustive = this.isExhaustive()

		const export = {
			kind: TypeKind::Enum
			type: @kind
			index: @index
			exhaustive
			variables: [name for const _, name of @variables]
			instanceMethods: {}
			staticMethods: {}
		}

		for const methods, name of @instanceMethods {
			export.instanceMethods[name] = [method.export(references, mode) for const method in methods when method.isExportable()]
		}

		for const methods, name of @staticMethods {
			export.staticMethods[name] = [method.export(references, mode) for const method in methods when method.isExportable()]
		}

		if exhaustive {
			const exhaustiveness = {}
			let notEmpty = false

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
	} // }}}
	hasVariable(name: String) => @variables[name]?
	getInstanceAssessment(name: String, node: AbstractNode) { // {{{
		if const assessment = @instanceAssessments[name] {
			return assessment
		}
		else if const methods = @instanceMethods[name] {
			const assessment = Router.assess([...methods], false, name, node)

			@instanceAssessments[name] = assessment

			return assessment
		}
		else {
			return null
		}
	} // }}}
	getStaticAssessment(name: String, node: AbstractNode) { // {{{
		if const assessment = @staticAssessments[name] {
			return assessment
		}
		else if const methods = @staticMethods[name] {
			const assessment = Router.assess([...methods], false, name, node)

			@staticAssessments[name] = assessment

			return assessment
		}
		else {
			return null
		}
	} // }}}
	getProperty(name: String) { // {{{
		if name == 'value' {
			return @type
		}
		else {
			return null
		}
	} // }}}
	hasInstanceMethod(name) { // {{{
		if @instanceMethods[name] is Array {
			return true
		}
		else {
			return false
		}
	} // }}}
	hasStaticMethod(name) { // {{{
		if @staticMethods[name] is Array {
			return true
		}
		else {
			return false
		}
	} // }}}
	hasMatchingInstanceMethod(name, type: FunctionType, mode: MatchingMode) { // {{{
		if @instanceMethods[name] is Array {
			for const method in @instanceMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} // }}}
	hasMatchingStaticMethod(name, type: FunctionType, mode: MatchingMode) { // {{{
		if @staticMethods[name] is Array {
			for const method in @staticMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} // }}}
	hasProperty(name: String) => name == 'value'
	index() => @index
	index(@index) => @index
	override isComparableWith(type) { // {{{
		if this.isNumber() {
			return type.canBeNumber()
		}
		else if this.isString() {
			return type.canBeString()
		}
		else {
			return false
		}
	} // }}}
	isEnum() => true
	isExhaustiveInstanceMethod(name) { // {{{
		if @exhaustiveness.instanceMethods[name] == false {
			return false
		}
		else {
			return true
		}
	} // }}}
	isExhaustiveInstanceMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveInstanceMethod(name)
	isExhaustiveStaticMethod(name) { // {{{
		if @exhaustiveness.staticMethods[name] == false {
			return false
		}
		else {
			return true
		}
	} // }}}
	isExhaustiveStaticMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveStaticMethod(name)
	isFlags() => @kind == EnumTypeKind::Flags
	isMatching(value: EnumType, mode: MatchingMode) => mode ~~ MatchingMode::Similar
	isMatching(value: ReferenceType, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Similar {
			return value.name() == 'Enum'
		}

		return false
	} // }}}
	isMergeable(type) => type.isEnum()
	isNumber() => @type.isNumber()
	isString() => @type.isString()
	kind() => @kind
	listMatchingInstanceMethods(name, type: FunctionType, mode: MatchingMode) { // {{{
		const results: Array = []

		if @instanceMethods[name] is Array {
			for const method in @instanceMethods[name] {
				if method.isMatching(type, mode) {
					results.push(method)
				}
			}
		}

		return results
	} // }}}
	listVariables() => [name for const _, name of @variables]
	matchContentOf(that: Type): Boolean => @type.matchContentOf(that)
	step() => ++@index
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toPositiveTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	type() => @type
}

class EnumVariableType {
	private {
		@alteration: Boolean	= false
	}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
	unflagAlteration() { // {{{
		@alteration = false

		return this
	} // }}}
}

class EnumMethodType extends FunctionType {
	private {
		@access: Accessibility					= Accessibility::Public
		@alteration: Boolean					= false
		@identifier: Number						= -1
	}
	static {
		fromAST(data, node: AbstractNode): EnumMethodType { // {{{
			const scope = node.scope()

			return new EnumMethodType([Type.fromAST(parameter, scope, false, node) for parameter in data.parameters], data, node)
		} // }}}
		fromMetadata(data, metadata, references, alterations, queue: Array, scope: Scope, node: AbstractNode): EnumMethodType { // {{{
			const type = new EnumMethodType(scope)

			type._identifier = data.id
			type._access = data.access
			type._async = data.async
			type._min = data.min
			type._max = data.max
			type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]

			type._returnType = Type.fromMetadata(data.returns, metadata, references, alterations, queue, scope, node)

			type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

			type.updateArguments()

			return type
		} // }}}
	}
	export(references, mode) { // {{{
		const export = {
			id: @identifier
			access: @access
			async: @async
			min: @min
			max: @max
			parameters: [parameter.export(references, mode) for parameter in @parameters]
			returns: @returnType.toReference(references, mode)
			throws: [throw.toReference(references, mode) for throw in @throws]
		}

		return export
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	identifier() => @identifier
	identifier(@identifier)
	isMethod() => true
}