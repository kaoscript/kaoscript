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
		// TODO
		// @assessment: Router.Assessment?		= null
		@assessment							= null
		@assignableThis: Boolean			= true
		@async: Boolean						= false
		@autoTyping: Boolean				= false
		@errors: Array<Type>				= []
		@generics: Generic[]				= []
		@hasRest: Boolean					= false
		@index: Number						= -1
		@maxs: Number{}						= {}
		@mins: Number{}						= {}
		@missingParameters: Boolean			= false
		@missingReturn: Boolean				= true
		@missingThis: Boolean				= true
		@parameters: Array<ParameterType>	= []
		@restIndex: Number					= -1
		@returnType: Type					= AnyType.NullableUnexplicit
		@thisType: Type						= AnyType.Unexplicit
	}
	static {
		clone(source: FunctionType, target: FunctionType): FunctionType { # {{{
			target._alien = source._alien
			target._async = source._async
			target._autoTyping = source._autoTyping
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
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): FunctionType { # {{{
			var type = FunctionType.new(scope)

			type._index = data.index ?? -1
			type._async = data.async

			if ?data.exhaustive {
				type._exhaustive = data.exhaustive
			}

			queue.push(() => {
				if ?data.this {
					type._thisType = Type.import(data.this, metadata, references, alterations, queue, scope, node)
					type._missingThis = false
				}

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
	constructor(parameters: ParameterType[]?, @generics = [], availables: Generic[] = generics, data, node) { # {{{
		super(node.scope())

		if ?data.type {
			@setReturnType(data.type, availables, node)

			@missingReturn = false
		}

		if ?#parameters {
			for var parameter in parameters {
				@addParameter(parameter, node)
			}
		}

		if ?data.modifiers {
			@processModifiers(data.modifiers)
		}

		if ?data.throws {
			var dyn type

			for var throw in data.throws {
				if (type ?= Type.fromAST(throw, availables, node).discardReference()) && type.isNamed() && type.isClass() {
					@errors.push(type)
				}
				else {
					TypeException.throwNotClass(throw.name, node)
				}
			}
		}
	} # }}}
	constructor(parameters: ParameterType[]?, @generics = [], data, @index, node) { # {{{
		this(parameters, generics, data, node)
	} # }}}
	addError(...types: Type) { # {{{
		@errors.pushUniq(...types)
	} # }}}
	addParameter(type: Type, name: String?, min, max) { # {{{
		var parameter = ParameterType.new(@scope, name, name, type, min, max)

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
	override applyGenerics(generics) { # {{{
		var result = @clone()

		for var parameter, index in result._parameters {
			result._parameters[index] = parameter.applyGenerics(generics)
		}

		if !@missingReturn {
			result._returnType = result._returnType.applyGenerics(generics)
		}

		if !@missingThis {
			result._thisType = result._thisType.applyGenerics(generics)
		}

		return result
	} # }}}
	assessment(name: String, node: AbstractNode) { # {{{
		@assessment ??= Router.assess([this], name, node)

		return @assessment
	} # }}}
	assist(main: FunctionType, mainParameters: Parameter[], node: AbstractNode): Void { # {{{
		if @missingReturn && !main.isMissingReturn() {
			@returnType = main.getReturnType()
			@missingReturn = false
		}

		for var parameter, index in @parameters {
			var mainParameter = main.parameter(index)

			if parameter.isMissingType() && !mainParameter.isMissingType() {
				var externalName = parameter.getExternalName()
				var internalName = parameter.getInternalName()
				var passing = mainParameter.getPassingMode()
				var type = mainParameter.type()
				var min = mainParameter.min()
				var max = mainParameter.max()

				var newParameter = ParameterType.new(@scope, externalName, internalName, passing, type, min, max)

				if parameter.hasDefaultValue() {
					newParameter.setDefaultValue(parameter.getDefaultValue(), parameter.isComprehensive(), parameter.isRequiringValue(), node)
				}
				else if mainParameter.hasDefaultValue() {
					newParameter.setDefaultValue(mainParameter.getDefaultValue(), mainParameter.isComprehensive(), mainParameter.isRequiringValue(), node)
				}

				newParameter.index(index)

				if newParameter.max() == Infinity {
					@restIndex = index
					@hasRest = true
				}

				@parameters[index] = newParameter

				mainParameters[index]
					..type(newParameter)
					..setDefaultValue(mainParameter.getDefaultValue()) if mainParameter.hasDefaultValue()
			}
		}
	} # }}}
	async() { # {{{
		@async = true
	} # }}}
	buildGenericMap(expressions: Expression[]?): AltType[] { # {{{
		return [] unless ?#expressions

		var map = {}

		for var parameter, index in @parameters {
			if parameter.isDeferrable() {
				parameter.type().buildGenericMap(CallMatchArgument.new(index), expressions, value => value, map)
			}
		}

		var result = []

		for var types, name of map {
			if types.length == 1 {
				result.push({ name, type: types[0] })
			}
			else {
				NotImplementedException.throw()
			}
		}

		return result
	} # }}}
	buildGenericMap(positions: CallMatchPosition[], expressions: Expression[]?): AltType[] { # {{{
		return [] unless ?#expressions

		var map = {}

		for var position, index in positions {
			var parameter = @parameters[index].type()

			if parameter.isDeferrable() {
				parameter.buildGenericMap(position, expressions, value => value, map)
			}
		}

		var result = []

		for var types, name of map {
			if types.length == 1 {
				result.push({ name, type: types[0] })
			}
			else {
				NotImplementedException.throw()
			}
		}

		return result
	} # }}}
	clone() { # {{{
		var clone = FunctionType.new(@scope)

		FunctionType.clone(this, clone)

		clone._missingThis = @missingThis
		clone._thisType = @thisType

		return clone
	} # }}}
	compareToRef(value: AnyType, equivalences: String[][]? = null) { # {{{
		return -1
	} # }}}
	compareToRef(value: FunctionType, equivalences: String[][]? = null) { # {{{
		return value.max() - @max()
	} # }}}
	compareToRef(value: Type, equivalences: String[][]? = null) { # {{{
		return 1
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var result = {
			kind: TypeKind.Function
		}

		if !@isAlien() && @index != -1 {
			result.index = @index
		}

		result.async = @async

		if mode !~ ExportMode.OverloadedFunction {
			result.exhaustive = @isExhaustive()
		}

		if @assignableThis && @thisType != AnyType.Unexplicit {
			result.this = @thisType.toReference(references, indexDelta, mode, module)
		}

		result.parameters = [parameter.export(references, indexDelta, mode, module) for var parameter in @parameters]
		result.returns = @returnType.toReference(references, indexDelta, mode, module)
		result.errors = [throw.toReference(references, indexDelta, mode, module) for var throw in @errors]

		return result
	} # }}}
	override extractFunction() => this
	flagExported(explicitly: Boolean) { # {{{
		if @exported {
			return this
		}

		@exported = true

		for var parameter in @parameters {
			parameter.getVariableType().flagExported(false)
		}

		for var error in @errors {
			error.flagExported(false)
		}

		@returnType.flagExported(false)

		return this
	} # }}}
	override flagIndirectlyReferenced()
	functions() => [this]
	generics() => @generics
	getCallIndex() => @alien ? 0 : @index
	getProperty(name: String) => Type.Any
	getRestIndex(): valueof @restIndex
	getRestParameter() => @parameters[@restIndex]
	getReturnType(): valueof @returnType
	getThisType(): valueof @thisType
	hashCode() { # {{{
		var mut fragments = ''

		if ?#@generics {
			fragments += '<'

			for var {name}, index in @generics {
				fragments += ', ' if index != 0
				fragments += name
			}

			fragments += '>'
		}

		fragments += '('

		if !@missingThis && @assignableThis {
			if @thisType.isAny() {
				fragments += 'this'
			}
			else {
				fragments += `this: \(@thisType.toQuote())`
			}

			if ?#@parameters {
				fragments += ', '
			}
		}

		for var parameter, index in @parameters {
			if index != 0 {
				fragments += ', '
			}

			fragments += parameter.toQuote()

			if parameter.hasDefaultValue() {
				fragments += ' = ?'
			}
		}

		fragments += ')'

		if @returnType.isExplicit() {
			fragments += ': ' + @returnType.toQuote()
		}

		return fragments
	} # }}}
	hasAssignableThis() => @assignableThis
	hasGenerics() => ?#@generics
	hasRestParameter(): valueof @hasRest
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
	index(): valueof @index
	index(@index): valueof this
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value is FunctionType {
			var mut mode = MatchingMode.FunctionSignature

			if anycast {
				mode += MatchingMode.AnycastParameter + MatchingMode.MissingReturn
			}

			return value.isSubsetOf(this, mode)
		}
		else if value.isAny() {
			return true
		}
		else if value.isAlias() {
			return @isAssignableToVariable(value.discardAlias(), anycast, nullcast, downcast)
		}
		else if value is UnionType {
			for var type in value.types() {
				if @isAssignableToVariable(type, anycast, nullcast, downcast) {
					return true
				}
			}
		}
		else if value.isFunction() {
			return true
		}

		return false
	} # }}}
	isAsync(): valueof @async
	isAutoTyping(): valueof @autoTyping
	isCatchingError(error): Boolean { # {{{
		if @errors.length != 0 {
			for var type in @errors {
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
	isDeferrable() { # {{{
		for var parameter in @parameters {
			if parameter.isDeferrable() {
				return true
			}
		}

		return true if @returnType.isDeferrable()

		for var error in @errors {
			if error.isDeferrable() {
				return true
			}
		}

		return false
	} # }}}
	override isExportable() { # {{{
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
	override isExportable(module) { # {{{
		return false unless !@standardLibrary || module.isStandardLibrary()

		return @isExportable()
	} # }}}
	isExtendable() => true
	isFunction() => true
	isMissingError() => @errors.length == 0
	isMissingReturn() => @missingReturn
	isMissingThis() => @missingThis
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
	assist isInstanceOf(value: ReferenceType, generics, subtypes) => value.name() == 'Function'
	private isParametersMatching(arguments: Array, mode: MatchingMode): Boolean => @isParametersMatching(0, -1, arguments, 0, -1, mode)
	private isParametersMatching(pIndex, pStep, arguments, aIndex, aStep, mode: MatchingMode) { # {{{
		// echo(pIndex, pStep, @parameters[pIndex]?.toQuote(), aIndex, aStep, arguments[aIndex]?.toQuote())
		if pStep == -1 {
			if pIndex >= @parameters.length {
				if mode !~ MatchingMode.RequireAllParameters {
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
	assist isSubsetOf(value: AnyType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Missing {
			return true
		}

		return false
	} # }}}
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) { # {{{
		if value.isAlias() {
			var { type, generics, subtypes } = value.getGenericMapper()

			return @isSubsetOf(type, generics, subtypes, mode)
		}

		return value.isFunction()
	} # }}}
	assist isSubsetOf(value: FunctionType, generics, subtypes, mut mode) { # {{{
		if @async != value._async {
			return false
		}

		if mode ~~ MatchingMode.Exact {
			mode += MatchingMode.ExactParameter + MatchingMode.ExactReturn
		}
		else if mode ~~ MatchingMode.Similar {
			mode += MatchingMode.SimilarParameter + MatchingMode.SimilarReturn
		}

		if mode ~~ MatchingMode.MissingParameter && @missingParameters {
			pass
		}
		else if mode ~~ MatchingMode.ShiftableParameters {
			var mut paramMode = MatchingMode.Default

			paramMode += MatchingMode.Exact if mode ~~ MatchingMode.ExactParameter
			paramMode += MatchingMode.Similar if mode ~~ MatchingMode.SimilarParameter
			paramMode += MatchingMode.MissingType if mode ~~ MatchingMode.MissingParameterType
			paramMode += MatchingMode.Subclass if mode ~~ MatchingMode.SubclassParameter
			paramMode += MatchingMode.Subset if mode ~~ MatchingMode.SubsetParameter
			paramMode += MatchingMode.NonNullToNull if mode ~~ MatchingMode.NonNullToNullParameter
			paramMode += MatchingMode.NullToNonNull if mode ~~ MatchingMode.NullToNonNullParameter
			paramMode += MatchingMode.MissingDefault if mode ~~ MatchingMode.MissingParameterDefault
			paramMode += MatchingMode.MissingArity if mode ~~ MatchingMode.MissingParameterArity
			paramMode += MatchingMode.Renamed if mode ~~ MatchingMode.Renamed
			paramMode += MatchingMode.IgnoreName if mode ~~ MatchingMode.IgnoreName
			paramMode += MatchingMode.IgnoreRetained if mode ~~ MatchingMode.IgnoreRetained
			paramMode += MatchingMode.Anycast if mode ~~ MatchingMode.AnycastParameter
			paramMode += MatchingMode.IgnoreAnonymous if mode ~~ MatchingMode.IgnoreAnonymous
			paramMode += MatchingMode.IgnoreNullable if mode ~~ MatchingMode.IgnoreNullable
			paramMode += MatchingMode.RequireAllParameters if mode ~~ MatchingMode.RequireAllParameters

			if !value.isParametersMatching(@parameters, paramMode) {
				return false
			}
		}
		else {
			if mode ~~ MatchingMode.AdditionalParameter {
				if @parameters.length < value._parameters.length {
					if mode !~ MatchingMode.MissingParameterDefault && @min() < value.min() {
						return false
					}

					for var parameter in value._parameters from @parameters.length {
						if parameter.min() != 0 {
							return false
						}
					}
				}
				else {
					if mode !~ MatchingMode.MissingParameterArity {
						if @max() < value.max() {
							return false
						}

						if mode !~ MatchingMode.MissingParameterDefault && @min() < value.min() {
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
			else if mode ~~ MatchingMode.MissingParameter {
				if @parameters.length > value._parameters.length {
					return false
				}

				for var parameter in value._parameters from @parameters.length {
					return false unless parameter.min() == 0
				}

				if mode !~ MatchingMode.MissingParameterArity && (@hasRest != value._hasRest || @restIndex != value._restIndex) {
					return false
				}

				if mode !~ MatchingMode.MissingParameterDefault && @min() != value.min() {
					return false
				}
			}
			else {
				if @parameters.length != value._parameters.length {
					return false
				}

				if mode !~ MatchingMode.MissingParameterArity && (@hasRest != value._hasRest || @restIndex != value._restIndex) {
					return false
				}

				if mode !~ MatchingMode.MissingParameterDefault && (@min() != value.min() || @max() != value.max()) {
					return false
				}
			}

			var mut paramMode = MatchingMode.Default

			paramMode += MatchingMode.Exact if mode ~~ MatchingMode.ExactParameter
			paramMode += MatchingMode.Similar if mode ~~ MatchingMode.SimilarParameter
			paramMode += MatchingMode.MissingType if mode ~~ MatchingMode.MissingParameterType
			paramMode += MatchingMode.Subclass if mode ~~ MatchingMode.SubclassParameter
			paramMode += MatchingMode.Subset if mode ~~ MatchingMode.SubsetParameter
			paramMode += MatchingMode.NonNullToNull if mode ~~ MatchingMode.NonNullToNullParameter
			paramMode += MatchingMode.NullToNonNull if mode ~~ MatchingMode.NullToNonNullParameter
			paramMode += MatchingMode.MissingDefault if mode ~~ MatchingMode.MissingParameterDefault
			paramMode += MatchingMode.MissingArity if mode ~~ MatchingMode.MissingParameterArity
			paramMode += MatchingMode.Renamed if mode ~~ MatchingMode.Renamed
			paramMode += MatchingMode.IgnoreName if mode ~~ MatchingMode.IgnoreName
			paramMode += MatchingMode.IgnoreRetained if mode ~~ MatchingMode.IgnoreRetained
			paramMode += MatchingMode.Anycast if mode ~~ MatchingMode.AnycastParameter
			paramMode += MatchingMode.IgnoreAnonymous if mode ~~ MatchingMode.IgnoreAnonymous

			if paramMode.value != 0 {
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
				var testLabel = mode !~ MatchingMode.IgnoreName

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

		if mode ~~ MatchingMode.IgnoreReturn {
			pass
		}
		else if !?@returnType {
			return false unless value.isMissingReturn()
		}
		else if !(mode ~~ MatchingMode.MissingReturn && value.isMissingReturn()) {
			var mut returnMode = MatchingMode.Default

			returnMode += MatchingMode.Exact if mode ~~ MatchingMode.ExactReturn
			returnMode += MatchingMode.Similar if mode ~~ MatchingMode.SimilarReturn
			returnMode += MatchingMode.Subclass if mode ~~ MatchingMode.SubclassReturn

			if returnMode.value != 0 {
				var newType = value.getReturnType()

				return false unless newType.isSubsetOf(@returnType, generics, subtypes, returnMode) || @returnType.isInstanceOf(newType, generics, subtypes)
			}
		}

		if mode ~~ MatchingMode.IgnoreError {
			pass
		}
		else if @errors.length == 0 {
			return false unless value.isMissingError()
		}
		else if !(mode ~~ MatchingMode.MissingError && value.isMissingError()) {
			var mut errorMode = MatchingMode.Default

			errorMode += MatchingMode.Exact if mode ~~ MatchingMode.ExactError
			errorMode += MatchingMode.Similar if mode ~~ MatchingMode.SimilarErrors
			errorMode += MatchingMode.Subclass if mode ~~ MatchingMode.SubclassError

			if errorMode.value != 0 {
				var newTypes = value.listErrors()

				for var oldType in @errors {
					var mut matched = false

					for var newType in newTypes until matched {
						if newType.isSubsetOf(oldType, errorMode) || oldType.isInstanceOf(newType, generics, subtypes) {
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
	override makeCallee(name, generics, node) { # {{{
		var assessment = this.assessment(name, node)

		match var result = node.matchArguments(assessment, generics) {
			is LenientCallMatchResult {
				node.addCallee(LenientFunctionCallee.new(node.data(), assessment, result, node))
			}
			is PreciseCallMatchResult with var { matches } {
				if matches.length == 1 {
					var match = matches[0]

					if match.function.isAlien() || match.function.index() == -1 || match.function is ClassMethodType {
						node.addCallee(LenientFunctionCallee.new(node.data(), assessment, [match.function], node))
					}
					else {
						node.addCallee(PreciseFunctionCallee.new(node.data(), assessment, matches, node))
					}
				}
				else if node.getMatchingMode() == .AllMatches {
					node.addCallee(PreciseFunctionCallee.new(node.data(), assessment, matches, node))
				}
				else {
					var functions = [match.function for var match in matches]

					node.addCallee(LenientFunctionCallee.new(node.data(), assessment, functions, node))
				}
			}
			else {
				return () => {
					match result {
						.NoArgumentMatch {
							if @isExhaustive(node) {
								ReferenceException.throwNoMatchingFunction(name, node.arguments(), node)
							}
							else {
								node.addCallee(DefaultCallee.new(node.data(), null, null, node))
							}
						}
						.NoThisMatch {
							if ?node.getCallScope() {
								ReferenceException.throwNoMatchingThis(name, node)
							}
							else {
								ReferenceException.throwMissingThisContext(name, node)
							}
						}
					}
				}
			}
		}

		return null
	} # }}}
	override makeMemberCallee(property, path, generics, node) { # {{{
		return @scope.reference('Function').makeMemberCallee(property, path, generics, node)
	} # }}}
	matchArguments(arguments: Array, node: AbstractNode) { # {{{
		var assessment = this.assessment('', node)

		return Router.matchArguments(assessment, null, arguments, [], node) is not NoMatchResult
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
	max(mode: MinMax = MinMax.DEFAULT, mut excludes: String[]? = null) { # {{{
		var key = ?#excludes ? `\(mode)/\(excludes.sort((a, b) => a.localeCompare(b)).join(','))` : `\(mode)/`

		if var max ?= @maxs[key] {
			return max
		}

		excludes ??= []

		var mut max = 0

		if mode ~~ MinMax.AFTER_REST {
			if @hasRest {
				for var parameter in @parameters from @restIndex + 1 when parameter.isPositional() && !excludes.contains(parameter.getExternalName()) {
					max += parameter.max()
				}
			}
		}
		else if mode ~~ MinMax.DEFAULT {
			for var parameter in @parameters when !excludes.contains(parameter.getExternalName()) {
				max += parameter.max()
			}
		}
		else if mode ~~ MinMax.LABELED_ONLY {
			for var parameter in @parameters when parameter.isOnlyLabeled() && !excludes.contains(parameter.getExternalName()) {
				max += parameter.max()
			}
		}
		else if mode ~~ MinMax.POSITIONAL {
			if @hasRest && mode ~~ MinMax.REST {
				max = Infinity
			}
			else {
				for var parameter in @parameters when parameter.isPositional() && parameter.isLimited() && !excludes.contains(parameter.getExternalName()) {
					max += parameter.max()
				}
			}
		}

		if @async && mode ~~ MinMax.ASYNC {
			max += 1
		}

		@maxs[key] = max

		return max
	} # }}}
	min(mode: MinMax = MinMax.DEFAULT, mut excludes: String[]? = null) { # {{{
		var key = ?#excludes ? `\(mode)/\(excludes.sort((a, b) => a.localeCompare(b)).join(','))` : `\(mode)/`

		if var min ?= @mins[key] {
			return min
		}

		excludes ??= []

		var mut min = 0

		if mode ~~ MinMax.AFTER_REST {
			if @hasRest {
				for var parameter in @parameters from @restIndex + 1 when parameter.isPositional() && !excludes.contains(parameter.getExternalName()) {
					min += parameter.min()
				}
			}
		}
		else if mode ~~ MinMax.DEFAULT {
			for var parameter in @parameters when !excludes.contains(parameter.getExternalName()) {
				min += parameter.min()
			}
		}
		else if mode ~~ MinMax.LABELED_ONLY {
			for var parameter in @parameters when parameter.isOnlyLabeled() && !excludes.contains(parameter.getExternalName()) {
				min += parameter.min()
			}
		}
		else if mode ~~ MinMax.POSITIONAL {
			if mode ~~ MinMax.REST {
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

		if @async && mode ~~ MinMax.ASYNC {
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
		for var modifier in modifiers {
			match modifier.kind {
				ModifierKind.Async {
					@async = true
				}
				ModifierKind.AutoType {
					@autoTyping = true
				}
			}
		}
	} # }}}
	pushTo(methods) { # {{{
		for var method in methods {
			if this.isSubsetOf(method, MatchingMode.SimilarParameter) {
				return
			}
		}

		methods.push(this)
	} # }}}
	setReturnType(data?, generics: Generic[], node) { # {{{
		if !?data {
			@returnType = AnyType.NullableUnexplicit
		}
		else if data.kind == NodeKind.TypeReference && data.typeName.kind == NodeKind.Identifier && data.typeName.name == 'auto' {
			@autoTyping = true
		}
		else {
			@returnType = Type.fromAST(data, generics, node)
		}
	} # }}}
	setReturnType(@returnType): valueof this
	setThisType(@thisType): valueof this { # {{{
		@missingThis = false
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, _, _, mut generics, subtypes, fragments, node) { # {{{
		fragments.code(`\($runtime.typeof('Function', node))`)
	} # }}}
	override toBlindTestFunctionFragments(funcname, varname, _, testingType, generics, fragments, node) { # {{{
		fragments.code(`\($runtime.typeof('Function', node))`)
	} # }}}
	toFragments(fragments, node) { # {{{
		fragments.code('Function')
	} # }}}
	toQuote() { # {{{
		var mut fragments = ''

		if ?#@generics {
			fragments += `<\(@generics.join(', '))>`
		}

		fragments += '('

		if !@missingThis && @assignableThis {
			if @thisType.isAny() {
				fragments += 'this'
			}
			else {
				fragments += `this: \(@thisType.toQuote())`
			}

			if ?#@parameters {
				fragments += ', '
			}
		}

		for var parameter, index in @parameters {
			if index != 0 {
				fragments += ', '
			}

			fragments += parameter.toQuote()
		}

		fragments += ')'

		if !@returnType.isAny() {
			fragments += ': ' + @returnType.toQuote()
		}

		return fragments
	} # }}}
	override toPositiveTestFragments(_, _, _, fragments, node) { # {{{
		fragments
			.code($runtime.type(node) + '.isFunction(')
			.compile(node)
			.code(')')
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('func', 1)
	} # }}}
	unflagAssignableThis(): valueof this { # {{{
		@assignableThis = false
		@missingThis = false
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
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): OverloadedFunctionType { # {{{
			var type = OverloadedFunctionType.new(scope)

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
	constructor(@scope) { # {{{
		super(@scope)
	} # }}}
	constructor(@scope, @functions) { # {{{
		super(scope)

		for var function in functions {
			if function.isAsync() {
				@async = true
				break
			}
		}
	} # }}}
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

		var fn = FunctionType.new(@scope, 0)
		fn.addParameter(AnyType.NullableExplicit, null, 0, Infinity)

		fn._missingParameters = true

		@functions.push(fn)

		@references.pushUniq(type)
	} # }}}
	assessment(name: String, node: AbstractNode) { # {{{
		@assessment ??= Router.assess(@functions, name, node)

		return @assessment
	} # }}}
	clone() { # {{{
		var that = OverloadedFunctionType.new(@scope, [function.clone() for var function in @functions])

		return that
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var functions = []

		var overloadedMode = mode + ExportMode.OverloadedFunction

		for var reference in @references {
			if reference._referenceIndex == -1 && reference is OverloadedFunctionType {
				for var fn in reference.functions() when fn.isExportable(mode, module) {
					functions.push(fn.toExportOrIndex(references, indexDelta, overloadedMode, module))
				}
			}
			else if reference.isExportable(mode, module) {
				functions.push(reference.toExportOrIndex(references, indexDelta, overloadedMode, module))
			}
		}

		return {
			kind: TypeKind.OverloadedFunction
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
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if @isNullable() {
				return nullcast || limited || value.isNullable()
			}
			else {
				return true
			}
		}
		else if limited {
			for var function in @functions {
				if function.isAssignableToVariable(value, anycast, nullcast, downcast) {
					return true
				}
			}

			return false
		}
		else {
			for var function in @functions {
				if !function.isAssignableToVariable(value, anycast, nullcast, downcast) {
					return false
				}
			}

			return true
		}
	} # }}}
	isAsync() => @async
	override isExportable() { # {{{
		for var reference in @references {
			if reference.isExportable() {
				return true
			}
		}

		return false
	} # }}}
	override isExportable(module) { # {{{
		for var reference in @references {
			if reference.isExportable(module) {
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
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact {
			return false
		}

		return value.isFunction()
	} # }}}
	assist isSubsetOf(value: FunctionType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact {
			return false
		}

		for var fn in @functions {
			if fn.isSubsetOf(value, mode) {
				return true
			}
		}

		return false
	} # }}}
	assist isSubsetOf(value: OverloadedFunctionType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact {
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
	assist isSubsetOf(value: NamedType, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact {
			return false
		}

		return this.isSubsetOf(value.type(), mode)
	} # }}}
	length() => @functions.length
	override makeCallee(name, generics, node) { # {{{
		var assessment = this.assessment(name, node)

		match var result = node.matchArguments(assessment) {
			is LenientCallMatchResult {
				node.addCallee(LenientFunctionCallee.new(node.data(), assessment, result, node))
			}
			is PreciseCallMatchResult with var { matches } {
				if matches.length == 1 {
					var match = matches[0]

					if match.function.isAlien() || match.function.index() == -1 || match.function is ClassMethodType {
						node.addCallee(LenientFunctionCallee.new(node.data(), assessment, [match.function], node))
					}
					else {
						node.addCallee(PreciseFunctionCallee.new(node.data(), assessment, matches, node))
					}
				}
				else if node.getMatchingMode() == .AllMatches {
					node.addCallee(PreciseFunctionCallee.new(node.data(), assessment, matches, node))
				}
				else {
					var functions = [match.function for var match in matches]

					node.addCallee(LenientFunctionCallee.new(node.data(), assessment, functions, node))
				}
			}
			else {
				return () => {
					match result {
						.NoArgumentMatch {
							if @isExhaustive(node) {
								ReferenceException.throwNoMatchingFunction(name, node.arguments(), node)
							}
							else {
								node.addCallee(DefaultCallee.new(node.data(), null, null, node))
							}
						}
						.NoThisMatch {
							if ?node.getCallScope() {
								ReferenceException.throwNoMatchingThis(name, node)
							}
							else {
								ReferenceException.throwMissingThisContext(name, node)
							}
						}
					}
				}
			}
		}

		return null
	} # }}}
	matchArguments(arguments: Array, node: AbstractNode) { # {{{
		var assessment = this.assessment('', node)

		return Router.matchArguments(assessment, null, arguments, [], node) is not NoMatchResult
	} # }}}
	originals(@majorOriginal): valueof this { # {{{
		@altering = true
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new()
	} # }}}
	toQuote() { # {{{
		return [function.toQuote() for var function in @functions].join('|')
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('func', @functions.length)
	} # }}}
}
