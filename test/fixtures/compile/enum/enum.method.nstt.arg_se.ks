enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    isSameAs(day: String): Boolean {
		match this {
			MONDAY => return day == 'monday'
		}

		return false
	}
}

func foobar(day: Weekday) {
    if day.isSameAs('tuesday') {
    }
}

export Weekday