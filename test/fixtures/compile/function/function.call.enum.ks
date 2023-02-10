extern console

enum Foobar {
	X
	Y
	Z
}

func toString(foo: Foobar) => 'xyz'

console.log(toString(Foobar.X))