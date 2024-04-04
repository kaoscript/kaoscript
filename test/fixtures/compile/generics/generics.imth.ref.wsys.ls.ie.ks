#![libstd(off)]

extern system class Array<T>

disclose Array<T is Any?> {
	push(...elements: T): Number
}

func foobar(values: String[], x) {
	var fn = values.push

	fn(0)

	quxbaz(fn)
}

func quxbaz(fn: Function) {
	fn('Hello!')
}