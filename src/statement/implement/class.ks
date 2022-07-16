class ImplementClassFieldDeclaration extends Statement {
	private lateinit {
		_type: ClassVariableType
	}
	private {
		_autoTyping: Boolean				= false
		_class: ClassType
		_classRef: ReferenceType
		_defaultValue: Boolean				= false
		_immutable: Boolean					= false
		_init: Number						= -1
		_instance: Boolean					= true
		_internalName: String
		_lateInit: Boolean					= false
		_name: String
		_value								= null
		_variable: NamedType<ClassType>
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent)

		@class = @variable.type()
		@classRef = @scope.reference(@variable)

		@name = @internalName = data.name.name

		let private = false
		let alias = false

		for const modifier in data.modifiers {
			switch modifier.kind {
				ModifierKind::AutoTyping => {
					@autoTyping = true
				}
				ModifierKind::Immutable => {
					@immutable = true
					@autoTyping = true
				}
				ModifierKind::LateInit => {
					@lateInit = true
				}
				ModifierKind::Private => {
					private = true
				}
				ModifierKind::Static => {
					@instance = false
				}
				ModifierKind::ThisAlias => {
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
	} // }}}
	analyse() { // {{{
		if @data.value? {
			@defaultValue = true

			@value = $compile.expression(@data.value, this)
			@value.analyse()
		}
	} // }}}
	prepare() { // {{{
		@type = ClassVariableType.fromAST(@data!?, this)

		@type.flagAltering()

		if @class.isSealed() {
			@type.flagSealed()
		}

		if @instance {
			@class.addInstanceVariable(@internalName, @type)
		}
		else {
			@class.addClassVariable(@internalName, @type)
		}

		if @defaultValue {
			if @instance {
				@init = @class.incInitializationSequence()
			}

			@value.prepare()

			if @autoTyping {
				@type.type(@value.type())
			}
		}
		else if !@lateInit && !@type.isNullable() {
			SyntaxException.throwNotInitializedField(@name, this)
		}
	} // }}}
	translate() { // {{{
		if @defaultValue {
			@value.translate()
		}
	} // }}}
	getSharedName() => @defaultValue && @instance ? '__ks_init' : null
	isMethod() => false
	isInstance() => @instance
	toFragments(fragments, mode) { // {{{
		return unless @defaultValue

		if @class.isSealed() {
			if @instance {
				let line, block, ctrl

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
	} // }}}
	toDefaultFragments(fragments) { // {{{
		return unless @instance && @defaultValue

		if @class.isSealed() {
			fragments.newLine().code(`that.\(@internalName) = `).compile(@value).done()
		}
		else {
			fragments.newLine().code(`this.\(@internalName) = `).compile(@value).done()
		}
	} // }}}
	toSharedFragments(fragments, properties) { // {{{
		if properties.some((property, _, _) => property.isInstance()) {
			if @class.isSealed() {
				if @init > 0 {
					fragments.line(`\(@variable.getSealedName()).__ks_init_\(@init) = \(@variable.getSealedName()).__ks_init`)
				}

				const line = fragments.newLine()

				line.code(`\(@variable.getSealedName()).__ks_init = function(that)`)

				const block = line.newBlock()

				if @init > 0 {
					block.line(`\(@variable.getSealedName()).__ks_init_\(@init)(that)`)
				}

				for const property in properties {
					property.toDefaultFragments(block)
				}

				block.line(`that[\($runtime.initFlag(this))] = true`)

				block.done()
				line.done()
			}
			else {
				fragments.line(`\(@variable.name()).prototype.__ks_init_\(@init) = \(@variable.name()).prototype.__ks_init`)

				const line = fragments.newLine()

				line.code(`\(@variable.name()).prototype.__ks_init = function()`)

				const block = line.newBlock()

				block.line(`this.__ks_init_\(@init)()`)

				for const property in properties {
					property.toDefaultFragments(block)
				}

				block.done()
				line.done()
			}
		}
	} // }}}
	type() => @type
}

class ImplementClassMethodDeclaration extends Statement {
	private lateinit {
		_block: Block
		_internalName: String
		_name: String
		_parameters: Array<Parameter>
		_this: Variable
		_type: ClassMethodType
	}
	private {
		_aliases: Array						= []
		_autoTyping: Boolean				= false
		_class: ClassType
		_classRef: ReferenceType
		_exists: Boolean					= false
		_hiddenOverride: Boolean			= false
		_indigentValues: Array				= []
		_instance: Boolean					= true
		_override: Boolean					= false
		_overwrite: Boolean					= false
		_variable: NamedType<ClassType>
		_topNodes: Array					= []
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, parent.scope(), ScopeType::Function)

		@class = @variable.type()
		@classRef = @scope.reference(@variable)
	} // }}}
	analyse() { // {{{
		@scope.line(@data.start.line)

		@name = @data.name.name

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Override {
				@override = true
			}
			else if modifier.kind == ModifierKind::Overwrite {
				@overwrite = true
			}
			else if modifier.kind == ModifierKind::Static {
				@instance = false
			}
		}

		@this = @scope.define('this', true, @classRef, true, this)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@block = $compile.function($ast.body(@data), this)
	} // }}}
	prepare() { // {{{
		@scope.line(@data.start.line)

		for const parameter in @parameters {
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

		@type = new ClassMethodType([parameter.type() for const parameter in @parameters], @data, this)

		@type.flagAltering()

		if @class.isSealed() {
			@type.flagSealed()
		}

		const returnReference = @data.type?.kind == NodeKind::ReturnTypeReference

		let overridden

		if @instance {
			if @override {
				if const data = @getOveriddenMethod(@class, returnReference) {
					{ method: overridden, type: @type } = data

					unless @class.isAbstract() {
						@hiddenOverride = true
					}

					const overloaded = @listOverloadedMethods(@class)

					overloaded:Array.remove(overridden)

					for const method in overloaded {
						@parent.addForkedMethod(@name, method, @type)
					}
				}
				else if this.isAssertingOverride() {
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

				const methods = @class.listMatchingInstanceMethods(@name, @type, MatchingMode::SimilarParameter + MatchingMode::ShiftableParameters + MatchingMode::IgnoreReturn + MatchingMode::IgnoreError)
				if methods.length == 0 {
					SyntaxException.throwNoSuitableOverwrite(@classRef, @name, @type, this)
				}

				@class.overwriteInstanceMethod(@name, @type, methods)

				@internalName = `__ks_func_\(@name)_\(@type.index())`

				const type = Type.union(@scope, ...methods)
				const variable = @scope.define('precursor', true, type, this)

				variable.replaceCall = (data, arguments, node) => new CallOverwrittenMethodSubstitude(data, arguments, @variable, @name, methods, true, this)
			}
			else {
				if @class.hasMatchingInstanceMethod(@name, @type, MatchingMode::ExactParameter + MatchingMode::IgnoreName + MatchingMode::Superclass) {
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

				const methods = @class.listMatchingClassMethods(@name, @type, MatchingMode::ShiftableParameters)
				if methods.length == 0 {
					SyntaxException.throwNoSuitableOverwrite(@classRef, @name, @type, this)
				}

				@class.overwriteClassMethod(@name, @type, methods)

				@internalName = `__ks_sttc_\(@name)_\(@type.index())`

				const type = Type.union(@scope, ...methods)
				const variable = @scope.define('precursor', true, type, this)

				variable.replaceCall = (data, arguments, node) => new CallOverwrittenMethodSubstitude(data, arguments, @variable, @name, methods, false, this)
			}
			else {
				if @class.hasMatchingClassMethod(@name, @type, MatchingMode::ExactParameter) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@internalName = `__ks_sttc_\(@name)_\(@class.addClassMethod(@name, @type))`
				}
			}
		}

		@block.analyse(@aliases)

		@block.analyse()

		if returnReference {
			switch @data.type.value.kind {
				NodeKind::Identifier => {
					if @data.type.value.name == 'auto' {
						if !@override {
							@type.setReturnType(@block.getUnpreparedType())

							@autoTyping = true
						}
					}
					else {
						if !@override {
							@type.setReturnType(@parent.type().reference(@scope))
						}

						if @instance {
							const return = $compile.expression(@data.type.value, this)

							return.analyse()

							@block.addReturn(return)
						}
					}
				}
				NodeKind::ThisExpression => {
					const return = $compile.expression(@data.type.value, this)

					return.analyse()

					if !@override {
						@type.setReturnType(return.getUnpreparedType())
					}

					@block.addReturn(return)
				}
			}
		}

		if ?overridden {
			const oldType = overridden.getReturnType()
			const newType = @type.getReturnType()

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

			@internalName = `__ks_func_\(@name)_\(@type.index())`
		}
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		for const indigent in @indigentValues {
			indigent.value.prepare()
			indigent.value.translate()
		}

		if @autoTyping {
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			@block.type(@type.getReturnType()).prepare()
		}

		@block.translate()
	} // }}}
	addAtThisParameter(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@block.statements(), statement.name(), false, false) {
			@aliases.push(statement)
		}
	} // }}}
	addIndigentValue(value: Expression, parameters) { // {{{
		const name = `__ks_default_\(@class.level())_\(@class.incDefaultSequence())`

		@indigentValues.push({
			name
			value
			parameters
		})

		return name
	} // }}}
	addTopNode(node) { // {{{
		@topNodes.push(node)
	} // }}}
	authority() => this
	isAssertingOverride() => @options.rules.assertOverride
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	class() => @variable
	getMatchingMode(): MatchingMode { // {{{
		if @override {
			return MatchingMode::ShiftableParameters
		}
		else if @overwrite {
			return MatchingMode::SimilarParameter + MatchingMode::ShiftableParameters
		}
		else {
			return MatchingMode::ExactParameter
		}
	} // }}}
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
	toIndigentFragments(fragments) { // {{{
		for const {name, value, parameters} in @indigentValues {
			const line = fragments.newLine()
			const ctrl = line.newControl(null, false, false)

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
	} // }}}
	toInstanceFragments(fragments) { // {{{
		const name = @variable.name()

		const assessment = Router.assess(@class.listInstanceMethods(@name), @name, this)

		const line = fragments.newLine()
		const block = line.code(`\(name).prototype.__ks_func_\(@name)_rt = function(that, proto, args)`).newBlock()

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
			const line = fragments.newLine()

			line
				.code(`\(name).prototype.\(@name) = function()`)
				.newBlock()
				.line(`return this.__ks_func_\(@name)_rt.call(null, this, this, arguments)`)
				.done()

			line.done()
		}
	} // }}}
	toStaticFragments(fragments) { // {{{
		const name = @variable.name()

		const assessment = Router.assess(@class.listClassMethods(@name), @name, this)

		const line = fragments.newLine()
		const block = line.code(`\(name).\(@name) = function()`).newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`\(name).__ks_func_\(@name)_\(function.index())(`)

				return false
			}
			'arguments'
			assessment
			block
			this
		)

		block.done()
		line.done()
	} // }}}
	toSealedInstanceFragments(fragments) { // {{{
		const name = @variable.name()
		const sealedName = @variable.getSealedName()

		const assessment = Router.assess(@class.listInstanceMethods(@name), @name, this)
		const exhaustive = @class.isExhaustiveInstanceMethod(@name, this)

		if !@exists {
			const line = fragments.newLine()
			const block = line.code(`\(sealedName)._im_\(@name) = function(that, ...args)`).newBlock()

			block.line(`return \(sealedName).__ks_func_\(@name)_rt(that, args)`)

			block.done()
			line.done()
		}

		const line = fragments.newLine()
		const block = line.code(`\(sealedName).__ks_func_\(@name)_rt = function(that, args)`).newBlock()

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
			exhaustive ? null : Router.FooterType::NO_THROW
			exhaustive ? null : (fragments, _) =>  {
				fragments
					.newControl()
					.code(`if(that.\(@name))`)
					.step()
					.line(`return that.\(@name)(...args)`)
					.done()

				fragments.line(`throw \($runtime.helper(this)).badArgs()`)
			}
			this
		)

		block.done()
		line.done()
	} // }}}
	toSealedStaticFragments(fragments) { // {{{
		const name = @variable.getSealedName()

		const assessment = Router.assess(@class.listClassMethods(@name), @name, this)
		const exhaustive = @class.isExhaustiveInstanceMethod(@name, this)

		const line = fragments.newLine()
		const block = line.code(`\(name)._sm_\(@name) = function()`).newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`\(name).__ks_sttc_\(@name)_\(function.index())(`)

				return false
			}
			'arguments'
			assessment
			block
			exhaustive ? null : Router.FooterType::NO_THROW
			exhaustive ? null : (fragments, _) =>  {
				fragments
					.newControl()
					.code(`if(\(@variable.name()).\(@name))`)
					.step()
					.line(`return \(@variable.name()).\(@name)(...arguments)`)
					.done()

				fragments.line(`throw \($runtime.helper(this)).badArgs()`)
			}
			this
		)

		block.done()
		line.done()
	} // }}}
	toSharedFragments(fragments, _) { // {{{
		return if @override

		if @instance {
			if @class.isSealed() {
				this.toSealedInstanceFragments(fragments)
			}
			else {
				this.toInstanceFragments(fragments)
			}
		}
		else {
			if @class.isSealed() {
				this.toSealedStaticFragments(fragments)
			}
			else {
				this.toStaticFragments(fragments)
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine()

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

		const block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
			fragments.code(')')

			return fragments.newBlock()
		})

		for const node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		block.done()
		line.done()

		this.toIndigentFragments(fragments)
	} // }}}
	type() => @type
	private {
		getOveriddenMethod(superclass: ClassType, returnReference: Boolean) { // {{{
			let mode = MatchingMode::FunctionSignature + MatchingMode::IgnoreReturn + MatchingMode::MissingError

			if !@override {
				mode -= MatchingMode::MissingParameterType - MatchingMode::MissingParameterArity
			}

			const methods = superclass.listInstantiableMethods(@name, @type, mode)

			let method = null
			let exact = false
			if methods.length == 1 {
				method = methods[0]
			}
			else if methods.length > 0 {
				for const m in methods {
					if m.isSubsetOf(@type, MatchingMode::ExactParameter) {
						method = m
						exact = true

						break
					}
				}

				if !?method {
					throw new NotSupportedException(this)
				}
			}

			if method? {
				const type = @override ? method.clone() : @type

				if @override {
					const parameters = type.parameters()

					for const parameter, index in @parameters {
						const currentType = parameter.type()
						const masterType = parameters[index]

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
						const oldType = method.getReturnType()
						const newType = @type.getReturnType()

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

				if !@type.isMissingError() {
					const newTypes = @type.listErrors()

					for const oldType in method.listErrors() {
						let matched = false

						for const newType in newTypes until matched {
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

				if !@override && (exact || type.isSubsetOf(method, MatchingMode::ExactParameter + MatchingMode::IgnoreName)) {
					type.index(method.index())
				}

				return { method, type }
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
		} // }}}
		listOverloadedMethods(superclass: ClassType) { // {{{
			if const methods = superclass.listInstanceMethods(@name) {
				for const method in methods {
					if method.isSubsetOf(@type, MatchingMode::ExactParameter) {
						return []
					}
				}
			}

			return superclass.listInstantiableMethods(
				@name
				@type
				MatchingMode::FunctionSignature + MatchingMode::SubsetParameter + MatchingMode::MissingParameter - MatchingMode::AdditionalParameter
			)
		} // }}}
	}
}

class ImplementClassConstructorDeclaration extends Statement {
	private lateinit {
		_block: Block
		_internalName: String
		_parameters: Array<Parameter>
		_this: Variable
		_type: ClassConstructorType
	}
	private {
		_aliases: Array					= []
		_class: ClassType
		_classRef: ReferenceType
		_dependent: Boolean				= false
		_overwrite: Boolean				= false
		_variable: NamedType<ClassType>
		_topNodes: Array				= []
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, parent.scope(), ScopeType::Function)

		@class = @variable.type()
		@classRef = @scope.reference(@variable)

		if @class.isHybrid() {
			NotSupportedException.throw(this)
		}
	} // }}}
	analyse() { // {{{
		@scope.line(@data.start.line)

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Overwrite {
				@overwrite = true
			}
		}

		@this = @scope.define('this', true, @classRef, true, this)

		const body = $ast.body(@data)

		if @class.isSealed() {
			if this.getConstructorIndex($ast.block(body).statements) != -1 {
				@scope.rename('this', 'that')

				@this.replaceCall = (data, arguments, node) => new CallSealedConstructorSubstitude(data, arguments, @variable, this)

				@dependent = true
			}
		}
		else {
			@this.replaceCall = (data, arguments, node) => new CallThisConstructorSubstitude(data, arguments, @variable, this)
		}

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@block = new ConstructorBlock($ast.block(body), this, @scope)
	} // }}}
	prepare() { // {{{
		@scope.line(@data.start.line)

		for const parameter in @parameters {
			parameter.prepare()
		}

		@type = new ClassConstructorType([parameter.type() for const parameter in @parameters], @data, this)

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

			const methods = @class.listMatchingConstructors(@type, MatchingMode::SimilarParameter + MatchingMode::ShiftableParameters)
			if methods.length == 0 {
				SyntaxException.throwNoSuitableOverwrite(@classRef, 'constructor', @type, this)
			}

			@class.overwriteConstructor(@type, methods)

			@internalName = `__ks_cons_\(@type.index())`

			const variable = @scope.define('precursor', true, @classRef, this)

			variable.replaceCall = (data, arguments, node) => new CallOverwrittenConstructorSubstitude(data, arguments, @variable, this)
		}
		else {
			if @class.hasMatchingConstructor(@type, MatchingMode::ExactParameter) {
				SyntaxException.throwDuplicateConstructor(this)
			}
			else {
				@internalName = `__ks_cons_\(@class.addConstructor(@type))`
			}
		}

		let index = 1
		if @block.isEmpty() {
			if @class.isExtending() {
				this.addCallToParentConstructor()

				index = 0
			}
		}
		else if @class.isExtending() && (index = this.getConstructorIndex(@block.statements())) == -1 {
			SyntaxException.throwNoSuperCall(this)
		}

		if @aliases.length == 0 {
			@block.analyse()
		}
		else {
			@block.analyse(0, index)

			@block.analyse(@aliases)

			@block.analyse(index + 1)
		}

		for const statement in @aliases {
			const name = statement.getVariableName()

			if const variable = @class.getInstanceVariable(name) {
				if variable.isRequiringInitialization() {
					@block.initializeVariable(VariableBrief(
						name
						type: statement.type()
						instance: true
					), statement, this)
				}
			}
		}
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		@block.prepare()
		@block.translate()

		@class.forEachInstanceVariables((name, variable) => {
			if variable.isRequiringInitialization() && !variable.isAlien() && !variable.isAltering() {
				this.checkVariableInitialization(name)
			}
		})
	} // }}}
	addAtThisParameter(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@block.statements(), statement.name(), false, false) {
			@aliases.push(statement)
		}
	} // }}}
	private addCallToParentConstructor() { // {{{
		// only add call if parent has an empty constructor
		const extendedType = @class.extends().type()

		if extendedType.matchArguments([]) {
			if extendedType.hasConstructors() || extendedType.isSealed() {
				@block.addStatement({
					kind: NodeKind::CallExpression
					attributes: []
					modifiers: []
					scope: {
						kind: ScopeKind::This
					}
					callee: {
						kind: NodeKind::Identifier
						name: 'super'
						start: @data.start
						end: @data.start
					}
					arguments: []
					start: @data.start
					end: @data.start
				})
			}
		}
		else {
			SyntaxException.throwNoSuperCall(this)
		}
	} // }}}
	addTopNode(node) { // {{{
		@topNodes.push(node)
	} // }}}
	authority() => this
	checkVariableInitialization(name) { // {{{
		if @block.isInitializingInstanceVariable(name) {
			@type.addInitializingInstanceVariable(name)
		}
		else {
			SyntaxException.throwNotInitializedField(name, this)
		}
	} // }}}
	class() => @variable
	private getConstructorIndex(body: Array) { // {{{
		for const statement, index in body {
			if statement.kind == NodeKind::CallExpression {
				if statement.callee.kind == NodeKind::Identifier && (statement.callee.name == 'this' || statement.callee.name == 'super' || (@overwrite && statement.callee.name == 'precursor')) {
					return index
				}
			}
			else if statement.kind == NodeKind::IfStatement {
				if statement.whenFalse? && this.getConstructorIndex(statement.whenTrue.statements) != -1 && this.getConstructorIndex(statement.whenFalse.statements) != -1 {
					return index
				}
			}
		}

		return -1
	} // }}}
	getMatchingMode(): MatchingMode { // {{{
		if @overwrite {
			return MatchingMode::SimilarParameter + MatchingMode::ShiftableParameters
		}
		else {
			return MatchingMode::ExactParameter
		}
	} // }}}
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
	toCreatorFragments(fragments) { // {{{
		const classname = @variable.name()
		const name = @class.isSealed() ? @variable.getSealedName() : @variable.name()
		const args = @type.max() == 0 ? '' : '...args'

		const line = fragments.newLine()
		const block = line.code(`\(name).__ks_new_\(@type.index()) = function(\(args))`).newBlock()

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
	} // }}}
	toSharedFragments(fragments, _) { // {{{
		const classname = @variable.name()

		const line = fragments.newLine()

		const assessment = Router.assess(@class.listAccessibleConstructors(), 'constructor', this)

		if @class.isSealed() {
			const sealedName = @variable.getSealedName()
			const exhaustive = @class.isExhaustiveConstructor(this)

			const block = line.code(`\(sealedName).new = function()`).newBlock()

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
				exhaustive ? null : Router.FooterType::NO_THROW
				exhaustive ? null : (fragments, _) => {
					fragments.line(`return new \(classname)(...arguments)`)
				}
				this
			)

			block.done()
		}
		else {
			const block = line.code(`\(classname).prototype.__ks_cons_rt = function(that, args)`).newBlock()

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
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		this.toCreatorFragments(fragments)

		const line = fragments.newLine()

		if @class.isSealed() {
			line.code(`\(@variable.getSealedName()).\(@internalName) = function(`)
		}
		else {
			line.code(`\(@variable.name()).prototype.\(@internalName) = function(`)
		}

		const block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
			fragments.code(')')

			return fragments.newBlock()
		})

		for const node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		if @class.isSealed() {
			block.newLine().code(`return `).compile(@this).done()
		}

		block.done()
		line.done()
	} // }}}
	type() => @type
}


