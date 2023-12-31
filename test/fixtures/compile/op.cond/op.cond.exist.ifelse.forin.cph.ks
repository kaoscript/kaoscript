func foobar(values?) {
	if ?values {
		pass
	}
	else {
		return [value for var value in values]
	}
}