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

func foobar(event: Event<String>(true)) {
	echo(`\(event.value)`)
}

var event: Event<String>(true) = { ok: false, expecting: 'hello' }

foobar(event)