#![libstd(off)]

extern system class Array<T>

disclose Array<T is Any?> {
	push(...elements: T): Number
}

func foobar(values: String[]) {
	values.push(quxbaz()!?, quxbaz()!?, quxbaz()!?)
}

func quxbaz() {
	return ''
}