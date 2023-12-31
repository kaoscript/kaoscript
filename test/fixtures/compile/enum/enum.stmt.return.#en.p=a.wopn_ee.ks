enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

func foobar(day): Weekday? {
	return day:>?(Weekday)
}