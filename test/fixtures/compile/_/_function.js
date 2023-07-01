const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = {};
	__ks_Function.__ks_sttc_vcurry_0 = function(self, bind = null, args) {
		return Helper.function((additionals) => {
			return self.apply(bind, args.concat(additionals));
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return fn.call(null, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		});
	};
	__ks_Function.__ks_func_toSource_0 = function() {
		return this.toString();
	};
	__ks_Function._sm_vcurry = function() {
		const t0 = Type.isFunction;
		const t1 = () => true;
		const t2 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(arguments.length >= 1) {
			if(t0(arguments[0]) && Helper.isVarargs(arguments, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(arguments, 0, arguments.length - 1, t2, pts, 1) && te(pts, 2)) {
				return __ks_Function.__ks_sttc_vcurry_0(arguments[0], Helper.getVararg(arguments, 1, pts[1]), Helper.getVarargs(arguments, pts[1], pts[2]));
			}
		}
		if(Function.vcurry) {
			return Function.vcurry(...arguments);
		}
		throw Helper.badArgs();
	};
	__ks_Function._im_toSource = function(that, ...args) {
		return __ks_Function.__ks_func_toSource_rt(that, args);
	};
	__ks_Function.__ks_func_toSource_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Function.__ks_func_toSource_0.call(that);
		}
		if(that.toSource) {
			return that.toSource(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Function
	};
};