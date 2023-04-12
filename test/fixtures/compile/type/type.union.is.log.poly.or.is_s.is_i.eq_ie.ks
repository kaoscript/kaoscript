class Foobar {
}

func foobar(mut x: Foobar | String | Number, y) {
	if x is String || x is Number || y == 0 {
		x = Foobar.new()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}