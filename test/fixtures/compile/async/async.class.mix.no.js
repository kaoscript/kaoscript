const {Helper, Operator, Type} = require("@kaoscript/runtime");
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
		__ks_func_foo_1(x, __ks_cb) {
			return __ks_cb(null, Operator.addOrConcat(x, 42));
		}
		__ks_func_foo_rt(that, proto, args) {
			const t0 = Type.isFunction;
			const t1 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foo_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t1(args[0]) && t0(args[1])) {
					return proto.__ks_func_foo_1.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
};