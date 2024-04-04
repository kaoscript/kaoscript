#![libstd(off)]

extern system class Array<T>

disclose Array<T is Any?> {
	push(...elements: T): Number
}

func foobar(values: String[]) {
	var fn = values.push

	fn('Hello!')

	quxbaz(fn)
}

func quxbaz(fn: Function) {
	fn('Hello!')
}