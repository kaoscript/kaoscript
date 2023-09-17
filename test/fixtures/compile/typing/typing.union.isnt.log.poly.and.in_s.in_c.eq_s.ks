class Foobar {
}

func foobar(x: Foobar | String | Number, y) {
	if x is not String && x is not Foobar && x == '3' {
		quxbaz(x)
	}
}

func quxbaz(x: Foobar) {

}