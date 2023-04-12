struct Foobar {
	qux: Quxbaz?	= null
}

struct Quxbaz {
	x
	y
}

var point = Foobar.new()

point.qux = Quxbaz.new(1, 1)