const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	const WorkingDay6 = Helper.alias(value => value === Weekday.MONDAY || value === Weekday.TUESDAY || value === Weekday.WEDNESDAY || value === Weekday.THURSDAY || value === Weekday.FRIDAY || value === Weekday.SATURDAY);
	const WorkingDay5 = Helper.alias(value => value === Weekday.MONDAY || value === Weekday.TUESDAY || value === Weekday.WEDNESDAY || value === Weekday.THURSDAY || value === Weekday.FRIDAY);
};