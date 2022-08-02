struct Foobar {
	qux: Quxbaz?	= null
}

struct Quxbaz {
	x
	y
}

var point = Foobar()

point.qux = Quxbaz(1, 1)