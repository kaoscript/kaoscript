class Foobar {
}

func foobar(mut x: Foobar | String | Number, y) {
	if y == 0 || x is String {
		x = new Foobar()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}