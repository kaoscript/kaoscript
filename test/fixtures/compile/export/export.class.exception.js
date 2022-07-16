const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Error = {};
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
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0() {
		}
		__ks_func_foo_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foo_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Exception extends Error {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
		static __ks_sttc_throwFoobar_0(name) {
		}
		static throwFoobar() {
			const t0 = Type.isValue;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Exception.__ks_sttc_throwFoobar_0(arguments[0]);
				}
			}
			if(Error.throwFoobar) {
				return Error.throwFoobar.apply(null, arguments);
			}
			throw Helper.badArgs();
		}
	}
	return {
		Foobar,
		Exception
	};
};