const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const DayAttr = Helper.bitmask(Number, ["Default", 0, "DoubleRate", 1, "Weekend", 2]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, DayAttr.Default, "TUESDAY", 1, DayAttr.Default, "WEDNESDAY", 2, DayAttr.Default, "THURSDAY", 3, DayAttr.Default, "FRIDAY", 4, DayAttr.Default, "SATURDAY", 5, DayAttr.Weekend, "SUNDAY", 6, DayAttr(DayAttr.Weekend | DayAttr.DoubleRate));
	const Weekend = Helper.alias(value => value === Weekday.SATURDAY || value === Weekday.SUNDAY);
	function isWeekend() {
		return isWeekend.__ks_rt(this, arguments);
	};
	isWeekend.__ks_0 = function(day) {
		return Weekend.is(day);
	};
	isWeekend.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Weekday);
		if(args.length === 1) {
			if(t0(args[0])) {
				return isWeekend.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		DayAttr,
		Weekday,
		Weekend,
		isWeekend
	};
};