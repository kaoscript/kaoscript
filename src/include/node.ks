
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
	initiate()
	isConsumedError(error): Boolean => @parent.isConsumedError(error)
	isIncluded(): Boolean => @file() != @module().file()
	module() => @parent.module()
	newScope(scope: Scope, type: ScopeType) { # {{{
		match type {
			ScopeType.Bleeding {
				return new BleedingScope(scope)
			}
			ScopeType.Block {
				return new BlockScope(scope)
			}
			ScopeType.Function {
				return new FunctionScope(scope)
			}
			ScopeType.Hollow {
				return new HollowScope(scope)
			}
			ScopeType.InlineBlock {
				if @options.format.variables == 'es6' {
					return new InlineBlockScope(scope)
				}
				else {
					return new LaxInlineBlockScope(scope)
				}
			}
			ScopeType.Operation {
				return new OperationScope(scope)
			}
		}
	} # }}}
	parent() => @parent
	printDebug() { # {{{
		console.log(`\(@file()):\(@data.start.line)`)
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
	'./attribute'
	'./fragment'
	'./type'
	'./variable'
	'./scope'
	'./module'
	'./router'
	'./statement'
	'./expression'
	'./parameter'
	'../statement/struct'
	'../statement/tuple'
	'../operator/index'
	'./block'
	'./macro'
}

