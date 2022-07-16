const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_func_setDate_1 = function(value, flag) {
		if(flag === void 0 || flag === null) {
			flag = true;
		}
		this.setDate(value);
		return this;
	};
	__ks_Date._im_setDate = function(that, ...args) {
		return __ks_Date.__ks_func_setDate_rt(that, args);
	};
	__ks_Date.__ks_func_setDate_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isBoolean(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
				return __ks_Date.__ks_func_setDate_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(d) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Date);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const d = new Date();
	foobar.__ks_0(__ks_Date.__ks_func_setDate_1.call(d, 1));
	return {
		Date,
		__ks_Date
	};
};