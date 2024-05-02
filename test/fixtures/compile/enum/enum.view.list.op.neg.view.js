const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isWorkingDay6: value => value === Weekday.MONDAY || value === Weekday.TUESDAY || value === Weekday.WEDNESDAY || value === Weekday.THURSDAY || value === Weekday.FRIDAY || value === Weekday.SATURDAY,
		isWorkingDay5: value => value === Weekday.MONDAY || value === Weekday.TUESDAY || value === Weekday.WEDNESDAY || value === Weekday.THURSDAY || value === Weekday.FRIDAY
	};
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
};