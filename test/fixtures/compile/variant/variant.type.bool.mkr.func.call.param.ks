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

func greeting(event: Event): String {
	if event.ok {
		return event.value
	}
	else {
		return event.expecting
	}
}

echo(greeting({ ok: true, value: 'hello' }))