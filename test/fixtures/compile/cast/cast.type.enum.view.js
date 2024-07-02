const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const DayAttr = Helper.bitmask(Number, ["Default", 0, "Weekend", 1]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, DayAttr.Default, "TUESDAY", 1, DayAttr.Default, "WEDNESDAY", 2, DayAttr.Default, "THURSDAY", 3, DayAttr.Default, "FRIDAY", 4, DayAttr.Default, "SATURDAY", 5, DayAttr.Weekend, "SUNDAY", 6, DayAttr.Weekend);
	const WeekendDay = Helper.alias(value => value === Weekday.SATURDAY || value === Weekday.SUNDAY);
	const WeekendJob = Helper.alias((value, cast) => Type.isDexObject(value, 1, 0, {name: Type.isString, day: () => Helper.castEnumView(value, "day", Weekday, cast, WeekendDay.is)}));
};