func foobar(x) {
	var mut y = null

	y ?= x()

	echo(y)
}