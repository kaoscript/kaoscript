extern console: {
	log(...args)
}

class Foo {
	static {
		bar: string = 'Hello world!'
	}
	
	public {
		name: string
	}
	
	Foo(@name)
	
	qux(name) {
		this.bar = 'Hello ' + name
	}
}

console.log(Foo.bar)

let foo = new Foo('xyz')
console.log(foo.name)

export Foo