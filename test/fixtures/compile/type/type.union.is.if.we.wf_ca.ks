class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is String {
	}
	else {
		quxbaz(x)
	}
}

func quxbaz(x: Foobar) {

}