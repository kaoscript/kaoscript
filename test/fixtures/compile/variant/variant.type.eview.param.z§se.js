const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const DayAttr = Helper.bitmask(Number, ["Default", 0, "Weekend", 1]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, DayAttr.Default, "TUESDAY", 1, DayAttr.Default, "WEDNESDAY", 2, DayAttr.Default, "THURSDAY", 3, DayAttr.Default, "FRIDAY", 4, DayAttr.Default, "SATURDAY", 5, DayAttr.Weekend, "SUNDAY", 6, DayAttr.Weekend);
	const Weekend = Helper.alias(value => value === Weekday.SATURDAY || value === Weekday.SUNDAY);
	const WeekendData = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
		if(cast) {
			if((variant = Weekday(variant)) === null || !Weekend.is(variant)) {
				return false;
			}
			value["kind"] = variant;
		}
		else if(!Weekend.is(variant)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		return true;
	}}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => WeekendData.is(value, 0, value => value === Weekday.SUNDAY);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};