extern console

class Foo {
	static {
		bar: string = 'Hello world!'
	}

	public {
		name: string
	}

	constructor(@name)

	qux(name) {
		Foo.bar = 'Hello ' + name
	}
}

console.log(Foo.bar)

var dyn foo = Foo.new('xyz')
console.log(foo.name)

export Foo