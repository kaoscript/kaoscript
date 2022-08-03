class Foobar {
}

func foobar(mut x: Foobar | String | Number, y) {
	if x is not String {
		x = new Foobar()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}