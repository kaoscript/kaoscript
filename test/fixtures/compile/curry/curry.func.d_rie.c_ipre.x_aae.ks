func add(...values: Number) {
}

var addOne = add^^(1, ...)

func foobar(x, y) {
	echo(addOne(x, y))
}