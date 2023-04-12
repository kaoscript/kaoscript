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

        throw Error.new()
    }
}

var day = try Weekday.fromString('monday')

export Weekday