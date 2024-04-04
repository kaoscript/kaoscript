const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Number = {};
	__ks_Number.__ks_func_limit_0 = function(min, max) {
		return isNaN(this) ? min : Math.min(max, Math.max(min, this));
	};
	__ks_Number.__ks_func_mod_0 = function(max) {
		if(isNaN(this)) {
			return 0;
		}
		else {
			let n = this % max;
			if(n < 0) {
				return n + max;
			}
			else {
				return n;
			}
		}
	};
	__ks_Number.__ks_func_round_0 = function(precision) {
		if(precision === void 0 || precision === null) {
			precision = 0;
		}
		const p = Math.pow(10, precision).toFixed(0);
		return Math.round(this * p) / p;
	};
	__ks_Number.__ks_func_toFloat_0 = function() {
		return parseFloat(this);
	};
	__ks_Number.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		return parseInt(this, base);
	};
	__ks_Number._im_limit = function(that, ...args) {
		return __ks_Number.__ks_func_limit_rt(that, args);
	};
	__ks_Number.__ks_func_limit_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_Number.__ks_func_limit_0.call(that, args[0], args[1]);
			}
		}
		if(that.limit) {
			return that.limit(...args);
		}
		throw Helper.badArgs();
	};
	__ks_Number._im_mod = function(that, ...args) {
		return __ks_Number.__ks_func_mod_rt(that, args);
	};
	__ks_Number.__ks_func_mod_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Number.__ks_func_mod_0.call(that, args[0]);
			}
		}
		if(that.mod) {
			return that.mod(...args);
		}
		throw Helper.badArgs();
	};
	__ks_Number._im_round = function(that, ...args) {
		return __ks_Number.__ks_func_round_rt(that, args);
	};
	__ks_Number.__ks_func_round_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_Number.__ks_func_round_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		if(that.round) {
			return that.round(...args);
		}
		throw Helper.badArgs();
	};
	__ks_Number._im_toFloat = function(that, ...args) {
		return __ks_Number.__ks_func_toFloat_rt(that, args);
	};
	__ks_Number.__ks_func_toFloat_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Number.__ks_func_toFloat_0.call(that);
		}
		if(that.toFloat) {
			return that.toFloat(...args);
		}
		throw Helper.badArgs();
	};
	__ks_Number._im_toInt = function(that, ...args) {
		return __ks_Number.__ks_func_toInt_rt(that, args);
	};
	__ks_Number.__ks_func_toInt_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_Number.__ks_func_toInt_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		if(that.toInt) {
			return that.toInt(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Number
	};
};