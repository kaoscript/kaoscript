class Foobar {
	x(): Number => 0
}

func foobar(x: Foobar?, y) {
	var a = x?.x() ?? y
}