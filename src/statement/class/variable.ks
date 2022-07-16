class ClassVariableDeclaration extends AbstractNode {
	private lateinit {
		_type: ClassVariableType
	}
	private {
		_autoTyping: Boolean		= false
		_defaultValue: Boolean		= false
		_immutable: Boolean			= false
		_instance: Boolean			= true
		_initialized: Boolean		= true
		_lateInit: Boolean			= false
		_name: String
		_value						= null
	}
	constructor(data, parent) { // {{{
		super(data, parent)

		@name = data.name.name

		let public = false
		let alias = false

		for const modifier in data.modifiers {
			switch modifier.kind {
				ModifierKind::AutoTyping => {
					@autoTyping = true
				}
				ModifierKind::Immutable => {
					@immutable = true
					@autoTyping = true
				}
				ModifierKind::LateInit => {
					@lateInit = true
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
	} // }}}
	analyse() { // {{{
		if @data.value? {
			@defaultValue = true
			@lateInit = false

			if !@instance {
				@value = $compile.expression(@data.value, this)
				@value.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		if @parent.isExtending() {
			const type = @parent._extendsType.type()

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

		if @defaultValue {
			if @instance {
				@value = $compile.expression(@data.value, this, @parent._instanceVariableScope)
				@value.analyse()
			}

			if @autoTyping {
				@type.type(@value.type())
			}
			else if @data.value.kind == NodeKind::Identifier && @data.value.name == 'null' {
				@type.flagNullable()
			}
		}
		else {
			if @type.isRequiringInitialization() {
				@initialized = false
			}
		}
	} // }}}
	translate() { // {{{
		if @defaultValue {
			@value.prepare()

			if !@value.isMatchingType(@type.type()) {
				TypeException.throwInvalidAssignement(@name, @type, @value.type(), this)
			}

			@value.translate()
		}
	} // }}}
	hasDefaultValue() => @defaultValue
	initialize(type, node) { // {{{
		if !@initialized {
			@initialized = true

			if @autoTyping {
				@type.type(type)
			}
		}
	} // }}}
	isImmutable() => @immutable
	isInitialized() => @initialized
	isInstance() => @instance
	isLateInit() => @lateInit
	isRequiringInitialization() => @type.isRequiringInitialization()
	name() => @name
	toFragments(fragments) { // {{{
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
	} // }}}
	type() => @type
}
