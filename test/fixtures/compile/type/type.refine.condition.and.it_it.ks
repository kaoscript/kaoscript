func foobar(a?, b?) {
	if a is String && b is String {
		return a.toLowerCase() == b.toLowerCase()
	}
	else {
		return false
	}
}