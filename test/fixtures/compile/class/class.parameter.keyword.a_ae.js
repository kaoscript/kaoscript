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
			this._class = null;
			this._default = -1;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(__ks_class_1, __ks_default_1) {
			if(__ks_class_1 === void 0) {
				__ks_class_1 = null;
			}
			if(__ks_default_1 === void 0 || __ks_default_1 === null) {
				__ks_default_1 = 0;
			}
			this._class = __ks_class_1;
			this._default = __ks_default_1;
			console.log(this._class, this._default);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const t1 = value => Type.isNumber(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
					return proto.__ks_func_foobar_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
};