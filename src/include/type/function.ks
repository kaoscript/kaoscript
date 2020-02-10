class FunctionType extends Type {
	private lateinit {
		_async: Boolean						= false
		_hasRest: Boolean					= false
		_index: Number
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
		_throws: Array<Type>				= []
	}
	static {
		fromAST(data, node: AbstractNode): Type => FunctionType.fromAST(data, node.scope(), true, node)
		fromAST(data, scope: Scope, defined: Boolean, node: AbstractNode): Type { // {{{
			if data.parameters? {
				return new FunctionType([Type.fromAST(parameter, scope, defined, node) for parameter in data.parameters], data, node)
			}
			else {
				return new FunctionType([new ParameterType(scope, Type.Any, 0, Infinity)], data, node)
			}
		} // }}}
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new FunctionType(scope)

			type._async = data.async
			type._min = data.min
			type._max = data.max

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]

			if data.returns? {
				type._returnType = Type.fromMetadata(data.returns, metadata, references, alterations, queue, scope, node)
				type._missingReturn = false
			}

			type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

			type.updateArguments()

			if data.sealed {
				type.flagSealed()
			}


			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new FunctionType(scope)

			type._async = data.async
			type._min = data.min
			type._max = data.max

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			queue.push(() => {
				type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]

				if data.returns? {
					type._returnType = Type.fromMetadata(data.returns, metadata, references, alterations, queue, scope, node)
					type._missingReturn = false
				}

				type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

				type.updateArguments()
			})

			return type
		} // }}}
		isOptional(parameters, index, step) { // {{{
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
		} // }}}
		toQuote(parameters) { // {{{
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
		} // }}}
	}
	constructor(@scope) { // {{{
		super(scope)
	} // }}}
	constructor(parameters: Array<ParameterType>, data, node) { // {{{
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
					@throws.push(type)
				}
				else {
					TypeException.throwNotClass(throw.name, node)
				}
			}
		}

		this.updateArguments()
	} // }}}
	absoluteMax() => @async ? @max + 1 : @max
	absoluteMin() => @async ? @min + 1 : @min
	addParameter(type: Type, min = 1, max = 1) { // {{{
		@parameters.push(new ParameterType(@scope, type, min, max))

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
	} // }}}
	addParameter(type: ParameterType) { // {{{
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
	} // }}}
	async() { // {{{
		@async = true
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) { // {{{
		if mode & ExportMode::OverloadedFunction != 0 {
			return {
				kind: TypeKind::Function
				async: @async
				min: @min
				max: @max
				parameters: [parameter.export(references, mode) for const parameter in @parameters]
				returns: @returnType.toReference(references, mode)
				throws: [throw.toReference(references, mode) for const throw in @throws]
			}
		}
		else {
			return {
				kind: TypeKind::Function
				async: @async
				exhaustive: this.isExhaustive()
				min: @min
				max: @max
				parameters: [parameter.export(references, mode) for const parameter in @parameters]
				returns: @returnType.toReference(references, mode)
				throws: [throw.toReference(references, mode) for const throw in @throws]
			}
		}
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		if @exported {
			return this
		}

		@exported = true

		for error in @throws {
			error.flagExported(false)
		}

		@returnType.flagExported(false)

		return this
	} // }}}
	getProperty(name: String) => Type.Any
	index() => @index
	index(@index) => this
	isAssignableToVariable(value, anycast, nullcast, downcast) { // {{{
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
	} // }}}
	isAsync() => @async
	isCatchingError(error): Boolean { // {{{
		if @throws.length != 0 {
			for type in @throws {
				if error.matchInheritanceOf(type) {
					return true
				}
			}
		}
		else if @returnType.isNever() {
			return true
		}

		return false
	} // }}}
	isExportable() { // {{{
		for const parameter in @parameters {
			if !parameter.isExportable() {
				return false
			}
		}

		return true
	} // }}}
	isFunction() => true
	isMatching(value: ReferenceType, mode: MatchingMode) { // {{{
		if value.name() != 'Function' {
			return false
		}

		if mode & MatchingMode::Exact != 0 || mode & MatchingMode::ExactParameters != 0 {
			return @min == 0 && @max == Infinity
		}
		else {
			return true
		}
	} // }}}
	isMatching(value: FunctionType, mode: MatchingMode) { // {{{
		if @async != value._async {
			return false
		}

		if mode & MatchingMode::Exact != 0 {
			mode |= MatchingMode::ExactParameters | MatchingMode::ExactReturn
		}
		else if mode & MatchingMode::Similar != 0 {
			mode |= MatchingMode::SimilarParameters | MatchingMode::SimilarReturn
		}

		if mode & MatchingMode::MissingParameters != 0 && @missingParameters {
			// do nothing
		}
		else if mode & MatchingMode::ShiftableParameters != 0 {
			let parameterMode: MatchingMode
			if mode & MatchingMode::ExactParameters != 0 {
				parameterMode = MatchingMode::Exact
			}
			else if mode & MatchingMode::MissingParameterType != 0 {
				parameterMode = MatchingMode::Similar | MatchingMode::MissingType
			}
			else {
				parameterMode = MatchingMode::Similar
			}

			if mode & MatchingMode::RequireAllParameters != 0 {
				parameterMode |= MatchingMode::RequireAllParameters
			}

			if !this.isParametersMatching(value._parameters, parameterMode) {
				return false
			}
		}
		else {
			if @hasRest != value._hasRest || @max != value._max || @min != value._min || @restIndex != value._restIndex || @parameters.length != value._parameters.length {
				return false
			}

			if mode & MatchingMode::ExactParameters != 0 {
				for const parameter, index in @parameters {
					if !parameter.isMatching(value._parameters[index], MatchingMode::Exact) {
						return false
					}
				}
			}
			else if mode & MatchingMode::SimilarParameters != 0 {
				for const parameter, index in @parameters {
					if !parameter.isMatching(value._parameters[index], MatchingMode::Similar) {
						return false
					}
				}
			}
		}

		if mode & MatchingMode::MissingReturn != 0 && @missingReturn {
			return true
		}
		else if mode & MatchingMode::ExactReturn != 0 {
			return @returnType.isMatching(value._returnType, MatchingMode::Exact)
		}
		else if mode & MatchingMode::SimilarReturn != 0 {
			return @returnType.isMatching(value._returnType, MatchingMode::Similar)
		}
		else {
			return true
		}
	} // }}}
	isMorePreciseThan(type: Type) { // {{{
		if type.isAny() {
			return true
		}

		return false
	} // }}}
	isInstanceOf(target: ReferenceType) => target.name() == 'Function'
	private isParametersMatching(arguments: Array, mode: MatchingMode): Boolean => this.isParametersMatching(0, -1, arguments, 0, -1, mode)
	private isParametersMatching(pIndex, pStep, arguments, aIndex, aStep, mode: MatchingMode) { // {{{
		// console.log(pIndex, pStep, aIndex, aStep)
		if pStep == -1 {
			if pIndex >= @parameters.length {
				if mode & MatchingMode::RequireAllParameters == 0 {
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
		else if @parameters[pIndex].isMatching(arguments[aIndex], mode) {
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
	} // }}}
	matchArguments(arguments: Array) { // {{{
		// console.log(@parameters)
		// console.log(arguments)
		if arguments.length == 0 {
			return @min == 0
		}
		if arguments.length > @max {
			return false
		}

		let spreadIndex: Number = -1

		for const argument, index in arguments {
			if argument is UnaryOperatorSpread {
				spreadIndex = index

				break
			}
		}

		if spreadIndex != -1 {
			if arguments.length == 1 {
				const argument = arguments[0].type().parameter()

				for const parameter in @parameters {
					if !parameter.matchArgument(argument) {
						return false
					}
				}
			}
			else {
				let argIndex = 0
				let parIndex = 0

				for argIndex from 0 til spreadIndex {
					if parIndex + 1 > @parameters.length {
						return false
					}
					if !@parameters[parIndex].matchArgument(arguments[argIndex]) {
						return false
					}

					++parIndex
				}

				const argument = arguments[spreadIndex].type().parameter()

				for const parameter in @parameters from parIndex {
					if !parameter.matchArgument(argument) {
						return false
					}
				}

			}

			return true
		}

		if arguments.length < @min {
			return false
		}

		if @parameters.length == 1 {
			const parameter = @parameters[0]

			for const argument in arguments {
				if !parameter.matchArgument(argument) {
					return false
				}
			}

			return true
		}
		else if @hasRest {
			let a = 0
			let b = arguments.length - 1

			for const parameter in @parameters from @parameters.length - 1 til @restIndex by -1 {
				for const j from 0 til parameter.min() {
					if !parameter.matchArgument(arguments[b]) {
						return false
					}

					--b
				}
			}

			for const parameter in @parameters from 0 til @restIndex {
				for const j from 0 til parameter.min() {
					if !parameter.matchArgument(arguments[a]) {
						return false
					}

					++a
				}

				for const j from parameter.min() til parameter.max() while a < b && parameter.matchArgument(arguments[a]) {
					++a
				}
			}

			const parameter = @parameters[@restIndex]

			for const j from 0 til parameter.min() {
				if !parameter.matchArgument(arguments[a]) {
					return false
				}

				++a
			}

			return true
		}
		else if arguments.length == @max {
			let a = 0

			let p
			for parameter in @parameters {
				for p from 0 til parameter.max() {
					if !parameter.matchArgument(arguments[a]) {
						return false
					}

					++a
				}
			}

			return true
		}
		else {
			let a = 0
			let optional = arguments.length - @min

			for const parameter in @parameters {
				for i from 0 til parameter.min() {
					if !parameter.matchArgument(arguments[a]) {
						return false
					}

					++a
				}

				for i from parameter.min() til parameter.max() while optional > 0 when parameter.matchArgument(arguments[a]) {
					++a
					--optional
				}
			}

			return optional == 0
		}
	} // }}}
	matchContentOf(type: Type) { // {{{
		if type.isAny() || type.isFunction() {
			return true
		}

		if type is UnionType {
			for const type in type.types() {
				if this.matchContentOf(type) {
					return true
				}
			}
		}

		return false
	} // }}}
	max() => @max
	min() => @min
	parameter(index) => @parameters[index]
	parameters() => @parameters
	private processModifiers(modifiers) { // {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				@async = true
			}
		}
	} // }}}
	pushTo(methods) { // {{{
		for const method in methods {
			if this.isMatching(method, MatchingMode::SimilarParameters) {
				return
			}
		}

		methods.push(this)
	} // }}}
	restIndex() => @restIndex
	returnType() => @returnType
	returnType(@returnType) => this
	throws() => @throws
	toFragments(fragments, node) { // {{{
		fragments.code('Function')
	} // }}}
	toQuote() { // {{{
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
	} // }}}
	toTestFragments(fragments, node) { // {{{
		fragments
			.code($runtime.type(node) + '.isFunction(')
			.compile(node)
			.code(')')
	} // }}}
	updateArguments() { // {{{
		for parameter, i in @parameters {
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
	} // }}}
}

class OverloadedFunctionType extends Type {
	private {
		_assessment							= null
		_async: Boolean						= false
		_functions: Array<FunctionType>		= []
		_references: Array<Type>			= []
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new OverloadedFunctionType(scope)

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			for function in data.functions {
				type.addFunction(Type.fromMetadata(function, metadata, references, alterations, queue, scope, node))
			}

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new OverloadedFunctionType(scope)

			if data.exhaustive? {
				type._exhaustive = data.exhaustive
			}

			queue.push(() => {
				for function in data.functions {
					type.addFunction(Type.fromMetadata(function, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} // }}}
	}
	addFunction(type: FunctionType) { // {{{
		if @functions.length == 0 {
			@async = type.isAsync()
		}

		@functions.push(type)

		@references.pushUniq(type)

		if type._exhaustive != null {
			if type._exhaustive {
				@exhaustive = true
			}
			else if @exhaustive == null {
				@exhaustive = false
			}
		}
	} // }}}
	addFunction(type: OverloadedFunctionType) { // {{{
		if @functions.length == 0 {
			@async = type.isAsync()
		}

		@references.pushUniq(type)

		for const function in type.functions() {
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
	} // }}}
	addFunction(type: ReferenceType) { // {{{
		if @functions.length == 0 {
			@async = type.isAsync()
		}

		const fn = new FunctionType(@scope)
		fn.addParameter(Type.Any, 0, Infinity)

		fn._missingParameters = true

		@functions.push(fn)

		@references.pushUniq(type)
	} // }}}
	assessment() { // {{{
		if @assessment == null {
			@assessment = Router.assess(@functions, true)
		}

		return @assessment
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) { // {{{
		const functions = []

		const overloadedMode = mode | ExportMode::OverloadedFunction

		for const reference in @references {
			if reference._referenceIndex == -1 && reference is OverloadedFunctionType {
				for const fn in reference.functions() when fn.isExportable() {
					functions.push(fn.toExportOrReference(references, overloadedMode))
				}
			}
			else if reference.isExportable() {
				functions.push(reference.toExportOrReference(references, overloadedMode))
			}
		}

		return {
			kind: TypeKind::OverloadedFunction
			exhaustive: this.isExhaustive()
			functions: functions
		}
	} // }}}
	functions() => @functions
	hasFunction(type: FunctionType) { // {{{
		for function in @functions {
			if function.equals(type) {
				return true
			}
		}

		return false
	} // }}}
	isAsync() => @async
	isExportable() { // {{{
		for const reference in @references {
			if reference.isExportable() {
				return true
			}
		}

		return false
	} // }}}
	isFunction() => true
	isMatching(value: ReferenceType, mode: MatchingMode) { // {{{
		if mode & MatchingMode::Exact != 0 {
			return false
		}

		return value.isFunction()
	} // }}}
	isMatching(value: FunctionType, mode: MatchingMode) { // {{{
		if mode & MatchingMode::Exact != 0 {
			return false
		}

		for fn in @functions {
			if fn.isMatching(value, mode) {
				return true
			}
		}

		return false
	} // }}}
	isMatching(value: OverloadedFunctionType, mode: MatchingMode) { // {{{
		if mode & MatchingMode::Exact != 0 {
			return false
		}

		let nf
		for fb in value.functions() {
			nf = true

			for fn in @functions while nf {
				if fn.isMatching(fb, mode) {
					nf = false
				}
			}

			if nf {
				return false
			}
		}

		return true
	} // }}}
	isMatching(value: NamedType, mode: MatchingMode) { // {{{
		if mode & MatchingMode::Exact != 0 {
			return false
		}

		return this.isMatching(value.type(), mode)
	} // }}}
	isMergeable(type) => type is OverloadedFunctionType && @async == type.isAsync()
	isMorePreciseThan(type: Type) { // {{{
		if type.isAny() {
			return true
		}

		return false
	} // }}}
	length() => @functions.length
	matchArguments(arguments: Array) { // {{{
		for const fn in @functions {
			if fn.matchArguments(arguments) {
				return true
			}
		}

		return false
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
}