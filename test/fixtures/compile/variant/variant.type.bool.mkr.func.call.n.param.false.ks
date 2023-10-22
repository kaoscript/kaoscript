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

func greeting(event: Event(N)): String {
	return event.expecting
}

echo(greeting({ ok: false, expecting: 'name' }))