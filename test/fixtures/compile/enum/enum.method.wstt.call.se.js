const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, {
		MONDAY: 0,
		TUESDAY: 1,
		WEDNESDAY: 2,
		THURSDAY: 3,
		FRIDAY: 4,
		SATURDAY: 5,
		SUNDAY: 6
	});
	Weekday.__ks_sttc_fromString_0 = function(value) {
		if(value === "monday") {
			return Weekday.MONDAY;
		}
		return null;
	};
	Weekday.fromString = function() {
		const t0 = Type.isString;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return Weekday.__ks_sttc_fromString_0(arguments[0]);
			}
		}
		throw Helper.badArgs();
	};
	const day = Weekday.__ks_sttc_fromString_0("monday");
	return {
		Weekday
	};
};