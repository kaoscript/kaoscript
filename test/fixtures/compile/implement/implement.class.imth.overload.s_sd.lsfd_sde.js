const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_unquote_0 = function(quote, escape) {
		if(escape === void 0 || escape === null) {
			escape = "";
		}
		return __ks_String.__ks_func_unquote_1.call(this, [quote], escape);
	};
	__ks_String.__ks_func_unquote_1 = function(quote, escape) {
		if(quote === void 0 || quote === null) {
			quote = ["\"", "'"];
		}
		if(escape === void 0 || escape === null) {
			escape = "";
		}
		return this;
	};
	__ks_String._im_unquote = function(that, ...args) {
		return __ks_String.__ks_func_unquote_rt(that, args);
	};
	__ks_String.__ks_func_unquote_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = value => Type.isString(value) || Type.isNull(value);
		const t2 = value => Type.isArray(value, Type.isString) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return __ks_String.__ks_func_unquote_1.call(that);
		}
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0])) {
				if(Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
					return __ks_String.__ks_func_unquote_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
				}
				throw Helper.badArgs();
			}
			if(t2(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
				return __ks_String.__ks_func_unquote_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
			}
		}
		if(that.unquote) {
			return that.unquote(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_String
	};
};