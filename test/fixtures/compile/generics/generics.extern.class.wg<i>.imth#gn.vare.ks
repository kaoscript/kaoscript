extern class Stack<T> {
	pop(): T?
}

func foobar(values: Stack<Number>) {
	var x = values.pop()
}