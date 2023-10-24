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

var NO: Event = { ok: false }

func quxbaz(first: Event = NO) {
}

quxbaz()