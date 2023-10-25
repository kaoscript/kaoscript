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

func foobar(): Event {
	return { ok: false }
}

var mut { ok } = foobar()

ok = true