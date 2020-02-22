class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is String || x is Number {
		x = new Foobar()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}