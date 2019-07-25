class Foobar {
}

class Quxbaz extends Foobar {
}

func quxbaz(x: Quxbaz) {
}

func foobar(x: Foobar) {
	if x is not Quxbaz {
		x = new Quxbaz()
	}

	quxbaz(x)
}