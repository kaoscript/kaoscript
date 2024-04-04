#![libstd(off)]
#![rules(ignore-misfit)]

disclose Array<T is Any?> {
	push(...elements: T): Number
}

func foobar(values: Array<String>, x) {
	values.push(x)
}