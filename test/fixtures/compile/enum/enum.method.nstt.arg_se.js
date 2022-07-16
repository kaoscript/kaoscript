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
	Weekday.__ks_func_isSameAs_0 = function(that, day) {
		if(that === Weekday.MONDAY) {
			return day === "monday";
		}
		return false;
	};
	Weekday.__ks_func_isSameAs = function(that, ...args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return Weekday.__ks_func_isSameAs_0(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day) {
		if(Weekday.__ks_func_isSameAs_0(day, "tuesday")) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Weekday);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Weekday
	};
};