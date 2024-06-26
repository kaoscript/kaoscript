class ClassDestructorDeclaration extends Statement {
	private late {
		@block: Block
		@parameters: Array
		@type: Type
	}
	private {
		@internalName: String
	}
	static toRouterFragments(node, fragments, variable) { # {{{
		var mut ctrl = fragments.newControl()

		if node._es5 {
			ctrl.code('__ks_destroy: function(that)')
		}
		else {
			ctrl.code('static __ks_destroy(that)')
		}

		ctrl.step()

		if node._extending {
			ctrl.line(`\(node._extendsName).__ks_destroy(that)`)
		}

		for var i from 0 to~ variable.type().getDestructorCount() {
			ctrl.line(`\(node._name).__ks_destroy_\(i)(that)`)
		}

		ctrl.done() unless node._es5
	} # }}}
	constructor(data, parent) { # {{{
		super(data, parent, parent.newScope(parent._destructorScope, ScopeType.Block))

		@internalName = `__ks_destroy_0`

		parent._destructor = this
	} # }}}
	analyse() { # {{{
		var parameter = Parameter.new({
			kind: AstKind.Parameter
			modifiers: []
			internal: $ast.identifier('that')
		}, this)

		parameter.analyse()

		@parameters = [parameter]
	} # }}}
	override prepare(target, targetMode) { # {{{
		@parameters[0].prepare()

		@type = ClassDestructorType.new(@data, this)

		@type.unflagAssignableThis()

		@type.setThisType(@parent.type().reference())
	} # }}}
	translate() { # {{{
		@block = $compile.function($ast.body(@data), this)
		@block.analyse()
		@block.prepare(Type.Void)
		@block.translate()
	} # }}}
	getFunctionNode() => this
	getParameterOffset() => 0
	isAbstract() { # {{{
		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Abstract {
				return true
			}
		}

		return false
	} # }}}
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isInstance() => false
	isInstanceMethod() => true
	isOverridableFunction() => false
	parameters() => @parameters
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl()

		if @parent._es5 {
			ctrl.code(`\(@internalName): function(`)
		}
		else {
			ctrl.code(`static \(@internalName)(`)
		}

		Parameter.toFragments(this, ctrl, ParameterMode.Default, (node) => node.code(')').step())

		ctrl.compile(@block)

		ctrl.done() unless @parent._es5
	} # }}}
	type() => @type
}
