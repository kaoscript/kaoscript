enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

func foobar(day: Weekday(!SATURDAY, !SUNDAY)) {
}

foobar(Weekday.MONDAY)