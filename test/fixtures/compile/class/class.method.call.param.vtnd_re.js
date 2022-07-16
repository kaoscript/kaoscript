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
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0(x = null, items) {
			return Helper.concatString("[", x, ", ", items, "]");
		}
		__ks_func_foo_rt(that, proto, args) {
			const t0 = value => Type.isNumber(value) || Type.isNull(value);
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, args.length, t1, pts, 1) && te(pts, 2)) {
				return proto.__ks_func_foo_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		}
	}
	const x = Foobar.__ks_new_0();
	console.log(x.__ks_func_foo_0(void 0, []));
	console.log(x.__ks_func_foo_0(1, []));
	console.log(x.__ks_func_foo_0(void 0, ["foo"]));
	console.log(x.__ks_func_foo_0(1, [2]));
	console.log(x.__ks_func_foo_0(void 0, ["foo", 1]));
};