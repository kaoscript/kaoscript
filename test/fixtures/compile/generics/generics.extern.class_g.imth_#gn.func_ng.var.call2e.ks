extern class Stack<T> {
	pop(): T?
}

func foobar(values: Stack) {
	var x = values.pop()

	x.pop()

	echo(x)
}