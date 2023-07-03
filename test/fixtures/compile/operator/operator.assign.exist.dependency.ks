extern console

func xyz() => 'xyz'
var dyn foo

if (foo ?= xyz()) && foo.bar?.name == 'xyz' && ?foo.qux {
	console.log(`hello \(foo)`)
}