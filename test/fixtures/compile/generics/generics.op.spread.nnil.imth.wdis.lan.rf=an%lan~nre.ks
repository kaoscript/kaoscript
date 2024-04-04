#![libstd(off)]

extern system class Array<T>

disclose Array<T is Any?> {
	push(...elements: T): Number
}

func foobar(values: Array) {
	values.push(...quxbaz()!?)
}

func quxbaz() {
	return []
}