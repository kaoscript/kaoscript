type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String?
		}
		true, Y {
			value: T
			line: Number
			column: Number
		}
	}
}

func foobar(value: { line: Number, column: Number }): Event(Y) {
	return {
		ok: true
		value
		...value { line, column }
	}
}