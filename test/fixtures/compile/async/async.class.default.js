const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foo {
		static __ks_new_0() {
			const o = Object.create(Foo.prototype);
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
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0(__ks_cb) {
			return __ks_cb(null, 42);
		}
		__ks_func_foo_rt(that, proto, args) {
			const t0 = Type.isFunction;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foo_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};