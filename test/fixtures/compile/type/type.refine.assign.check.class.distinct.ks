extern console

class Foo {
}

class Bar extends Foo {
}

func bar(x: Foo): String => ''
func bar(x: Bar): Number => 42

var dyn x: Foo = new Foo()

console.log(`\(bar(x))`)

var dyn y: Foo = new Bar()

console.log(`\(bar(y))`)

var dyn z: Bar = new Bar()

console.log(`\(bar(z))`)