class CallOverwrittenMethodSubstitude {
	private lateinit {
		_instance: Boolean
	}
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_methods: Array<FunctionType>	= []
		_name: String
		_type: Type
	}
	constructor(@data, @arguments, @class, @name, methods: Array<FunctionType>, @instance, node: AbstractNode) { // {{{
		const types = []

		for const method in methods {
			if method.matchArguments(@arguments, node) {
				types.push(method.getReturnType())

				@methods.push(method)
			}
		}

		@type = Type.union(@class.scope(), ...types)
	} // }}}
	isNullable() => false
	isSkippable() => false
	toFragments(fragments, mode) { // {{{
		if @methods.length == 1 && @methods[0].isSealed() {
			fragments.code(`\(@class.getSealedName()).__ks_\(@instance ? 'func' : 'sttc')_\(@name)_\(@methods[0].index())`)

			if @arguments.length == 0 {
				fragments.code(`.apply(this`)
			}
			else {
				fragments.code(`.call(this, `)

				for const argument, index in @arguments {
					if index != 0 {
						fragments.code($comma)
					}

					fragments.compile(argument)
				}
			}
		}
		else {
			fragments.code(`this.\(@name)(`)

			for const argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
	} // }}}
	type() => @type
}

class CallSealedConstructorSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_node
	}
	constructor(@data, @arguments, @class, @node)
	isNullable() => false
	isSkippable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`var that = \(@class.getSealedName()).new(`)

		for const argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		if @class.type().isInitializing() {
			fragments.whenDone($callSealedInitializer^^(fragments, @class, @node))
		}
	} // }}}
	type() => Type.Void
}

class CallOverwrittenConstructorSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_node
	}
	constructor(@data, @arguments, @class, @node)
	isNullable() => false
	isSkippable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`const that = new \(@class.name())(`)

		for const argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		if @class.isSealed() && @class.type().isInitializing() {
			fragments.whenDone($callSealedInitializer^^(fragments, @class, @node))
		}
	} // }}}
	type() => Type.Void
}

func $callSealedInitializer(fragments, type, node) { // {{{
	const ctrl = fragments.newControl()
	ctrl.code(`if(!that[\($runtime.initFlag(node))])`).step()
	ctrl.line(`\(type.getSealedName()).__ks_init(that)`)
	ctrl.done()
} // }}}
