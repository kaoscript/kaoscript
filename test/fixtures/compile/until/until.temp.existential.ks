func foobar(x) {
	let parent = x.parent()

	until parent ?= parent.parent() {

	}
}