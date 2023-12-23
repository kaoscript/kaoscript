const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isWeekend: value => value === Weekday.SATURDAY || value === Weekday.SUNDAY
	};
	const DayAttr = Helper.bitmask(Number, ["Default", 0, "Weekend", 1]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, DayAttr.Default, "TUESDAY", 1, DayAttr.Default, "WEDNESDAY", 2, DayAttr.Default, "THURSDAY", 3, DayAttr.Default, "FRIDAY", 4, DayAttr.Default, "SATURDAY", 5, DayAttr.Weekend, "SUNDAY", 6, DayAttr.Weekend);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day) {
		return (() => {
			const o = new OBJ();
			o.day = day;
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isWeekend;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};