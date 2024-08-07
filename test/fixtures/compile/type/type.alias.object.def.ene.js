const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	const WeekdayData = Helper.alias((value, cast) => Type.isDexObject(value, 1, 0, {kind: () => Type.isNull(value["kind"]) || Helper.castEnum(value, "kind", Weekday, cast)}));
};