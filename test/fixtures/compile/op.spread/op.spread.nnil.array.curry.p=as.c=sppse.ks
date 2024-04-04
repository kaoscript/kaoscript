func log(...args) {
	echo(...args)
}

func foobar(info, user: String) {
	var logHello = log^^(...info, user, ': ', ...)

	logHello('foo')
}