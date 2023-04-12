class ClassConstructorDeclaration extends Statement {
	private late {
		@block: Block
		@internalName: String
		@parameters: Array<Parameter>
		@type: ClassConstructorType
	}
	private {
		@aliases: Array							= []
		@abstract: Boolean
		@forked: Boolean						= false
		@forks: Array<ClassConstructorType>?	= null
		@hiddenOverride: Boolean				= false
		@indigentValues: Array					= []
		@override: Boolean						= false
		@overriding: Boolean					= false
		@topNodes: Array						= []
	}
	static toCreatorFragments(class, constructor, fragments) { # {{{
		var ctrl = fragments.newControl()

		var args = constructor.max() == 0 ? '' : '...args'
		var block = ctrl.code(`static __ks_new_\(constructor.index())(\(args))`).step()

		block
			.line(`const o = Object.create(\(class.name()).prototype)`)
			.line('o.__ks_init()')
			.line(`o.__ks_cons_\(constructor.index())(\(args))`)
			.line('return o')

		ctrl.done()
	} # }}}
	static toRouterFragments(node, fragments, variable, methods, scope: String?, header, footer) { # {{{
		var name = variable.name()

		var assessment = Router.assess(methods, 'constructor', node)

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
				variable.type().hasConstructors() ? Router.FooterType.MUST_THROW : Router.FooterType.NO_THROW
				(fragments, _) => {
					var constructorName = variable.type().extends().isSealedAlien() ? 'constructor' : '__ks_cons_rt'

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
		super(data, parent, parent.newScope(parent._constructorScope, ScopeType.Block))

		@abstract = parent.isAbstract()

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind.Override {
				@override = true
			}
		}

		parent._constructors.push(this)
	} # }}}
	analyse() { # {{{
		@parameters = []

		for var data in @data.parameters {
			var parameter = Parameter.new(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@block = ConstructorBlock.new($ast.block($ast.body(@data)), this, @scope)
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var parameter in @parameters {
			parameter.prepare()

			if var value ?= parameter.getDefaultValue() {
				value.walkNode((node) => {
					match node {
						is CallExpression {
							var data = node.data()

							if data.callee.kind == NodeKind.ThisExpression {
								SyntaxException.throwNotYetDefined(`@\(data.callee.name.name)`, node)
							}
						}
						is IdentifierLiteral {
							if node.name() == 'this' {
								SyntaxException.throwNotYetDefined('this', node)
							}
						}
						is ThisExpression => SyntaxException.throwNotYetDefined(`@\(node.name())`, node)
					}

					return true
				})
			}
		}

		@type = ClassConstructorType.new([parameter.type() for var parameter in @parameters], @data, this)

		@type.unflagAssignableThis()

		@type.setThisType(@parent.type().reference())

		var dyn overridden

		if @parent.isExtending() {
			var superclass = @parent.extends().type()

			if var data ?= @getOveriddenConstructor(superclass) {
				{ method % overridden, type % @type } = data

				@overriding = true

				unless superclass.isAbstract() {
					@hiddenOverride = true
				}
			}
		}
		else if @override {
			SyntaxException.throwNoOverridableConstructor(@parent.type(), @parameters, this)
		}

		var mut index = 1
		if @block.isEmpty() {
			if @parent._extending {
				@addCallToParentConstructor()

				index = 0
			}
		}
		else if (index <- @getConstructorIndex(@block.getDataStatements())) == -1 && @parent._extending {
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

		var class = @parent.type().type()

		for var statement in @aliases {
			var name = statement.getVariableName()

			if var variable ?= class.getInstanceVariable(name) {
				if variable.isRequiringInitialization() {
					@block.initializeVariable(VariableBrief.new(
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

		for var {value} in @indigentValues {
			value.prepare()
			value.translate()
		}

		@block.prepare(Type.Void)
		@block.translate()

		@internalName = `__ks_cons_\(@type.index())`
	} # }}}
	addAtThisParameter(statement: AliasStatement) { # {{{
		if !ClassDeclaration.isAssigningAlias(@block.getDataStatements(), statement.name(), true, @parent._extending) {
			@aliases.push(statement)
		}
	} # }}}
	private addCallToParentConstructor() { # {{{
		// only add call if parent has an empty constructor
		var extendsType = @parent.extends().type()

		if extendsType.matchArguments([], this) {
			if extendsType.hasConstructors() || extendsType.isSealed() {
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
	checkVariableInitialization(variables: String[]): Void { # {{{
		for var variable in variables {
			if @block.isInitializingInstanceVariable(variable) {
				@type.flagInitializingInstanceVariable(variable)
			}
			else if !@abstract {
				SyntaxException.throwNotInitializedField(variable, this)
			}
		}
	} # }}}
	private getConstructorIndex(body: Array) { # {{{
		for statement, index in body {
			if statement.kind == NodeKind.ExpressionStatement {
				var expression = statement.expression

				if expression.kind == NodeKind.CallExpression {
					if expression.callee.kind == NodeKind.Identifier && (expression.callee.name == 'this' || expression.callee.name == 'super') {
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
	getFunctionNode() => this
	getOverridableVarname() => 'this'
	getParameterOffset() => 0
	private getSuperIndex(body: Array) { # {{{
		for statement, index in body {
			if statement.kind == NodeKind.ExpressionStatement {
				var expression = statement.expression

				if expression.kind == NodeKind.CallExpression {
					if expression.callee.kind == NodeKind.Identifier && expression.callee.name == 'super' {
						return index
					}
				}
			}
			else if statement.kind == NodeKind.IfStatement {
				if ?statement.whenFalse && @getSuperIndex(statement.whenTrue.statements) != -1 && @getSuperIndex(statement.whenFalse.statements) != -1 {
					return index
				}
			}
		}

		return -1
	} # }}}
	isAbstract() { # {{{
		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Abstract {
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
		var mut ctrl = fragments
			.newControl()
			.code('constructor(')

		Parameter.toFragments(this, ctrl, ParameterMode.Default, (node) => node.code(')').step())

		if @parent._extendsType.isSealedAlien() {
			var index = @getSuperIndex(@block.getDataStatements())

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
		if !@parent._es5 && @parent.isHybrid() {
			var ctrl = fragments
				.newLine()
				.code(`const \(@internalName) = (`)

			var block = Parameter.toFragments(this, ctrl, ParameterMode.Default, (node) => node.code(') =>').newBlock())

			var index = @getSuperIndex(@block.getDataStatements())

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
			var mut ctrl = fragments.newControl()

			if @parent._es5 {
				ctrl.code(`\(@internalName): function(`)
			}
			else {
				ctrl.code(`\(@internalName)(`)
			}

			Parameter.toFragments(this, ctrl, ParameterMode.Default, (node) => node.code(')').step())

			for var node in @topNodes {
				node.toAuthorityFragments(ctrl)
			}

			ctrl.compile(@block)

			ctrl.done() unless @parent._es5
		}

		@toIndigentFragments(fragments)
	} # }}}
	type() => @type
	override walkNode(fn) => fn(this) && @block.walkNode(fn)
	private {
		getOveriddenConstructor(superclass: ClassType) { # {{{
			var mut mode = MatchingMode.FunctionSignature

			if !@override {
				mode -= MatchingMode.MissingParameterType - MatchingMode.MissingParameterArity
			}

			var methods = superclass.listConstructors(@type, mode)

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
					return null
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

				if !@type.isMissingError() {
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
			if var methods ?= superclass.listConstructors() {
				for var method in methods {
					if method.isSubsetOf(@type, MatchingMode.ExactParameter) {
						return []
					}
				}
			}

			return superclass.listConstructors(@type, MatchingMode.FunctionSignature + MatchingMode.SubsetParameter)
		} # }}}
	}
}
