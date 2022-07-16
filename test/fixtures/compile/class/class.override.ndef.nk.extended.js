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
		xyz() {
			return this.__ks_func_xyz_rt.call(null, this, this, arguments);
		}
		__ks_func_xyz_0(x, y, z) {
		}
		__ks_func_xyz_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 3) {
				if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
					return proto.__ks_func_xyz_0.call(that, args[0], args[1], args[2]);
				}
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
		__ks_func_xyz_1(xyz) {
		}
		__ks_func_xyz_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_xyz_1.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			return super.__ks_func_xyz_rt.call(null, that, Foobar.prototype, args);
		}
	}
};