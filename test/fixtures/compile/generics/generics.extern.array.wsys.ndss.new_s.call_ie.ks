#![libstd(package='npm:@kaoscript/runtime/src/libstd/atomic.ks')]

extern system class Array<T> {
	pop(): T?
	push(...elements: T): Number
}

var stack: String[] = []

stack.push(0, 2, 4)

if var value ?= stack.pop() {
	echo(`\(value)`)
}