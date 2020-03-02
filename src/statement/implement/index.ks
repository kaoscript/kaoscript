class ImplementDeclaration extends Statement {
	private lateinit {
		_newSealedClass		= false
		_properties			= []
		_sharingProperties	= {}
		_type: NamedType
		_variable: Variable
	}
	analyse() { // {{{
		if @variable !?= @scope.getVariable(@data.variable.name) {
			ReferenceException.throwNotDefined(@data.variable.name, this)
		}

		if @variable.isPredefined() {
			const type = @variable.getDeclaredType().clone().condense()

			@variable = @scope.define(@variable.name(), true, type, this)

			@newSealedClass = type.isSealed() && type.isExtendable()
		}
	} // }}}
	prepare() { // {{{
		@variable.prepareAlteration()

		@type = @variable.getDeclaredType()

		unless @type is NamedType {
			TypeException.throwImplInvalidType(this)
		}

		const type = @type.type()

		if type is ClassType {
			for const data in @data.properties {
				let property: Statement

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
			for const data in @data.properties {
				let property: Statement

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
				let property: Statement

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

		const methods = {
			false: {}
			true: {}
		}

		for const property in @properties {
			property.prepare()

			if const name = property.getSharedName() {
				@sharingProperties[name] = property
			}

			if property.isMethod() {
				const name = property.name()
				const type = property.type()
				const instance = property.isInstance()
				const mode = property.getMatchingMode()

				if const methods = methods[instance][name] {
					for const method in methods {
						if method.isMatching(type, mode) {
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
	} // }}}
	translate() { // {{{
		for property in @properties {
			property.translate()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @newSealedClass {
			fragments.line(`var \(@type.getSealedName()) = {}`)
		}

		for property in @properties {
			property.toFragments(fragments, Mode::None)
		}

		for const property of @sharingProperties {
			property.toSharedFragments(fragments)
		}
	} // }}}
	type() => @type
}

include {
	'./class.ks'
	'./enum.ks'
	'./namespace.ks'
}