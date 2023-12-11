enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type Weekend = Weekday(SATURDAY, SUNDAY)

func foobar(day: Weekend) {
}

var day = Weekday.SATURDAY

foobar(day)