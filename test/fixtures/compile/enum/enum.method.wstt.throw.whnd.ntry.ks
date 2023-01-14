 enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    static fromString(value: String): Weekday ~ Error {
        match value {
            'monday' => return MONDAY
        }

        throw new Error()
    }
}

var day = Weekday.fromString('monday')

export Weekday