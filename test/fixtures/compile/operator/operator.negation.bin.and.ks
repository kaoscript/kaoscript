func foobar(args: Array) {
	var dyn src

	if !((src ?= args[0]) && src is Object) {
	}
}