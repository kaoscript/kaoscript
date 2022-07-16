require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = require("./.class.override.wdef.wk.wscop.warg.master.ks.j5k8r9.ksb")().Foobar;
	class Quxbaz extends Foobar {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(x, y) {
			if(y === void 0 || y === null) {
				y = this.__ks_default_0_0(x);
			}
			return y;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
					return proto.__ks_func_foobar_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
				}
			}
			if(super.__ks_func_foobar_rt) {
				return super.__ks_func_foobar_rt.call(null, that, Foobar.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	return {
		Foobar,
		Quxbaz
	};
};