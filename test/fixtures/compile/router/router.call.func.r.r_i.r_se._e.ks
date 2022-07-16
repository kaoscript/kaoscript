func foobar(...args, x: Number): Number {
	return x
}
func foobar(...args, x: String): String {
	return x
}
func foobar(...args) {
	return null
}

const i = `\(foobar())`