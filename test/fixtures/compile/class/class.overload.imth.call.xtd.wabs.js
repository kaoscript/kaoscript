const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
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
	class ClassB extends ClassA {
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_1(x, y) {
			return this.__ks_func_foobar_0(x);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return proto.__ks_func_foobar_1.call(that, args[0], args[1]);
				}
			}
			if(super.__ks_func_foobar_rt) {
				return super.__ks_func_foobar_rt.call(null, that, ClassA.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};