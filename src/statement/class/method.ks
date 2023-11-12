namespace Method {
	type Matcher = {
		match(name: String): Array
		matchAll(name: String, type: FunctionType, mode: MatchingMode): Array
	}

	func noopList(name: String): Array => []
	func noopMatch(name: String, type: FunctionType, mode: MatchingMode): Array => []

	func instance(class: ClassDeclaration): Matcher { # {{{
		if class.isExtending() {
			if class.isImplementing() {
				return {
					match: (name: String): Array => {
						var result = class.extends().type().listInstanceMethods(name)

						for var interface in class.listInterfaces() {
							result.push(...interface.listFunctions(name)!?)
						}

						return result
					}
					matchAll: (name: String, type: FunctionType, mode: MatchingMode): Array => {
						var result = class.extends().type().listInstantiableMethods(name, type, mode)

						for var interface in class.listInterfaces() {
							result.push(...interface.listFunctions(name, type, mode)!?)
						}

						return result
					}
				}
			}
			else {
				return {
					match: (name: String): Array => {
						return class.extends().type().listInstanceMethods(name)
					}
					matchAll: (name: String, type: FunctionType, mode: MatchingMode): Array => {
						return class.extends().type().listInstantiableMethods(name, type, mode)
					}
				}
			}
		}
		else if class.isImplementing() {
			return {
				match: (name: String): Array => {
					var result = []

					for var interface in class.listInterfaces() {
						result.push(...interface.listFunctions(name)!?)
					}

					return result
				}
				matchAll: (name: String, type: FunctionType, mode: MatchingMode): Array => {
					var result = []

					for var interface in class.listInterfaces() {
						result.push(...interface.listFunctions(name, type, mode)!?)
					}

					return result
				}
			}
		}
		else {
			return {
				match: noopList
				matchAll: noopMatch
			}
		}
	} # }}}

	func instance(class: ClassType): Matcher { # {{{
		return {
			match: (name: String): Array => {
				return class.listInstantiableMethods(name)
			}
			matchAll: (name: String, type: FunctionType, mode: MatchingMode): Array => {
				return class.listInstantiableMethods(name, type, mode)
			}
		}
	} # }}}

	func static(class: ClassDeclaration): Matcher { # {{{
		if class.isExtending() {
			var superClass = class.extends().type()

			return {
				match: (name: String): Array => superClass.listStaticMethods(name)
				matchAll: (name: String, type: FunctionType, mode: MatchingMode): Array => superClass.listStaticMethods(name, type, mode)
			}
		}
		else {
			return {
				match: noopList
				matchAll: noopMatch
			}
		}
	} # }}}

	export instance, static, Matcher
}

