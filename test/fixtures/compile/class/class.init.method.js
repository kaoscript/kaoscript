const {Helper} = require("@kaoscript/runtime");
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
			this._foo = this.__ks_func_qux_0();
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		qux() {
			return this.__ks_func_qux_rt.call(null, this, this, arguments);
		}
		__ks_func_qux_0() {
			return 42;
		}
		__ks_func_qux_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_qux_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};