extern sealed class Date {
	setDate(value: Number): Number
}

impl Date {
	overwrite setDate(value: Number, flag: Boolean = true): Date {
		precursor(value)

		return this
	}
}

func foobar(d: Date) {

}

const d = new Date()

foobar(d.setDate(1))

export Date