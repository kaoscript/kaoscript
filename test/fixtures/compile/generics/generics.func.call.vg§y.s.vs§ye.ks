type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String?
		}
		true, Y {
			value: T
			line: Number?
			column: Number?
		}
	}
}

func foobar<T>(value: T): Event<T>(Y) {
	return {
		ok: true
		value
	}
}

func quxbaz(value: String): Event<String>(Y) {
	return foobar(value)
}