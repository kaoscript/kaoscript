const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function $memoize() {
		return $memoize.__ks_rt(this, arguments);
	};
	$memoize.__ks_0 = function(hasher, bind, self, cache, args) {
		if(hasher === void 0) {
			hasher = null;
		}
		if(bind === void 0) {
			bind = null;
		}
	};
	$memoize.__ks_rt = function(that, args) {
		const t0 = value => Type.isFunction(value) || Type.isNull(value);
		const t1 = Type.isFunction;
		const t2 = Type.isObject;
		if(args.length >= 4) {
			if(t0(args[0]) && t1(args[2]) && t2(args[3])) {
				return $memoize.__ks_0.call(that, args[0], args[1], args[2], args[3], Array.from(args).slice(4));
			}
		}
		throw Helper.badArgs();
	};
	const __ks_Function = {};
	__ks_Function.__ks_func_memoize_0 = function(hasher = null, bind = null) {
		return Helper.curry((that, fn, ...args) => {
			return fn[0](Array.from(args));
		}, (__ks_0) => $memoize.__ks_0(hasher, bind, this, new OBJ(), __ks_0));
	};
	__ks_Function._im_memoize = function(that, ...args) {
		return __ks_Function.__ks_func_memoize_rt(that, args);
	};
	__ks_Function.__ks_func_memoize_rt = function(that, args) {
		const t0 = value => Type.isFunction(value) || Type.isNull(value);
		const t1 = () => true;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 2) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
				return __ks_Function.__ks_func_memoize_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		if(that.memoize) {
			return that.memoize(...args);
		}
		throw Helper.badArgs();
	};
};