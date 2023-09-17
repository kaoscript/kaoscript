#![rules(ignore-misfit)]

extern console

class Foo {
	foo(): String => ''
}

class Bar extends Foo {
	bar(): String => ''
}

func bar(): Bar => Bar.new()

var mut x: Foo = Foo.new()

console.log(`\(x.foo())`)
console.log(`\(x.bar())`)

x = bar()

console.log(`\(x.foo())`)
console.log(`\(x.bar())`)

var mut y: Foo = Bar.new()

console.log(`\(y.foo())`)
console.log(`\(y.bar())`)

var mut z: Bar = Bar.new()

console.log(`\(z.foo())`)
console.log(`\(z.bar())`)

export Foo, Bar, x, y, z