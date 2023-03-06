func add(...values: Number) {
}

var addOne = add^^(1, ...)

func foobar(values: []) {
	echo(addOne(...values))
}