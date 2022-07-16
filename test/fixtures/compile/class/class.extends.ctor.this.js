const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
	class ClassB extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassB.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(ClassB.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._x = 42;
		}
		__ks_cons_0() {
		}
		__ks_cons_1(x) {
			ClassB.prototype.__ks_cons_0.call(this);
			this._x = x;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 0) {
				return ClassB.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassB.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class ClassC extends ClassA {
		static __ks_new_0(...args) {
			const o = Object.create(ClassC.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(ClassC.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		__ks_cons_0(name) {
			ClassC.prototype.__ks_cons_1.call(this, name, "home");
		}
		__ks_cons_1(name, domain) {
			this._name = name;
			this._domain = domain;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassC.prototype.__ks_cons_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return ClassC.prototype.__ks_cons_1.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
};