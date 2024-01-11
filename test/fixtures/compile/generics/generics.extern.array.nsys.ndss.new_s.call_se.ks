extern class Stack<T> {
	pop(): T?
	push(...elements: T): Number
}

var stack = Stack<String>.new()

stack.push('hello', 'world')

if var value ?= stack.pop() {
	echo(`\(value)`)
}