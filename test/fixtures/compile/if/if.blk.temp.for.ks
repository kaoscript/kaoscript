extern console, foo

var dyn items, item

if items ?= foo() {
	for item in items {
		console.log(items)
	}
}