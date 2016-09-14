extern console: {
	log(...args)
}

func foo(...items) {
	console.log(items)
}

func bar(x, ...items) {
	console.log(x, items)
}

func baz(x, ...items, z) {
	console.log(x, items, z)
}

func qux(x, ...items, z = 1) {
	console.log(x, items, z)
}

func quux(x = 1, ...items, z = 1) {
	console.log(x, items, z)
}

func corge(...items = [1..5]) {
	console.log(items)
}

func grault(...items, z) {
	console.log(items, z)
}

func garply(...items, z = 1) {
	console.log(items, z)
}

func waldo(...items, x, y, z) {
	console.log(items, x, y, z)
}

func fred(...items, x, y = 1, z) {
	console.log(items, x, y, z)
}