const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	const WorkingDay = Helper.alias(value => value === Weekday.MONDAY || value === Weekday.TUESDAY || value === Weekday.WEDNESDAY || value === Weekday.THURSDAY || value === Weekday.FRIDAY);
	function isWorkingDay() {
		return isWorkingDay.__ks_rt(this, arguments);
	};
	isWorkingDay.__ks_0 = function(day) {
		return WorkingDay.is(day);
	};
	isWorkingDay.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Weekday);
		if(args.length === 1) {
			if(t0(args[0])) {
				return isWorkingDay.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};