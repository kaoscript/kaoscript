class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is String {
		return
	}
	else {
		quxbaz(x)
	}
}

func quxbaz(x: Foobar) {

}