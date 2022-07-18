class FunctionType extends Type {
	private lateinit {
		_assessment							= null
		_async: Boolean						= false
		_errors: Array<Type>				= []
		_hasRest: Boolean					= false
		_index: Number						= -1
		_max: Number						= 0
		_maxBefore: Number					= 0
		_maxAfter: Number					= 0
		_min: Number						= 0
		_minBefore: Number					= 0
		_minAfter: Number					= 0
		_missingParameters: Boolean			= false
		_missingReturn: Boolean				= true
		_parameters: Array<ParameterType>	= []
		_restIndex: Number					= -1
		_returnType: Type					= AnyType.NullableUnexplicit
	}
	static {
		clone(source: FunctionType, target: FunctionType): FunctionType { # {{{
			for const key in ['_async', '_hasRest', '_index', '_max', '_maxBefore', '_maxAfter', '_min', '_minBefore', '_minAfter', '_missingParameters', '_missingReturn', '_restIndex', '_returnType'] {
				target[key] = source[key]
			}

			target._parameters = [...source._parameters]
			target._errors = [...source._errors]

			return target
		} # }}}
		fromAST(data, node: AbstractNode): Type => FunctionType.fromAST(data, node.scope(), true, node)
		fromAST(data, scope: Scope, defined: Boolean, node: AbstractNode): Type { # {{{
			if data.parameters? {
				return new FunctionType([ParameterType.fromAST(parameter, false, scope, defined, node) for parameter in data.parameters], data, node)
			}
			else {
				return new FunctionType([new ParameterType(scope, Type.Any, 0, Infinity)], data, node)
			}
		} # }}}
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): FunctionType { # {{{
			const type = new FunctionType(scope)

			type._index = data.index ?? -1
			type._async = data.async
			type._min = data.min
			type._max = data.max

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			queue.push(() => {
				type._errors = [Type.import(throw, metadata, references, alterations, queue, scope, node) for throw in data.errors]

				if data.returns? {
					type._returnType = Type.import(data.returns, metadata, references, alterations, queue, scope, node)
					type._missingReturn = false
				}

				type._parameters = [ParameterType.import(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

				type.updateParameters()
			})

			return type
		} # }}}
		isOptional(parameters, index, step) { # {{{
			if index >= parameters.length {
				return true
			}

			if step <= parameters[index].min() {
				return false
			}

			for const parameter in parameters from index + 1 {
				if parameter.min() != 0 {
					return false
				}
			}

			return true
		} # }}}
		toQuote(parameters) { # {{{
			let fragments = ''

			fragments += '('

			for const parameter, index in parameters {
				if index != 0 {
					fragments += ', '
				}

				fragments += parameter.toQuote()
			}

			fragments += ')'


			return fragments
		} # }}}
	}
	constructor(@scope) { # {{{
		super(scope)
	} # }}}
	constructor(@scope, @index) { # {{{
		super(scope)
	} # }}}
	constructor(parameters: Array<ParameterType>, data, node) { # {{{
		super(node.scope())

		if data.type? {
			if data.type.kind != NodeKind::ReturnTypeReference {
				@returnType = Type.fromAST(data.type, node)
			}

			@missingReturn = false
		}

		for const parameter in parameters {
			if parameter.max() == Infinity {
				if @max == Infinity {
					SyntaxException.throwTooMuchRestParameter(node)
				}
				else {
					@max = Infinity
				}
			}
			else {
				@max += parameter.max()
			}

			@min += parameter.min()

			@parameters.push(parameter)
		}

		if data.modifiers? {
			this.processModifiers(data.modifiers)
		}

		if data.throws? {
			let type

			for const throw in data.throws {
				if (type ?= Type.fromAST(throw, node).discardReference()) && type.isNamed() && type.isClass() {
					@errors.push(type)
				}
				else {
					TypeException.throwNotClass(throw.name, node)
				}
			}
		}

		this.updateParameters()
	} # }}}
	constructor(parameters: Array<ParameterType>, data, @index, node) { # {{{
		this(parameters, data, node)
	} # }}}
	absoluteMax() => @async ? @max + 1 : @max
	absoluteMin() => @async ? @min + 1 : @min
	addError(...types: Type) { # {{{
		@errors.pushUniq(...types)
	} # }}}
	addParameter(type: Type, name: String?, min, max) { # {{{
		@parameters.push(new ParameterType(@scope, name, type, min, max))

		if @hasRest {
			@max += max

			@minAfter += min
			@maxAfter += max
		}
		else if max == Infinity {
			@max = Infinity

			@restIndex = @parameters.length - 1
			@hasRest = true
		}
		else {
			@max += max

			@minBefore += min
			@maxBefore += max
		}

		@min += min
	} # }}}
	addParameter(type: ParameterType) { # {{{
		@parameters.push(type)

		if @hasRest {
			@max += type.max()

			@minAfter += type.min()
			@maxAfter += type.max()
		}
		else if type.max() == Infinity {
			@max = Infinity

			@restIndex = @parameters.length - 1
			@hasRest = true
		}
		else {
			@max += type.max()

			@minBefore += type.min()
			@maxBefore += type.max()
		}

		@min += type.min()
	} # }}}
	assessment(name: String, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess([this], name, node)
		}

		return @assessment
	} # }}}
	async() { # {{{
		@async = true
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		const result = {
			kind: TypeKind::Function
		}

		if !this.isAlien() && @index != -1 {
			result.index = @index
		}

		result.async = @async

		if mode !~ ExportMode::OverloadedFunction {
			result.exhaustive = this.isExhaustive()
		}

		result.min = @min
		result.max = @max
		result.parameters = [parameter.export(references, indexDelta, mode, module) for const parameter in @parameters]
		result.returns = @returnType.toReference(references, indexDelta, mode, module)
		result.errors = [throw.toReference(references, indexDelta, mode, module) for const throw in @errors]

		return result
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if @exported {
			return this
		}

		@exported = true

		for error in @errors {
			error.flagExported(false)
		}

		@returnType.flagExported(false)

		return this
	} # }}}
	getCallIndex() => @alien ? 0 : @index
	getMaxAfter(): @maxAfter
	getMaxAfter(excludes: Array<String>?): Number { # {{{
		return 0 unless @hasRest

		if excludes? {
			auto max = 0

			for const parameter in @parameters from @restIndex + 1 when !excludes.contains(parameter.name()) {
				max += parameter.max()
			}

			return max
		}
		else {
			return @maxAfter
		}
	} # }}}
	getMaxBefore(): @maxBefore
	getMaxBefore(excludes: Array<String>?): Number { # {{{
		return 0 unless @hasRest

		if excludes? {
			auto max = 0

			for const parameter in @parameters til @restIndex when !excludes.contains(parameter.name()) {
				max += parameter.max()
			}

			return max
		}
		else {
			return @maxBefore
		}
	} # }}}
	getMinAfter(): @minAfter
	getMinAfter(excludes: Array<String>?): Number { # {{{
		return 0 unless @hasRest

		if excludes? {
			auto min = 0

			for const parameter in @parameters from @restIndex + 1 when !excludes.contains(parameter.name()) {
				min += parameter.min()
			}

			return min
		}
		else {
			return @minAfter
		}
	} # }}}
	getMinBefore(): @minBefore
	getMinBefore(excludes: Array<String>?): Number { # {{{
		return 0 unless @hasRest

		if excludes? {
			auto min = 0

			for const parameter in @parameters til @restIndex when !excludes.contains(parameter.name()) {
				min += parameter.min()
			}

			return min
		}
		else {
			return @minBefore
		}
	} # }}}
	getProperty(name: String) => Type.Any
	getRestIndex(): @restIndex
	getRestParameter() => @parameters[@restIndex]
	getReturnType(): @returnType
	hashCode() => `Function`
	hasRestParameter(): @hasRest
	hasVarargsParameter() { # {{{
		for const parameter in @parameters {
			return true if parameter.isVarargs()
		}

		return false
	} # }}}
	index(): @index
	index(@index): this
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() || value.isFunction() {
			return true
		}
		else if value is UnionType {
			for const type in value.types() {
				if this.isAssignableToVariable(type, anycast, nullcast, downcast) {
					return true
				}
			}
		}

		return false
	} # }}}
	isAsync(): @async
	isCatchingError(error): Boolean { # {{{
		if @errors.length != 0 {
			for type in @errors {
				if error.matchInheritanceOf(type) {
					return true
				}
			}
		}
		else if @returnType.isNever() {
			return true
		}

		return false
	} # }}}
	isExportable() { # {{{
		for const parameter in @parameters {
			if !parameter.isExportable() {
				return false
			}
		}

		if !@returnType.isExportable() {
			return false
		}

		return true
	} # }}}
	isExtendable() => true
	isFunction() => true
	isMissingError() => @errors.length == 0
	isMissingReturn() => @missingReturn
	isMorePreciseThan(value: FunctionType) { # {{{
		if @parameters.length != value._parameters.length {
			return false
		}

		for const parameter, i in @parameters {
			if parameter.isMorePreciseThan(value._parameters[i]) {
				return true
			}
		}

		return false
	} # }}}
	isMorePreciseThan(value: Type) => value.isAny()
	isInstanceOf(target: ReferenceType) => target.name() == 'Function'
	private isParametersMatching(arguments: Array, mode: MatchingMode): Boolean => this.isParametersMatching(0, -1, arguments, 0, -1, mode)
	private isParametersMatching(pIndex, pStep, arguments, aIndex, aStep, mode: MatchingMode) { # {{{
		if pStep == -1 {
			if pIndex >= @parameters.length {
				if mode !~ MatchingMode::RequireAllParameters {
					return FunctionType.isOptional(arguments, aIndex, aStep)
				}
				else {
					return aIndex >= arguments.length || (aIndex + 1 == arguments.length && aStep > arguments[aIndex].max())
				}
			}

			const parameter = @parameters[pIndex]

			if parameter.max() == Infinity {
				return this.isParametersMatching(pIndex, 1, arguments, aIndex, aStep, mode)
			}

			for const i from 1 to parameter.min() {
				if !this.isParametersMatching(pIndex, i, arguments, aIndex, aStep, mode) {
					return false
				}
			}

			if parameter.min() == parameter.max() {
				return true
			}

			for const i from parameter.min() + 1 to parameter.max() {
				if this.isParametersMatching(pIndex, i, arguments, aIndex, aStep, mode) {
					return true
				}
			}

			return false
		}
		else if pStep > @parameters[pIndex].max() {
			return this.isParametersMatching(pIndex + 1, -1, arguments, aIndex, aStep, mode)
		}
		else if aStep == -1 {
			if aIndex >= arguments.length {
				return FunctionType.isOptional(@parameters, pIndex, pStep)
			}

			const argument = arguments[aIndex]

			if argument.max() == Infinity {
				return this.isParametersMatching(pIndex, pStep, arguments, aIndex, 1, mode)
			}

			for const i from 1 to argument.min() {
				if !this.isParametersMatching(pIndex, pStep, arguments, aIndex, i, mode) {
					return false
				}
			}

			if argument.min() == argument.max() {
				return true
			}

			for const i from argument.min() + 1 to argument.max() {
				if this.isParametersMatching(pIndex, pStep, arguments, aIndex, i, mode) {
					return true
				}
			}

			return false
		}
		else if aStep > arguments[aIndex].max() {
			return this.isParametersMatching(pIndex, pStep, arguments, aIndex + 1, -1, mode)
		}
		else if arguments[aIndex].isSubsetOf(@parameters[pIndex], mode) {
			if @parameters[pIndex].max() == Infinity {
				if arguments[aIndex].max() == Infinity {
					return true
				}
				else {
					return this.isParametersMatching(pIndex, pStep, arguments, aIndex, aStep + 1, mode)
				}
			}
			else {
				return this.isParametersMatching(pIndex, pStep + 1, arguments, aIndex, aStep + 1, mode)
			}
		}
		else {
			return false
		}
	} # }}}
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		return value.isFunction()
	} # }}}
	isSubsetOf(value: FunctionType, mode: MatchingMode) { # {{{
		if @async != value._async {
			return false
		}
		if mode ~~ MatchingMode::Exact {
			mode += MatchingMode::ExactParameter + MatchingMode::ExactReturn
		}
		else if mode ~~ MatchingMode::Similar {
			mode += MatchingMode::SimilarParameter + MatchingMode::SimilarReturn
		}

		if mode ~~ MatchingMode::MissingParameter && @missingParameters {
			// do nothing
		}
		else if mode ~~ MatchingMode::ShiftableParameters {
			let parameterMode: MatchingMode

			if mode ~~ MatchingMode::ExactParameter {
				parameterMode = MatchingMode::Exact
			}
			else if mode ~~ MatchingMode::MissingParameterType {
				parameterMode = MatchingMode::Similar + MatchingMode::Missing
			}
			else {
				parameterMode = MatchingMode::Similar
			}

			if mode ~~ MatchingMode::RequireAllParameters {
				parameterMode += MatchingMode::RequireAllParameters
			}

			if !value.isParametersMatching(@parameters, parameterMode) {
				return false
			}
		}
		else {
			if mode ~~ MatchingMode::AdditionalParameter {
				if @parameters.length < value._parameters.length {
					if mode !~ MatchingMode::MissingParameterDefault && @min < value._min {
						return false
					}

					for const parameter in value._parameters from @parameters.length {
						if parameter.min() != 0 {
							return false
						}
					}
				}
				else {
					if mode !~ MatchingMode::MissingParameterArity {
						if @max < value._max {
							return false
						}

						if mode !~ MatchingMode::MissingParameterDefault && @min < value._min {
							return false
						}
					}

					for const parameter in @parameters from value._parameters.length {
						if parameter.min() != 0 {
							return false
						}
					}
				}
			}
			else if mode ~~ MatchingMode::MissingParameter {
				if @parameters.length > value._parameters.length {
					return false
				}

				for const parameter in value._parameters from @parameters.length {
					return false unless parameter.min() == 0
				}

				if mode !~ MatchingMode::MissingParameterArity && (@hasRest != value._hasRest || @restIndex != value._restIndex) {
					return false
				}

				if mode !~ MatchingMode::MissingParameterDefault && @min != value._min {
					return false
				}
			}
			else {
				if @parameters.length != value._parameters.length {
					return false
				}

				if mode !~ MatchingMode::MissingParameterArity && (@hasRest != value._hasRest || @restIndex != value._restIndex) {
					return false
				}

				if mode !~ MatchingMode::MissingParameterDefault && (@min != value._min || @max != value._max) {
					return false
				}
			}

			let paramMode = MatchingMode::Default

			paramMode += MatchingMode::Exact if mode ~~ MatchingMode::ExactParameter
			paramMode += MatchingMode::Similar if mode ~~ MatchingMode::SimilarParameter
			paramMode += MatchingMode::MissingType if mode ~~ MatchingMode::MissingParameterType
			paramMode += MatchingMode::Subclass if mode ~~ MatchingMode::SubclassParameter
			paramMode += MatchingMode::Subset if mode ~~ MatchingMode::SubsetParameter
			paramMode += MatchingMode::NonNullToNull if mode ~~ MatchingMode::NonNullToNullParameter
			paramMode += MatchingMode::MissingDefault if mode ~~ MatchingMode::MissingParameterDefault
			paramMode += MatchingMode::MissingArity if mode ~~ MatchingMode::MissingParameterArity
			paramMode += MatchingMode::Renamed if mode ~~ MatchingMode::Renamed
			paramMode += MatchingMode::IgnoreName if mode ~~ MatchingMode::IgnoreName

			if paramMode != 0 {
				for const parameter, index in @parameters til value._parameters.length {
					return false unless parameter.isSubsetOf(value._parameters[index], paramMode)
				}
			}
		}

		if mode ~~ MatchingMode::IgnoreReturn {
			// do nothing
		}
		else if !?@returnType {
			return false unless value.isMissingReturn()
		}
		else if !(mode ~~ MatchingMode::MissingReturn && value.isMissingReturn()) {
			let returnMode = MatchingMode::Default

			returnMode += MatchingMode::Exact if mode ~~ MatchingMode::ExactReturn
			returnMode += MatchingMode::Similar if mode ~~ MatchingMode::SimilarReturn
			returnMode += MatchingMode::Subclass if mode ~~ MatchingMode::SubclassReturn

			if returnMode != 0 {
				const newType = value.getReturnType()

				return false unless newType.isSubsetOf(@returnType, returnMode) || @returnType.isInstanceOf(newType)
			}
		}

		if mode ~~ MatchingMode::IgnoreError {
			// do nothing
		}
		else if @errors.length == 0 {
			return false unless value.isMissingError()
		}
		else if !(mode ~~ MatchingMode::MissingError && value.isMissingError()) {
			let errorMode = MatchingMode::Default

			errorMode += MatchingMode::Exact if mode ~~ MatchingMode::ExactError
			errorMode += MatchingMode::Similar if mode ~~ MatchingMode::SimilarErrors
			errorMode += MatchingMode::Subclass if mode ~~ MatchingMode::SubclassError

			if errorMode != 0 {
				const newTypes = value.listErrors()

				for const oldType in @errors {
					let matched = false

					for const newType in newTypes until matched {
						if newType.isSubsetOf(oldType, errorMode) || oldType.isInstanceOf(newType) {
							matched = true
						}
					}

					return false unless matched
				}
			}
		}

		return true
	} # }}}
	length() => 1
	listErrors() => @errors
	matchArguments(arguments: Array, node: AbstractNode) { # {{{
		const assessment = this.assessment('', node)

		return ?Router.matchArguments(assessment, arguments, node)
	} # }}}
	matchContentOf(value: Type) { # {{{
		if value.isAny() || value.isFunction() {
			return true
		}

		if value is UnionType {
			for const type in value.types() {
				if this.matchContentOf(type) {
					return true
				}
			}
		}

		return false
	} # }}}
	max(): @max
	max(excludes: Array<String>?): Number { # {{{
		if excludes? {
			auto max = 0

			for const parameter in @parameters when !excludes.contains(parameter.name()) {
				max += parameter.max()
			}

			return max
		}
		else {
			return @max
		}
	} # }}}
	min(): @min
	min(excludes: Array<String>?): Number { # {{{
		if excludes? {
			auto min = 0

			for const parameter in @parameters when !excludes.contains(parameter.name()) {
				min += parameter.min()
			}

			return min
		}
		else {
			return @min
		}
	} # }}}
	parameter(index) => @parameters[index]
	parameters(): Array<ParameterType> => @parameters
	parameters(excludes: Array<String>?): Array<ParameterType> { # {{{
		if excludes? {
			return [parameter for const parameter in @parameters when !excludes.contains(parameter.name())]
		}
		else {
			return @parameters
		}
	} # }}}
	private processModifiers(modifiers) { # {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				@async = true
			}
		}
	} # }}}
	pushTo(methods) { # {{{
		for const method in methods {
			if this.isSubsetOf(method, MatchingMode::SimilarParameter) {
				return
			}
		}

		methods.push(this)
	} # }}}
	setReturnType(@returnType): this
	toFragments(fragments, node) { # {{{
		fragments.code('Function')
	} # }}}
	toQuote() { # {{{
		let fragments = ''

		fragments += '('

		for const parameter, index in @parameters {
			if index != 0 {
				fragments += ', '
			}

			fragments += parameter.toQuote()
		}

		fragments += ')'

		if !@returnType.isAny() || !@returnType.isNullable() {
			fragments += ': ' + @returnType.toQuote()
		}

		return fragments
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		fragments
			.code($runtime.type(node) + '.isFunction(')
			.compile(node)
			.code(')')
	} # }}}
	toTestFunctionFragments(fragments, node) { # {{{
		fragments.code(`\($runtime.typeof('Function', node))`)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('func', 1)
	} # }}}
	updateParameters() { # {{{
		for const parameter, i in @parameters {
			if @hasRest {
				@minAfter += parameter.min()
				@maxAfter += parameter.max()
			}
			else if parameter.max() == Infinity {
				@restIndex = i
				@hasRest = true
			}
			else {
				@minBefore += parameter.min()
				@maxBefore += parameter.max()
			}
		}
	} # }}}
}

