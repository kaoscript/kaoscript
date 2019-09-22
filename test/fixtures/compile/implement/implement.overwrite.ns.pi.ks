require class Date {
	setDate(value: Number): Number
}

impl Date {
	overwrite setDate(value: Number): Date {
		precursor(value)

		return this
	}
}