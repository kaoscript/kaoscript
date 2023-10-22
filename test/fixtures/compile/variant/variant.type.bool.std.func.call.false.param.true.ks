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

func greeting(event: Event(false)): String {
	return event.expecting
}

echo(greeting({ ok: true, value: 'hello' }))