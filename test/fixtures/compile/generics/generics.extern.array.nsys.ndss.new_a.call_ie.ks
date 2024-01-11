extern class Stack<T> {
	pop(): T?
	push(...elements: T): Number
}

var stack = Stack.new()

stack.push(0, 2, 4)

if var value ?= stack.pop() {
	echo(`\(value)`)
}