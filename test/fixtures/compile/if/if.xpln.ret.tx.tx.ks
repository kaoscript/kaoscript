func throw(): Never ~ Error {
	throw Error.new()
}

func foobar(x): String ~ Error {
	return if x set throw() else throw()
}