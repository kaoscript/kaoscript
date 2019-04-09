class RefinableScope extends InlineBlockScope {
	define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable => @parent.define(name, immutable, type, node)
	replaceVariable(name: String, immutable: Boolean, type: Type) { // {{{
		@variables[name] = new Variable(name, immutable, false, type)
	} // }}}
}