extern console

class Foobar {
	private {
		_x: String
		_y: String
	}
	foobar({@x, @y}) {
		console.log(`\(@x).\(@y)`)
	}
}