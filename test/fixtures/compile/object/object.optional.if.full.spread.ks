func foobar(args, flag) {
	var value = {
		...args
		foobar: 1 if flag
	}

	return value
}