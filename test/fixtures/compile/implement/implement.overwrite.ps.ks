extern sealed class Date {
	setDate(value: Number): Number
}

impl Date {
	overwrite setDate(value: String): Date {
		precursor(value)

		return this
	}
}

func foobar(d: Date) {

}

var d = new Date()

foobar(d.setDate(1))

export Date