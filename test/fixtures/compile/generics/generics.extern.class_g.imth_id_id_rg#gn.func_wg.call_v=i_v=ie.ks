extern class Stack<T> {
	splice(start: Number = 0, deleteCount: Number = 0, ...items: T): T[]
}

func foobar(values: Stack) {
	var deleteds = values.splice(0, 10)

	for var del in deleteds {
		echo(`\(del)`)
	}
}