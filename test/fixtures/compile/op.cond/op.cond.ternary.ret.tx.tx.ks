func throw(): Never ~ Error {
	throw Error.new()
}

func foobar(x): String ~ Error {
	x ? throw() : throw()
}