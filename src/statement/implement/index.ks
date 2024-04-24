class ImplementDeclaration extends Statement {
	private late {
		@auxiliary					= false
		@forkedMethods				= {}
		@properties					= []
		@sharingProperties			= {}
		@type: NamedType
		@useDeclaration: Boolean	= false
		@variable: Variable
	}
	analyse() { # {{{
		if @variable !?= @scope.getVariable(@data.variable.name) {
			ReferenceException.throwNotDefined(@data.variable.name, this)
		}

		match var declaration = @variable.declaration() {
			is ClassDeclaration {
				if declaration.type().isSealed() {
					@variable.setComplete(false)
				}
				else {
					@useDeclaration = true

					var class = declaration.type().type()

					for var data in @data.properties {
						match data.kind {
							NodeKind.FieldDeclaration {
								var property = ImplementUnifiedClassFieldDeclaration.new(data, declaration, this)

								property.analyse()

								@properties.push(property)
							}
							NodeKind.MethodDeclaration {
								var property = if class.isConstructor(data.name.name) {
									set ImplementUnifiedClassConstructorDeclaration.new(data, declaration, this)
								}
								else if class.isDestructor(data.name.name) {
									set ImplementUnifiedClassDestructorDeclaration.new(data, declaration)
								}
								else {
									set ImplementUnifiedClassMethodDeclaration.new(data, declaration, this)
								}

								property.analyse()

								@properties.push(property)
							}
							else {
								throw NotImplementedException.new(this)
							}
						}
					}
				}
			}
			else {
				@variable.setComplete(false)
			}
		}
	} # }}}
	enhance() { # {{{
		return if @useDeclaration

		if !@variable.isClassStatement() {
			@resolveType(false)
		}
	} # }}}
	resolveType(class: Boolean) { # {{{
		@type = @variable.getDeclaredType()

		unless ?@type {
			TypeException.throwImplInvalidType(this)
		}

		if @type.isClass() && @type.isVirtual() {
			TypeException.throwImplInvalidType(this)
		}

		if @variable.isPredefined() {
			@variable = @scope.define(@variable.name(), true, @type.clone().unflagAltering(), this)
		}
		else if @variable.isStandardLibrary(.Closed) {
			pass
		}
		else if @module().isStandardLibrary() {
			@type.setStandardLibrary(.Yes + .Closed)
		}
		else if (@type.isAlien() || @type.isRequired()) && !@variable.isAltereable() {
			@variable.setDeclaredType(@type.unflagAltering())
		}
		else if class || @type.isAltering() {
			@variable.setDeclaredType(@type.clone().unflagAltering())
		}

		@variable.prepareAlteration()

		@type = @variable.getDeclaredType()

		@type.origin(@type.origin() + TypeOrigin.Implements)

		if @type.isUsingAuxiliary() && !@type.hasAuxiliary() {
			@type.flagAuxiliary()

			@auxiliary = true
		}

		unless ?@type {
			TypeException.throwImplInvalidType(this)
		}

		if @auxiliary {
			@type.useSealedName(@module())

			if @variable.isStandardLibrary(.Closed) {
				@type.setStandardLibrary(.Yes + .Opened)
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		return if @useDeclaration

		if @variable.isClassStatement() {
			@resolveType(true)
		}

		var type = @type.type()

		if type is ClassType {
			for var data in @data.properties {
				var property =
					match data.kind {
						NodeKind.FieldDeclaration {
							set ImplementDividedClassFieldDeclaration.new(data, this, @type)
						}
						NodeKind.MethodDeclaration {
							if type.isConstructor(data.name.name) {
								set ImplementDividedClassConstructorDeclaration.new(data, this, @type)
							}
							else if type.isDestructor(data.name.name) {
								NotImplementedException.throw(this)
							}
							else {
								set ImplementDividedClassMethodDeclaration.new(data, this, @type)
							}
						}
						else {
							throw NotSupportedException.new(`Unexpected kind \(data.kind)`, this)
						}
					}

				property.analyse()

				@properties.push(property)
			}
		}
		else if type is EnumType {
			for var data in @data.properties {
				var late property

				match data.kind {
					NodeKind.FieldDeclaration {
						property = ImplementEnumValueDeclaration.new(data, this, @type)
					}
					NodeKind.MethodDeclaration {
						property = ImplementEnumMethodDeclaration.new(data, this, @type)
					}
					else {
						throw NotSupportedException.new(`Unexpected kind \(data.kind)`, this)
					}
				}

				property.analyse()

				@properties.push(property)
			}
		}
		else if type is NamespaceType {
			for var data in @data.properties {
				var late property

				match data.kind {
					NodeKind.FieldDeclaration {
						property = ImplementNamespaceVariableDeclaration.new(data, this, @type)
					}
					NodeKind.MethodDeclaration {
						property = ImplementNamespaceFunctionDeclaration.new(data, this, @type)
					}
					else {
						throw NotSupportedException.new(`Unexpected kind \(data.kind)`, this)
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
				var propType = property.type()
				var instance = property.isInstance()
				var mode = property.getMatchingMode()

				if var mths ?= methods[instance][name] {
					for var method in mths {
						if method.isSubsetOf(propType, mode) {
							if property.isConstructor() {
								SyntaxException.throwDuplicateConstructor(property)
							}
							else {
								SyntaxException.throwDuplicateMethod(name, property)
							}
						}
					}

					mths.push(propType)
				}
				else {
					methods[instance][name] = [propType]
				}
			}
		}

		for var mths, name of @forkedMethods {
			for var { original, forks } of mths {
				var index = original.index()
				var mut found = false

				for var method in @type.listInstanceMethods(name) until found {
					if index == method.type().index() {
						method.flagForked(@type, forks)

						found = true
					}
				}

				if !found {
					throw NotImplementedException.new()
				}
			}
		}
	} # }}}
	translate() { # {{{
		return if @useDeclaration

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
		return if @useDeclaration

		if @auxiliary {
			fragments.line(`\($runtime.immutableScope(this))\(@type.getSealedName()) = {}`)
		}

		for var property in @properties {
			property.toFragments(fragments, Mode.None)
		}

		for var properties of @sharingProperties {
			properties[0].toSharedFragments(fragments, properties)
		}
	} # }}}
	type() => @type
}

include {
	'./divided-class.ks'
	'./unified-class.ks'
	'./enum.ks'
	'./namespace.ks'
}
