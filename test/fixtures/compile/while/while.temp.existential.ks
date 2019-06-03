func foobar(x) {
	let parent = x.parent()

	while parent ?= parent.parent() {

	}
}