bitmask ExitMode {
	Nil
	Always
	Continuity
	Expression
	Statement
}

enum TargetMode {
	Ignore
	Permissive
	Strict
}

abstract class AbstractNode {
	private {
		@data: Any?				= null
		@options
		@parent: AbstractNode?	= null
		@reference
		@scope: Scope?			= null
	}
	constructor()
	constructor(@data, @parent, @scope = parent?.scope()) { # {{{
		@options = parent._options
	} # }}}
	constructor(@data, @parent, scope: Scope, kind: ScopeType) { # {{{
		@options = parent._options

		@scope = @newScope(scope, kind)
	} # }}}
	abstract analyse()
	// TODO remove default value
	abstract prepare(target: Type = Type.Void, targetMode: TargetMode = TargetMode.Strict)
	abstract translate()
	authority() => @parent.authority()
	data() => @data
	directory() => @parent.directory()
	enhance()
	file() => @parent.file()
	getASTReference(name: String) => @parent?.getASTReference(name)
	getFunctionNode() => @parent?.getFunctionNode()
	getTopicReference(data) => @parent?.getTopicReference(data)
	initiate()
	isConsumedError(error): Boolean => @parent.isConsumedError(error)
	isIncluded(): Boolean => @file() != @module().file()
	isMisfit() => @options.rules.ignoreMisfit
	module() => @parent.module()
	newScope(scope: Scope, type: ScopeType) { # {{{
		match type {
			.Bleeding {
				return BleedingScope.new(scope)
			}
			.Block {
				return BlockScope.new(scope)
			}
			.Function {
				return FunctionScope.new(scope)
			}
			.Hollow {
				return HollowScope.new(scope)
			}
			.InlineBlock {
				if @options.format.variables == 'es6' {
					return InlineBlockScope.new(scope)
				}
				else {
					return LaxInlineBlockScope.new(scope)
				}
			}
			.InlineFunction {
				return InlineFunctionScope.new(scope)
			}
			.Method {
				return MethodScope.new(scope)
			}
			.Operation {
				return OperationScope.new(scope)
			}
		}
	} # }}}
	parent() => @parent
	printDebug() { # {{{
		echo(`\(@file()):\(@data.start.line)`)
	} # }}}
	reference() { # {{{
		if ?@parent?.reference() {
			return @parent.reference() + @reference
		}
		else {
			return @reference
		}
	} # }}}
	reference(@reference)
	scope() => @scope
	statement() => @parent?.statement()
	walkNode(fn: (node: AbstractNode): Boolean): Boolean => fn(this)
	walkVariable(fn: (name: String, type: Type): Void): Void
}

include {
	'./attribute.ks'
	'./fragment.ks'
	'./type.ks'
	'./variable.ks'
	'./scope.ks'
	'./module.ks'
	'./router.ks'
	'./iteration/index.ks'
	'./block.ks'
	'./expression.ks'
	'./statement.ks'
	'./parameter.ks'
	'../statement/struct.ks'
	'../statement/tuple.ks'
	'../operator/index.ks'
	'./macro.ks'
}

