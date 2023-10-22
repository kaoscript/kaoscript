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

func greeting(event: Event): String {
	if event.ok {
		return event.value
	}
	else {
		return event.expecting
	}
}

var event = { ok: true, value: 'hello' }

echo(greeting(event))