type Event = {
	variant ok: Boolean {
		false, N {
			expecting: String
		}
		true, Y {
			value: String
		}
	}
}

func greeting(event: Event(true)): String {
	return event.value
}

echo(greeting({ ok: true, value: 'hello' }))