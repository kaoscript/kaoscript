class Foobar {
}

class Quxbaz extends Foobar {
}

func foobar(test: Boolean): Foobar {
	if test {
		return Quxbaz.new()
	}
	else {
		return Foobar.new()
	}
}