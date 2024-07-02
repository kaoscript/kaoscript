const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const TypeA = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	class ClassA {
		static __ks_new_0(...args) {
			const o = Object.create(ClassA.prototype);
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
		__ks_cons_0(name) {
			this.name = name;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassA.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};