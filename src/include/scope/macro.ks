class MacroScope extends ModuleScope {
	private {
		@evalReferences					= {}
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
	getEvalReference(name: String) => @evalReferences[name]
	override isMacro() => true
}
