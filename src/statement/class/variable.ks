class ClassVariableDeclaration extends AbstractNode {
	private late {
		@type: ClassVariableType
	}
	private {
		@defaultValue: Boolean		= false
		@dynamic: Boolean			= false
		@immutable: Boolean			= false
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
				ModifierKind.Immutable {
					@immutable = true
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
			parent._instanceVariables[@name] = this
		}
		else if @name == 'name' || @name == 'version' {
			SyntaxException.throwReservedStaticVariable(@name, parent)
		}
		else {
			parent._staticVariables[@name] = this
		}
	} # }}}
	analyse() { # {{{
		if ?@data.value {
			@defaultValue = true
			@lateInit = false
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @parent.isExtending() {
			var type = @parent._extendsType.type()

			if @instance {
				if type.hasInstanceVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
			else {
				if type.hasStaticVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
		}

		@type = ClassVariableType.fromAST(@data!?, this)

		if @type.isRequiringInitialization() {
			@initialized = false
		}
	} # }}}
	translate() { # {{{
		if @defaultValue {
			@value = $compile.expression(@data.value, this, @instance ? @parent._instanceVariableScope : null)
			@value.analyse()
			@value.prepare()

			var type = @value.type().asReference()

			if @type.type().isExplicit() {
				unless type.isAssignableToVariable(@type.type(), true, true, false) {
					TypeException.throwInvalidAssignement(@name, @type, @value.type(), this)
				}
			}
			else if @immutable {
				if !@lateInit {
					@type.type(type)
				}
			}
			else if !@dynamic {
				if type.isNull() {
					@type.type(AnyType.NullableUnexplicit)
				}
				else if @nullable && !type.isNullable() {
					@type.type(type.setNullable(true))
				}
				else {
					@type.type(type)
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
	isImmutable() => @immutable
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
