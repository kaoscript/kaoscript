class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x == 0 || x is not String {
		quxbaz(x)
	}
}

func quxbaz(x: Foobar) {

}