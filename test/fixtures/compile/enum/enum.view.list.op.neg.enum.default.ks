enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type WorkingDay = Weekday(!SATURDAY, !SUNDAY)

func isWorkingDay(day: Weekday) {
    return day is WorkingDay
}