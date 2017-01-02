#![cfg(format(variables='es6'))]

extern console, foo

if items ?= foo() {
	for item in items {
		console.log(items)
	}
}