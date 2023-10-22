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

func foobar(event: Event<String>) {
	if event.ok {
		echo(`\(event.value)`)
	}
}

func quxbaz(): Event<String>(Y) {
	return { ok: false, expecting: 'name' }
}

foobar(quxbaz())