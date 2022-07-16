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
		__ks_func_foobar_0(a) {
			return 0;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_foobar_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_foobar_1(a) {
			return 1;
		}
		__ks_func_foobar_2(a, b) {
			return 2;
		}
		__ks_func_foobar_0(a) {
			if(a.length === 1) {
				if(Type.isNumber(a[0])) {
					return this.__ks_func_foobar_1(a[0]);
				}
			}
			return super.__ks_func_foobar_0(a);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
			}
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return proto.__ks_func_foobar_2.call(that, args[0], args[1]);
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, Foobar.prototype, args);
		}
	}
};