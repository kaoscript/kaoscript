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

var NO: Event(N) = { ok: false }

func foobar(): Event<String> {
	return NO
}