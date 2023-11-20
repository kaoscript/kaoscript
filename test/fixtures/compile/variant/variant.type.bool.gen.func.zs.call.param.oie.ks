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

func foobar(event: Event<String>) {
	if event.ok {
		echo(`\(event.value)`)
	}
}

foobar({ ok: true, value: 42 })