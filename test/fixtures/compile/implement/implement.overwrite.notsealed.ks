require class Foobar {
	setDate(value: Number): Number
}

impl Foobar {
	overwrite setDate(value: Number): Date {
		precursor(value)

		return this
	}
}