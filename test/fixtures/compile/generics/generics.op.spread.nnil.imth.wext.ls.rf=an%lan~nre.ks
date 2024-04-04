#![libstd(off)]

extern system class Array<T is Any?> {
	push(...elements: T): Number
}

func foobar(values: String[]) {
	values.push(...quxbaz()!?)
}

func quxbaz() {
	return []
}