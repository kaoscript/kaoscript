func foobar(...args) {
	var mut value: Array? = null

	var mut i = 0
	var l = args.length

	while i < l && (value <- args[i]) is not Array {
		i += 1
	}

	if value is Array {
	}
}