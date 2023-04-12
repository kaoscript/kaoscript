class ClassProxyDeclaration extends Statement {
	private late {
		@external: Expression
		@externalName: String
		@externalPath: String
		@instance: Boolean				= true
		@name: String
		@overridenMethods: Array		= []
		@type: Type
	}
	constructor(data, parent) { # {{{
		var mut instance = true

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind.Static {
				instance = false

				break
			}
		}

		super(data, parent, parent.newMethodScope(instance))

		@name = data.internal.name
		@instance = instance

		parent._proxies.push(this)
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		var class = @parent.type().type()

		@external = $compile.expression(@data.external, this)
		@external.analyse()
		@external.prepare()

		var mut parent = @external
		do {
			if parent.type().isExplicit() && parent.type().isNullable() {
				ReferenceException.throwNotNullableProxy(@name, this)
			}

			if parent is MemberExpression {
				parent = parent.caller()
			}
			else {
				break
			}
		}
		while true

		var path: Array = @external.path().split('.').slice(1)

		if path.length == 1 {
			@externalPath = ''
			@externalName = path[0]
		}
		else {
			@externalPath = `.\(path.slice(0, -1).join('.'))`
			@externalName = path.last()
		}

		@type = @external.type()

		if @type.isFunction() {
			if @instance {
				for var function in @type.functions() {
					var type = function.clone()
					type.setProxy(@externalPath, @externalName)

					if var method ?= class.getMatchingInstanceMethod(@name, type, MatchingMode.ExactParameter + MatchingMode.Superclass) {
						@overridenMethods.push({
							index: method.index()
							type
						})
					}

					class.addInstanceMethod(@name, type)
				}
			}
			else {
				throw NotImplementedException.new()
			}
		}
		else if @type.isAny() {
			ReferenceException.throwNoTypeProxy(@external.toQuote(), this)
		}
		else {
			class.addInstanceVariable(@name, ClassVariableType.new(@scope(), @type))
		}
	} # }}}
	translate() { # {{{
		@external.translate()
	} # }}}
	isInstance() => @instance
	name(): @name
	toStatementFragments(fragments, mode) { # {{{
		if @type.isFunction() {
			if @instance {
				var mut ctrl = fragments.newControl()

				ctrl.code(`\(@name)()`).step()

				ctrl.line(`return this\(@externalPath).__ks_func_\(@externalName)_rt.call(null, this\(@externalPath), this\(@externalPath), arguments)`)

				ctrl.done()

				for var { index, type } in @overridenMethods {
					ctrl = fragments.newControl()

					ctrl.code(`__ks_func_\(@name)_\(index)()`).step()

					ctrl.line(`return this\(@externalPath).__ks_func_\(@externalName)_\(type.index())(...arguments)`)

					ctrl.done()
				}

				ctrl = fragments.newControl()

				ctrl.code(`__ks_func_\(@name)_rt(that, proto, args)`).step()

				ctrl.line(`return proto.\(@externalName).apply(that, args)`)

				ctrl.done()
			}
			else {
				throw NotImplementedException.new()
			}
		}
		else {
			var mut ctrl = fragments.newControl()

			ctrl.code(`get \(@name)()`).step()

			ctrl.line(`return this\(@externalPath).\(@externalName)`)

			ctrl.done()

			ctrl = fragments.newControl()

			ctrl.code(`set \(@name)(value)`).step()

			ctrl.line(`this\(@externalPath).\(@externalName) = value`)

			ctrl.done()
		}
	} # }}}
}

