type Event = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: String
		}
	}
}

func foobar(mut x: Event(N), mut y: Event) {
	x ?]]= y
}