const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 2, "dayOfWeek", "printableName", "MONDAY", 0, 1, "Monday", "TUESDAY", 1, 2, "Tuesday", "WEDNESDAY", 2, 3, "Wednesday", "THURSDAY", 3, 4, "Thursday", "FRIDAY", 4, 5, "Friday", "SATURDAY", 5, 6, "Saturday", "SUNDAY", 6, 7, "Sunday");
	for(let __ks_1 = 0, __ks_0 = Weekday.values.length, printableName; __ks_1 < __ks_0; ++__ks_1) {
		({printableName} = Weekday.values[__ks_1]);
		console.log(printableName);
	}
};