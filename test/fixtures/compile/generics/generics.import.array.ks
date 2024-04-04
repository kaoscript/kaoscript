#![libstd(off)]

extern console

import './generics.export.array.ks'

var stack: String[] = []

stack.push('hello', 'world')

if var value ?= stack.pop() {
	console.log(`\(value)`)
}