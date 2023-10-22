type Event<T> = {
	variant ok: Boolean {
		false {
			expecting: String
		}
		true {
			value: T
		}
	}
}

func foobar(event: Event) {
	if event.ok {
		echo(`\(event.value)`)
	}
}

foobar({ ok: true, value: 'hello' })