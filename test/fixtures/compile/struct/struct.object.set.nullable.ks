struct Foobar {
	qux: Quxbaz?	= null
}

struct Quxbaz {
	x
	y
}

const point = Foobar()

point.qux = Quxbaz(1, 1)