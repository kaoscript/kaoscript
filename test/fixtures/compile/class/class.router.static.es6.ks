extern {
	class Domain

	class Scope {
		domain(): Domain
	}

	class AbstractNode {
		scope(): Scope
	}
}

abstract class Type {
	static {
		import(data, references: Object, domain: Domain, node: AbstractNode): Type { // {{{
			return Type.import(null, data, references, domain, node)
		} // }}}
		import(name: String, data, references: Object, node: AbstractNode): Type { // {{{
			return Type.import(name, data, references, node.scope().domain(), node)
		} // }}}
		import(name: String?, data, references, domain: Domain, node: AbstractNode): Type { // {{{
		} // }}}
	}
}