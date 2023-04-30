type Foobar = {
	x: Number
	y: Number
}

type Quxbaz = Foobar & {
	z: Number
}

func foobar(value: Foobar) {
	quxbaz(value)
}

func quxbaz(value: Quxbaz) {
}