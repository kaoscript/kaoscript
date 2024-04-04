require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array) {
	const PI = 3.14;
	if(!__ks_Array) {
		var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	}
	__ks_Array.__ks_func_contains_0 = function(item, from) {
		if(from === void 0 || from === null) {
			from = 0;
		}
		return this.indexOf(item, from) !== -1;
	};
	__ks_Array.__ks_func_pushUniq_0 = function(args) {
		if(args.length === 1) {
			if(!(__ks_Array.__ks_func_contains_0.call(this, args[0]) === true)) {
				this.push(args[0]);
			}
		}
		else {
			for(let __ks_1 = 0, __ks_0 = args.length, item; __ks_1 < __ks_0; ++__ks_1) {
				item = args[__ks_1];
				if(!(__ks_Array.__ks_func_contains_0.call(this, item) === true)) {
					this.push(item);
				}
			}
		}
		return this;
	};
	__ks_Array._im_contains = function(that, ...args) {
		return __ks_Array.__ks_func_contains_rt(that, args);
	};
	__ks_Array.__ks_func_contains_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0])) {
				return __ks_Array.__ks_func_contains_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	__ks_Array._im_pushUniq = function(that, ...args) {
		return __ks_Array.__ks_func_pushUniq_rt(that, args);
	};
	__ks_Array.__ks_func_pushUniq_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Array.__ks_func_pushUniq_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};