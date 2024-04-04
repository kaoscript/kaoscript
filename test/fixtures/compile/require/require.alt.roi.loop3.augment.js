require("kaoscript/register");
const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Date) {
	if(!__ks_Date) {
		var __ks_Date = require("./.require.alt.roi.loop3.genesis.ks.np51g.ksb")().__ks_Date;
	}
	__ks_Date.__ks_new_1 = function(...args) {
		return __ks_Date.__ks_cons_1(...args);
	};
	__ks_Date.__ks_cons_1 = function(year, month, day, hours, minutes, seconds, milliseconds) {
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
	__ks_Date.__ks_func_fromAugment_0 = function() {
	};
	__ks_Date.new = function() {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(arguments.length >= 2 && arguments.length <= 7) {
			if(t0(arguments[0]) && t0(arguments[1]) && Helper.isVarargs(arguments, 0, 1, t0, pts = [2], 0) && Helper.isVarargs(arguments, 0, 1, t0, pts, 1) && Helper.isVarargs(arguments, 0, 1, t0, pts, 2) && Helper.isVarargs(arguments, 0, 1, t0, pts, 3) && Helper.isVarargs(arguments, 0, 1, t0, pts, 4) && te(pts, 5)) {
				return __ks_Date.__ks_cons_1(arguments[0], arguments[1], Helper.getVararg(arguments, 2, pts[1]), Helper.getVararg(arguments, pts[1], pts[2]), Helper.getVararg(arguments, pts[2], pts[3]), Helper.getVararg(arguments, pts[3], pts[4]), Helper.getVararg(arguments, pts[4], pts[5]));
			}
		}
		throw Helper.badArgs();
	};
	__ks_Date._im_fromAugment = function(that, ...args) {
		return __ks_Date.__ks_func_fromAugment_rt(that, args);
	};
	__ks_Date.__ks_func_fromAugment_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_fromAugment_0.call(that);
		}
		throw Helper.badArgs();
	};
	const d = __ks_Date.__ks_new_1(2000, 1, 20, 3, 45, 6, 789);
	return {
		__ks_Date
	};
};