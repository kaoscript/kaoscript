const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isWeekend: value => value === Weekday.SATURDAY || value === Weekday.SUNDAY,
		isWeekendJob: (value, cast, filter) => Type.isDexObject(value, 1, 0, {day: variant => {
			if(cast) {
				if((variant = Weekday(variant)) === null || !__ksType.isWeekend(variant)) {
					return false;
				}
				value["day"] = variant;
			}
			else if(!__ksType.isWeekend(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === Weekday.SATURDAY) {
				return Type.isDexObject(value, 0, 0, {shop: Type.isString});
			}
			if(variant === Weekday.SUNDAY) {
				return Type.isDexObject(value, 0, 0, {church: Type.isString});
			}
			return true;
		}})
	};
	const DayAttr = Helper.bitmask(Number, ["Default", 0, "Weekend", 1]);
	const Weekday = Helper.enum(Number, 1, "attribute", "MONDAY", 0, DayAttr.Default, "TUESDAY", 1, DayAttr.Default, "WEDNESDAY", 2, DayAttr.Default, "THURSDAY", 3, DayAttr.Default, "FRIDAY", 4, DayAttr.Default, "SATURDAY", 5, DayAttr.Weekend, "SUNDAY", 6, DayAttr.Weekend);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(job) {
		if(job.day === Weekday.SATURDAY) {
			console.log(job.shop);
		}
		else if(job.day === Weekday.SUNDAY) {
			console.log(job.church);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isWeekendJob;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};