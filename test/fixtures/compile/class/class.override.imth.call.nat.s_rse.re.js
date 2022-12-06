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
		__ks_func_foobar_0(items) {
			this.quxbaz.apply(this, [].concat(items));
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
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0(values) {
		}
		__ks_func_quxbaz_1(values) {
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			const t0 = Type.isString;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_quxbaz_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_quxbaz_1.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
};