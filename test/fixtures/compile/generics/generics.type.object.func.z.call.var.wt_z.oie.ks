type Event<T> = {
	ok: Boolean
	value: T
}

func foobar(event: Event) {
	if event.ok {
		echo(`\(event.value)`)
	}
}

var event: Event = { ok: true, value: 42 }

foobar(event)