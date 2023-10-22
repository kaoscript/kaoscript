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

func foobar(event: Event<String>(Y)) {
	echo(`\(event.value)`)
}

func quxbaz(): Event<String>(N) {
	return { ok: false, expecting: 'value' }
}

foobar(quxbaz())