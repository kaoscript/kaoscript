const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassZ {
		static __ks_new_0(...args) {
			const o = Object.create(ClassZ.prototype);
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
		__ks_cons_0(values) {
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isArray(value, value => Type.isClassInstance(value, ClassA));
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassZ.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassA.prototype);
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
	}
};