class ClassMethodDeclaration extends Statement {
	private late {
		@block: FunctionBlock
		@internalName: String
		@type: Type
	}
	private {
		@abstract: Boolean					= false
		@aliases: Array						= []
		@analysed: Boolean					= false
		@autoTyping: Boolean				= false
		@assist: Boolean					= false
		@awaiting: Boolean					= false
		@exact: Boolean						= false
		@exit: Boolean						= false
		@forked: Boolean					= false
		@forks: Array<ClassMethodType>?		= null
		@generics: Generic[]					= []
		@hiddenOverride: Boolean			= false
		@indigentValues: Array				= []
		@instance: Boolean					= true
		@name: String
		@offset: Number						= 0
		@override: Boolean					= false
		@overriding: Boolean				= false
		@parameters: Array<Parameter>		= []
		@returnNull: Boolean				= false
		@topNodes: Array					= []
	}
	static toClassRouterFragments(node, fragments, variable, methods, overflow, name: String, class: ClassType, header, footer) { # {{{
		var classname = variable.name()
		var labelable = class.isLabelableStaticMethod(name)
		var assessment = Router.assess(methods, name, node)

		header(node, fragments, labelable)

		if variable.type().isExtending() {
			var extends = variable.type().extends()
			var parent = extends.name()

			Router.toFragments(
				(function, line) => {
					line.code(`\(classname).__ks_sttc_\(name)_\(function.index())(`)

					return false
				}
				labelable ? 'args' : `arguments`
				assessment
				fragments.block()
				extends.type().hasStaticMethod(name) ? Router.FooterType.NO_THROW : Router.FooterType.MIGHT_THROW
				(fragments, _) => {
					if extends.type().hasStaticMethod(name) {
						if labelable {
							fragments.line(`return \(parent).\(name).call(null, kws, ...args)`)
						}
						else {
							fragments.line(`return \(parent).\(name).apply(null, arguments)`)
						}
					}
					else {
						var ctrl = fragments
							.newControl()
							.code(`if(\(parent).\(name))`)
							.step()

						if labelable {
							ctrl.line(`return \(parent).\(name).call(null, kws, ...args)`)
						}
						else {
							ctrl.line(`return \(parent).\(name).apply(null, arguments)`)
						}

						ctrl.done()

						fragments.line(`throw \($runtime.helper(node)).badArgs()`)
					}
				}
				node
			)
		}
		else {
			Router.toFragments(
				(function, line) => {
					line.code(`\(classname).__ks_sttc_\(name)_\(function.index())(`)

					return false
				}
				labelable ? 'args' : `arguments`
				assessment
				fragments.block()
				node
			)
		}

		footer(fragments)
	} # }}}
	static toInstanceHeadFragments(name: String, class: ClassType, fragments) { # {{{
		var ctrl = fragments.newControl()

		if class.isLabelableInstanceMethod(name) {
			ctrl.code(`\(name)(kws, ...args)`).step()

			ctrl.line(`return this.__ks_func_\(name)_rt.call(null, this, this, kws, args)`)
		}
		else {
			ctrl.code(`\(name)()`).step()

			ctrl.line(`return this.__ks_func_\(name)_rt.call(null, this, this, arguments)`)
		}

		ctrl.done()
	} # }}}
	static toInstanceRouterFragments(node, fragments, variable, methods, overflow, name: String, class: ClassType, header, footer) { # {{{
		var classname = variable.name()
		var labelable = class.isLabelableInstanceMethod(name)
		var assessment = Router.assess(methods, name, node)

		header(node, fragments, labelable)

		if variable.type().isExtending() {
			var extends = variable.type().extends()
			var parent = extends.name()

			Router.toFragments(
				(function, line) => {
					var index = function.isForked() ? function.getForkedIndex() : function.index()

					line.code(`proto.__ks_func_\(name)_\(index).call(that`)

					return true
				}
				null
				assessment
				fragments.block()
				extends.type().hasInstanceMethod(name) ? Router.FooterType.NO_THROW : Router.FooterType.MIGHT_THROW
				(fragments, _) => {
					if extends.type().hasInstanceMethod(name) {
						if extends.type().isSealedInstanceMethod(name) {
							fragments.line(`return \(extends.getSealedName()).__ks_func_\(name)_rt(that, args)`)
						}
						else if extends.type().isAlien() {
							fragments.line(`return super.\(name).apply(that, args)`)
						}
						else {
							fragments.line(`return super.__ks_func_\(name)_rt.call(null, that, \(parent).prototype, args)`)
						}
					}
					else {
						fragments
							.newControl()
							.code(`if(super.__ks_func_\(name)_rt)`)
							.step()
							.line(`return super.__ks_func_\(name)_rt.call(null, that, \(parent).prototype, args)`)
							.done()

						fragments.line(`throw \($runtime.helper(node)).badArgs()`)
					}
				}
				node
			)
		}
		else {
			Router.toFragments(
				(function, line) => {
					if variable.isSealed() {
						line.code(`this.__ks_func_\(name)_\(function.index())(`)

						return false
					}
					else {
						line.code(`proto.__ks_func_\(name)_\(function.index()).call(that`)

						return true
					}
				}
				null
				assessment
				fragments.block()
				node
			)
		}

		footer(fragments)
	} # }}}
	constructor(data, parent) { # {{{
		var mut instance = true

		for var modifier in data.modifiers {
			if modifier.kind == ModifierKind.Static {
				instance = false

				break
			}
		}

		super(data, parent, parent.newMethodScope(instance))

		@name = data.name.name
		@instance = instance

		for var modifier in data.modifiers {
			match modifier.kind {
				ModifierKind.Abstract {
					@abstract = true
				}
				ModifierKind.Assist {
					@assist = true
				}
				ModifierKind.Override {
					@override = true
				}
			}
		}

		if @instance {
			if @abstract {
				if parent._abstract {
					if parent._abstractMethods[@name] is Array {
						parent._abstractMethods[@name].push(this)
					}
					else {
						parent._abstractMethods[@name] = [this]
					}
				}
				else {
					SyntaxException.throwNotAbstractClass(parent._name, @name, parent)
				}
			}
			else {
				if parent._instanceMethods[@name] is Array {
					parent._instanceMethods[@name].push(this)
				}
				else {
					parent._instanceMethods[@name] = [this]
				}
			}
		}
		else if @name == 'name' || @name == 'version' {
			SyntaxException.throwReservedStaticMethod(@name, parent)
		}
		else {
			if parent.hasMacro(@name) {
				SyntaxException.throwIdenticalMacro(@name, this)
			}

			if parent._staticMethods[@name] is Array {
				parent._staticMethods[@name].push(this)
			}
			else {
				parent._staticMethods[@name] = [this]
			}
		}
	} # }}}
	analyse() { # {{{
		@offset = @scope.module().getLineOffset()

		@scope.line(@line())

		if #@data.typeParameters {
			for var parameter in @data.typeParameters {
				@generics.push(Type.toGeneric(parameter, this))
			}
		}

