const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, "MONDAY", 0, "TUESDAY", 1, "WEDNESDAY", 2, "THURSDAY", 3, "FRIDAY", 4, "SATURDAY", 5, "SUNDAY", 6);
	Weekday.__ks_func_foobar_0 = function(that, values, x, y, z) {
		return false;
	};
	Weekday.__ks_func_foobar = function(that, ...args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 3) {
			if(Helper.isVarargs(args, 0, args.length - 3, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && Helper.isVarargs(args, 1, 1, t0, pts, 2) && Helper.isVarargs(args, 1, 1, t0, pts, 3) && te(pts, 4)) {
				return Weekday.__ks_func_foobar_0(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(day) {
		if(Weekday.__ks_func_foobar_0(day, [], 1, 2, 3)) {
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