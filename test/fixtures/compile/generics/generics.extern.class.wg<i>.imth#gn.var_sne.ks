extern class Stack<T> {
	pop(): T?
}

func foobar(values: Stack<Number>) {
	var x: String? = values.pop()
}