class FunctionType extends Type {
	private {
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
		_returnType: Type					= Type.Any
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

			type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]

			if data.returns? {
				type._returnType = Type.fromMetadata(data.returns, metadata, references, alterations, queue, scope, node)
				type._missingReturn = false
			}

			type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

			type.updateArguments()

			if data.sealed == true {
				type.flagSealed()
			}


			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new FunctionType(scope)

			type._async = data.async
			type._min = data.min
			type._max = data.max

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
	}
	constructor(@scope) { // {{{
		super(scope)
	} // }}}
	constructor(parameters: Array<ParameterType>, data, node) { // {{{
		super(node.scope())

		if data.type? {
			@returnType = Type.fromAST(data.type, node)
			@missingReturn = false
		}

		let last: Type = null

		for parameter in parameters {
			if last == null {
				@parameters.push(last = parameter.clone())
			}
			else if !parameter._type.equals(last._type) {
				if last._max == Infinity {
					if @max == Infinity {
						SyntaxException.throwTooMuchRestParameter(node)
					}
					else {
						@max = Infinity
					}
				}
				else {
					@max += last._max
				}

				@min += last._min

				@parameters.push(last = parameter.clone())
			}
			else {
				if parameter._max == Infinity {
					last._max = Infinity
				}
				else {
					last._max += parameter._max
				}

				last._min += parameter._min
			}
		}

		if last != null {
			if last._max == Infinity {
				if @max == Infinity {
					SyntaxException.throwTooMuchRestParameter(node)
				}
				else {
					@max = Infinity
				}
			}
			else {
				@max += last._max
			}

			@min += last._min
		}

		if data.modifiers? {
			this.processModifiers(data.modifiers)
		}

		if data.throws? {
			let type

			for throw in data.throws {
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
		let last

		if @parameters.length == 0 {
			@parameters.push(new ParameterType(@scope, type, min, max))
		}
		else if type.equals((last = @parameters[@parameters.length - 1])._type) {
			if max == Infinity {
				last._max = Infinity
			}
			else {
				last._max += max
			}

			last._min += min
		}

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
	async() { // {{{
		@async = true
	} // }}}
	equals(b?): Boolean { // {{{
		if b is ReferenceType {
			return b.name() == 'Function'
		}
		else if b is not FunctionType {
			return false
		}

		if @async != b._async || @hasRest != b._hasRest || @max != b._max || @min != b._min || @restIndex != b._restIndex || @parameters.length != b._parameters.length {
			return false
		}

		for parameter, index in @parameters {
			if !parameter.equals(b._parameters[index]) {
				return false
			}
		}

		return true
	} // }}}
	export(references, ignoreAlteration) => { // {{{
		kind: TypeKind::Function
		async: @async
		min: @min
		max: @max
		parameters: [parameter.export(references, ignoreAlteration) for parameter in @parameters]
		returns: @returnType.toReference(references, ignoreAlteration)
		throws: [throw.toReference(references, ignoreAlteration) for throw in @throws]
	} // }}}
	flagExported() { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for parameter in @parameters {
			parameter.type().flagExported()
		}

		for error in @throws {
			error.type().flagExported()
		}

		@returnType.flagExported()

		return this
	} // }}}
	getProperty(name: String) => Type.Any
	index() => @index
	index(@index) => this
	isAsync() => @async
	isCatchingError(error): Boolean { // {{{
		for type in @throws {
			if error.matchInheritanceOf(type) {
				return true
			}
		}

		return false
	} // }}}
	isFunction() => true
	isMorePreciseThan(type: Type) { // {{{
		if type.isAny() {
			return true
		}

		return false
	} // }}}
	isInstanceOf(target: ReferenceType) => target.name() == 'Function'
	matchSignatureOf(value: Type, matchables): Boolean { // {{{
		// console.log(this)
		// console.log(value)
		if value is ReferenceType {
			return value.isFunction()
		}
		else if value is FunctionType {
			// console.log(this.matchArguments(value._parameters))
			// console.log(@returnType.matchSignatureOf(value._returnType))
			return (@missingParameters || this.matchArguments(value._parameters)) && (@missingReturn || @returnType.matchSignatureOf(value._returnType, matchables))
		}
		else if value is OverloadedFunctionType {
			throw new NotImplementedException()
		}

		return false
	} // }}}
	matchArguments(arguments: Array<Type>) { // {{{
		// console.log(@parameters)
		// console.log(arguments)
		if arguments.length == 0 {
			return @min == 0
		}
		else if arguments[0] is ParameterType {
			if @parameters.length != arguments.length {
				return false
			}

			for parameter, i in @parameters {
				if !parameter.matchContentTo(arguments[i]) {
					return false
				}
			}

			return true
		}
		else {
			if !(@min <= arguments.length <= @max) {
				return false
			}

			if arguments.length == 0 {
				return true
			}
			else if @parameters.length == 1 {
				const parameter = @parameters[0]

				for argument in arguments {
					if !parameter.matchContentTo(argument) {
						return false
					}
				}

				return true
			}
			else if @hasRest {
				let a = 0
				let b = arguments.length - 1

				for i from @parameters.length - 1 til @restIndex by -1 {
					parameter = @parameters[i]

					for j from 0 til parameter.min() {
						if !parameter.matchContentTo(arguments[b]) {
							return false
						}

						--b
					}
				}

				let optional = @maxBefore - @minBefore

				for i from 0 til @restIndex {
					parameter = @parameters[i]

					for j from 0 til parameter.min() {
						if !parameter.matchContentTo(arguments[a]) {
							return false
						}

						++a
					}

					for j from parameter.min() til parameter.max() while optional != 0 when parameter.matchContentTo(arguments[a]) {
						++a
						--optional
					}
				}

				parameter = @parameters[@restIndex]
				for j from 0 til parameter.min() {
					if !parameter.matchContentTo(arguments[a]) {
						return false
					}

					++a
				}

				return true
			}
			else if arguments.length == @parameters.length {
				for parameter, i in @parameters {
					if !parameter.matchContentTo(arguments[i]) {
						return false
					}
				}

				return true
			}
			else if arguments.length == @max {
				let a = -1

				let p
				for parameter in @parameters {
					for p from 0 til parameter.max() {
						if !parameter.matchContentTo(arguments[++a]) {
							return false
						}
					}
				}

				return true
			}
			else {
				let a = 0
				let optional = arguments.length - @min

				for parameter in @parameters {
					for i from 0 til parameter.min() {
						if !parameter.matchContentTo(arguments[a]) {
							return false
						}

						++a
					}

					for i from parameter.min() til parameter.max() while optional > 0 when parameter.matchContentTo(arguments[a]) {
						++a
						--optional
					}
				}

				return optional == 0
			}
		}
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
	returnType() => @returnType
	throws() => @throws
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote(): String { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
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
		_async: Boolean						= false
		_functions: Array<FunctionType>		= []
		_references: Array<Type>			= []
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new OverloadedFunctionType(scope)

			for function in data.functions {
				type.addFunction(Type.fromMetadata(function, metadata, references, alterations, queue, scope, node))
			}

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new OverloadedFunctionType(scope)

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
	} // }}}
	addFunction(type: OverloadedFunctionType) { // {{{
		if @functions.length == 0 {
			@async = type.isAsync()
		}

		for fn in type.functions() {
			@functions.push(fn)

			@references.pushUniq(type)
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
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, ignoreAlteration) { // {{{
		const functions = []

		for reference in @references {
			if reference._referenceIndex == -1 && reference is OverloadedFunctionType {
				for fn in reference.functions() {
					functions.push(fn.toExportOrReference(references, ignoreAlteration))
				}
			}
			else {
				functions.push(reference.toExportOrReference(references, ignoreAlteration))
			}
		}

		return {
			kind: TypeKind::OverloadedFunction
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
	isFunction() => true
	isMergeable(type) => type is OverloadedFunctionType && @async == type.isAsync()
	isMorePreciseThan(type: Type) { // {{{
		if type.isAny() {
			return true
		}

		return false
	} // }}}
	matchSignatureOf(value: Type, matchables) { // {{{
		if value is ReferenceType {
			return value.isFunction()
		}
		else if value is FunctionType {
			for fn in @functions {
				if fn.matchSignatureOf(value, matchables) {
					return true
				}
			}
		}
		else if value is OverloadedFunctionType {
			let nf
			for fb in value.functions() {
				nf = true

				for fn in @functions while nf {
					if fn.matchSignatureOf(fb, matchables) {
						nf = false
					}
				}

				if nf {
					return false
				}
			}

			return true
		}
		else if value is NamedType {
			return this.matchSignatureOf(value.type(), matchables)
		}

		return false
	} // }}}
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
}