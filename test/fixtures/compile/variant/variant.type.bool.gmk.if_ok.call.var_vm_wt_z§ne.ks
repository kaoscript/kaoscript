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
	var mut event: Event = { ok: false }

	if event.ok {
		echo(`\(event.value)`)

		quxbaz(event)
	}
}

func quxbaz(event: Event(Y)) {
}