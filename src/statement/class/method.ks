class ClassMethodDeclaration extends Statement {
	private late {
		_block: FunctionBlock
		_internalName: String
		_type: Type
	}
	private {
		_abstract: Boolean					= false
		_aliases: Array						= []
		_analysed: Boolean					= false
		_autoTyping: Boolean				= false
		_awaiting: Boolean					= false
		_exact: Boolean						= false
		_exit: Boolean						= false
		_forked: Boolean					= false
		_forks: Array<ClassMethodType>?		= null
		_hiddenOverride: Boolean			= false
		_indigentValues: Array				= []
		_instance: Boolean					= true
		_name: String
		_override: Boolean					= false
		_overriding: Boolean				= false
		_parameters: Array<Parameter>		= []
		_returnNull: Boolean				= false
		_topNodes: Array					= []
	}
	static toClassRouterFragments(node, fragments, variable, methods, overflow, name, header, footer) { # {{{
		var classname = variable.name()

		var assessment = Router.assess(methods, name, node)

		header(node, fragments)

		if variable.type().isExtending() {
			var extends = variable.type().extends()
			var parent = extends.name()

			Router.toFragments(
				(function, line) => {
					line.code(`\(classname).__ks_sttc_\(name)_\(function.index())(`)

					return false
				}
				`arguments`
				assessment
				fragments.block()
				extends.type().hasInstanceMethod(name) ? Router.FooterType::NO_THROW : Router.FooterType::MIGHT_THROW
				(fragments, _) => {
					if extends.type().hasInstanceMethod(name) {
						fragments.line(`return \(parent).\(name).apply(null, arguments)`)
					}
					else {
						fragments
							.newControl()
							.code(`if(\(parent).\(name))`)
							.step()
							.line(`return \(parent).\(name).apply(null, arguments)`)
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
					line.code(`\(classname).__ks_sttc_\(name)_\(function.index())(`)

					return false
				}
				`arguments`
				assessment
				fragments.block()
				node
			)
		}

		footer(fragments)
	} # }}}
	static toInstanceHeadFragments(name, fragments) { # {{{
		var ctrl = fragments.newControl()

		ctrl.code(`\(name)()`).step()

		ctrl.line(`return this.__ks_func_\(name)_rt.call(null, this, this, arguments)`)

		ctrl.done()
	} # }}}
	static toInstanceRouterFragments(node, fragments, variable, methods, overflow, name, header, footer) { # {{{
		var classname = variable.name()

		var assessment = Router.assess(methods, name, node)

		header(node, fragments)

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
				extends.type().hasInstanceMethod(name) ? Router.FooterType::NO_THROW : Router.FooterType::MIGHT_THROW
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
		super(data, parent, parent.newInstanceMethodScope())

		@name = data.name.name

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@abstract = true
			}
			else if modifier.kind == ModifierKind::Override {
				@override = true
			}
			else if modifier.kind == ModifierKind::Static {
				@instance = false
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
			SyntaxException.throwReservedClassMethod(@name, parent)
		}
		else {
			if parent._classMethods[@name] is Array {
				parent._classMethods[@name].push(this)
			}
			else {
				parent._classMethods[@name] = [this]
			}
		}
	} # }}}
	analyse() { # {{{
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		if @data.body? {
			@returnNull = @data.body.kind == NodeKind::IfStatement || @data.body.kind == NodeKind::UnlessStatement
		}

		@block = new MethodBlock($ast.block($ast.body(@data)), this, @scope)
	} # }}}
	prepare() { # {{{
		return if @analysed

		@parent.updateMethodScope(this)

		for var parameter in @parameters {
			parameter.prepare()
		}

		@type = new ClassMethodType([parameter.type() for var parameter in @parameters], @data, this)

		var returnReference = @data.type?.kind == NodeKind::ReturnTypeReference

		var mut overridden
		var mut overloaded = []

		if @parent.isExtending() {
			var superclass = @parent.extends().type()

			if var data = @getOveriddenMethod(superclass, returnReference) {

				@overriding = true
				{ method: overridden, type: @type, exact: @exact } = data
			}

			overloaded = @listOverloadedMethods(superclass)

			if @overriding {
				if @exact {
					overloaded:Array.remove(overridden)
				}
				else if overloaded:Array.contains(overridden) {
					@parent.addForkedMethod(@name, overridden, @type, true)

					overloaded:Array.remove(overridden)
				}
				else {
					@parent.addForkedMethod(@name, overridden, @type, true)
				}
			}

			for var method in overloaded {
				var mut hidden = null

				if @type.isSubsetOf(method, MatchingMode::ExactParameter + MatchingMode::AdditionalParameter + MatchingMode::IgnoreReturn + MatchingMode::IgnoreError) {
					hidden = true
				}
				else if @type.isSubsetOf(method, MatchingMode::AdditionalParameter + MatchingMode::MissingParameterArity + MatchingMode::IgnoreReturn + MatchingMode::IgnoreError) {
					hidden = false
				}

				@parent.addForkedMethod(@name, method, @type, hidden)
			}

			if var sealedclass = superclass.getHybridMethod(@name, @parent.extends()) {
				@parent.addSharedMethod(@name, sealedclass)
			}
		}
		else if @override {
			SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
		}

		if @exact {
			@hiddenOverride = !overridden.isAbstract()
		}
		else {
			var mode = MatchingMode::ExactParameter + MatchingMode::IgnoreName + MatchingMode::Superclass

			if @instance {
				if @parent.class().hasMatchingInstanceMethod(@name, @type, mode) {
					SyntaxException.throwIdenticalMethod(@name, this)
				}
			}
			else {
				if @parent.class().hasMatchingClassMethod(@name, @type, mode) {
					SyntaxException.throwIdenticalMethod(@name, this)
				}
			}
		}

		for var alias in @aliases {
			@type.addInitializingInstanceVariable(alias.getVariableName())
		}

		@block.analyse(@aliases)

		@block.analyse()

		if returnReference {
			switch @data.type.value.kind {
				NodeKind::Identifier => {
					if @data.type.value.name == 'auto' {
						@type.setReturnType(@block.getUnpreparedType())

						@autoTyping = true
					}
					else if @data.type.value.name == 'this' {
						@type.setReturnType(@parent.type().reference(@scope))

						if @instance {
							var return = $compile.expression(@data.type.value, this)

							return.analyse()

							@block.addReturn(return)
						}
					}
					else {
						throw new NotSupportedException()
					}
				}
				NodeKind::ThisExpression => {
					var return = $compile.expression(@data.type.value, this)

					return.analyse()

					@type.setReturnType(return.getUnpreparedType())

					@block.addReturn(return)
				}
			}
		}

		if @overriding {
			var oldType = overridden.getReturnType()
			var newType = @type.getReturnType()

			unless newType.isSubsetOf(oldType, MatchingMode::Exact + MatchingMode::Missing) || newType.isInstanceOf(oldType) {
				if @override {
					if this.isAssertingOverride() {
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
				@type.addError(...overload.listErrors())
			}
		}
		else if overloaded.length > 1 {
			if @type.isMissingReturn() {
				var mut type = null

				for var overload in overloaded when !overload.isMissingReturn() {
					if ?type {
						if type.isSubsetOf(overload.getReturnType()) {
							type = overload.getReturnType()
						}
						else if !overload.getReturnType().isSubsetOf(type) {
							throw new NotImplementedException()
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

		if @autoTyping {
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			if !@abstract {
				@block.type(@type.getReturnType())
			}

			@block.prepare()
		}

		@block.translate()

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} # }}}
	addAtThisParameter(statement: AliasStatement) { # {{{
		if !ClassDeclaration.isAssigningAlias(@block.statements(), statement.name(), false, false) {
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
	isAlias() => false
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

			ctrl.code(parameter.name())

			parameters += parameter.name()

			names[parameter.name()] = true
		}

		ctrl.code(')').step()

		for var fork in @forks {
			var ctrl2 = ctrl.newControl()

			ctrl2.code(`if(`)

			var mut index = 0

			for var parameter in fork.parameters() when parameter.min() > 0 || names[parameter.name()] {
				ctrl2.code(' && ') unless index == 0

				var literal = new Literal(false, this, this.scope(), parameter.name())

				parameter.type().toPositiveTestFragments(ctrl2, literal, Junction::AND)

				++index
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

			if @parent._es5 {
				ctrl.code(`\(name): function(\(parameters.join(', ')))`).step()
			}
			else {
				ctrl.code(`\(name)(\(parameters.join(', ')))`).step()
			}

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done() unless @parent._es5
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

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
			return node.code(')').step()
		})

		for var node in @topNodes {
			node.toAuthorityFragments(ctrl)
		}

		if @awaiting {
			throw new NotImplementedException(this)
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

		this.toIndigentFragments(fragments)
	} # }}}
	type() { # {{{
		if @analysed {
			return @type
		}
		else {
			this.prepare()

			return @type
		}
	} # }}}
	private {
		getOveriddenMethod(superclass: ClassType, returnReference: Boolean) { # {{{
			var mut mode = MatchingMode::FunctionSignature + MatchingMode::IgnoreReturn + MatchingMode::MissingError

			if !@override {
				mode -= MatchingMode::MissingParameterType - MatchingMode::MissingParameterArity
			}

			var methods = @instance ? superclass.listInstantiableMethods(@name, @type, mode) : superclass.listClassMethods(@name, @type, mode)

			var mut method = null
			var mut exact = false
			if methods.length == 1 {
				method = methods[0]
			}
			else if methods.length > 0 {
				for var m in methods {
					if m.isSubsetOf(@type, MatchingMode::ExactParameter) {
						method = m
						exact = true

						break
					}
				}

				if !?method {
					return null
				}
			}

			if method? {
				var type = @override ? method.clone() : @type

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
					if !@type.isMissingReturn() {
						var oldType = method.getReturnType()
						var newType = @type.getReturnType()

						if !(newType.isSubsetOf(oldType, MatchingMode::Default + MatchingMode::Missing) || newType.isInstanceOf(oldType)) {
							if this.isAssertingOverride() {
								SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
							}
							else {
								@override = false
							}

							return null
						}
						else {
							type.setReturnType(method.getReturnType())
						}
					}
				}
				else {
					if @type.isMissingReturn() {
						type.setReturnType(method.getReturnType())
					}
				}

				if @type.isMissingError() {
					type.addError(...method.listErrors())
				}
				else {
					var newTypes = @type.listErrors()

					for var oldType in method.listErrors() {
						var mut matched = false

						for var newType in newTypes until matched {
							if newType.isSubsetOf(oldType, MatchingMode::Default) || newType.isInstanceOf(oldType) {
								matched = true
							}
						}

						if !matched {
							if @override {
								if this.isAssertingOverride() {
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

				if exact && method.isForked() {
					type.setForkedIndex(method.getForkedIndex())
				}

				if !@override {
					if exact || type.isSubsetOf(method, MatchingMode::ExactParameter + MatchingMode::IgnoreName + MatchingMode::IgnoreReturn) {
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
				if this.isAssertingOverride() {
					SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
				}
				else {
					@override = false
				}
			}

			return null
		} # }}}
		listOverloadedMethods(superclass: ClassType) { # {{{
			if @instance {
				if var methods = superclass.listInstanceMethods(@name) {
					for var method in methods {
						if method.isSubsetOf(@type, MatchingMode::ExactParameter) {
							return []
						}
					}
				}

				return superclass.listInstantiableMethods(
					@name
					@type
					MatchingMode::FunctionSignature + MatchingMode::SubsetParameter + MatchingMode::MissingParameter - MatchingMode::AdditionalParameter + MatchingMode::MissingReturn + MatchingMode::MissingError
				)
			}
			else {
				if var methods = superclass.listClassMethods(@name) {
					for var method in methods {
						if method.isSubsetOf(@type, MatchingMode::ExactParameter) {
							return []
						}
					}
				}

				return superclass.listClassMethods(
					@name
					@type
					MatchingMode::FunctionSignature + MatchingMode::SubsetParameter + MatchingMode::MissingParameter - MatchingMode::AdditionalParameter + MatchingMode::MissingReturn + MatchingMode::MissingError
				)
			}
		} # }}}
	}
}
