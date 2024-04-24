func foobar(...args) {
	var mut value: Array? = null

	var mut i = 0
	var l = args.length

	while i < l {
		if args[i] is Array {
			value = args[i]

			break
		}

		i += 1
	}

	if value is Array {
	}
}