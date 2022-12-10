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
		__ks_cons_0(values) {
			this._values = values;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Foobar.prototype.__ks_cons_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
	const f = Foobar.__ks_new_0([]);
};