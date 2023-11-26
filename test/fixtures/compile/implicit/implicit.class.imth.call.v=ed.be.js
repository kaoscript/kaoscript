const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const ANSIColor = Helper.enum(Number, 0, "BLACK", 0, "RED", 1, "GREEN", 2, "YELLOW", 3, "BLUE", 4, "MAGENTA", 5, "CYAN", 6, "WHITE", 7, "DEFAULT", 8);
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
		__ks_func_foobar_0() {
			this.__ks_func_quxbaz_0(ANSIColor.YELLOW, true);
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0(color, flag) {
			if(color === void 0 || color === null) {
				color = ANSIColor.BLACK;
			}
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			const t0 = value => Type.isEnumInstance(value, ANSIColor) || Type.isNull(value);
			const t1 = Type.isBoolean;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return proto.__ks_func_quxbaz_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
	}
};