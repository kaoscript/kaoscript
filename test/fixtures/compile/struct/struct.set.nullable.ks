struct Foobar {
	qux: Quxbaz?	= null
}

struct Quxbaz {
	x
	y
}

var point = new Foobar()

point.qux = new Quxbaz(1, 1)