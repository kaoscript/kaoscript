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
		__ks_func_foobar_0(c) {
			if(c === void 0 || c === null) {
				c = true;
			}
			return 0;
		}
		__ks_func_foobar_1(c, d) {
			if(c === void 0 || c === null) {
				c = 0;
			}
			return 1;
		}
		__ks_func_foobar_2(c, d, e, f) {
			if(f === void 0 || f === null) {
				f = true;
			}
			return 2;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isNumber(value) || Type.isString(value);
			const t1 = value => Type.isBoolean(value) || Type.isNull(value);
			const t2 = value => Type.isNumber(value) || Type.isString(value) || Type.isNull(value);
			const t3 = value => Type.isString(value) || Type.isDictionary(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, void 0, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t2(args[0]) && t0(args[1])) {
					return proto.__ks_func_foobar_1.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(args.length >= 3 && args.length <= 4) {
				if(t0(args[0]) && t0(args[1]) && t3(args[2]) && Helper.isVarargs(args, 0, 1, t1, pts = [3], 0) && te(pts, 1)) {
					return proto.__ks_func_foobar_2.call(that, args[0], args[1], args[2], Helper.getVararg(args, 3, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
};