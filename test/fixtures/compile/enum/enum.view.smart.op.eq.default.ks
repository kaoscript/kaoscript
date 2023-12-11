enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type Weekend = Weekday(name == 'SATURDAY' | 'SUNDAY')

func isWeekend(day: Weekday) {
    return day is Weekend
}