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
		toString() {
			return this.__ks_func_toString_rt.call(null, this, this, arguments);
		}
		__ks_func_toString_0() {
			return "foo";
		}
		__ks_func_toString_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_toString_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Bar {
		static __ks_new_0(...args) {
			const o = Object.create(Bar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(foo) {
			if(foo === void 0) {
				foo = null;
			}
			this._foo = foo;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isClassInstance(value, Foo) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return Bar.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0() {
			return this._foo;
		}
		__ks_func_foo_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foo_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Qux extends Bar {
		static __ks_new_0() {
			const o = Object.create(Qux.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		__ks_cons_0() {
			Bar.prototype.__ks_cons_0.call(this, Foo.__ks_new_0());
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Qux.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	return {
		Qux
	};
};