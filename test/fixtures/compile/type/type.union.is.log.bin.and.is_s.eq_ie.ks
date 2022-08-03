class Foobar {
}

func foobar(mut x: Foobar | String | Number, y) {
	if x is String && y == 0 {
		x = new Foobar()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}