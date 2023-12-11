const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const WeekdayAttribute = Helper.bitmask(Number, ["Nil", 0, "Weekend", 1]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, WeekdayAttribute.Nil, "TUESDAY", 1, WeekdayAttribute.Nil, "WEDNESDAY", 2, WeekdayAttribute.Nil, "THURSDAY", 3, WeekdayAttribute.Nil, "FRIDAY", 4, WeekdayAttribute.Nil, "SATURDAY", 5, WeekdayAttribute.Weekend, "SUNDAY", 6, WeekdayAttribute.Weekend);
};