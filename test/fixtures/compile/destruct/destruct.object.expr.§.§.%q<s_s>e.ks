extern console

struct Foobar {
	x: String
	y: String
}

foo = new Foobar('x', 'y')

{x, y} = foo

console.log(`\(x).\(y)`)