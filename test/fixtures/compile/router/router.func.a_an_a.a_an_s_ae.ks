extern console

func foobar(a, b? = null, c) {
	console.log(a, b, c)
}
func foobar(a, b? = null, c: String, d) {
	console.log(a, b, c, d)
}