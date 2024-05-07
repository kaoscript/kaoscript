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

func quxbaz(day: Weekday(!SATURDAY, !SUNDAY)) {
}

export *