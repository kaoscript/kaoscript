const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isWeekdayData: (value, cast) => Type.isDexObject(value, 1, 0, {kind: () => Type.isNull(value) || Helper.castEnum(value, "kind", Weekday, cast)})
	};
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
};