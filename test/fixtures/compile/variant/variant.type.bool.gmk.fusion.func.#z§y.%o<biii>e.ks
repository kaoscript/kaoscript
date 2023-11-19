type Position = {
	line: Number
	column: Number
}

type Event<T> = Position & {
	variant ok: Boolean {
		false, N {
			expecting: String?
		}
		true, Y {
			value: T
		}
	}
}

func foobar(): Event(Y) {
	return { ok: true, value: 0, line: 0, column: 0 }
}