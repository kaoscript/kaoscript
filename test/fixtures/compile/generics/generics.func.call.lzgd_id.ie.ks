type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
		}
	}
}

func foobar(event: Event[] = [], mode: Number = 0) {
}

foobar(42)