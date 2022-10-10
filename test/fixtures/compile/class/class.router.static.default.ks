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
		import(data, references, domain: Domain, node: AbstractNode): Type { # {{{
			return Type.import(null, data, references, domain, node)
		} # }}}
		import(name: String, data, references, node: AbstractNode): Type { # {{{
			return Type.import(name, data, references, node.scope().domain(), node)
		} # }}}
		import(name: String?, data, references, domain: Domain, node: AbstractNode): Type { # {{{
			return new FoobarType()
		} # }}}
	}
}

class FoobarType extends Type {

}