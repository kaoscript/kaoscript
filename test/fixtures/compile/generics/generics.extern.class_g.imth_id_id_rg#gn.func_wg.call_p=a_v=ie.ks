extern class Stack<T> {
	splice(start: Number = 0, deleteCount: Number = 0, ...items: T): T[]
}

func foobar(values: Stack, index) {
	var deleteds = values.splice(index, 10)

	for var del in deleteds {
		echo(`\(del)`)
	}
}