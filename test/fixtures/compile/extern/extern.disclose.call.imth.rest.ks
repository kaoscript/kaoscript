#![libstd(off)]

extern system class Array<T>

disclose Array<T is Any?> {
	length: Number
	splice(start: Number = 0, deleteCount: Number = 0, ...items: T): T[]
}

func foobar(values: Array) {
	values.splice(0, 1)
}