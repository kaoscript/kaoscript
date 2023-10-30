func log(...args) {
	echo(...args)
}

func foobar(info: String[], machine) {
	var logHello = log^^(machine, ':', ...info, ...)

	logHello('foo')
}