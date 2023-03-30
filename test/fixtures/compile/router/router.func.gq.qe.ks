struct Foobar {
	x
	y
}

func foobar({x, y}: Foobar) {
	return 1
}

func foobar(x: Foobar) {
	return 2
}