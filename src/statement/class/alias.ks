class ClassAliasDeclaration extends Statement {
	private late {
		@instance: Boolean				= true
		@name: String
		@overridenMethods: Array		= []
		@target: Expression
		@targetName: String
		@targetPath: String
		@type: Type
	}
	constructor(data, parent) { # {{{
		super(data, parent, parent.newInstanceMethodScope())

		@name = data.name.name

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Static {
				@instance = false
			}
		}

		parent._aliases[@name] = this
	} # }}}
	analyse()
	override prepare(target) { # {{{
		var class = @parent.type().type()

		@target = $compile.expression(@data.target, this)
		@target.analyse()
		@target.prepare()

		var mut parent = @target
		do {
			if parent.type().isNullable() {
				ReferenceException.throwNullableAlias(@name, this)
			}

			if parent is MemberExpression {
				parent = parent.caller()
			}
			else {
				break
			}
		}
		while true

		var path: Array = @target.path().split('.').slice(1)

		if path.length == 1 {
			@targetPath = ''
			@targetName = path[0]
		}
		else {
			@targetPath = `.\(path.slice(0, -1).join('.'))`
			@targetName = path.last()
		}

		@type = @target.type()

		if @type.isFunction() {
			if @instance {
				for var function in @type.functions() {
					var type = function.clone()
					type.setAlias(@targetPath, @targetName)

					if var method = class.getMatchingInstanceMethod(@name, type, MatchingMode::ExactParameter + MatchingMode::Superclass) {
						@overridenMethods.push({
							index: method.index()
							type
						})
					}

					class.addInstanceMethod(@name, type)
				}
			}
			else {
				throw new NotImplementedException()
			}
		}
		else {
			throw new NotImplementedException()
		}
	} # }}}
	translate() { # {{{
		@target.translate()
	} # }}}
	isAlias(): true
	isInstance() => @instance
	name(): @name
	toStatementFragments(fragments, mode) { # {{{
		if @type.isFunction() {
			if @instance {
				var ctrl = fragments.newControl()

				ctrl.code(`\(@name)()`).step()

				ctrl.line(`return this\(@targetPath).__ks_func_\(@targetName)_rt.call(null, this\(@targetPath), this\(@targetPath), arguments)`)

				ctrl.done()

				for var { index, type } in @overridenMethods {
					var ctrl = fragments.newControl()

					ctrl.code(`__ks_func_\(@name)_\(index)()`).step()

					ctrl.line(`return this\(@targetPath).__ks_func_\(@targetName)_\(type.index())(...arguments)`)

					ctrl.done()
				}
			}
			else {
				throw new NotImplementedException()
			}
		}
		else {
			throw new NotImplementedException()
		}
	} # }}}
}
