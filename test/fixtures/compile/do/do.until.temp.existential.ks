func foobar(x) {
	let parent = x.parent()

	do {

	}
	until parent ?= parent.parent()
}