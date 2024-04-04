func log(...args) {
	echo(...args)
}

func foobar(info, machine) {
	var logHello = log^^(machine, ':', ...info, ...)

	logHello('foo')
}