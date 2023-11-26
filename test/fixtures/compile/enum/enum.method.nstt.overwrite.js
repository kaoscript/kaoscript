const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	Weekday.__ks_eq_WEEKEND = value => value === Weekday.SATURDAY || value === Weekday.SUNDAY;
	Weekday.__ks_func_WEEKEND_0 = function(that) {
		return that === Weekday.SATURDAY || that === Weekday.SUNDAY;
	};
	Weekday.__ks_func_WEEKEND = function(that, ...args) {
		if(args.length === 0) {
			return Weekday.__ks_func_WEEKEND_0(that);
		}
		throw Helper.badArgs();
	};
};