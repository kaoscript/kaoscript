extern console

struct Foobar {
	x: String
	y: String
}

foo = Foobar.new('x', 'y')

{x, y} = foo

console.log(`\(x).\(y)`)