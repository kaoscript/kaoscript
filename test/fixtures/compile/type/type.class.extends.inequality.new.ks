class Foobar {
}

class Quxbaz extends Foobar {
}

func quxbaz(x: Quxbaz) {
}

func foobar(mut x: Foobar) {
	if x is not Quxbaz {
		x = Quxbaz.new()
	}

	quxbaz(x)
}