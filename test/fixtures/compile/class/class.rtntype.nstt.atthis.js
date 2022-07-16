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
			this._value = "";
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		value() {
			return this.__ks_func_value_rt.call(null, this, this, arguments);
		}
		__ks_func_value_0() {
			return this._value;
		}
		__ks_func_value_1(value) {
			this._value = value;
			return this;
		}
		__ks_func_value_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return proto.__ks_func_value_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_value_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	const f = Foobar.__ks_new_0();
	console.log(f.__ks_func_value_1("foobar").__ks_func_value_0());
	return {
		Foobar
	};
};