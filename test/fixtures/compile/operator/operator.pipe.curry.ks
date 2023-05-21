extern {
	func filter(value: Array, fn: Function): Array
	func map(value: Array, fn: Function): Array
}

func process(elements: Array): Array {
	return elements
		|> map(_, add^^(^, 1))
		|> filter(_, greaterThan^^(^, 5))
}


func add(x, y) => x + y
func greaterThan(x, y) => x > y