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
			this._values = [];
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(fn) {
			return (() => {
				const a = [];
				for(let index = 0, __ks_0 = this._values.length, value; index < __ks_0; ++index) {
					value = this._values[index];
					if(Type.isValue(value)) {
						a.push(fn(value, index, this));
					}
				}
				return a;
			})();
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
	}
};