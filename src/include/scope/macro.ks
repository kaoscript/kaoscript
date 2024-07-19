class MacroScope extends ModuleScope {
	private {
		@evalReferences					= {}
		@newReferences: String[]		= []
	}
	static createBlock(node: AbstractNode): BlockScope { # {{{
		var macro = node.module().compiler().getMacroScope(node)

		return BlockScope.new(macro)
	} # }}}
	constructor(node: AbstractNode) { # {{{
		super(true)

		ImportDeclaration.new({
			kind: AstKind.ImportDeclaration
			declarations: [{
				kind: AstKind.ImportDeclarator
				source: {
					value: 'npm:@kaoscript/ast'
				}
				attributes: []
				modifiers: []
				specifiers: []
				start: { line: 1 }
				end: { line: 1 }
			}]
			attributes: []
			start: { line: 1 }
			end: { line: 1 }
		}, node.module().authority(), this)
			..flagMacro()
			..initiate()
			..analyse()
			..prepare(Type.Void, TargetMode.Permissive)
	} # }}}
	addEvalReference(name: String, reference) { # {{{
		@evalReferences[name] = reference
	} # }}}
	override define(name, immutable, type, initialized, overwrite, node) { # {{{
		var variable = super(name, immutable, type, initialized, overwrite, node)

		@newReferences.push(name)

		return variable
	} # }}}
	getEvalReference(name: String) => @evalReferences[name]
	hasEvalReference(name: String): Boolean => @newReferences.contains(name)
	override isMacro() => true
}
