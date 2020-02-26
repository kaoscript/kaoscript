enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    static fromString(value: String): Weekday? {
        switch value {
            'monday' => return MONDAY
        }

        return null
    }
}

const day = Weekday.fromString('monday')

export Weekday