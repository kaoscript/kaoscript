enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    isWeekend(): Boolean ~ Error {
		throw Error.new()
	}
}

func foobar(day: Weekday) {
    if day.isWeekend() {
    }
}

export Weekday