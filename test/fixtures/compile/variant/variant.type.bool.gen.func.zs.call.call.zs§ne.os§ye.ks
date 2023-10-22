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

func quxbaz(): Event<String>(N) {
	return { ok: true, value: 'hello' }
}

foobar(quxbaz())