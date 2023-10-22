type Event = {
	variant ok: Boolean {
		false {
			expecting: String
		}
		true {
			value: String
		}
	}
}