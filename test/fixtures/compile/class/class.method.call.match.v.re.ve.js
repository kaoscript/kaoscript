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
		alt() {
			return this.__ks_func_alt_rt.call(null, this, this, arguments);
		}
		__ks_func_alt_0() {
			return this.__ks_func_test_0("");
		}
		__ks_func_alt_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_alt_0.call(that);
			}
			throw Helper.badArgs();
		}
		test() {
			return this.__ks_func_test_rt.call(null, this, this, arguments);
		}
		__ks_func_test_0(token) {
			return true;
		}
		__ks_func_test_1(tokens) {
			return true;
		}
		__ks_func_test_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_test_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_test_1.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
};