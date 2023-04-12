class Foobar {
}

func foobar(mut x: Foobar | String | Number, y, z) {
	if x is String && y == 0 && z == 0 {
		x = Foobar.new()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}