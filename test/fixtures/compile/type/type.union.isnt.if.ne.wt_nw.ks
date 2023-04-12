class Foobar {
}

func foobar(mut x: Foobar | String | Number, y) {
	if x is not String {
		x = Foobar.new()
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}