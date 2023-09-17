func foobar(a?, b?) {
	if a is not String || b is not String {
		return false
	}
	else {
		return a.toLowerCase() == b.toLowerCase()
	}
}