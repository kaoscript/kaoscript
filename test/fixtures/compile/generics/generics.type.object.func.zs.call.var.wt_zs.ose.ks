type Event<T> = {
	ok: Boolean
	value: T
}

func foobar(event: Event<String>) {
	if event.ok {
		echo(`\(event.value)`)
	}
}

var event: Event<String> = { ok: true, value: 'hello' }

foobar(event)