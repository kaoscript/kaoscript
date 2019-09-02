func foobar(x?) {
	if x?.y()? {
		return x.z()
	}
}