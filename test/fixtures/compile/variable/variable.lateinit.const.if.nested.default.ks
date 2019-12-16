func quxbaz(): Number => 42

func foobar() {
	lateinit const x

	if const a = quxbaz() {
		if a == 0 {
			x = -1
		}
		else {
			x = a
		}
	}
	else {
		x = 0
	}

	return x + 2
}