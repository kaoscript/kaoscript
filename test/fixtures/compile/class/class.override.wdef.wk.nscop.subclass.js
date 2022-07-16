require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = require("./.class.override.wdef.wk.nscop.master.ks.j5k8r9.ksb")().Foobar;
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
		__ks_func_foobar_0(x) {
			if(x === void 0 || x === null) {
				x = "";
			}
			return x;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return proto.__ks_func_foobar_0.call(that, Helper.getVararg(args, 0, pts[1]));
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