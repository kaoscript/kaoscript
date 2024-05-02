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

func foobar(x: Event) {
	var mut t = null

	if t !?]= x {
	}
}