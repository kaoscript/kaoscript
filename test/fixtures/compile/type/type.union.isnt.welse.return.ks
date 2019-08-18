class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is not String {
		return
	}
	else {
		quxbaz(x)
	}
}

func quxbaz(x: Foobar) {

}