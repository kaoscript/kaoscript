class DiscloseDeclaration extends Statement {
	private late {
		@auxiliary									= false
		@instanceMethods: ClassMethodType[]{}		= {}
		@name: String
		@type: Type
	}
	analyse()
	enhance() { # {{{
		@name = @data.name.name
		var variable = @scope.getVariable(@name)

		unless ?variable {
			ReferenceException.throwNotDefined(@name, this)
		}

		unless variable.getDeclaredType() is NamedType {
			TypeException.throwNotClass(@name, this)
		}

		unless variable.getDeclaredType().isAlien() {
			TypeException.throwNotAlien(@name, this)
		}

		variable.prepareAlteration()

		@type = variable.getDeclaredType().type()

		if ?#@data.typeParameters {
			var generics = [Type.toGeneric(parameter, this) for var parameter in @data.typeParameters]

			@type.generics(generics)
		}

		for var data in @data.members {
			@type.addPropertyFromAST(data, @name, this)
		}

		if @options.rules.nonExhaustive {
			@type.setExhaustive(false)
		}
		else {
			@type.setExhaustive(true)
		}

		if @type.isClass() && @type.isSealed() {
			for var methods, name of @type.listInstanceMethods() {
				for var method in methods {
					if !method.hasAuxiliary() && (method.hasGenerics() || method.hasDeferredParameter()) {
						@instanceMethods[name] = methods

						for var mth in methods {
							mth.flagAuxiliary()
						}

						break
					}
				}
			}

			if ?#@instanceMethods {
				var type = variable.getDeclaredType()

				if !type.hasAuxiliary() {
					type
						..flagAuxiliary()
						..useAuxiliaryName(@module())

					@auxiliary = true
				}
			}
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	toStatementFragments(fragments, mode) { # {{{
		return unless ?#@instanceMethods

		if @auxiliary {
			var variable = @scope.getVariable(@name)
			var sealedName = variable.getDeclaredType().getAuxiliaryName()

			fragments.line(`\($runtime.immutableScope(this))\(sealedName) = {}`)
		}

		for var methods, name of @instanceMethods {
			@toSealedInstanceFragments(name, methods, fragments)
		}
	} # }}}
	toSealedInstanceFragments(name: String, methods: ClassMethodType[], fragments) { # {{{
		var variable = @scope.getVariable(@name)
		var sealedName = variable.getDeclaredType().getAuxiliaryName()
		var labelable = @type.isLabelableInstanceMethod(@name)
		var assessment = Router.assess(@type.listInstanceMethods(name), name, this)

		var mut line = fragments.newLine()

		if labelable {
			line.code(`\(sealedName)._im_\(name) = function(that, gens, kws, ...args)`)
		}
		else {
			line.code(`\(sealedName)._im_\(name) = function(that, gens, ...args)`)
		}

		var mut block = line.newBlock()

		if labelable {
			block.line(`return \(sealedName).__ks_func_\(name)_rt(that, gens || {}, kws, args)`)
		}
		else {
			block.line(`return \(sealedName).__ks_func_\(name)_rt(that, gens || {}, args)`)
		}

		block.done()
		line.done()

		line = fragments.newLine()

		if labelable {
			line.code(`\(sealedName).__ks_func_\(name)_rt = function(that, gens, kws, args)`)
		}
		else {
			line.code(`\(sealedName).__ks_func_\(name)_rt = function(that, gens, args)`)
		}

		block = line.newBlock()

		Router.toFragments(
			(function, writer) => {
				if function.isSealed() {
					writer.code(`\(sealedName).__ks_func_\(name)_\(function.index()).call(that`)

					return true
				}
				else {
					writer.code(`that.\(name).call(that`)

					return true
				}
			}
			null
			assessment
			true
			block
			this
		)

		block.done()
		line.done()
	} # }}}
}
