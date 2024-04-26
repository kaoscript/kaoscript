enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type WorkingDay = Weekday(name != 'SATURDAY' & 'SUNDAY')

func isWorkingDay(day: Weekday) {
    return day is WorkingDay
}