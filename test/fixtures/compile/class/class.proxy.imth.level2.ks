extern console

abstract class AbstractNode {
	abstract foobar(value: String): String
}

class Root extends AbstractNode {
	override foobar(value) => value
}

class Node extends AbstractNode {
	private {
		@parent: AbstractNode
	}
	constructor(@parent)
	proxy {
		foobar = @parent.foobar
	}
}

func foobar() => 42

var root = new Root()
var level1 = new Node(root)
var level2 = new Node(level1)
var value = foobar()

console.log(`\(level2.foobar(value))`)