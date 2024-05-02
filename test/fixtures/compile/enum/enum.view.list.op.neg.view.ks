enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type WorkingDay6 = Weekday(!SUNDAY)
type WorkingDay5 = WorkingDay6(!SATURDAY)