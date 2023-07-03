#![cfg(format(variables='es6'))]

extern console, foo

if ?foo {
	var dyn items

	if foo.foo() {
	}
	else if items ?= foo.bar() {
	}
}