enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    foobar(...values, x, y, z): Boolean {
		return false
	}
}

func foobar(day: Weekday) {
    if day.foobar(1, 2, 3) {
    }
}

export Weekday