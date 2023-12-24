bitmask WeekdayAttribute {
	Nil

	Weekend
	Working
}

enum Weekday {
    MONDAY		= (.Working)
    TUESDAY		= (.Working)
    WEDNESDAY	= (.Working)
    THURSDAY	= (.Working)
    FRIDAY		= (.Working)
    SATURDAY	= (.Working + .Weekend)
    SUNDAY		= (.Weekend)

	const attribute: WeekdayAttribute
}