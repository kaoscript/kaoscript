enum HelperTypeKind { // {{{
	Native
	Referenced
	Unreferenced
} // }}}

enum TypeStatus { // {{{
	Native
	Referenced
	Unreferenced
} // }}}

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
	static callMethod(node, variable, fnName, argName, retCode, fragments, method, index) { // {{{
		if method.max() == 0 && !method.isAsync() {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this)')
		}
		else {
			fragments.line(retCode, variable.name(), '.', fnName, index, '.apply(this, ', argName, ')')
		}
	} // }}}
	static isAssigningAlias(data, name, constructor, extending) { // {{{
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
	} // }}}
	static toWrongDoingFragments(block, ctrl?, argName, async, returns) { // {{{
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
	} // }}}
	constructor(data, parent, scope) { // {{{
		super(data, parent, scope)

		@constructorScope = this.newScope(@scope, ScopeType::Function)
		@destructorScope = this.newScope(@scope, ScopeType::Function)
		@instanceVariableScope = this.newScope(@scope, ScopeType::Function)
		@es5 = @options.format.classes == 'es5'
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@class = new ClassType(@scope)
		@type = new NamedType(@name, @class)

		@variable = @scope.define(@name, true, @type, this)

		let thisVariable = @constructorScope.define('this', true, @scope.reference(@name), true, this)

		thisVariable.replaceCall = (data, arguments) => new CallThisConstructorSubstitude(data, arguments, @type)

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
					const name = data.name.name

					declaration = new MacroDeclaration(data, this, null)

					if @macros[name] is Array {
						@macros[name].push(declaration)
					}
					else {
						@macros[name] = [declaration]
					}
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
	} // }}}
	prepare() { // {{{
		if @extending {
			@constructorScope.flagExtending()
			@instanceVariableScope.flagExtending()

			if @extendsType !?= Type.fromAST(@data.extends, this) {
				ReferenceException.throwNotDefined(@extendsName, this)
			}
			else if @extendsType.discardName() is not ClassType {
				TypeException.throwNotClass(@extendsName, this)
			}

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

				if @class.hasMatchingClassMethod(name, method.type(), MatchingMode::ExactParameters) {
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

				if @class.hasMatchingInstanceMethod(name, method.type(), MatchingMode::ExactParameters) {
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

				if @class.hasMatchingInstanceMethod(name, method.type(), MatchingMode::ExactParameters) {
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

				if @class.hasMatchingConstructor(constructor.type(), MatchingMode::ExactParameters) {
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

		for const macros of @macros {
			for const macro in macros {
				macro.export(this)
			}
		}
	} // }}}
	translate() { // {{{
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
					if variable.isRequiringInitialization() && !variable.isAlien() && !variable.isAlteration() {
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
	} // }}}
	addSharedMethod(name: String, sealedclass: NamedType): Void { // {{{
		if !?@sharedMethods[name] {
			@sharedMethods[name] = {
				class: sealedclass
				index: sealedclass.type().incSharedMethod(name)
			}
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	exportMacro(name, macro) { // {{{
		@parent.exportMacro(`\(@name).\(name)`, macro)
	} // }}}
	extends() => @extendsType
	flagForcefullyRebinded() { // {{{
		@forcefullyRebinded = true
	} // }}}
	getClassVariable(name: String) => @classVariables[name]
	getInstanceVariable(name: String) => @instanceVariables[name]
	hasConstructors() => @constructors.length != 0
	isAbstract() => @abstract
	isExtending() => @extending
	isHybrid() => @hybrid
	name() => @name
	newInstanceMethodScope(method: ClassMethodDeclaration) { // {{{
		const scope = this.newScope(@scope, ScopeType::Function)

		scope.define('this', true, @scope.reference(@name), true, this)

		if @extending {
			scope.flagExtending()

			scope.define('super', true, @scope.reference(@extendsName), true, this)
		}

		return scope
	} // }}}
	registerMacro(name, macro) { // {{{
		@scope.addMacro(name, macro)

		@parent.registerMacro(`\(@name).\(name)`, macro)
	} // }}}
	toContinousES5Fragments(fragments) { // {{{
		this.module().flag('Helper')

		const line = fragments.newLine().code($runtime.scope(this), @name, ' = ', $runtime.helper(this), '.class(')
		const clazz = line.newObject()

		clazz.line('$name: ' + $quote(@name))

		if @data.version? {
			clazz.line(`$version: [\(@data.version.major), \(@data.version.minor), \(@data.version.patch)]`)
		}

		if @extending {
			clazz.line('$extends: ', @extendsName)
		}

		const m = []

		let ctrl
		if @destructor? || !Dictionary.isEmpty(@classMethods) {
			ctrl = clazz.newLine().code('$static: ').newObject()

			if @destructor? {
				@destructor.toFragments(ctrl, Mode::None)

				ClassDestructorDeclaration.toRouterFragments(this, ctrl, @type)
			}

			for const methods, name of @classMethods {
				m.clear()

				for method in methods {
					method.toFragments(ctrl, Mode::None)

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

				ClassMethodDeclaration.toClassSwitchFragments(this, ctrl.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
			}

			ctrl.done()
		}

		if !@extending || @extendsType.isSealedAlien() {
			clazz
				.newControl()
				.code('$create: function()')
				.step()
				.line('this.__ks_init()')
				.line('this.__ks_cons(arguments)')
		}

		if @inits {
			ctrl = clazz
				.newControl()
				.code(`__ks_init_\(@initsId): function()`)
				.step()

			for const field of @instanceVariables {
				field.toFragments(ctrl)
			}

			ctrl = clazz.newControl().code('__ks_init: function()').step()

			if @extending && !@extendsType.isSealedAlien() {
				ctrl.line(@extendsName + '.prototype.__ks_init.call(this)')
			}

			ctrl.line(`\(@name).prototype.__ks_init_\(@initsId).call(this)`)
		}
		else {
			if @extending {
				if @extendsType.isSealedAlien() {
					clazz
						.newControl()
						.code('__ks_init: function()')
						.step()
				}
				else {
					clazz
						.newControl()
						.code('__ks_init: function()')
						.step()
						.line(@extendsName + '.prototype.__ks_init.call(this)')
				}
			}
			else {
				clazz.newControl().code('__ks_init: function()').step()
			}
		}

		m.clear()

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toRouterFragments(this, clazz.newControl(), @type, m, func(node, fragments) => fragments.code('__ks_cons: function(args)').step(), func(fragments) {})

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

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
		}

		clazz.done()
		line.code(')').done()
	} // }}}
	toContinousES6Fragments(fragments) { // {{{
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

		let ctrl
		if !@extending {
			clazz
				.newControl()
				.code('constructor()')
				.step()
				.line('this.__ks_init()')
				.line('this.__ks_cons(arguments)')
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

			ctrl = clazz.newControl().code('__ks_init()').step()

			if @extending && !@extendsType.isSealedAlien() {
				ctrl.line(@extendsName + '.prototype.__ks_init.call(this)')
			}

			ctrl.line(`\(@name).prototype.__ks_init_\(@initsId).call(this)`)

			ctrl.done()
		}
		else {
			if @extending {
				clazz
					.newControl()
					.code('__ks_init()')
					.step()
					.line(@extendsName + '.prototype.__ks_init.call(this)')
					.done()
			}
			else {
				clazz.newControl().code('__ks_init()').step().done()
			}
		}

		const m = []

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toRouterFragments(this, clazz.newControl(), @type, m, func(node, fragments) => fragments.code('__ks_cons(args)').step(), func(fragments) {
			fragments.done()
		})

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

			for const method in methods {
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

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
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

			ClassMethodDeclaration.toClassSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()

		if @forcefullyRebinded {
			root.done()
		}
	} // }}}
	toHybridES6Fragments(fragments) { // {{{
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

			const line = ctrl
				.newLine()
				.code('const __ks_cons = (__ks_arguments) =>')

			const assessment = Router.assess(m, false, 'constructor', this)

			Router.toFragments(
				assessment
				line.newBlock()
				'__ks_arguments'
				false
				func(node, fragments) => fragments
				func(fragments) {
					fragments.done()
				}
				(fragments, method, index) => {
					fragments.line(`__ks_cons_\(index)(__ks_arguments)`)
				}
				ClassDeclaration.toWrongDoingFragments
				this
			)

			line.done()

			ctrl
				.line('__ks_cons(arguments)')
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

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
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

			ClassMethodDeclaration.toClassSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()
	} // }}}
	toSealedES5Fragments(fragments) { // {{{
		@module().flag('Helper')

		const line = fragments.newLine().code($runtime.scope(this), @name, ' = ', $runtime.helper(this), '.class(')
		const clazz = line.newObject()

		clazz.line('$name: ' + $quote(@name))

		if @data.version? {
			clazz.line(`$version: [\(@data.version.major), \(@data.version.minor), \(@data.version.patch)]`)
		}

		if @extending {
			clazz.line('$extends: ', @extendsName)
		}

		const m = []

		let ctrl
		if @destructor? || !Dictionary.isEmpty(@classMethods) {
			ctrl = clazz.newLine().code('$static: ').newObject()

			if @destructor? {
				@destructor.toFragments(ctrl, Mode::None)

				ClassDestructorDeclaration.toRouterFragments(this, ctrl, @type)
			}

			for const methods, name of @classMethods {
				m.clear()

				for method in methods {
					method.toFragments(ctrl, Mode::None)

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

				ClassMethodDeclaration.toClassSwitchFragments(this, ctrl.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
			}

			ctrl.done()
		}

		if @extending && !@extendsType.isSealedAlien() {
			ctrl = clazz
				.newControl()
				.code('__ks_init: function()')
				.step()

			ctrl.line(@extendsName, '.prototype.__ks_init.call(this)')

			if @inits {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}
		}
		else {
			ctrl = clazz
				.newControl()
				.code('$create: function()')
				.step()

			if @inits {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}

			ctrl.line('this.__ks_cons(arguments)')
		}

		m.clear()

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toRouterFragments(this, clazz.newControl(), @type, m, (node, fragments) => fragments.code('__ks_cons: function(args)').step(), func(fragments) {})

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

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`\(name): function()`).step(), func(fragments) {})
		}

		clazz.done()
		line.code(')').done()
	} // }}}
	toSealedES6Fragments(fragments) { // {{{
		const clazz = fragments
			.newControl()
			.code('class ', @name)

		if @extending {
			clazz.code(' extends ', @extendsName)
		}

		clazz.step()

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

			if @inits {
				for const field of @instanceVariables {
					field.toFragments(ctrl)
				}
			}

			ctrl.line('this.__ks_cons(arguments)')

			ctrl.done()
		}

		const m = []

		for method in @constructors {
			method.toFragments(clazz, Mode::None)

			m.push(method.type())
		}

		ClassConstructorDeclaration.toRouterFragments(this, clazz.newControl(), @type, m, (node, fragments) => fragments.code('__ks_cons(args)').step(), func(fragments) {
			fragments.done()
		})

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

			ClassMethodDeclaration.toInstanceSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`\(name)()`).step(), func(fragments) {
				fragments.done()
			})
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

			ClassMethodDeclaration.toClassSwitchFragments(this, clazz.newControl(), @type, m, overflow, name, (node, fragments) => fragments.code(`static \(name)()`).step(), func(fragments) {
				fragments.done()
			})
		}

		clazz.done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @sealed {
			if @es5 {
				this.toSealedES5Fragments(fragments)
			}
			else {
				this.toSealedES6Fragments(fragments)
			}
		}
		else {
			if @es5 {
				this.toContinousES5Fragments(fragments)
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
			fragments.line(`var \(@type.getSealedName()) = {}`)
		}
		else {
			for const {class, index}, name of @sharedMethods {
				fragments.line(`\(class.getSealedName())._im_\(index)_\(name) = \(class.getSealedName())._im_\(name)`)

				const line = fragments.newLine()
				const block = line.code(`\(class.getSealedName())._im_\(name) = function(that)`).newBlock()

				const condition = block.newControl()

				condition.code('if(', $runtime.type(this), '.isClassInstance(that, ', @name, '))').step()

				condition.line(`return that.\(name).apply(that, Array.prototype.slice.call(arguments, 1, arguments.length))`)

				condition.step().code('else').step()

				condition.line(`return \(class.getSealedName())._im_\(index)_\(name).apply(null, arguments)`)

				condition.done()

				block.done()
				line.done()
			}
		}
	} // }}}
	type() => @type
	updateConstructorScope() { // {{{
		const superVariable = @constructorScope.getVariable('super')

		if @hybrid && !@es5 {
			const thisVariable = @constructorScope.getVariable('this')

			thisVariable.replaceCall = (data, arguments) => new CallHybridThisConstructorES6Substitude(data, arguments, @type)

			superVariable.replaceCall = (data, arguments) => new CallHybridSuperConstructorES6Substitude(data, arguments, @type)
		}
		else {
			if @es5 {
				superVariable.replaceCall = (data, arguments) => new CallSuperConstructorES5Substitude(data, arguments, @type)

				superVariable.replaceMemberCall = (property, arguments, node) => new MemberSuperMethodES5Substitude(property, arguments, @type, node)
			}
			else {
				superVariable.replaceCall = (data, arguments) => new CallSuperConstructorSubstitude(data, arguments, @type)
			}
		}

		if @extendsType.isSealed() {
			superVariable.replaceMemberCall = (property, arguments, node) => new MemberSealedSuperMethodSubstitude(property, arguments, @type, node)
		}
	} // }}}
	updateMethodScope(method) { // {{{
		if @extending {
			const variable = method.scope().getVariable('super').setDeclaredType(@scope.reference(@extendsName))

			if @extendsType.isSealed() {
				variable.replaceCall = (data, arguments) => new CallSealedSuperMethodSubstitude(data, arguments, method, @type)

				variable.replaceMemberCall = (property, arguments, node) => new MemberSealedSuperMethodSubstitude(property, arguments, @type, node)
			}
			else if @es5 {
				variable.replaceCall = (data, arguments) => new CallSuperMethodES5Substitude(data, arguments, method, @type)

				variable.replaceMemberCall = (property, arguments, node) => new MemberSuperMethodES5Substitude(property, arguments, @type, node)
			}
			else {
				variable.replaceCall = (data, arguments) => new CallSuperMethodES6Substitude(data, arguments, method, @type)
			}
		}
	} // }}}
	walk(fn) { // {{{
		fn(@name, @type)
	} // }}}
}

class CallThisConstructorSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
	}
	constructor(@data, @arguments, @class)
	isInitializingInstanceVariable(name) { // {{{
		if const constructor = @class.type().getConstructor(@arguments) {
			return constructor.isInitializingInstanceVariable(name)
		}
		else {
			return false
		}
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.path()).prototype.__ks_cons.call(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
	type() => Type.Void
}

class CallHybridThisConstructorES6Substitude extends CallThisConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		fragments.code(`__ks_cons([`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
}

class CallSuperConstructorSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
	}
	constructor(@data, @arguments, @class)
	isInitializingInstanceVariable(name) { // {{{
		if const constructor = @class.type().extends().type().getConstructor(@arguments) {
			return constructor.isInitializingInstanceVariable(name)
		}
		else {
			return false
		}
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons.call(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
	type() => Type.Void
}

class CallSuperConstructorES5Substitude extends CallSuperConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		if @class.type().extends().isAlien() {
			if @arguments.length == 0 {
				fragments.code('(1')
			}
			else {
				throw new NotSupportedException()
			}
		}
		else {
			fragments.code(`\(@class.type().extends().path()).prototype.__ks_cons.call(this, [`)

			for argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}

			fragments.code(']')
		}
	} // }}}
}

class CallHybridSuperConstructorES6Substitude extends CallSuperConstructorSubstitude {
	toFragments(fragments, mode) { // {{{
		fragments.code(`super(`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}
	} // }}}
}

class CallSuperMethodES5Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_method: ClassMethodDeclaration
	}
	constructor(@data, @arguments, @method, @class)
	isInitializingInstanceVariable(name) => @method.type().isInitializingInstanceVariable(name)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.type().extends().path()).prototype.\(@method.name()).apply(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
	type() => @method.type().getReturnType()
}

