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

func yes(): Event<Null>(Y) => { ok: true }

func foobar(mut top: Event = NO) {
	if !top.ok {
		top = yes()
	}

	quxbaz(top)
}

func quxbaz(event: Event(Y)) {
}