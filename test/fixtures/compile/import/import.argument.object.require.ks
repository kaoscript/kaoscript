extern console

require foobar: {
	func waldo(): String
}

console.log(`\(foobar.waldo())`)