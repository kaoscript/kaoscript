extern console

func xyz() => 'xyz'

if (foo ?= xyz()) && foo.bar?.name == 'xyz' && foo.qux? {
	console.log(`hello \(foo)`)
}