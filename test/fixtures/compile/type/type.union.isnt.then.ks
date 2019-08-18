class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is not String {
		quxbaz(x)
	}
}

func quxbaz(x: Foobar) {

}