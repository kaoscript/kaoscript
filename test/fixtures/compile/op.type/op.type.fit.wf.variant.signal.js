const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const DayAttr = Helper.bitmask(Number, ["Default", 0, "Weekend", 1]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, DayAttr.Default, "TUESDAY", 1, DayAttr.Default, "WEDNESDAY", 2, DayAttr.Default, "THURSDAY", 3, DayAttr.Default, "FRIDAY", 4, DayAttr.Default, "SATURDAY", 5, DayAttr.Weekend, "SUNDAY", 6, DayAttr.Weekend);
	const Weekend = Helper.alias(value => value === Weekday.SATURDAY || value === Weekday.SUNDAY);
	const WeekendJob = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {day: variant => {
		if(cast) {
			if((variant = Weekday(variant)) === null || !Weekend.is(variant)) {
				return false;
			}
			value["day"] = variant;
		}
		else if(!Weekend.is(variant)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		return true;
	}, name: Type.isString}));
	function getWeekendJob() {
		return getWeekendJob.__ks_rt(this, arguments);
	};
	getWeekendJob.__ks_0 = function(day, name) {
		return (() => {
			const o = new OBJ();
			o.day = day;
			o.name = name;
			return o;
		})();
	};
	getWeekendJob.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Weekday);
		const t1 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return getWeekendJob.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};