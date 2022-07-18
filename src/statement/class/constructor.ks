class ClassConstructorDeclaration extends Statement {
	private lateinit {
		_block: Block
		_internalName: String
		_parameters: Array<Parameter>
		_type: ClassConstructorType
	}
	private {
		_aliases: Array							= []
		_abstract: Boolean
		_forked: Boolean						= false
		_forks: Array<ClassConstructorType>?	= null
		_hiddenOverride: Boolean				= false
		_indigentValues: Array					= []
		_override: Boolean						= false
		_overriding: Boolean					= false
		_topNodes: Array						= []
	}
	static toCreatorFragments(class, constructor, fragments) { # {{{
		const ctrl = fragments.newControl()

		const args = constructor.max() == 0 ? '' : '...args'
		const block = ctrl.code(`static __ks_new_\(constructor.index())(\(args))`).step()

		block
			.line(`const o = Object.create(\(class.name()).prototype)`)
			.line('o.__ks_init()')
			.line(`o.__ks_cons_\(constructor.index())(\(args))`)
			.line('return o')

		ctrl.done()
	} # }}}
	static toRouterFragments(node, fragments, variable, methods, scope: String?, header, footer) { # {{{
		const name = variable.name()

		const assessment = Router.assess(methods, 'constructor', node)

		header(node, fragments)

		if node.isExtending() {
			Router.toFragments(
				(function, line) => {
					line.code(`\(name).prototype.__ks_cons_\(function.index()).call(\(scope ?? 'that')`)

					return true
				}
				null
				assessment
				fragments.block()
				variable.type().hasConstructors() ? Router.FooterType::MUST_THROW : Router.FooterType::NO_THROW
				(fragments, _) => {
					const constructorName = variable.type().extends().isSealedAlien() ? 'constructor' : '__ks_cons_rt'

					fragments.line(`super.\(constructorName).call(null, that, args)`)
				}
				node
			)
		}
		else {
			Router.toFragments(
				(function, line) => {
					line.code(`\(name).prototype.__ks_cons_\(function.index()).call(\(scope ?? 'that')`)

					return true
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
		super(data, parent, parent.newScope(parent._constructorScope, ScopeType::Block))

		@abstract = parent.isAbstract()

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Override {
				@override = true
			}
		}

		parent._constructors.push(this)
	} # }}}
	analyse() { # {{{
		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@block = new ConstructorBlock($ast.block($ast.body(@data)), this, @scope)
	} # }}}
	prepare() { # {{{
		for const parameter in @parameters {
			parameter.prepare()
		}

		@type = new ClassConstructorType([parameter.type() for const parameter in @parameters], @data, this)

		let overridden

		if @parent.isExtending() {
			const superclass = @parent.extends().type()

			if const data = @getOveriddenConstructor(superclass) {
				{ method: overridden, type: @type } = data

				@overriding = true

				unless superclass.isAbstract() {
					@hiddenOverride = true
				}
			}
		}
		else if @override {
			SyntaxException.throwNoOverridableConstructor(@parent.type(), @parameters, this)
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
	} # }}}
	translate() { # {{{
		for parameter in @parameters {
			parameter.translate()
		}

		for const {value} in @indigentValues {
			value.prepare()
			value.translate()
		}

		@block.prepare()
		@block.translate()

		@internalName = `__ks_cons_\(@type.index())`
	} # }}}
	addAtThisParameter(statement: AliasStatement) { # {{{
		if !ClassDeclaration.isAssigningAlias(@block.statements(), statement.name(), true, @parent._extending) {
			@aliases.push(statement)
		}
	} # }}}
	private addCallToParentConstructor() { # {{{
		// only add call if parent has an empty constructor
		const extendsType = @parent.extends().type()

		if extendsType.matchArguments([], this) {
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
	} # }}}
	addIndigentValue(value: Expression, parameters) { # {{{
		const class = @parent.type().type()
		const name = `__ks_default_\(class.level())_\(class.incDefaultSequence())`

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
	checkVariableInitialization(name) { # {{{
		if @block.isInitializingInstanceVariable(name) {
			@type.addInitializingInstanceVariable(name)
		}
		else if !@abstract {
			SyntaxException.throwNotInitializedField(name, this)
		}
	} # }}}
	private getConstructorIndex(body: Array) { # {{{
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
	} # }}}
	getFunctionNode() => this
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	private getSuperIndex(body: Array) { # {{{
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
	} # }}}
	isAbstract() { # {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Abstract {
				return true
			}
		}

		return false
	} # }}}
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isForked() => @forked
	isHiddenOverride() => @hiddenOverride
	isInstanceMethod() => true
	isOverridableFunction() => true
	isRoutable() => true
	parameters() => @parameters
	toHybridConstructorFragments(fragments) { # {{{
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
	} # }}}
	toIndigentFragments(fragments) { # {{{
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
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if !@parent._es5 && @parent.isHybrid() {
			const ctrl = fragments
				.newLine()
				.code(`const \(@internalName) = (`)

			const block = Parameter.toFragments(this, ctrl, ParameterMode::Default, func(node) {
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
	} # }}}
	type() => @type
	private {
		getOveriddenConstructor(superclass: ClassType) { # {{{
			let mode = MatchingMode::FunctionSignature

			if !@override {
				mode -= MatchingMode::MissingParameterType - MatchingMode::MissingParameterArity
			}

			const methods = superclass.listConstructors(@type, mode)

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
					return null
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
								SyntaxException.throwNoOverridableConstructor(@parent.extends(), @parameters, this)
							}

							return null
						}
					}
				}

				return { method, type }
			}
			else if @override {
				SyntaxException.throwNoOverridableConstructor(@parent.extends(), @parameters, this)
			}

			return null
		} # }}}
		listOverloadedConstructors(superclass: ClassType) { # {{{
			if const methods = superclass.listConstructors() {
				for const method in methods {
					if method.isSubsetOf(@type, MatchingMode::ExactParameter) {
						return []
					}
				}
			}

			return superclass.listConstructors(@type, MatchingMode::FunctionSignature + MatchingMode::SubsetParameter)
		} # }}}
	}
}
