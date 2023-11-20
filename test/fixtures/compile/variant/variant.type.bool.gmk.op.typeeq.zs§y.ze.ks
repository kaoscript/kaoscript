type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String
		}
		true, Y {
			value: T
		}
	}
}

func foobar(event: Event<String>(Y)) {
	if event is Event {
		echo(`\(event.value)`)
	}
}