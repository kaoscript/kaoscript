const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(flag) {
			if(flag === void 0 || flag === null) {
				flag = false;
			}
			this._flag = flag;
			!this._flag && (this._flag = true);
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isBoolean(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return Foobar.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
};