type Foobar = {
	x: Number
	y: Number
}

type Quxbaz = Foobar & {
	z: Number
}

func foobar(value: Quxbaz) {
	quxbaz(value)
}

func quxbaz(value: Foobar) {
}