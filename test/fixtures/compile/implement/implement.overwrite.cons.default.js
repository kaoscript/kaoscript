const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_new_3 = function(...args) {
		return __ks_Date.__ks_cons_3(...args);
	};
	__ks_Date.__ks_cons_3 = function(year, month, day, hours, minutes, seconds, milliseconds) {
		if(day === void 0 || day === null) {
			day = 1;
		}
		if(hours === void 0 || hours === null) {
			hours = 0;
		}
		if(minutes === void 0 || minutes === null) {
			minutes = 0;
		}
		if(seconds === void 0 || seconds === null) {
			seconds = 0;
		}
		if(milliseconds === void 0 || milliseconds === null) {
			milliseconds = 0;
		}
		const that = new Date(year, Operator.subtraction(month, 1), day, hours, minutes, seconds, milliseconds);
		that.setUTCMinutes(that.getUTCMinutes() - that.getTimezoneOffset());
		return that;
	};
	__ks_Date.new = function() {
		const t0 = value => Type.isClassInstance(value, Date);
		const t1 = Type.isValue;
		const t2 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(arguments.length === 0) {
			return new Date();
		}
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return new Date(arguments[0]);
			}
			throw Helper.badArgs();
		}
		if(arguments.length >= 2 && arguments.length <= 7) {
			if(t1(arguments[0]) && t1(arguments[1])) {
				if(Helper.isVarargs(arguments, 0, 1, t2, pts = [2], 0) && Helper.isVarargs(arguments, 0, 1, t2, pts, 1) && Helper.isVarargs(arguments, 0, 1, t2, pts, 2) && Helper.isVarargs(arguments, 0, 1, t2, pts, 3) && Helper.isVarargs(arguments, 0, 1, t2, pts, 4) && te(pts, 5)) {
					return __ks_Date.__ks_cons_3(arguments[0], arguments[1], Helper.getVararg(arguments, 2, pts[1]), Helper.getVararg(arguments, pts[1], pts[2]), Helper.getVararg(arguments, pts[2], pts[3]), Helper.getVararg(arguments, pts[3], pts[4]), Helper.getVararg(arguments, pts[4], pts[5]));
				}
			}
		}
		throw Helper.badArgs();
	};
	const d1 = new Date();
	const d2 = new Date(d1);
	const d3 = __ks_Date.__ks_new_3(2000, 1, 1);
	return {
		Date,
		__ks_Date
	};
};