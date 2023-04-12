class Foobar {
}

func foobar(mut x: Foobar | String | Number, y) {
	if x is String || y == 0 || x is Number {
		x = Foobar.new()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}