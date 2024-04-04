#![libstd(off)]

extern system class Array<T>

disclose Array<T> {
	pop(): T?
	push(...elements: T): Number
}

export Array