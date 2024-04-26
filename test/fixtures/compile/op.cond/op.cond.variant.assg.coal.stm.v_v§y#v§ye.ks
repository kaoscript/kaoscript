type Event = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: String
		}
	}
}

func foobar(mut x: Event, mut y: Event(Y)): Event(Y) {
	x ?]]= y

	return x
}