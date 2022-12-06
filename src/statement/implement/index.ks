class ImplementDeclaration extends Statement {
	private late {
		@forkedMethods			= {}
		@newSealedClass			= false
		@properties				= []
		@sharingProperties		= {}
		@type: NamedType
		@variable: Variable
	}
	analyse() { # {{{
		if @variable !?= @scope.getVariable(@data.variable.name) {
			ReferenceException.throwNotDefined(@data.variable.name, this)
		}

		@variable.setComplete(false)
	} # }}}
	enhance() { # {{{
		if !@variable.isClassStatement() {
			@resolveType(false)
		}
	} # }}}
	resolveType(class: Boolean) { # {{{
		@type = @variable.getDeclaredType()

		unless @type is NamedType {
			TypeException.throwImplInvalidType(this)
		}
		if @type.isClass() && @type.isVirtual() {
			TypeException.throwImplInvalidType(this)
		}

		if @variable.isPredefined() {
			@variable = @scope.define(@variable.name(), true, @type.clone().unflagAltering(), this)

			@newSealedClass = @type.isSealed() && @type.isExtendable()
		}
		else if (@type.isAlien() || @type.isRequired()) && !@variable.isAltereable() {
			@variable.setDeclaredType(@type.unflagAltering())
		}
		else if class || @type.isAltering() {
			@variable.setDeclaredType(@type.clone().unflagAltering())
		}

		@variable.prepareAlteration()

		@type = @variable.getDeclaredType()

		unless @type is NamedType {
			TypeException.throwImplInvalidType(this)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @variable.isClassStatement() {
			@resolveType(true)
		}

		var type = @type.type()

		if type is ClassType {
			for var data in @data.properties {
				var late property

				switch data.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementClassFieldDeclaration(data, this, @type)
					}
					NodeKind::MethodDeclaration => {
						if type.isConstructor(data.name.name) {
							property = new ImplementClassConstructorDeclaration(data, this, @type)
						}
						else if type.isDestructor(data.name.name) {
							NotImplementedException.throw(this)
						}
						else {
							property = new ImplementClassMethodDeclaration(data, this, @type)
						}
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(data.kind)`, this)
					}
				}

				property.analyse()

				@properties.push(property)
			}
		}
		else if type is EnumType {
			for var data in @data.properties {
				var late property

				switch data.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementEnumFieldDeclaration(data, this, @type)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementEnumMethodDeclaration(data, this, @type)
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(data.kind)`, this)
					}
				}

				property.analyse()

				@properties.push(property)
			}
		}
		else if type is NamespaceType {
			for data in @data.properties {
				var late property

				switch data.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementNamespaceVariableDeclaration(data, this, @type)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementNamespaceFunctionDeclaration(data, this, @type)
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(data.kind)`, this)
					}
				}

				property.analyse()

				@properties.push(property)
			}
		}
		else {
			TypeException.throwImplInvalidType(this)
		}

		var methods = {
			false: {}
			true: {}
		}

		for var property in @properties {
			property.prepare()

			if var name ?= property.getSharedName() {
				if ?@sharingProperties[name] {
					@sharingProperties[name].push(property)
				}
				else {
					@sharingProperties[name] = [property]
				}
			}

			if property.isMethod() {
				var name = property.name()
				var type = property.type()
				var instance = property.isInstance()
				var mode = property.getMatchingMode()

				if var methods ?= methods[instance][name] {
					for var method in methods {
						if method.isSubsetOf(type, mode) {
							if property.isConstructor() {
								SyntaxException.throwDuplicateConstructor(property)
							}
							else {
								SyntaxException.throwDuplicateMethod(name, property)
							}
						}
					}

					methods.push(type)
				}
				else {
					methods[instance][name] = [type]
				}
			}
		}

		for var methods, name of @forkedMethods {
			for var { original, forks } of methods {
				var index = original.index()
				var mut found = false

				for var method in @type.listInstanceMethods(name) until found {
					if index == method.type().index() {
						method.flagForked(@type, forks)

						found = true
					}
				}

				if !found {
					throw new NotImplementedException()
				}
			}
		}
	} # }}}
	translate() { # {{{
		for var property in @properties {
			property.translate()
		}
	} # }}}
	addForkedMethod(name: String, oldMethod: ClassMethodType, newMethod: ClassMethodType) { # {{{
		var index = oldMethod.index()

		@forkedMethods[name] ??= {}

		if !?@forkedMethods[name][index] {
			@forkedMethods[name][index] = {
				original: oldMethod
				forks: [newMethod]
			}
		}
		else {
			@forkedMethods[name][index].forks.push(newMethod)
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @newSealedClass {
			fragments.line(`\($runtime.immutableScope(this))\(@type.getSealedName()) = {}`)
		}

		for property in @properties {
			property.toFragments(fragments, Mode::None)
		}

		for var properties of @sharingProperties {
			properties[0].toSharedFragments(fragments, properties)
		}
	} # }}}
	type() => @type
}

include {
	'./class.ks'
	'./enum.ks'
	'./namespace.ks'
}
