// import 'path' as {
// 	var sep: String
// }

// func foobar(): String => path.sep



// import 'path' {
// 	func basename(path: String): String
// }

// path.basename('')




// enum ScopeType {
// 	Bleeding
// 	Block
// 	Function
// 	Hollow
// 	InlineBlock
// 	Macro
// 	Operation
// }

// abstract class Scope {
// }

// abstract class AbstractNode {
// 	private {
// 		@data: Any?				= null
// 		@parent: AbstractNode?	= null
// 		@scope: Scope?			= null
// 	}
// 	constructor()
// 	constructor(@data, @parent, @scope = parent?.scope()) { # {{{
// 	} # }}}
// 	constructor(@data, @parent, scope: Scope, kind: ScopeType) { # {{{
// 		@scope = @newScope(scope, kind)
// 	} # }}}
// 	newScope(scope: Scope, type: ScopeType) { # {{{
// 		return scope
// 	} # }}}
// 	scope() => @scope
// }

// abstract class Statement extends AbstractNode {
// 	constructor(@data, @parent, @scope = parent.scope()) { # {{{
// 		super(data, parent, scope)
// 	} # }}}
// 	constructor(@data, @parent, scope: Scope, kind: ScopeType) { # {{{
// 		super(data, parent, scope, kind)
// 	} # }}}
// }

// class WithStatement extends Statement {
// 	constructor(@data, @parent, @scope = @parent.scope()) {
// 		super(data, parent, scope, ScopeType::Bleeding)
// 	}
// }