class ClassProxyGroupDeclaration extends Statement {
	private late {
		@instance: Boolean					= true
		@elements: Object<Object>			= {}
		@recipient: Expression
		@recipientPath: String
	}
	constructor(data, parent) { # {{{
		var mut instance = true

		for modifier in data.modifiers {
			if modifier.kind == ModifierKind.Static {
				instance = false

				break
			}
		}

		super(data, parent, parent.newMethodScope(instance))

		@instance = instance

		parent._proxies.push(this)
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		var class = @parent.type().type()

		@recipient = $compile.expression(@data.recipient, this)
		@recipient.analyse()
		@recipient.prepare()

		var mut parent = @recipient
		do {
			if parent.type().isExplicit() && parent.type().isNullable() {
				ReferenceException.throwNotNullableProxy(parent.toQuote(), this)
			}

			if parent is MemberExpression {
				parent = parent.caller()
			}
			else {
				break
			}
		}
		while true

		@recipientPath = '.' + @recipient.path().split('.').slice(1).join('.')

		var type = @recipient.type()

		unless type.isComplete() {
			ReferenceException.throwUncompleteType(type, @parent.type(), this)
		}

		if type.isAny() {
			ReferenceException.throwNoTypeProxy(@recipient.toQuote(), this)
		}

		if @instance {
			for var data in @data.elements {
				var internal = data.internal.name
				var external = data.external.name

				if ?@elements[internal] {
					throw NotImplementedException.new()
				}
				else if var property ?= type.getProperty(external) {
					var type = property.clone()

					if type.isFunction() {
						type.setProxy(@recipientPath, external)

						var overloads = []

						if type is ClassMethodGroupType {
							for var function in type.functions() {
								if var method ?= class.getMatchingInstanceMethod(internal, function, MatchingMode.ExactParameter + MatchingMode.Superclass) {
									overloads.push({
										internal: method.index()
										external: function.index()
									})
								}

								class.addInstanceMethod(internal, function)
							}
						}
						else {
							if var method ?= class.getMatchingInstanceMethod(internal, type, MatchingMode.ExactParameter + MatchingMode.Superclass) {
								overloads.push({
									internal: method.index()
									external: type.index()
								})
							}

							class.addInstanceMethod(internal, type)
						}

						@elements[internal] = {
							external
							type
							overloads
						}
					}
					else if type.isAny() {
						ReferenceException.throwNoTypeProxy(@recipient.toQuote(), external, this)
					}
					else {
						class.addInstanceVariable(internal, ClassVariableType.new(@scope(), type))

						@elements[internal] = {
							external
							type
						}
					}
				}
				else {
					ReferenceException.throwNotDefinedProperty(external, this)
				}
			}
		}
		else {
			throw NotImplementedException.new()
		}
	} # }}}
	translate()
	isInstance() => @instance
	toStatementFragments(fragments, mode) { # {{{
		if @instance {
			for var { external, type, overloads }, internal of @elements {
				if type.isFunction() {
					var mut ctrl = fragments.newControl()

					ctrl.code(`\(internal)()`).step()

					ctrl.line(`return this\(@recipientPath).__ks_func_\(external)_rt.call(null, this\(@recipientPath), this\(@recipientPath), arguments)`)

					ctrl.done()

					if #overloads {
						for var overload in overloads {
							ctrl = fragments.newControl()

							ctrl.code(`__ks_func_\(internal)_\(overload.internal)()`).step()

							ctrl.line(`return this\(@recipientPath).__ks_func_\(external)_\(overload.external)(...arguments)`)

							ctrl.done()
						}
					}

					ctrl = fragments.newControl()

					ctrl.code(`__ks_func_\(internal)_rt(that, proto, args)`).step()

					ctrl.line(`return proto.\(external).apply(that, args)`)

					ctrl.done()
				}
				else {
					var mut ctrl = fragments.newControl()

					ctrl.code(`get \(internal)()`).step()

					ctrl.line(`return this\(@recipientPath).\(external)`)

					ctrl.done()

					ctrl = fragments.newControl()

					ctrl.code(`set \(internal)(value)`).step()

					ctrl.line(`this\(@recipientPath).\(external) = value`)

					ctrl.done()
				}
			}
		}
		else {
			throw NotImplementedException.new()
		}
	} # }}}
}
