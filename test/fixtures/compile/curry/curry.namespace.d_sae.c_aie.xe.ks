namespace Foobar {
	export func add(x: String, y) {
	}
}

func add(x: String, y) {
}

func foobar(x) {
	var addZero = add^^(x, 10)

	var addOne = Foobar.add^^(x, 10)
}