const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const WeekdayAttribute = Helper.bitmask(Number, ["Nil", 0, "Children", 1, "Weekend", 2, "Working", 4]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, WeekdayAttribute.Working, "TUESDAY", 1, WeekdayAttribute.Working, "WEDNESDAY", 2, WeekdayAttribute(WeekdayAttribute.Working | WeekdayAttribute.Children), "THURSDAY", 3, WeekdayAttribute.Working, "FRIDAY", 4, WeekdayAttribute.Working, "SATURDAY", 5, WeekdayAttribute(WeekdayAttribute.Working | WeekdayAttribute.Weekend | WeekdayAttribute.Children), "SUNDAY", 6, WeekdayAttribute(WeekdayAttribute.Weekend | WeekdayAttribute.Children));
};