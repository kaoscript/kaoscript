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
		equals() {
			return this.__ks_func_equals_rt.call(null, this, this, arguments);
		}
		__ks_func_equals_0(b) {
		}
		__ks_func_equals_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Foo);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_equals_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	return {
		Foo
	};
};