class OverloadedFunctionType extends Type {
	private {
		_altering: Boolean					= false
		_assessment							= null
		_async: Boolean						= false
		_functions: Array<FunctionType>		= []
		_majorOriginal: Type?
		_references: Array<Type>			= []
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): OverloadedFunctionType { # {{{
			const type = new OverloadedFunctionType(scope)

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			queue.push(() => {
				for const function in data.functions {
					type.addFunction(Type.import(function, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} # }}}
	}
	addFunction(type: FunctionType) { # {{{
		if @functions.length == 0 {
			@async = type.isAsync()
		}

		if type.index() == -1 {
			type.index(@functions.length)
		}

		@references.pushUniq(type)

		@functions.push(type)

		if type._exhaustive != null {
			if type._exhaustive {
				@exhaustive = true
			}
			else if @exhaustive == null {
				@exhaustive = false
			}
		}
	} # }}}
	addFunction(type: OverloadedFunctionType) { # {{{
		if @functions.length == 0 {
			@async = type.isAsync()
		}

		@references.pushUniq(type)

		for const function in type.functions() {
			if function.index() == -1 {
				function.index(@functions.length)
			}

			@functions.push(function)

			if function._exhaustive != null {
				if function._exhaustive {
					@exhaustive = true
				}
				else if @exhaustive == null {
					@exhaustive = false
				}
			}
		}
	} # }}}
	addFunction(type: ReferenceType) { # {{{
		if @functions.length == 0 {
			@async = type.isAsync()
		}

		const fn = new FunctionType(@scope, 0)
		fn.addParameter(AnyType.NullableExplicit, null, 0, Infinity)

		fn._missingParameters = true

		@functions.push(fn)

		@references.pushUniq(type)
	} # }}}
	assessment(name: String, node: AbstractNode) { # {{{
		if @assessment == null {
			@assessment = Router.assess(@functions, name, node)
		}

		return @assessment
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		const functions = []

		const overloadedMode = mode + ExportMode::OverloadedFunction

		for const reference in @references {
			if reference._referenceIndex == -1 && reference is OverloadedFunctionType {
				for const fn in reference.functions() when fn.isExportable(mode) {
					functions.push(fn.toExportOrReference(references, indexDelta, overloadedMode, module))
				}
			}
			else if reference.isExportable(mode) {
				functions.push(reference.toExportOrReference(references, indexDelta, overloadedMode, module))
			}
		}

		return {
			kind: TypeKind::OverloadedFunction
			exhaustive: this.isExhaustive()
			functions
		}
	} # }}}
	functions() => @functions
	hasFunction(type: FunctionType) { # {{{
		for function in @functions {
			if function.equals(type) {
				return true
			}
		}

		return false
	} # }}}
	isAsync() => @async
	isExportable() { # {{{
		for const reference in @references {
			if reference.isExportable() {
				return true
			}
		}

		return false
	} # }}}
	isExtendable() => true
	isFunction() => true
	isMergeable(type) => type is OverloadedFunctionType && @async == type.isAsync()
	isMorePreciseThan(value: Type) { # {{{
		if value.isAny() {
			return true
		}

		return false
	} # }}}
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Exact {
			return false
		}

		return value.isFunction()
	} # }}}
	isSubsetOf(value: FunctionType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Exact {
			return false
		}

		for fn in @functions {
			if fn.isSubsetOf(value, mode) {
				return true
			}
		}

		return false
	} # }}}
	isSubsetOf(value: OverloadedFunctionType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Exact {
			return false
		}

		let nf
		for fb in value.functions() {
			nf = true

			for fn in @functions while nf {
				if fn.isSubsetOf(fb, mode) {
					nf = false
				}
			}

			if nf {
				return false
			}
		}

		return true
	} # }}}
	isSubsetOf(value: NamedType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Exact {
			return false
		}

		return this.isSubsetOf(value.type(), mode)
	} # }}}
	length() => @functions.length
	matchArguments(arguments: Array, node: AbstractNode) { # {{{
		const assessment = this.assessment('', node)

		return ?Router.matchArguments(assessment, arguments, node)
	} # }}}
	originals(@majorOriginal): this { # {{{
		@altering = true
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('func', @functions.length)
	} # }}}
}
