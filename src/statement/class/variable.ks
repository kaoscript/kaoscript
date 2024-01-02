class ClassVariableDeclaration extends AbstractNode {
	private late {
		@type: ClassVariableType
	}
	private {
		@defaultValue: Boolean		= false
		@dynamic: Boolean			= false
		@final: Boolean				= false
		@instance: Boolean			= true
		@initialized: Boolean		= true
		@lateInit: Boolean			= false
		@name: String
		@nullable: Boolean			= false
		@value						= null
	}
	constructor(data, parent) { # {{{
		super(data, parent)

		@name = data.name.name

		var mut public = false
		var mut alias = false

		for var modifier in data.modifiers {
			match modifier.kind {
				ModifierKind.Dynamic {
					@dynamic = true
				}
				ModifierKind.Final {
					@final = true
				}
				ModifierKind.LateInit {
					@lateInit = true
				}
				ModifierKind.Nullable {
					@nullable = true
				}
				ModifierKind.Public {
					public = true
				}
				ModifierKind.Static {
					@instance = false
				}
				ModifierKind.ThisAlias {
					alias = true
				}
			}
		}

		if alias && !public {
			@name = `_\(@name)`
		}

		if @instance {
			// TODO
			// if ?parent._instanceVariables[@name] {
			// 	SyntaxException.throwIdenticalField(@name, this)
			// }

			parent._instanceVariables[@name] = this
		}
		else if @name == 'name' || @name == 'version' {
			SyntaxException.throwReservedStaticVariable(@name, parent)
		}
		else {
			// TODO
			// if ?parent._staticVariables[@name] {
			// 	SyntaxException.throwIdenticalField(@name, this)
			// }

			parent._staticVariables[@name] = this
		}
	} # }}}
	analyse() { # {{{
		if ?@data.value {
			@defaultValue = true
			@lateInit = false

			if @instance {
				@parent._inits = true
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = ClassVariableType.fromAST(@data!?, this)

		if @instance {
			if @parent.isExtending() {
				if @parent.extends().type().hasInstanceVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}

			if @parent.isImplementing() {
				for var interface in @parent.listInterfaces() {
					if var property ?= interface.getProperty(@data.name.name) {
						if Accessibility.isLessAccessibleThan(@type.access(), Accessibility.Public) {
							SyntaxException.throwLessAccessibleVariable(@parent.type(), @name, this)
						}

						if @type.type().isExplicit() {
							unless @type.isSubsetOf(property, MatchingMode.Default) {
								SyntaxException.throwUnmatchVariable(@parent.type(), interface, @name, this)
							}
						}
						else {
							@type.type(property)
						}
					}
				}
			}
		}
		else {
			if @parent.isExtending() {
				if @parent.extends().type().hasStaticVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
		}

		if @type.isRequiringInitialization() {
			@initialized = false
		}
	} # }}}
	translate() { # {{{
		if @defaultValue {
			@value = $compile.expression(@data.value, this, @instance ? @parent._instanceVariableScope : null)
			@value.analyse()
			@value.prepare()

			var type = @value.type().discardValue().asReference()

			if ?@data.type {
				unless type.isAssignableToVariable(@type.type(), true, true, false) {
					TypeException.throwInvalidAssignment(@name, @type, @value.type(), this)
				}
			}
			else if @final {
				if !@lateInit {
					@type.type(type)
				}
			}
			else if !@dynamic {
				if type.isNull() {
					@type.type(AnyType.NullableUnexplicit)
				}
				else if @nullable && !type.isNullable() {
					@type.type(type.setNullable(true).unspecify())
				}
				else {
					@type.type(type.unspecify())
				}
			}

			@value.translate()
		}
	} # }}}
	hasDefaultValue() => @defaultValue
	initialize(type, node) { # {{{
		if !@initialized {
			@initialized = true
		}
	} # }}}
	isImmutable() => @final
	isImplementing() => false
	isInitialized() => @initialized
	isInstance() => @instance
	isLateInit() => @lateInit
	isRequiringInitialization() => @type.isRequiringInitialization()
	name() => @name
	toFragments(fragments) { # {{{
		if @defaultValue {
			if @instance {
				fragments
					.newLine()
					.code(`this.\(@name) = `)
					.compile(@value)
					.done()
			}
			else {
				fragments
					.newLine()
					.code(`\(@parent.name()).\(@name) = `)
					.compile(@value)
					.done()
			}
		}
	} # }}}
	type() => @type
}
