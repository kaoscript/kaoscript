extern sealed class Date {
	setDate(value: Number): Number
}

impl Date {
	overwrite setDate(value: Number | String): Date {
		precursor(value)

		return this
	}
}

func foobar(d: Date) {

}

var d = Date.new()

foobar(d.setDate(1))

export Date