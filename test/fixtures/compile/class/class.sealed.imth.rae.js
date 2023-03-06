const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassA.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt(arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		__ks_func_foobar_0(args) {
		}
		foobar(...args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return this.__ks_func_foobar_0(Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
	const __ks_ClassA = {};
};