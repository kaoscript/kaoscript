class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is not String {
		x = new Foobar()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}