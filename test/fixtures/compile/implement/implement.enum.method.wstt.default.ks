enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

impl Weekday {
	static fromString(value: String): Weekday? {
        match value {
            'monday' => return MONDAY
        }

        return null
    }
}

var day = Weekday.fromString('monday')

export Weekday