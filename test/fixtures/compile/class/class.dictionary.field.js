const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
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
		data() {
			return this.__ks_func_data_rt.call(null, this, this, arguments);
		}
		__ks_func_data_0(values) {
			values.push((() => {
				const d = new Dictionary();
				d.value = this._value.name();
				return d;
			})());
		}
		__ks_func_data_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_data_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};