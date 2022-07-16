const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Master {
		static __ks_new_0() {
			const o = Object.create(Master.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this.a = "";
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
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Foobar extends Master {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this.b = "";
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_foobar_1(a, b) {
			if(a === void 0 || a === null) {
				a = this.a;
			}
			if(b === void 0 || b === null) {
				b = this.b;
			}
			return b;
		}
		__ks_func_foobar_0(a) {
			return this.__ks_func_foobar_1(a);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
					return proto.__ks_func_foobar_1.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, Master.prototype, args);
		}
	}
	const f = Foobar.__ks_new_0();
	f.__ks_func_foobar_1("", "");
};