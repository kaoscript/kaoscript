func add(...values: Number) {
}

var addOne = add^^(1, ...)

func foobar(values: Number[]) {
	echo(addOne(...values))
}