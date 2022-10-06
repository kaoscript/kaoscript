extern console

class Foobar {
	private {
		_x: Number	= 0
	}
	x() => @x
}

var f = new Foobar()

var dyn x = f.x

console.log(x())

console.log(f.x())