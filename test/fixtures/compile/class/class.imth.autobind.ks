extern console

class Foobar {
	private {
		_x: Number	= 0
	}
	x() => @x
}

var f = Foobar.new()

var dyn x = f.x

console.log(x())

console.log(f.x())