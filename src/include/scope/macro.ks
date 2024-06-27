class MacroScope extends ModuleScope {
	static create(node: AbstractNode): BlockScope {
		var instance = MacroScope.instance(node)

		return BlockScope.new(instance)
	}
	private static instance(node: AbstractNode): MacroScope {
		if !?MacroScope._instance {
			MacroScope._instance = MacroScope.new(node)
		}

		// TODO
		return MacroScope._instance!?
	}
	private static _instance: MacroScope?
	private constructor(node: AbstractNode) {
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
	}
	override isMacro() => true
}
