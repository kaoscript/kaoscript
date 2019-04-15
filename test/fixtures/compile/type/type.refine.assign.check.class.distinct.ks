extern console

class Foo {
}

class Bar extends Foo {
}

func bar(x: Foo): String => ''
func bar(x: Bar): Number => 42

let x: Foo = new Foo()

console.log(`\(bar(x))`)

let y: Foo = new Bar()

console.log(`\(bar(y))`)

let z: Bar = new Bar()

console.log(`\(bar(z))`)