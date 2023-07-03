extern console

struct Foobar {
	x: String
	y: String
}

var foo = Foobar.new('x', 'y')
var dyn x, y

{x, y} = foo

console.log(`\(x).\(y)`)