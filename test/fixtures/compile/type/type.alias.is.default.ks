type NS = Number | String

func foobar(mut x: NS) {
	if x is String {
		x = 42
	}

	quxbaz(x)
}

func quxbaz(x: Number) {
}