func log(...args) {
	echo(...args)
}

func foobar(info: String[]) {
	var logHello = log^^(...info, ...)

	logHello('foo')
}