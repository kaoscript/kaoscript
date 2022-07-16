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
			this._foo = 42;
			this.bar = "foobar";
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0() {
			return this._foo;
		}
		__ks_func_foo_1(foo) {
			this._foo = foo;
			return this;
		}
		__ks_func_foo_rt(that, proto, args) {
			const t0 = Type.isNumber;
			if(args.length === 0) {
				return proto.__ks_func_foo_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foo_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};