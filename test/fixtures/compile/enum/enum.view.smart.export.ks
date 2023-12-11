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

export Weekday, Weekend