const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Quxbaz {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
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
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(x) {
			return Operator.multiplication(x, 1);
		}
		__ks_func_foobar_1(x) {
			return x;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Waldo extends Quxbaz {
		static __ks_new_0() {
			const o = Object.create(Waldo.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_foobar_0(x) {
			return Operator.multiplication(x, 2);
		}
	}
};