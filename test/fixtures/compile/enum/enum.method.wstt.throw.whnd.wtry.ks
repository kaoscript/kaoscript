 enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    static fromString(value: String): Weekday ~ Error {
        switch value {
            'monday' => return MONDAY
        }

        throw new Error()
    }
}

var day = try Weekday.fromString('monday')

export Weekday