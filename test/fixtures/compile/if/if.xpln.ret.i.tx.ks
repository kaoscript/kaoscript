func throw(): Never ~ Error {
	throw Error.new()
}

func foobar(x): Number ~ Error {
	return if x set 0 else throw()
}