const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_quote_0 = function(quote, escape) {
		if(quote === void 0 || quote === null) {
			quote = "\"";
		}
		return Operator.add(quote, this.replaceAll(escape, Operator.add(escape, escape)).replaceAll(quote, Operator.add(escape, quote)), quote);
	};
	__ks_String.__ks_func_replaceAll_0 = function(find, replacement) {
		return this;
	};
	__ks_String._im_quote = function(that, ...args) {
		return __ks_String.__ks_func_quote_rt(that, args);
	};
	__ks_String.__ks_func_quote_rt = function(that, args) {
		const t0 = () => true;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
				return __ks_String.__ks_func_quote_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		if(that.quote) {
			return that.quote(...args);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_replaceAll = function(that, ...args) {
		return __ks_String.__ks_func_replaceAll_rt(that, args);
	};
	__ks_String.__ks_func_replaceAll_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_String.__ks_func_replaceAll_0.call(that, args[0], args[1]);
			}
		}
		if(that.replaceAll) {
			return that.replaceAll(...args);
		}
		throw Helper.badArgs();
	};
};