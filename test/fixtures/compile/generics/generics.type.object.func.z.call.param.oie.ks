type Event<T> = {
	ok: Boolean
	value: T
}

func foobar(event: Event) {
	if event.ok {
		echo(`\(event.value)`)
	}
}

foobar({ ok: true, value: 42 })