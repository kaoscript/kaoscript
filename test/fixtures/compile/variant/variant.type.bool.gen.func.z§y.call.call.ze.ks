type Event<T> = {
	variant ok: Boolean {
		false {
			expecting: String
		}
		true {
			value: T
		}
	}
}

func foobar(event: Event(true)) {
	echo(`\(event.value)`)
}

func quxbaz(): Event {
	return { ok: true, value: 42 }
}

foobar(quxbaz())