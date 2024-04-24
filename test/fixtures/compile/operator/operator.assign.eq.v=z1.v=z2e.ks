type Range = {
	start: Number
	end: Number
}

type Event = {
	value: String
	start: Number
	end: Number
}

func foobar(test: Boolean, e: Event): Range {
	var mut r: Range? = null

	if test {
		r = e

		return r
	}

	return e
}