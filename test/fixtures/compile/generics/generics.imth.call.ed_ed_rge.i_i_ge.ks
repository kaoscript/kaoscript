extern system class Array<T> {
	length: Number
	splice(start: Number = 0, deleteCount: Number = 0, ...items: T): T[]
}

func foobar<T>(values: T[], value: T) {
	values.splice(0, 5, value)
}