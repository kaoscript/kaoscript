class ClassForkedMethodDeclaration extends AbstractNode {
	private {
		@forks: Array<ClassMethodType>
		@hidden: Boolean
		@instance: Boolean
		@name: String
		@type: ClassMethodType
	}
	constructor(@name, @type, @forks, @hidden, parent) { // {{{
		super(null, parent)

		@instance = @type.isInstance()

		if @instance {
			parent._instanceMethods[@name].push(this)
		}
		else {
			parent._classMethods[@name].push(this)
		}
	} // }}}
	analyse()
	prepare()
	translate()
	isForked() => true
	isRoutable() => false
	toFragments(fragments, mode) { // {{{
		if !@hidden && !@instance {
			const ctrl = fragments.newControl()

			ctrl.code(`static __ks_sttc_\(@name)_\(@type.index())()`).step()

			ctrl.line(`return \(@parent.extends().name()).__ks_sttc_\(@name)_\(@type.getForkedIndex())(...arguments)`)

			ctrl.done()
		}
	} // }}}
	toForkFragments(fragments) { // {{{
		const ctrl = fragments.newControl()

		ctrl.code(`__ks_func_\(@name)_\(@type.index())(`)

		let parameters = ''

		const names = {}

		for const parameter, index in @type.parameters() {
			if index > 0 {
				ctrl.code($comma)

				parameters += ', '
			}

			ctrl.code(parameter.name())

			parameters += parameter.name()

			names[parameter.name()] = true
		}

		ctrl.code(')').step()

		if @hidden {
			const fork = @forks[0]

			if fork.hasVarargsParameter() {
				const line = ctrl.newLine().code(`return this.__ks_func_\(@name)_\(@forks[0].index())(`)

				let comma = false

				for const parameter in fork.parameters() {
					if comma {
						line.code($comma)
					}
					else {
						comma = true
					}

					const name = parameter.name()

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
				const parameter = @type.parameter(0)

				const ctrl3 = ctrl.newControl()

				ctrl3.code(`if(\(parameter.name()).length === 1)`).step()

				for const fork in @forks {
					const ctrl2 = ctrl3.newControl()

					ctrl2.code(`if(`)

					let index = 0

					for const parameter in fork.parameters() when parameter.min() > 0 || names[parameter.name()] {
						ctrl2.code(' && ') unless index == 0

						const literal = new Literal(false, this, this.scope(), `\(parameter.name())[0]`)

						parameter.type().toPositiveTestFragments(ctrl2, literal, Junction::AND)

						++index
					}

					ctrl2.code(`)`).step()

					ctrl2.line(`return this.__ks_func_\(@name)_\(fork.index())(\(parameter.name())[0])`)

					ctrl2.done()
				}

				ctrl3.done()

				ctrl.line(`return super.__ks_func_\(@name)_\(@type.index())(\(parameters))`)
			}
			else {
				throw new NotSupportedException()
			}
		}
		else {
			for const fork in @forks {
				const ctrl2 = ctrl.newControl()

				ctrl2.code(`if(`)

				let index = 0

				for const parameter in fork.parameters() when parameter.min() > 0 || names[parameter.name()] {
					ctrl2.code(' && ') unless index == 0

					const literal = new Literal(false, this, this.scope(), parameter.name())

					parameter.type().toPositiveTestFragments(ctrl2, literal, Junction::AND)

					++index
				}

				ctrl2.code(`)`).step()

				ctrl2.line(`return this.__ks_func_\(@name)_\(fork.index())(\(parameters))`)

				ctrl2.done()
			}

			ctrl.line(`return super.__ks_func_\(@name)_\(@type.index())(\(parameters))`)
		}

		ctrl.done()
	} // }}}
	type() => @type
}
