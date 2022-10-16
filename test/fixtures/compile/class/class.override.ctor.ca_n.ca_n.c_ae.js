const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x) {
			this._x = x;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassA.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class ClassB extends ClassA {
		__ks_cons_0(x) {
			ClassA.prototype.__ks_cons_0.call(this, x);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassB.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class ClassC extends ClassB {
		static __ks_new_0(...args) {
			const o = Object.create(ClassC.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(x) {
			ClassB.prototype.__ks_cons_rt.call(null, this, [x]);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassC.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};