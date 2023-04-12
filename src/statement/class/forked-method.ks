class ClassForkedMethodDeclaration extends AbstractNode {
	private {
		@forks: Array<ClassMethodType>
		@hidden: Boolean
		@instance: Boolean
		@name: String
		@type: ClassMethodType
	}
	constructor(@name, @type, @forks, @hidden, parent) { # {{{
		super(null, parent)

		@instance = @type.isInstance()

		if @instance {
			parent._instanceMethods[@name].push(this)
		}
		else {
			parent._staticMethods[@name].push(this)
		}
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	isForked() => true
	isRoutable() => false
	toFragments(fragments, mode) { # {{{
		if !@hidden && !@instance {
			var ctrl = fragments.newControl()

			ctrl.code(`static __ks_sttc_\(@name)_\(@type.index())()`).step()

			ctrl.line(`return \(@parent.extends().name()).__ks_sttc_\(@name)_\(@type.getForkedIndex())(...arguments)`)

			ctrl.done()
		}
	} # }}}
	toForkFragments(fragments) { # {{{
		var ctrl = fragments.newControl()

		ctrl.code(`__ks_func_\(@name)_\(@type.index())(`)

		var mut parameters = ''

		var names = {}

		for var parameter, index in @type.parameters() {
			if index > 0 {
				ctrl.code($comma)

				parameters += ', '
			}

			ctrl.code(parameter.getExternalName())

			parameters += parameter.getExternalName()

			names[parameter.getExternalName()] = true
		}

		ctrl.code(')').step()

		if @hidden {
			var fork = @forks[0]

			if fork.hasVarargsParameter() {
				var line = ctrl.newLine().code(`return this.__ks_func_\(@name)_\(@forks[0].index())(`)

				var mut comma = false

				for var parameter in fork.parameters() {
					if comma {
						line.code($comma)
					}
					else {
						comma = true
					}

					var name = parameter.getExternalName()

					if parameter.isVarargs() {
						if names[name] {
							line.code(`[\(name)]`)
						}
						else {
							line.code('[]')
						}

						break
					}
					else {
						if names[name] {
							line.code(name)
						}
						else {
							line.code('void 0')
						}
					}
				}

				line.code(')').done()
			}
			else {
				ctrl.line(`return this.__ks_func_\(@name)_\(@forks[0].index())(\(parameters))`)
			}
		}
		else if @type.hasVarargsParameter() {
			if @type.parameters().length == 1 {
				var parameter = @type.parameter(0)

				var ctrl3 = ctrl.newControl()

				ctrl3.code(`if(\(parameter.getExternalName()).length === 1)`).step()

				for var fork in @forks {
					var ctrl2 = ctrl3.newControl()

					ctrl2.code(`if(`)

					var mut index = 0

					for var parameter in fork.parameters() when parameter.min() > 0 || names[parameter.getExternalName()] {
						ctrl2.code(' && ') unless index == 0

						var literal = Literal.new(false, this, @scope(), `\(parameter.getExternalName())[0]`)

						parameter.type().toPositiveTestFragments(ctrl2, literal, Junction.AND)

						index += 1
					}

					ctrl2.code(`)`).step()

					ctrl2.line(`return this.__ks_func_\(@name)_\(fork.index())(\(parameter.getExternalName())[0])`)

					ctrl2.done()
				}

				ctrl3.done()

				ctrl.line(`return super.__ks_func_\(@name)_\(@type.index())(\(parameters))`)
			}
			else {
				throw NotSupportedException.new()
			}
		}
		else {
			for var fork in @forks {
				var ctrl2 = ctrl.newControl()

				ctrl2.code(`if(`)

				var mut index = 0

				for var parameter in fork.parameters() when parameter.min() > 0 || names[parameter.getExternalName()] {
					ctrl2.code(' && ') unless index == 0

					var literal = Literal.new(false, this, @scope(), parameter.getExternalName())

					parameter.type().toPositiveTestFragments(ctrl2, literal, Junction.AND)

					index += 1
				}

				ctrl2.code(`)`).step()

				ctrl2.line(`return this.__ks_func_\(@name)_\(fork.index())(\(parameters))`)

				ctrl2.done()
			}

			ctrl.line(`return super.__ks_func_\(@name)_\(@type.index())(\(parameters))`)
		}

		ctrl.done()
	} # }}}
	type() => @type
}
