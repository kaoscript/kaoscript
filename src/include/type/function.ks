bitmask MinMax {
	AFTER_REST = 1
	ASYNC
	DEFAULT
	LABELED_ONLY
	POSITIONAL
	REST
}

class FunctionType extends Type {
	private late {
		@assessment							= null
		@async: Boolean						= false
		@autoTyping: Boolean				= false
		@dynamicReturn: Boolean				= false
		@errors: Array<Type>				= []
		@hasRest: Boolean					= false
		@index: Number						= -1
		@maxs: Number{}						= {}
		@mins: Number{}						= {}
		@missingParameters: Boolean			= false
		@missingReturn: Boolean				= true
		@parameters: Array<ParameterType>	= []
		@restIndex: Number					= -1
		@returnData							= null
		@returnType: Type					= AnyType.NullableUnexplicit
	}
	static {
		clone(source: FunctionType, target: FunctionType): FunctionType { # {{{
			target._async = source._async
			target._autoTyping = source._autoTyping
			target._dynamicReturn = source._dynamicReturn
			target._errors = [...source._errors]
			target._hasRest = source._hasRest
			target._index = source._index
			target._maxs = {...source._maxs}
			target._mins = {...source._mins}
			target._missingParameters = source._missingParameters
			target._missingReturn = source._missingReturn
			target._parameters = [...source._parameters]
			target._restIndex = source._restIndex
			target._returnData = source._returnData
			target._returnType = source._returnType

			return target
		} # }}}
		fromAST(data, node: AbstractNode): Type => FunctionType.fromAST(data, node.scope(), true, node)
		fromAST(data, scope: Scope, defined: Boolean, node: AbstractNode): Type { # {{{
			if ?data.parameters {
				return new FunctionType([ParameterType.fromAST(parameter, false, scope, defined, node) for parameter in data.parameters], data, node)
			}
			else {
				return new FunctionType([new ParameterType(scope, Type.Any, 0, Infinity)], data, node)
			}
		} # }}}
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): FunctionType { # {{{
			var type = new FunctionType(scope)

			type._index = data.index ?? -1
			type._async = data.async

			if ?data.exhaustive {
				type._exhaustive = data.exhaustive
			}

			queue.push(() => {
				type._errors = [Type.import(throw, metadata, references, alterations, queue, scope, node) for var throw in data.errors]

				if ?data.returns {
					type._returnType = Type.import(data.returns, metadata, references, alterations, queue, scope, node)
					type._missingReturn = false
				}

				for var parameter in data.parameters {
					type.addParameter(ParameterType.import(parameter, metadata, references, alterations, queue, scope, node), node)
				}
			})

			return type.flagComplete()
		} # }}}
		isOptional(parameters, index, step) { # {{{
			if index >= parameters.length {
				return true
			}

			if step <= parameters[index].min() {
				return false
			}

			for var parameter in parameters from index + 1 {
				if parameter.min() != 0 {
					return false
				}
			}

			return true
		} # }}}
		toQuote(parameters) { # {{{
			var mut fragments = ''

			fragments += '('

			for var parameter, index in parameters {
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

		if ?data.type {
			@setReturnType(data.type, node)

			@missingReturn = false
		}

		for var parameter in parameters {
			@addParameter(parameter, node)
		}

		if ?data.modifiers {
			@processModifiers(data.modifiers)
		}

		if ?data.throws {
			var dyn type

			for var throw in data.throws {
				if (type ?= Type.fromAST(throw, node).discardReference()) && type.isNamed() && type.isClass() {
					@errors.push(type)
				}
				else {
					TypeException.throwNotClass(throw.name, node)
				}
			}
		}
	} # }}}
	constructor(parameters: Array<ParameterType>, data, @index, node) { # {{{
		this(parameters, data, node)
	} # }}}
	addError(...types: Type) { # {{{
		@errors.pushUniq(...types)
	} # }}}
	addParameter(type: Type, name: String?, min, max) { # {{{
		var parameter = new ParameterType(@scope, name, name, type, min, max)

		parameter.index(@parameters.length)

		@parameters.push(parameter)

		if max == Infinity && !@hasRest {
			@restIndex = @parameters.length - 1
			@hasRest = true
		}
	} # }}}
	addParameter(type: ParameterType, node) { # {{{
		type.index(@parameters.length)

		@parameters.push(type)

		if type.max() == Infinity {
			if @hasRest {
				SyntaxException.throwTooMuchRestParameter(node)
			}

			@restIndex = @parameters.length - 1
			@hasRest = true
		}
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
		var result = {
			kind: TypeKind::Function
		}

		if !@isAlien() && @index != -1 {
			result.index = @index
		}

		result.async = @async

		if mode !~ ExportMode::OverloadedFunction {
			result.exhaustive = @isExhaustive()
		}

		result.parameters = [parameter.export(references, indexDelta, mode, module) for var parameter in @parameters]
		result.returns = @returnType.toReference(references, indexDelta, mode, module)
		result.errors = [throw.toReference(references, indexDelta, mode, module) for var throw in @errors]

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
	functions() => [this]
	getCallIndex() => @alien ? 0 : @index
	getProperty(name: String) => Type.Any
	getRestIndex(): @restIndex
	getRestParameter() => @parameters[@restIndex]
	getReturnData(): @returnData
	getReturnType(): @returnType
	hashCode() => `Function`
	hasRestParameter(): @hasRest
	hasVarargsParameter() { # {{{
		for var parameter in @parameters {
			return true if parameter.isVarargs()
		}

		return false
	} # }}}
	hasOnlyLabeledParameter() { # {{{
		for var parameter in @parameters {
			return true if parameter.isOnlyLabeled()
		}

		return false
	} # }}}
	index(): @index
	index(@index): this
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value is FunctionType {
			var mut mode = MatchingMode::FunctionSignature

			if anycast {
				mode += MatchingMode::AnycastParameter + MatchingMode::MissingReturn
			}

			return this.isSubsetOf(value, mode)
		}
		else if value.isAny() || value.isFunction() {
			return true
		}
		else if value is UnionType {
			for var type in value.types() {
				if @isAssignableToVariable(type, anycast, nullcast, downcast) {
					return true
				}
			}
		}

		return false
	} # }}}
	isAsync(): @async
	isAutoTyping(): @autoTyping
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
	isDynamicReturn(): @dynamicReturn
	isExportable() { # {{{
		for var parameter in @parameters {
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

		for var parameter, i in @parameters {
			if parameter.isMorePreciseThan(value._parameters[i]) {
				return true
			}
		}

		return false
	} # }}}
	isMorePreciseThan(value: Type) => value.isAny()
	isInstanceOf(target: ReferenceType) => target.name() == 'Function'
	private isParametersMatching(arguments: Array, mode: MatchingMode): Boolean => @isParametersMatching(0, -1, arguments, 0, -1, mode)
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

			var parameter = @parameters[pIndex]

			if parameter.max() == Infinity {
				return @isParametersMatching(pIndex, 1, arguments, aIndex, aStep, mode)
			}

			for var i from 1 to parameter.min() {
				if !@isParametersMatching(pIndex, i, arguments, aIndex, aStep, mode) {
					return false
				}
			}

			if parameter.min() == parameter.max() {
				return true
			}

			for var i from parameter.min() + 1 to parameter.max() {
				if @isParametersMatching(pIndex, i, arguments, aIndex, aStep, mode) {
					return true
				}
			}

			return false
		}
		else if pStep > @parameters[pIndex].max() {
			return @isParametersMatching(pIndex + 1, -1, arguments, aIndex, aStep, mode)
		}
		else if aStep == -1 {
			if aIndex >= arguments.length {
				return FunctionType.isOptional(@parameters, pIndex, pStep)
			}

			var argument = arguments[aIndex]

			if argument.max() == Infinity {
				return @isParametersMatching(pIndex, pStep, arguments, aIndex, 1, mode)
			}

			for var i from 1 to argument.min() {
				if !@isParametersMatching(pIndex, pStep, arguments, aIndex, i, mode) {
					return false
				}
			}

			if argument.min() == argument.max() {
				return true
			}

			for var i from argument.min() + 1 to argument.max() {
				if @isParametersMatching(pIndex, pStep, arguments, aIndex, i, mode) {
					return true
				}
			}

			return false
		}
		else if aStep > arguments[aIndex].max() {
			return @isParametersMatching(pIndex, pStep, arguments, aIndex + 1, -1, mode)
		}
		else if arguments[aIndex].isSubsetOf(@parameters[pIndex], mode) {
			if @parameters[pIndex].max() == Infinity {
				if arguments[aIndex].max() == Infinity {
					return true
				}
				else {
					return @isParametersMatching(pIndex, pStep, arguments, aIndex, aStep + 1, mode)
				}
			}
			else {
				return @isParametersMatching(pIndex, pStep + 1, arguments, aIndex, aStep + 1, mode)
			}
		}
		else {
			return false
		}
	} # }}}
	isProxy() => false
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		return value.isFunction()
	} # }}}
	isSubsetOf(value: FunctionType, mut mode: MatchingMode) { # {{{
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
			pass
		}
		else if mode ~~ MatchingMode::ShiftableParameters {
			var mut parameterMode: MatchingMode

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
					if mode !~ MatchingMode::MissingParameterDefault && @min() < value.min() {
						return false
					}

					for var parameter in value._parameters from @parameters.length {
						if parameter.min() != 0 {
							return false
						}
					}
				}
				else {
					if mode !~ MatchingMode::MissingParameterArity {
						if @max() < value.max() {
							return false
						}

						if mode !~ MatchingMode::MissingParameterDefault && @min() < value.min() {
							return false
						}
					}

					for var parameter in @parameters from value._parameters.length {
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

				for var parameter in value._parameters from @parameters.length {
					return false unless parameter.min() == 0
				}

				if mode !~ MatchingMode::MissingParameterArity && (@hasRest != value._hasRest || @restIndex != value._restIndex) {
					return false
				}

				if mode !~ MatchingMode::MissingParameterDefault && @min() != value.min() {
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

				if mode !~ MatchingMode::MissingParameterDefault && (@min() != value.min() || @max() != value.max()) {
					return false
				}
			}

			var mut paramMode = MatchingMode::Default

			paramMode += MatchingMode::Exact if mode ~~ MatchingMode::ExactParameter
			paramMode += MatchingMode::Similar if mode ~~ MatchingMode::SimilarParameter
			paramMode += MatchingMode::MissingType if mode ~~ MatchingMode::MissingParameterType
			paramMode += MatchingMode::Subclass if mode ~~ MatchingMode::SubclassParameter
			paramMode += MatchingMode::Subset if mode ~~ MatchingMode::SubsetParameter
			paramMode += MatchingMode::NonNullToNull if mode ~~ MatchingMode::NonNullToNullParameter
			paramMode += MatchingMode::NullToNonNull if mode ~~ MatchingMode::NullToNonNullParameter
			paramMode += MatchingMode::MissingDefault if mode ~~ MatchingMode::MissingParameterDefault
			paramMode += MatchingMode::MissingArity if mode ~~ MatchingMode::MissingParameterArity
			paramMode += MatchingMode::Renamed if mode ~~ MatchingMode::Renamed
			paramMode += MatchingMode::IgnoreName if mode ~~ MatchingMode::IgnoreName
			paramMode += MatchingMode::IgnoreRetained if mode ~~ MatchingMode::IgnoreRetained
			paramMode += MatchingMode::Anycast if mode ~~ MatchingMode::AnycastParameter

			if paramMode != 0 {
				var valLabels = {}
				var valPositions = []

				for var parameter in value._parameters {
					if parameter.isLabeled() {
						valLabels[parameter.getExternalName()] = parameter
					}
					if parameter.isPositional() {
						valPositions.push(parameter)
					}
				}

				var mut index = 0
				var testLabel = mode !~ MatchingMode::IgnoreName

				for var parameter in @parameters {
					if testLabel && parameter.isLabeled() {
						if var valParam ?= valLabels[parameter.getExternalName()] {
							return false unless parameter.isSubsetOf(valParam, paramMode)
						}
						else if parameter.isPositional() && index < valPositions.length {
							return false unless parameter.min() == 0 || valPositions[index].isAnonymous()
						}
						else {
							return false unless parameter.min() == 0
						}
					}

					if parameter.isPositional() && index < valPositions.length {
						return false unless parameter.isSubsetOf(valPositions[index], paramMode)

						index += 1
					}
				}
			}
		}

		if mode ~~ MatchingMode::IgnoreReturn {
			pass
		}
		else if !?@returnType {
			return false unless value.isMissingReturn()
		}
		else if !(mode ~~ MatchingMode::MissingReturn && value.isMissingReturn()) {
			var mut returnMode = MatchingMode::Default

			returnMode += MatchingMode::Exact if mode ~~ MatchingMode::ExactReturn
			returnMode += MatchingMode::Similar if mode ~~ MatchingMode::SimilarReturn
			returnMode += MatchingMode::Subclass if mode ~~ MatchingMode::SubclassReturn

			if returnMode != 0 {
				var newType = value.getReturnType()

				return false unless newType.isSubsetOf(@returnType, returnMode) || @returnType.isInstanceOf(newType)
			}
		}

		if mode ~~ MatchingMode::IgnoreError {
			pass
		}
		else if @errors.length == 0 {
			return false unless value.isMissingError()
		}
		else if !(mode ~~ MatchingMode::MissingError && value.isMissingError()) {
			var mut errorMode = MatchingMode::Default

			errorMode += MatchingMode::Exact if mode ~~ MatchingMode::ExactError
			errorMode += MatchingMode::Similar if mode ~~ MatchingMode::SimilarErrors
			errorMode += MatchingMode::Subclass if mode ~~ MatchingMode::SubclassError

			if errorMode != 0 {
				var newTypes = value.listErrors()

				for var oldType in @errors {
					var mut matched = false

					for var newType in newTypes until matched {
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
	isUnknownReturnType() => @autoTyping
	length() => 1
	listErrors() => @errors
	matchArguments(arguments: Array, node: AbstractNode) { # {{{
		var assessment = this.assessment('', node)

		return ?Router.matchArguments(assessment, arguments, node)
	} # }}}
	matchContentOf(value: Type) { # {{{
		if value.isAny() || value.isFunction() {
			return true
		}

		if value is UnionType {
			for var type in value.types() {
				if @matchContentOf(type) {
					return true
				}
			}
		}

		return false
	} # }}}
	max(mode: MinMax = MinMax::DEFAULT, mut excludes: String[]? = null) { # {{{
		var key = #excludes ? `\(mode)/\(excludes.sort((a, b) => a.localeCompare(b)).join(','))` : `\(mode)/`

		if var max ?= @maxs[key] {
			return max
		}

		excludes ??= []

		var mut max = 0

		if mode ~~ MinMax::AFTER_REST {
			if @hasRest {
				for var parameter in @parameters from @restIndex + 1 when parameter.isPositional() && !excludes.contains(parameter.getExternalName()) {
					max += parameter.max()
				}
			}
		}
		else if mode ~~ MinMax::DEFAULT {
			for var parameter in @parameters when !excludes.contains(parameter.getExternalName()) {
				max += parameter.max()
			}
		}
		else if mode ~~ MinMax::LABELED_ONLY {
			for var parameter in @parameters when parameter.isOnlyLabeled() && !excludes.contains(parameter.getExternalName()) {
				max += parameter.max()
			}
		}
		else if mode ~~ MinMax::POSITIONAL {
			if @hasRest && mode ~~ MinMax::REST {
				max = Infinity
			}
			else {
				for var parameter in @parameters when parameter.isPositional() && parameter.isLimited() && !excludes.contains(parameter.getExternalName()) {
					max += parameter.max()
				}
			}
		}

		if @async && mode ~~ MinMax::ASYNC {
			max += 1
		}

		@maxs[key] = max

		return max
	} # }}}
	min(mode: MinMax = MinMax::DEFAULT, mut excludes: String[]? = null) { # {{{
		var key = #excludes ? `\(mode)/\(excludes.sort((a, b) => a.localeCompare(b)).join(','))` : `\(mode)/`

		if var min ?= @mins[key] {
			return min
		}

		excludes ??= []

		var mut min = 0

		if mode ~~ MinMax::AFTER_REST {
			if @hasRest {
				for var parameter in @parameters from @restIndex + 1 when parameter.isPositional() && !excludes.contains(parameter.getExternalName()) {
					min += parameter.min()
				}
			}
		}
		else if mode ~~ MinMax::DEFAULT {
			for var parameter in @parameters when !excludes.contains(parameter.getExternalName()) {
				min += parameter.min()
			}
		}
		else if mode ~~ MinMax::LABELED_ONLY {
			for var parameter in @parameters when parameter.isOnlyLabeled() && !excludes.contains(parameter.getExternalName()) {
				min += parameter.min()
			}
		}
		else if mode ~~ MinMax::POSITIONAL {
			if mode ~~ MinMax::REST {
				for var parameter in @parameters when parameter.isPositional() && !excludes.contains(parameter.getExternalName()) {
					min += parameter.min()
				}
			}
			else {
				for var parameter in @parameters when parameter.isPositional() && parameter.isLimited() && !excludes.contains(parameter.getExternalName()) {
					min += parameter.min()
				}
			}
		}

		if @async && mode ~~ MinMax::ASYNC {
			min += 1
		}

		@mins[key] = min

		return min
	} # }}}
	parameter(index) => @parameters[index]
	parameters(): Array<ParameterType> => @parameters
	parameters(excludes: Array<String>?): Array<ParameterType> { # {{{
		if ?excludes {
			return [parameter for var parameter in @parameters when !excludes.contains(parameter.getExternalName())]
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
		for var method in methods {
			if this.isSubsetOf(method, MatchingMode::SimilarParameter) {
				return
			}
		}

		methods.push(this)
	} # }}}
	setReturnType(data?, node) { # {{{
		if !?data {
			@returnType = AnyType.NullableUnexplicit

			return
		}

		if data.kind == NodeKind::TypeReference && data.typeName.kind == NodeKind::Identifier {
			switch data.typeName.name {
				'auto' => {
					@dynamicReturn = true
					@autoTyping = true

					return
				}
				'false', 'true' => {
					@dynamicReturn = true
					@returnType = node.scope().reference('Boolean')
					@returnData = data.typeName

					return
				}
				'Infinity', 'NaN' => {
					@dynamicReturn = true
					@returnType = node.scope().reference('Number')
					@returnData = data.typeName

					return
				}
				'null' => {
					@dynamicReturn = true
					@returnType = node.scope().reference('Null')
					@returnData = data.typeName

					return
				}
			}
		}
		else if data.kind == NodeKind::NumericExpression {
			@dynamicReturn = true
			@returnType = node.scope().reference('Number')
			@returnData = data

			return
		}

		@returnType = Type.fromAST(data, node)
	} # }}}
	setReturnType(@returnType): this
	toFragments(fragments, node) { # {{{
		fragments.code('Function')
	} # }}}
	toQuote() { # {{{
		var mut fragments = ''

		fragments += '('

		for var parameter, index in @parameters {
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
}

class OverloadedFunctionType extends Type {
	private {
		@altering: Boolean					= false
		@assessment							= null
		@async: Boolean						= false
		@functions: Array<FunctionType>		= []
		@majorOriginal: Type?
		@references: Array<Type>			= []
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): OverloadedFunctionType { # {{{
			var type = new OverloadedFunctionType(scope)

			if ?data.exhaustive {
				type._exhaustive = data.exhaustive
			}

			queue.push(() => {
				for var function in data.functions {
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

		for var function in type.functions() {
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

		var fn = new FunctionType(@scope, 0)
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
		var functions = []

		var overloadedMode = mode + ExportMode::OverloadedFunction

		for var reference in @references {
			if reference._referenceIndex == -1 && reference is OverloadedFunctionType {
				for var fn in reference.functions() when fn.isExportable(mode) {
					functions.push(fn.toExportOrReference(references, indexDelta, overloadedMode, module))
				}
			}
			else if reference.isExportable(mode) {
				functions.push(reference.toExportOrReference(references, indexDelta, overloadedMode, module))
			}
		}

		return {
			kind: TypeKind::OverloadedFunction
			exhaustive: @isExhaustive()
			functions
		}
	} # }}}
	functions() => @functions
	hasFunction(type: FunctionType) { # {{{
		for var function in @functions {
			if function.equals(type) {
				return true
			}
		}

		return false
	} # }}}
	isAsync() => @async
	isExportable() { # {{{
		for var reference in @references {
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

		for var fb in value.functions() {
			var mut nf = true

			for var fn in @functions while nf {
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
		var assessment = this.assessment('', node)

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
