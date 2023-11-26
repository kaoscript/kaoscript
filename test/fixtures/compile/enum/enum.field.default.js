const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 2, "dayOfWeek", "printableName", "MONDAY", 1, 1, "Monday", "TUESDAY", 2, 2, "Tuesday", "WEDNESDAY", 3, 3, "Wednesday", "THURSDAY", 4, 4, "Thursday", "FRIDAY", 5, 5, "Friday", "SATURDAY", 6, 6, "Saturday", "SUNDAY", 7, 7, "Sunday");
};