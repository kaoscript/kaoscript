enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

func foobar(day: String): Weekday? {
	return day:>?(Weekday)
}