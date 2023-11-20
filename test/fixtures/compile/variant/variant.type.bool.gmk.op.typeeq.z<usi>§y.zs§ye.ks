type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String
		}
		true, Y {
			value: T
		}
	}
}

func foobar(event: Event<String | Number>(Y)) {
	if event is Event<String>(Y) {
		echo(`\(event.value)`)
	}
	else {
		echo(event.value + 1)
	}
}