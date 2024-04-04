#![libstd(package='npm:@kaoscript/runtime/src/libstd/atomic.ks')]

extern system class Array<T> {
	pop(): T?
	push(...elements: T): Number
}

var stack: String[] = []

stack.push('hello', 'world')

if var value ?= stack.pop() {
	echo(`\(value)`)
}