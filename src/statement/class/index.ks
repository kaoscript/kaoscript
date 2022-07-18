enum HelperTypeKind { # {{{
	Native
	Referenced
	Unreferenced
} # }}}

enum TypeStatus { # {{{
	Native
	Referenced
	Unreferenced
} # }}}

class ClassDeclaration extends Statement {
	private lateinit {
		_class: ClassType
		_extendsName: String
		_extendsType: NamedType<ClassType>
		_initsId: String
		_name: String
		_type: NamedType<ClassType>
		_variable: Variable
	}
	private {
		_abstract: Boolean 					= false
		_abstractMethods					= {}
		_classMethods						= {}
		_classVariables						= {}
		_constructors						= []
		_constructorScope
		_destructor							= null
		_destructorScope
		_es5: Boolean						= false
		_extending: Boolean					= false
		_forcefullyRebinded: Boolean		= false
		_forkedMethods						= {}
		_hybrid: Boolean					= false
		_inits: Boolean						= false
		_instanceMethods					= {}
		_instanceVariables					= {}
		_instanceVariableScope
		_macros								= {}
		_references							= {}
		_sealed: Boolean 					= false
		_sharedMethods: Dictionary			= {}
	}
	static callMethod(node, variable, fnName, argName, retCode, fragments, method, index) { # {{{
		if method.max() == 0 && !method.isAsync() {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this)')
		}
		else {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this, ', argName, ')')
		}
	} # }}}
	static isAssigningAlias(data, name, constructor, extending) { # {{{
		if data is Array {
			for d in data {
				if ClassDeclaration.isAssigningAlias(d, name, constructor, extending) {
					return true
				}
			}
		}
		else {
			switch data.kind {
				NodeKind::BinaryExpression => {
					if data.operator.kind == BinaryOperatorKind::Assignment {
						if data.left.kind == NodeKind::ThisExpression && data.left.name.name == name {
							return true
						}
						else if data.left.kind == NodeKind::MemberExpression && data.left.object.kind == NodeKind::Identifier && data.left.object.name == 'this' && data.left.property.kind == NodeKind::Identifier && (data.left.property.name == name || data.left.property.name == `_\(name)`) {
							return true
						}
					}
				}
				NodeKind::CallExpression => {
					if constructor && data.callee.kind == NodeKind::Identifier {
						if data.callee.name == 'this' || (extending && data.callee.name == 'super') {
							for arg in data.arguments {
								if arg.kind == NodeKind::Identifier && arg.name == name {
									return true
								}
							}
						}
					}
				}
				NodeKind::ReturnStatement => {
					return ClassDeclaration.isAssigningAlias(data.value, name, constructor, extending)
				}
			}
		}

		return false
	} # }}}
	static toWrongDoingFragments(block, ctrl?, argName, async, returns) { # {{{
		if ctrl == null {
			if async {
				throw new NotImplementedException()
			}
			else {
				block
					.newControl()
					.code(`if(\(argName).length !== 0)`)
					.step()
					.line('throw new SyntaxError("Wrong number of arguments")')
					.done()
			}
		}
		else {
			if async {
				ctrl.step().code('else').step()

				ctrl.line(`let __ks_cb, __ks_error = new SyntaxError("Wrong number of arguments")`)

				ctrl
					.newControl()
					.code(`if(\(argName).length > 0 && Type.isFunction((__ks_cb = \(argName)[\(argName).length - 1])))`)
					.step()
					.line(`return __ks_cb(__ks_error)`)
					.step()
					.code(`else`)
					.step()
					.line(`throw __ks_error`)
					.done()

				ctrl.done()
			}
			else if returns {
				ctrl.done()

				block.line('throw new SyntaxError("Wrong number of arguments")')
			}
			else {
				ctrl.step().code('else').step().line('throw new SyntaxError("Wrong number of arguments")').done()
			}
		}
	} # }}}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope)

		@constructorScope = this.newScope(@scope, ScopeType::Function)
		@destructorScope = this.newScope(@scope, ScopeType::Function)
		@instanceVariableScope = this.newScope(@scope, ScopeType::Function)
		@es5 = @options.format.classes == 'es5'
	} # }}}
	initiate() { # {{{
		@name = @data.name.name
		@class = new ClassType(@scope)
		@type = new NamedType(@name, @class)

		@variable = @scope.define(@name, true, @type, this)

		for const data in @data.members when data.kind == NodeKind::MacroDeclaration {
			const name = data.name.name
			const declaration = new MacroDeclaration(data, this, null)

			if @macros[name] is Array {
				@macros[name].push(declaration)
			}
			else {
				@macros[name] = [declaration]
			}
		}

		@variable.flagClassStatement()
	} # }}}
	analyse() { # {{{
		let thisVariable = @constructorScope.define('this', true, @scope.reference(@name), true, this)

		thisVariable.replaceCall = (data, arguments, node) => new CallThisConstructorSubstitude(data, arguments, @type, this)

		@destructorScope.define('this', true, @scope.reference(@name), true, this)
		@destructorScope.rename('this', 'that')

		@instanceVariableScope.define('this', true, @scope.reference(@name), true, this)

		if @data.extends? {
			@extending = true

			let name = ''
			let member = @data.extends
			while member.kind == NodeKind::MemberExpression {
				name = `.\(member.property.name)\(name)`

				member = member.object
			}

			@extendsName = `\(member.name)\(name)`

			if @extendsName == @name {
				SyntaxException.throwInheritanceLoop(@name, this)
			}
		}

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				@abstract = true

				@class.flagAbstract()
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true

				@class.flagSealed()
			}
		}

		let declaration
		for const data in @data.members {
			switch data.kind {
				NodeKind::CommentBlock => {
				}
				NodeKind::CommentLine => {
				}
				NodeKind::FieldDeclaration => {
					declaration = new ClassVariableDeclaration(data, this)

					declaration.analyse()

					if declaration.isInstance() && declaration.hasDefaultValue() {
						@inits = true
					}
				}
				NodeKind::MacroDeclaration => {
				}
				NodeKind::MethodDeclaration => {
					if @class.isConstructor(data.name.name) {
						declaration = new ClassConstructorDeclaration(data, this)
					}
					else if @class.isDestructor(data.name.name) {
						declaration = new ClassDestructorDeclaration(data, this)
					}
					else {
						declaration = new ClassMethodDeclaration(data, this)
					}

					declaration.analyse()
				}
				=> {
					throw new NotSupportedException(`Unknow kind \(data.kind)`, this)
				}
			}
		}

		if @inits {
			@initsId = @class.incInitializationSequence()
		}
	} # }}}
	enhance() { # {{{
		if @extending {
			if @extendsType !?= Type.fromAST(@data.extends, this) {
				ReferenceException.throwNotDefined(@extendsName, this)
			}
			else if @extendsType.discardName() is not ClassType {
				TypeException.throwNotClass(@extendsName, this)
			}

			@class.extends(@extendsType)
		}
	} # }}}
	prepare() { # {{{
		if @extending {
			@constructorScope.flagExtending()
			@instanceVariableScope.flagExtending()

			@class.extends(@extendsType)

			@hybrid = @class.isHybrid()

			const superType = @scope.reference(@extendsName)

			@constructorScope.define('super', true, superType, true, this)

			@instanceVariableScope.define('super', true, superType, true, this)

			this.updateConstructorScope()
		}

		for const variable, name of @classVariables {
			variable.prepare()

			@class.addClassVariable(name, variable.type())
		}

		for const methods, name of @classMethods {
			const async = @extendsType?.type().isAsyncClassMethod(name) ?? methods[0].type().isAsync()

			for method in methods {
				method.prepare()

				if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @class.hasMatchingClassMethod(name, method.type(), MatchingMode::ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@class.addClassMethod(name, method.type())
			}
		}

		for const variable, name of @instanceVariables {
			variable.prepare()

			@class.addInstanceVariable(name, variable.type())
		}

		for const methods, name of @instanceMethods {
			const async = @extendsType?.type().isAsyncInstanceMethod(name) ?? methods[0].type().isAsync()

			for method in methods {
				method.prepare()

				if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @class.hasMatchingInstanceMethod(name, method.type(), MatchingMode::ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@class.addInstanceMethod(name, method.type())
			}
		}

		for const methods, name of @abstractMethods {
			const async = @extendsType?.type().isAsyncInstanceMethod(name) ?? methods[0].type().isAsync()

			for const method in methods {
				method.prepare()

				if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @class.hasMatchingInstanceMethod(name, method.type(), MatchingMode::ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@class.addAbstractMethod(name, method.type())
			}
		}

		if @abstract {
			for const constructor in @constructors {
				constructor.prepare()

				@class.addConstructor(constructor.type())
			}
		}
		else {
			for const constructor in @constructors {
				constructor.prepare()

				if @class.hasMatchingConstructor(constructor.type(), MatchingMode::ExactParameter) {
					SyntaxException.throwIdenticalConstructor(constructor)
				}

				@class.addConstructor(constructor.type())
			}
		}

		if @destructor != null {
			@destructor.prepare()

			@class.incDestructorSequence()
		}

		if @extending && !@abstract && !Dictionary.isEmpty(notImplemented = @class.listMissingAbstractMethods()) {
			SyntaxException.throwMissingAbstractMethods(@name, notImplemented, this)
		}

		for const methods, name of @forkedMethods {
			for let { original, forks, hidden } of methods {
				const index = original.index()
				const instance = original.isInstance()
				let found = false

				if instance {
					for const method in @instanceMethods[name] until found {
						if index == method.type().index() {
							if hidden == false {
								method.flagForked(@class, forks)
							}

							found = true
						}
					}
				}
				else {
					for const method in @classMethods[name] until found {
						if index == method.type().index() {
							if hidden == false {
								method.flagForked(@class, forks)
							}

							found = true
						}
					}
				}

				if !found {
					const method = original.clone()

					if !?hidden {
						hidden = false

						if method.isAbstract() {
							hidden = true
						}
						else {
							for const fork in forks {
								if method.isSubsetOf(
										fork
										MatchingMode::FunctionSignature + MatchingMode::MissingParameter
									)
								{
									hidden = true

									break
								}
							}
						}
					}

					method.flagForked(hidden)

					if !hidden {
						if instance {
							@class.addInstanceMethod(name, method)
						}
						else {
							@class.addClassMethod(name, method)
						}
					}

					new ClassForkedMethodDeclaration(name, method, forks, hidden, this)
				}
			}
		}

		if @extending {
			const extends = @extendsType.type()
			for const methods, name of @instanceMethods {
				const all = extends.listInstantiableMethods(name)

				for const method in methods {
					for const m in all when m.index() != method.type().index() && m.index() != method.type().getForkedIndex() {
						if method.type().isSubsetOf(m.type(), MatchingMode::FunctionSignature + MatchingMode::IgnoreName + MatchingMode::IgnoreReturn + MatchingMode::IgnoreError) && !method.type().isSubsetOf(m.type(), MatchingMode::FunctionSignature + MatchingMode::IgnoreReturn + MatchingMode::IgnoreError) {
							SyntaxException.throwHiddenMethod(name, @type, m.type(), @type, method.type(), method)
						}
						else if m.type().isSubsetOf(method.type(), MatchingMode::FunctionSignature + MatchingMode::IgnoreName + MatchingMode::IgnoreReturn + MatchingMode::IgnoreError) && !m.type().isSubsetOf(method.type(), MatchingMode::FunctionSignature + MatchingMode::IgnoreReturn + MatchingMode::IgnoreError) {
							SyntaxException.throwHiddenMethod(name, @type, method.type(), @type, m.type(), method)
						}
					}
				}
			}
		}

		for const macros of @macros {
			for const macro in macros {
				macro.export(this)
			}
		}

		if !@class.isHybrid() {
			@class.setExhaustive(true)
		}
	} # }}}
	translate() { # {{{
		for const variable of @classVariables {
			variable.translate()

			if variable.isRequiringInitialization() && !variable.isInitialized() {
				SyntaxException.throwNotInitializedField(variable.name(), variable)
			}
		}

		for const variable of @instanceVariables {
			variable.translate()
		}

		for const methods of @instanceMethods {
			for method in methods {
				method.translate()
			}
		}

		if @constructors.length == 0 {
			if @extending {
				let extends = @class.extends()

				while extends? && !extends.type().hasConstructors() {
					extends = extends.type().extends()
				}

				if extends? {
					for const constructor in extends.type().listConstructors() {
						constructor.checkVariablesInitializations(this, @class)
					}
				}
				else {
					@class.checkVariablesInitializations(this)
				}
			}
			else if !@abstract {
				@class.forEachInstanceVariables((name, variable) => {
					if variable.isRequiringInitialization() {
						SyntaxException.throwNotInitializedField(name, this)
					}
				})
			}
		}
		else {
			for const constructor in @constructors {
				constructor.translate()

				@class.forEachInstanceVariables((name, variable) => {
					if variable.isRequiringInitialization() && !variable.isAlien() && !variable.isAltering() {
						constructor.checkVariableInitialization(name)
					}
				})
			}
		}

		if @destructor? {
			@destructor.translate()
		}

		for const methods of @abstractMethods {
			for method in methods {
				method.translate()
			}
		}

		for const methods of @classMethods {
			for method in methods {
				method.translate()
			}
		}
	} # }}}
	addForkedMethod(name: String, oldMethod: ClassMethodType, newMethod: ClassMethodType, hidden: Boolean?) { # {{{
		const index = oldMethod.index()

		@forkedMethods[name] ??= {}

		if const fork = @forkedMethods[name][index] {
			fork.forks.push(newMethod)
			fork.hidden = false
		}
		else {
			@forkedMethods[name][index] = {
				original: oldMethod
				forks: [newMethod]
				hidden
			}
		}
	} # }}}
	addSharedMethod(name: String, sealedclass: NamedType): Void { # {{{
		if !?@sharedMethods[name] {
			@sharedMethods[name] = {
				class: sealedclass
				index: sealedclass.type().incSharedMethod(name)
			}
		}
	} # }}}
	class() => @class
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	exportMacro(name, macro) { # {{{
		@parent.exportMacro(`\(@name).\(name)`, macro)
	} # }}}
	extends() => @extendsType
	flagForcefullyRebinded() { # {{{
		@forcefullyRebinded = true
	} # }}}
	getClassVariable(name: String) => @classVariables[name]
	getInstanceVariable(name: String) => @instanceVariables[name]
	hasConstructors() => @constructors.length != 0
	isAbstract() => @abstract
	isEnhancementExport() => true
	isExtending() => @extending
	isHybrid() => @hybrid
	level() => @class.level()
	name() => @name
	newInstanceMethodScope(method: ClassMethodDeclaration) { # {{{
		const scope = this.newScope(@scope, ScopeType::Function)

		scope.define('this', true, @scope.reference(@name), true, this)

		if @extending {
			scope.flagExtending()

			scope.define('super', true, @scope.reference(@extendsName), true, this)
		}

		return scope
	} # }}}
	registerMacro(name, macro) { # {{{
		@scope.addMacro(name, macro)

		@parent.registerMacro(`\(@name).\(name)`, macro)
	} # }}}
	toContinousES6Fragments(fragments) { # {{{
		let root = fragments
		let breakable = true

		if @forcefullyRebinded {
			root = fragments.newLine().code(`var \(@name) = `)
			breakable = false
		}

		const clazz = root
			.newControl(null, breakable, breakable)
			.code('class ', @name)

		if @extending {
			clazz.code(' extends ', @extendsName)
		}

		clazz.step()

		if !@abstract {
			const constructors = @class.listAccessibleConstructors()

			if constructors.length == 0 {
				clazz
					.newControl()
					.code('static __ks_new_0()')
					.step()
					.line(`const o = Object.create(\(@name).prototype)`)
					.line('o.__ks_init()')
					.line('return o')
					.done()
			}
			else {
				for const method in constructors {
					ClassConstructorDeclaration.toCreatorFragments(@type, method.type(), clazz)
				}
			}
		}

		let ctrl
		if !@extending {
			clazz
				.newControl()
				.code('constructor()')
				.step()
				.line('this.__ks_init()')
				.line('this.__ks_cons_rt.call(null, this, arguments)')
				.done()
		}

		if @inits {
			ctrl = clazz
				.newControl()
				.code(`__ks_init()`)
				.step()

			if @extending && !@extendsType.isSealedAlien() {
				ctrl.line('super.__ks_init()')
			}

			for const field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl.done()
		}
		else {
			if !@extending {
				clazz.newControl().code('__ks_init()').step().done()
			}
		}

		const m = []

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toRouterFragments(
			this
			clazz.newControl()
			@type
			m
			null
			(node, fragments) => fragments.code('__ks_cons_rt(that, args)').step()
			(fragments) => fragments.done()
		)

		if @destructor? {
			@destructor.toFragments(clazz, Mode::None)

			ClassDestructorDeclaration.toRouterFragments(this, clazz, @type)
		}

		for const methods of @abstractMethods {
			for const method in methods {
				method.toIndigentFragments(clazz)
			}
		}

		for const methods, name of @instanceMethods {
			const m = []

			if !@extending || !@extendsType.type().hasInstanceMethod(name) {
				ClassMethodDeclaration.toInstanceHeadFragments(name, clazz)
			}

			const overrides = []

			for const method in methods {
				if method.isForked() {
					method.toForkFragments(clazz)
				}

				method.toFragments(clazz, Mode::None)

				if method.isRoutable() {
					if method.isHiddenOverride() {
						overrides.push(method.type())
					}
					else {
						m.push(method.type())
					}
				}
			}

			if m.length > 0 {
				m.push(...overrides)

				ClassMethodDeclaration.toInstanceRouterFragments(
					this
					clazz.newControl()
					@type
					m
					// overflow
					false
					name
					(node, fragments) => fragments.code(`__ks_func_\(name)_rt(that, proto, args)`).step()
					(fragments) => fragments.done()
				)
			}
		}

		for const methods, name of @classMethods {
			const m = []

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toClassRouterFragments(
				this
				clazz.newControl()
				@type
				m
				// overflow
				false
				name
				(node, fragments) => fragments.code(`static \(name)()`).step()
				(fragments) => fragments.done()
			)
		}

		clazz.done()

		if @forcefullyRebinded {
			root.done()
		}
	} # }}}
	toHybridES6Fragments(fragments) { # {{{
		const clazz = fragments
			.newControl()
			.code('class ', @name, ' extends ', @extendsName)
			.step()

		const m = []

		let ctrl
		if @constructors.length == 0 {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()
				.line('super(...arguments)')

			if @extendsType.isSealedAlien() {
				ctrl.line('this.constructor.prototype.__ks_init()')
			}

			ctrl.done()
		}
		else if @constructors.length == 1 {
			@constructors[0].toHybridConstructorFragments(clazz)
		}
		else {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()

			for method in @constructors {
				method.toFragments(ctrl, Mode::None)

				m.push(method.type())
			}

			const assessment = Router.assess(m, 'constructor', this)

			const line = ctrl.newLine()
			const block = line.code('const __ks_cons_rt = (args) =>').newBlock()

			Router.toFragments(
				(function, line) => {
					line.code(`__ks_cons_\(function.index())(`)

					return false
				}
				null
				assessment
				block
				Router.FooterType::MUST_THROW
				this
			)

			block.done()
			line.done()

			ctrl
				.line('__ks_cons_rt(arguments)')
				.done()
		}

		if @inits {
			ctrl = clazz
				.newControl()
				.code(`__ks_init_\(@initsId)()`)
				.step()

			for const field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl.done()

			if @extendsType.isSealedAlien() {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.line(`\(@name).prototype.__ks_init_\(@initsId).call(this)`)
					.done()
			}
			else {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.line(`\(@extendsName).prototype.__ks_init.call(this)`)
					.line(`\(@name).prototype.__ks_init_\(@initsId).call(this)`)
					.done()
			}
		}
		else if @extendsType.isSealedAlien() {
			clazz.newControl().code('__ks_init()').step().done()
		}
		else {
			clazz
				.newControl()
				.code('__ks_init()')
				.step()
				.line(`\(@extendsName).prototype.__ks_init.call(this)`)
				.done()
		}

		if @destructor? {
			@destructor.toFragments(clazz, Mode::None)

			ClassDestructorDeclaration.toRouterFragments(this, clazz, @type)
		}

		for const methods of @abstractMethods {
			for const method in methods {
				method.toIndigentFragments(clazz)
			}
		}

		for const methods, name of @instanceMethods {
			m.clear()

			let overflow = false

			if @extending {
				if const methods = @extendsType.type().listInstanceMethods(name) {
					for const method in methods until overflow {
						if method.isOverflowing(m) {
							overflow = true
						}
					}
				}
			}

			ClassMethodDeclaration.toInstanceHeadFragments(name, clazz)

			for const method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toInstanceRouterFragments(
				this
				clazz.newControl()
				@type
				m
				overflow
				name
				(node, fragments) => fragments.code(`__ks_func_\(name)_rt(that, proto, args)`).step()
				(fragments) => fragments.done()
			)
		}

		for const methods, name of @classMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			let overflow = false

			if @extending {
				if const methods = @extendsType.type().listClassMethods(name) {
					for const method in methods {
						if method.isOverflowing(m) {
							overflow = true
							break
						}
					}
				}
			}

			ClassMethodDeclaration.toClassRouterFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()
	} # }}}
	toSealedES6Fragments(fragments) { # {{{
		const clazz = fragments
			.newControl()
			.code('class ', @name)

		if @extending {
			clazz.code(' extends ', @extendsName)
		}

		clazz.step()

		if !@abstract {
			const constructors = @class.listAccessibleConstructors()

			if constructors.length == 0 {
				clazz
					.newControl()
					.code('static __ks_new_0()')
					.step()
					.line(`const o = Object.create(\(@name).prototype)`)
					.line('o.__ks_init()')
					.line('return o')
					.done()
			}
			else {
				for const method in constructors {
					ClassConstructorDeclaration.toCreatorFragments(@type, method.type(), clazz)
				}
			}
		}

		let ctrl
		if @extending && !@extendsType.isSealedAlien() {
			ctrl = clazz
				.newControl()
				.code('__ks_init()')
				.step()

			ctrl.line(@extendsName, '.prototype.__ks_init.call(this)')

			if @inits {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}

			ctrl.done()
		}
		else {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()

			ctrl.line('this.__ks_init()')
			ctrl.line('this.__ks_cons_rt(arguments)')

			ctrl.done()

			ctrl = clazz
				.newControl()
				.code('__ks_init()')
				.step()

			for const field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl.done()
		}

		const m = []

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toRouterFragments(
			this
			clazz.newControl()
			@type
			m
			'this'
			(node, fragments) => fragments.code('__ks_cons_rt(args)').step()
			(fragments) => fragments.done()
		)

		if @destructor? {
			@destructor.toFragments(clazz, Mode::None)

			ClassDestructorDeclaration.toRouterFragments(this, clazz, @type)
		}

		for const methods of @abstractMethods {
			for const method in methods {
				method.toIndigentFragments(clazz)
			}
		}

		for const methods, name of @instanceMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			let overflow = false

			if @extending {
				if const methods = @extendsType.type().listInstanceMethods(name) {
					for const method in methods {
						if method.isOverflowing(m) {
							overflow = true
							break
						}
					}
				}
			}

			ClassMethodDeclaration.toInstanceRouterFragments(
				this
				clazz.newControl()
				@type
				m
				overflow
				name
				(node, fragments) => fragments.code(`\(name)()`).step()
				(fragments) => fragments.done()
			)
		}

		for const methods, name of @classMethods {
			m.clear()

			for method in methods {
				method.toFragments(clazz, Mode::None)

				m.push(method.type())
			}

			let overflow = false

			if @extending {
				if const methods = @extendsType.type().listClassMethods(name) {
					for const method in methods {
						if method.isOverflowing(m) {
							overflow = true
							break
						}
					}
				}
			}

			ClassMethodDeclaration.toClassRouterFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @sealed {
			if @es5 {
				TargetException.throwNotSupported(@options.target, this)
			}
			else {
				this.toSealedES6Fragments(fragments)
			}
		}
		else {
			if @es5 {
				TargetException.throwNotSupported(@options.target, this)
			}
			else if @hybrid {
				this.toHybridES6Fragments(fragments)
			}
			else {
				this.toContinousES6Fragments(fragments)
			}
		}

		for const variable of @classVariables {
			variable.toFragments(fragments)
		}

		if !@es5 && @data.version? {
			let line = fragments.newLine()

			line
				.code(`Object.defineProperty(\(@name), 'version', `)
				.newObject()
				.line(`value: [\(@data.version.major), \(@data.version.minor), \(@data.version.patch)]`)
				.done()

			line.code(')').done()
		}

		if @sealed {
			fragments.line(`\($runtime.immutableScope(this))\(@type.getSealedName()) = {}`)
		}
		else {
			for const {class, index}, name of @sharedMethods {
				const line = fragments.newLine()
				const block = line.code(`\(class.getSealedName())._im_\(name) = function(that, ...args)`).newBlock()

				block
					.newControl()
					.code(`if(that.__ks_func_\(name)_rt)`).step()
					.line(`return that.__ks_func_\(name)_rt.call(null, that, args)`)
					.done()

				block.line(`return \(class.getSealedName()).__ks_func_\(name)_rt(that, args)`)

				block.done()
				line.done()
			}
		}
	} # }}}
	type() => @type
	updateConstructorScope() { # {{{
		const superVariable = @constructorScope.getVariable('super')

		if @hybrid && !@es5 {
			const thisVariable = @constructorScope.getVariable('this')

			thisVariable.replaceCall = (data, arguments, node) => new CallHybridThisConstructorES6Substitude(data, arguments, @type, node)

			superVariable.replaceCall = (data, arguments, node) => new CallHybridSuperConstructorES6Substitude(data, arguments, @type, node)
		}
		else {
			if @es5 {
				throw new NotSupportedException()
			}
			else {
				superVariable.replaceCall = (data, arguments, node) => new CallSuperConstructorSubstitude(data, arguments, @type, node)
			}
		}

		if @extendsType.isSealed() {
			superVariable.replaceMemberCall = (property, arguments, node) => new MemberSealedSuperMethodSubstitude(property, arguments, @type, node)
		}
	} # }}}
	updateMethodScope(method) { # {{{
		if @extending {
			const variable = method.scope().getVariable('super').setDeclaredType(@scope.reference(@extendsName))

			if @extendsType.isSealed() {
				variable.replaceCall = (data, arguments, node) => new CallSealedSuperMethodSubstitude(data, arguments, method, @type)
				variable.replaceMemberCall = (property, arguments, node) => new MemberSealedSuperMethodSubstitude(property, arguments, @type, node)
				variable.replaceContext = () => (fragments) => fragments.code('this')
			}
			else if @es5 {
				throw new NotSupportedException()
			}
			else {
				variable.replaceCall = (data, arguments, node) => new CallSuperMethodES6Substitude(data, arguments, method, @type)
			}
		}
	} # }}}
	walk(fn) { # {{{
		fn(@name, @type)
	} # }}}
}

include {
	'./substitude'
	'./variable'
	'./constructor'
	'./destructor'
	'./method'
	'./forked-method'
}
