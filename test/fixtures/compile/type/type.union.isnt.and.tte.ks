class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is not String && x is not Number {
		quxbaz(x)
	}
}

func quxbaz(x: Foobar) {

}