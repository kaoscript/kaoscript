#![libstd(off)]

extern system class Array<T>

disclose Array<T> {
	unshift(...elements: T): Number
}

func foobar(): String[] {
	return []
}

func quxbaz(): Number[] {
	return []
}

var modifiers = quxbaz()

modifiers.unshift(...quxbaz())

var nodes = foobar()

nodes.unshift(...foobar())