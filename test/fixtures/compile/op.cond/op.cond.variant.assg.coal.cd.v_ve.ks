type Event = {
	variant ok: Boolean {
		false {
			message: String
		}
		true {
			value: String
		}
	}
}

func foobar(mut x: Event, mut y: Event) {
	if x ?||= y {
	}
}