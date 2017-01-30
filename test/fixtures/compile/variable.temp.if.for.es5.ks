#![format(variables='es5')]

extern console, foo

if items ?= foo() {
	for item in items {
		console.log(items)
	}
}