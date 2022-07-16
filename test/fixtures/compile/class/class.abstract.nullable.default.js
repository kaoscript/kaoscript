const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Type {
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
	class FunctionType extends Type {
		static __ks_new_0() {
			const o = Object.create(FunctionType.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		equals() {
			return this.__ks_func_equals_rt.call(null, this, this, arguments);
		}
		__ks_func_equals_0(b) {
			if(b === void 0) {
				b = null;
			}
			return true;
		}
		__ks_func_equals_rt(that, proto, args) {
			if(args.length === 1) {
				return proto.__ks_func_equals_0.call(that, args[0]);
			}
			if(super.__ks_func_equals_rt) {
				return super.__ks_func_equals_rt.call(null, that, Type.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};