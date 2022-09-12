extern console

class Foo {
}

class Bar extends Foo {
}

func bar(x: Foo): String => ''
func bar(x: Bar): Number => 42

var mut x: Foo = new Foo()

console.log(`\(bar(x))`)

var mut y: Foo = new Bar()

console.log(`\(bar(y))`)

var mut z: Bar = new Bar()

console.log(`\(bar(z))`)