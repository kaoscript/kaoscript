func foobar(x) {
	var dyn parent = x.parent()

	while parent ?= parent.parent() {

	}
}