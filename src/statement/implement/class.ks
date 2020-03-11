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
		@type = ClassVariableType.fromAST(@data, this)

		@type.flagAlteration()

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
	toFragments(fragments, mode) { // {{{
		if @defaultValue {
			if @class.isSealed() {
				if @instance {
					let line, block, ctrl

					// init()
					line = fragments.newLine()

					line.code(`\(@variable.getSealedName()).__ks_init_\(@init) = function(that)`)

					block = line.newBlock()

					block.newLine().code(`that.\(@internalName) = `).compile(@value).done()

					block.done()
					line.done()

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
				if @instance {
					const line = fragments.newLine()

					line.code(`\(@variable.name()).prototype.__ks_init_\(@init) = function()`)

					const block = line.newBlock()

					block.newLine().code(`this.\(@internalName) = `).compile(@value).done()

					block.done()
					line.done()
				}
				else {
					fragments.newLine().code(`\(@variable.name()).\(@internalName) = `).compile(@value).done()
				}
			}
		}
	} // }}}
	toSharedFragments(fragments) { // {{{
		if @class.isSealed() {
			const line = fragments.newLine()

			line.code(`\(@variable.getSealedName()).__ks_init = function(that)`)

			const block = line.newBlock()

			for let i from 0 to @init {
				block.line(`\(@variable.getSealedName()).__ks_init_\(i)(that)`)
			}

			block.line(`that[\($runtime.initFlag(this))] = true`)

			block.done()
			line.done()
		}
		else {
			const line = fragments.newLine()

			line.code(`\(@variable.name()).prototype.__ks_init = function()`)

			const block = line.newBlock()

			for let i from 0 to @init {
				block.line(`\(@variable.name()).prototype.__ks_init_\(i).call(this)`)
			}

			block.done()
			line.done()
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
		_aliases: Array					= []
		_autoTyping: Boolean			= false
		_class: ClassType
		_classRef: ReferenceType
		_indigentValues: Array			= []
		_instance: Boolean				= true
		_override: Boolean				= false
		_overwrite: Boolean				= false
		_variable: NamedType<ClassType>
		_topNodes: Array				= []
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

		@type = new ClassMethodType([parameter.type() for const parameter in @parameters], @data, this)

		@type.flagAlteration()

		if @class.isSealed() {
			@type.flagSealed()
		}

		if @instance {
			if @override {
				if const method = @class.getInstantiableMethod(@name, @parameters) {
					@type = method.clone().flagAlteration()
					@internalName = `__ks_func_\(@name)_\(method.identifier())`

					const parameters = @type.parameters()

					for const parameter, index in @parameters {
						parameter.type(parameters[index])
					}
				}
				else {
					/* SyntaxException.throwNoOverridableMethod(@class, @name, @parameters, this) */
					@override = false
					@internalName = `__ks_func_\(@name)_\(@class.addInstanceMethod(@name, @type))`
				}
			}
			else if @overwrite {
				unless @class.isSealed() {
					SyntaxException.throwNotSealedOverwrite(this)
				}

				const methods = @class.listMatchingInstanceMethods(@name, @type, MatchingMode::SimilarParameters + MatchingMode::ShiftableParameters)
				if methods.length == 0 {
					SyntaxException.throwNoSuitableOverwrite(@classRef, @name, @type, this)
				}

				@class.overwriteInstanceMethod(@name, @type, methods)

				@internalName = `__ks_func_\(@name)_\(@type.identifier())`

				const type = Type.union(@scope, ...methods)
				const variable = @scope.define('precursor', true, type, this)

				variable.replaceCall = (data, arguments) => new CallOverwrittenMethodSubstitude(data, arguments, @variable, @name, methods, true)
			}
			else {
				if @class.hasMatchingInstanceMethod(@name, @type, MatchingMode::ExactParameters) {
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

				@internalName = `__ks_sttc_\(@name)_\(@type.identifier())`

				const type = Type.union(@scope, ...methods)
				const variable = @scope.define('precursor', true, type, this)

				variable.replaceCall = (data, arguments) => new CallOverwrittenMethodSubstitude(data, arguments, @variable, @name, methods, false)
			}
			else {
				if @class.hasMatchingClassMethod(@name, @type, MatchingMode::ExactParameters) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@internalName = `__ks_sttc_\(@name)_\(@class.addClassMethod(@name, @type))`
				}
			}
		}

		@block.analyse(@aliases)

		@block.analyse()

		if @data.type?.kind == NodeKind::ReturnTypeReference {
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
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	class() => @variable
	getMatchingMode(): MatchingMode { // {{{
		if @override {
			return MatchingMode::ShiftableParameters
		}
		else if @overwrite {
			return MatchingMode::SimilarParameters + MatchingMode::ShiftableParameters
		}
		else {
			return MatchingMode::ExactParameters
		}
	} // }}}
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	getSharedName() => @override ? null : @instance ? `_im_\(@name)` : `_cm_\(@name)`
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
	toSharedFragments(fragments) { // {{{
		return if @override

		if @instance {
			if @class.isSealed() {
				const assessment = Router.assess(@class.listInstanceMethods(@name), false, @name, this)

				Router.toFragments(
					assessment
					fragments.newLine()
					'args'
					true
					(node, fragments) => {
						const block = fragments.code(`\(@variable.getSealedName())._im_\(@name) = function(that)`).newBlock()

						block.line('var args = Array.prototype.slice.call(arguments, 1, arguments.length)')

						return block
					}
					(fragments) => fragments.done()
					(fragments, method) => {
						if method.max() == 0 {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_func_\(@name)_\(method.identifier()).apply(that)`)
							}
							else {
								fragments.line(`return \(@variable.name()).prototype.__ks_func_\(@name)_\(method.identifier()).apply(that)`)
							}
						}
						else {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_func_\(@name)_\(method.identifier()).apply(that, args)`)
							}
							else {
								fragments.line(`return \(@variable.name()).prototype.__ks_func_\(@name)_\(method.identifier()).apply(that, args)`)
							}
						}
					}
					ClassDeclaration.toWrongDoingFragments
					this
				).done()
			}
			else {
				ClassMethodDeclaration.toInstanceSwitchFragments(this, fragments.newLine(), @variable, @class.listInstanceMethods(@name), false, @name, (node, fragments) => fragments.code(`\(@variable.name()).prototype.\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
			}
		}
		else {
			if @class.isSealed() {
				const assessment = Router.assess(@class.listClassMethods(@name), false, @name, this)

				Router.toFragments(
					assessment
					fragments.newLine()
					'args'
					true
					(node, fragments) => {
						const block = fragments.code(`\(@variable.getSealedName())._cm_\(@name) = function()`).newBlock()

						block.line('var args = Array.prototype.slice.call(arguments)')

						return block
					}
					(fragments) => fragments.done()
					(fragments, method) => {
						if method.max() == 0 {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_sttc_\(@name)_\(method.identifier())()`)
							}
							else {
								fragments.line(`return \(@variable.name()).__ks_sttc_\(@name)_\(method.identifier())()`)
							}
						}
						else {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_sttc_\(@name)_\(method.identifier()).apply(null, args)`)
							}
							else {
								fragments.line(`return \(@variable.name()).__ks_sttc_\(@name)_\(method.identifier()).apply(null, args)`)
							}
						}
					}
					ClassDeclaration.toWrongDoingFragments
					this
				).done()
			}
			else {
				ClassMethodDeclaration.toClassSwitchFragments(this, fragments.newLine(), @variable, @class.listClassMethods(@name), false, @name, (node, fragments) => fragments.code(`\(@variable.name()).\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
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

				@this.replaceCall = (data, arguments) => new CallSealedConstructorSubstitude(data, arguments, @variable, this)

				@dependent = true
			}
		}
		else {
			@this.replaceCall = (data, arguments) => new CallThisConstructorSubstitude(data, arguments, @variable)
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

		@type.flagAlteration()

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

			const methods = @class.listMatchingConstructors(@type, MatchingMode::SimilarParameters + MatchingMode::ShiftableParameters)
			if methods.length == 0 {
				SyntaxException.throwNoSuitableOverwrite(@classRef, 'constructor', @type, this)
			}

			@class.overwriteConstructor(@type, methods)

			@internalName = `__ks_cons_\(@type.identifier())`

			const variable = @scope.define('precursor', true, @classRef, this)

			variable.replaceCall = (data, arguments) => new CallOverwrittenConstructorSubstitude(data, arguments, @variable, this)
		}
		else {
			if @class.hasMatchingConstructor(@type, MatchingMode::ExactParameters) {
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
			if variable.isRequiringInitialization() && !variable.isAlien() && !variable.isAlteration() {
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
			return MatchingMode::SimilarParameters + MatchingMode::ShiftableParameters
		}
		else {
			return MatchingMode::ExactParameters
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
	toSharedFragments(fragments) { // {{{
		if @class.isSealed() {
			const assessment = Router.assess([constructor for const constructor in @class.listConstructors()], false, 'constructor', this, false, groups => {
				for const group of groups {
					auto sealed = 0
					auto notsealed = 0

					for const function in group.functions {
						if function.isSealed() {
							++sealed
						}
						else {
							++notsealed
						}
					}

					if sealed == 0 {
						group.functions = [group.functions[0]]
					}
				}
			})

			const es5 = @options.format.spreads == 'es5'
			let min = Number.MAX_VALUE

			Router.toFragments(
				assessment
				fragments.newLine()
				'arguments'
				false
				(node, fragments) => fragments.code(`\(@variable.getSealedName()).new = function()`).newBlock()
				(fragments) => fragments.done()
				(fragments, method, index) => {
					if !method.isSealed() {
						if method.max() == 0 {
							fragments.line(`return new \(@variable.name())()`)
						}
						else {
							if es5 {
								fragments.line(`return new (Function.bind.apply(\(@variable.name()), [null].concat(Array.prototype.slice.call(arguments))))`)
							}
							else {
								fragments.line(`return new \(@variable.name())(...arguments)`)
							}
						}
					}
					else if method.isDependent() {
						if es5 {
							fragments.line(`return \(@variable.getSealedName()).__ks_cons_\(method.identifier()).apply(null, arguments)`)
						}
						else {
							fragments.line(`return \(@variable.getSealedName()).__ks_cons_\(method.identifier())(...arguments)`)
						}
					}
					else {
						fragments.line(`return \(@variable.getSealedName()).__ks_cons_\(method.identifier()).apply(new \(@variable.name())(), arguments)`)
					}

					if method.min() < min {
						min = method.min()
					}
				}
				(block, ctrl) => {
					if @class.isExhaustive() {
						ctrl
							.step()
							.code('else')
							.step()
							.line(`throw new SyntaxError("Wrong number of arguments")`)
							.done()
					}
					else {
						ctrl.step()

						if min > 0 {
							ctrl
								.code('else if(arguments.length === 0)')
								.step()
								.line(`return new \(@variable.name())()`)
								.step()
						}

						ctrl.code(`else`).step()

						if es5 {
							ctrl.line(`return new (Function.bind.apply(\(@variable.name()), [null].concat(Array.prototype.slice.call(arguments))))`)
						}
						else {
							ctrl.line(`return new \(@variable.name())(...arguments)`)
						}

						ctrl.done()
					}
				}
				this
			).done()
		}
		else {
			ClassConstructorDeclaration.toRouterFragments(
				this
				fragments.newControl()
				@classRef
				@class.listConstructors()
				(node, fragments) => fragments.code(`\(@variable.name()).prototype.__ks_cons = function(args)`).step()
				(fragments) => fragments.done()
			)
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
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
	constructor(@data, @arguments, @class, @name, methods: Array<FunctionType>, @instance) { // {{{
		const types = []

		for const method in methods {
			if method.matchArguments(@arguments) {
				types.push(method.getReturnType())

				@methods.push(method)
			}
		}

		@type = Type.union(@class.scope(), ...types)
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		if @methods.length == 1 && @methods[0].isSealed() {
			fragments.code(`\(@class.getSealedName()).__ks_\(@instance ? 'func' : 'sttc')_\(@name)_\(@methods[0].identifier())`)

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
	toFragments(fragments, mode) { // {{{
		fragments.code(`var that = new \(@class.name())(`)

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