#![rules(ignore-misfit)]

extern console

class Foo {
	foo(): String => ''
}

class Bar extends Foo {
	bar(): String => ''
}

func bar(): Bar => new Bar()

let x: Foo = new Foo()

console.log(`\(x.foo())`)
console.log(`\(x.bar())`)

x = bar()

console.log(`\(x.foo())`)
console.log(`\(x.bar())`)

let y: Foo = new Bar()

console.log(`\(y.foo())`)
console.log(`\(y.bar())`)

let z: Bar = new Bar()

console.log(`\(z.foo())`)
console.log(`\(z.bar())`)

export Foo, Bar, x, y, z