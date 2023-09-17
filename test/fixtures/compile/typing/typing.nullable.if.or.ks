func foobar(x?, y?) {
	if x == null || y == null {
		return null
	}

	return x.foobar() + y.foobar()
}