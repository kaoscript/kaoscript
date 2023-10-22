type Event = {
	variant ok: Boolean {
		false, N {
			expecting: String
		}
		true, Y {
			value: String
		}
	}
}