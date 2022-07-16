const {Dictionary, Helper, Operator, Type} = require("@kaoscript/runtime");
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
		xy() {
			return this.__ks_func_xy_rt.call(null, this, this, arguments);
		}
		__ks_func_xy_0() {
			return (() => {
				const d = new Dictionary();
				d.xy = this.xy(this._x, this._y);
				return d;
			})();
		}
		__ks_func_xy_1(x, y) {
			return Operator.addOrConcat(x, y);
		}
		__ks_func_xy_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_xy_0.call(that);
			}
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return proto.__ks_func_xy_1.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
};