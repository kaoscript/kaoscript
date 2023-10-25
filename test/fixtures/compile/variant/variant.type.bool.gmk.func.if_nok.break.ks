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

func foobar() {
	while true {
		var event = getEvent()

		if !event.ok {
			break
		}

		echo(`\(event.value)`)
	}
}

func getEvent(): Event<String> {
	return { ok: false }
}