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

func foobar(value: Event(Y)) {
	return {
		...value { line, column }
	}
}