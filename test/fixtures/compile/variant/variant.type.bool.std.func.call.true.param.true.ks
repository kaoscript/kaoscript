type Event = {
	variant ok: Boolean {
		false {
			expecting: String
		}
		true {
			value: String
		}
	}
}

func greeting(event: Event(true)): String {
	return event.value
}

echo(greeting({ ok: true, value: 'hello' }))