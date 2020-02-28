enum Weekday {
	MONDAY
	TUESDAY
	WEDNESDAY
	THURSDAY
	FRIDAY
	SATURDAY
	SUNDAY
}

func foobar(day: Weekday, month: Number) {
	return 0
}
func foobar(day: Weekday, month: String) {
	return 1
}
func foobar(day: String, month: Number) {
	return 2
}
func foobar(day: String, month: String) {
	return 3
}

foobar('', -1)