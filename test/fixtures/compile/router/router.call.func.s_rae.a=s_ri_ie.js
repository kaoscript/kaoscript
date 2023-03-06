const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, values) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
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
		__ks_func_foobar_0(values, more) {
			foobar.__ks_0(this._x, [...values, more]);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isArray(value, Type.isNumber);
			const t1 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return proto.__ks_func_foobar_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
};