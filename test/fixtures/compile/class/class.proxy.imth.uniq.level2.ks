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

var root = Root.new()
var level1 = Node.new(root)
var level2 = Node.new(level1)
var value = foobar()

console.log(`\(level2.foobar(value))`)