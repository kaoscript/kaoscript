const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function shouldSaturday() {
		return shouldSaturday.__ks_rt(this, arguments);
	};
	shouldSaturday.__ks_0 = function() {
		return true;
	};
	shouldSaturday.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return shouldSaturday.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const Weekday = Helper.enum(Number, 0, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	Weekday.__ks_func_isWeekend_0 = function(that, sat) {
		if(sat === void 0 || sat === null) {
			sat = Weekday.__ks_default_0();
		}
		return (sat && (that === Weekday.SATURDAY)) || (that === Weekday.SUNDAY);
	};
	Weekday.__ks_default_0 = function() {
		return shouldSaturday.__ks_0();
	};
	Weekday.__ks_func_isWeekend = function(that, ...args) {
		const t0 = value => Type.isBoolean(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return Weekday.__ks_func_isWeekend_0(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	Weekday.__ks_func_isWeekend_0 = function(that, sat) {
		if(sat === void 0 || sat === null) {
			sat = Weekday.__ks_default_0();
		}
		return (sat && (that === Weekday.FRIDAY || that === Weekday.SATURDAY)) || (that === Weekday.SUNDAY);
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day) {
		if(Weekday.__ks_func_isWeekend_0(day)) {
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