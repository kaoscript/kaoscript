const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isWeekend: value => value === Weekday.SATURDAY || value === Weekday.SUNDAY
	};
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	return {
		Weekday,
		__ksType: [__ksType.isWeekend]
	};
};