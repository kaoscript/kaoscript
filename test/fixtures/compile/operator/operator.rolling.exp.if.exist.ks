extern system class Array<T> {
	push(...elements: T): Number
}

func foobar(value: Number?, result: []) {
	result
		..push(0)
		..push(value) if ?value
}