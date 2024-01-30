extern class Stack<T> {
	pop(): T?
}

func foobar(values: Stack) {
	var x: Number = values.pop()!?
}