class CallSuperMethodES6Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_data
		_method: ClassMethodDeclaration
	}
	constructor(@data, @arguments, @method, @class)
	isInitializingInstanceVariable(name) => @method.type().isInitializingInstanceVariable(name)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`super.\(@method.name())(`)

		for const argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}
	} // }}}
	type() => @method.type().getReturnType()
}

class CallSealedSuperMethodSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_extendsType: NamedType<ClassType>
		_data
		_method: ClassMethodDeclaration
		_property: String
		_sealed: Boolean					= false
	}
	constructor(@data, @arguments, @method, @class) { // {{{
		@extendsType = @class.type().extends()
		@property = @method.name()

		if const property = @extendsType.type().getInstanceProperty(@property) {
			@sealed = property.isSealed()
		}
	} // }}}
	isInitializingInstanceVariable(name) => @method.type().isInitializingInstanceVariable(name)
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		if @sealed {
			fragments.code(`\(@extendsType.getSealedPath())._im_\(@property)(this`)

			for const argument in @arguments {
				fragments.code($comma).compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@property)(`)

			for const argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
	} // }}}
	type() => @method.type().getReturnType()
}

class MemberSuperMethodES5Substitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_property: String
	}
	constructor(@property, @arguments, @class, node) { // {{{
		const superClass = @class.type().extends().type()

		if const property = superClass.getInstanceProperty(@property) {
		}
		else if !(superClass.isAlien() || superClass.isHybrid()) {
			ReferenceException.throwNotDefinedProperty(@property, node)
		}
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		fragments.code(`\(@class.discardName().extends().name()).prototype.\(@property).apply(this, [`)

		for argument, index in @arguments {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(argument)
		}

		fragments.code(']')
	} // }}}
}

class MemberSealedSuperMethodSubstitude {
	private {
		_arguments
		_class: NamedType<ClassType>
		_extendsType: NamedType<ClassType>
		_property: String
		_sealed: Boolean					= false
	}
	constructor(@property, @arguments, @class, node) { // {{{
		@extendsType = @class.type().extends()

		if const property = @extendsType.type().getInstanceProperty(@property) {
			@sealed = property.isSealed()
		}
	} // }}}
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		if @sealed {
			if const index = @extendsType.type().getSharedMethodIndex(@property) {
				fragments.code(`\(@extendsType.getSealedPath())._im_\(index)_\(@property)(this`)
			}
			else {
				fragments.code(`\(@extendsType.getSealedPath())._im_\(@property)(this`)
			}

			for const argument in @arguments {
				fragments.code($comma).compile(argument)
			}
		}
		else {
			fragments.code(`super.\(@property)(`)

			for const argument, index in @arguments {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(argument)
			}
		}
	} // }}}
}

class ClassMethodDeclaration extends Statement {
	private lateinit {
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
		_exit: Boolean						= false
		_indigentValues: Array				= []
		_instance: Boolean					= true
		_name: String
		_override: Boolean					= false
		_parameters: Array<Parameter>		= []
		_returnNull: Boolean				= false
		_topNodes: Array					= []
	}
	static toClassSwitchFragments(node, fragments, variable, methods, overflow, name, header, footer) { // {{{
		const assessment = Router.assess(methods, false, name, node, overflow)

		if variable.type().isExtending() {
			return Router.toFragments(
				assessment
				fragments
				'arguments'
				true
				header
				footer
				ClassDeclaration.callMethod^^(node, variable, `__ks_sttc_\(name)_`, 'arguments', 'return ')
				(block, ctrl?, argName, async, returns) => {
					const extends = variable.type().extends()
					const parent = extends.name()

					if extends.type().hasClassMethod(name) {
						ctrl.done()

						block.line(`return \(parent).\(name).apply(null, arguments)`)
					}
					else {
						ctrl
							.step()
							.code(`else if(\(parent).\(name))`)
							.step()
							.line(`return \(parent).\(name).apply(null, arguments)`)
							.done()

						block.line('throw new SyntaxError("Wrong number of arguments")')
					}
				}
				node
			)
		}
		else {
			return Router.toFragments(
				assessment
				fragments
				'arguments'
				true
				header
				footer
				ClassDeclaration.callMethod^^(node, variable, `__ks_sttc_\(name)_`, 'arguments', 'return ')
				ClassDeclaration.toWrongDoingFragments
				node
			)
		}
	} // }}}
	static toInstanceSwitchFragments(node, fragments, variable, methods, overflow, name, header, footer) { // {{{
		const assessment = Router.assess(methods, false, name, node, overflow)

		if variable.type().isExtending() {
			return Router.toFragments(
				assessment
				fragments
				'arguments'
				true
				header
				footer
				ClassDeclaration.callMethod^^(node, variable, `prototype.__ks_func_\(name)_`, 'arguments', 'return ')
				(block, ctrl?, argName, async, returns) => {
					const extends = variable.type().extends()
					const parent = extends.name()

					if extends.type().hasInstanceMethod(name) {
						ctrl.done()

						block.line(`return \(parent).prototype.\(name).apply(this, arguments)`)
					}
					else {
						ctrl
							.step()
							.code(`else if(\(parent).prototype.\(name))`)
							.step()
							.line(`return \(parent).prototype.\(name).apply(this, arguments)`)
							.done()

						block.line('throw new SyntaxError("Wrong number of arguments")')
					}
				}
				node
			)
		}
		else {
			return Router.toFragments(
				assessment
				fragments
				'arguments'
				true
				header
				footer
				ClassDeclaration.callMethod^^(node, variable, `prototype.__ks_func_\(name)_`, 'arguments', 'return ')
				ClassDeclaration.toWrongDoingFragments
				node
			)
		}
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newInstanceMethodScope(this))

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
						@internalName = `__ks_func_\(@name)_\(parent._abstractMethods[@name].length)`

						parent._abstractMethods[@name].push(this)
					}
					else {
						@internalName = `__ks_func_\(@name)_0`

						parent._abstractMethods[@name] = [this]
					}
				}
				else {
					SyntaxException.throwNotAbstractClass(parent._name, @name, parent)
				}
			}
			else {
				if parent._instanceMethods[@name] is Array {
					@internalName = `__ks_func_\(@name)_\(parent._instanceMethods[@name].length)`

					parent._instanceMethods[@name].push(this)
				}
				else {
					@internalName = `__ks_func_\(@name)_0`

					parent._instanceMethods[@name] = [this]
				}
			}
		}
		else if @name == 'name' || @name == 'version' {
			SyntaxException.throwReservedClassMethod(@name, parent)
		}
		else {
			if parent._classMethods[@name] is Array {
				@internalName = `__ks_sttc_\(@name)_\(parent._classMethods[@name].length)`

				parent._classMethods[@name].push(this)
			}
			else {
				@internalName = `__ks_sttc_\(@name)_0`

				parent._classMethods[@name] = [this]
			}
		}
	} // }}}
	analyse() { // {{{
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		if @data.body? {
			@returnNull = @data.body.kind == NodeKind::IfStatement || @data.body.kind == NodeKind::UnlessStatement
		}

		@block = new MethodBlock($ast.block($ast.body(@data)), this, @scope)
	} // }}}
	prepare() { // {{{
		return if @analysed

		@parent.updateMethodScope(this)

		for const parameter in @parameters {
			parameter.prepare()
		}

		if @override {
			unless @parent.isExtending() {
				SyntaxException.throwNoOverridableMethod(@parent.type(), @name, @parameters, this)
			}

			const superclass = @parent.extends().type()

			if const method = superclass.getInstantiableMethod(@name, @parameters) {
				if method.isSealed() {
					@type = method.clone()
				}
				else {
					@type = method
				}

				const parameters = @type.parameters()

				for const parameter, index in @parameters {
					parameter.type(parameters[index])
				}
			}
			else if this.isAssertingOverride() {
				SyntaxException.throwNoOverridableMethod(@parent.extends(), @name, @parameters, this)
			}
			else {
				@override = false
			}

			if @override {
				if const sealedclass = superclass.getHybridMethod(@name, @parent.extends()) {
					@parent.addSharedMethod(@name, sealedclass)
				}
			}
		}

		if !@override {
			const arguments = [parameter.type() for const parameter in @parameters]

			@type = new ClassMethodType(arguments, @data, this)

			if @parent.isExtending() {
				const superclass = @parent.extends().type()

				if const method = superclass.getInstantiableMethod(@name, @parameters) {
					if @data.type? {
						if !@type.getReturnType().isInstanceOf(method.getReturnType()) {
							SyntaxException.throwInvalidMethodReturn(@parent.name(), @name, this)
						}
					}
					else {
						@type.setReturnType(method.getReturnType())
					}
				}

				if const sealedclass = superclass.getHybridMethod(@name, @parent.extends()) {
					@parent.addSharedMethod(@name, sealedclass)
				}
			}
		}

		for const alias in @aliases {
			@type.addInitializingInstanceVariable(alias.getVariableName())
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

		@analysed = true
	} // }}}
	translate() { // {{{
		for const parameter in @parameters {
			parameter.translate()
		}

		for const {value} in @indigentValues {
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
	} // }}}
	addAtThisParameter(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@block.statements(), statement.name(), false, false) {
			@aliases.push(statement)
		}
	} // }}}
	addIndigentValue(value: Expression, parameters) { // {{{
		const class = @parent.type().type()
		const name = `__ks_default_\(class.level())_\(class.incDefaultSequence())`

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
	getFunctionNode() => this
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	isAbstract() => @abstract
	isAssertingOverride() => @options.rules.assertOverride
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstance() => @instance
	isInstanceMethod() => @instance
	isOverridableFunction() => true
	length() => @parameters.length
	name() => @name
	parameters() => @parameters
	toIndigentFragments(fragments) { // {{{
		for const {name, value, parameters} in @indigentValues {
			const ctrl = fragments.newControl()

			if @parent._es5 {
				ctrl.code(`\(name): function(\(parameters.join(', ')))`).step()
			}
			else {
				ctrl.code(`\(name)(\(parameters.join(', ')))`).step()
			}

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done() unless @parent._es5
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const ctrl = fragments.newControl()

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

		for const node in @topNodes {
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
	} // }}}
	type() { // {{{
		if @analysed {
			return @type
		}
		else {
			this.prepare()

			return @type
		}
	} // }}}
}

class ClassConstructorDeclaration extends Statement {
	private lateinit {
		_block: Block
		_parameters: Array<Parameter>
		_type: ClassConstructorType
	}
	private {
		_aliases: Array						= []
		_abstract: Boolean
		_indigentValues: Array				= []
		_internalName: String
		_override: Boolean					= false
		_topNodes: Array					= []
	}
	static toRouterFragments(node, fragments, variable, methods, header, footer) { // {{{
		const assessment = Router.assess(methods, false, 'constructor', node)

		if node.isExtending() {
			return Router.toFragments(
				assessment
				fragments
				'args'
				false
				header
				footer
				ClassDeclaration.callMethod^^(node, variable, 'prototype.__ks_cons_', 'args', '')
				(block, ctrl?, argName, async, returns) => {
					if variable.type().hasConstructors() {
						ctrl
							.step()
							.code('else')
							.step()
							.line(`throw new SyntaxError("Wrong number of arguments")`)
							.done()
					}
					else {
						const constructorName = variable.type().extends().isSealedAlien() ? 'constructor' : '__ks_cons'

						block.line(`\(variable.type().extends().path()).prototype.\(constructorName).call(this, args)`)
					}
				}
				node
			)

		}
		else {
			return Router.toFragments(
				assessment
				fragments
				'args'
				false
				header
				footer
				ClassDeclaration.callMethod^^(node, variable, 'prototype.__ks_cons_', 'args', '')
				ClassDeclaration.toWrongDoingFragments
				node
			)
		}
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope(parent._constructorScope, ScopeType::Block))

		@internalName = `__ks_cons_\(parent._constructors.length)`

		@abstract = parent.isAbstract()

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Override {
				@override = true
			}
		}

		parent._constructors.push(this)
	} // }}}
	analyse() { // {{{
		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@block = new ConstructorBlock($ast.block($ast.body(@data)), this, @scope)
	} // }}}
	prepare() { // {{{
		for const parameter in @parameters {
			parameter.prepare()
		}

		if @override {
			unless @parent.isExtending() {
				SyntaxException.throwNoOverridableConstructor(@parent.type(), @parameters, this)
			}

			const superclass = @parent.extends().type()

			if const method = superclass.getConstructor(@parameters) {
				if method.isSealed() {
					@type = method.clone()
				}
				else {
					@type = method
				}

				const parameters = @type.parameters()

				for const parameter, index in @parameters {
					parameter.type(parameters[index])
				}
			}
			else {
				SyntaxException.throwNoOverridableConstructor(@parent.extends(), @parameters, this)
			}

			if const sealedclass = superclass.getHybridConstructor(@parent.extends()) {
				@parent.addSharedConstructor(sealedclass)
			}
		}
		else {
			@type = new ClassConstructorType([parameter.type() for const parameter in @parameters], @data, this)
		}

		let index = 1
		if @block.isEmpty() {
			if @parent._extending {
				this.addCallToParentConstructor()

				index = 0
			}
		}
		else if (index = this.getConstructorIndex(@block.statements())) == -1 && @parent._extending {
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

		const class = @parent.type().type()

		for const statement in @aliases {
			const name = statement.getVariableName()

			if const variable = class.getInstanceVariable(name) {
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

		for const {value} in @indigentValues {
			value.prepare()
			value.translate()
		}

		@block.prepare()
		@block.translate()
	} // }}}
	addAtThisParameter(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@block.statements(), statement.name(), true, @parent._extending) {
			@aliases.push(statement)
		}
	} // }}}
	private addCallToParentConstructor() { // {{{
		// only add call if parent has an empty constructor
		const extendsType = @parent.extends().type()

		if extendsType.matchArguments([]) {
			if extendsType.hasConstructors() || extendsType.isSealed() {
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
	addIndigentValue(value: Expression, parameters) { // {{{
		const class = @parent.type().type()
		const name = `__ks_default_\(class.level())_\(class.incDefaultSequence())`

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
	checkVariableInitialization(name) { // {{{
		if @block.isInitializingInstanceVariable(name) {
			@type.addInitializingInstanceVariable(name)
		}
		else if !@abstract {
			SyntaxException.throwNotInitializedField(name, this)
		}
	} // }}}
	private getConstructorIndex(body: Array) { // {{{
		for statement, index in body {
			if statement.kind == NodeKind::CallExpression {
				if statement.callee.kind == NodeKind::Identifier && (statement.callee.name == 'this' || statement.callee.name == 'super') {
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
	getFunctionNode() => this
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	private getSuperIndex(body: Array) { // {{{
		for statement, index in body {
			if statement.kind == NodeKind::CallExpression {
				if statement.callee.kind == NodeKind::Identifier && statement.callee.name == 'super' {
					return index
				}
			}
			else if statement.kind == NodeKind::IfStatement {
				if statement.whenFalse? && this.getSuperIndex(statement.whenTrue.statements) != -1 && this.getSuperIndex(statement.whenFalse.statements) != -1 {
					return index
				}
			}
		}

		return -1
	} // }}}
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}

		return false
	} // }}}
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => true
	isOverridableFunction() => true
	parameters() => @parameters
	toHybridConstructorFragments(fragments) { // {{{
		let ctrl = fragments
			.newControl()
			.code('constructor(')

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
			return node.code(')').step()
		})

		if @parent._extendsType.isSealedAlien() {
			const index = this.getSuperIndex(@block.statements())

			if index == -1 {
				ctrl.line('super()')
				ctrl.line('this.constructor.prototype.__ks_init()')

				ctrl.compile(@block)
			}
			else {
				@block.toRangeFragments(ctrl, 0, index)

				ctrl.line('this.constructor.prototype.__ks_init()')

				@block.toRangeFragments(ctrl, index + 1)
			}
		}
		else {
			ctrl.compile(@block)
		}

		ctrl.done()
	} // }}}
	toIndigentFragments(fragments) { // {{{
		for const {name, value, parameters} in @indigentValues {
			const ctrl = fragments.newControl()

			if @parent._es5 {
				ctrl.code(`\(name): function(\(parameters.join(', ')))`).step()
			}
			else {
				ctrl.code(`\(name)(\(parameters.join(', ')))`).step()
			}

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done() unless @parent._es5
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if !@parent._es5 && @parent.isHybrid() {
			const ctrl = fragments
				.newLine()
				.code(`const \(@internalName) = (`)

			const block = Parameter.toFragments(this, ctrl, ParameterMode::HybridConstructor, func(node) {
				return node.code(') =>').newBlock()
			})

			const index = this.getSuperIndex(@block.statements())

			if index == -1 {
				block.compile(@block)
			}
			else {
				@block.toRangeFragments(block, 0, index)

				if @parent.extends().isSealed() {
					block.line('this.__ks_init()')
				}

				@block.toRangeFragments(block, index + 1)
			}

			block.done()
			ctrl.done()
		}
		else {
			let ctrl = fragments.newControl()

			if @parent._es5 {
				ctrl.code(`\(@internalName): function(`)
			}
			else {
				ctrl.code(`\(@internalName)(`)
			}

			Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
				return node.code(')').step()
			})

			for const node in @topNodes {
				node.toAuthorityFragments(ctrl)
			}

			ctrl.compile(@block)

			ctrl.done() unless @parent._es5
		}

		this.toIndigentFragments(fragments)
	} // }}}
	type() => @type
}

class ClassDestructorDeclaration extends Statement {
	private lateinit {
		_block: Block
		_parameters: Array
		_type: Type
	}
	private {
		_internalName: String
	}
	static toRouterFragments(node, fragments, variable) { // {{{
		let ctrl = fragments.newControl()

		if node._es5 {
			ctrl.code('__ks_destroy: function(that)')
		}
		else {
			ctrl.code('static __ks_destroy(that)')
		}

		ctrl.step()

		if node._extending {
			ctrl.line(`\(node._extendsName).__ks_destroy(that)`)
		}

		for i from 0 til variable.type().getConstructorCount() {
			ctrl.line(`\(node._name).__ks_destroy_\(i)(that)`)
		}

		ctrl.done() unless node._es5
	} // }}}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope(parent._destructorScope, ScopeType::Block))

		@internalName = `__ks_destroy_0`

		parent._destructor = this
	} // }}}
	analyse() { // {{{
		const parameter = new Parameter({
			kind: NodeKind::Parameter
			modifiers: []
			name: $ast.identifier('that')
		}, this)

		parameter.analyse()

		@parameters = [parameter]
	} // }}}
	prepare() { // {{{
		@parameters[0].prepare()

		@type = new ClassDestructorType(@data, this)
	} // }}}
	translate() { // {{{
		@block = $compile.function($ast.body(@data), this)
		@block.analyse()
		@block.prepare()
		@block.translate()
	} // }}}
	getFunctionNode() => this
	getParameterOffset() => 0
	isAbstract() { // {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}

		return false
	} // }}}
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isInstance() => false
	isInstanceMethod() => true
	isOverridableFunction() => false
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()

		if @parent._es5 {
			ctrl.code(`\(@internalName): function(`)
		}
		else {
			ctrl.code(`static \(@internalName)(`)
		}

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
			return node.code(')').step()
		})

		ctrl.compile(@block)

		ctrl.done() unless @parent._es5
	} // }}}
	type() => @type
}

class ClassVariableDeclaration extends AbstractNode {
	private lateinit {
		_type: ClassVariableType
	}
	private {
		_autoTyping: Boolean		= false
		_defaultValue: Boolean		= false
		_immutable: Boolean			= false
		_instance: Boolean			= true
		_initialized: Boolean		= true
		_lateInit: Boolean			= false
		_name: String
		_value						= null
	}
	constructor(data, parent) { // {{{
		super(data, parent)

		@name = data.name.name

		let public = false
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
				ModifierKind::Public => {
					public = true
				}
				ModifierKind::Static => {
					@instance = false
				}
				ModifierKind::ThisAlias => {
					alias = true
				}
			}
		}

		if alias && !public {
			@name = `_\(@name)`
		}

		if @instance {
			parent._instanceVariables[@name] = this
		}
		else if @name == 'name' || @name == 'version' {
			SyntaxException.throwReservedClassVariable(@name, parent)
		}
		else {
			parent._classVariables[@name] = this
		}
	} // }}}
	analyse() { // {{{
		if @data.value? {
			@defaultValue = true
			@lateInit = false

			if !@instance {
				@value = $compile.expression(@data.value, this)
				@value.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		if @parent.isExtending() {
			const type = @parent._extendsType.type()

			if @instance {
				if type.hasInstanceVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
			else {
				if type.hasClassVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
		}

		@type = ClassVariableType.fromAST(@data, this)

		if @defaultValue {
			if @instance {
				@value = $compile.expression(@data.value, this, @parent._instanceVariableScope)
				@value.analyse()
			}

			if @autoTyping {
				@type.type(@value.type())
			}
			else if @data.value.kind == NodeKind::Identifier && @data.value.name == 'null' {
				@type.flagNullable()
			}
		}
		else {
			if @type.isRequiringInitialization() {
				@initialized = false
			}
		}
	} // }}}
	translate() { // {{{
		if @defaultValue {
			@value.prepare()

			if !@value.isMatchingType(@type.type()) {
				TypeException.throwInvalidAssignement(@name, @type, @value.type(), this)
			}

			@value.translate()
		}
	} // }}}
	hasDefaultValue() => @defaultValue
	initialize(type, node) { // {{{
		if !@initialized {
			@initialized = true

			if @autoTyping {
				@type.type(type)
			}
		}
	} // }}}
	isImmutable() => @immutable
	isInitialized() => @initialized
	isInstance() => @instance
	isLateInit() => @lateInit
	isRequiringInitialization() => @type.isRequiringInitialization()
	name() => @name
	toFragments(fragments) { // {{{
		if @defaultValue {
			if @instance {
				fragments
					.newLine()
					.code(`this.\(@name) = `)
					.compile(@value)
					.done()
			}
			else {
				fragments
					.newLine()
					.code(`\(@parent.name()).\(@name) = `)
					.compile(@value)
					.done()
			}
		}
	} // }}}
	type() => @type
}