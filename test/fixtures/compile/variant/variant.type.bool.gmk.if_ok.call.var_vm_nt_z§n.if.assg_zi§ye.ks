type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String?
		}
		true, Y {
			value: T
		}
	}
}

func foobar(load: Boolean) {
	var mut event = { ok: false }

	if load {
		event = { ok: true, value: 0 }
	}

	if event.ok {
		echo(`\(event.value)`)

		quxbaz(event)
	}
}

func quxbaz(event: Event(Y)) {
}