extern console

class Foobar {
	private {
		_x: Number	= 0
	}
	x() => @x
}

const f = new Foobar()

if ?f.x {
	console.log(f.x)
}

let x = f.x

console.log(x())

console.log(f.x())