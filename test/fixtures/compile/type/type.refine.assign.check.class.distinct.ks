extern console

class Foo {
}

class Bar extends Foo {
}

func bar(x: Foo): String => ''
func bar(x: Bar): Number => 42

var mut x: Foo = Foo.new()

console.log(`\(bar(x))`)

var mut y: Foo = Bar.new()

console.log(`\(bar(y))`)

var mut z: Bar = Bar.new()

console.log(`\(bar(z))`)