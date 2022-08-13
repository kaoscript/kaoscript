class ClassVariableDeclaration extends AbstractNode {
	private late {
		_type: ClassVariableType
	}
	private {
		_defaultValue: Boolean		= false
		_dynamic: Boolean			= false
		_immutable: Boolean			= false
		_instance: Boolean			= true
		_initialized: Boolean		= true
		_lateInit: Boolean			= false
		_name: String
		_nullable: Boolean			= false
		_value						= null
	}
	constructor(data, parent) { # {{{
		super(data, parent)

		@name = data.name.name

		var mut public = false
		var mut alias = false

		for var modifier in data.modifiers {
			switch modifier.kind {
				ModifierKind::Dynamic => {
					@dynamic = true
				}
				ModifierKind::Immutable => {
					@immutable = true
				}
				ModifierKind::LateInit => {
					@lateInit = true
				}
				ModifierKind::Nullable => {
					@nullable = true
				}
				ModifierKind::Public => {
					public = true
				}
				ModifierKind::Static => {
					@instance = false
				}
				ModifierKind::ThisAlias => {
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
			SyntaxException.throwReservedClassVariable(@name, parent)
		}
		else {
			parent._classVariables[@name] = this
		}
	} # }}}
	analyse() { # {{{
		if @data.value? {
			@defaultValue = true
			@lateInit = false
		}
	} # }}}
	prepare() { # {{{
		if @parent.isExtending() {
			var type = @parent._extendsType.type()

			if @instance {
				if type.hasInstanceVariable(@name) {
					ReferenceException.throwAlreadyDefinedField(@name, this)
				}
			}
			else {
				if type.hasClassVariable(@name) {
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

			if @data.type? {
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
