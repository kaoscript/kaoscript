const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(pattern, position, __ks_default_1) {
			if(position === void 0 || position === null) {
				position = 0;
			}
			if(__ks_default_1 === void 0 || __ks_default_1 === null) {
				__ks_default_1 = "";
			}
		}
		__ks_func_foobar_1(pattern, position, __ks_default_1) {
			if(position === void 0 || position === null) {
				position = 0;
			}
			if(__ks_default_1 === void 0 || __ks_default_1 === null) {
				__ks_default_1 = "";
			}
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = value => Type.isBoolean(value) || Type.isNumber(value) || Type.isNull(value);
			const t2 = value => Type.isString(value) || Type.isNull(value);
			const t3 = Type.isRegExp;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 3) {
				if(t0(args[0])) {
					if(Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
						return proto.__ks_func_foobar_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
					throw Helper.badArgs();
				}
				if(t3(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
					return proto.__ks_func_foobar_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
	}
};