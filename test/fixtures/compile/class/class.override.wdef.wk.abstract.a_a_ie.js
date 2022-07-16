const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foo {
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
	}
	class Bar extends Foo {
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	class Qux extends Bar {
		static __ks_new_0() {
			const o = Object.create(Qux.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		greet() {
			return this.__ks_func_greet_rt.call(null, this, this, arguments);
		}
		__ks_func_greet_0(name) {
			return Helper.concatString("Hello ", name, "!");
		}
		__ks_func_greet_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_greet_0.call(that, args[0]);
				}
			}
			if(super.__ks_func_greet_rt) {
				return super.__ks_func_greet_rt.call(null, that, Bar.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};