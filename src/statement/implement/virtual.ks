class ImplementVirtualMethodDeclaration extends Statement {
	private late {
		@block: Block
		@name: String
		@parameters: Array<Parameter>
		@type: VirtualMethodType
	}
	private {
		@autoTyping: Boolean				= false
		@instance: Boolean					= true
		@override: Boolean					= false
		@topNodes: Array					= []
		@virtualType: AliasType | StructType | TupleType
		@virtualName: NamedType<AliasType | StructType | TupleType>
		@virtualRef: ReferenceType
	}
	constructor(data, parent, @virtualName) { # {{{
		super(data, parent, parent.scope(), ScopeType.Function)

		@virtualType = @virtualName.type()
		@virtualRef = @scope.reference(@virtualName)
	} # }}}
	analyse() { # {{{
		@scope.line(@data.start.line)

		@name = @data.name.name

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Override {
				@override = true
			}
			else if modifier.kind == ModifierKind.Overwrite {
				NotSupportedException.throw(this)
			}
			else if modifier.kind == ModifierKind.Static {
				@instance = false
			}
		}

		@parameters = []
		for var data in @data.parameters {
			var parameter = Parameter.new(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@block = $compile.function($ast.body(@data), this)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@scope.line(@data.start.line)

		if @instance {
			@scope.define('this', true, @virtualRef, true, this)
			@scope.rename('this', 'that')
		}

		for var parameter in @parameters {
			parameter.prepare()
		}

		@type = VirtualMethodType.new([parameter.type() for var parameter in @parameters], @data, this)

		@type.flagAlteration()

		if @instance {
			var mut mode = MatchingMode.FunctionSignature + MatchingMode.IgnoreReturn + MatchingMode.MissingError

			if @override {
				if var method ?= @virtualType.getInstantiableMethod(@name, @type, mode) {
					@type = method.clone().flagAlteration()

					var parameters = @type.parameters()

					for var parameter, index in @parameters {
						parameter.type(parameters[index])
					}
				}
				else if @isAssertingOverride() {
					SyntaxException.throwNoOverridableMethod(@virtualName, @name, @parameters, this)
				}
				else {
					@override = false
					@virtualType.addInstanceMethod(@name, @type)
				}
			}
			else {
				mode -= MatchingMode.MissingParameterType - MatchingMode.MissingParameterArity

				if @virtualType.hasMatchingInstanceMethod(@name, @type, MatchingMode.ExactParameter) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@virtualType.addInstanceMethod(@name, @type)
				}
			}
		}
		else {
			if @override {
				NotSupportedException.throw(this)
			}
			else {
				if @virtualType.hasMatchingStaticMethod(@name, @type, MatchingMode.ExactParameter) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@virtualType.addStaticMethod(@name, @type)
				}
			}
		}

		@block.analyse()

		@autoTyping = @type.isAutoTyping()

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}
	} # }}}
	translate() { # {{{
		for var parameter in @parameters {
			parameter.translate()
		}

		if @autoTyping {
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			@block.prepare(@type.getReturnType())
		}

		@block.translate()
	} # }}}
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	getMatchingMode(): MatchingMode { # {{{
		if @override {
			return MatchingMode.ShiftableParameters
		}
		else {
			return MatchingMode.ExactParameter
		}
	} # }}}
	getOverridableVarname() => @virtualName.name()
	getParameterOffset() => if @instance set 1 else 0
	getSharedName() => if @override set null else if @instance set `__ks_func_\(@name)` else `__ks_sttc_\(@name)`
	getVirtualName() => @virtualName
	isAssertingOverride() => @options.rules.assertOverride
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isInstance() => @instance
	isInstanceMethod() => @instance
	isMethod() => true
	isOverridableFunction() => true
	name() => @name
	parameters() => @parameters
	toSharedFragments(fragments, _) { # {{{
		var name = @virtualName.getAuxiliaryName()

		if @instance {
			var assessment = @virtualType.getInstanceAssessment(@name, this)

			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(name).__ks_func_\(@name) = function(that, ...args)`).step()

			Router.toFragments(
				(function, writer) => {
					writer.code(`\(name).__ks_func_\(@name)_\(function.index())(that`)

					return true
				}
				`args`
				assessment
				ctrl.block()
				this
			)

			ctrl.done()
			line.done()
		}
		else {
			var assessment = @virtualType.getStaticAssessment(@name, this)

			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(name).\(@name) = function()`).step()

			Router.toFragments(
				(function, writer) => {
					writer.code(`\(name).__ks_sttc_\(@name)_\(function.index())(`)

					return false
				}
				`arguments`
				assessment
				ctrl.block()
				this
			)

			ctrl.done()
			line.done()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine()
		var name = @virtualName.getAuxiliaryName()

		if @instance {
			line.code(`\(name).__ks_func_\(@name)_\(@type.index()) = function(that`)
		}
		else {
			line.code(`\(name).__ks_sttc_\(@name)_\(@type.index()) = function(`)
		}

		var block = Parameter.toFragments(this, line, ParameterMode.Default, (writer) => writer.code(')').newBlock())

		for var node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		block.done()
		line.done()
	} # }}}
	type() => @type
}