		for var data in @data.parameters {
			var parameter = Parameter.new(data, @generics, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		if ?@data.body {
			@returnNull = @data.body.kind == NodeKind.IfStatement || @data.body.kind == NodeKind.UnlessStatement
		}

		@block = MethodBlock.new($ast.block($ast.body(@data)), this, @scope)
	} # }}}
	override prepare(target, targetMode) { # {{{
		return if @analysed

		@scope
			..module().setLineOffset(@offset)
			..line(@line())

		@parent.updateMethodScope(this)

		for var parameter in @parameters {
			parameter.prepare()
		}

		@type = ClassMethodType.new([parameter.type() for var parameter in @parameters], @generics, @data, this)

		@type
			..unflagAssignableThis()
			..setThisType(@parent.type().reference()) if @instance

		var { overridden, overloaded } = @resolveOver()

		for var alias in @aliases {
			@type.flagInitializingInstanceVariable(alias.getVariableName())
		}

		@block
			..analyse(@aliases)
			..analyse()

		var return = @type.getReturnType()

		if return is ValueOfType {
			@block.addReturn(return.expression())
		}
		else if @type.isAutoTyping() {
			@type.setReturnType(@block.getUnpreparedType())

			@autoTyping = true
		}

		if @overriding {
			var oldType = overridden.getReturnType()
			var newType = @type.getReturnType()

			unless newType.isSubsetOf(oldType, MatchingMode.Exact + MatchingMode.Missing) || newType.isInstanceOf(oldType) {
				if @override {
					if @isAssertingOverride() {
						SyntaxException.throwNoOverridableMethod(@parent.extends(), @name, @parameters, this)
					}
					else {
						@override = false
					}
				}
				else {
					SyntaxException.throwInvalidMethodReturn(@parent.name(), @name, this)
				}
			}
		}

		if overloaded.length == 1 {
			var overload = overloaded[0]

			if @type.isMissingReturn() && !overload.isMissingReturn() {
				@type.setReturnType(overload.getReturnType())
			}

			if @type.isMissingError() && !overload.isMissingError() {
				@type.addError(...overload.listErrors()!?)
			}
		}
		else if overloaded.length > 1 {
			if @type.isMissingReturn() {
				var mut type = null

				for var overload in overloaded when !overload.isMissingReturn() {
					if ?type {
						if type.isSubsetOf(overload.getReturnType(), MatchingMode.Default) {
							pass
						}
						else if overload.getReturnType().isSubsetOf(type, MatchingMode.Default) {
							type = overload.getReturnType()
						}
						else {
							SyntaxException.throwInvalidMethodReturn(@parent.name(), @name, this)
						}
					}
					else {
						type = overload.getReturnType()
					}
				}

				if ?type {
					@type.setReturnType(type)
				}
			}
		}

		@analysed = true
	} # }}}
	translate() { # {{{
		@scope.line(@line())

		var index = @forked || (@overriding && @type.isForked()) ? @type.getForkedIndex() : @type.index()

		if @instance {
			@internalName = `__ks_func_\(@name)_\(index)`
		}
		else {
			@internalName = `__ks_sttc_\(@name)_\(index)`
		}

		for var parameter in @parameters {
			parameter.translate()
		}

		for var {value} in @indigentValues {
			value.prepare()
			value.translate()
		}

		if !@abstract {
			if @autoTyping {
				@block.prepare(AnyType.NullableUnexplicit)

				@type.setReturnType(@block.type())
			}
			else {
				@block.prepare(@type.getReturnType())
			}

			@block.translate()

			@awaiting = @block.isAwait()
			@exit = @block.isExit()
		}
	} # }}}
	addAtThisParameter(statement: AliasStatement) { # {{{
		if !ClassDeclaration.isAssigningAlias(@block.getDataStatements(), statement.name(), false, false) {
			@aliases.push(statement)
		}
	} # }}}
	addIndigentValue(value: Expression, parameters) { # {{{
		var class = @parent.type().type()
		var name = `__ks_default_\(class.level())_\(class.incDefaultSequence())`

		@indigentValues.push({
			name
			value
			parameters
		})

		return name
	} # }}}
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	flagForked(class: ClassType, @forks) { # {{{
		@type.flagForked(false)

		class.updateInstanceMethodIndex(@name, @type)

		@forked = true
	} # }}}
	getFunctionNode() => this
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	isAbstract() => @abstract
	isAssertingOverride() => @options.rules.assertOverride
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isForked() => @forked
	isHiddenOverride() => @hiddenOverride
	isInstance() => @instance
	isInstanceMethod() => @instance
	isOverridableFunction() => true
	isRoutable() => true
	length() => @parameters.length
	name() => @name
	parameters() => @parameters
	toForkFragments(fragments) { # {{{
		var ctrl = fragments.newControl()

		ctrl.code(`__ks_func_\(@name)_\(@type.index())(`)

		var mut parameters = ''

		var names = {}

		for var parameter, index in @type.parameters() {
			if index > 0 {
				ctrl.code($comma)

				parameters += ', '
			}

			ctrl.code(parameter.getExternalName())

			parameters += parameter.getExternalName()

			names[parameter.getExternalName()] = true
		}

		ctrl.code(')').step()

		for var fork in @forks {
			var ctrl2 = ctrl.newControl()

			ctrl2.code(`if(`)

			var mut index = 0

			for var parameter in fork.parameters() when parameter.min() > 0 || names[parameter.getExternalName()] {
				ctrl2.code(' && ') unless index == 0

				var literal = Literal.new(false, this, @scope(), parameter.getExternalName())

				parameter.type().toPositiveTestFragments(Junction.AND, ctrl2, literal)

				index += 1
			}

			ctrl2.code(`)`).step()

			ctrl2.line(`return this.__ks_func_\(@name)_\(fork.index())(\(parameters))`)

			ctrl2.done()
		}

		ctrl.line(`return this.__ks_func_\(@name)_\(@type.getForkedIndex())(\(parameters))`)

		ctrl.done()
	} # }}}
	toIndigentFragments(fragments) { # {{{
		for var {name, value, parameters} in @indigentValues {
			var ctrl = fragments.newControl()

			ctrl.code(`\(name)(\(parameters.join(', ')))`).step()

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var ctrl = fragments.newControl()

		if @parent._es5 {
			ctrl.code(`\(@internalName): function(`)
		}
		else {
			ctrl.code('static ') if !@instance

			ctrl.code(`\(@internalName)(`)
		}

		Parameter.toFragments(this, ctrl, ParameterMode.Default, (node) => node.code(')').step())

		for var node in @topNodes {
			node.toAuthorityFragments(ctrl)
		}

		if @awaiting {
			throw NotImplementedException.new(this)
		}
		else {
			ctrl.compile(@block)

			if !@exit {
				if @type.isAsync() {
					ctrl.line('__ks_cb()')
				}
				else if @returnNull {
					ctrl.line('return null')
				}
			}
		}

		ctrl.done() unless @parent._es5

		@toIndigentFragments(fragments)
	} # }}}
	type() { # {{{
		if @analysed {
			return @type
		}
		else {
			@prepare()

			return @type
		}
	} # }}}
	protected {
		getOveriddenMethod({ matchAll }: Method.Matcher, returnReference: Boolean) { # {{{
			var mut mode = MatchingMode.FunctionSignature + MatchingMode.IgnoreReturn + MatchingMode.MissingError

			if @override {
				mode += MatchingMode.NullToNonNullParameter
			}
			else {
				mode -= MatchingMode.MissingParameterType - MatchingMode.MissingParameterArity
			}

			var mut method = null
			var mut exact = false

			if var methods #= matchAll(@name, @type, MatchingMode.ExactParameter) {
				if methods.length == 1 {
					method = methods[0]
					exact = true
				}
				else {
					return null
				}
			}
			else if @override {
				if var methods #= matchAll(@name, @type, mode - MatchingMode.SubclassParameter) {
					if methods.length == 1 {
						method = methods[0]
					}
					else {
						return null
					}
				}
			}

			// TODO!
			// if !?method ;; var methods #= matchAll(@name, @type, mode) {
			if !?method {
				if var methods #= matchAll(@name, @type, mode) {
					if methods.length == 1 {
						method = methods[0]
					}
					else {
						return null
					}
				}
			}

			if ?method {
				var type = if @override {
					if method is ClassMethodType {
						set method.clone()
					}
					else {
						set ClassMethodType.fromFunction(method)
					}
				}
				else {
					set @type
				}

				if @type.isLessAccessibleThan(method) {
					SyntaxException.throwLessAccessibleMethod(@parent.type(), @name, @parameters, this)
				}

				if @override {
					var parameters = type.parameters()

					for var parameter, index in @parameters {
						var currentType = parameter.type()
						var masterType = parameters[index]

						if currentType.isMissingType() {
							parameter.type(masterType)
						}
						else {
							if masterType.hasDefaultValue() && !currentType.hasDefaultValue() {
								parameter.setDefaultValue(masterType.getDefaultValue())
							}

							parameters[index] = currentType
						}
					}
				}

				if returnReference {
					// don't check since the type isn't set, yet
				}
				else if @override {
					if @type.isMissingReturn() {
						type.setReturnType(method.getReturnType())
					}
					else {
						var oldType = method.getReturnType()
						var newType = @type.getReturnType()

						if !(newType.isSubsetOf(oldType, MatchingMode.Default + MatchingMode.Missing) || newType.isInstanceOf(oldType)) {
							if @isAssertingOverride() {
								SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
							}
							else {
								@override = false
							}

							return null
						}
						else if newType.isValueOf() {
							type.setReturnType(newType)
						}
						else {
							type.setReturnType(oldType)
						}
					}
				}
				else {
					if @type.isMissingReturn() {
						type.setReturnType(method.getReturnType())
					}
				}

				if @type.isMissingError() {
					type.addError(...method.listErrors()!?)
				}
				else {
					var newTypes = @type.listErrors()

					for var oldType in method.listErrors() {
						var mut matched = false

						for var newType in newTypes until matched {
							if newType.isSubsetOf(oldType, MatchingMode.Default) || newType.isInstanceOf(oldType) {
								matched = true
							}
						}

						if !matched {
							if @override {
								if @isAssertingOverride() {
									SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
								}
								else {
									@override = false
								}
							}

							return null
						}
					}
				}

				if exact && method.isMethod() && method.isForked() {
					type.setForkedIndex(method.getForkedIndex())
				}

				if !@override {
					if exact || type.isSubsetOf(method, MatchingMode.ExactParameter + MatchingMode.IgnoreName + MatchingMode.IgnoreReturn) {
						type.index(method.index())

						return { method, type, exact: true }
					}
					else {
						return { method, type, exact: false }
					}
				}
				else {
					return { method, type, exact: true }
				}
			}
			else if @override {
				if @isAssertingOverride() {
					SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
				}
				else {
					@override = false
				}
			}

			return null
		} # }}}
		listOverloadedMethods({ match, matchAll }: Method.Matcher) { # {{{
			if var methods ?= match(@name) {
				for var method in methods {
					if method.isSubsetOf(@type, MatchingMode.ExactParameter) {
						return []
					}
				}
			}

			return matchAll(
				@name
				@type
				MatchingMode.FunctionSignature + MatchingMode.SubsetParameter + MatchingMode.MissingParameter - MatchingMode.AdditionalParameter + MatchingMode.IgnoreReturn + MatchingMode.MissingError
			)
		} # }}}
		resolveOver(): { overridden: FunctionType?, overloaded: FunctionType[] } { # {{{
			var mut overridden = null
			var mut overloaded = []

			if @assist {
				var mode: MatchingMode = .IgnoreAnonymous + .MissingParameterType + .MissingParameterArity + .MissingParameterDefault + .MissingReturn + .MissingError
				var assisteds = []

				for var method in @listOverloadedMethods(Method.instance(@parent.class())) {
					if !@type.isMissingReturn() && !@type.getReturnType().isSubsetOf(method.getReturnType(), MatchingMode.Default) {
						pass
					}
					else if @type.isSubsetOf(method, mode) {
						assisteds.push(method)
					}
				}

				if assisteds.length == 1 {
					@type.assist(assisteds[0], @parameters)

					@parent.addForkedMethod(@name, assisteds[0], @type, null)
				}
				else if #assisteds {
					NotImplementedException.throw(this)
				}
				else {
					SyntaxException.throwNoAssistableMethod(@parent.type(), @name, @parameters, this)
				}
			}
			else if @parent.isExtending() || @parent.isImplementing() {
				var matcher = @instance ? Method.instance(@parent) : Method.static(@parent)

				if var data ?= @getOveriddenMethod(matcher, @type.isUnknownReturnType()) {
					@overriding = true
					{ method % overridden, type % @type, exact % @exact } = data
				}

				overloaded = @listOverloadedMethods(matcher)

				var overload = []

				if @overriding {
					if @exact {
						overloaded:Array.remove(overridden)

						overload.push(overridden.index())
					}
					else if overloaded:Array.contains(overridden) {
						@parent.addForkedMethod(@name, overridden, @type, true)

						overloaded:Array.remove(overridden)

						overload.push(overridden.index())
					}
					else {
						@parent.addForkedMethod(@name, overridden, @type, true)
					}
				}
				else if @override {
					SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
				}

				for var method in overloaded {
					var mut hidden = null

					if !@type.isMissingReturn() && !@type.getReturnType().isSubsetOf(method.getReturnType(), MatchingMode.Default) {
						SyntaxException.throwInvalidMethodReturn(@parent.name(), @name, this)
					}
					else if @type.isSubsetOf(method, MatchingMode.ExactParameter + MatchingMode.AdditionalParameter + MatchingMode.IgnoreAnonymous + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError) {
						hidden = true

						overload.push(method.index())
					}
					else if method.isSubsetOf(@type, MatchingMode.AdditionalParameter + MatchingMode.MissingParameterArity + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError) {
						hidden = true

						overload.push(method.index())
					}
					else if @type.isSubsetOf(method, MatchingMode.AdditionalParameter + MatchingMode.MissingParameterArity + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError) {
						hidden = false

						overload.push(method.index())
					}

					@parent.addForkedMethod(@name, method, @type, hidden)
				}

				if #overload {
					@type.overload(overload)
				}

				if @parent.isExtending() {
					var superclass = @parent.extends().type()

					if var sealedclass ?= superclass.getHybridMethod(@name, @parent.extends()) {
						@parent.addSharedMethod(@name, sealedclass)
					}
				}
			}
			else if @override {
				SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
			}

			if @exact {
				@hiddenOverride = !(overridden is not ClassMethodType || overridden.isAbstract())
			}
			else {
				var mode = MatchingMode.ExactParameter + MatchingMode.IgnoreName + MatchingMode.Superclass

				if @instance {
					if @parent.class().hasMatchingInstanceMethod(@name, @type, mode) {
						SyntaxException.throwIdenticalMethod(@name, this)
					}
				}
				else {
					if @parent.class().hasMatchingStaticMethod(@name, @type, mode) {
						SyntaxException.throwIdenticalMethod(@name, this)
					}
				}
			}

			return { overridden, overloaded }
		} # }}}
	}
}
