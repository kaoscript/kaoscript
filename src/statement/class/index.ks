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
	private late {
		@class: ClassType
		@extendsName: String
		@extendsType: NamedType<ClassType>
		@initsId: String
		@name: String
		@type: NamedType<ClassType>
		@variable: Variable
	}
	private {
		@abstract: Boolean 					= false
		@abstractMethods					= {}
		@staticMethods						= {}
		@staticVariables						= {}
		@constructors						= []
		@constructorScope
		@destructor							= null
		@destructorScope
		@es5: Boolean						= false
		@extending: Boolean					= false
		@forcefullyRebinded: Boolean		= false
		@forkedMethods						= {}
		@hybrid: Boolean					= false
		@implementing: Boolean				= false
		@inits: Boolean						= false
		@instanceMethods					= {}
		@instanceVariables					= {}
		@instanceVariableScope
		@interfaces							= []
		@macros								= {}
		@proxies							= []
		@references							= {}
		@sealed: Boolean 					= false
		@sharedMethods: Object				= {}
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
			for var d in data {
				if ClassDeclaration.isAssigningAlias(d, name, constructor, extending) {
					return true
				}
			}
		}
		else {
			match data.kind {
				NodeKind.ExpressionStatement {
					var expression = data.expression

					match expression.kind {
						NodeKind.BinaryExpression {
							if expression.operator.kind == BinaryOperatorKind.Assignment && expression.operator.assignment == AssignmentOperatorKind.Equals {
								if $ast.isThisField(name, expression.left) {
									return !$ast.some(expression.right, $ast.isThisField^^(name, ^))
								}
							}
						}
						NodeKind.CallExpression {
							if constructor && expression.callee.kind == NodeKind.Identifier {
								if expression.callee.name == 'this' || (extending && expression.callee.name == 'super') {
									for var arg in expression.arguments {
										if arg.kind == NodeKind.Identifier && arg.name == name {
											return true
										}
									}
								}
							}
						}
					}
				}
				NodeKind.ReturnStatement {
					return ClassDeclaration.isAssigningAlias(data.value, name, constructor, extending)
				}
			}
		}

		return false
	} # }}}
	static toWrongDoingFragments(block, ctrl?, argName, async, returns) { # {{{
		if ctrl == null {
			if async {
				throw NotImplementedException.new()
			}
			else {
				block
					.newControl()
					.code(`if(\(argName).length !== 0)`)
					.step()
					.line('throw SyntaxError.new("Wrong number of arguments")')
					.done()
			}
		}
		else {
			if async {
				ctrl.step().code('else').step()

				ctrl.line(`let __ks_cb, __ks_error = SyntaxError.new("Wrong number of arguments")`)

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

				block.line('throw SyntaxError.new("Wrong number of arguments")')
			}
			else {
				ctrl.step().code('else').step().line('throw SyntaxError.new("Wrong number of arguments")').done()
			}
		}
	} # }}}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope)

		@constructorScope = @newScope(@scope!?, ScopeType.Method)
		@destructorScope = @newScope(@scope!?, ScopeType.Method)
		@instanceVariableScope = @newScope(@scope!?, ScopeType.Method)
		@es5 = @options.format.classes == 'es5'
	} # }}}
	initiate() { # {{{
		@name = @data.name.name
		@class = ClassType.new(@scope)
		@type = NamedType.new(@name, @class)

		@variable = @scope.define(@name, true, @type, this)

		for var data in @data.members when data.kind == NodeKind.MacroDeclaration {
			var name = data.name.name
			var declaration = MacroDeclaration.new(data, this, null)

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
		var mut thisVariable = @constructorScope.define('this', true, @scope.reference(@name), true, this)

		thisVariable.replaceCall = (data, arguments, node) => CallThisConstructorSubstitude.new(data, arguments, @type, this)

		@destructorScope.define('this', true, @scope.reference(@name), true, this)
		@destructorScope.rename('this', 'that')

		@instanceVariableScope.define('this', true, @scope.reference(@name), true, this)

		if ?@data.extends {
			@extending = true

			@extendsName = $ast.toIMString(@data.extends)

			if @extendsName == @name {
				SyntaxException.throwInheritanceLoop(@name, this)
			}
		}

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Abstract {
				@abstract = true

				@class.flagAbstract()
			}
			else if modifier.kind == ModifierKind.Sealed {
				@sealed = true

				@class.flagSealed()
			}
		}

		for var data in @data.members {
			match data.kind {
				NodeKind.CommentBlock {
				}
				NodeKind.CommentLine {
				}
				NodeKind.FieldDeclaration {
					var declaration = ClassVariableDeclaration.new(data, this)

					declaration.analyse()
				}
				NodeKind.MacroDeclaration {
				}
				NodeKind.MethodDeclaration {
					var declaration = if @class.isConstructor(data.name.name) {
						set ClassConstructorDeclaration.new(data, this)
					}
					else if @class.isDestructor(data.name.name) {
						set ClassDestructorDeclaration.new(data, this)
					}
					else {
						set ClassMethodDeclaration.new(data, this)
					}

					declaration.analyse()
				}
				NodeKind.ProxyDeclaration {
					var declaration = ClassProxyDeclaration.new(data, this)

					declaration.analyse()
				}
				NodeKind.ProxyGroupDeclaration {
					var declaration = ClassProxyGroupDeclaration.new(data, this)

					declaration.analyse()
				}
				else {
					throw NotSupportedException.new(`Unknow kind \(data.kind)`, this)
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

		if ?@data.implements {
			@implementing = true

			for var implement in @data.implements {
				var name = $ast.toIMString(implement)

				if name == @name {
					SyntaxException.throwInheritanceLoop(@name, this)
				}

				if var type ?= Type.fromAST(implement, this) {
					if type.isAlias() {
						unless type.isObject() {
							SyntaxException.throwNotObjectInterface(name, this)
						}
					}
					else {
						throw NotImplementedException.new(this)
					}

					@interfaces.push(type)
				}
				else {
					ReferenceException.throwNotDefined(name, this)
				}
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @extending {
			@constructorScope.flagExtending()
			@instanceVariableScope.flagExtending()

			@class.extends(@extendsType)

			@hybrid = @class.isHybrid()

			var superType = @scope.reference(@extendsName)

			@constructorScope.define('super', true, superType, true, this)

			@instanceVariableScope.define('super', true, superType, true, this)

			@updateConstructorScope()
		}

		if @implementing {
			for var interface in @interfaces {
				@class.addInterface(interface)
			}
		}

		for var variable, name of @staticVariables {
			variable.prepare()

			@class.addStaticVariable(name, variable.type())
		}

		for var variable, name of @instanceVariables {
			variable.prepare()

			@class.addInstanceVariable(name, variable.type())
		}

		for var methods, name of @instanceMethods {
			var async = @extendsType?.type().isAsyncInstanceMethod(name) ?? methods[0].type().isAsync()

			for var method in methods {
				method.prepare()

				if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @class.hasMatchingInstanceMethod(name, method.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@class.addInstanceMethod(name, method.type())
			}
		}

		for var methods, name of @abstractMethods {
			var async = @extendsType?.type().isAsyncInstanceMethod(name) ?? methods[0].type().isAsync()

			for var method in methods {
				method.prepare()

				if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @class.hasMatchingInstanceMethod(name, method.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@class.addAbstractMethod(name, method.type())
			}
		}

		for var methods, name of @staticMethods {
			var async = @extendsType?.type().isAsyncStaticMethod(name) ?? methods[0].type().isAsync()

			for var method in methods {
				method.prepare()

				if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @class.hasMatchingStaticMethod(name, method.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@class.addStaticMethod(name, method.type())
			}
		}

		for var proxy in @proxies {
			proxy.prepare()
		}

		if @abstract {
			for var constructor in @constructors {
				constructor.prepare()

				@class.addConstructor(constructor.type())
			}
		}
		else {
			for var constructor in @constructors {
				constructor.prepare()

				if @class.hasMatchingConstructor(constructor.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalConstructor(constructor)
				}

				@class.addConstructor(constructor.type())
			}
		}

		if @destructor != null {
			@destructor.prepare()

			@class.incDestructorSequence()
		}

		if !@abstract {
			if @extending {
				var notImplemented = @class.listMissingAbstractMethods()

				if ?#notImplemented {
					SyntaxException.throwMissingAbstractMethods(@name, notImplemented, this)
				}
			}

			if @implementing {
				for var interface in @interfaces {
					var notImplemented = interface.listMissingProperties(@class)

					if ?#notImplemented.fields || ?#notImplemented.functions {
						SyntaxException.throwMissingProperties('Class', @name, interface, notImplemented, this)
					}
				}
			}
		}

		for var methods, name of @forkedMethods {
			for var mut { original, forks, hidden? } of methods {
				var index = original.index()
				var instance = original.isInstance()
				var mut found = false

				if instance {
					if ?#@instanceMethods[name] {
						for var method in @instanceMethods[name] until found {
							if index == method.type().index() {
								if hidden == false {
									method.flagForked(@class, forks)
								}

								found = true
							}
						}
					}
					else {
						continue
					}
				}
				else {
					if ?#@staticMethods[name] {
						for var method in @staticMethods[name] until found {
							if index == method.type().index() {
								if hidden == false {
									method.flagForked(@class, forks)
								}

								found = true
							}
						}
					}
					else {
						continue
					}
				}

				if !found {
					var method = original.clone()

					if !?hidden {
						hidden = false

						if method.isAbstract() {
							hidden = true
						}
						else {
							for var fork in forks {
								if method.isSubsetOf(
										fork
										MatchingMode.FunctionSignature + MatchingMode.MissingParameter
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
							@class.addStaticMethod(name, method)
						}
					}

					ClassForkedMethodDeclaration.new(name, method, forks, hidden, this)
				}
			}
		}

		if @extending {
			var extends = @extendsType.type()
			for var methods, name of @instanceMethods {
				var all = extends.listInstantiableMethods(name)

				for var method in methods {
					for var m in all when m.index() != method.type().index() && m.index() != method.type().getForkedIndex() {
						if method.type().isSubsetOf(m.type(), MatchingMode.FunctionSignature + MatchingMode.IgnoreName + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError) && !method.type().isSubsetOf(m.type(), MatchingMode.FunctionSignature + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError) {
							SyntaxException.throwHiddenMethod(name, @type, m.type(), @type, method.type(), method)
						}
						if m.type().isSubsetOf(method.type(), MatchingMode.FunctionSignature + MatchingMode.IgnoreName + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError) && !m.type().isSubsetOf(method.type(), MatchingMode.FunctionSignature + MatchingMode.IgnoreReturn + MatchingMode.IgnoreError) {
							SyntaxException.throwHiddenMethod(name, @type, method.type(), @type, m.type(), method)
						}
					}
				}
			}
		}

		if @implementing {
			for var interface in @interfaces {
			}
		}

		for var macros of @macros {
			for var macro in macros {
				macro.export(this)
			}
		}

		if !@class.isHybrid() {
			@class.setExhaustive(true)
		}

		@class.flagComplete()
	} # }}}
	translate() { # {{{
		for var variable of @staticVariables {
			variable.translate()

			if variable.isRequiringInitialization() && !variable.isInitialized() {
				SyntaxException.throwNotInitializedField(variable.name(), variable)
			}
		}

		for var variable of @instanceVariables {
			variable.translate()
		}

		for var methods of @instanceMethods {
			for var method in methods {
				method.translate()
			}
		}

		var variables = @class.listInstanceVariables((_, type) => type.isRequiringInitialization() && !type.isAlien() && !type.isAltering())

		if @constructors.length == 0 {
			if @extending {
				var mut extends = @class.extends()

				while ?extends && !extends.type().hasConstructors() {
					extends = extends.type().extends()
				}

				if ?extends {
					for var constructor in extends.type().listConstructors() {
						constructor.checkVariableInitialization(variables, this)
					}
				}
				else {
					if ?#variables {
						SyntaxException.throwNotInitializedFields(variables, this)
					}
				}
			}
			else if !@abstract {
				if ?#variables {
					SyntaxException.throwNotInitializedFields(variables, this)
				}
			}
		}
		else {
			var roots = []
			var nonroots = []

			for var constructor in @constructors {
				constructor.translate()

				var mut root = true

				constructor.walkNode((node) => {
					if node is CallExpression {
						for var callee in node.callees() {
							if callee is SubstituteCallee && callee.substitute() is CallThisConstructorSubstitude {
								root = false

								return false
							}
						}
					}

					return true
				})

				if root {
					roots.push(constructor)
				}
				else {
					nonroots.push(constructor)
				}
			}

			for var constructor in roots {
				constructor.checkVariableInitialization(variables)
			}

			if @abstract {
				for var constructor in nonroots {
					constructor.checkVariableInitialization(variables)
				}
			}
			else {
				for var constructor in nonroots {
					constructor.type().flagInitializingInstanceVariable(...variables)
				}
			}
		}

		if ?@destructor {
			@destructor.translate()
		}

		for var methods of @abstractMethods {
			for var method in methods {
				method.translate()
			}
		}

		for var methods of @staticMethods {
			for var method in methods {
				method.translate()
			}
		}

		for var proxy in @proxies {
			proxy.translate()
		}
	} # }}}
	addForkedMethod(name: String, oldMethod: ClassMethodType, newMethod: ClassMethodType, hidden: Boolean?) { # {{{
		var index = oldMethod.index()

		@forkedMethods[name] ??= {}

		if var fork ?= @forkedMethods[name][index] {
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
	extends(): valueof @extendsType
	flagForcefullyRebinded() { # {{{
		@forcefullyRebinded = true
	} # }}}
	getStaticVariable(name: String) => @staticVariables[name]
	getInstanceVariable(name: String) => @instanceVariables[name]
	hasConstructors() => @constructors.length != 0
	hasMacro(name) => @scope.hasMacro(name)
	hasMatchingInstanceMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		return false unless ?@instanceMethods[name]

		for var method in @instanceMethods[name] {
			if method.type().isSubsetOf(type, mode) {
				return true
			}
		}

		return false
	} # }}}
	isAbstract() => @abstract
	isEnhancementExport() => true
	isExtending() => @extending
	isImplementing() => @implementing
	isHybrid() => @hybrid
	level() => @class.level()
	listInterfaces() => @interfaces
	name() => @name
	newMethodScope(instance: Boolean) { # {{{
		var scope = @newScope(@scope!?, ScopeType.Method)

		if instance {
			scope.define('this', true, @scope.reference(@name), true, this)

			if @extending {
				scope.flagExtending()

				scope.define('super', true, @scope.reference(@extendsName), true, this)
			}
		}

		return scope
	} # }}}
	registerMacro(name, macro) { # {{{
		@scope.addMacro(name, macro)

		@parent.registerMacro(`\(@name).\(name)`, macro)
	} # }}}
	toContinousES6Fragments(fragments) { # {{{
		var mut root = fragments
		var mut breakable = true

		if @forcefullyRebinded {
			root = fragments.newLine().code(`var \(@name) = `)
			breakable = false
		}

		var clazz = root
			.newControl(null, breakable, breakable)
			.code('class ', @name)

		if @extending {
			clazz.code(' extends ', @extendsName)
		}

		clazz.step()

		if !@abstract {
			var constructors = @class.listAccessibleConstructors()

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
				for var method in constructors {
					ClassConstructorDeclaration.toCreatorFragments(@type, method.type(), clazz)
				}
			}
		}

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
			var ctrl = clazz
				.newControl()
				.code(`__ks_init()`)
				.step()

			if @extending && !@extendsType.isSealedAlien() {
				ctrl.line('super.__ks_init()')
			}

			for var field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl.done()
		}
		else {
			if !@extending {
				clazz.newControl().code('__ks_init()').step().done()
			}
		}

		var m = []

		for var method in @constructors {
			method.toFragments(clazz, Mode.None)

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

		if ?@destructor {
			@destructor.toFragments(clazz, Mode.None)

			ClassDestructorDeclaration.toRouterFragments(this, clazz, @type)
		}

		for var methods of @abstractMethods {
			for var method in methods {
				method.toIndigentFragments(clazz)
			}
		}

		for var methods, name of @instanceMethods {
			var m = []

			if !@extending || !@extendsType.type().hasInstanceMethod(name) {
				ClassMethodDeclaration.toInstanceHeadFragments(name, @class, clazz)
			}

			var overrides = []

			for var method in methods {
				if method.isForked() {
					method.toForkFragments(clazz)
				}

				method.toFragments(clazz, Mode.None)

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
					@class
					(node, fragments, labelable) => {
						if labelable {
							fragments.code(`__ks_func_\(name)_rt(that, proto, kws, args)`).step()
						}
						else {
							fragments.code(`__ks_func_\(name)_rt(that, proto, args)`).step()
						}
					}
					(fragments) => fragments.done()
				)
			}
		}

		for var methods, name of @staticMethods {
			var m = []

			for var method in methods {
				method.toFragments(clazz, Mode.None)

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
				@class
				(node, fragments, labelable) => {
					if labelable {
						fragments.code(`static \(name)(kws, ...args)`).step()
					}
					else {
						fragments.code(`static \(name)()`).step()
					}
				}
				(fragments) => fragments.done()
			)
		}

		for var proxy in @proxies {
			proxy.toFragments(clazz, Mode.None)
		}

		clazz.done()

		if @forcefullyRebinded {
			root.done()
		}
	} # }}}
	toHybridES6Fragments(fragments) { # {{{
		var clazz = fragments
			.newControl()
			.code('class ', @name, ' extends ', @extendsName)
			.step()

		var m = []

		if @constructors.length == 0 {
			var ctrl = clazz
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
			var ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()

			for var method in @constructors {
				method.toFragments(ctrl, Mode.None)

				m.push(method.type())
			}

			var assessment = Router.assess(m, 'constructor', this)

			var line = ctrl.newLine()
			var block = line.code('const __ks_cons_rt = (args) =>').newBlock()

			Router.toFragments(
				(function, line) => {
					line.code(`__ks_cons_\(function.index())(`)

					return false
				}
				null
				assessment
				block
				Router.FooterType.MUST_THROW
				this
			)

			block.done()
			line.done()

			ctrl
				.line('__ks_cons_rt(arguments)')
				.done()
		}

		if @inits {
			var ctrl = clazz
				.newControl()
				.code(`__ks_init_\(@initsId)()`)
				.step()

			for var field of @instanceVariables {
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

		if ?@destructor {
			@destructor.toFragments(clazz, Mode.None)

			ClassDestructorDeclaration.toRouterFragments(this, clazz, @type)
		}

		for var methods of @abstractMethods {
			for var method in methods {
				method.toIndigentFragments(clazz)
			}
		}

		for var methods, name of @instanceMethods {
			m.clear()

			var mut overflow = false

			if @extending {
				if var methods ?= @extendsType.type().listInstanceMethods(name) {
					for var method in methods until overflow {
						if method.isOverflowing(m) {
							overflow = true
						}
					}
				}
			}

			ClassMethodDeclaration.toInstanceHeadFragments(name, @class, clazz)

			for var method in methods {
				method.toFragments(clazz, Mode.None)

				m.push(method.type())
			}

			ClassMethodDeclaration.toInstanceRouterFragments(
				this
				clazz.newControl()
				@type
				m
				overflow
				name
				@class
				(node, fragments, labelable) => {
					if labelable {
						fragments.code(`__ks_func_\(name)_rt(that, proto, kws, args)`).step()
					}
					else {
						fragments.code(`__ks_func_\(name)_rt(that, proto, args)`).step()
					}
				}
				(fragments) => fragments.done()
			)
		}

		for var methods, name of @staticMethods {
			m.clear()

			for var method in methods {
				method.toFragments(clazz, Mode.None)

				m.push(method.type())
			}

			var mut overflow = false

			if @extending {
				if var methods ?= @extendsType.type().listStaticMethods(name) {
					for var method in methods {
						if method.isOverflowing(m) {
							overflow = true
							break
						}
					}
				}
			}

			ClassMethodDeclaration.toClassRouterFragments(
				this
				clazz.newControl()
				@type
				m
				overflow
				name
				@class
				(node, fragments, labelable) => {
					if labelable {
						fragments.code(`static \(name)(kws, ...args)`).step()
					}
					else {
						fragments.code(`static \(name)()`).step()
					}
				}
				(fragments) => fragments.done()
			)
		}

		clazz.done()
	} # }}}
	toSealedES6Fragments(fragments) { # {{{
		var clazz = fragments
			.newControl()
			.code('class ', @name)

		if @extending {
			clazz.code(' extends ', @extendsName)
		}

		clazz.step()

		if !@abstract {
			var constructors = @class.listAccessibleConstructors()

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
				for var method in constructors {
					ClassConstructorDeclaration.toCreatorFragments(@type, method.type(), clazz)
				}
			}
		}

		if @extending && !@extendsType.isSealedAlien() {
			var ctrl = clazz
				.newControl()
				.code('__ks_init()')
				.step()

			ctrl.line(@extendsName, '.prototype.__ks_init.call(this)')

			if @inits {
				for var field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}

			ctrl.done()
		}
		else {
			var mut ctrl = clazz
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

			for var field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl.done()
		}

		var m = []

		for var method in @constructors {
			method.toFragments(clazz, Mode.None)

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

		if ?@destructor {
			@destructor.toFragments(clazz, Mode.None)

			ClassDestructorDeclaration.toRouterFragments(this, clazz, @type)
		}

		for var methods of @abstractMethods {
			for var method in methods {
				method.toIndigentFragments(clazz)
			}
		}

		for var methods, name of @instanceMethods {
			m.clear()

			for var method in methods {
				method.toFragments(clazz, Mode.None)

				m.push(method.type())
			}

			var mut overflow = false

			if @extending {
				if var methods ?= @extendsType.type().listInstanceMethods(name) {
					for var method in methods {
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
				@class
				(node, fragments, labelable) => {
					if labelable {
						fragments.code(`\(name)(kws, ...args)`).step()
					}
					else {
						fragments.code(`\(name)(...args)`).step()
					}
				}
				(fragments) => fragments.done()
			)
		}

		for var methods, name of @staticMethods {
			m.clear()

			for var method in methods {
				method.toFragments(clazz, Mode.None)

				m.push(method.type())
			}

			var mut overflow = false

			if @extending {
				if var methods ?= @extendsType.type().listStaticMethods(name) {
					for var method in methods {
						if method.isOverflowing(m) {
							overflow = true
							break
						}
					}
				}
			}

			ClassMethodDeclaration.toClassRouterFragments(
				this
				clazz.newControl()
				@type
				m
				overflow
				name
				@class
				(node, fragments, labelable) => {
					if labelable {
						fragments.code(`static \(name)(kws, ...args)`).step()
					}
					else {
						fragments.code(`static \(name)()`).step()
					}
				}
				(fragments) => fragments.done()
			)
		}

		clazz.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @sealed {
			if @es5 {
				TargetException.throwNotSupported(@options.target, this)
			}
			else {
				@toSealedES6Fragments(fragments)
			}
		}
		else {
			if @es5 {
				TargetException.throwNotSupported(@options.target, this)
			}
			else if @hybrid {
				@toHybridES6Fragments(fragments)
			}
			else {
				@toContinousES6Fragments(fragments)
			}
		}

		for var variable of @staticVariables {
			variable.toFragments(fragments)
		}

		if !@es5 && ?@data.version {
			var mut line = fragments.newLine()

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
			for var {class, index}, name of @sharedMethods {
				var line = fragments.newLine()
				var block = line.code(`\(class.getSealedName())._im_\(name) = function(that, ...args)`).newBlock()

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
		var superVariable = @constructorScope.getVariable('super')

		if @hybrid && !@es5 {
			var thisVariable = @constructorScope.getVariable('this')

			thisVariable.replaceCall = (data, arguments, node) => CallHybridThisConstructorES6Substitude.new(data, arguments, @type, node)

			superVariable.replaceCall = (data, arguments, node) => CallHybridSuperConstructorES6Substitude.new(data, arguments, @type, node)
		}
		else {
			if @es5 {
				throw NotSupportedException.new()
			}
			else {
				superVariable.replaceCall = (data, arguments, node) => CallSuperConstructorSubstitude.new(data, arguments, @type, node)
			}
		}

		if @extendsType.isSealed() {
			superVariable.replaceMemberCall = (property, arguments, node) => MemberSealedSuperMethodSubstitude.new(property, arguments, @type, node)
		}
	} # }}}
	updateMethodScope(method) { # {{{
		if method.isInstance() {
			if @extending {
				var variable = method.scope().getVariable('super').setDeclaredType(@scope.reference(@extendsName))

				if @extendsType.isSealed() {
					variable.replaceCall = (data, arguments, node) => CallSealedSuperMethodSubstitude.new(data, arguments, method, @type)
					variable.replaceMemberCall = (property, arguments, node) => MemberSealedSuperMethodSubstitude.new(property, arguments, @type, node)
					variable.replaceContext = () => (fragments) => fragments.code('this')
				}
				else {
					variable.replaceCall = (data, arguments, node) => CallSuperMethodES6Substitude.new(data, arguments, method, @type)
				}
			}
		}
	} # }}}
	walk(fn) { # {{{
		fn(@name, @type)
	} # }}}
}

include {
	'./substitude.ks'
	'./variable.ks'
	'./constructor.ks'
	'./destructor.ks'
	'./method.ks'
	'./forked-method.ks'
	'./proxy.ks'
}
