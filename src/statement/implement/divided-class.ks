class ImplementDividedClassFieldDeclaration extends Statement {
	private late {
		@type: ClassVariableType
	}
	private {
		@class: ClassType
		@classRef: ReferenceType
		@defaultValue: Boolean				= false
		@final: Boolean					= false
		@init: Number						= -1
		@instance: Boolean					= true
		@internalName: String
		@lateInit: Boolean					= false
		@name: String
		@value								= null
		@variable: NamedType<ClassType>
	}
	constructor(data, parent, @variable) { # {{{
		super(data, parent)

		@class = @variable.type()
		@classRef = @scope.reference(@variable)

		@name = @internalName = data.name.name

		var mut private = false
		var mut alias = false

		for var modifier in data.modifiers {
			match modifier.kind {
				ModifierKind.Final {
					@final = true
				}
				ModifierKind.LateInit {
					@lateInit = true
				}
				ModifierKind.Private {
					private = true
				}
				ModifierKind.Static {
					@instance = false
				}
				ModifierKind.ThisAlias {
					alias = true
				}
			}
		}

		if private {
			if alias {
				@internalName = `_\(@name)`
			}
			else if @name[0] == '_' {
				@name = @name.substr(1)
			}
		}

		if @class.features() !~ ClassFeature.Field {
			TypeException.throwImplInvalidField(@variable.name(), this)
		}
	} # }}}
	analyse() { # {{{
		if ?@data.value {
			@defaultValue = true

			@value = $compile.expression(@data.value, this)
			@value.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = ClassVariableType.fromAST(@data!?, this)

		@type.flagAltering()

		if @class.isSealed() {
			@type.flagSealed()
		}

		if @instance {
			@class.addInstanceVariable(@internalName, @type)
		}
		else {
			@class.addStaticVariable(@internalName, @type)
		}

		if @defaultValue {
			if @instance {
				@init = @class.incInitializationSequence()
			}
		}
		else if !@lateInit && !@type.isNullable() {
			SyntaxException.throwNotInitializedField(@name, this)
		}
	} # }}}
	translate() { # {{{
		if @defaultValue {
			@value.prepare()

			if !?@data.type && @final && !@lateInit {
				@type.type(@value.type())
			}

			@value.translate()
		}
		else if @type.isRequiringInitialization() {
			var constructors = @class.listConstructors()
			var variables = [@name]

			for var constructor in constructors {
				constructor.checkVariableInitialization(variables, this)
			}
		}
	} # }}}
	getSharedName() => @defaultValue && @instance ? '__ks_init' : null
	isMethod() => false
	isInstance() => @instance
	toFragments(fragments, mode) { # {{{
		return unless @defaultValue

		if @class.isSealed() {
			if @instance {
				var dyn line, block, ctrl

				// get()
				line = fragments.newLine()

				line.code(`\(@variable.getSealedName()).__ks_get_\(@name) = function(that)`)

				block = line.newBlock()

				ctrl = block.newControl()
				ctrl.code(`if(!that[\($runtime.initFlag(this))])`).step()
				ctrl.line(`\(@variable.getSealedName()).__ks_init(that)`)
				ctrl.done()

				block.line(`return that.\(@internalName)`)

				block.done()
				line.done()

				// set()
				line = fragments.newLine()

				line.code(`\(@variable.getSealedName()).__ks_set_\(@name) = function(that, value)`)

				block = line.newBlock()

				ctrl = block.newControl()
				ctrl.code(`if(!that[\($runtime.initFlag(this))])`).step()
				ctrl.line(`\(@variable.getSealedName()).__ks_init(that)`)
				ctrl.done()

				block.line(`that.\(@internalName) = value`)

				block.done()
				line.done()
			}
			else {
				fragments.newLine().code(`\(@variable.getSealedName()).\(@internalName) = `).compile(@value).done()
			}
		}
		else {
			if !@instance {
				fragments.newLine().code(`\(@variable.name()).\(@internalName) = `).compile(@value).done()
			}
		}
	} # }}}
	toDefaultFragments(fragments) { # {{{
		return unless @instance && @defaultValue

		if @class.isSealed() {
			fragments.newLine().code(`that.\(@internalName) = `).compile(@value).done()
		}
		else {
			fragments.newLine().code(`this.\(@internalName) = `).compile(@value).done()
		}
	} # }}}
	toSharedFragments(fragments, properties) { # {{{
		if properties.some((property, _, _) => property.isInstance()) {
			if @class.isSealed() {
				if @init > 0 {
					fragments.line(`\(@variable.getSealedName()).__ks_init_\(@init) = \(@variable.getSealedName()).__ks_init`)
				}

				var line = fragments.newLine()

				line.code(`\(@variable.getSealedName()).__ks_init = function(that)`)

				var block = line.newBlock()

				if @init > 0 {
					block.line(`\(@variable.getSealedName()).__ks_init_\(@init)(that)`)
				}

				for var property in properties {
					property.toDefaultFragments(block)
				}

				block.line(`that[\($runtime.initFlag(this))] = true`)

				block.done()
				line.done()
			}
			else {
				fragments.line(`\(@variable.name()).prototype.__ks_init_\(@init) = \(@variable.name()).prototype.__ks_init`)

				var line = fragments.newLine()

				line.code(`\(@variable.name()).prototype.__ks_init = function()`)

				var block = line.newBlock()

				block.line(`this.__ks_init_\(@init)()`)

				for var property in properties {
					property.toDefaultFragments(block)
				}

				block.done()
				line.done()
			}
		}
	} # }}}
	type() => @type
}

class ImplementDividedClassMethodDeclaration extends Statement {
	private late {
		@block: Block
		@internalName: String
		@name: String
		@parameters: Array<Parameter>
		@this: Variable
		@type: ClassMethodType
	}
	private {
		@aliases: Array						= []
		@autoTyping: Boolean				= false
		@class: ClassType
		@classRef: ReferenceType
		@exists: Boolean					= false
		@hiddenOverride: Boolean			= false
		@indigentValues: Array				= []
		@instance: Boolean					= true
		@override: Boolean					= false
		@overwrite: Boolean					= false
		@variable: NamedType<ClassType>
		@topNodes: Array					= []
	}
	constructor(data, parent, @variable) { # {{{
		super(data, parent, parent.scope(), ScopeType.Function)

		@class = @variable.type()
		@classRef = @scope.reference(@variable)

		@name = @data.name.name

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Override {
				@override = true
			}
			else if modifier.kind == ModifierKind.Overwrite {
				@overwrite = true
			}
			else if modifier.kind == ModifierKind.Static {
				@instance = false
			}
		}

		if @instance {
			if @class.features() !~ ClassFeature.InstanceMethod {
				TypeException.throwImplInvalidInstanceMethod(@variable.name(), this)
			}
		}
		else {
			if @class.features() !~ ClassFeature.StaticMethod {
				TypeException.throwImplInvalidStaticMethod(@variable.name(), this)
			}
		}
	} # }}}
	analyse() { # {{{
		@scope.line(@data.start.line)

		@this = @scope.define('this', true, @classRef, true, this)

		@parameters = []
		for var data in @data.parameters {
			var parameter = Parameter.new(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@block = $compile.function($ast.body(@data), this)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@scope.line(@data.start.line)

		for var parameter in @parameters {
			parameter.prepare()
		}

		if @instance {
			if @class.isSealed() {
				@exists = @class.hasSealedInstanceMethod(@name)
			}
			else {
				@exists = @class.hasInstanceMethod(@name)
			}
		}

		@type = ClassMethodType.new([parameter.type() for var parameter in @parameters], @data, this)

		@type.flagAltering()

		if @class.isSealed() {
			@type.flagSealed()
		}

		var unknownReturnType = @type.isUnknownReturnType()

		var mut overridden = null

		if @instance {
			if @override {
				if var data ?= @getOveriddenMethod(@class, unknownReturnType) {
					{ method % overridden, type % @type } = data

					unless @class.isAbstract() {
						@hiddenOverride = true
					}

					var overloaded = @listOverloadedMethods(@class)

					overloaded:!(Array).remove(overridden)

					for var method in overloaded {
						@parent.addForkedMethod(@name, method, @type)
					}
				}
				else if @isAssertingOverride() {
					SyntaxException.throwNoOverridableMethod(@variable, @name, @parameters, this)
				}
				else {
					@override = false
					@internalName = `__ks_func_\(@name)_\(@class.addInstanceMethod(@name, @type))`
				}
			}
			else if @overwrite {
				unless @class.isSealed() {
					SyntaxException.throwNotSealedOverwrite(this)
				}

				var methods = @class.listMatchingInstanceMethods(@name, @type, MatchingMode.SimilarParameter + MatchingMode.ShiftableParameters + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError)
				if methods.length == 0 {
					SyntaxException.throwNoSuitableOverwrite(@classRef, @name, @type, this)
				}

				@class.overwriteInstanceMethod(@name, @type, methods)

				@internalName = `__ks_func_\(@name)_\(@type.index())`

				var type = Type.union(@scope, ...methods!?)
				var variable = @scope.define('precursor', true, type, this)

				variable.replaceCall = (data, arguments, node) => CallOverwrittenMethodSubstitude.new(data, arguments, @variable, @name, methods, true, this)
			}
			else {
				if @class.hasMatchingInstanceMethod(@name, @type, MatchingMode.ExactParameter + MatchingMode.IgnoreName + MatchingMode.Superclass) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@internalName = `__ks_func_\(@name)_\(@class.addInstanceMethod(@name, @type))`
				}
			}
		}
		else {
			if @override {
				NotImplementedException.throw(this)
			}
			else if @overwrite {
				unless @class.isSealed() {
					NotImplementedException.throw(this)
				}

				var methods = @class.listMatchingStaticMethods(@name, @type, MatchingMode.ShiftableParameters)
				if methods.length == 0 {
					SyntaxException.throwNoSuitableOverwrite(@classRef, @name, @type, this)
				}

				@class.overwriteClassMethod(@name, @type, methods)

				@internalName = `__ks_sttc_\(@name)_\(@type.index())`

				var type = Type.union(@scope, ...methods!?)
				var variable = @scope.define('precursor', true, type, this)

				variable.replaceCall = (data, arguments, node) => CallOverwrittenMethodSubstitude.new(data, arguments, @variable, @name, methods, false, this)
			}
			else {
				if @class.hasMatchingStaticMethod(@name, @type, MatchingMode.ExactParameter) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@internalName = `__ks_sttc_\(@name)_\(@class.addStaticMethod(@name, @type))`
				}
			}
		}

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
		else if @type.isAutoTyping() && !@override {
			@type.setReturnType(@block.getUnpreparedType())

			@autoTyping = true
		}

		if ?overridden {
			var oldType = overridden.getReturnType()
			var newType = @type.getReturnType()

			unless newType.isSubsetOf(oldType, MatchingMode.Exact + MatchingMode.Missing) || newType.isInstanceOf(oldType, null, null) {
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

			@internalName = `__ks_func_\(@name)_\(@type.index())`
		}
	} # }}}
	translate() { # {{{
		for var parameter in @parameters {
			parameter.translate()
		}

		for var indigent in @indigentValues {
			indigent.value.prepare()
			indigent.value.translate()
		}

		if @autoTyping {
			@block.prepare(AnyType.NullableUnexplicit)

			@type.setReturnType(@block.type())
		}
		else {
			@block.prepare(@type.getReturnType())
		}

		@block.translate()
	} # }}}
	addAtThisParameter(statement: AliasStatement) { # {{{
		if !ClassDeclaration.isAssigningAlias(@block.getDataStatements(), statement.name(), false, false) {
			@aliases.push(statement)
		}
	} # }}}
	addIndigentValue(value: Expression, parameters) { # {{{
		var name = `__ks_default_\(@class.level())_\(@class.incDefaultSequence())`

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
	isAssertingOverride() => @options.rules.assertOverride
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	class() => @variable
	getMatchingMode(): MatchingMode { # {{{
		if @override {
			return MatchingMode.ShiftableParameters
		}
		else if @overwrite {
			return MatchingMode.SimilarParameter + MatchingMode.ShiftableParameters
		}
		else {
			return MatchingMode.ExactParameter
		}
	} # }}}
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	getSharedName() => @override ? null : @instance ? `_im_\(@name)` : `_sm_\(@name)`
	isConstructor() => false
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstance() => @instance
	isInstanceMethod() => @instance
	isMethod() => true
	isOverridableFunction() => true
	name() => @name
	parameters() => @parameters
	toIndigentFragments(fragments) { # {{{
		for var {name, value, parameters} in @indigentValues {
			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			if @class.isSealed() {
				ctrl.code(`\(@variable.getSealedName()).\(name) = function(\(parameters.join(', ')))`).step()
			}
			else {
				ctrl.code(`\(@variable.name()).prototype.\(name) = function(\(parameters.join(', ')))`).step()
			}

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done()
			line.done()
		}
	} # }}}
	toInstanceFragments(fragments) { # {{{
		var name = @variable.name()
		var labelable = @class.isLabelableInstanceMethod(@name)
		var assessment = Router.assess(@class.listInstanceMethods(@name), @name, this)

		var line = fragments.newLine()

		if labelable {
			line.code(`\(name).prototype.__ks_func_\(@name)_rt = function(that, proto, kws, args)`)
		}
		else {
			line.code(`\(name).prototype.__ks_func_\(@name)_rt = function(that, proto, args)`)
		}

		var block = line.newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`proto.__ks_func_\(@name)_\(function.index()).call(that`)

				return true
			}
			null
			assessment
			block
			this
		)

		block.done()
		line.done()

		if !@exists {
			var line = fragments.newLine()

			if labelable {
				line.code(`\(name).prototype.\(@name) = function(kws, ...args)`)
			}
			else {
				line.code(`\(name).prototype.\(@name) = function()`)
			}

			var block = line.newBlock()

			if labelable {
				block.line(`return this.__ks_func_\(@name)_rt.call(null, this, this, kws, args)`)
			}
			else {
				block.line(`return this.__ks_func_\(@name)_rt.call(null, this, this, arguments)`)
			}

			block.done()

			line.done()
		}
	} # }}}
	toStaticFragments(fragments) { # {{{
		var name = @variable.name()
		var labelable = @class.isLabelableStaticMethod(@name)
		var assessment = Router.assess(@class.listStaticMethods(@name), @name, this)

		var line = fragments.newLine()

		if labelable {
			line.code(`\(name).\(@name) = function(kws, ...args)`)
		}
		else {
			line.code(`\(name).\(@name) = function()`)
		}

		var block = line.newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`\(name).__ks_func_\(@name)_\(function.index())(`)

				return false
			}
			labelable ? 'args' : 'arguments'
			assessment
			block
			this
		)

		block.done()
		line.done()
	} # }}}
	toSealedInstanceFragments(fragments) { # {{{
		var name = @variable.name()
		var sealedName = @variable.getSealedName()
		var labelable = @class.isLabelableInstanceMethod(@name)
		var assessment = Router.assess(@class.listInstanceMethods(@name), @name, this)
		var exhaustive = @class.isExhaustiveInstanceMethod(@name, this)

		if !@exists {
			var line = fragments.newLine()

			if labelable {
				line.code(`\(sealedName)._im_\(@name) = function(that, kws, ...args)`)
			}
			else {
				line.code(`\(sealedName)._im_\(@name) = function(that, ...args)`)
			}

			var block = line.newBlock()

			if labelable {
				block.line(`return \(sealedName).__ks_func_\(@name)_rt(that, kws, args)`)
			}
			else {
				block.line(`return \(sealedName).__ks_func_\(@name)_rt(that, args)`)
			}

			block.done()
			line.done()
		}

		var line = fragments.newLine()

		if labelable {
			line.code(`\(sealedName).__ks_func_\(@name)_rt = function(that, kws, args)`)
		}
		else {
			line.code(`\(sealedName).__ks_func_\(@name)_rt = function(that, args)`)
		}

		var block = line.newBlock()

		Router.toFragments(
			(function, line) => {
				if function.isSealed() {
					line.code(`\(sealedName).__ks_func_\(@name)_\(function.index()).call(that`)

					return true
				}
				else {
					line.code(`that.__ks_func_\(@name)_\(function.index())(`)

					return false
				}
			}
			null
			assessment
			block
			exhaustive ? null : Router.FooterType.NO_THROW
			exhaustive ? null : (fragments, _) => {
				if !labelable {
					fragments
						.newControl()
						.code(`if(that.\(@name))`)
						.step()
						.line(`return that.\(@name)(...args)`)
						.done()
				}

				fragments.line(`throw \($runtime.helper(this)).badArgs()`)
			}
			this
		)

		block.done()
		line.done()
	} # }}}
	toSealedStaticFragments(fragments) { # {{{
		var name = @variable.getSealedName()
		var labelable = @class.isLabelableStaticMethod(@name)
		var exhaustive = @class.isExhaustiveInstanceMethod(@name, this)
		var assessment = Router.assess(@class.listStaticMethods(@name), @name, this)

		var line = fragments.newLine()

		if labelable {
			line.code(`\(name)._sm_\(@name) = function(kws, ...args)`)
		}
		else {
			line.code(`\(name)._sm_\(@name) = function()`)
		}

		var block = line.newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`\(name).__ks_sttc_\(@name)_\(function.index())(`)

				return false
			}
			labelable ? 'args' : 'arguments'
			assessment
			block
			exhaustive ? null : Router.FooterType.NO_THROW
			exhaustive ? null : (fragments, _) => {
				if !labelable {
					fragments
						.newControl()
						.code(`if(\(@variable.name()).\(@name))`)
						.step()
						.line(`return \(@variable.name()).\(@name)(...arguments)`)
						.done()
				}

				fragments.line(`throw \($runtime.helper(this)).badArgs()`)
			}
			this
		)

		block.done()
		line.done()
	} # }}}
	toSharedFragments(fragments, _) { # {{{
		return if @override

		if @instance {
			if @class.isSealed() {
				@toSealedInstanceFragments(fragments)
			}
			else {
				@toInstanceFragments(fragments)
			}
		}
		else {
			if @class.isSealed() {
				@toSealedStaticFragments(fragments)
			}
			else {
				@toStaticFragments(fragments)
			}
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine()

		if @class.isSealed() {
			line.code(`\(@variable.getSealedName()).\(@internalName) = function(`)
		}
		else {
			if @instance {
				line.code(`\(@variable.name()).prototype.\(@internalName) = function(`)
			}
			else {
				line.code(`\(@variable.name()).\(@internalName) = function(`)
			}
		}

		var block = Parameter.toFragments(this, line, ParameterMode.Default, (fragments) => fragments.code(')').newBlock())

		for var node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		block.done()
		line.done()

		@toIndigentFragments(fragments)
	} # }}}
	type() => @type
	private {
		getOveriddenMethod(superclass: ClassType, returnReference: Boolean) { # {{{
			var mut mode = MatchingMode.FunctionSignature + MatchingMode.IgnoreReturn + MatchingMode.MissingError

			if !@override {
				mode -= MatchingMode.MissingParameterType - MatchingMode.MissingParameterArity
			}

			var methods = superclass.listInstantiableMethods(@name, @type, mode)

			var mut method = null
			var mut exact = false
			if methods.length == 1 {
				method = methods[0]
			}
			else if methods.length > 0 {
				for var m in methods {
					if m.isSubsetOf(@type, MatchingMode.ExactParameter) {
						method = m
						exact = true

						break
					}
				}

				if !?method {
					throw NotSupportedException.new(this)
				}
			}

			if ?method {
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

						if !(newType.isSubsetOf(oldType, MatchingMode.Default + MatchingMode.Missing) || newType.isInstanceOf(oldType, null, null)) {
							if @isAssertingOverride() {
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

				if !@type.isMissingError() {
					var newTypes = @type.listErrors()

					for var oldType in method.listErrors() {
						var mut matched = false

						for var newType in newTypes until matched {
							if newType.isSubsetOf(oldType, MatchingMode.Default) || newType.isInstanceOf(oldType, null, null) {
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

				if !@override && (exact || type.isSubsetOf(method, MatchingMode.ExactParameter + MatchingMode.IgnoreName)) {
					type.index(method.index())
				}

				return { method, type }
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
		listOverloadedMethods(superclass: ClassType) { # {{{
			if var methods ?= superclass.listInstanceMethods(@name) {
				for var method in methods {
					if method.isSubsetOf(@type, MatchingMode.ExactParameter) {
						return []
					}
				}
			}

			return superclass.listInstantiableMethods(
				@name
				@type
				MatchingMode.FunctionSignature + MatchingMode.SubsetParameter + MatchingMode.MissingParameter - MatchingMode.AdditionalParameter
			)
		} # }}}
	}
}

class ImplementDividedClassConstructorDeclaration extends Statement {
	private late {
		@block: Block
		@internalName: String
		@parameters: Array<Parameter>
		@this: Variable
		@type: ClassConstructorType
	}
	private {
		@aliases: Array					= []
		@class: ClassType
		@classRef: ReferenceType
		@dependent: Boolean				= false
		@overwrite: Boolean				= false
		@variable: NamedType<ClassType>
		@topNodes: Array				= []
	}
	constructor(data, parent, @variable) { # {{{
		super(data, parent, parent.scope(), ScopeType.Function)

		@class = @variable.type()
		@classRef = @scope.reference(@variable)

		if @class.isHybrid() {
			NotSupportedException.throw(this)
		}
		if @class.features() !~ ClassFeature.Constructor {
			NotSupportedException.throw(this)
		}
	} # }}}
	analyse() { # {{{
		@scope.line(@data.start.line)

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Overwrite {
				@overwrite = true
			}
		}

		@this = @scope.define('this', true, @classRef, true, this)

		var body = $ast.body(@data)

		if @class.isSealed() {
			if @getConstructorIndex($ast.block(body).statements) != -1 {
				@scope.rename('this', 'that')

				@this.replaceCall = (data, arguments, node) => CallSealedConstructorSubstitude.new(data, arguments, @variable, this)

				@dependent = true
			}
		}
		else {
			@this.replaceCall = (data, arguments, node) => CallThisConstructorSubstitude.new(data, arguments, @variable, this)
		}

		@parameters = []
		for var data in @data.parameters {
			var parameter = Parameter.new(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@block = ConstructorBlock.new($ast.block(body), this, @scope)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@scope.line(@data.start.line)

		for var parameter in @parameters {
			parameter.prepare()
		}

		@type = ClassConstructorType.new([parameter.type() for var parameter in @parameters], @data, this)

		@type.flagAltering()

		if @class.isSealed() {
			@type.flagSealed()
		}

		if @dependent {
			@type.flagDependent()
		}

		if @overwrite {
			unless @class.isSealed() {
				SyntaxException.throwNotSealedOverwrite(this)
			}

			var methods = @class.listMatchingConstructors(@type, MatchingMode.SimilarParameter + MatchingMode.ShiftableParameters)
			if methods.length == 0 {
				SyntaxException.throwNoSuitableOverwrite(@classRef, 'constructor', @type, this)
			}

			@class.overwriteConstructor(@type, methods)

			@internalName = `__ks_cons_\(@type.index())`

			var variable = @scope.define('precursor', true, @classRef, this)

			variable.replaceCall = (data, arguments, node) => CallOverwrittenConstructorSubstitude.new(data, arguments, @variable, this)
		}
		else {
			if @class.hasMatchingConstructor(@type, MatchingMode.ExactParameter) {
				SyntaxException.throwDuplicateConstructor(this)
			}
			else {
				@internalName = `__ks_cons_\(@class.addConstructor(@type))`
			}
		}

		var mut index = 1
		if @block.isEmpty() {
			if @class.isExtending() {
				@addCallToParentConstructor()

				index = 0
			}
		}
		else if @class.isExtending() && (index <- @getConstructorIndex(@block.getDataStatements())) == -1 {
			SyntaxException.throwNoSuperCall(this)
		}

		if ?#@aliases {
			@block.analyse(0, index)

			@block.analyse(@aliases)

			@block.analyse(index + 1)

			for var statement in @aliases {
				var name = statement.getVariableName()

				if var variable ?= @class.getInstanceVariable(name) {
					if variable.isRequiringInitialization() {
						@block.initializeVariable(VariableBrief.new(
							name
							type: statement.type()
							instance: true
						), statement, this)
					}
				}
			}
		}
		else {
			@block.analyse()
		}
	} # }}}
	translate() { # {{{
		for var parameter in @parameters {
			parameter.translate()
		}

		@block.prepare()
		@block.translate()

		var variables = @class.listInstanceVariables((_, type) => type.isRequiringInitialization() && !type.isAlien() && !type.isAltering())

		@checkVariableInitialization(variables)
	} # }}}
	addAtThisParameter(statement: AliasStatement) { # {{{
		if !ClassDeclaration.isAssigningAlias(@block.getDataStatements(), statement.name(), false, false) {
			@aliases.push(statement)
		}
	} # }}}
	private addCallToParentConstructor() { # {{{
		// only add call if parent has an empty constructor
		var extendedType = @class.extends().type()

		if extendedType.matchArguments([]) {
			if extendedType.hasConstructors() || extendedType.isSealed() {
				@block.addDataStatement({
					kind: NodeKind.ExpressionStatement
					attributes: []
					modifiers: []
					expression: {
						kind: NodeKind.CallExpression
						attributes: []
						modifiers: []
						scope: {
							kind: ScopeKind.This
						}
						callee: {
							kind: NodeKind.Identifier
							name: 'super'
							start: @data.start
							end: @data.start
						}
						arguments: []
						start: @data.start
						end: @data.start
					}
					start: @data.start
					end: @data.start
				})
			}
		}
		else {
			SyntaxException.throwNoSuperCall(this)
		}
	} # }}}
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	checkVariableInitialization(variables: String[]): Void { # {{{
		for var variable in variables {
			if @block.isInitializingInstanceVariable(variable) {
				@type.flagInitializingInstanceVariable(variable)
			}
			else {
				SyntaxException.throwNotInitializedField(variable, this)
			}
		}
	} # }}}
	class() => @variable
	private getConstructorIndex(body: Array) { # {{{
		for var statement, index in body {
			if statement.kind == NodeKind.ExpressionStatement {
				var expression = statement.expression

				if expression.kind == NodeKind.CallExpression {
					if expression.callee.kind == NodeKind.Identifier && (expression.callee.name == 'this' || expression.callee.name == 'super' || (@overwrite && expression.callee.name == 'precursor')) {
						return index
					}
				}
			}
			else if statement.kind == NodeKind.IfStatement {
				if ?statement.whenFalse && @getConstructorIndex(statement.whenTrue.statements) != -1 && @getConstructorIndex(statement.whenFalse.statements) != -1 {
					return index
				}
			}
		}

		return -1
	} # }}}
	getMatchingMode(): MatchingMode { # {{{
		if @overwrite {
			return MatchingMode.SimilarParameter + MatchingMode.ShiftableParameters
		}
		else {
			return MatchingMode.ExactParameter
		}
	} # }}}
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	getSharedName() => '__ks_cons'
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConstructor() => true
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isExtending() => @class.isExtending()
	isInstance() => false
	isMethod() => true
	isOverridableFunction() => true
	name() => 'constructor'
	parameters() => @parameters
	toCreatorFragments(fragments) { # {{{
		var classname = @variable.name()
		var name = @class.isSealed() ? @variable.getSealedName() : @variable.name()
		var args = @type.max() == 0 ? '' : '...args'

		var line = fragments.newLine()
		var block = line.code(`\(name).__ks_new_\(@type.index()) = function(\(args))`).newBlock()

		if @class.isSealed() {
			if @type.isDependent() {
				block.line(`return \(name).__ks_cons_\(@type.index())(\(args))`)
			}
			else {
				block.line(`return \(name).__ks_cons_\(@type.index()).call(new \(classname)(), \(args))`)
			}
		}
		else {
			block
				.line(`const o = Object.create(\(@variable.name()).prototype)`)
				.line('o.__ks_init()')
				.line(`o.__ks_cons_\(@type.index())(\(args))`)
				.line('return o')
		}

		block.done()
		line.done()
	} # }}}
	toSharedFragments(fragments, _) { # {{{
		var classname = @variable.name()

		var line = fragments.newLine()

		var assessment = Router.assess(@class.listAccessibleConstructors(), 'constructor', this)

		if @class.isSealed() {
			var sealedName = @variable.getSealedName()
			var exhaustive = @class.isExhaustiveConstructor(this)

			var block = line.code(`\(sealedName).new = function()`).newBlock()

			Router.toFragments(
				(function, line) => {
					if function.isSealed() {
						if function.isDependent() {
							line.code(`\(sealedName).__ks_cons_\(function.index())(`)

							return false
						}
						else {
							line.code(`\(sealedName).__ks_cons_\(function.index()).call(new \(classname)()`)

							return true
						}
					}
					else {
						line.code(`new \(classname)(`)

						return false
					}
				}
				'arguments'
				assessment
				block
				exhaustive ? null : Router.FooterType.NO_THROW
				exhaustive ? null : (fragments, _) => {
					fragments.line(`return new \(classname)(...arguments)`)
				}
				this
			)

			block.done()
		}
		else {
			var block = line.code(`\(classname).prototype.__ks_cons_rt = function(that, args)`).newBlock()

			Router.toFragments(
				(function, line) => {
					line.code(`\(classname).prototype.__ks_cons_\(function.index()).call(that`)

					return true
				}
				null
				assessment
				block
				this
			)

			block.done()
		}

		line.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		@toCreatorFragments(fragments)

		var line = fragments.newLine()

		if @class.isSealed() {
			line.code(`\(@variable.getSealedName()).\(@internalName) = function(`)
		}
		else {
			line.code(`\(@variable.name()).prototype.\(@internalName) = function(`)
		}

		var block = Parameter.toFragments(this, line, ParameterMode.Default, (fragments) => fragments.code(')').newBlock())

		for var node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		if @class.isSealed() {
			block.newLine().code(`return `).compile(@this).done()
		}

		block.done()
		line.done()
	} # }}}
	type() => @type
}


class CallOverwrittenMethodSubstitude extends Substitude {
	private late {
		@instance: Boolean
	}
	private {
		@arguments
		@class: NamedType<ClassType>
		@data
		@methods: Array<FunctionType>	= []
		@name: String
		@type: Type
	}
	constructor(@data, @arguments, @class, @name, methods: Array<FunctionType>, @instance, node: AbstractNode) { # {{{
		super()

		var types = []

		for var method in methods {
			if method.matchArguments(@arguments, node) {
				types.push(method.getReturnType())

				@methods.push(method)
			}
		}

		@type = Type.union(@class.scope(), ...types)
	} # }}}
	isNullable() => false
	isSkippable() => false
	toFragments(fragments, mode) { # {{{
		if @methods.length == 1 && @methods[0].isSealed() {
			fragments.code(`\(@class.getSealedName()).__ks_\(@instance ? 'func' : 'sttc')_\(@name)_\(@methods[0].index())`)

			if @arguments.length == 0 {
				fragments.code(`.apply(this`)
			}
			else {
				fragments.code(`.call(this, `)

				for var argument, index in @arguments {
					if index != 0 {
						fragments.code($comma)
					}

					fragments.compile(argument)
				}
			}
		}
		else {
			fragments.code(`this.\(@name)(`)

			for var argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
	} # }}}
	type() => @type
}

class CallSealedConstructorSubstitude extends Substitude {
	private {
		@arguments
		@class: NamedType<ClassType>
		@data
		@node
	}
	constructor(@data, @arguments, @class, @node)
	isNullable() => false
	isSkippable() => false
	toFragments(fragments, mode) { # {{{
		fragments.code(`var that = \(@class.getSealedName()).new(`)

		for var argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		if @class.type().isInitializing() {
			fragments.whenDone($callSealedInitializer^^(fragments, @class, @node))
		}
	} # }}}
	type() => Type.Void
}

class CallOverwrittenConstructorSubstitude extends Substitude {
	private {
		@arguments
		@class: NamedType<ClassType>
		@data
		@node
	}
	constructor(@data, @arguments, @class, @node)
	isNullable() => false
	isSkippable() => false
	toFragments(fragments, mode) { # {{{
		fragments.code(`const that = new \(@class.name())(`)

		for var argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		if @class.isSealed() && @class.type().isInitializing() {
			fragments.whenDone($callSealedInitializer^^(fragments, @class, @node))
		}
	} # }}}
	type() => Type.Void
}

func $callSealedInitializer(fragments, type, node) { # {{{
	var ctrl = fragments.newControl()
	ctrl.code(`if(!that[\($runtime.initFlag(node))])`).step()
	ctrl.line(`\(type.getSealedName()).__ks_init(that)`)
	ctrl.done()
} # }}}
