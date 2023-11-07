enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

	WEEKEND = SATURDAY | SUNDAY

    static WEEKEND(that: Weekday): Boolean => that == SATURDAY | SUNDAY
}